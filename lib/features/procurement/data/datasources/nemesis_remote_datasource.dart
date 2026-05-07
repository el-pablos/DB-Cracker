import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../models/package_model.dart';
import '../models/bootstrap_model.dart';
import '../models/paginated_response.dart';

abstract class NemesisRemoteDataSource {
  Future<BootstrapModel> getBootstrap();
  Future<PaginatedResponse<ProcurementPackageModel>> getRegionPackages({
    required String regionKey,
    int page = 1,
    int pageSize = 25,
    String? search,
    String? ownerType,
    String? severity,
    bool? priorityOnly,
  });
  Future<PaginatedResponse<ProcurementPackageModel>> getProvincePackages({
    required String provinceKey,
    int page = 1,
    int pageSize = 25,
    String? severity,
    bool? priorityOnly,
  });
  Future<bool> healthCheck();
}

class NemesisRemoteDataSourceImpl implements NemesisRemoteDataSource {
  final Dio _dio;

  // FIX #1: Correct base URL
  static const _baseUrl = 'https://nemesis.tams.codes/api';

  NemesisRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  /// Create a properly configured Dio instance for Nemesis API.
  /// Use this factory instead of bare Dio() to get timeouts, retry, and logging.
  static Dio createConfiguredDio() {
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        // FIX #2c: Request gzip compression
        'Accept-Encoding': 'gzip, deflate',
      },
      // FIX #5b: CORS — avoid sending credentials on web to prevent preflight issues
      extra: {'withCredentials': false},
    ));

    // FIX #2b: Retry interceptor for transient failures
    dio.interceptors.add(_RetryInterceptor(dio: dio, maxRetries: 2));

    // Debug logging only in debug mode
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (s) => debugPrint('[NEMESIS] $s'),
      ));
    }

    return dio;
  }

  @override
  Future<BootstrapModel> getBootstrap() async {
    try {
      final response = await _dio.get('$_baseUrl/bootstrap');
      if (response.statusCode == 200) {
        return BootstrapModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerException('Gagal memuat data dashboard');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on ServerException {
      rethrow;
    } on RateLimitException {
      rethrow;
    } on app_exceptions.TimeoutException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      // FIX #3: Never leak raw error details
      throw const ServerException('Gagal memuat data dashboard');
    }
  }

  @override
  Future<PaginatedResponse<ProcurementPackageModel>> getRegionPackages({
    required String regionKey,
    int page = 1,
    int pageSize = 25,
    String? search,
    String? ownerType,
    String? severity,
    bool? priorityOnly,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/regions/$regionKey/packages',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (search != null && search.isNotEmpty) 'search': search,
          if (ownerType != null) 'ownerType': ownerType,
          if (severity != null) 'severity': severity,
          if (priorityOnly == true) 'priorityOnly': '1',
        },
      );
      if (response.statusCode == 200) {
        return _parsePaginatedPackages(response.data as Map<String, dynamic>);
      }
      throw const ServerException('Gagal memuat data paket');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on ServerException {
      rethrow;
    } on RateLimitException {
      rethrow;
    } on app_exceptions.TimeoutException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw const ServerException('Gagal memuat data paket');
    }
  }

  @override
  Future<PaginatedResponse<ProcurementPackageModel>> getProvincePackages({
    required String provinceKey,
    int page = 1,
    int pageSize = 25,
    String? severity,
    bool? priorityOnly,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/provinces/$provinceKey/packages',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (severity != null) 'severity': severity,
          if (priorityOnly == true) 'priorityOnly': '1',
        },
      );
      if (response.statusCode == 200) {
        return _parsePaginatedPackages(response.data as Map<String, dynamic>);
      }
      throw const ServerException('Gagal memuat data paket provinsi');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on ServerException {
      rethrow;
    } on RateLimitException {
      rethrow;
    } on app_exceptions.TimeoutException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw const ServerException('Gagal memuat data paket provinsi');
    }
  }

  @override
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('$_baseUrl/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── Private Helpers ─────────────────────────────────────────────────────

  /// Parse paginated package response — DRY helper
  PaginatedResponse<ProcurementPackageModel> _parsePaginatedPackages(
    Map<String, dynamic> data,
  ) {
    final packages = (data['data'] as List? ?? [])
        .map((e) =>
            ProcurementPackageModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pagination = data['pagination'] != null
        ? PaginationMeta.fromJson(data['pagination'] as Map<String, dynamic>)
        : null;
    return PaginatedResponse(data: packages, pagination: pagination);
  }

  /// FIX #4: Differentiate timeout, connection, rate limit, and server errors.
  /// FIX #3: Never expose raw Dio error messages to upper layers.
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const app_exceptions.TimeoutException(
          'Server tidak merespons, coba lagi nanti',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          'Tidak dapat terhubung ke server',
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 429) {
          return const RateLimitException(
            'Terlalu banyak permintaan, tunggu sebentar',
          );
        }
        if (statusCode == 404) {
          return const ServerException('Data tidak ditemukan', 404);
        }
        if (statusCode == 503) {
          return const ServerException(
            'Server sedang maintenance, coba lagi nanti',
            503,
          );
        }
        if (statusCode != null && statusCode >= 500) {
          return ServerException(
            'Terjadi kesalahan pada server',
            statusCode,
          );
        }
        return ServerException(
          'Permintaan gagal diproses',
          statusCode,
        );

      case DioExceptionType.cancel:
        return const ServerException('Permintaan dibatalkan');

      case DioExceptionType.badCertificate:
        return const ServerException('Sertifikat keamanan tidak valid');

      case DioExceptionType.unknown:
        // Check if it's actually a network issue wrapped in unknown
        if (e.error != null &&
            e.error.toString().contains('SocketException')) {
          return const NetworkException('Tidak dapat terhubung ke server');
        }
        return const ServerException('Terjadi kesalahan koneksi');
    }
  }
}

// ─── Retry Interceptor ───────────────────────────────────────────────────────

/// Retries failed requests on transient server errors (5xx) and timeouts.
/// Uses exponential backoff: 1s, 2s, 4s...
class _RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  _RetryInterceptor({required this.dio, this.maxRetries = 2});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = _isRetryable(err);
    final attempt = (err.requestOptions.extra['_retryCount'] as int?) ?? 0;

    if (shouldRetry && attempt < maxRetries) {
      final nextAttempt = attempt + 1;
      final delay = Duration(seconds: 1 << attempt); // 1s, 2s, 4s

      if (kDebugMode) {
        debugPrint(
          '[NEMESIS] Retry $nextAttempt/$maxRetries after ${delay.inSeconds}s '
          'for ${err.requestOptions.path}',
        );
      }

      await Future.delayed(delay);

      // Clone request with updated retry count
      final options = err.requestOptions;
      options.extra['_retryCount'] = nextAttempt;

      try {
        final response = await dio.fetch(options);
        handler.resolve(response);
        return;
      } on DioException catch (retryErr) {
        // Let the next retry attempt handle it, or fall through
        if (nextAttempt >= maxRetries) {
          handler.next(retryErr);
          return;
        }
        handler.next(retryErr);
        return;
      }
    }

    handler.next(err);
  }

  bool _isRetryable(DioException err) {
    // Retry on timeout
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }
    // Retry on server errors (5xx) but NOT on 429 (rate limit)
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 500 && statusCode != 429) {
      return true;
    }
    // Retry on connection errors
    if (err.type == DioExceptionType.connectionError) {
      return true;
    }
    return false;
  }
}
