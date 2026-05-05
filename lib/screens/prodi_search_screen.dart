import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../api/multi_api_factory.dart';
import '../models/prodi.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../widgets/search/neo_search_bar.dart';
import '../widgets/core/neo_card.dart';
import '../widgets/core/neo_badge.dart';
import '../widgets/feedback/neo_skeleton.dart';
import '../widgets/feedback/neo_empty.dart';
import '../widgets/feedback/neo_error.dart';
import '../utils/constants.dart';

/// Screen pencarian program studi — Neo-Violet Academic theme.
class ProdiSearchScreen extends StatefulWidget {
  const ProdiSearchScreen({Key? key}) : super(key: key);

  @override
  State<ProdiSearchScreen> createState() => _ProdiSearchScreenState();
}

enum _ProdiSearchState { initial, loading, empty, error, results }

class _ProdiSearchScreenState extends State<ProdiSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final MultiApiFactory _multiApiFactory;

  List<Prodi> _searchResults = [];
  String? _errorMessage;
  bool _isSearchInProgress = false;
  _ProdiSearchState _state = _ProdiSearchState.initial;

  @override
  void initState() {
    super.initState();
    _multiApiFactory = MultiApiFactory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Search Logic ──────────────────────────────────────────────────────────

  Future<void> _searchProdi(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      setState(() => _errorMessage = AppStrings.pleaseEnterSearchTerm);
      return;
    }

    final sanitized = trimmed
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '')
        .replaceAll("'", '');
    if (sanitized.length < 2) {
      setState(() => _errorMessage = 'Minimal 2 karakter untuk pencarian');
      return;
    }

    if (_isSearchInProgress) return;
    _isSearchInProgress = true;

    setState(() {
      _state = _ProdiSearchState.loading;
      _errorMessage = null;
      _searchResults.clear();
    });

    try {
      final results = await _multiApiFactory
          .searchProdi(sanitized)
          .timeout(const Duration(seconds: 30));

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _state = results.isEmpty
            ? _ProdiSearchState.empty
            : _ProdiSearchState.results;
      });
    } catch (e) {
      if (!mounted) return;
      if (kDebugMode) debugPrint('Prodi search error: $e');

      String errorMsg = e.toString().replaceAll('Exception: ', '');
      if (errorMsg.contains('XMLHttpRequest')) {
        errorMsg = 'Gagal terhubung ke server. Periksa koneksi internet.';
      } else if (errorMsg.contains('Timeout')) {
        errorMsg = 'Koneksi timeout. Server sibuk, silakan coba lagi.';
      } else if (errorMsg.contains('403')) {
        errorMsg = 'Akses ditolak oleh server (403 Forbidden).';
      }

      setState(() {
        _state = _ProdiSearchState.error;
        _errorMessage = errorMsg;
      });
    } finally {
      _isSearchInProgress = false;
    }
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
                  Text(
                    'Cari Program Studi',
                    style: AppTypography.headlineMedium,
                  ),
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
                hintText: 'Nama prodi atau universitas...',
                isLoading: _state == _ProdiSearchState.loading,
                onSubmitted: _searchProdi,
              ),
            ),

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

  // ─── Content States ────────────────────────────────────────────────────────

  Widget _buildContent() {
    switch (_state) {
      case _ProdiSearchState.initial:
        return _buildInitial();
      case _ProdiSearchState.loading:
        return _buildLoading();
      case _ProdiSearchState.empty:
        return NeoEmpty(
          key: const ValueKey('empty'),
          icon: Icons.search_off_rounded,
          title: 'Program studi tidak ditemukan',
          subtitle: 'Coba kata kunci lain atau periksa ejaan',
        );
      case _ProdiSearchState.error:
        return NeoError(
          key: const ValueKey('error'),
          message: _errorMessage ?? 'Terjadi kesalahan',
          onRetry: () => _searchProdi(_searchController.text),
        );
      case _ProdiSearchState.results:
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
              Icons.account_balance_rounded,
              size: 32,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg2),
          Text(
            'Cari program studi di seluruh Indonesia',
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
                NeoSkeleton.text(width: 200),
                const SizedBox(height: AppSpacing.sm),
                NeoSkeleton.text(width: 140),
                const SizedBox(height: AppSpacing.sm),
                NeoSkeleton.text(width: 60),
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
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, index) => _buildResultCard(_searchResults[index]),
    );
  }

  // ─── Result Card ───────────────────────────────────────────────────────────

  Widget _buildResultCard(Prodi prodi) {
    return NeoCard(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/prodi/detail/${prodi.id}',
          arguments: prodi,
        );
      },
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondaryDark.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.account_balance_rounded,
              size: 20,
              color: AppColors.secondaryLight,
            ),
          ),
          const SizedBox(width: AppSpacing.md2),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prodi.nama,
                  style: AppTypography.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  prodi.pt,
                  style: AppTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (prodi.jenjang.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  NeoBadge(
                    label: prodi.jenjang,
                    variant: NeoBadgeVariant.info,
                    icon: Icons.school_rounded,
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
