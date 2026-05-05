import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:db_cracker_tamaengs/api/providers/api_provider.dart';
import 'package:db_cracker_tamaengs/api/providers/provider_chain.dart';
import 'package:db_cracker_tamaengs/api/cache/cache_store.dart';
import 'package:db_cracker_tamaengs/api/cache/cache_entry.dart';
import 'package:db_cracker_tamaengs/api/cache/cache_policy.dart';
import 'package:db_cracker_tamaengs/api/cache/in_memory_cache_store.dart';

void main() {
  late InMemoryCacheStore cacheStore;
  late List<ApiProvider> providers;

  final testPolicy = const CachePolicy(
    freshTtl: Duration(minutes: 5),
    staleTtl: Duration(hours: 1),
  );

  setUp(() {
    cacheStore = InMemoryCacheStore(maxEntries: 50);
    providers = [
      const ApiProvider(
        id: 'primary',
        name: 'Primary',
        baseUrl: 'https://primary.test/api',
        priority: 1,
      ),
      const ApiProvider(
        id: 'fallback',
        name: 'Fallback',
        baseUrl: 'https://fallback.test/api',
        priority: 2,
      ),
    ];
  });

  List<String> decoder(dynamic json) {
    if (json is List) return json.map((e) => e.toString()).toList();
    return [];
  }

  group('ProviderChainService', () {
    test('1. provider pertama sukses, provider kedua tidak dipanggil', () async {
      final requestedUrls = <String>[];
      final client = MockClient((request) async {
        requestedUrls.add(request.url.toString());
        return http.Response(json.encode(['data1', 'data2']), 200);
      });

      final service = ProviderChainService(
        providers: providers,
        cacheStore: cacheStore,
        httpClient: client,
      );

      final result = await service.request<List<String>>(
        path: '/search/mhs/test/',
        cachePolicy: testPolicy,
        decoder: decoder,
      );

      expect(result.data, ['data1', 'data2']);
      expect(result.providerId, 'primary');
      expect(result.fromCache, false);
      expect(requestedUrls.length, 1);
      expect(requestedUrls.first, contains('primary.test'));
    });

    test('2. provider pertama 503, provider kedua sukses', () async {
      final requestedUrls = <String>[];
      final client = MockClient((request) async {
        requestedUrls.add(request.url.host);
        if (request.url.host == 'primary.test') {
          return http.Response('Service Unavailable', 503);
        }
        return http.Response(json.encode(['fallback_data']), 200);
      });

      final service = ProviderChainService(
        providers: providers,
        cacheStore: cacheStore,
        httpClient: client,
      );

      final result = await service.request<List<String>>(
        path: '/search/mhs/test/',
        cachePolicy: testPolicy,
        decoder: decoder,
      );

      expect(result.data, ['fallback_data']);
      expect(result.providerId, 'fallback');
      expect(requestedUrls.length, 2);
    });

    test('3. provider pertama timeout, provider kedua sukses', () async {
      final client = MockClient((request) async {
        if (request.url.host == 'primary.test') {
          await Future.delayed(const Duration(seconds: 15));
          return http.Response('', 200);
        }
        return http.Response(json.encode(['ok']), 200);
      });

      final shortTimeoutProviders = [
        const ApiProvider(
          id: 'primary',
          name: 'Primary',
          baseUrl: 'https://primary.test/api',
          priority: 1,
          timeout: Duration(milliseconds: 100), // Very short for test
        ),
        const ApiProvider(
          id: 'fallback',
          name: 'Fallback',
          baseUrl: 'https://fallback.test/api',
          priority: 2,
          timeout: Duration(seconds: 5),
        ),
      ];

      final service = ProviderChainService(
        providers: shortTimeoutProviders,
        cacheStore: cacheStore,
        httpClient: client,
      );

      final result = await service.request<List<String>>(
        path: '/search/mhs/test/',
        cachePolicy: testPolicy,
        decoder: decoder,
      );

      expect(result.data, ['ok']);
      expect(result.providerId, 'fallback');
    });

    test('4. semua provider gagal, stale cache ada, return stale', () async {
      // Pre-populate stale cache
      await cacheStore.put(CacheEntry(
        key: 'pddikti:/search/mhs/test/',
        body: json.encode(['stale_data']),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        freshUntil: DateTime.now().subtract(const Duration(hours: 1)), // expired fresh
        staleUntil: DateTime.now().add(const Duration(hours: 23)), // still stale-valid
        source: 'old_provider',
      ));

      final client = MockClient((request) async {
        return http.Response('Error', 500);
      });

      final service = ProviderChainService(
        providers: providers,
        cacheStore: cacheStore,
        httpClient: client,
      );

      final result = await service.request<List<String>>(
        path: '/search/mhs/test/',
        cachePolicy: testPolicy,
        decoder: decoder,
      );

      expect(result.data, ['stale_data']);
      expect(result.fromCache, true);
      expect(result.stale, true);
      expect(result.providerId, contains('stale-cache'));
    });

    test('5. semua provider gagal dan stale cache tidak ada, throw AllProvidersFailedException', () async {
      final client = MockClient((request) async {
        return http.Response('Error', 500);
      });

      final service = ProviderChainService(
        providers: providers,
        cacheStore: cacheStore,
        httpClient: client,
      );

      expect(
        () => service.request<List<String>>(
          path: '/search/mhs/notfound/',
          cachePolicy: testPolicy,
          decoder: decoder,
        ),
        throwsA(isA<AllProvidersFailedException>()),
      );
    });

    test('6. cache key membedakan endpoint dan query', () async {
      final client = MockClient((request) async {
        final keyword = request.url.pathSegments.last;
        return http.Response(json.encode([keyword]), 200);
      });

      final service = ProviderChainService(
        providers: providers,
        cacheStore: cacheStore,
        httpClient: client,
      );

      await service.request<List<String>>(
        path: '/search/mhs/akbar/',
        cachePolicy: testPolicy,
        decoder: decoder,
      );

      await service.request<List<String>>(
        path: '/search/mhs/budi/',
        cachePolicy: testPolicy,
        decoder: decoder,
      );

      final stats = await cacheStore.stats();
      expect(stats.totalEntries, 2);
    });

    test('7. retryable status tidak disimpan sebagai cache sukses', () async {
      final client = MockClient((request) async {
        return http.Response('Service Unavailable', 503);
      });

      final service = ProviderChainService(
        providers: providers,
        cacheStore: cacheStore,
        httpClient: client,
      );

      try {
        await service.request<List<String>>(
          path: '/search/mhs/fail/',
          cachePolicy: testPolicy,
          decoder: decoder,
        );
      } catch (_) {}

      final cached = await cacheStore.get('pddikti:/search/mhs/fail/');
      expect(cached, isNull);
    });

    test('8. response JSON invalid menghasilkan error typed', () async {
      final client = MockClient((request) async {
        return http.Response('not json {{{', 200);
      });

      final service = ProviderChainService(
        providers: providers,
        cacheStore: cacheStore,
        httpClient: client,
      );

      expect(
        () => service.request<List<String>>(
          path: '/search/mhs/badjson/',
          cachePolicy: testPolicy,
          decoder: decoder,
        ),
        throwsA(isA<AllProvidersFailedException>()),
      );
    });

    test('9. provider disabled tidak dipakai', () async {
      final requestedUrls = <String>[];
      final client = MockClient((request) async {
        requestedUrls.add(request.url.host);
        return http.Response(json.encode(['ok']), 200);
      });

      final mixedProviders = [
        const ApiProvider(
          id: 'disabled',
          name: 'Disabled',
          baseUrl: 'https://disabled.test/api',
          priority: 1,
          enabled: false,
        ),
        const ApiProvider(
          id: 'active',
          name: 'Active',
          baseUrl: 'https://active.test/api',
          priority: 2,
        ),
      ];

      final service = ProviderChainService(
        providers: mixedProviders,
        cacheStore: cacheStore,
        httpClient: client,
      );

      final result = await service.request<List<String>>(
        path: '/search/mhs/test/',
        cachePolicy: testPolicy,
        decoder: decoder,
      );

      expect(result.providerId, 'active');
      expect(requestedUrls, isNot(contains('disabled.test')));
    });

    test('10. latency tercatat untuk health report', () async {
      final client = MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return http.Response(json.encode(['ok']), 200);
      });

      final service = ProviderChainService(
        providers: providers,
        cacheStore: cacheStore,
        httpClient: client,
      );

      final result = await service.request<List<String>>(
        path: '/search/mhs/test/',
        cachePolicy: testPolicy,
        decoder: decoder,
      );

      expect(result.latency.inMilliseconds, greaterThan(40));
    });
  });
}
