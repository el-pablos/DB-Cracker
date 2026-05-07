import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/economy_models.dart';

/// Bank Indonesia Data Exchange API datasource.
abstract class BiRemoteDataSource {
  /// Get exchange rate for a specific currency and date.
  Future<ExchangeRateModel> getExchangeRate({
    required String currency,
    required String date,
  });

  /// Get latest available rate (handles weekends/holidays by fallback).
  Future<ExchangeRateModel> getLatestRate({
    required String currency,
  });

  /// Get BI-Rate (suku bunga acuan).
  Future<BiRateModel> getBiRate();
}

class BiRemoteDataSourceImpl implements BiRemoteDataSource {
  final Dio _dio;
  static const _baseUrl = 'https://dataapi.bi.go.id/dataexchange/v1';

  BiRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ExchangeRateModel> getExchangeRate({
    required String currency,
    required String date,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/kurs',
        queryParameters: {
          'mata_uang': currency.toUpperCase(),
          'tanggal': date,
        },
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final data = _extractData(body);
        if (data == null) {
          throw ServerException(
            'No exchange rate data for $currency on $date',
            404,
          );
        }
        return ExchangeRateModel.fromBiResponse(data);
      }

      throw ServerException('BI API error', response.statusCode);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<ExchangeRateModel> getLatestRate({
    required String currency,
  }) async {
    // BI doesn't publish rates on weekends/holidays.
    // Try today, then fallback up to 5 days back.
    final now = DateTime.now();

    for (var i = 0; i < 5; i++) {
      final targetDate = now.subtract(Duration(days: i));
      final dateStr = _formatDate(targetDate);

      try {
        final result = await getExchangeRate(
          currency: currency,
          date: dateStr,
        );
        return result;
      } on ServerException catch (e) {
        // 404 means no data for that date, try previous day
        if (e.statusCode == 404 && i < 4) continue;
        rethrow;
      }
    }

    throw ServerException(
      'No exchange rate available for $currency in the last 5 days',
      404,
    );
  }

  @override
  Future<BiRateModel> getBiRate() async {
    try {
      final response = await _dio.get('$_baseUrl/bi-rate');

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final data = _extractData(body);
        if (data == null) {
          throw const ServerException('No BI Rate data available', 404);
        }
        return BiRateModel.fromJson(data);
      }

      throw ServerException('BI Rate API error', response.statusCode);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Extract data payload from BI API response envelope.
  Map<String, dynamic>? _extractData(Map<String, dynamic> body) {
    // BI API may wrap in { "data": [...] } or { "result": {...} }
    final data = body['data'];
    if (data is List && data.isNotEmpty) {
      return data.first as Map<String, dynamic>;
    }
    if (data is Map<String, dynamic>) return data;

    final result = body['result'];
    if (result is Map<String, dynamic>) return result;

    return null;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Exception _handleError(DioException e) {
    final statusCode = e.response?.statusCode;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const TimeoutException('BI API timeout');
    }

    if (e.type == DioExceptionType.connectionError) {
      return const NetworkException('Tidak dapat terhubung ke BI API');
    }

    if (statusCode == 429) {
      return const RateLimitException('BI API rate limit exceeded');
    }

    if (statusCode == 401 || statusCode == 403) {
      return ServerException('BI API authentication failed', statusCode);
    }

    return ServerException(
      e.response?.statusMessage ?? 'BI API error',
      statusCode,
    );
  }
}
