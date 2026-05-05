import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_provider.dart';
import '../cache/cache_store.dart';
import '../cache/cache_entry.dart';
import '../cache/cache_policy.dart';

/// Hasil dari provider chain request — bawa metadata source
class ProviderChainResult<T> {
  final T data;
  final String providerId;
  final bool fromCache;
  final bool stale;
  final int? statusCode;
  final Duration latency;

  const ProviderChainResult({
    required this.data,
    required this.providerId,
    this.fromCache = false,
    this.stale = false,
    this.statusCode,
    this.latency = Duration.zero,
  });
}

/// Record kegagalan satu provider
class ApiProviderFailure {
  final String providerId;
  final String message;
  final int? statusCode;
  final Duration latency;

  const ApiProviderFailure({
    required this.providerId,
    required this.message,
    this.statusCode,
    this.latency = Duration.zero,
  });

  @override
  String toString() => 'Failure($providerId: $message, ${statusCode ?? "no status"})';
}

/// Exception typed — semua provider gagal
class AllProvidersFailedException implements Exception {
  final String path;
  final List<ApiProviderFailure> failures;

  const AllProvidersFailedException({required this.path, required this.failures});

  @override
  String toString() => 'Semua provider gagal untuk $path: ${failures.map((f) => f.providerId).join(", ")}';

  /// User-friendly message
  String get userMessage {
    if (failures.any((f) => f.statusCode == 503 || f.statusCode == 429)) {
      return 'Server PDDIKTI sedang sibuk. Coba lagi dalam beberapa menit.';
    }
    if (failures.any((f) => f.message.contains('Timeout'))) {
      return 'Koneksi timeout. Periksa internet dan coba lagi.';
    }
    return 'Gagal terhubung ke server. Periksa koneksi internet.';
  }
}

/// Exception typed — single provider error
class ApiProviderException implements Exception {
  final String message;
  final String? providerId;
  final int? statusCode;
  final Object? cause;

  const ApiProviderException({
    required this.message,
    this.providerId,
    this.statusCode,
    this.cause,
  });

  @override
  String toString() => 'ApiProviderException($providerId: $message)';
}

/// Provider Chain Service — orchestrate request across multiple providers
/// dengan cache fresh/stale, latency tracking, dan typed errors
class ProviderChainService {
  final List<ApiProvider> providers;
  final CacheStore cacheStore;
  final http.Client httpClient;

  /// Headers default — simple, no spoofing
  static const Map<String, String> _defaultHeaders = {
    'Accept': 'application/json',
    'User-Agent': 'DB-Cracker-App/3.0',
  };

  ProviderChainService({
    required this.providers,
    required this.cacheStore,
    required this.httpClient,
  });

  /// Request dengan provider chain + cache
  /// [path] = endpoint path tanpa base URL (e.g. "/search/mhs/akbar/")
  /// [cachePolicy] = TTL fresh/stale
  /// [decoder] = function untuk decode JSON response ke type T
  Future<ProviderChainResult<T>> request<T>({
    required String path,
    required CachePolicy cachePolicy,
    required T Function(dynamic json) decoder,
  }) async {
    final cacheKey = 'pddikti:$path';

    // 1. Cek fresh cache
    final cached = await cacheStore.get(cacheKey);
    if (cached != null && cached.isFresh) {
      try {
        final data = decoder(json.decode(cached.body));
        return ProviderChainResult<T>(
          data: data,
          providerId: 'cache:${cached.source}',
          fromCache: true,
          stale: false,
          latency: Duration.zero,
        );
      } catch (_) {
        // Cache corrupt, lanjut ke network
        await cacheStore.delete(cacheKey);
      }
    }

    // 2. Iterasi provider berdasarkan priority
    final enabledProviders = providers.where((p) => p.enabled).toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));

    final failures = <ApiProviderFailure>[];

    for (final provider in enabledProviders) {
      final stopwatch = Stopwatch()..start();
      try {
        final url = Uri.parse('${provider.baseUrl}$path');
        final response = await httpClient
            .get(url, headers: _defaultHeaders)
            .timeout(provider.timeout);
        stopwatch.stop();

        // Cek retryable status
        if (provider.retryableStatusCodes.contains(response.statusCode)) {
          failures.add(ApiProviderFailure(
            providerId: provider.id,
            message: 'Status ${response.statusCode}',
            statusCode: response.statusCode,
            latency: stopwatch.elapsed,
          ));
          continue; // Coba provider berikutnya
        }

        // Non-200 non-retryable = error final
        if (response.statusCode != 200) {
          failures.add(ApiProviderFailure(
            providerId: provider.id,
            message: 'Status ${response.statusCode}',
            statusCode: response.statusCode,
            latency: stopwatch.elapsed,
          ));
          continue;
        }

        // 3. Decode JSON sekali
        final dynamic jsonData = json.decode(response.body);
        final T data = decoder(jsonData);

        // 4. Simpan ke cache
        await cacheStore.put(CacheEntry(
          key: cacheKey,
          body: response.body,
          createdAt: DateTime.now(),
          freshUntil: DateTime.now().add(cachePolicy.freshTtl),
          staleUntil: DateTime.now().add(cachePolicy.staleTtl),
          source: provider.id,
          statusCode: 200,
        ));

        return ProviderChainResult<T>(
          data: data,
          providerId: provider.id,
          fromCache: false,
          stale: false,
          statusCode: 200,
          latency: stopwatch.elapsed,
        );
      } on FormatException catch (e) {
        stopwatch.stop();
        failures.add(ApiProviderFailure(
          providerId: provider.id,
          message: 'JSON invalid: ${e.message}',
          latency: stopwatch.elapsed,
        ));
      } catch (e) {
        stopwatch.stop();
        final msg = e.toString().contains('TimeoutException')
            ? 'Timeout (${provider.timeout.inSeconds}s)'
            : e.toString().length > 100
                ? '${e.toString().substring(0, 100)}...'
                : e.toString();
        failures.add(ApiProviderFailure(
          providerId: provider.id,
          message: msg,
          latency: stopwatch.elapsed,
        ));
      }
    }

    // 5. Semua provider gagal — cek stale cache
    if (cached != null && cached.isStale && cachePolicy.allowStaleOnFailure) {
      try {
        final data = decoder(json.decode(cached.body));
        if (kDebugMode) debugPrint('ProviderChain: returning stale cache for $path');
        return ProviderChainResult<T>(
          data: data,
          providerId: 'stale-cache:${cached.source}',
          fromCache: true,
          stale: true,
          latency: Duration.zero,
        );
      } catch (_) {
        // Stale cache juga corrupt
      }
    }

    // 6. Tidak ada data sama sekali
    throw AllProvidersFailedException(path: path, failures: failures);
  }
}
