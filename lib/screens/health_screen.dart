import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api/health/health_service.dart';
import '../api/core/provider_registry.dart';
import '../api/cache/in_memory_cache_store.dart';
import '../api/cache/cache_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../widgets/core/neo_card.dart';
import '../widgets/core/neo_badge.dart';
import '../widgets/data/neo_stat_card.dart';
import '../widgets/feedback/neo_error.dart';

/// API Health Monitor — Neo-Violet Academic theme
/// Displays provider health status, latency, and cache stats.
class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  AppHealthReport? _report;
  bool _isLoading = false;
  String? _error;

  // BUG-002/003 fix: create once, reuse across calls
  late final http.Client _httpClient;
  late final CacheStore _cacheStore;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    _cacheStore = InMemoryCacheStore();
    _runHealthCheck();
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  Future<void> _runHealthCheck() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = HealthService(
        httpClient: _httpClient,
        cacheStore: _cacheStore,
      );
      final report = await service.checkAll();
      if (mounted) {
        setState(() {
          _report = report;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('API Health Monitor', style: AppTypography.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _isLoading ? null : _runHealthCheck,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: _runHealthCheck,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _report == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null && _report == null) {
      return NeoError(
        message: _error!,
        onRetry: _runHealthCheck,
      );
    }

    if (_report == null) {
      return const SizedBox.shrink();
    }

    final report = _report!;
    final allHealthy = report.unavailableCount == 0 && report.degradedCount == 0;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppSpacing.screenPadding,
      children: [
        // Overall status card
        _buildOverallStatusCard(report, allHealthy),
        const SizedBox(height: AppSpacing.lg),

        // Stats row
        _buildStatsRow(report),
        const SizedBox(height: AppSpacing.lg),

        // Endpoint list header
        const Text('Endpoints', style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.md2),

        // Provider cards
        ...report.providers.map(_buildProviderCard),

        const SizedBox(height: AppSpacing.lg),

        // Last check timestamp
        Center(
          child: Text(
            'Terakhir dicek: ${_formatTimestamp(report.generatedAt)}',
            style: AppTypography.codeSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }

  Widget _buildOverallStatusCard(AppHealthReport report, bool allHealthy) {
    return NeoCard(
      variant: NeoCardVariant.gradient,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (allHealthy ? AppColors.success : AppColors.warning)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              allHealthy
                  ? Icons.check_circle_rounded
                  : Icons.warning_amber_rounded,
              color: allHealthy ? AppColors.success : AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allHealthy ? 'Semua Sistem Normal' : 'Ada Gangguan',
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${report.providers.length} provider terpantau',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          NeoBadge(
            label: allHealthy ? 'OK' : '${report.unavailableCount} down',
            variant:
                allHealthy ? NeoBadgeVariant.success : NeoBadgeVariant.warning,
            icon: allHealthy ? Icons.verified_rounded : Icons.error_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AppHealthReport report) {
    return Row(
      children: [
        Expanded(
          child: NeoStatCard(
            label: 'Healthy',
            value: report.healthyCount.toString(),
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: NeoStatCard(
            label: 'Degraded',
            value: report.degradedCount.toString(),
            icon: Icons.warning_amber_rounded,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: NeoStatCard(
            label: 'Down',
            value: report.unavailableCount.toString(),
            icon: Icons.cancel_outlined,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard(ProviderHealthResult result) {
    final color = _statusColor(result.status);
    final latencyText = result.latency != null
        ? '${result.latency!.inMilliseconds}ms'
        : '-';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: NeoCard(
        variant: NeoCardVariant.flat,
        child: Row(
          children: [
            // Status dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md2),
            // Name + status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.providerName,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.message ?? _statusLabel(result.status),
                    style: AppTypography.bodySmall.copyWith(color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Latency
            Text(
              latencyText,
              style: AppTypography.codeMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(ProviderStatus status) {
    switch (status) {
      case ProviderStatus.healthy:
        return AppColors.success;
      case ProviderStatus.degraded:
      case ProviderStatus.rateLimited:
        return AppColors.warning;
      case ProviderStatus.unavailable:
      case ProviderStatus.malformed:
      case ProviderStatus.timeout:
        return AppColors.error;
      case ProviderStatus.unknown:
        return AppColors.textTertiary;
    }
  }

  String _statusLabel(ProviderStatus status) {
    switch (status) {
      case ProviderStatus.healthy:
        return 'Healthy';
      case ProviderStatus.degraded:
        return 'Degraded';
      case ProviderStatus.rateLimited:
        return 'Rate Limited';
      case ProviderStatus.unavailable:
        return 'Unavailable';
      case ProviderStatus.malformed:
        return 'Malformed Response';
      case ProviderStatus.timeout:
        return 'Timeout';
      case ProviderStatus.unknown:
        return 'Unknown';
    }
  }

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} $h:$m:$s';
  }
}
