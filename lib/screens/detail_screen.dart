import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../api/multi_api_factory.dart';
// PERF-FIX: ApiServicesIntegration import removed — Wikipedia fetch disabled
import '../models/mahasiswa.dart';
import '../widgets/hacker_loading_indicator.dart';
import '../widgets/console_text.dart';
import '../widgets/terminal_window.dart';
import '../utils/constants.dart';
// unused import removed: screen_utils.dart

class DetailScreen extends StatefulWidget {
  final String mahasiswaId;
  final String subjectName;

  const DetailScreen({
    Key? key,
    required this.mahasiswaId,
    required this.subjectName,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Future<MahasiswaDetail> _mahasiswaFuture;
  bool _isDecrypting = true;
  List<String> _consoleMessages = [];
  final List<Timer> _activeTimers = [];
  final Random _random = Random();
  late final bool _statusDotIsGreen;
  Timer? _decryptTimer;
  late AnimationController _animationController;

  // Tab yang aktif
  int _activeTabIndex = 0;

  // Tambahkan instance MultiApiFactory
  late MultiApiFactory _multiApiFactory;

  // External data system removed — Wikipedia fetch was dead code

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _statusDotIsGreen = Random().nextBool();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.repeat(reverse: true);

    // Inisialisasi MultiApiFactory
    _multiApiFactory = MultiApiFactory();

    // Mulai sequence dekripsi
    _simulateDecryption();

    // PERF-FIX: Wikipedia fetch removed — never returns useful data for student names
    // and _buildExternalDataTerminal() was never called anyway (dead code)
  }

  void _simulateDecryption() {
    setState(() {
      _consoleMessages = [];
      _isDecrypting = true;
    });

    _addConsoleMessageWithDelay("AKSES DATABASE AMAN...", 300);
    _addConsoleMessageWithDelay("MENCARI SUBJEK: ${widget.subjectName}", 800);
    _addConsoleMessageWithDelay("DEKRIPSI DATA PRIBADI...", 1400);
    _addConsoleMessageWithDelay("MELEWATI ENKRIPSI...", 2000);
    _addConsoleMessageWithDelay("EKSTRAKSI CATATAN INSTITUSI...", 2600);
    _addConsoleMessageWithDelay("MEMBERSIHKAN DATA...", 3200);
    _addConsoleMessageWithDelay(
        "KORELASI DATA DENGAN DATABASE EKSTERNAL...", 3800); // Pesan baru

    // Fetch data setelah simulasi
    _decryptTimer = Timer(const Duration(milliseconds: 1000), () {
      _fetchMahasiswaDetail();
    });
  }

  void _addConsoleMessageWithDelay(String message, int delay) {
    final timer = Timer(Duration(milliseconds: delay), () {
      if (mounted) {
        setState(() {
          _consoleMessages.add(message);
        });
      }
    });
    _activeTimers.add(timer);
  }

  void _fetchMahasiswaDetail() {
    // Gunakan MultiApiFactory
    _mahasiswaFuture = _multiApiFactory.getMahasiswaDetail(widget.mahasiswaId);

    _mahasiswaFuture.then((_) {
      if (!mounted) return;
      setState(() {
        _isDecrypting = false;
      });
      _addConsoleMessageWithDelay("EKSTRAKSI DATA SELESAI", 300);
      _addConsoleMessageWithDelay("AKSES DIBERIKAN", 600);
    }).catchError((error) {
      setState(() {
        _isDecrypting = false;
      });
      _addConsoleMessageWithDelay("ERROR: EKSTRAKSI DATA GAGAL", 300);
      _addConsoleMessageWithDelay("AKSES DITOLAK", 600);
    });
  }

  // PERF-FIX: _fetchExternalData removed — Wikipedia search by student name
  // never returns useful data, and _buildExternalDataTerminal was dead code

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _animationController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _decryptTimer?.cancel();
    _animationController.dispose();
    for (final timer in _activeTimers) { timer.cancel(); }
    _activeTimers.clear();
    super.dispose();
  }

  String _getRandomHexValue(int length) {
    const chars = '0123456789ABCDEF';
    return List.generate(
      length,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CtOSColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _animationController.value > 0.5
                        ? CtOSColors.primary
                        : CtOSColors.secondary,
                  ),
                );
              },
            ),
            Flexible(
              child: Text(
                AppStrings.detailTitle,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  color: CtOSColors.primary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: CtOSColors.surface,
        iconTheme: const IconThemeData(
          color: CtOSColors.primary,
        ),
        // External data toggle removed — feature was dead code
      ),
      body: SafeArea(
        child: Container(
        color: CtOSColors.background,
        child: Column(
          children: [
            Container(
              color: CtOSColors.surface.withValues(alpha: 0.7),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _statusDotIsGreen
                          ? CtOSColors.primary
                          : CtOSColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'RAHASIA - LEVEL AKSES 3 - SUBJEK: ${widget.subjectName}',
                    style: const TextStyle(
                      color: CtOSColors.textAccent,
                      fontFamily: 'Courier',
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isDecrypting
                  ? TerminalWindow(
                      title: "DEKRIPSI DATA",
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _consoleMessages.length,
                              itemBuilder: (context, index) {
                                bool isSuccess = index ==
                                        _consoleMessages.length - 1 &&
                                    _consoleMessages[index].contains("SELESAI");
                                bool isError = index ==
                                        _consoleMessages.length - 1 &&
                                    _consoleMessages[index].contains("ERROR");

                                return ConsoleText(
                                  text: _consoleMessages[index],
                                  isSuccess: isSuccess,
                                  isError: isError,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : FutureBuilder<MahasiswaDetail>(
                      future: _mahasiswaFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: HackerLoadingIndicator());
                        } else if (snapshot.hasError) {
                          return TerminalWindow(
                            title: "ERROR",
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: CtOSColors.error,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '${AppStrings.errorLoadingData} ${snapshot.error}',
                                      style: const TextStyle(
                                        color: CtOSColors.error,
                                        fontSize: 16,
                                        fontFamily: 'Courier',
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: _simulateDecryption,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: CtOSColors.surface,
                                        foregroundColor: CtOSColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        side: const BorderSide(
                                            color: CtOSColors.primary),
                                      ),
                                      child: const Text(
                                        AppStrings.retry,
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData) {
                          return const Center(
                            child: Text(
                              AppStrings.noDataAvailable,
                              style: TextStyle(
                                color: CtOSColors.error,
                                fontFamily: 'Courier',
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        final mahasiswa = snapshot.data!;
                        return _buildHackerDetailView(mahasiswa);
                      },
                    ),
            ),
            Container(
              color: CtOSColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _statusDotIsGreen
                              ? CtOSColors.primary
                              : CtOSColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'KUNCI: ${_getRandomHexValue(8)}-${_getRandomHexValue(4)}-${_getRandomHexValue(4)}',
                        style: const TextStyle(
                          color: CtOSColors.textPrimary,
                          fontSize: 10,
                          fontFamily: 'Courier',
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                  const Text(
                    'BY: TAMAENGS',
                    style: TextStyle(
                      color: CtOSColors.textPrimary,
                      fontSize: 10,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHackerDetailView(MahasiswaDetail mahasiswa) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Profile Card
          _buildProfileCard(mahasiswa),
          const SizedBox(height: 16),

          // Tab Navigation
          _buildTabNavigation(),
          const SizedBox(height: 16),

          // Tab Content
          _buildTabContent(mahasiswa),
        ],
      ),
    );
  }

  Widget _buildProfileCard(MahasiswaDetail mahasiswa) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CtOSColors.surface,
        border: Border.all(color: CtOSColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CtOSColors.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar dan Nama
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: CtOSColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: CtOSColors.primary, width: 2),
                ),
                child: Icon(
                  Icons.school,
                  size: 40,
                  color: CtOSColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mahasiswa.nama,
                      style: const TextStyle(
                        color: CtOSColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (mahasiswa.nim.isNotEmpty)
                      Text(
                        'NIM: ${mahasiswa.nim}',
                        style: const TextStyle(
                          color: CtOSColors.secondary,
                          fontSize: 14,
                          fontFamily: 'Courier',
                        ),
                      ),
                    if (mahasiswa.statusSaatIni.isNotEmpty)
                      Text(
                        mahasiswa.statusSaatIni,
                        style: const TextStyle(
                          color: CtOSColors.textAccent,
                          fontSize: 14,
                          fontFamily: 'Courier',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status Indicators
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip('Status', mahasiswa.statusSaatIni),
              _buildStatusChip('Jenjang', mahasiswa.jenjang),
              if (mahasiswa.tahunMasuk.isNotEmpty)
                _buildStatusChip('Tahun Masuk', mahasiswa.tahunMasuk),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: CtOSColors.primary.withValues(alpha: 0.1),
        border: Border.all(color: CtOSColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: CtOSColors.primary,
          fontSize: 12,
          fontFamily: 'Courier',
        ),
      ),
    );
  }

  Widget _buildTabNavigation() {
    final tabs = [
      'PROFIL',
      'AKADEMIK',
      'TRANSKRIP',
      'KELULUSAN',
    ];

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: CtOSColors.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: CtOSColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isActive = _activeTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTabIndex = index),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isActive ? CtOSColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: isActive
                          ? CtOSColors.background
                          : CtOSColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(MahasiswaDetail mahasiswa) {
    switch (_activeTabIndex) {
      case 0:
        return _buildProfilTab(mahasiswa);
      case 1:
        return _buildAkademikTab(mahasiswa);
      case 2:
        return _buildTranskripTab(mahasiswa);
      case 3:
        return _buildKelulusanTab(mahasiswa);
      default:
        return _buildProfilTab(mahasiswa);
    }
  }

  Widget _buildProfilTab(MahasiswaDetail mahasiswa) {
    return Column(
      children: [
        _buildInfoCard('INFORMASI PERSONAL', [
          _buildInfoRow('Nama Lengkap', mahasiswa.nama),
          _buildInfoRow('NIM', mahasiswa.nim),
          _buildInfoRow('Jenis Kelamin', mahasiswa.jenisKelamin),
          _buildInfoRow('Tempat Lahir', mahasiswa.tempatLahir),
          _buildInfoRow('Tanggal Lahir', mahasiswa.tanggalLahir),
          _buildInfoRow('Agama', mahasiswa.agama),
          _buildInfoRow('Alamat', mahasiswa.alamat),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('STATUS AKADEMIK', [
          _buildInfoRow('Status Saat Ini', mahasiswa.statusSaatIni),
          _buildInfoRow('Tahun Masuk', mahasiswa.tahunMasuk),
          _buildInfoRow('Jenis Daftar', mahasiswa.jenisDaftar),
          _buildInfoRow('Semester Saat Ini', mahasiswa.semesterSaatIni),
          _buildInfoRow(
              'Semester Aktif Terakhir', mahasiswa.semesterAktifTerakhir),
          _buildInfoRow('Status Akhir', mahasiswa.statusAkhir),
        ]),
      ],
    );
  }

  Widget _buildAkademikTab(MahasiswaDetail mahasiswa) {
    return Column(
      children: [
        _buildInfoCard('PERGURUAN TINGGI', [
          _buildInfoRow('Nama PT', mahasiswa.namaPt),
          _buildInfoRow('Kode PT', mahasiswa.kodePt),
          _buildInfoRow('ID PT', mahasiswa.idPt),
          _buildInfoRow('Program Studi', mahasiswa.prodi),
          _buildInfoRow('Kode Prodi', mahasiswa.kodeProdi),
          _buildInfoRow('ID SMS', mahasiswa.idSms),
          _buildInfoRow('Jenjang', mahasiswa.jenjang),
          _buildInfoRow('Akreditasi Prodi', mahasiswa.akreditasiProdi),
        ]),
        const SizedBox(height: 16),
        if (mahasiswa.riwayatKelas.isNotEmpty) ...[
          _buildListCard(
              'RIWAYAT KELAS',
              mahasiswa.riwayatKelas
                  .map((kelas) => _buildRiwayatKelasItem(kelas))
                  .toList()),
          const SizedBox(height: 16),
        ],
        if (mahasiswa.riwayatKelas.isEmpty)
          _buildEmptyState('Data riwayat kelas tidak tersedia dari sumber API saat ini'),
      ],
    );
  }

  Widget _buildTranskripTab(MahasiswaDetail mahasiswa) {
    return Column(
      children: [
        if (mahasiswa.riwayatNilai.isNotEmpty) ...[
          _buildListCard(
              'TRANSKRIP NILAI',
              mahasiswa.riwayatNilai
                  .map((nilai) => _buildTranskripItem(nilai))
                  .toList()),
          const SizedBox(height: 16),
        ],
        if (mahasiswa.riwayatSemester.isNotEmpty) ...[
          _buildListCard(
              'IP PER SEMESTER',
              mahasiswa.riwayatSemester
                  .map((ip) => _buildIpSemesterItem(ip))
                  .toList()),
        ],
        if (mahasiswa.riwayatNilai.isEmpty && mahasiswa.riwayatSemester.isEmpty)
          _buildEmptyState('Data transkrip tidak tersedia dari sumber API saat ini'),
      ],
    );
  }

  Widget _buildKelulusanTab(MahasiswaDetail mahasiswa) {
    return Column(
      children: [
        _buildInfoCard('DATA KELULUSAN', [
          _buildInfoRow('Tanggal Lulus', mahasiswa.tanggalLulus),
          _buildInfoRow('Tahun Lulus', mahasiswa.tahunLulus),
          _buildInfoRow('Nomor Ijazah', mahasiswa.nomorIjazah),
          _buildInfoRow('IPK', mahasiswa.ipk),
          _buildInfoRow('Total SKS', mahasiswa.totalSks),
          _buildInfoRow('Predikat Kelulusan', mahasiswa.predikatKelulusan),
          _buildInfoRow('Judul Skripsi', mahasiswa.judulSkripsi),
        ]),
        const SizedBox(height: 16),
        if (mahasiswa.tanggalLulus.isEmpty)
          _buildEmptyState('Data kelulusan tidak tersedia dari sumber API saat ini'),
      ],
    );
  }

  // Helper Methods
  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CtOSColors.surface,
        border: Border.all(color: CtOSColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: CtOSColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CtOSColors.surface,
        border: Border.all(color: CtOSColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: CtOSColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: CtOSColors.secondary,
                fontSize: 14,
                fontFamily: 'Courier',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: CtOSColors.textPrimary,
                fontSize: 14,
                fontFamily: 'Courier',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatKelasItem(MahasiswaKelas kelas) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CtOSColors.background,
        border: Border.all(color: CtOSColors.secondary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kelas.namaMatkul,
            style: const TextStyle(
              color: CtOSColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kode: ${kelas.kodeMatkul}',
            style: const TextStyle(
              color: CtOSColors.secondary,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
          Text(
            'Dosen: ${kelas.namaDosen}',
            style: const TextStyle(
              color: CtOSColors.textPrimary,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
          Text(
            'Kelas: ${kelas.namaKelas}',
            style: const TextStyle(
              color: CtOSColors.textAccent,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
          Text(
            'Semester: ${kelas.namaSemester}',
            style: const TextStyle(
              color: CtOSColors.textAccent,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranskripItem(MahasiswaNilai nilai) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CtOSColors.background,
        border: Border.all(color: CtOSColors.secondary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  nilai.namaMatkul,
                  style: const TextStyle(
                    color: CtOSColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      _getNilaiColor(nilai.nilaiHuruf).withValues(alpha: 0.2),
                  border: Border.all(color: _getNilaiColor(nilai.nilaiHuruf)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  nilai.nilaiHuruf,
                  style: TextStyle(
                    color: _getNilaiColor(nilai.nilaiHuruf),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Kode: ${nilai.kodeMatkul}',
            style: const TextStyle(
              color: CtOSColors.secondary,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
          Row(
            children: [
              Text(
                'SKS: ${nilai.sks}',
                style: const TextStyle(
                  color: CtOSColors.textPrimary,
                  fontSize: 12,
                  fontFamily: 'Courier',
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Nilai: ${nilai.nilaiAngka}',
                style: const TextStyle(
                  color: CtOSColors.textAccent,
                  fontSize: 12,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
          Text(
            'Semester: ${nilai.namaSemester}',
            style: const TextStyle(
              color: CtOSColors.textAccent,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIpSemesterItem(MahasiswaRiwayatSemester semester) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CtOSColors.background,
        border: Border.all(color: CtOSColors.secondary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            semester.namaSemester,
            style: const TextStyle(
              color: CtOSColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('IPS', semester.ips),
              ),
              Expanded(
                child: _buildStatItem('IPK', semester.ipk),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('SKS Diambil', semester.sksDiambil),
              ),
              Expanded(
                child: _buildStatItem('SKS Lulus', semester.sksLulus),
              ),
            ],
          ),
          Text(
            'Status: ${semester.statusSemester}',
            style: const TextStyle(
              color: CtOSColors.textAccent,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  // U2-FIX: _buildSertifikatItem removed — dead code, never called

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: CtOSColors.surface,
        border: Border.all(color: CtOSColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CtOSColors.secondary,
              fontSize: 10,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              color: CtOSColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: CtOSColors.surface,
        border: Border.all(color: CtOSColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: CtOSColors.secondary,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: CtOSColors.secondary,
              fontSize: 14,
              fontFamily: 'Courier',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getNilaiColor(String nilaiHuruf) {
    switch (nilaiHuruf.toUpperCase()) {
      case 'A':
        return CtOSColors.primary;
      case 'B':
        return CtOSColors.textAccent;
      case 'C':
        return CtOSColors.secondary;
      case 'D':
        return CtOSColors.error;
      case 'E':
      case 'F':
        return CtOSColors.error;
      default:
        return CtOSColors.textPrimary;
    }
  }

  // U2-FIX: Removed 265 lines of dead code:
  // - _buildDataTerminal (never called — replaced by _buildInfoCard)
  // - _buildExternalDataTerminal (never called — Wikipedia fetch disabled)
  // - _buildSecurityTerminal (never called)
  // - _generateRandomSecurityInfo (only used by _buildSecurityTerminal)
  // - _getSecurityColor (only used by _buildSecurityTerminal)
  // - _buildDataRow (never called — replaced by _buildInfoRow)
}
