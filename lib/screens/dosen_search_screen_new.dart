import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_factory.dart';
import '../models/dosen.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../widgets/search/neo_search_bar.dart';
import '../widgets/core/neo_card.dart';
import '../widgets/feedback/neo_skeleton.dart';
import '../widgets/feedback/neo_empty.dart';
import '../widgets/feedback/neo_error.dart';

/// Screen pencarian dosen — Neo-Violet Academic theme.
class DosenSearchScreenNew extends StatefulWidget {
  const DosenSearchScreenNew({Key? key}) : super(key: key);

  @override
  State<DosenSearchScreenNew> createState() => _DosenSearchScreenNewState();
}

enum _SearchState { initial, loading, empty, error, results }

class _DosenSearchScreenNewState extends State<DosenSearchScreenNew> {
  final TextEditingController _searchController = TextEditingController();

  List<Dosen> _searchResults = [];
  List<Dosen> _filteredResults = [];
  List<String> _ptList = [];
  String? _selectedPt;
  String? _errorMessage;
  _SearchState _state = _SearchState.initial;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Search Logic ──────────────────────────────────────────────────────────

  Future<void> _searchDosen(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      setState(() => _errorMessage = 'Masukkan nama dosen untuk mencari');
      return;
    }
    if (trimmed.length < 2) {
      setState(() => _errorMessage = 'Nama dosen minimal 2 karakter');
      return;
    }

    final sanitized = trimmed
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '')
        .replaceAll("'", '');
    if (sanitized.isEmpty) {
      setState(() => _errorMessage = 'Nama dosen tidak valid');
      return;
    }

    setState(() {
      _state = _SearchState.loading;
      _errorMessage = null;
      _searchResults.clear();
      _filteredResults.clear();
      _ptList.clear();
      _selectedPt = null;
    });

    try {
      final apiFactory = Provider.of<ApiFactory>(context, listen: false);
      final results = await apiFactory
          .searchDosen(sanitized)
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _filteredResults = results;
        _ptList = results.map((d) => d.namaPt).toSet().toList()..sort();
        _state = results.isEmpty ? _SearchState.empty : _SearchState.results;
      });
    } catch (e) {
      if (!mounted) return;
      if (kDebugMode) debugPrint('Search error: $e');
      setState(() {
        _state = _SearchState.error;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _filterByPt(String? pt) {
    setState(() {
      _selectedPt = pt;
      _filteredResults = pt == null
          ? _searchResults
          : _searchResults.where((d) => d.namaPt == pt).toList();
    });
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm, AppSpacing.md, AppSpacing.md, 0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.textPrimary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Cari Dosen', style: AppTypography.headlineMedium),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md2,
              ),
              child: NeoSearchBar(
                controller: _searchController,
                autofocus: true,
                hintText: 'Masukkan nama dosen...',
                isLoading: _state == _SearchState.loading,
                onSubmitted: _searchDosen,
              ),
            ),

            // PT filter chips
            if (_ptList.length > 1) _buildPtFilter(),

            // Content area
            Expanded(
              child: AnimatedSwitcher(
                duration: AppSpacing.durationNormal,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PT Filter ─────────────────────────────────────────────────────────────

  Widget _buildPtFilter() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _ptList.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isActive = _selectedPt == null;
            return FilterChip(
              label: Text('Semua', style: AppTypography.labelMedium.copyWith(
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
              )),
              selected: isActive,
              onSelected: (_) => _filterByPt(null),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primaryDark,
              side: BorderSide(
                color: isActive ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            );
          }
          final pt = _ptList[index - 1];
          final isActive = _selectedPt == pt;
          return FilterChip(
            label: Text(
              pt.length > 25 ? '${pt.substring(0, 25)}...' : pt,
              style: AppTypography.labelMedium.copyWith(
                color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            selected: isActive,
            onSelected: (_) => _filterByPt(pt),
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primaryDark,
            side: BorderSide(
              color: isActive ? AppColors.primary : AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          );
        },
      ),
    );
  }

  // ─── Content States ────────────────────────────────────────────────────────

  Widget _buildContent() {
    switch (_state) {
      case _SearchState.initial:
        return _buildInitial();
      case _SearchState.loading:
        return _buildLoading();
      case _SearchState.empty:
        return NeoEmpty(
          key: const ValueKey('empty'),
          icon: Icons.person_search_rounded,
          title: 'Dosen tidak ditemukan',
          subtitle: 'Coba kata kunci lain atau periksa ejaan',
        );
      case _SearchState.error:
        return NeoError(
          key: const ValueKey('error'),
          message: _errorMessage ?? 'Terjadi kesalahan',
          onRetry: () => _searchDosen(_searchController.text),
        );
      case _SearchState.results:
        return _buildResults();
    }
  }

  Widget _buildInitial() {
    return Center(
      key: const ValueKey('initial'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg2),
          Text(
            'Cari dosen di seluruh Indonesia',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.separated(
      key: const ValueKey('loading'),
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md2),
      itemBuilder: (_, __) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return NeoCard(
      child: Row(
        children: [
          NeoSkeleton.circle(size: 44),
          const SizedBox(width: AppSpacing.md2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeoSkeleton.text(width: 180),
                const SizedBox(height: AppSpacing.sm),
                NeoSkeleton.text(width: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView.separated(
      key: const ValueKey('results'),
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _filteredResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, index) => _buildResultCard(_filteredResults[index]),
    );
  }

  // ─── Result Card ───────────────────────────────────────────────────────────

  Widget _buildResultCard(Dosen dosen) {
    final initial = dosen.nama.isNotEmpty ? dosen.nama[0].toUpperCase() : '?';

    return NeoCard(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/dosen/detail/${dosen.id}',
          arguments: dosen,
        );
      },
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.primaryLight,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md2),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dosen.nama,
                  style: AppTypography.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dosen.namaPt,
                  style: AppTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dosen.nidn.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'NIDN: ${dosen.nidn}',
                    style: AppTypography.codeSmall,
                  ),
                ],
              ],
            ),
          ),

          // Chevron
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
