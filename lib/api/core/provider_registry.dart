/// Provider Registry — mengelola semua API provider secara seragam
/// Semua provider core WAJIB no-auth. Provider yang butuh key/OAuth
/// tidak boleh masuk core flow.

/// Jenis provider
enum ProviderKind {
  pddikti,
  wilayah,
  sekolah,
  wikipedia,
  kbbi,
  maganghub,
  externalLink,
}

/// Mode autentikasi — core flow hanya boleh `none`
enum ProviderAuthMode {
  none,
  apiKey,
  oauth,
  unknown,
}

/// Status kesehatan provider
enum ProviderStatus {
  unknown,
  healthy,
  degraded,
  rateLimited,
  unavailable,
  malformed,
  timeout,
}

/// Konfigurasi satu provider
class ApiProviderConfig {
  final String id;
  final String name;
  final String baseUrl;
  final ProviderKind kind;
  final ProviderAuthMode authMode;
  final int priority;
  final bool enabled;
  final Duration timeout;
  final List<int> retryableStatusCodes;

  const ApiProviderConfig({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.kind,
    this.authMode = ProviderAuthMode.none,
    required this.priority,
    this.enabled = true,
    this.timeout = const Duration(seconds: 12),
    this.retryableStatusCodes = const [408, 425, 429, 500, 502, 503, 504],
  });

  @override
  String toString() => 'Provider($id, $kind, priority=$priority, enabled=$enabled)';
}

/// Registry semua provider yang terdaftar
class ProviderRegistry {
  static const List<ApiProviderConfig> allProviders = [
    // === PDDIKTI Core ===
    ApiProviderConfig(
      id: 'pddikti_fastapicloud',
      name: 'PDDikti FastAPI Cloud',
      baseUrl: 'https://pddikti.fastapicloud.dev/api',
      kind: ProviderKind.pddikti,
      priority: 1,
      timeout: Duration(seconds: 15),
    ),
    ApiProviderConfig(
      id: 'pddikti_rone',
      name: 'PDDikti Rone.dev',
      baseUrl: 'https://pddikti.rone.dev/api',
      kind: ProviderKind.pddikti,
      priority: 2,
      timeout: Duration(seconds: 12),
    ),

    // === Wilayah Core ===
    ApiProviderConfig(
      id: 'wilayah_id',
      name: 'Wilayah.id',
      baseUrl: 'https://wilayah.id/api',
      kind: ProviderKind.wilayah,
      priority: 1,
      timeout: Duration(seconds: 8),
    ),
    ApiProviderConfig(
      id: 'emsifa_wilayah',
      name: 'Emsifa Wilayah (GitHub Pages)',
      baseUrl: 'https://emsifa.github.io/api-wilayah-indonesia/api',
      kind: ProviderKind.wilayah,
      priority: 2,
      timeout: Duration(seconds: 10),
    ),

    // === Sekolah/NPSN ===
    ApiProviderConfig(
      id: 'fazriansyah_sekolah',
      name: 'API Sekolah Indonesia',
      baseUrl: 'https://api.fazriansyah.eu.org/v1',
      kind: ProviderKind.sekolah,
      priority: 1,
      timeout: Duration(seconds: 10),
    ),

    // === Wikipedia ===
    ApiProviderConfig(
      id: 'wikipedia_id',
      name: 'Wikipedia Indonesia',
      baseUrl: 'https://id.wikipedia.org/api/rest_v1',
      kind: ProviderKind.wikipedia,
      priority: 1,
      timeout: Duration(seconds: 8),
    ),

    // === KBBI ===
    ApiProviderConfig(
      id: 'kbbi_api',
      name: 'KBBI API',
      baseUrl: 'https://kbbi-api-amm.herokuapp.com',
      kind: ProviderKind.kbbi,
      priority: 1,
      timeout: Duration(seconds: 8),
    ),

    // === MagangHub ===
    ApiProviderConfig(
      id: 'maganghub',
      name: 'MagangHub',
      baseUrl: 'https://maganghub.ndav.my.id/api/scrape',
      kind: ProviderKind.maganghub,
      priority: 1,
      timeout: Duration(seconds: 10),
    ),

    // === External Links (bukan API, hanya deep-link) ===
    ApiProviderConfig(
      id: 'garuda_link',
      name: 'GARUDA Kemdiktisaintek',
      baseUrl: 'https://garuda.kemdiktisaintek.go.id',
      kind: ProviderKind.externalLink,
      priority: 1,
    ),
    ApiProviderConfig(
      id: 'rama_link',
      name: 'RAMA Repository',
      baseUrl: 'https://rama.kemdiktisaintek.go.id',
      kind: ProviderKind.externalLink,
      priority: 2,
    ),
    ApiProviderConfig(
      id: 'sinta_link',
      name: 'SINTA Kemdikbud',
      baseUrl: 'https://sinta.kemdikbud.go.id',
      kind: ProviderKind.externalLink,
      priority: 3,
    ),
  ];

  /// Ambil providers berdasarkan jenis
  static List<ApiProviderConfig> byKind(ProviderKind kind) =>
      allProviders.where((p) => p.kind == kind && p.enabled).toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));

  /// Ambil provider berdasarkan ID
  static ApiProviderConfig? byId(String id) {
    try {
      return allProviders.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Semua provider core (no-auth only)
  static List<ApiProviderConfig> get coreProviders =>
      allProviders.where((p) => p.authMode == ProviderAuthMode.none && p.enabled).toList();

  /// Semua external link providers
  static List<ApiProviderConfig> get externalLinkProviders =>
      allProviders.where((p) => p.kind == ProviderKind.externalLink).toList();
}
