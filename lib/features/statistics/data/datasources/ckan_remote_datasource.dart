import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/statistics_models.dart';

/// Supported CKAN portal base URLs.
enum CkanPortal {
  dataGoId('https://data.go.id/api/3/action'),
  jakarta('https://satudata.jakarta.go.id/api/3/action'),
  jabar('https://opendata.jabarprov.go.id/api/3/action'),
  bnpb('https://data.bnpb.go.id/api/3/action');

  final String baseUrl;
  const CkanPortal(this.baseUrl);
}

/// Unified CKAN API client supporting multiple Indonesian open data portals.
abstract class CkanRemoteDataSource {
  /// Search packages/datasets across a CKAN portal.
  Future<List<CkanDatasetModel>> searchPackages({
    required String baseUrl,
    required String query,
    int rows = 10,
    int start = 0,
  });

  /// Get a single package/dataset by ID or name.
  Future<CkanDatasetModel> getPackage({
    required String baseUrl,
    required String id,
  });

  /// Query the DataStore API for tabular data.
  Future<Map<String, dynamic>> queryDatastore({
    required String baseUrl,
    required String resourceId,
    int limit = 100,
    int offset = 0,
    String? filters,
    String? sort,
  });
}

class CkanRemoteDataSourceImpl implements CkanRemoteDataSource {
  final Dio _dio;

  CkanRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<CkanDatasetModel>> searchPackages({
    required String baseUrl,
    required String query,
    int rows = 10,
    int start = 0,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/package_search',
        queryParameters: {
          'q': query,
          'rows': rows,
          'start': start,
        },
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final result = body['result'] as Map<String, dynamic>?;
        if (result == null) return [];

        final results = result['results'] as List? ?? [];
        return results
            .map((e) => CkanDatasetModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        'CKAN search failed',
        response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleError(e, 'searchPackages');
    }
  }

  @override
  Future<CkanDatasetModel> getPackage({
    required String baseUrl,
    required String id,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/package_show',
        queryParameters: {'id': id},
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final result = body['result'] as Map<String, dynamic>?;
        if (result == null) {
          throw const ServerException('Package not found', 404);
        }
        return CkanDatasetModel.fromJson(result);
      }

      throw ServerException(
        'CKAN package_show failed',
        response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleError(e, 'getPackage');
    }
  }

  @override
  Future<Map<String, dynamic>> queryDatastore({
    required String baseUrl,
    required String resourceId,
    int limit = 100,
    int offset = 0,
    String? filters,
    String? sort,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/datastore_search',
        queryParameters: {
          'resource_id': resourceId,
          'limit': limit,
          'offset': offset,
          if (filters != null) 'filters': filters,
          if (sort != null) 'sort': sort,
        },
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final result = body['result'] as Map<String, dynamic>?;
        if (result == null) {
          return {'records': [], 'fields': [], 'total': 0};
        }

        return {
          'records': result['records'] as List? ?? [],
          'fields': result['fields'] as List? ?? [],
          'total': result['total'] as int? ?? 0,
        };
      }

      throw ServerException(
        'CKAN datastore_search failed',
        response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleError(e, 'queryDatastore');
    }
  }

  /// Centralized DioException → typed exception mapping.
  Exception _handleError(DioException e, String method) {
    final statusCode = e.response?.statusCode;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const TimeoutException('CKAN request timeout');
    }

    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException('Tidak dapat terhubung ke CKAN portal');
    }

    if (statusCode == 429) {
      return const RateLimitException('CKAN rate limit exceeded');
    }

    if (statusCode == 404) {
      return ServerException('CKAN resource not found ($method)', 404);
    }

    return ServerException(
      e.response?.statusMessage ?? 'CKAN error in $method',
      statusCode,
    );
  }
}
