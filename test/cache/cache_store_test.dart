import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/api/cache/cache_entry.dart';
import 'package:db_cracker_tamaengs/api/cache/in_memory_cache_store.dart';

void main() {
  late InMemoryCacheStore store;

  setUp(() {
    store = InMemoryCacheStore(maxEntries: 10);
  });

  CacheEntry _freshEntry(String key, {String body = '{"data":"test"}'}) {
    return CacheEntry(
      key: key,
      body: body,
      createdAt: DateTime.now(),
      freshUntil: DateTime.now().add(const Duration(minutes: 5)),
      staleUntil: DateTime.now().add(const Duration(hours: 1)),
      source: 'test',
    );
  }

  CacheEntry _staleEntry(String key) {
    return CacheEntry(
      key: key,
      body: '{"data":"stale"}',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      freshUntil: DateTime.now().subtract(const Duration(hours: 1)),
      staleUntil: DateTime.now().add(const Duration(hours: 23)),
      source: 'test',
    );
  }

  CacheEntry _expiredEntry(String key) {
    return CacheEntry(
      key: key,
      body: '{"data":"expired"}',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      freshUntil: DateTime.now().subtract(const Duration(days: 1)),
      staleUntil: DateTime.now().subtract(const Duration(hours: 1)),
      source: 'test',
    );
  }

  group('InMemoryCacheStore', () {
    test('1. fresh cache terbaca sebelum expired', () async {
      await store.put(_freshEntry('key1'));
      final result = await store.get('key1');
      expect(result, isNotNull);
      expect(result!.isFresh, true);
      expect(result.body, '{"data":"test"}');
    });

    test('2. stale cache terbaca (untuk allowStaleOnFailure)', () async {
      await store.put(_staleEntry('key2'));
      final result = await store.get('key2');
      expect(result, isNotNull);
      expect(result!.isFresh, false);
      expect(result.isStale, true);
    });

    test('3. expired stale tidak dipakai (return null)', () async {
      await store.put(_expiredEntry('key3'));
      final result = await store.get('key3');
      expect(result, isNull);
    });

    test('4. clearByPrefix menghapus data sesuai prefix', () async {
      await store.put(_freshEntry('pddikti:/search/mhs/a'));
      await store.put(_freshEntry('pddikti:/search/mhs/b'));
      await store.put(_freshEntry('wilayah:/provinces'));

      await store.clearByPrefix('pddikti:');

      final stats = await store.stats();
      expect(stats.totalEntries, 1);

      final remaining = await store.get('wilayah:/provinces');
      expect(remaining, isNotNull);
    });

    test('5. stats menghitung entries fresh, stale, expired', () async {
      await store.put(_freshEntry('fresh1'));
      await store.put(_freshEntry('fresh2'));
      await store.put(_staleEntry('stale1'));

      final stats = await store.stats();
      expect(stats.totalEntries, 3);
      expect(stats.freshEntries, 2);
      expect(stats.staleEntries, 1);
      expect(stats.expiredEntries, 0);
    });

    test('6. cache key deterministic', () async {
      await store.put(_freshEntry('same-key', body: '{"v":1}'));
      await store.put(_freshEntry('same-key', body: '{"v":2}'));

      final stats = await store.stats();
      expect(stats.totalEntries, 1); // Overwritten, not duplicated

      final result = await store.get('same-key');
      expect(result!.body, '{"v":2}');
    });

    test('7. eviction saat maxEntries tercapai', () async {
      for (int i = 0; i < 12; i++) {
        await store.put(_freshEntry('key_$i'));
      }

      final stats = await store.stats();
      expect(stats.totalEntries, 10); // maxEntries = 10
    });

    test('8. clearExpired aman saat cache kosong', () async {
      await store.clearExpired();
      final stats = await store.stats();
      expect(stats.totalEntries, 0);
    });

    test('9. clearAll menghapus semua', () async {
      await store.put(_freshEntry('a'));
      await store.put(_freshEntry('b'));
      await store.clearAll();

      final stats = await store.stats();
      expect(stats.totalEntries, 0);
    });

    test('10. delete menghapus entry spesifik', () async {
      await store.put(_freshEntry('target'));
      await store.put(_freshEntry('keep'));

      await store.delete('target');

      expect(await store.get('target'), isNull);
      expect(await store.get('keep'), isNotNull);
    });
  });
}
