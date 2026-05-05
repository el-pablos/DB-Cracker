import 'cache_entry.dart';
import 'cache_store.dart';

/// In-memory cache store — cocok untuk mobile dan web
/// Tidak persist antar session, tapi cepat dan zero-dependency
class InMemoryCacheStore implements CacheStore {
  final Map<String, CacheEntry> _store = {};
  final int maxEntries;

  InMemoryCacheStore({this.maxEntries = 200});

  @override
  Future<CacheEntry?> get(String key) async {
    final entry = _store[key];
    if (entry == null) return null;

    // Hapus jika sudah expired total
    if (entry.isExpired) {
      _store.remove(key);
      return null;
    }

    return entry;
  }

  @override
  Future<void> put(CacheEntry entry) async {
    // Evict oldest jika penuh (FIFO)
    if (_store.length >= maxEntries && !_store.containsKey(entry.key)) {
      final oldestKey = _store.keys.first;
      _store.remove(oldestKey);
    }
    _store[entry.key] = entry;
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clearByPrefix(String prefix) async {
    _store.removeWhere((key, _) => key.startsWith(prefix));
  }

  @override
  Future<void> clearExpired() async {
    _store.removeWhere((_, entry) => entry.isExpired);
  }

  @override
  Future<void> clearAll() async {
    _store.clear();
  }

  @override
  Future<CacheStats> stats() async {
    int fresh = 0;
    int stale = 0;
    int expired = 0;

    for (final entry in _store.values) {
      if (entry.isFresh) {
        fresh++;
      } else if (entry.isStale) {
        stale++;
      } else {
        expired++;
      }
    }

    return CacheStats(
      totalEntries: _store.length,
      freshEntries: fresh,
      staleEntries: stale,
      expiredEntries: expired,
    );
  }
}
