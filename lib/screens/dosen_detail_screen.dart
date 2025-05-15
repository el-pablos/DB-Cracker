import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../api/multi_api_factory.dart';
import '../models/dosen.dart';
import '../widgets/hacker_loading_indicator.dart';
import '../widgets/console_text.dart';
import '../widgets/terminal_window.dart';
import '../utils/constants.dart';
import '../utils/screen_utils.dart';
import '../widgets/responsive_card.dart';
import '../widgets/flexible_text.dart';

/// Screen untuk menampilkan detail dosen
class DosenDetailScreen extends StatefulWidget {
  final String dosenId;
  final String dosenName;

  const DosenDetailScreen({
    Key? key,
    required this.dosenId,
    required this.dosenName,
  }) : super(key: key);

  @override
  _DosenDetailScreenState createState() => _DosenDetailScreenState();
}

class _DosenDetailScreenState extends State<DosenDetailScreen> with SingleTickerProviderStateMixin {
  late Future<DosenDetail> _dosenFuture;
  bool _isLoading = true;
  List<String> _consoleMessages = [];
  final Random _random = Random();
  Timer? _loadTimer;
  late AnimationController _animationController;
  
  // Tab yang aktif
  int _activeTabIndex = 0;
  
  // Tambahkan instance MultiApiFactory
  late MultiApiFactory _multiApiFactory;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.repeat(reverse: true);
    
    // Inisialisasi MultiApiFactory
    _multiApiFactory = MultiApiFactory();
    
    // Mulai sequence loading
    _simulateLoading();
  }

  void _simulateLoading() {
    setState(() {
      _consoleMessages = [];
      _isLoading = true;
    });

    _addConsoleMessageWithDelay("AKSES DATABASE AMAN...", 300);
    _addConsoleMessageWithDelay("MENCARI DATA DOSEN: ${widget.dosenName}", 800);
    _addConsoleMessageWithDelay("DEKRIPSI RIWAYAT AKADEMIK...", 1400);
    _addConsoleMessageWithDelay("SCRAPING DATA INSTITUSI...", 2000);
    _addConsoleMessageWithDelay("EKSTRAKSI RIWAYAT MENGAJAR...", 2600);
    _addConsoleMessageWithDelay("AKSES KARYA ILMIAH...", 3200);
    _addConsoleMessageWithDelay("KOMPILASI PROFIL DOSEN...", 3800);
    
    // Fetch data setelah simulasi
    _loadTimer = Timer(const Duration(milliseconds: 4200), () {
      _fetchDosenDetail();
    });
  }

  void _addConsoleMessageWithDelay(String message, int delay) {
    Timer(Duration(milliseconds: delay), () {
      if (mounted) {
        setState(() {
          _consoleMessages.add(message);
        });
      }
    });
  }

  void _fetchDosenDetail() {
    // Gunakan MultiApiFactory untuk mencari data dosen
    _dosenFuture = _multiApiFactory.getDosenDetailFromAllSources(widget.dosenId);
    
    _dosenFuture.then((_) {
      setState(() {
        _isLoading = false;
      });
      _addConsoleMessageWithDelay("EKSTRAKSI DATA SELESAI", 300);
      _addConsoleMessageWithDelay("AKSES DIBERIKAN", 600);
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      _addConsoleMessageWithDelay("ERROR: EKSTRAKSI DATA GAGAL", 300);
      _addConsoleMessageWithDelay("AKSES DITOLAK", 600);
    });
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    _animationController.dispose();
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
    // Pastikan ScreenUtils diinisialisasi
    if (ScreenUtils.screenWidth == 0) {
      ScreenUtils.init(context);
    }
    
    // Adaptasi berdasarkan ukuran layar
    final bool isMobile = ScreenUtils.isMobileScreen();
    
    return Scaffold(
      backgroundColor: HackerColors.background,
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
                        ? HackerColors.primary 
                        : HackerColors.accent,
                  ),
                );
              },
            ),
            const Text(
              "PROFIL DOSEN",
              style: TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                color: HackerColors.primary,
                fontSize: 16,
              ),
            ),
          ],
        ),
        backgroundColor: HackerColors.surface,
        iconTheme: const IconThemeData(
          color: HackerColors.primary,
        ),
      ),
      body: SafeArea(
        child: Container(
          color: HackerColors.background,
          child: Column(
            children: [
              Container(
                color: HackerColors.surface.withOpacity(0.7),
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _random.nextBool() 
                            ? HackerColors.primary 
                            : HackerColors.accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SUBJEK: ${widget.dosenName}',
                      style: const TextStyle(
                        color: HackerColors.highlight,
                        fontFamily: 'Courier',
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                  ? TerminalWindow(
                      title: "DEKRIPSI DATA",
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _consoleMessages.length,
                              itemBuilder: (context, index) {
                                bool isSuccess = index == _consoleMessages.length - 1 && 
                                            _consoleMessages[index].contains("SELESAI");
                                bool isError = index == _consoleMessages.length - 1 && 
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
                  : FutureBuilder<DosenDetail>(
                      future: _dosenFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
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
                                      color: HackerColors.error,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error: ${snapshot.error}',
                                      style: const TextStyle(
                                        color: HackerColors.error,
                                        fontSize: 16,
                                        fontFamily: 'Courier',
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: _simulateLoading,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: HackerColors.surface,
                                        foregroundColor: HackerColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16, 
                                          vertical: 8
                                        ),
                                        side: const BorderSide(color: HackerColors.primary),
                                      ),
                                      child: const Text(
                                        "COBA LAGI",
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
                              'Data Dosen tidak tersedia',
                              style: TextStyle(
                                color: HackerColors.error,
                                fontFamily: 'Courier',
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        final dosen = snapshot.data!;
                        return _buildDosenDetailView(dosen);
                      },
                    ),
              ),
              Container(
                color: HackerColors.surface,
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
                            color: _random.nextBool() 
                                ? HackerColors.primary 
                                : HackerColors.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'KUNCI: ${_getRandomHexValue(8)}-${_getRandomHexValue(4)}-${_getRandomHexValue(4)}',
                          style: const TextStyle(
                            color: HackerColors.text,
                            fontSize: 10,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'BY: TAMAENGS',
                      style: TextStyle(
                        color: HackerColors.text,
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

  Widget _buildDosenDetailView(DosenDetail dosen) {
    final bool isMobile = ScreenUtils.isMobileScreen();
    
    // Tabs untuk bagian-bagian data
    final List<String> tabs = [
      "PROFIL",
      "INSTITUSI",
      "AKADEMIK",
      "KARYA ILMIAH",
    ];
    
    return Column(
      children: [
        // Tabs header
        Container(
          height: 42,
          color: HackerColors.surface,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tabs.length,
            itemBuilder: (context, index) {
              final bool isActive = _activeTabIndex == index;
              
              return InkWell(
                onTap: () {
                  setState(() {
                    _activeTabIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isActive ? HackerColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: isActive ? HackerColors.primary : HackerColors.text,
                      fontFamily: 'Courier',
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Tab content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _buildTabContent(dosen, _activeTabIndex, isMobile),
          ),
        ),
      ],
    );
  }
  
  // Widget untuk membangun konten tab
  Widget _buildTabContent(DosenDetail dosen, int tabIndex, bool isMobile) {
    switch (tabIndex) {
      case 0: // PROFIL
        return _buildProfileTab(dosen, isMobile);
      case 1: // INSTITUSI
        return _buildInstitusiTab(dosen, isMobile);
      case 2: // AKADEMIK
        return _buildAkademikTab(dosen, isMobile);
      case 3: // KARYA ILMIAH
        return _buildKaryaIlmiahTab(dosen, isMobile);
      default:
        return const Center(
          child: Text(
            'Tab tidak tersedia',
            style: TextStyle(
              color: HackerColors.error,
              fontFamily: 'Courier',
              fontSize: 16,
            ),
          ),
        );
    }
  }
  
  // Widget untuk tab profil
  Widget _buildProfileTab(DosenDetail dosen, bool isMobile) {
    return isMobile
      ? Column(
          children: [
            Expanded(
              child: _buildDataCard(
                title: "DATA PRIBADI",
                icon: Icons.person,
                content: [
                  _buildDataRow("NAMA", dosen.namaDosen),
                  _buildDataRow("ID SDM", dosen.idSdm),
                  _buildDataRow("JENIS KELAMIN", dosen.jenisKelamin),
                  _buildDataRow("PENDIDIKAN", dosen.pendidikanTertinggi),
                  _buildDataRow("JABATAN", dosen.jabatanAkademik),
                  _buildDataRow("STATUS", dosen.statusAktivitas),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _buildDataCard(
                title: "INSTITUSI AKTIF",
                icon: Icons.school,
                content: [
                  _buildDataRow("PERGURUAN TINGGI", dosen.namaPt),
                  _buildDataRow("PROGRAM STUDI", dosen.namaProdi),
                  _buildDataRow("STATUS KERJA", dosen.statusIkatanKerja),
                ],
              ),
            ),
          ],
        )
      : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: _buildDataCard(
                title: "DATA PRIBADI",
                icon: Icons.person,
                content: [
                  _buildDataRow("NAMA", dosen.namaDosen),
                  _buildDataRow("ID SDM", dosen.idSdm),
                  _buildDataRow("JENIS KELAMIN", dosen.jenisKelamin),
                  _buildDataRow("PENDIDIKAN", dosen.pendidikanTertinggi),
                  _buildDataRow("JABATAN", dosen.jabatanAkademik),
                  _buildDataRow("STATUS", dosen.statusAktivitas),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _buildDataCard(
                title: "INSTITUSI AKTIF",
                icon: Icons.school,
                content: [
                  _buildDataRow("PERGURUAN TINGGI", dosen.namaPt),
                  _buildDataRow("PROGRAM STUDI", dosen.namaProdi),
                  _buildDataRow("STATUS KERJA", dosen.statusIkatanKerja),
                ],
              ),
            ),
          ],
        );
  }
  
  // Widget untuk tab institusi
  Widget _buildInstitusiTab(DosenDetail dosen, bool isMobile) {
    return isMobile
      ? Column(
          children: [
            Expanded(
              child: _buildDataCard(
                title: "DATA INSTITUSI",
                icon: Icons.domain,
                content: [
                  _buildDataRow("PERGURUAN TINGGI", dosen.homePt.isNotEmpty ? dosen.homePt : dosen.namaPt),
                  _buildDataRow("PROGRAM STUDI", dosen.homeProdi.isNotEmpty ? dosen.homeProdi : dosen.namaProdi),
                  _buildDataRow("RASIO HOMEBASE", dosen.rasioHomebase.isNotEmpty ? dosen.rasioHomebase : "1.0"),
                  _buildDataRow("IKATAN KERJA", dosen.statusIkatanKerja),
                  _buildDataRow("STATUS AKTIVITAS", dosen.statusAktivitas),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _buildAnalisisInstitusi(dosen),
            ),
          ],
        )
      : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: _buildDataCard(
                title: "DATA INSTITUSI",
                icon: Icons.domain,
                content: [
                  _buildDataRow("PERGURUAN TINGGI", dosen.homePt.isNotEmpty ? dosen.homePt : dosen.namaPt),
                  _buildDataRow("PROGRAM STUDI", dosen.homeProdi.isNotEmpty ? dosen.homeProdi : dosen.namaProdi),
                  _buildDataRow("RASIO HOMEBASE", dosen.rasioHomebase.isNotEmpty ? dosen.rasioHomebase : "1.0"),
                  _buildDataRow("IKATAN KERJA", dosen.statusIkatanKerja),
                  _buildDataRow("STATUS AKTIVITAS", dosen.statusAktivitas),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _buildAnalisisInstitusi(dosen),
            ),
          ],
        );
  }
  
  // Widget untuk tab akademik
  Widget _buildAkademikTab(DosenDetail dosen, bool isMobile) {
    // Tampilkan riwayat pendidikan dan riwayat mengajar
    return isMobile
      ? Column(
          children: [
            const SizedBox(height: 8),
            _buildSectionHeader("RIWAYAT PENDIDIKAN"),
            const SizedBox(height: 8),
            Expanded(
              flex: 1,
              child: _buildRiwayatStudi(dosen),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader("RIWAYAT MENGAJAR"),
            const SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: _buildRiwayatMengajar(dosen),
            ),
          ],
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildSectionHeader("RIWAYAT PENDIDIKAN"),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: _buildRiwayatStudi(dosen),
            ),
            const SizedBox(height: 16),
            _buildSectionHeader("RIWAYAT MENGAJAR"),
            const SizedBox(height: 8),
            Expanded(
              child: _buildRiwayatMengajar(dosen),
            ),
          ],
        );
  }
  
  // Widget untuk tab karya ilmiah
  Widget _buildKaryaIlmiahTab(DosenDetail dosen, bool isMobile) {
    // Tampilkan penelitian, pengabdian, karya dan paten
    return isMobile
      ? Column(
          children: [
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    Container(
                      color: HackerColors.surface,
                      child: const TabBar(
                        tabs: [
                          Tab(text: "PENELITIAN"),
                          Tab(text: "PENGABDIAN"),
                          Tab(text: "KARYA"),
                          Tab(text: "PATEN"),
                        ],
                        labelColor: HackerColors.primary,
                        unselectedLabelColor: HackerColors.text,
                        indicatorColor: HackerColors.primary,
                        labelStyle: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildPortofolioList(dosen.penelitian, "PENELITIAN"),
                          _buildPortofolioList(dosen.pengabdian, "PENGABDIAN"),
                          _buildPortofolioList(dosen.karya, "KARYA"),
                          _buildPortofolioList(dosen.paten, "PATEN"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      : Column(
          children: [
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    Container(
                      color: HackerColors.surface,
                      child: const TabBar(
                        tabs: [
                          Tab(text: "PENELITIAN"),
                          Tab(text: "PENGABDIAN"),
                          Tab(text: "KARYA"),
                          Tab(text: "PATEN"),
                        ],
                        labelColor: HackerColors.primary,
                        unselectedLabelColor: HackerColors.text,
                        indicatorColor: HackerColors.primary,
                        labelStyle: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildPortofolioList(dosen.penelitian, "PENELITIAN"),
                          _buildPortofolioList(dosen.pengabdian, "PENGABDIAN"),
                          _buildPortofolioList(dosen.karya, "KARYA"),
                          _buildPortofolioList(dosen.paten, "PATEN"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
  }
  
  // Widget untuk menampilkan card data
  Widget _buildDataCard({
    required String title,
    required IconData icon,
    required List<Widget> content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: HackerColors.accent, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: HackerColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: HackerColors.primary,
                    fontFamily: 'Courier',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(
            color: HackerColors.accent,
            height: 24,
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: content,
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget analisis institusi
  Widget _buildAnalisisInstitusi(DosenDetail dosen) {
    return Container(
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: HackerColors.accent, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.analytics,
                color: HackerColors.primary,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                "ANALISIS AKTIVITAS",
                style: TextStyle(
                  color: HackerColors.primary,
                  fontFamily: 'Courier',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(
            color: HackerColors.accent,
            height: 24,
          ),
          Expanded(
            child: ListView(
              children: [
                _buildMetricCard(
                  title: "RASIO HOMEBASE",
                  value: dosen.rasioHomebase.isNotEmpty ? dosen.rasioHomebase : "1.0",
                  valueColor: HackerColors.primary,
                  icon: Icons.analytics,
                  description: "Rasio keaktifan dosen di program studi homebase",
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  title: "PENELITIAN",
                  value: "${dosen.penelitian.length}",
                  valueColor: HackerColors.accent,
                  icon: Icons.science,
                  description: "Jumlah penelitian yang tercatat",
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  title: "PUBLIKASI",
                  value: "${dosen.karya.length + dosen.paten.length}",
                  valueColor: HackerColors.warning,
                  icon: Icons.article,
                  description: "Jumlah karya ilmiah dan paten",
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  title: "MATA KULIAH",
                  value: "${dosen.riwayatMengajar.length}",
                  valueColor: HackerColors.warning,
                  icon: Icons.school,
                  description: "Jumlah mata kuliah yang diajar",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget untuk kartu metrik
  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color valueColor,
    required IconData icon,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: HackerColors.background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: HackerColors.accent.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: valueColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: valueColor,
                  fontFamily: 'Courier',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontFamily: 'Courier',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: HackerColors.text.withOpacity(0.8),
              fontFamily: 'Courier',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget untuk baris data
  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: HackerColors.text.withOpacity(0.7),
              fontFamily: 'Courier',
              fontSize: 10,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: HackerColors

              void _clearFilter() {
    // Tampilkan overlay untuk simulasi proses
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const FilterOverlay(
        message: "MEMBERSIHKAN FILTER...",
      ),
    );
    
    // Delay untuk simulasi proses
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _selectedPt = null;
        _filteredResults = _searchResults;
        _filterController.clear();
      });
      
      // Tutup overlay dialog
      Navigator.of(context).pop();
      
      // Tampilkan konfirmasi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "FILTER DIHAPUS",
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 14,
            ),
          ),
          backgroundColor: HackerColors.surface,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtils for responsive design
    ScreenUtils.init(context);
    
    // Adaptasi berdasarkan ukuran layar
    final bool isMobile = ScreenUtils.isMobileScreen();
    
    return Scaffold(
      backgroundColor: HackerColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _animationController.value > 0.5 
                        ? HackerColors.primary 
                        : HackerColors.error,
                  ),
                );
              },
            ),
            const FlexibleText(
              "DATABASE SCANNER DOSEN",
              style: TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                color: HackerColors.primary,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        backgroundColor: HackerColors.surface,
        actions: [
          // Tampilkan jumlah hasil jika ada
          if (_searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: HackerColors.background,
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(color: HackerColors.primary),
                  ),
                  child: Text(
                    '${_filteredResults.length}/${_searchResults.length}',
                    style: const TextStyle(
                      color: HackerColors.primary,
                      fontFamily: 'Courier',
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: HackerColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: HackerColors.surface.withOpacity(0.7),
                padding: const EdgeInsets.all(8.0),
                child: const FlexibleText(
                  'AKSES DATABASE DOSEN',
                  style: TextStyle(
                    color: HackerColors.highlight,
                    fontFamily: 'Courier',
                    fontSize: 12.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: HackerSearchBar(
                  controller: _searchController,
                  hintText: "masukkan nama dosen...",
                  onSearch: _simulateHacking,
                ),
              ),
              
              // Tampilkan filter kampus jika ada hasil pencarian
              if (_searchResults.isNotEmpty && _ptList.isNotEmpty)
                _buildPtFilter(),
                
              Expanded(
                child: _isLoading
                  ? TerminalWindow(
                      title: "PENCARIAN SEDANG BERJALAN",
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _consoleMessages.length,
                              itemBuilder: (context, index) {
                                return ConsoleText(text: _consoleMessages[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage != null
                    ? TerminalWindow(
                        title: "PERINGATAN SISTEM",
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: HackerColors.error,
                                  size: 48.0,
                                ),
                                const SizedBox(height: 16.0),
                                FlexibleText(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: HackerColors.error,
                                    fontSize: 16.0,
                                    fontFamily: 'Courier',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24.0),
                                ElevatedButton(
                                  onPressed: _simulateHacking,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: HackerColors.surface,
                                    foregroundColor: HackerColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, 
                                      vertical: 8.0
                                    ),
                                    side: const BorderSide(color: HackerColors.primary),
                                  ),
                                  child: const FlexibleText(
                                    'COBA LAGI',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'Courier',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : _searchResults.isEmpty
                      ? TerminalWindow(
                          title: "MENUNGGU INPUT",
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_search,
                                color: HackerColors.accent.withOpacity(0.5),
                                size: 64.0,
                              ),
                              const SizedBox(height: 16.0),
                              const FlexibleText(
                                "MASUKKAN NAMA DOSEN UNTUK MENCARI",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: HackerColors.text,
                                  fontFamily: 'Courier',
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8.0),
                              const FlexibleText(
                                "SIAP UNTUK MEMULAI PENCARIAN",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: HackerColors.accent,
                                  fontFamily: 'Courier',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              // Console pesan
                              if (_consoleMessages.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    height: 120,
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: HackerColors.surface,
                                      borderRadius: BorderRadius.circular(4.0),
                                      border: Border.all(color: HackerColors.accent),
                                    ),
                                    child: ListView.builder(
                                      itemCount: _consoleMessages.length,
                                      itemBuilder: (context, index) {
                                        return ConsoleText(text: _consoleMessages[index]);
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : TerminalWindow(
                          title: "HASIL PENCARIAN",
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18.0,
                                      height: 18.0,
                                      decoration: BoxDecoration(
                                        color: HackerColors.background,
                                        borderRadius: BorderRadius.circular(9.0),
                                        border: Border.all(color: HackerColors.primary),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.person, 
                                          color: HackerColors.primary, 
                                          size: 12.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: FlexibleText(
                                        _selectedPt != null
                                            ? 'FILTER AKTIF: $_selectedPt (${_filteredResults.length})'
                                            : 'DITEMUKAN ${_searchResults.length} DOSEN',
                                        style: TextStyle(
                                          color: _selectedPt != null
                                              ? HackerColors.warning
                                              : HackerColors.primary,
                                          fontFamily: 'Courier',
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                    
                                    // Tombol reset filter
                                    if (_selectedPt != null)
                                      InkWell(
                                        onTap: _clearFilter,
                                        child: Container(
                                          padding: const EdgeInsets.all(4.0),
                                          decoration: BoxDecoration(
                                            color: HackerColors.background,
                                            borderRadius: BorderRadius.circular(4.0),
                                            border: Border.all(color: HackerColors.warning),
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: HackerColors.warning,
                                            size: 14.0,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              
                              // Tampilkan pesan jika hasil filter kosong
                              if (_filteredResults.isEmpty && _selectedPt != null)
                                Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.filter_alt_off,
                                          color: HackerColors.warning,
                                          size: 40.0,
                                        ),
                                        const SizedBox(height: 16.0),
                                        const Text(
                                          "TIDAK ADA HASIL UNTUK FILTER INI",
                                          style: TextStyle(
                                            color: HackerColors.warning,
                                            fontSize: 16.0,
                                            fontFamily: 'Courier',
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16.0),
                                        ElevatedButton(
                                          onPressed: _clearFilter,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: HackerColors.surface,
                                            foregroundColor: HackerColors.warning,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, 
                                              vertical: 8.0
                                            ),
                                            side: const BorderSide(color: HackerColors.warning),
                                          ),
                                          child: const Text(
                                            "HAPUS FILTER",
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontFamily: 'Courier',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Expanded(
                                  child: _buildDosenList(),
                                ),
                            ],
                          ),
                        ),
              ),
              Container(
                color: HackerColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, 
                  vertical: 8.0
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _random.nextBool() ? HackerColors.primary : HackerColors.accent,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        FlexibleText(
                          DateTime.now().toString().substring(0, 19),
                          style: const TextStyle(
                            color: HackerColors.text,
                            fontSize: 10.0,
                            fontFamily: 'Courier',
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                    const FlexibleText(
                      'BY: TAMAENGS',
                      style: TextStyle(
                        color: HackerColors.text,
                        fontSize: 10.0,
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
  
  // Widget untuk filter PT
  Widget _buildPtFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: HackerColors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.filter_list,
                color: HackerColors.accent,
                size: 14.0,
              ),
              SizedBox(width: 8.0),
              Text(
                "FILTER PERGURUAN TINGGI",
                style: TextStyle(
                  color: HackerColors.accent,
                  fontFamily: 'Courier',
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: HackerColors.background,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: HackerColors.accent.withOpacity(0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedPt,
                hint: const Text(
                  "PILIH PERGURUAN TINGGI",
                  style: TextStyle(
                    color: HackerColors.text,
                    fontFamily: 'Courier',
                    fontSize: 12.0,
                  ),
                ),
                dropdownColor: HackerColors.surface,
                style: const TextStyle(
                  color: HackerColors.primary,
                  fontFamily: 'Courier',
                  fontSize: 12.0,
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: HackerColors.accent,
                ),
                onChanged: (String? value) {
                  _filterResults(value);
                },
                items: [
                  // Item untuk semua PT
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      "SEMUA PERGURUAN TINGGI",
                      style: TextStyle(
                        color: HackerColors.text,
                        fontFamily: 'Courier',
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  
                  // Divider
                  const DropdownMenuItem<String>(
                    enabled: false,
                    child: Divider(color: HackerColors.accent),
                  ),
                  
                  // Daftar PT
                  ..._ptList.map<DropdownMenuItem<String>>((String pt) {
                    return DropdownMenuItem<String>(
                      value: pt,
                      child: Text(
                        pt,
                        style: const TextStyle(
                          color: HackerColors.primary,
                          fontFamily: 'Courier',
                          fontSize: 12.0,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget untuk menampilkan daftar dosen dengan efek hacker
  Widget _buildDosenList() {
    return ListView.builder(
      itemCount: _filteredResults.length,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      itemBuilder: (context, index) {
        final dosen = _filteredResults[index];
        
        // Tambahkan efek visual berdasarkan index
        final bool isEven = index % 2 == 0;
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: HackerColors.surface,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: isEven ? HackerColors.primary : HackerColors.accent,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: (isEven ? HackerColors.primary : HackerColors.accent).withOpacity(0.1),
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),

          Expanded(
                child: _isLoading
                  ? TerminalWindow(
                      title: "PENCARIAN SEDANG BERJALAN",
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _consoleMessages.length,
                              itemBuilder: (context, index) {
                                return ConsoleText(text: _consoleMessages[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage != null
                    ? TerminalWindow(
                        title: "PERINGATAN SISTEM",
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: HackerColors.error,
                                  size: 48.0,
                                ),
                                const SizedBox(height: 16.0),
                                FlexibleText(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: HackerColors.error,
                                    fontSize: 16.0,
                                    fontFamily: 'Courier',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24.0),
                                ElevatedButton(
                                  onPressed: _simulateHacking,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: HackerColors.surface,
                                    foregroundColor: HackerColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, 
                                      vertical: 8.0
                                    ),
                                    side: const BorderSide(color: HackerColors.primary),
                                  ),
                                  child: const FlexibleText(
                                    'COBA LAGI',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontFamily: 'Courier',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : _searchResults.isEmpty
                      ? TerminalWindow(
                          title: "MENUNGGU INPUT",
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_search,
                                color: HackerColors.accent.withOpacity(0.5),
                                size: 64.0,
                              ),
                              const SizedBox(height: 16.0),
                              const FlexibleText(
                                "MASUKKAN NAMA DOSEN UNTUK MENCARI",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: HackerColors.text,
                                  fontFamily: 'Courier',
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8.0),
                              const FlexibleText(
                                "SIAP UNTUK MEMULAI PENCARIAN",
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: HackerColors.accent,
                                  fontFamily: 'Courier',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              // Console pesan
                              if (_consoleMessages.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    height: 120,
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: HackerColors.surface,
                                      borderRadius: BorderRadius.circular(4.0),
                                      border: Border.all(color: HackerColors.accent),
                                    ),
                                    child: ListView.builder(
                                      itemCount: _consoleMessages.length,
                                      itemBuilder: (context, index) {
                                        return ConsoleText(text: _consoleMessages[index]);
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : TerminalWindow(
                          title: "HASIL PENCARIAN",
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 18.0,
                                      height: 18.0,
                                      decoration: BoxDecoration(
                                        color: HackerColors.background,
                                        borderRadius: BorderRadius.circular(9.0),
                                        border: Border.all(color: HackerColors.primary),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.person, 
                                          color: HackerColors.primary, 
                                          size: 12.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: FlexibleText(
                                        _selectedPt != null
                                            ? 'FILTER AKTIF: $_selectedPt (${_filteredResults.length})'
                                            : 'DITEMUKAN ${_searchResults.length} DOSEN',
                                        style: TextStyle(
                                          color: _selectedPt != null
                                              ? HackerColors.warning
                                              : HackerColors.primary,
                                          fontFamily: 'Courier',
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                    
                                    // Tombol reset filter
                                    if (_selectedPt != null)
                                      InkWell(
                                        onTap: _clearFilter,
                                        child: Container(
                                          padding: const EdgeInsets.all(4.0),
                                          decoration: BoxDecoration(
                                            color: HackerColors.background,
                                            borderRadius: BorderRadius.circular(4.0),
                                            border: Border.all(color: HackerColors.warning),
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: HackerColors.warning,
                                            size: 14.0,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              
                              // Tampilkan pesan jika hasil filter kosong
                              if (_filteredResults.isEmpty && _selectedPt != null)
                                Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.filter_alt_off,
                                          color: HackerColors.warning,
                                          size: 40.0,
                                        ),
                                        const SizedBox(height: 16.0),
                                        const Text(
                                          "TIDAK ADA HASIL UNTUK FILTER INI",
                                          style: TextStyle(
                                            color: HackerColors.warning,
                                            fontSize: 16.0,
                                            fontFamily: 'Courier',
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16.0),
                                        ElevatedButton(
                                          onPressed: _clearFilter,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: HackerColors.surface,
                                            foregroundColor: HackerColors.warning,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, 
                                              vertical: 8.0
                                            ),
                                            side: const BorderSide(color: HackerColors.warning),
                                          ),
                                          child: const Text(
                                            "HAPUS FILTER",
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontFamily: 'Courier',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Expanded(
                                  child: _buildDosenList(),
                                ),
                            ],
                          ),
                        ),
              ),
              Container(
                color: HackerColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, 
                  vertical: 8.0
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _random.nextBool() ? HackerColors.primary : HackerColors.accent,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        FlexibleText(
                          DateTime.now().toString().substring(0, 19),
                          style: const TextStyle(
                            color: HackerColors.text,
                            fontSize: 10.0,
                            fontFamily: 'Courier',
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                    const FlexibleText(
                      'BY: TAMAENGS',
                      style: TextStyle(
                        color: HackerColors.text,
                        fontSize: 10.0,
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
  
  // Widget untuk filter PT
  Widget _buildPtFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: HackerColors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.filter_list,
                color: HackerColors.accent,
                size: 14.0,
              ),
              SizedBox(width: 8.0),
              Text(
                "FILTER PERGURUAN TINGGI",
                style: TextStyle(
                  color: HackerColors.accent,
                  fontFamily: 'Courier',
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: HackerColors.background,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: HackerColors.accent.withOpacity(0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedPt,
                hint: const Text(
                  "PILIH PERGURUAN TINGGI",
                  style: TextStyle(
                    color: HackerColors.text,
                    fontFamily: 'Courier',
                    fontSize: 12.0,
                  ),
                ),
                dropdownColor: HackerColors.surface,
                style: const TextStyle(
                  color: HackerColors.primary,
                  fontFamily: 'Courier',
                  fontSize: 12.0,
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: HackerColors.accent,
                ),
                onChanged: (String? value) {
                  _filterResults(value);
                },
                items: [
                  // Item untuk semua PT
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      "SEMUA PERGURUAN TINGGI",
                      style: TextStyle(
                        color: HackerColors.text,
                        fontFamily: 'Courier',
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  
                  // Divider
                  const DropdownMenuItem<String>(
                    enabled: false,
                    child: Divider(color: HackerColors.accent),
                  ),
                  
                  // Daftar PT
                  ..._ptList.map<DropdownMenuItem<String>>((String pt) {
                    return DropdownMenuItem<String>(
                      value: pt,
                      child: Text(
                        pt,
                        style: const TextStyle(
                          color: HackerColors.primary,
                          fontFamily: 'Courier',
                          fontSize: 12.0,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget untuk menampilkan daftar dosen dengan efek hacker
  Widget _buildDosenList() {
    return ListView.builder(
      itemCount: _filteredResults.length,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      itemBuilder: (context, index) {
        final dosen = _filteredResults[index];
        
        // Tambahkan efek visual berdasarkan index
        final bool isEven = index % 2 == 0;
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: HackerColors.surface,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: isEven ? HackerColors.primary : HackerColors.accent,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: (isEven ? HackerColors.primary : HackerColors.accent).withOpacity(0.1),
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/dosen/detail/${dosen.id}',
                arguments: {
                  'dosenName': dosen.nama,
                },
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: HackerColors.background,
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(
                      color: isEven ? HackerColors.primary : HackerColors.accent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dosen.nama.isNotEmpty ? dosen.nama[0].toUpperCase() : 'D',
                      style: TextStyle(
                        color: isEven ? HackerColors.primary : HackerColors.accent,
                        fontFamily: 'Courier',
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dosen.nama,
                        style: TextStyle(
                          color: isEven ? HackerColors.primary : HackerColors.accent,
                          fontFamily: 'Courier',
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'NIDN: ${dosen.nidn}',
                        style: const TextStyle(
                          color: HackerColors.text,
                          fontFamily: 'Courier',
                          fontSize: 12.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.0),
                      Container(import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../api/multi_api_factory.dart';
import '../models/dosen.dart';
import '../models/pt.dart';
import '../widgets/dosen_navigation_button.dart';
import '../widgets/hacker_search_bar.dart';
import '../widgets/console_text.dart';
import '../widgets/terminal_window.dart';
import '../widgets/flexible_text.dart';
import '../widgets/filter_overlay.dart';
import '../utils/constants.dart';
import '../utils/screen_utils.dart';

/// Screen untuk melakukan pencarian dosen dengan fitur filter kampus
class DosenSearchScreen extends StatefulWidget {
  const DosenSearchScreen({Key? key}) : super(key: key);

  @override
  _DosenSearchScreenState createState() => _DosenSearchScreenState();
}

class _DosenSearchScreenState extends State<DosenSearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _filterController = TextEditingController();
  List<Dosen> _searchResults = [];
  List<Dosen> _filteredResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  List<String> _consoleMessages = [];
  final Random _random = Random();
  Timer? _consoleTimer;
  
  // Filter kampus
  List<String> _ptList = [];
  String? _selectedPt;
  
  // Tambahkan instance MultiApiFactory
  late MultiApiFactory _multiApiFactory;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animationController.repeat(reverse: true);
    
    // Inisialisasi MultiApiFactory
    _multiApiFactory = MultiApiFactory();
    
    // Tampilkan pesan console simulasi hack startup
    _simulateSystemStartup();
  }
  
  void _simulateSystemStartup() {
    setState(() {
      _consoleMessages = [];
    });

    _addConsoleMessageWithDelay("MEMULAI SISTEM PENCARIAN DOSEN...", 300);
    _addConsoleMessageWithDelay("MENGAKSES DATABASE PDDIKTI...", 800);
    _addConsoleMessageWithDelay("BYPASS KEAMANAN AKTIVASI...", 1500);
    _addConsoleMessageWithDelay("SISTEM SIAP - MASUKKAN PENCARIAN", 2300);
  }

  void _addConsoleMessageWithDelay(String message, int delay) {
    Timer(Duration(milliseconds: delay), () {
      if (mounted) {
        setState(() {
          _consoleMessages.add(message);
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterController.dispose();
    _animationController.dispose();
    _consoleTimer?.cancel();
    super.dispose();
  }

  void _simulateHacking() {
    setState(() {
      _consoleMessages = [];
      _isLoading = true;
      // Reset filter saat melakukan pencarian baru
      _selectedPt = null;
      _filterController.clear();
      _ptList = [];
      _filteredResults = [];
    });

    final String query = _searchController.text.trim();
    
    _addConsoleMessageWithDelay("MEMULAI PEMINDAIAN DATABASE DOSEN UNTUK: $query", 300);
    _addConsoleMessageWithDelay("MELEWATI LAPISAN KEAMANAN SISTEM...", 800);
    _addConsoleMessageWithDelay("MENYUNTIKKAN QUERY SQL...", 1200);
    _addConsoleMessageWithDelay("MENCOBA MEMECAHKAN ENKRIPSI...", 1800);
    _addConsoleMessageWithDelay("MENEMBUS FIREWALL...", 2400);
    _addConsoleMessageWithDelay("MENGAKSES DATABASE DOSEN...", 3000);
    
    _actuallyPerformSearch();
  }

  Future<void> _actuallyPerformSearch() async {
    final String query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = "ERROR: TARGET DOSEN TIDAK DITENTUKAN";
        _isLoading = false;
      });
      _addConsoleMessageWithDelay("ERROR: TARGET TIDAK DITENTUKAN", 500);
      return;
    }

    try {
      // Tambahan indikator loading
      _addConsoleMessageWithDelay("MENGAKSES SERVER DATABASE DOSEN...", 1000);
      _addConsoleMessageWithDelay("MENCOBA KONEKSI AMAN...", 2000);

      // Cari data dengan error handling
      List<Dosen> results = [];
      try {
        // Gunakan API MultiApiFactory untuk mencari Dosen
        results = await _multiApiFactory.searchAllDosen(query);
        _addConsoleMessageWithDelay("MENDAPATKAN DATA DOSEN...", 2500);
      } catch (e) {
        print('Error dalam pencarian: $e');
        String errorMsg = e.toString();
        
        if (errorMsg.contains('XMLHttpRequest')) {
          throw Exception('Gagal terhubung ke server. Periksa koneksi internet atau coba lagi nanti.');
        } else if (errorMsg.contains('Timeout')) {
          throw Exception('Koneksi timeout. Server sibuk, silakan coba lagi.');
        } else if (errorMsg.contains('403')) {
          throw Exception('Akses ditolak oleh server (403 Forbidden). Menggunakan data offline.');
        } else {
          throw Exception('Error: $e');
        }
      }
      
      // Delay untuk simulasi hacking
      await Future.delayed(const Duration(milliseconds: 3000));
      
      setState(() {
        _searchResults = results;
        _filteredResults = results; // Awalnya, hasil filter sama dengan hasil pencarian
        _isLoading = false;
        
        if (results.isEmpty) {
          _errorMessage = 'TIDAK DITEMUKAN HASIL UNTUK "$query"';
          _addConsoleMessageWithDelay("TIDAK ADA DATA YANG COCOK", 300);
          _addConsoleMessageWithDelay("AKSES DITOLAK", 600);
        } else {
          _errorMessage = null;
          _addConsoleMessageWithDelay("DATA DITEMUKAN: ${results.length}", 300);
          _addConsoleMessageWithDelay("MENDEKRIPSI DATA...", 600);
          _addConsoleMessageWithDelay("AKSES DIBERIKAN", 900);
          
          // Ekstrak daftar perguruan tinggi dari hasil
          _extractPTList(results);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
        // Bersihkan pesan error
        String errorMsg = e.toString().replaceAll("Exception: ", "");
        _errorMessage = errorMsg;
      });
      _addConsoleMessageWithDelay("KONEKSI TERPUTUS", 300);
      _addConsoleMessageWithDelay("PERINGATAN KEAMANAN: DISCONNECT...", 600);
    }
  }
  
  // Ekstrak daftar perguruan tinggi unik
  void _extractPTList(List<Dosen> results) {
    Set<String> uniquePtNames = {};
    
    for (var dosen in results) {
      if (dosen.namaPt.isNotEmpty) {
        uniquePtNames.add(dosen.namaPt);
      }
    }
    
    setState(() {
      _ptList = uniquePtNames.toList()..sort();
    });
  }
  
  // Filter hasil berdasarkan PT
  void _filterResults(String? ptName) {
    setState(() {
      _selectedPt = ptName;
    });
    
    // Simulasi proses filtering dengan menampilkan overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const FilterOverlay(
        message: "MEMFILTER DATA DOSEN...",
      ),
    );
    
    // Delay proses untuk efek visual
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        if (ptName == null) {
          _filteredResults = _searchResults;
        } else {
          _filteredResults = _searchResults
              .where((dosen) => dosen.namaPt == ptName)
              .toList();
        }
      });
      
      // Tutup overlay dialog
      Navigator.of(context).pop();
    });
  }
  
  void _clearFilter() {
    // Tampilkan overlay untuk simulasi proses
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const FilterOverlay(
        message: "MEMBERSIHKAN FILTER...",
      ),
    );
    
    // Delay untuk simulasi proses
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _selectedPt = null;
        _filteredResults = _searchResults;
        _filterController.clear();
      });
      
      // Tutup overlay dialog
      Navigator.of(context).pop();
      
      // Tampilkan konfirmasi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "FILTER DIHAPUS",
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 14,
            ),
          ),
          backgroundColor: HackerColors.surface,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtils for responsive design
    ScreenUtils.init(context);
    
    // Adaptasi berdasarkan ukuran layar
    final bool isMobile = ScreenUtils.isMobileScreen();
    
    return Scaffold(
      backgroundColor: HackerColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _animationController.value > 0.5 
                        ? HackerColors.primary 
                        : HackerColors.error,
                  ),
                );
              },
            ),
            const FlexibleText(
              "DATABASE SCANNER DOSEN",
              style: TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                color: HackerColors.primary,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        backgroundColor: HackerColors.surface,
        actions: [
          // Tampilkan jumlah hasil jika ada
          if (_searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: HackerColors.background,
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(color: HackerColors.primary),
                  ),
                  child: Text(
                    '${_filteredResults.length}/${_searchResults.length}',
                    style: const TextStyle(
                      color: HackerColors.primary,
                      fontFamily: 'Courier',
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: HackerColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: HackerColors.surface.withOpacity(0.7),
                padding: const EdgeInsets.all(8.0),
                child: const FlexibleText(
                  'AKSES DATABASE DOSEN',
                  style: TextStyle(
                    color: HackerColors.highlight,
                    fontFamily: 'Courier',
                    fontSize: 12.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: HackerSearchBar(
                  controller: _searchController,
                  hintText: "masukkan nama dosen...",
                  onSearch: _simulateHacking,
                ),
              ),
              
              // Tampilkan filter kampus jika ada hasil pencarian
              if (_searchResults.isNotEmpty && _ptList.isNotEmpty)
                _buildPtFilter(),