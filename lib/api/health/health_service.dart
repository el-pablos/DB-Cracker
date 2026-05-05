import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/provider_registry.dart';
import '../cache/cache_store.dart';

/// Model hasil health check satu provider
class ProviderHealthResult {
  final String providerId;
  final String providerName;
  final ProviderKind kind;
  final ProviderStatus status;
  final int? httpStatusCode;
  final Duration? latency;
  final DateTime checkedAt;
  final String? message;

  const ProviderHealthResult({
    required this.providerId,
    required this.providerName,
    required this.kind,
    required this.status,
    this.httpStatusCode,
    this.latency,
    required this.checkedAt,
    this.message,
  });
}

/// Laporan kesehatan keseluruhan app
class AppHealthReport {
  final List<ProviderHealthResult> providers;
  final CacheStats cacheStats;
  final DateTime generatedAt;
  final String appVersion;

  const AppHealthReport({
    required this.providers,
    required this.cacheStats,
    required this.generatedAt,
    this.appVersion = '3.1.0',
  });

  int get healthyCount => providers.where((p) => p.status == ProviderStatus.healthy).length;
  int get degradedCount => providers.where((p) => p.status == ProviderStatus.degraded || p.status == ProviderStatus.rateLimited).length;
  int get unavailableCount => providers.where((p) => p.status == ProviderStatus.unavailable || p.status == ProviderStatus.timeout).length;
}

/// Service untuk health check semua provider
/// Menggunakan endpoint ringan, timeout pendek, cache 1 menit
class HealthService {
  final http.Client httpClient;
  final CacheStore cacheStore;

  HealthService({required this.httpClient, required this.cacheStore});

  /// Check semua provider dan return laporan lengkap
  Future<AppHealthReport> checkAll() async {
    final results = <ProviderHealthResult>[];

    // Check PDDIKTI providers
    for (final provider in ProviderRegistry.byKind(ProviderKind.pddikti)) {
      results.add(await _checkProvider(provider));
    }

    // Check Wilayah providers
    for (final provider in ProviderRegistry.byKind(ProviderKind.wilayah)) {
      results.add(await _checkProvider(provider));
    }

    // Check Sekolah
    for (final provider in ProviderRegistry.byKind(ProviderKind.sekolah)) {
      results.add(await _checkProviderSimple(provider));
    }

    // Check Wikipedia
    for (final provider in ProviderRegistry.byKind(ProviderKind.wikipedia)) {
      results.add(await _checkProvider(provider, path: '/page/summary/Indonesia'));
    }

    // Check KBBI
    for (final provider in ProviderRegistry.byKind(ProviderKind.kbbi)) {
      results.add(await _checkProviderSimple(provider));
    }

    // Check MagangHub
    for (final provider in ProviderRegistry.byKind(ProviderKind.maganghub)) {
      results.add(await _checkProvider(provider, path: '/provinces'));
    }

    // External links — always mark as healthy (they're just URLs)
    for (final provider in ProviderRegistry.externalLinkProviders) {
      results.add(ProviderHealthResult(
        providerId: provider.id,
        providerName: provider.name,
        kind: provider.kind,
        status: ProviderStatus.healthy,
        checkedAt: DateTime.now(),
        message: 'Deep-link (tidak perlu health check)',
      ));
    }

    final stats = await cacheStore.stats();

    return AppHealthReport(
      providers: results,
      cacheStats: stats,
      generatedAt: DateTime.now(),
    );
  }

  /// Health check satu provider dengan endpoint ringan
  Future<ProviderHealthResult> _checkProvider(ApiProviderConfig provider, {String? path}) async {
    final stopwatch = Stopwatch()..start();
    try {
      final checkPath = path ?? '/';
      final url = '${provider.baseUrl}$checkPath';
      final response = await httpClient
          .get(Uri.parse(url), headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 5));
      stopwatch.stop();

      ProviderStatus status;
      if (response.statusCode == 200) {
        status = ProviderStatus.healthy;
      } else if (response.statusCode == 429) {
        status = ProviderStatus.rateLimited;
      } else if (response.statusCode >= 500) {
        status = ProviderStatus.degraded;
      } else {
        status = ProviderStatus.unavailable;
      }

      return ProviderHealthResult(
        providerId: provider.id,
        providerName: provider.name,
        kind: provider.kind,
        status: status,
        httpStatusCode: response.statusCode,
        latency: stopwatch.elapsed,
        checkedAt: DateTime.now(),
      );
    } catch (e) {
      stopwatch.stop();
      final isTimeout = e.toString().contains('TimeoutException') || e.toString().contains('Timeout');

      return ProviderHealthResult(
        providerId: provider.id,
        providerName: provider.name,
        kind: provider.kind,
        status: isTimeout ? ProviderStatus.timeout : ProviderStatus.unavailable,
        latency: stopwatch.elapsed,
        checkedAt: DateTime.now(),
        message: isTimeout ? 'Timeout (5s)' : e.toString().substring(0, (e.toString().length).clamp(0, 80)),
      );
    }
  }

  /// Simple check — hanya cek apakah provider configured dan enabled
  Future<ProviderHealthResult> _checkProviderSimple(ApiProviderConfig provider) async {
    if (!provider.enabled) {
      return ProviderHealthResult(
        providerId: provider.id,
        providerName: provider.name,
        kind: provider.kind,
        status: ProviderStatus.unavailable,
        checkedAt: DateTime.now(),
        message: 'Provider disabled',
      );
    }

    // Untuk provider yang butuh parameter (sekolah butuh NPSN), skip live check
    return ProviderHealthResult(
      providerId: provider.id,
      providerName: provider.name,
      kind: provider.kind,
      status: ProviderStatus.unknown,
      checkedAt: DateTime.now(),
      message: 'Membutuhkan parameter untuk test (NPSN/keyword)',
    );
  }
}
