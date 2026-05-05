import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/multi_api_factory.dart';
import '../api/enrichment/external_links.dart';
import '../models/dosen.dart';
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

class DosenDetailScreen extends StatefulWidget {
  final String dosenId;
  final String dosenName;

  const DosenDetailScreen({
    super.key,
    required this.dosenId,
    required this.dosenName,
  });

  @override
  State<DosenDetailScreen> createState() => _DosenDetailScreenState();
}

class _DosenDetailScreenState extends State<DosenDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final Future<DosenDetail> _dosenFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _dosenFuture = MultiApiFactory().getDosenDetailFromAllSources(widget.dosenId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(Uri url) async {
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka tautan')),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Detail Dosen',
          style: AppTypography.headlineMedium,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<DosenDetail>(
        future: _dosenFuture,
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
          if (!snapshot.hasData) {
            return const NeoEmpty(title: 'Data dosen tidak ditemukan');
          }
          return _buildContent(snapshot.data!);
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
          NeoSkeleton.card(),
          const SizedBox(height: 12),
          NeoSkeleton.text(width: 200),
          const SizedBox(height: 8),
          NeoSkeleton.text(),
        ],
      ),
    );
  }

  Widget _buildContent(DosenDetail dosen) {
    return Column(
      children: [
        _buildProfileHeader(dosen),
        NeoTabBar(
          controller: _tabController,
          tabs: const ['Profil', 'Mengajar', 'Penelitian', 'Riwayat'],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProfilTab(dosen),
              _buildMengajarTab(dosen),
              _buildPenelitianTab(dosen),
              _buildRiwayatTab(dosen),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(DosenDetail dosen) {
    final fullName = dosen.namaDosen;
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
    final gelar = [dosen.gelarDepan, dosen.gelarBelakang]
        .where((g) => g.isNotEmpty)
        .join(' ');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Center(
              child: Text(
                initial,
                style: AppTypography.displayMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            fullName,
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (gelar.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              gelar,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 6),
          Text(
            dosen.nidn.isNotEmpty ? 'NIDN: ${dosen.nidn}' : 'NIDK: ${dosen.nidk}',
            style: AppTypography.codeMedium.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 10),
          Text(
            dosen.namaPt,
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (dosen.jabatanAkademik.isNotEmpty)
                NeoBadge(
                  label: dosen.jabatanAkademik,
                  variant: NeoBadgeVariant.info,
                  icon: Icons.school_rounded,
                ),
              NeoBadge(
                label: dosen.statusAktivitas.isNotEmpty
                    ? dosen.statusAktivitas
                    : 'Tidak Diketahui',
                variant: dosen.statusAktivitas.toLowerCase().contains('aktif')
                    ? NeoBadgeVariant.success
                    : NeoBadgeVariant.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfilTab(DosenDetail dosen) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informasi Pribadi', style: AppTypography.headlineSmall),
              const SizedBox(height: 8),
              NeoDataRow(label: 'NIDN', value: dosen.nidn, isCode: true, copyable: true),
              NeoDataRow(label: 'NIDK', value: dosen.nidk, isCode: true, copyable: true),
              NeoDataRow(label: 'Nama Lengkap', value: dosen.namaDosen),
              NeoDataRow(label: 'Jenis Kelamin', value: dosen.jenisKelamin),
              NeoDataRow(label: 'Tempat Lahir', value: dosen.tempatLahir),
              NeoDataRow(label: 'Tanggal Lahir', value: dosen.tanggalLahir),
              NeoDataRow(label: 'Agama', value: dosen.agama),
            ],
          ),
        ),
        const SizedBox(height: 12),
        NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status Kepegawaian', style: AppTypography.headlineSmall),
              const SizedBox(height: 8),
              NeoDataRow(label: 'Ikatan Kerja', value: dosen.statusIkatanKerja),
              NeoDataRow(label: 'Status Aktivitas', value: dosen.statusAktivitas),
              NeoDataRow(label: 'Jabatan Akademik', value: dosen.jabatanAkademik),
              NeoDataRow(label: 'Pendidikan', value: dosen.pendidikanTertinggi),
              NeoDataRow(label: 'Bidang Ilmu', value: dosen.bidangIlmu),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (dosen.statusSertifikasi.isNotEmpty)
          NeoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sertifikasi', style: AppTypography.headlineSmall),
                const SizedBox(height: 8),
                NeoDataRow(label: 'Status', value: dosen.statusSertifikasi),
                NeoDataRow(label: 'Tahun', value: dosen.tahunSertifikasi),
                NeoDataRow(label: 'No. Sertifikat', value: dosen.nomorSertifikat, isCode: true),
                NeoDataRow(label: 'Bidang', value: dosen.bidangSertifikasi),
              ],
            ),
          ),
        const SizedBox(height: 12),
        _buildExternalLinks(dosen),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMengajarTab(DosenDetail dosen) {
    final items = dosen.riwayatMengajar;
    if (items.isEmpty) {
      return const NeoEmpty(
        icon: Icons.menu_book_rounded,
        title: 'Belum Ada Data Mengajar',
        subtitle: 'Riwayat mengajar belum tersedia',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.namaMatkul,
                style: AppTypography.headlineSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  if (item.namaSemester.isNotEmpty)
                    _infoChip(Icons.calendar_today_rounded, item.namaSemester),
                  if (item.kodeMatkul.isNotEmpty)
                    _infoChip(Icons.code_rounded, item.kodeMatkul),
                ],
              ),
              if (item.namaKelas.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Kelas: ${item.namaKelas}',
                  style: AppTypography.bodySmall,
                ),
              ],
              if (item.namaPt.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.namaPt,
                  style: AppTypography.bodySmall,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPenelitianTab(DosenDetail dosen) {
    final items = dosen.penelitian;
    if (items.isEmpty) {
      return const NeoEmpty(
        icon: Icons.science_rounded,
        title: 'Belum Ada Data Penelitian',
        subtitle: 'Data penelitian belum tersedia',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.judulKegiatan,
                style: AppTypography.headlineSmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (item.tahunKegiatan.isNotEmpty)
                _infoChip(Icons.calendar_today_rounded, item.tahunKegiatan),
              if (item.detailKegiatan.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.detailKegiatan,
                  style: AppTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiwayatTab(DosenDetail dosen) {
    final items = dosen.riwayatStudi;
    if (items.isEmpty) {
      return const NeoEmpty(
        icon: Icons.history_edu_rounded,
        title: 'Belum Ada Riwayat Pendidikan',
        subtitle: 'Data riwayat pendidikan belum tersedia',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return NeoCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    item.jenjang,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.perguruan,
                      style: AppTypography.headlineSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.bidangStudi.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(item.bidangStudi, style: AppTypography.bodySmall),
                    ],
                    if (item.tahunLulus.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Lulus: ${item.tahunLulus}',
                        style: AppTypography.codeSmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExternalLinks(DosenDetail dosen) {
    final links = getDosenEnrichmentLinks(
      dosenName: dosen.namaDosen,
      institutionName: dosen.namaPt,
    );

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tautan Eksternal', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: links.map((link) {
              return OutlinedButton.icon(
                onPressed: () => _launchUrl(link.url),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(link.title, style: const TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(text, style: AppTypography.codeSmall),
      ],
    );
  }
}
