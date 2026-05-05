/// Model cache entry — menyimpan response body + metadata TTL
class CacheEntry {
  final String key;
  final String body;
  final DateTime createdAt;
  final DateTime freshUntil;
  final DateTime staleUntil;
  final String source;
  final int? statusCode;

  const CacheEntry({
    required this.key,
    required this.body,
    required this.createdAt,
    required this.freshUntil,
    required this.staleUntil,
    required this.source,
    this.statusCode,
  });

  /// Masih fresh — data valid tanpa network call
  bool get isFresh => DateTime.now().isBefore(freshUntil);

  /// Sudah stale tapi belum expired — bisa dipakai sebagai fallback
  bool get isStale => !isFresh && DateTime.now().isBefore(staleUntil);

  /// Sudah expired total — harus dihapus
  bool get isExpired => DateTime.now().isAfter(staleUntil);

  /// Umur entry dalam detik
  int get ageSeconds => DateTime.now().difference(createdAt).inSeconds;

  @override
  String toString() => 'CacheEntry($key, fresh=${isFresh}, stale=${isStale}, source=$source)';
}
