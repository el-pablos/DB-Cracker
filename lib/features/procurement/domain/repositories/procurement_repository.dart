import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/bootstrap_model.dart';
import '../../data/models/package_model.dart';
import '../../data/models/paginated_response.dart';

abstract class ProcurementRepository {
  Future<Either<Failure, BootstrapModel>> getBootstrap();
  Future<Either<Failure, PaginatedResponse<ProcurementPackageModel>>>
      getRegionPackages({
    required String regionKey,
    int page = 1,
    int pageSize = 25,
    String? search,
    String? ownerType,
    String? severity,
    bool? priorityOnly,
  });
  Future<Either<Failure, PaginatedResponse<ProcurementPackageModel>>>
      getProvincePackages({
    required String provinceKey,
    int page = 1,
    int pageSize = 25,
    String? severity,
    bool? priorityOnly,
  });
}
