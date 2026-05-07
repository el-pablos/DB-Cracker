import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/data/neo_stat_card.dart';
import '../../../../widgets/core/neo_badge.dart';
import '../../../../widgets/feedback/neo_error.dart';
import '../../../../widgets/feedback/neo_skeleton.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/nemesis_remote_datasource.dart';
import '../../data/repositories/procurement_repository_impl.dart';
import '../../data/models/bootstrap_model.dart';
import '../../data/models/region_model.dart';

// ─── Providers (Singleton Hierarchy) ─────────────────────────────────────────
//
// FIX #5: Provider hierarchy ensures single instances.
// Repository is created ONCE → in-memory cache actually works.

/// Singleton NetworkInfo provider
final _networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

/// Singleton Dio instance configured for Nemesis API
/// with timeouts, retry interceptor, gzip, and logging.
final _nemesisDioProvider = Provider((ref) {
  // FIX #2: Use factory that configures Dio with 30s timeout,
  // retry interceptor, gzip, and debug logging.
  return NemesisRemoteDataSourceImpl.createConfiguredDio();
});

/// Singleton data source — reuses the configured Dio
final _nemesisDataSourceProvider = Provider<NemesisRemoteDataSource>((ref) {
  return NemesisRemoteDataSourceImpl(dio: ref.watch(_nemesisDioProvider));
});

/// Singleton repository — cache persists across rebuilds
final _procurementRepoProvider = Provider<ProcurementRepositoryImpl>((ref) {
  return ProcurementRepositoryImpl(
    remoteDataSource: ref.watch(_nemesisDataSourceProvider),
    networkInfo: ref.watch(_networkInfoProvider),
  );
});

/// Bootstrap data provider — uses the singleton repo so cache works
final _bootstrapProvider = FutureProvider<BootstrapModel>((ref) async {
  final repo = ref.watch(_procurementRepoProvider);
  final result = await repo.getBootstrap();
  return result.fold(
    // FIX #3: Throw typed ProcurementException with user-friendly message
    // instead of raw Exception(failure.message) which leaks internals.
    (failure) => throw ProcurementException.fromFailure(failure),
    (data) => data,
  );
});

// ─── Exception Wrapper ───────────────────────────────────────────────────────

/// User-facing exception that maps Failure types to friendly messages.
/// Never exposes internal details like URLs, stack traces, or Dio messages.
class ProcurementException implements Exception {
  final String userMessage;
  final String? actionHint;

  const ProcurementException(this.userMessage, {this.actionHint});

  factory ProcurementException.fromFailure(Failure failure) {
    if (failure is NetworkFailure) {
      return const ProcurementException(
        'Tidak ada koneksi internet',
        actionHint: 'Periksa koneksi WiFi atau data seluler Anda',
      );
    }
    if (failure is TimeoutFailure) {
      return const ProcurementException(
        'Server tidak merespons',
        actionHint: 'Coba lagi dalam beberapa saat',
      );
    }
    if (failure is RateLimitFailure) {
      return const ProcurementException(
        'Terlalu banyak permintaan',
        actionHint: 'Tunggu sebentar lalu coba lagi',
      );
    }
    if (failure is ServerFailure) {
      return ProcurementException(
        failure.message,
        actionHint: 'Coba lagi atau hubungi admin',
      );
    }
    return const ProcurementException(
      'Terjadi kesalahan',
      actionHint: 'Coba lagi',
    );
  }

  @override
  String toString() => userMessage;
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _formatRupiah(num value) {
  if (value >= 1e12) return 'Rp ${(value / 1e12).toStringAsFixed(1)} T';
  if (value >= 1e9) return 'Rp ${(value / 1e9).toStringAsFixed(1)} M';
  if (value >= 1e6) return 'Rp ${(value / 1e6).toStringAsFixed(0)} Jt';
  return 'Rp ${value.toStringAsFixed(0)}';
}

NeoBadgeVariant _riskVariant(double score) {
  if (score >= 0.7) return NeoBadgeVariant.error;
  if (score >= 0.4) return NeoBadgeVariant.warning;
  return NeoBadgeVariant.success;
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class ProcurementDashboardScreen extends ConsumerStatefulWidget {
  const ProcurementDashboardScreen({super.key});

  @override
  ConsumerState<ProcurementDashboardScreen> createState() =>
      _ProcurementDashboardScreenState();
}

class _ProcurementDashboardScreenState
    extends ConsumerState<ProcurementDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final asyncBootstrap = ref.watch(_bootstrapProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= AppSpacing.breakpointLg;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Procurement Dashboard', style: AppTypography.headlineMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () => ref.invalidate(_bootstrapProvider),
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: asyncBootstrap.when(
        loading: () => _buildLoadingState(isTablet),
        // FIX #3: Show sanitized user-friendly error message
        error: (error, _) => NeoError(
          message: _extractUserMessage(error),
          onRetry: () => ref.invalidate(_bootstrapProvider),
        ),
        data: (data) => _buildDataState(data, isTablet),
      ),
    );
  }

  /// Extract user-friendly message from error.
  /// Never shows raw exception details, stack traces, or internal URLs.
  String _extractUserMessage(Object error) {
    if (error is ProcurementException) {
      final hint = error.actionHint;
      if (hint != null) return '${error.userMessage}\n$hint';
      return error.userMessage;
    }
    // Fallback — should never reach here if provider is correct
    return 'Terjadi kesalahan. Coba lagi.';
  }

  // ─── Loading State ───────────────────────────────────────────────────────

  Widget _buildLoadingState(bool isTablet) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: isTablet ? 2 : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md2,
            crossAxisSpacing: AppSpacing.md2,
            childAspectRatio: isTablet ? 2.2 : 2.8,
            children: List.generate(4, (_) => NeoSkeleton.card()),
          ),
          const SizedBox(height: AppSpacing.xl),
          NeoSkeleton.text(width: 180),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(
            5,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: NeoSkeleton.card(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Data State ──────────────────────────────────────────────────────────

  Widget _buildDataState(BootstrapModel data, bool isTablet) {
    final summary = data.summary;
    final topRegions = List<RegionModel>.from(data.regions)
      ..sort((a, b) => b.avgRiskScore.compareTo(a.avgRiskScore));
    final top5 = topRegions.take(5).toList();

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_bootstrapProvider),
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary Stats ──────────────────────────────────────────────
            GridView.count(
              crossAxisCount: isTablet ? 2 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md2,
              crossAxisSpacing: AppSpacing.md2,
              childAspectRatio: isTablet ? 2.2 : 2.8,
              children: [
                NeoStatCard(
                  label: 'Total Paket',
                  value: '${summary?.totalPackages ?? 0}',
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.info,
                  subtitle: 'paket',
                ),
                NeoStatCard(
                  label: 'Potensi Pemborosan',
                  value: _formatRupiah(summary?.totalPotentialWaste ?? 0),
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.error,
                ),
                NeoStatCard(
                  label: 'Total Anggaran',
                  value: _formatRupiah(summary?.totalBudget ?? 0),
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.secondary,
                ),
                NeoStatCard(
                  label: 'Paket Absurd',
                  value: '${summary?.totalPriorityPackages ?? 0}',
                  icon: Icons.flag_rounded,
                  color: AppColors.warning,
                  subtitle: 'prioritas',
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Top Wilayah Berisiko ───────────────────────────────────────
            Text(
              'Top Wilayah Berisiko',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Peringkat berdasarkan rata-rata skor risiko',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),

            if (top5.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'Belum ada data wilayah',
                    style: AppTypography.bodySmall,
                  ),
                ),
              )
            else
              ...top5.asMap().entries.map(
                    (entry) => _buildRegionCard(entry.key + 1, entry.value),
                  ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  // ─── Region Card ─────────────────────────────────────────────────────────

  Widget _buildRegionCard(int rank, RegionModel region) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md2),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Rank indicator
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md2),

          // Region info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  region.regionName ?? region.regionKey,
                  style: AppTypography.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  region.provinceName ?? '-',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      '${region.totalPackages} paket',
                      style: AppTypography.codeSmall,
                    ),
                    const SizedBox(width: AppSpacing.md2),
                    Text(
                      _formatRupiah(region.totalPotentialWaste),
                      style: AppTypography.codeSmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Risk badge
          NeoBadge(
            label: '${(region.avgRiskScore * 100).toStringAsFixed(0)}%',
            variant: _riskVariant(region.avgRiskScore),
            icon: Icons.shield_outlined,
          ),
        ],
      ),
    );
  }
}
