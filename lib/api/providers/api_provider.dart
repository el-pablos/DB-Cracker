/// Model untuk API provider dalam provider chain
/// Setiap provider punya priority, timeout, dan status codes yang bisa di-retry
class ApiProvider {
  final String id;
  final String name;
  final String baseUrl;
  final int priority;
  final bool enabled;
  final Duration timeout;
  final Set<int> retryableStatusCodes;

  const ApiProvider({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.priority,
    this.enabled = true,
    this.timeout = const Duration(seconds: 12),
    this.retryableStatusCodes = const {408, 425, 429, 500, 502, 503, 504},
  });

  @override
  String toString() => 'ApiProvider($id, priority=$priority, enabled=$enabled)';
}

/// Default PDDIKTI providers — proxy yang punya proper SSL
class PddiktiProviders {
  static const fastapicloud = ApiProvider(
    id: 'fastapicloud',
    name: 'PDDikti FastAPI Cloud',
    baseUrl: 'https://pddikti.fastapicloud.dev/api',
    priority: 1,
    timeout: Duration(seconds: 15),
  );

  static const rone = ApiProvider(
    id: 'rone',
    name: 'PDDikti Rone.dev',
    baseUrl: 'https://pddikti.rone.dev/api',
    priority: 2,
    timeout: Duration(seconds: 12),
  );

  /// Official API — disabled by default karena SSL cert chain issues di Android
  static const official = ApiProvider(
    id: 'official',
    name: 'PDDikti Official (Kemdiktisaintek)',
    baseUrl: 'https://api-pddikti.kemdiktisaintek.go.id',
    priority: 99,
    enabled: false,
    timeout: Duration(seconds: 15),
  );

  static List<ApiProvider> get defaults => [fastapicloud, rone];
  static List<ApiProvider> get all => [fastapicloud, rone, official];
}
