import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/economy_models.dart';

/// Kemnaker Satu Data API datasource for minimum wage data.
abstract class KemnakerRemoteDataSource {
  /// Get UMP (Upah Minimum Provinsi) for a given year.
  Future<List<MinimumWageModel>> getUmp({required int tahun});

  /// Get UMP for a specific province and year.
  Future<MinimumWageModel> getUmpByProvinsi({
    required String provinsi,
    required int tahun,
  });
}

class KemnakerRemoteDataSourceImpl implements KemnakerRemoteDataSource {
  final Dio _dio;
  static const _baseUrl = 'https://satudata.kemnaker.go.id/api/v1';

  KemnakerRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<MinimumWageModel>> getUmp({required int tahun}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/upah-minimum',
        queryParameters: {'tahun': tahun},
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final records = _extractRecords(body);

        return records
            .map((e) => MinimumWageModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ServerException('Kemnaker API error', response.statusCode);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<MinimumWageModel> getUmpByProvinsi({
    required String provinsi,
    required int tahun,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/upah-minimum',
        queryParameters: {
          'tahun': tahun,
          'provinsi': provinsi,
        },
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final records = _extractRecords(body);

        if (records.isEmpty) {
          throw ServerException(
            'UMP data not found for $provinsi/$tahun',
            404,
          );
        }

        return MinimumWageModel.fromJson(records.first as Map<String, dynamic>);
      }

      throw ServerException('Kemnaker API error', response.statusCode);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Extract records list from Kemnaker API response envelope.
  List<dynamic> _extractRecords(Map<String, dynamic> body) {
    // Kemnaker may wrap in { "data": [...] } or { "result": { "records": [...] } }
    final data = body['data'];
    if (data is List) return data;

    final result = body['result'];
    if (result is Map<String, dynamic>) {
      final records = result['records'];
      if (records is List) return records;
    }

    // Fallback: try top-level records
    final records = body['records'];
    if (records is List) return records;

    return [];
  }

  Exception _handleError(DioException e) {
    final statusCode = e.response?.statusCode;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const TimeoutException('Kemnaker API timeout');
    }

    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException('Tidak dapat terhubung ke Kemnaker API');
    }

    if (statusCode == 429) {
      return const RateLimitException('Kemnaker API rate limit exceeded');
    }

    if (statusCode == 404) {
      return ServerException('Data UMP tidak ditemukan', 404);
    }

    return ServerException(
      e.response?.statusMessage ?? 'Kemnaker API error',
      statusCode,
    );
  }
}
