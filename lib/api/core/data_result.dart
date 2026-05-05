/// Tipe sumber data — agar UI tahu asal data yang ditampilkan
enum DataSourceType {
  /// Data langsung dari API provider (fresh)
  live,

  /// Data dari memory cache (masih fresh)
  memoryCache,

  /// Data dari persistent local cache (masih fresh)
  persistentCache,

  /// Data dari stale cache (expired fresh tapi masih dalam stale window)
  /// UI wajib tampilkan warning
  staleCache,

  /// Data mock/demo — hanya untuk testing, TIDAK boleh di production tanpa label
  mock,

  /// Tautan eksternal — bukan data yang di-fetch, hanya URL
  externalLink,

  /// Provider tidak tersedia
  unavailable,
}

/// Generic result wrapper — membawa data + metadata sumber
/// Agar UI bisa menampilkan source badge dan warning stale
class DataResult<T> {
  final T data;
  final DataSourceType sourceType;
  final String providerId;
  final String providerName;
  final bool isStale;
  final DateTime fetchedAt;
  final Duration? latency;
  final String? warning;
  final Object? rawError;

  const DataResult({
    required this.data,
    required this.sourceType,
    required this.providerId,
    required this.providerName,
    required this.isStale,
    required this.fetchedAt,
    this.latency,
    this.warning,
    this.rawError,
  });

  /// Shortcut untuk bikin result live
  factory DataResult.live({
    required T data,
    required String providerId,
    required String providerName,
    Duration? latency,
  }) => DataResult(
    data: data,
    sourceType: DataSourceType.live,
    providerId: providerId,
    providerName: providerName,
    isStale: false,
    fetchedAt: DateTime.now(),
    latency: latency,
  );

  /// Shortcut untuk bikin result dari cache
  factory DataResult.cached({
    required T data,
    required String providerId,
    required String providerName,
    required bool isStale,
  }) => DataResult(
    data: data,
    sourceType: isStale ? DataSourceType.staleCache : DataSourceType.memoryCache,
    providerId: providerId,
    providerName: providerName,
    isStale: isStale,
    fetchedAt: DateTime.now(),
    warning: isStale ? 'Data mungkin tidak terbaru (dari cache)' : null,
  );

  /// Shortcut untuk unavailable
  factory DataResult.unavailable({
    required String providerId,
    required String providerName,
    Object? error,
  }) => DataResult(
    data: null as T,
    sourceType: DataSourceType.unavailable,
    providerId: providerId,
    providerName: providerName,
    isStale: false,
    fetchedAt: DateTime.now(),
    rawError: error,
    warning: 'Data tidak tersedia saat ini',
  );

  /// Label user-friendly untuk source
  String get sourceLabel {
    switch (sourceType) {
      case DataSourceType.live:
        return 'Sumber: $providerName (live)';
      case DataSourceType.memoryCache:
        return 'Sumber: cache lokal';
      case DataSourceType.persistentCache:
        return 'Sumber: cache tersimpan';
      case DataSourceType.staleCache:
        return 'Sumber: cache lama, data mungkin tidak terbaru';
      case DataSourceType.mock:
        return 'Sumber: data demo';
      case DataSourceType.externalLink:
        return 'Tautan eksternal: $providerName';
      case DataSourceType.unavailable:
        return 'Data tidak tersedia';
    }
  }
}
