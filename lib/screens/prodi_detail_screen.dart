import 'package:flutter/material.dart';
import '../api/multi_api_factory.dart';
import '../models/prodi.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_gradients.dart';
import '../widgets/core/neo_card.dart';
import '../widgets/core/neo_badge.dart';
import '../widgets/data/neo_data_row.dart';
import '../widgets/data/neo_stat_card.dart';
import '../widgets/feedback/neo_error.dart';
import '../widgets/feedback/neo_skeleton.dart';

class ProdiDetailScreen extends StatefulWidget {
  final String prodiId;
  final String prodiName;

  const ProdiDetailScreen({
    super.key,
    required this.prodiId,
    required this.prodiName,
  });

  @override
  State<ProdiDetailScreen> createState() => _ProdiDetailScreenState();
}

class _ProdiDetailScreenState extends State<ProdiDetailScreen> {
  late final Future<ProdiDetail?> _prodiFuture;

  @override
  void initState() {
    super.initState();
    _prodiFuture = MultiApiFactory().getDetailProdi(widget.prodiId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Detail Program Studi',
          style: AppTypography.headlineMedium,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<ProdiDetail?>(
        future: _prodiFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeleton();
          }
          if (snapshot.hasError) {
            return NeoError(
              message: snapshot.error.toString(),
              onRetry: () => setState(() {}),
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(
              child: Text(
                'Data program studi tidak ditemukan',
                style: AppTypography.bodyMedium,
              ),
            );
          }
          return _buildContent(data);
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          NeoSkeleton.card(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: NeoSkeleton(height: 90, borderRadius: 12)),
              const SizedBox(width: 12),
              Expanded(child: NeoSkeleton(height: 90, borderRadius: 12)),
            ],
          ),
          const SizedBox(height: 16),
          NeoSkeleton.card(),
        ],
      ),
    );
  }

  Widget _buildContent(ProdiDetail prodi) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileHeader(prodi),
        const SizedBox(height: 16),
        _buildStatsRow(prodi),
        const SizedBox(height: 16),
        _buildInfoSection(prodi),
        const SizedBox(height: 16),
        _buildContactSection(prodi),
        if (prodi.visi.isNotEmpty || prodi.misi.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildVisiMisiSection(prodi),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProfileHeader(ProdiDetail prodi) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            prodi.namaProdi,
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            prodi.namaPt,
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (prodi.jenjangDidik.isNotEmpty)
                NeoBadge(
                  label: prodi.jenjangDidik,
                  variant: NeoBadgeVariant.info,
                  icon: Icons.layers_rounded,
                ),
              if (prodi.akreditasi.isNotEmpty)
                NeoBadge(
                  label: 'Akreditasi ${prodi.akreditasi}',
                  variant: _akreditasiVariant(prodi.akreditasi),
                  icon: Icons.verified_rounded,
                ),
              if (prodi.status.isNotEmpty)
                NeoBadge(
                  label: prodi.status,
                  variant: prodi.status.toLowerCase().contains('aktif')
                      ? NeoBadgeVariant.success
                      : NeoBadgeVariant.warning,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ProdiDetail prodi) {
    // Only show stats row if we have meaningful data
    final hasRataMasa = prodi.rataMasaStudi.isNotEmpty;
    if (!hasRataMasa && prodi.kelBidang.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        if (hasRataMasa)
          Expanded(
            child: NeoStatCard(
              label: 'Rata-rata Masa Studi',
              value: prodi.rataMasaStudi,
              icon: Icons.timer_rounded,
              color: AppColors.secondary,
            ),
          ),
        if (hasRataMasa && prodi.kelBidang.isNotEmpty)
          const SizedBox(width: 12),
        if (prodi.kelBidang.isNotEmpty)
          Expanded(
            child: NeoStatCard(
              label: 'Kelompok Bidang',
              value: prodi.kelBidang,
              icon: Icons.category_rounded,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection(ProdiDetail prodi) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Program Studi', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          NeoDataRow(label: 'Kode Prodi', value: prodi.kodeProdi, isCode: true, copyable: true),
          NeoDataRow(label: 'Jenjang', value: prodi.jenjangDidik),
          NeoDataRow(label: 'Status', value: prodi.status),
          NeoDataRow(label: 'Akreditasi', value: prodi.akreditasi),
          if (prodi.akreditasiInternasional.isNotEmpty)
            NeoDataRow(label: 'Akred. Intl', value: prodi.akreditasiInternasional),
          NeoDataRow(label: 'Tanggal Berdiri', value: prodi.tglBerdiri),
          NeoDataRow(label: 'SK Selenggara', value: prodi.skSelenggara, isCode: true),
          NeoDataRow(label: 'Perguruan Tinggi', value: prodi.namaPt),
          NeoDataRow(label: 'Kode PT', value: prodi.kodePt, isCode: true),
        ],
      ),
    );
  }

  Widget _buildContactSection(ProdiDetail prodi) {
    final hasContact = prodi.alamat.isNotEmpty ||
        prodi.noTel.isNotEmpty ||
        prodi.email.isNotEmpty ||
        prodi.website.isNotEmpty;

    if (!hasContact) return const SizedBox.shrink();

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kontak & Lokasi', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          if (prodi.alamat.isNotEmpty)
            NeoDataRow(label: 'Alamat', value: prodi.alamat, icon: Icons.location_on_rounded),
          if (prodi.kabKota.isNotEmpty)
            NeoDataRow(label: 'Kota', value: prodi.kabKota),
          if (prodi.provinsi.isNotEmpty)
            NeoDataRow(label: 'Provinsi', value: prodi.provinsi),
          if (prodi.noTel.isNotEmpty)
            NeoDataRow(label: 'Telepon', value: prodi.noTel, icon: Icons.phone_rounded),
          if (prodi.email.isNotEmpty)
            NeoDataRow(label: 'Email', value: prodi.email, icon: Icons.email_rounded, copyable: true),
          if (prodi.website.isNotEmpty)
            NeoDataRow(label: 'Website', value: prodi.website, icon: Icons.language_rounded, copyable: true),
        ],
      ),
    );
  }

  Widget _buildVisiMisiSection(ProdiDetail prodi) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Visi & Misi', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          if (prodi.visi.isNotEmpty) ...[
            Text('Visi', style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(prodi.visi, style: AppTypography.bodyMedium),
            const SizedBox(height: 12),
          ],
          if (prodi.misi.isNotEmpty) ...[
            Text('Misi', style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(prodi.misi, style: AppTypography.bodyMedium),
          ],
        ],
      ),
    );
  }

  NeoBadgeVariant _akreditasiVariant(String akreditasi) {
    final upper = akreditasi.toUpperCase().trim();
    if (upper == 'A' || upper == 'UNGGUL') return NeoBadgeVariant.success;
    if (upper == 'B' || upper == 'BAIK SEKALI') return NeoBadgeVariant.info;
    if (upper == 'C' || upper == 'BAIK') return NeoBadgeVariant.warning;
    return NeoBadgeVariant.neutral;
  }
}
