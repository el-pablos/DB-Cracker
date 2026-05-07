import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/core/neo_card.dart';
import '../../../../widgets/core/neo_badge.dart';
import '../../../../widgets/data/neo_stat_card.dart';

// ─── Mock Data ───────────────────────────────────────────────────────────────

class _ExchangeRate {
  final String pair;
  final double rate;
  final double change;
  final String updatedAt;
  const _ExchangeRate({required this.pair, required this.rate, required this.change, required this.updatedAt});
}

class _UmpData {
  final String province;
  final int ump;
  final int year;
  const _UmpData({required this.province, required this.ump, required this.year});
}

final _exchangeRateProvider = FutureProvider<_ExchangeRate>((ref) async {
  await Future.delayed(const Duration(milliseconds: 800));
  return const _ExchangeRate(pair: 'USD/IDR', rate: 16245, change: -0.32, updatedAt: '2025-01-07');
});

final _umpProvider = FutureProvider<List<_UmpData>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return const [
    _UmpData(province: 'DKI Jakarta', ump: 5067381, year: 2024),
    _UmpData(province: 'Papua', ump: 4024000, year: 2024),
    _UmpData(province: 'Papua Barat', ump: 3864696, year: 2024),
    _UmpData(province: 'Kalimantan Timur', ump: 3360858, year: 2024),
    _UmpData(province: 'Sulawesi Utara', ump: 3485000, year: 2024),
  ];
});

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _formatRupiah(num value) {
  final str = value.toStringAsFixed(0);
  final buffer = StringBuffer();
  for (var i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
    buffer.write(str[i]);
  }
  return 'Rp $buffer';
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class EconomyDashboardScreen extends ConsumerStatefulWidget {
  const EconomyDashboardScreen({super.key});

  @override
  ConsumerState<EconomyDashboardScreen> createState() => _EconomyDashboardScreenState();
}

class _EconomyDashboardScreenState extends ConsumerState<EconomyDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= AppSpacing.breakpointLg;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Economy Dashboard', style: AppTypography.headlineMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: () {
              ref.invalidate(_exchangeRateProvider);
              ref.invalidate(_umpProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExchangeSection(isTablet),
            const SizedBox(height: AppSpacing.xl),
            _buildUmpSection(isTablet),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  // ─── Exchange Rate Hero ──────────────────────────────────────────────────

  Widget _buildExchangeSection(bool isTablet) {
    final asyncRate = ref.watch(_exchangeRateProvider);

    return asyncRate.when(
      loading: () => NeoStatCard(
        label: 'Memuat kurs...',
        value: '---',
        icon: Icons.currency_exchange_rounded,
        color: AppColors.secondary,
      ),
      error: (_, __) => NeoStatCard(
        label: 'Gagal memuat kurs',
        value: 'Error',
        icon: Icons.error_outline_rounded,
        color: AppColors.error,
      ),
      data: (rate) => NeoCard(
        variant: NeoCardVariant.elevated,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Icon(Icons.currency_exchange_rounded, color: AppColors.secondary, size: 20),
                ),
                const SizedBox(width: AppSpacing.md2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rate.pair, style: AppTypography.labelLarge),
                    Text('Update: ${rate.updatedAt}', style: AppTypography.codeSmall),
                  ],
                ),
                const Spacer(),
                NeoBadge(
                  label: '${rate.change > 0 ? '+' : ''}${rate.change.toStringAsFixed(2)}%',
                  variant: rate.change >= 0 ? NeoBadgeVariant.error : NeoBadgeVariant.success,
                  icon: rate.change >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Rp ${rate.rate.toStringAsFixed(0)}',
              style: AppTypography.displayLarge.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('per 1 USD (mock data — BI API butuh registrasi)', style: AppTypography.bodySmall),
          ],
        ),
      ),
    );
  }

  // ─── UMP Section ─────────────────────────────────────────────────────────

  Widget _buildUmpSection(bool isTablet) {
    final asyncUmp = ref.watch(_umpProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top 5 UMP Tertinggi 2024', style: AppTypography.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Text('Upah Minimum Provinsi', style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.md),
        asyncUmp.when(
          loading: () => Column(
            children: List.generate(5, (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
            )),
          ),
          error: (err, _) => Text('Error: $err', style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
          data: (list) => Column(
            children: list.asMap().entries.map((entry) => _buildUmpRow(entry.key + 1, entry.value, isTablet)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildUmpRow(int rank, _UmpData data, bool isTablet) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            alignment: Alignment.center,
            child: Text('#$rank', style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
          ),
          const SizedBox(width: AppSpacing.md2),
          Expanded(
            child: Text(data.province, style: AppTypography.headlineSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Text(_formatRupiah(data.ump), style: AppTypography.codeMedium.copyWith(color: AppColors.success)),
        ],
      ),
    );
  }
}
