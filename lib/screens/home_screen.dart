import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_factory.dart';
import '../api/multi_api_factory.dart';
import '../models/mahasiswa.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_gradients.dart';
import '../widgets/search/neo_search_bar.dart';
import '../widgets/core/neo_card.dart';
import '../widgets/core/neo_badge.dart';
import '../widgets/feedback/neo_skeleton.dart';
import '../widgets/feedback/neo_empty.dart';
import '../widgets/navigation/neo_quick_action.dart';
import '../utils/constants.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _filterController = TextEditingController();
  List<Mahasiswa> _searchResults = [];
  List<Mahasiswa> _filteredResults = [];
  bool _isLoading = false;
  bool _isSearchInProgress = false;
  String? _errorMessage;

  late MultiApiFactory _multiApiFactory;
  bool _useMultiSource = true;

  List<String> _universities = [];
  String? _selectedUniversity;
  Timer? _filterDebounce;

  @override
  void initState() {
    super.initState();
    _multiApiFactory = MultiApiFactory();
    _filterController.addListener(_onFilterChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterController.dispose();
    _filterDebounce?.cancel();
    super.dispose();
  }

  // ─── Filter Logic ──────────────────────────────────────────────────────────

  void _onFilterChanged() {
    if (_filterDebounce?.isActive ?? false) {
      _filterDebounce!.cancel();
    }
    _filterDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_filterController.text.isNotEmpty) {
        _autoFilterResults(_filterController.text);
      }
    });
  }

  void _autoFilterResults(String query) {
    final matchingUniversities = _universities
        .where((u) => u.toLowerCase().contains(query.toLowerCase()))
        .toList();
    if (matchingUniversities.isNotEmpty) {
      _filterResults(matchingUniversities.first);
    }
  }

  void _extractUniversities(List<Mahasiswa> results) {
    final Set<String> unique = {};
    for (var m in results) {
      if (m.namaPt.isNotEmpty) unique.add(m.namaPt);
    }
    setState(() {
      _universities = unique.toList()..sort();
    });
  }

  void _filterResults(String? university) {
    setState(() {
      _selectedUniversity = university;
      if (university == null) {
        _filteredResults = _searchResults;
      } else {
        _filteredResults =
            _searchResults.where((m) => m.namaPt == university).toList();
      }
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedUniversity = null;
      _filteredResults = _searchResults;
      _filterController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.filterCleared, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary)),
        backgroundColor: AppColors.surface,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ─── Search Logic ──────────────────────────────────────────────────────────

  void _performSearch([String? _]) {
    if (_isSearchInProgress) return;
    _isSearchInProgress = true;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedUniversity = null;
      _filterController.clear();
      _universities = [];
      _filteredResults = [];
    });

    final String query = _searchController.text.trim();
    final sanitizedQuery =
        query.replaceAll(RegExp(r'[<>"' "'" r']'), '').trim();
    if (sanitizedQuery.length < 2) {
      setState(() {
        _errorMessage = 'Minimal 2 karakter untuk pencarian';
        _isLoading = false;
      });
      _isSearchInProgress = false;
      return;
    }

    _actuallyPerformSearch(sanitizedQuery);
  }

  Future<void> _actuallyPerformSearch(String sanitizedQuery) async {
    if (sanitizedQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _filteredResults = [];
        _errorMessage = AppStrings.pleaseEnterSearchTerm;
        _isLoading = false;
      });
      _isSearchInProgress = false;
      return;
    }

    try {
      List<Mahasiswa> results = [];
      try {
        if (_useMultiSource) {
          results = await _multiApiFactory.searchAllSources(sanitizedQuery);
        } else {
          final api = Provider.of<ApiFactory>(context, listen: false);
          results = await api.searchMahasiswa(sanitizedQuery);
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Error dalam pencarian: $e');
        String errorMsg = e.toString();
        if (errorMsg.contains('XMLHttpRequest')) {
          throw Exception('Gagal terhubung ke server. Periksa koneksi internet atau coba lagi nanti.');
        } else if (errorMsg.contains('Timeout')) {
          throw Exception('Koneksi timeout. Server sibuk, silakan coba lagi.');
        } else if (errorMsg.contains('403')) {
          throw Exception('Akses ditolak oleh server (403 Forbidden).');
        } else {
          throw Exception('Error: $e');
        }
      }

      setState(() {
        _searchResults = results;
        _filteredResults = results;
        _isLoading = false;
        if (results.isEmpty) {
          _errorMessage = '${AppStrings.noResultsFound} "$sanitizedQuery"';
        } else {
          _errorMessage = null;
          _extractUniversities(results);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
        _filteredResults = [];
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      _isSearchInProgress = false;
    }
  }

  void _viewMahasiswaDetail(BuildContext context, Mahasiswa mahasiswa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          mahasiswaId: mahasiswa.id,
          subjectName: mahasiswa.nama,
        ),
      ),
    );
  }

  // ─── UI Helpers ────────────────────────────────────────────────────────────

  bool get _hasResults => _searchResults.isNotEmpty && !_isLoading;

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildGradientHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: NeoSearchBar(
                controller: _searchController,
                onSubmitted: _performSearch,
                isLoading: _isLoading,
                hintText: AppStrings.searchHint,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? _buildLoadingSkeleton()
                  : _hasResults
                      ? _buildSearchResults()
                      : _errorMessage != null
                          ? _buildErrorState()
                          : _buildDefaultContent(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Gradient Header ───────────────────────────────────────────────────────

  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: const BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.homeTitle,
                  style: AppTypography.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PDDIKTI Data Explorer',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              NeoBadge(
                label: AppStrings.appVersion,
                variant: NeoBadgeVariant.info,
              ),
              const SizedBox(height: 8),
              _buildMultiSourceToggle(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSourceToggle() {
    return GestureDetector(
      onTap: () {
        setState(() => _useMultiSource = !_useMultiSource);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _useMultiSource
                  ? 'Mode Multi-Source diaktifkan'
                  : 'Mode PDDIKTI saja',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.surface,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _useMultiSource ? Icons.cloud_sync_rounded : Icons.cloud_outlined,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              _useMultiSource ? 'MULTI-DB' : 'PDDIKTI',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Default Content (Quick Actions) ───────────────────────────────────────

  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Akses Cepat', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95,
            children: [
              NeoQuickAction(
                icon: Icons.school_rounded,
                label: 'Mahasiswa',
                color: AppColors.primary,
                onTap: () => _searchController.text.isEmpty
                    ? null
                    : _performSearch(),
              ),
              NeoQuickAction(
                icon: Icons.person_rounded,
                label: 'Dosen',
                color: AppColors.secondary,
                onTap: () => Navigator.pushNamed(context, '/dosen'),
              ),
              NeoQuickAction(
                icon: Icons.menu_book_rounded,
                label: 'Prodi',
                color: AppColors.success,
                onTap: () => Navigator.pushNamed(context, '/prodi'),
              ),
              NeoQuickAction(
                icon: Icons.account_balance_rounded,
                label: 'Kampus',
                color: AppColors.warning,
                onTap: () => Navigator.pushNamed(context, '/kampus'),
              ),
              NeoQuickAction(
                icon: Icons.monitor_heart_rounded,
                label: 'Health',
                color: AppColors.error,
                onTap: () => Navigator.pushNamed(context, '/health'),
              ),
              NeoQuickAction(
                icon: Icons.domain_rounded,
                label: 'Sekolah',
                color: AppColors.info,
                onTap: () => Navigator.pushNamed(context, '/sekolah'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          NeoEmpty(
            icon: Icons.search_rounded,
            title: AppStrings.emptySearchPrompt,
            subtitle: 'Gunakan search bar di atas untuk mencari data mahasiswa dari PDDIKTI',
          ),
        ],
      ),
    );
  }

  // ─── Loading Skeleton ──────────────────────────────────────────────────────

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: NeoCard(
          child: Row(
            children: [
              NeoSkeleton.circle(size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NeoSkeleton.text(width: 160),
                    const SizedBox(height: 8),
                    NeoSkeleton.text(width: 120),
                    const SizedBox(height: 6),
                    NeoSkeleton.text(width: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Error State ───────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.errorSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.error_outline_rounded, size: 32, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _performSearch,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Search Results ────────────────────────────────────────────────────────

  Widget _buildSearchResults() {
    final displayResults = _filteredResults;

    return Column(
      children: [
        // Filter chips row
        if (_universities.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _universities.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isActive = _selectedUniversity == null;
                        return _buildFilterChip('Semua', isActive, () => _clearFilter());
                      }
                      final uni = _universities[index - 1];
                      final isActive = _selectedUniversity == uni;
                      return _buildFilterChip(
                        uni.length > 20 ? '${uni.substring(0, 18)}...' : uni,
                        isActive,
                        () => _filterResults(uni),
                      );
                    },
                  ),
                ),
                if (_selectedUniversity != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(Icons.filter_alt_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${displayResults.length} hasil dari $_selectedUniversity',
                            style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        // Results count
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text(
                '${displayResults.length} hasil ditemukan',
                style: AppTypography.labelMedium,
              ),
              const Spacer(),
              if (_useMultiSource)
                NeoBadge(label: 'Multi-Source', variant: NeoBadgeVariant.info, icon: Icons.cloud_sync_rounded),
            ],
          ),
        ),
        // Results list
        Expanded(
          child: displayResults.isEmpty
              ? NeoEmpty(
                  icon: Icons.filter_alt_off_rounded,
                  title: AppStrings.noFilterResultsFound,
                  actionLabel: AppStrings.clearFilter,
                  onAction: _clearFilter,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: displayResults.length,
                  itemBuilder: (context, index) {
                    final m = displayResults[index];
                    return _buildResultItem(m);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppSpacing.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildResultItem(Mahasiswa m) {
    final initial = m.nama.isNotEmpty ? m.nama[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeoCard(
        variant: NeoCardVariant.flat,
        onTap: () => _viewMahasiswaDetail(context, m),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: AppTypography.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.nama,
                    style: AppTypography.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    m.namaPt,
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // NIM badge
            if (m.nim.isNotEmpty)
              NeoBadge(label: m.nim, variant: NeoBadgeVariant.neutral),
          ],
        ),
      ),
    );
  }
}
