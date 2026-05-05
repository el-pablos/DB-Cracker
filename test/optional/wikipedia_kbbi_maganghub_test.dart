import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:db_cracker_tamaengs/api/optional/wikipedia_service.dart';
import 'package:db_cracker_tamaengs/api/optional/kbbi_service.dart';
import 'package:db_cracker_tamaengs/api/optional/maganghub_service.dart';
import 'package:db_cracker_tamaengs/api/cache/in_memory_cache_store.dart';

void main() {
  late InMemoryCacheStore cacheStore;

  setUp(() {
    cacheStore = InMemoryCacheStore();
  });

  group('WikipediaService', () {
    test('returns WikipediaSummary on valid response', () async {
      final client = MockClient((request) async {
        return http.Response(json.encode({
          'title': 'Universitas Indonesia',
          'extract': 'UI adalah perguruan tinggi negeri.',
          'content_urls': {'desktop': {'page': 'https://id.wikipedia.org/wiki/UI'}},
          'thumbnail': {'source': 'https://upload.wikimedia.org/thumb.png'},
        }), 200);
      });

      final service = WikipediaService(httpClient: client, cacheStore: cacheStore);
      final result = await service.getSummary('Universitas Indonesia');

      expect(result, isNotNull);
      expect(result!.title, 'Universitas Indonesia');
      expect(result.extract, contains('perguruan tinggi'));
      expect(result.pageUrl, contains('wikipedia'));
    });

    test('returns null for empty keyword', () async {
      final client = MockClient((request) async => http.Response('', 200));
      final service = WikipediaService(httpClient: client, cacheStore: cacheStore);
      final result = await service.getSummary('');
      expect(result, isNull);
    });

    test('returns null for keyword < 3 chars', () async {
      final client = MockClient((request) async => http.Response('', 200));
      final service = WikipediaService(httpClient: client, cacheStore: cacheStore);
      final result = await service.getSummary('ab');
      expect(result, isNull);
    });

    test('returns null on 404', () async {
      final client = MockClient((request) async => http.Response('Not Found', 404));
      final service = WikipediaService(httpClient: client, cacheStore: cacheStore);
      final result = await service.getSummary('xyznonexistent');
      expect(result, isNull);
    });

    test('uses cache on second call', () async {
      int callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        return http.Response(json.encode({
          'title': 'Test', 'extract': 'Cached content',
        }), 200);
      });

      final service = WikipediaService(httpClient: client, cacheStore: cacheStore);
      await service.getSummary('Test University');
      await service.getSummary('Test University');

      expect(callCount, 1); // Second call uses cache
    });
  });

  group('KbbiService', () {
    test('returns local fallback for known academic terms', () async {
      final client = MockClient((request) async => http.Response('', 500));
      final service = KbbiService(httpClient: client, cacheStore: cacheStore);

      final result = await service.lookup('akreditasi');
      expect(result, isNotNull);
      expect(result!.source, 'local_fallback');
      expect(result.definition, contains('kelayakan'));
    });

    test('returns null for empty term', () async {
      final client = MockClient((request) async => http.Response('', 200));
      final service = KbbiService(httpClient: client, cacheStore: cacheStore);
      final result = await service.lookup('');
      expect(result, isNull);
    });

    test('local fallback has priority over API', () async {
      int apiCalled = 0;
      final client = MockClient((request) async {
        apiCalled++;
        return http.Response(json.encode([{'arti': 'from api'}]), 200);
      });

      final service = KbbiService(httpClient: client, cacheStore: cacheStore);
      final result = await service.lookup('sks'); // Known local term

      expect(result!.source, 'local_fallback');
      expect(apiCalled, 0); // API not called because local found first
    });

    test('getAllLocalTerms returns all entries', () async {
      final client = MockClient((request) async => http.Response('', 200));
      final service = KbbiService(httpClient: client, cacheStore: cacheStore);
      final terms = service.getAllLocalTerms();
      expect(terms.length, greaterThan(10));
      expect(terms.any((t) => t.word == 'ipk'), true);
    });
  });

  group('MagangHubService', () {
    test('getInternships returns parsed list on 200', () async {
      final client = MockClient((request) async {
        return http.Response(json.encode([
          {'title': 'Frontend Dev', 'company': 'Tokopedia', 'location': 'Jakarta'},
          {'title': 'Backend Dev', 'company': 'Gojek', 'location': 'Bandung'},
        ]), 200);
      });

      final service = MagangHubService(httpClient: client, cacheStore: cacheStore);
      final results = await service.getInternships();

      expect(results.length, 2);
      expect(results.first.title, 'Frontend Dev');
      expect(results.first.company, 'Tokopedia');
    });

    test('getInternships returns empty on failure', () async {
      final client = MockClient((request) async => http.Response('Error', 500));
      final service = MagangHubService(httpClient: client, cacheStore: cacheStore);
      final results = await service.getInternships();
      expect(results, isEmpty);
    });

    test('getInternships filters empty titles', () async {
      final client = MockClient((request) async {
        return http.Response(json.encode([
          {'title': '', 'company': 'Empty'},
          {'title': 'Valid', 'company': 'Good'},
        ]), 200);
      });

      final service = MagangHubService(httpClient: client, cacheStore: cacheStore);
      final results = await service.getInternships();
      expect(results.length, 1);
      expect(results.first.title, 'Valid');
    });

    test('getCompanies returns list', () async {
      final client = MockClient((request) async {
        return http.Response(json.encode([
          {'name': 'Tokopedia'},
          {'name': 'Gojek'},
        ]), 200);
      });

      final service = MagangHubService(httpClient: client, cacheStore: cacheStore);
      final results = await service.getCompanies();
      expect(results.length, 2);
      expect(results.first, 'Tokopedia');
    });
  });
}
