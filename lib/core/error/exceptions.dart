class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException([this.message = 'Server error', this.statusCode]);
  @override
  String toString() => 'ServerException: $message (${statusCode ?? "no code"})';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Network unavailable']);
}

class TimeoutException implements Exception {
  final String message;
  const TimeoutException([this.message = 'Request timeout']);
}

class RateLimitException implements Exception {
  final String message;
  final Duration? retryAfter;
  const RateLimitException([this.message = 'Rate limited', this.retryAfter]);
}

class ParseException implements Exception {
  final String message;
  const ParseException([this.message = 'Parse error']);
}
