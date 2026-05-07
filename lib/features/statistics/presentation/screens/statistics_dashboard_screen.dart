import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/core/neo_card.dart';
import '../../../../widgets/core/neo_badge.dart';
import '../../../../widgets/search/neo_search_bar.dart';
import '../../../../widgets/feedback/neo_empty.dart';
import '../../../../widgets/feedback/neo_error.dart';
import '../../../../widgets/feedback/neo_skeleton.dart';

// ─── Provider ────────────────────────────────────────────────────────────────

final _ckanSearchProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];
  final dio = Dio();
  final response = await dio.get(
    'https://data.go.id/api/3/action/package_search',
    queryParameters: {'q': query, 'rows': 15},
  );
  final results = response.data['result']['results'] as List;
  return results.cast<Map<String, dynamic>>();
});

// ─── Screen ──────────────────────────────────────────────────────────────────

class StatisticsDashboardScreen extends ConsumerStatefulWidget {
  const StatisticsDashboardScreen({super.key});

  @override
  ConsumerState<StatisticsDashboardScreen> createState() =>
      _StatisticsDashboardScreenState();
}

class _StatisticsDashboardScreenState
    extends ConsumerState<StatisticsDashboardScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= AppSpacing.breakpointLg;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Statistics Dashboard', style: AppTypography.headlineMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm,
            ),
            child: NeoSearchBar(
              controller: _searchController,
              hintText: 'Cari dataset di data.go.id...',
              onSubmitted: (val) => setState(() => _query = val),
              onClear: () => setState(() => _query = ''),
            ),
          ),
          Expanded(child: _buildBody(isTablet)),
        ],
      ),
    );
  }

  Widget _buildBody(bool isTablet) {
    if (_query.isEmpty) {
      return const NeoEmpty(
        icon: Icons.bar_chart_rounded,
        title: 'Cari Dataset CKAN',
        subtitle: 'Ketik kata kunci lalu tekan enter untuk mencari dataset publik',
      );
    }

    final asyncResults = ref.watch(_ckanSearchProvider(_query));

    return asyncResults.when(
      loading: () => _buildLoading(),
      error: (err, _) => NeoError(
        message: 'Gagal memuat data: $err',
        onRetry: () => ref.invalidate(_ckanSearchProvider(_query)),
      ),
      data: (results) {
        if (results.isEmpty) {
          return NeoEmpty(
            icon: Icons.search_off_rounded,
            title: 'Tidak ditemukan',
            subtitle: 'Tidak ada dataset untuk "$_query"',
          );
        }
        return ListView.builder(
          padding: AppSpacing.screenPadding,
          itemCount: results.length,
          itemBuilder: (_, i) => _buildResultCard(results[i]),
        );
      },
    );
  }

  Widget _buildLoading() {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: List.generate(
          5,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md2),
            child: NeoSkeleton.card(),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> dataset) {
    final title = dataset['title'] ?? 'Untitled';
    final org = dataset['organization']?['title'] ?? '-';
    final resources = (dataset['resources'] as List?) ?? [];
    final formats = resources
        .map((r) => (r['format'] ?? '').toString().toUpperCase())
        .where((f) => f.isNotEmpty)
        .toSet()
        .take(3)
        .toList();
    final date = dataset['metadata_modified']?.toString().split('T').first ?? '-';

    return NeoCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.headlineSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.business_rounded, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(org, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              ...formats.map((f) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: NeoBadge(label: f, variant: _formatVariant(f)),
              )),
              const Spacer(),
              Text(date, style: AppTypography.codeSmall),
            ],
          ),
        ],
      ),
    );
  }

  NeoBadgeVariant _formatVariant(String format) {
    switch (format) {
      case 'CSV':
        return NeoBadgeVariant.success;
      case 'JSON':
        return NeoBadgeVariant.info;
      case 'PDF':
        return NeoBadgeVariant.warning;
      default:
        return NeoBadgeVariant.neutral;
    }
  }
}
