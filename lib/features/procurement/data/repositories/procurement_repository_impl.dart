import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/procurement_repository.dart';
import '../datasources/nemesis_remote_datasource.dart';
import '../models/bootstrap_model.dart';
import '../models/package_model.dart';
import '../models/paginated_response.dart';

class ProcurementRepositoryImpl implements ProcurementRepository {
  final NemesisRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  // Simple in-memory cache for bootstrap
  BootstrapModel? _cachedBootstrap;
  DateTime? _bootstrapCachedAt;
  static const _bootstrapTtl = Duration(hours: 24);

  ProcurementRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, BootstrapModel>> getBootstrap() async {
    // Check cache
    if (_cachedBootstrap != null && _bootstrapCachedAt != null) {
      final age = DateTime.now().difference(_bootstrapCachedAt!);
      if (age < _bootstrapTtl) return Right(_cachedBootstrap!);
    }

    if (!await networkInfo.isConnected) {
      if (_cachedBootstrap != null) return Right(_cachedBootstrap!);
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.getBootstrap();
      _cachedBootstrap = result;
      _bootstrapCachedAt = DateTime.now();
      return Right(result);
    } on RateLimitException {
      if (_cachedBootstrap != null) return Right(_cachedBootstrap!);
      return const Left(RateLimitFailure());
    } on ServerException catch (e) {
      if (_cachedBootstrap != null) return Right(_cachedBootstrap!);
      return Left(ServerFailure(e.message, e.statusCode));
    } on NetworkException {
      if (_cachedBootstrap != null) return Right(_cachedBootstrap!);
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<ProcurementPackageModel>>>
      getRegionPackages({
    required String regionKey,
    int page = 1,
    int pageSize = 25,
    String? search,
    String? ownerType,
    String? severity,
    bool? priorityOnly,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.getRegionPackages(
        regionKey: regionKey,
        page: page,
        pageSize: pageSize,
        search: search,
        ownerType: ownerType,
        severity: severity,
        priorityOnly: priorityOnly,
      );
      return Right(result);
    } on RateLimitException {
      return const Left(RateLimitFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<ProcurementPackageModel>>>
      getProvincePackages({
    required String provinceKey,
    int page = 1,
    int pageSize = 25,
    String? severity,
    bool? priorityOnly,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await remoteDataSource.getProvincePackages(
        provinceKey: provinceKey,
        page: page,
        pageSize: pageSize,
        severity: severity,
        priorityOnly: priorityOnly,
      );
      return Right(result);
    } on RateLimitException {
      return const Left(RateLimitFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
