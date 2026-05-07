import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api/multi_api_factory.dart';
import '../models/mahasiswa.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import '../theme/app_gradients.dart';
import '../widgets/core/neo_card.dart';
import '../widgets/core/neo_badge.dart';
import '../widgets/data/neo_data_row.dart';
import '../widgets/navigation/neo_tab_bar.dart';
import '../widgets/feedback/neo_error.dart';
import '../widgets/feedback/neo_skeleton.dart';
import '../widgets/feedback/neo_empty.dart';

class DetailScreen extends StatefulWidget {
  final String mahasiswaId;
  final String subjectName;

  const DetailScreen({
    Key? key,
    required this.mahasiswaId,
    required this.subjectName,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<MahasiswaDetail> _mahasiswaFuture;
  late MultiApiFactory _multiApiFactory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _multiApiFactory = MultiApiFactory();
    _mahasiswaFuture = _multiApiFactory
        .getMahasiswaDetail(widget.mahasiswaId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.subjectName,
          style: AppTypography.headlineSmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<MahasiswaDetail>(
        future: _mahasiswaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton();
          }
          if (snapshot.hasError) {
            return NeoError(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _mahasiswaFuture = _multiApiFactory
                      .getMahasiswaDetail(widget.mahasiswaId);
                });
              },
            );
          }
          if (!snapshot.hasData) {
            return const NeoEmpty(
              icon: Icons.person_off_rounded,
              title: 'Data tidak ditemukan',
              subtitle: 'Mahasiswa dengan ID tersebut tidak tersedia.',
            );
          }
          return _buildContent(snapshot.data!);
        },
      ),
    ),
    );
  }

  // ─── Loading Skeleton ────────────────────────────────────────────────────────

  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          NeoSkeleton.card(),
          const SizedBox(height: AppSpacing.md),
          const NeoSkeleton(width: double.infinity, height: 42, borderRadius: 8),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Column(
              children: List.generate(
                6,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeoSkeleton.text(width: double.infinity),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Main Content ────────────────────────────────────────────────────────────

  Widget _buildContent(MahasiswaDetail detail) {
    return Column(
      children: [
        _buildProfileCard(detail),
        NeoTabBar(
          controller: _tabController,
          tabs: const ['Biodata', 'Akademik', 'Riwayat'],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBiodataTab(detail),
              _buildAkademikTab(detail),
              _buildRiwayatTab(detail),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Profile Card ────────────────────────────────────────────────────────────

  Widget _buildProfileCard(MahasiswaDetail detail) {
    final initials = detail.nama.isNotEmpty
        ? detail.nama.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTypography.headlineLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.nama,
                  style: AppTypography.headlineMedium.copyWith(
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  detail.nim,
                  style: AppTypography.codeMedium.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail.namaPt.isNotEmpty ? detail.namaPt : '-',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status badge
          _buildStatusBadge(detail.statusSaatIni),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final lower = status.toLowerCase();
    NeoBadgeVariant variant;
    if (lower.contains('aktif')) {
      variant = NeoBadgeVariant.success;
    } else if (lower.contains('lulus')) {
      variant = NeoBadgeVariant.info;
    } else if (lower.contains('cuti') || lower.contains('non')) {
      variant = NeoBadgeVariant.warning;
    } else if (lower.contains('drop') || lower.contains('keluar')) {
      variant = NeoBadgeVariant.error;
    } else {
      variant = NeoBadgeVariant.neutral;
    }

    return NeoBadge(
      label: status.isNotEmpty ? status : 'N/A',
      variant: variant,
    );
  }

  // ─── Biodata Tab ─────────────────────────────────────────────────────────────

  Widget _buildBiodataTab(MahasiswaDetail detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: NeoCard(
        variant: NeoCardVariant.flat,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data Pribadi', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            const Divider(color: AppColors.divider, height: 1),
            NeoDataRow(
              icon: Icons.badge_outlined,
              label: 'NIM',
              value: detail.nim,
              isCode: true,
              copyable: true,
            ),
            NeoDataRow(
              icon: Icons.person_outline_rounded,
              label: 'Nama',
              value: detail.nama,
            ),
            NeoDataRow(
              icon: Icons.wc_rounded,
              label: 'Jenis Kelamin',
              value: detail.jenisKelamin,
            ),
            NeoDataRow(
              icon: Icons.location_city_rounded,
              label: 'Tempat Lahir',
              value: detail.tempatLahir,
            ),
            NeoDataRow(
              icon: Icons.cake_outlined,
              label: 'Tanggal Lahir',
              value: detail.tanggalLahir,
            ),
            NeoDataRow(
              icon: Icons.auto_awesome_outlined,
              label: 'Agama',
              value: detail.agama,
            ),
            NeoDataRow(
              icon: Icons.home_outlined,
              label: 'Alamat',
              value: detail.alamat,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Akademik Tab ────────────────────────────────────────────────────────────

  Widget _buildAkademikTab(MahasiswaDetail detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          NeoCard(
            variant: NeoCardVariant.flat,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Informasi Akademik', style: AppTypography.labelLarge),
                const SizedBox(height: 8),
                const Divider(color: AppColors.divider, height: 1),
                NeoDataRow(
                  icon: Icons.school_outlined,
                  label: 'Perguruan Tinggi',
                  value: detail.namaPt,
                ),
                NeoDataRow(
                  icon: Icons.menu_book_rounded,
                  label: 'Program Studi',
                  value: detail.prodi,
                ),
                NeoDataRow(
                  icon: Icons.layers_outlined,
                  label: 'Jenjang',
                  value: detail.jenjang,
                ),
                NeoDataRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Tahun Masuk',
                  value: detail.tahunMasuk,
                ),
                NeoDataRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Status',
                  value: detail.statusSaatIni,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NeoCard(
            variant: NeoCardVariant.flat,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prestasi Akademik', style: AppTypography.labelLarge),
                const SizedBox(height: 8),
                const Divider(color: AppColors.divider, height: 1),
                NeoDataRow(
                  icon: Icons.trending_up_rounded,
                  label: 'IPK',
                  value: detail.ipk,
                  isCode: true,
                ),
                NeoDataRow(
                  icon: Icons.assignment_outlined,
                  label: 'Total SKS',
                  value: detail.totalSks,
                  isCode: true,
                ),
                NeoDataRow(
                  icon: Icons.description_outlined,
                  label: 'Judul Skripsi',
                  value: detail.judulSkripsi,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Riwayat Tab ─────────────────────────────────────────────────────────────

  Widget _buildRiwayatTab(MahasiswaDetail detail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Riwayat Pendidikan Sebelumnya
          NeoCard(
            variant: NeoCardVariant.flat,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Riwayat Pendidikan', style: AppTypography.labelLarge),
                const SizedBox(height: 8),
                const Divider(color: AppColors.divider, height: 1),
                NeoDataRow(
                  icon: Icons.school_outlined,
                  label: 'Jenjang Saat Ini',
                  value: detail.jenjang.isNotEmpty ? detail.jenjang : '-',
                ),
                NeoDataRow(
                  icon: Icons.login_rounded,
                  label: 'Jenis Pendaftaran',
                  value: detail.jenisDaftar.isNotEmpty ? detail.jenisDaftar : '-',
                ),
                NeoDataRow(
                  icon: Icons.route_rounded,
                  label: 'Jalur Masuk',
                  value: detail.jalurMasuk.isNotEmpty ? detail.jalurMasuk : '-',
                ),
                NeoDataRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'Tahun Masuk',
                  value: detail.tahunMasuk.isNotEmpty ? detail.tahunMasuk : '-',
                ),
                NeoDataRow(
                  icon: Icons.emoji_events_outlined,
                  label: 'Tahun Lulus',
                  value: detail.tahunLulus.isNotEmpty ? detail.tahunLulus : '-',
                ),
                NeoDataRow(
                  icon: Icons.verified_outlined,
                  label: 'Status Akhir',
                  value: detail.statusAkhir.isNotEmpty ? detail.statusAkhir : detail.statusSaatIni,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Riwayat Semester
          if (detail.riwayatSemester.isNotEmpty) ...[
            Text('Riwayat Semester', style: AppTypography.labelLarge),
            const SizedBox(height: 8),
            ...detail.riwayatSemester.map((semester) => _buildSemesterCard(semester)),
          ] else
            const NeoEmpty(
              icon: Icons.history_rounded,
              title: 'Belum ada riwayat semester',
              subtitle: 'Data riwayat semester belum tersedia dari PDDIKTI.',
            ),
        ],
      ),
    );
  }

  Widget _buildSemesterCard(MahasiswaRiwayatSemester semester) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeoCard(
        variant: NeoCardVariant.flat,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    semester.namaSemester.isNotEmpty
                        ? semester.namaSemester
                        : 'Semester',
                    style: AppTypography.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                NeoBadge(
                  label: semester.statusSemester.isNotEmpty
                      ? semester.statusSemester
                      : '-',
                  variant: semester.statusSemester.toLowerCase().contains('aktif')
                      ? NeoBadgeVariant.success
                      : NeoBadgeVariant.neutral,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSemesterStat('IPS', semester.ips),
                _buildSemesterStat('IPK', semester.ipk),
                _buildSemesterStat('SKS Ambil', semester.sksDiambil),
                _buildSemesterStat('SKS Lulus', semester.sksLulus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.isNotEmpty ? value : '-',
            style: AppTypography.codeMedium.copyWith(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall,
          ),
        ],
      ),
    );
  }
}
