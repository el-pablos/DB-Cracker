import 'package:flutter/material.dart';
import '../api/multi_api_factory.dart';
import '../models/pt.dart';
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

class PtDetailScreen extends StatefulWidget {
  final String ptId;
  final String ptName;

  const PtDetailScreen({
    super.key,
    required this.ptId,
    required this.ptName,
  });

  @override
  State<PtDetailScreen> createState() => _PtDetailScreenState();
}

class _PtDetailScreenState extends State<PtDetailScreen> {
  late final Future<PerguruanTinggiDetail?> _ptFuture;

  @override
  void initState() {
    super.initState();
    _ptFuture = MultiApiFactory().getDetailPT(widget.ptId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Detail Perguruan Tinggi',
          style: AppTypography.headlineMedium,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<PerguruanTinggiDetail?>(
        future: _ptFuture,
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
                'Data perguruan tinggi tidak ditemukan',
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
              const SizedBox(width: 10),
              Expanded(child: NeoSkeleton(height: 90, borderRadius: 12)),
              const SizedBox(width: 10),
              Expanded(child: NeoSkeleton(height: 90, borderRadius: 12)),
            ],
          ),
          const SizedBox(height: 16),
          NeoSkeleton.card(),
        ],
      ),
    );
  }

  Widget _buildContent(PerguruanTinggiDetail pt) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileHeader(pt),
        const SizedBox(height: 16),
        _buildStatsGrid(pt),
        const SizedBox(height: 16),
        _buildInfoSection(pt),
        const SizedBox(height: 16),
        _buildContactSection(pt),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProfileHeader(PerguruanTinggiDetail pt) {
    final location = [pt.kabKotaPt, pt.provinsiPt]
        .where((s) => s.isNotEmpty)
        .join(', ');

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
              Icons.account_balance_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            pt.namaPt,
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (pt.nmSingkat.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              pt.nmSingkat,
              style: AppTypography.codeMedium.copyWith(color: AppColors.secondary),
            ),
          ],
          if (location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              location,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (pt.kelompok.isNotEmpty)
                NeoBadge(
                  label: pt.kelompok,
                  variant: NeoBadgeVariant.info,
                  icon: Icons.domain_rounded,
                ),
              if (pt.akreditasiPt.isNotEmpty)
                NeoBadge(
                  label: 'Akreditasi ${pt.akreditasiPt}',
                  variant: _akreditasiVariant(pt.akreditasiPt),
                  icon: Icons.verified_rounded,
                ),
              if (pt.statusPt.isNotEmpty)
                NeoBadge(
                  label: pt.statusPt,
                  variant: pt.statusPt.toLowerCase().contains('aktif')
                      ? NeoBadgeVariant.success
                      : NeoBadgeVariant.warning,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(PerguruanTinggiDetail pt) {
    final hasProdi = pt.jumlahProdi.isNotEmpty && pt.jumlahProdi != '0';
    final hasMhs = pt.jumlahMahasiswa.isNotEmpty && pt.jumlahMahasiswa != '0';
    final hasDosen = pt.jumlahDosen.isNotEmpty && pt.jumlahDosen != '0';

    if (!hasProdi && !hasMhs && !hasDosen) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            if (hasProdi)
              Expanded(
                child: NeoStatCard(
                  label: 'Program Studi',
                  value: pt.jumlahProdi,
                  icon: Icons.school_rounded,
                  color: AppColors.primary,
                ),
              ),
            if (hasProdi && hasMhs) const SizedBox(width: 10),
            if (hasMhs)
              Expanded(
                child: NeoStatCard(
                  label: 'Mahasiswa',
                  value: pt.jumlahMahasiswa,
                  icon: Icons.people_rounded,
                  color: AppColors.secondary,
                ),
              ),
            if ((hasProdi || hasMhs) && hasDosen) const SizedBox(width: 10),
            if (hasDosen)
              Expanded(
                child: NeoStatCard(
                  label: 'Dosen',
                  value: pt.jumlahDosen,
                  icon: Icons.person_rounded,
                  color: AppColors.success,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection(PerguruanTinggiDetail pt) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Umum', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          NeoDataRow(label: 'Kode PT', value: pt.kodePt, isCode: true, copyable: true),
          NeoDataRow(label: 'Kelompok', value: pt.kelompok),
          NeoDataRow(label: 'Pembina', value: pt.pembina),
          NeoDataRow(label: 'Akreditasi', value: pt.akreditasiPt),
          NeoDataRow(label: 'Status', value: pt.statusPt),
          NeoDataRow(label: 'Tanggal Berdiri', value: pt.tglBerdiriPt),
          NeoDataRow(label: 'SK Pendirian', value: pt.skPendirianSp, isCode: true),
          if (pt.rasio.isNotEmpty)
            NeoDataRow(label: 'Rasio Dosen/Mhs', value: pt.rasio),
          if (pt.rangeBiayaKuliah.isNotEmpty)
            NeoDataRow(label: 'Biaya Kuliah', value: pt.rangeBiayaKuliah),
          if (pt.graduationRate.isNotEmpty)
            NeoDataRow(label: 'Graduation Rate', value: pt.graduationRate),
        ],
      ),
    );
  }

  Widget _buildContactSection(PerguruanTinggiDetail pt) {
    final hasContact = pt.alamat.isNotEmpty ||
        pt.noTel.isNotEmpty ||
        pt.email.isNotEmpty ||
        pt.website.isNotEmpty;

    if (!hasContact) return const SizedBox.shrink();

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kontak & Lokasi', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          if (pt.alamat.isNotEmpty)
            NeoDataRow(label: 'Alamat', value: pt.alamat, icon: Icons.location_on_rounded),
          if (pt.kabKotaPt.isNotEmpty)
            NeoDataRow(label: 'Kota', value: pt.kabKotaPt),
          if (pt.provinsiPt.isNotEmpty)
            NeoDataRow(label: 'Provinsi', value: pt.provinsiPt),
          if (pt.kodePos.isNotEmpty)
            NeoDataRow(label: 'Kode Pos', value: pt.kodePos),
          if (pt.noTel.isNotEmpty)
            NeoDataRow(label: 'Telepon', value: pt.noTel, icon: Icons.phone_rounded),
          if (pt.noFax.isNotEmpty)
            NeoDataRow(label: 'Fax', value: pt.noFax),
          if (pt.email.isNotEmpty)
            NeoDataRow(label: 'Email', value: pt.email, icon: Icons.email_rounded, copyable: true),
          if (pt.website.isNotEmpty)
            NeoDataRow(label: 'Website', value: pt.website, icon: Icons.language_rounded, copyable: true),
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
