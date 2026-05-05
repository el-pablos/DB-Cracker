import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api/sekolah/sekolah_service.dart';
import '../api/sekolah/sekolah_models.dart';
import '../api/cache/in_memory_cache_store.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../widgets/search/neo_search_bar.dart';
import '../widgets/core/neo_card.dart';
import '../widgets/feedback/neo_empty.dart';
import '../widgets/feedback/neo_error.dart';
import '../widgets/feedback/neo_skeleton.dart';
import '../widgets/data/neo_data_row.dart';
import '../widgets/core/neo_badge.dart';

/// Cari Sekolah — Neo-Violet Academic theme
/// NPSN lookup with clean card-based result display.
class SekolahLookupScreen extends StatefulWidget {
  const SekolahLookupScreen({super.key});

  @override
  State<SekolahLookupScreen> createState() => _SekolahLookupScreenState();
}

class _SekolahLookupScreenState extends State<SekolahLookupScreen> {
  final _npsnController = TextEditingController();
  Sekolah? _result;
  bool _isLoading = false;
  String? _error;


  // BUG-002/003 fix: create once, reuse across calls
  late final http.Client _httpClient;
  late final InMemoryCacheStore _cacheStore;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    _cacheStore = InMemoryCacheStore();
  }

  @override
  void dispose() {
    _npsnController.dispose();
    _httpClient.close();
    super.dispose();
  }

  Future<void> _lookup() async {
    final npsn = _npsnController.text.trim();
    if (npsn.isEmpty || npsn.length < 6) {
      setState(() => _error = 'NPSN harus minimal 6 digit angka');
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(npsn)) {
      setState(() => _error = 'NPSN harus berupa angka');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final service = SekolahService(
        httpClient: _httpClient,
        cacheStore: _cacheStore,
      );
      final result = await service.lookupByNpsn(npsn);
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
          if (result == null) {
            _error = 'Sekolah dengan NPSN "$npsn" tidak ditemukan';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Custom AppBar row
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                AppSpacing.md2,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text('Cari Sekolah', style: AppTypography.headlineMedium),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: NeoSearchBar(
                controller: _npsnController,
                hintText: 'Masukkan NPSN (min 6 digit)...',
                isLoading: _isLoading,
                onSubmitted: (_) => _lookup(),
                onClear: () {
                  setState(() {
                    _result = null;
                    _error = null;
                  });
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Content area with AnimatedSwitcher
            Expanded(
              child: AnimatedSwitcher(
                duration: AppSpacing.durationNormal,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Loading state
    if (_isLoading) {
      return Padding(
        key: const ValueKey('loading'),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          children: [
            NeoSkeleton.card(),
            const SizedBox(height: AppSpacing.md2),
            NeoSkeleton.card(),
          ],
        ),
      );
    }

    // Error state
    if (_error != null) {
      return NeoError(
        key: const ValueKey('error'),
        message: _error!,
        onRetry: _lookup,
      );
    }

    // Result state
    if (_result != null) {
      return _buildResultCard(_result!);
    }

    // Initial state — no search yet
    return const NeoEmpty(
      key: ValueKey('initial'),
      icon: Icons.school_rounded,
      title: 'Cari Sekolah',
      subtitle: 'Masukkan NPSN untuk mencari data sekolah dari database nasional',
    );
  }

  Widget _buildResultCard(Sekolah sekolah) {
    return SingleChildScrollView(
      key: const ValueKey('result'),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: NeoCard(
        variant: NeoCardVariant.elevated,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sekolah.nama,
                        style: AppTypography.headlineSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      NeoBadge(
                        label: sekolah.bentukPendidikan.isNotEmpty
                            ? sekolah.bentukPendidikan
                            : 'Sekolah',
                        variant: NeoBadgeVariant.info,
                        icon: Icons.category_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.sm),

            // Data rows
            NeoDataRow(
              label: 'NPSN',
              value: sekolah.npsn,
              icon: Icons.tag_rounded,
              isCode: true,
              copyable: true,
            ),
            NeoDataRow(
              label: 'Nama',
              value: sekolah.nama,
              icon: Icons.business_rounded,
            ),
            NeoDataRow(
              label: 'Alamat',
              value: sekolah.alamat,
              icon: Icons.location_on_outlined,
            ),
            NeoDataRow(
              label: 'Kab/Kota',
              value: sekolah.kabupatenKota,
              icon: Icons.location_city_rounded,
            ),
            NeoDataRow(
              label: 'Provinsi',
              value: sekolah.provinsi,
              icon: Icons.map_outlined,
            ),
            NeoDataRow(
              label: 'Jenjang',
              value: sekolah.bentukPendidikan,
              icon: Icons.school_outlined,
            ),
            if (sekolah.statusSekolah.isNotEmpty)
              NeoDataRow(
                label: 'Status',
                value: sekolah.statusSekolah,
                icon: Icons.verified_outlined,
              ),
            if (sekolah.kecamatan.isNotEmpty)
              NeoDataRow(
                label: 'Kecamatan',
                value: sekolah.kecamatan,
                icon: Icons.place_outlined,
              ),
            if (sekolah.kelurahan.isNotEmpty)
              NeoDataRow(
                label: 'Kelurahan',
                value: sekolah.kelurahan,
                icon: Icons.pin_drop_outlined,
              ),
            if (sekolah.lintang.isNotEmpty)
              NeoDataRow(
                label: 'Koordinat',
                value: '${sekolah.lintang}, ${sekolah.bujur}',
                icon: Icons.gps_fixed_rounded,
                isCode: true,
                copyable: true,
              ),
          ],
        ),
      ),
    );
  }
}
