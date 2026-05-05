import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:db_cracker_tamaengs/api/health/health_service.dart';
import 'package:db_cracker_tamaengs/api/core/provider_registry.dart';
import 'package:db_cracker_tamaengs/api/cache/in_memory_cache_store.dart';

void main() {
  late InMemoryCacheStore cacheStore;

  setUp(() {
    cacheStore = InMemoryCacheStore();
  });

  group('HealthService', () {
    test('1. healthy provider returns status healthy', () async {
      final client = MockClient((request) async {
        return http.Response('{"status":"ok"}', 200);
      });

      final service = HealthService(httpClient: client, cacheStore: cacheStore);
      final report = await service.checkAll();

      final pddiktiResults = report.providers.where((p) => p.kind == ProviderKind.pddikti);
      expect(pddiktiResults.any((p) => p.status == ProviderStatus.healthy), true);
    });

    test('2. 503 provider returns degraded', () async {
      final client = MockClient((request) async {
        if (request.url.host.contains('fastapicloud')) {
          return http.Response('Service Unavailable', 503);
        }
        return http.Response('ok', 200);
      });

      final service = HealthService(httpClient: client, cacheStore: cacheStore);
      final report = await service.checkAll();

      final fastapicloud = report.providers.firstWhere((p) => p.providerId == 'pddikti_fastapicloud');
      expect(fastapicloud.status, ProviderStatus.degraded);
    });

    test('3. timeout provider returns timeout status', () async {
      final client = MockClient((request) async {
        if (request.url.host.contains('fastapicloud')) {
          await Future.delayed(const Duration(seconds: 10));
          return http.Response('', 200);
        }
        return http.Response('ok', 200);
      });

      final service = HealthService(httpClient: client, cacheStore: cacheStore);
      final report = await service.checkAll();

      final fastapicloud = report.providers.firstWhere((p) => p.providerId == 'pddikti_fastapicloud');
      expect(fastapicloud.status, ProviderStatus.timeout);
    });

    test('4. external link providers always healthy', () async {
      final client = MockClient((request) async => http.Response('ok', 200));
      final service = HealthService(httpClient: client, cacheStore: cacheStore);
      final report = await service.checkAll();

      final externalLinks = report.providers.where((p) => p.kind == ProviderKind.externalLink);
      for (final link in externalLinks) {
        expect(link.status, ProviderStatus.healthy);
      }
    });

    test('5. report contains cache stats', () async {
      final client = MockClient((request) async => http.Response('ok', 200));
      final service = HealthService(httpClient: client, cacheStore: cacheStore);
      final report = await service.checkAll();

      expect(report.cacheStats, isNotNull);
      expect(report.cacheStats.totalEntries, 0);
    });

    test('6. report has all registered providers', () async {
      final client = MockClient((request) async => http.Response('ok', 200));
      final service = HealthService(httpClient: client, cacheStore: cacheStore);
      final report = await service.checkAll();

      // Should have at least PDDIKTI + Wilayah + external links
      expect(report.providers.length, greaterThanOrEqualTo(5));
    });

    test('7. latency is recorded for network checks', () async {
      final client = MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 20));
        return http.Response('ok', 200);
      });

      final service = HealthService(httpClient: client, cacheStore: cacheStore);
      final report = await service.checkAll();

      final networkChecked = report.providers.where((p) => p.latency != null && p.kind != ProviderKind.externalLink);
      expect(networkChecked.isNotEmpty, true);
      for (final p in networkChecked) {
        expect(p.latency!.inMilliseconds, greaterThanOrEqualTo(0));
      }
    });

    test('8. 429 returns rateLimited', () async {
      final client = MockClient((request) async {
        return http.Response('Too Many Requests', 429);
      });

      final service = HealthService(httpClient: client, cacheStore: cacheStore);
      final report = await service.checkAll();

      final pddikti = report.providers.where((p) => p.kind == ProviderKind.pddikti);
      expect(pddikti.any((p) => p.status == ProviderStatus.rateLimited), true);
    });
  });
}
