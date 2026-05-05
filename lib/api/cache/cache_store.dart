import 'cache_entry.dart';

/// Statistik cache
class CacheStats {
  final int totalEntries;
  final int freshEntries;
  final int staleEntries;
  final int expiredEntries;

  const CacheStats({
    this.totalEntries = 0,
    this.freshEntries = 0,
    this.staleEntries = 0,
    this.expiredEntries = 0,
  });

  @override
  String toString() => 'CacheStats(total=$totalEntries, fresh=$freshEntries, stale=$staleEntries, expired=$expiredEntries)';
}

/// Abstract cache store — bisa di-implement sebagai InMemory, SQLite, atau Redis (gateway)
abstract class CacheStore {
  /// Ambil entry berdasarkan key (return null jika tidak ada atau expired total)
  Future<CacheEntry?> get(String key);

  /// Simpan entry baru
  Future<void> put(CacheEntry entry);

  /// Hapus entry berdasarkan key
  Future<void> delete(String key);

  /// Hapus semua entry yang key-nya dimulai dengan prefix
  Future<void> clearByPrefix(String prefix);

  /// Hapus semua entry yang sudah expired (staleUntil sudah lewat)
  Future<void> clearExpired();

  /// Hapus semua cache
  Future<void> clearAll();

  /// Statistik cache saat ini
  Future<CacheStats> stats();
}
