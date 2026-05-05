/// Cache policy — menentukan TTL fresh dan stale per tipe data
class CachePolicy {
  final Duration freshTtl;
  final Duration staleTtl;
  final bool allowStaleOnFailure;

  const CachePolicy({
    required this.freshTtl,
    required this.staleTtl,
    this.allowStaleOnFailure = true,
  });

  /// Policies default per tipe data PDDIKTI
  static const searchMahasiswa = CachePolicy(
    freshTtl: Duration(minutes: 5),
    staleTtl: Duration(hours: 24),
  );

  static const searchDosen = CachePolicy(
    freshTtl: Duration(minutes: 5),
    staleTtl: Duration(hours: 24),
  );

  static const searchPt = CachePolicy(
    freshTtl: Duration(minutes: 30),
    staleTtl: Duration(days: 7),
  );

  static const searchProdi = CachePolicy(
    freshTtl: Duration(minutes: 30),
    staleTtl: Duration(days: 7),
  );

  static const detailMahasiswa = CachePolicy(
    freshTtl: Duration(hours: 1),
    staleTtl: Duration(days: 7),
  );

  static const detailDosen = CachePolicy(
    freshTtl: Duration(hours: 1),
    staleTtl: Duration(days: 7),
  );

  static const detailPt = CachePolicy(
    freshTtl: Duration(hours: 24),
    staleTtl: Duration(days: 30),
  );

  static const detailProdi = CachePolicy(
    freshTtl: Duration(hours: 24),
    staleTtl: Duration(days: 30),
  );

  /// Wilayah — data jarang berubah
  static const wilayah = CachePolicy(
    freshTtl: Duration(days: 30),
    staleTtl: Duration(days: 180),
  );

  /// BPS — data statistik
  static const bpsData = CachePolicy(
    freshTtl: Duration(hours: 24),
    staleTtl: Duration(days: 7),
  );

  /// Enrichment akademik — GARUDA/SINTA/RAMA
  static const enrichment = CachePolicy(
    freshTtl: Duration(days: 7),
    staleTtl: Duration(days: 30),
  );

  /// Health check — sangat pendek
  static const health = CachePolicy(
    freshTtl: Duration(minutes: 1),
    staleTtl: Duration(minutes: 10),
    allowStaleOnFailure: false,
  );
}
