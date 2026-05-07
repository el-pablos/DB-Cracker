import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
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
  static const _baseUrl = 'https://assai.id/nemesis/api';

  NemesisRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<BootstrapModel> getBootstrap() async {
    try {
      final response = await _dio.get('$_baseUrl/bootstrap');
      if (response.statusCode == 200) {
        return BootstrapModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException('Bootstrap failed', response.statusCode);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const RateLimitException('Nemesis rate limited');
      }
      throw ServerException(
          e.message ?? 'Nemesis error', e.response?.statusCode);
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
        final data = response.data as Map<String, dynamic>;
        final packages = (data['data'] as List? ?? [])
            .map((e) =>
                ProcurementPackageModel.fromJson(e as Map<String, dynamic>))
            .toList();
        final pagination = data['pagination'] != null
            ? PaginationMeta.fromJson(
                data['pagination'] as Map<String, dynamic>)
            : null;
        return PaginatedResponse(data: packages, pagination: pagination);
      }
      throw ServerException('Failed to get packages', response.statusCode);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const RateLimitException('Nemesis rate limited');
      }
      throw ServerException(
          e.message ?? 'Nemesis error', e.response?.statusCode);
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
        final data = response.data as Map<String, dynamic>;
        final packages = (data['data'] as List? ?? [])
            .map((e) =>
                ProcurementPackageModel.fromJson(e as Map<String, dynamic>))
            .toList();
        final pagination = data['pagination'] != null
            ? PaginationMeta.fromJson(
                data['pagination'] as Map<String, dynamic>)
            : null;
        return PaginatedResponse(data: packages, pagination: pagination);
      }
      throw ServerException('Failed to get packages', response.statusCode);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const RateLimitException('Nemesis rate limited');
      }
      throw ServerException(
          e.message ?? 'Nemesis error', e.response?.statusCode);
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
}
