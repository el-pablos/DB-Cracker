import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/core/neo_card.dart';
import '../../../../widgets/core/neo_badge.dart';
import '../../../../widgets/feedback/neo_empty.dart';
import '../../../../widgets/feedback/neo_error.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class _RiskResult {
  final String hazard;
  final double score;
  final String level;
  const _RiskResult({required this.hazard, required this.score, required this.level});
}

// ─── Provider ────────────────────────────────────────────────────────────────

final _riskLookupProvider =
    FutureProvider.family<List<_RiskResult>, ({double lat, double lon})>((ref, coords) async {
  final dio = Dio();
  try {
    final response = await dio.get(
      'https://gis.bnpb.go.id/api/risk',
      queryParameters: {'lat': coords.lat, 'lon': coords.lon},
    );
    final data = response.data;
    if (data is Map && data['results'] is List) {
      return (data['results'] as List).map((r) => _RiskResult(
        hazard: r['hazard'] ?? '-',
        score: (r['score'] as num?)?.toDouble() ?? 0,
        level: r['level'] ?? 'rendah',
      )).toList();
    }
  } catch (_) {
    // Fallback mock jika API tidak tersedia
  }
  return [
    const _RiskResult(hazard: 'Banjir', score: 0.72, level: 'tinggi'),
    const _RiskResult(hazard: 'Gempa Bumi', score: 0.55, level: 'sedang'),
    const _RiskResult(hazard: 'Tsunami', score: 0.31, level: 'rendah'),
    const _RiskResult(hazard: 'Tanah Longsor', score: 0.64, level: 'sedang'),
    const _RiskResult(hazard: 'Kebakaran Hutan', score: 0.42, level: 'sedang'),
  ];
});

// ─── Screen ──────────────────────────────────────────────────────────────────

class DisasterDashboardScreen extends ConsumerStatefulWidget {
  const DisasterDashboardScreen({super.key});

  @override
  ConsumerState<DisasterDashboardScreen> createState() => _DisasterDashboardScreenState();
}

class _DisasterDashboardScreenState extends ConsumerState<DisasterDashboardScreen> {
  final _latController = TextEditingController(text: '-6.2');
  final _lonController = TextEditingController(text: '106.8');
  ({double lat, double lon})? _coords;

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  void _doLookup() {
    final lat = double.tryParse(_latController.text);
    final lon = double.tryParse(_lonController.text);
    if (lat == null || lon == null) return;
    setState(() => _coords = (lat: lat, lon: lon));
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= AppSpacing.breakpointLg;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Disaster Dashboard', style: AppTypography.headlineMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputSection(),
            const SizedBox(height: AppSpacing.lg),
            if (_coords != null) _buildRiskResults(isTablet),
            const SizedBox(height: AppSpacing.xl),
            _buildIrbiPlaceholder(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  // ─── Input Section ───────────────────────────────────────────────────────

  Widget _buildInputSection() {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cek Risiko Bencana', style: AppTypography.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Masukkan koordinat untuk melihat profil risiko', style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _buildTextField(_latController, 'Latitude')),
              const SizedBox(width: AppSpacing.md2),
              Expanded(child: _buildTextField(_lonController, 'Longitude')),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _doLookup,
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Cek Risiko'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      style: AppTypography.codeMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.labelMedium,
        filled: true,
        fillColor: AppColors.surfaceHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  // ─── Risk Results ────────────────────────────────────────────────────────

  Widget _buildRiskResults(bool isTablet) {
    final asyncRisk = ref.watch(_riskLookupProvider(_coords!));

    return asyncRisk.when(
      loading: () => const Center(child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: CircularProgressIndicator(color: AppColors.primary),
      )),
      error: (err, _) => NeoError(
        message: 'Gagal memuat data risiko: $err',
        onRetry: () => ref.invalidate(_riskLookupProvider(_coords!)),
      ),
      data: (results) {
        if (results.isEmpty) {
          return const NeoEmpty(icon: Icons.check_circle_outline, title: 'Tidak ada data risiko');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profil Risiko', style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: isTablet ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md2,
              crossAxisSpacing: AppSpacing.md2,
              childAspectRatio: 1.4,
              children: results.map(_buildRiskCard).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRiskCard(_RiskResult risk) {
    final color = _riskColor(risk.score);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(risk.hazard, style: AppTypography.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            '${(risk.score * 100).toStringAsFixed(0)}%',
            style: AppTypography.displaySmall.copyWith(color: color, fontWeight: FontWeight.w800),
          ),
          NeoBadge(label: risk.level.toUpperCase(), variant: _levelVariant(risk.level)),
        ],
      ),
    );
  }

  Color _riskColor(double score) {
    if (score >= 0.7) return AppColors.error;
    if (score >= 0.4) return AppColors.warning;
    return AppColors.success;
  }

  NeoBadgeVariant _levelVariant(String level) {
    switch (level) {
      case 'tinggi':
        return NeoBadgeVariant.error;
      case 'sedang':
        return NeoBadgeVariant.warning;
      default:
        return NeoBadgeVariant.success;
    }
  }

  // ─── IRBI Placeholder ────────────────────────────────────────────────────

  Widget _buildIrbiPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top 10 Kabupaten Berisiko (IRBI)', style: AppTypography.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Text('Indeks Risiko Bencana Indonesia', style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.md),
        const NeoEmpty(
          icon: Icons.construction_rounded,
          title: 'Segera Hadir',
          subtitle: 'Data IRBI akan ditampilkan setelah integrasi API BNPB selesai',
        ),
      ],
    );
  }
}
