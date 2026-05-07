import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/disaster_models.dart';

/// BNPB InaRISK API datasource for disaster risk data.
abstract class BnpbRemoteDataSource {
  /// Get disaster risk score for a specific coordinate.
  Future<DisasterRiskModel> getRiskScore({
    required double lat,
    required double lon,
  });

  /// Get IRBI (Indeks Risiko Bencana Indonesia) data for a given year.
  Future<List<IrbiModel>> getIrbi({required int tahun});

  /// Get IRBI for a specific province.
  Future<List<IrbiModel>> getIrbiByProvinsi({
    required int tahun,
    required String provinsi,
  });
}

class BnpbRemoteDataSourceImpl implements BnpbRemoteDataSource {
  final Dio _dio;
  static const _baseUrl = 'https://inarisk.bnpb.go.id/api';

  BnpbRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<DisasterRiskModel> getRiskScore({
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/risk-score',
        queryParameters: {
          'lat': lat,
          'lon': lon,
        },
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final data = _extractSingleResult(body);

        if (data == null) {
          throw ServerException(
            'No risk data for coordinates ($lat, $lon)',
            404,
          );
        }

        return DisasterRiskModel.fromJson(data);
      }

      throw ServerException('BNPB API error', response.statusCode);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<IrbiModel>> getIrbi({required int tahun}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/irbi',
        queryParameters: {'tahun': tahun},
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final records = _extractRecords(body);

        return records
            .map((e) => IrbiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ServerException('BNPB IRBI API error', response.statusCode);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<IrbiModel>> getIrbiByProvinsi({
    required int tahun,
    required String provinsi,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/irbi',
        queryParameters: {
          'tahun': tahun,
          'provinsi': provinsi,
        },
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final records = _extractRecords(body);

        return records
            .map((e) => IrbiModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ServerException('BNPB IRBI API error', response.statusCode);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Extract single result from BNPB response envelope.
  Map<String, dynamic>? _extractSingleResult(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is List && data.isNotEmpty) {
      return data.first as Map<String, dynamic>;
    }

    final result = body['result'];
    if (result is Map<String, dynamic>) return result;

    return null;
  }

  /// Extract records list from BNPB response envelope.
  List<dynamic> _extractRecords(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is List) return data;

    final result = body['result'];
    if (result is Map<String, dynamic>) {
      final records = result['records'] ?? result['data'];
      if (records is List) return records;
    }
    if (result is List) return result;

    return [];
  }

  Exception _handleError(DioException e) {
    final statusCode = e.response?.statusCode;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const TimeoutException('BNPB InaRISK API timeout');
    }

    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException('Tidak dapat terhubung ke BNPB InaRISK');
    }

    if (statusCode == 429) {
      return const RateLimitException('BNPB API rate limit exceeded');
    }

    if (statusCode == 404) {
      return ServerException('Data risiko bencana tidak ditemukan', 404);
    }

    return ServerException(
      e.response?.statusMessage ?? 'BNPB API error',
      statusCode,
    );
  }
}
