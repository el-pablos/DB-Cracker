// lib/screens/detail_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_factory.dart';
import '../api/multi_api_factory.dart';
import '../api/api_services_integration.dart';
import '../models/mahasiswa.dart';
import '../widgets/flexible_text.dart';
import '../widgets/hacker_loading_indicator.dart';
import '../widgets/console_text.dart';
import '../widgets/responsive_card.dart';
import '../widgets/terminal_window.dart';
import '../utils/constants.dart';
import '../utils/screen_utils.dart';

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

class _DetailScreenState extends State<DetailScreen> with SingleTickerProviderStateMixin {
  late Future<MahasiswaDetail> _mahasiswaFuture;
  bool _isDecrypting = true;
  List<String> _consoleMessages = [];
  final Random _random = Random();
  Timer? _decryptTimer;
  late AnimationController _animationController;
  
  // Tambahkan instance MultiApiFactory
  late MultiApiFactory _multiApiFactory;
  
  // Flag untuk menampilkan informasi eksternal
  bool _showExternalInfo = false;
  Map<String, dynamic> _externalData = {};
  
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
    
    // Mulai sequence dekripsi
    _simulateDecryption();
    
    // Coba dapatkan data tambahan
    _fetchExternalData();
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
    _addConsoleMessageWithDelay("KORELASI DATA DENGAN DATABASE EKSTERNAL...", 3800); // Pesan baru
    
    // Fetch data setelah simulasi
    _decryptTimer = Timer(const Duration(milliseconds: 4000), () {
      _fetchMahasiswaDetail();
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

  void _fetchMahasiswaDetail() {
    // Gunakan MultiApiFactory
    _mahasiswaFuture = _multiApiFactory.getMahasiswaDetailFromAllSources(widget.mahasiswaId);
    
    _mahasiswaFuture.then((_) {
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
  
  // Metode untuk mengambil data tambahan dari API eksternal
  Future<void> _fetchExternalData() async {
    try {
      // Delay untuk simulasi pencarian
      await Future.delayed(Duration(seconds: 2));
      
      // Coba cari di Wikipedia
      final apiServices = ApiServicesIntegration();
      final wikipediaData = await apiServices.searchWikipedia(widget.subjectName);
      
      if (wikipediaData.isNotEmpty) {
        setState(() {
          _externalData = wikipediaData;
          _showExternalInfo = true;
        });
      }
    } catch (e) {
      print('Error fetching external data: $e');
    }
  }

  @override
  void dispose() {
    _decryptTimer?.cancel();
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

  // Fungsi untuk mendeteksi jika layar berukuran kecil (mobile)
  bool isMobileScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtils for responsive design
    ScreenUtils.init(context);
    
    return Scaffold(
      backgroundColor: HackerColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 12.w, // Gunakan ekstensi responsive
                  height: 12.h, // Gunakan ekstensi responsive
                  margin: EdgeInsets.only(right: 8.w), // Gunakan ekstensi responsive
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _animationController.value > 0.5 
                        ? HackerColors.primary 
                        : HackerColors.accent,
                  ),
                );
              },
            ),
            Text(
              AppStrings.detailTitle,
              style: TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                color: HackerColors.primary,
                fontSize: 16.sp, // Gunakan ekstensi responsive
              ),
            ),
          ],
        ),
        backgroundColor: HackerColors.surface,
        iconTheme: IconThemeData(
          color: HackerColors.primary,
        ),
        actions: [
          // Toggle untuk menampilkan info eksternal
          IconButton(
            icon: Icon(
              _showExternalInfo ? Icons.visibility : Icons.visibility_off,
              color: HackerColors.primary,
              size: 20.sp, // Gunakan ekstensi responsive
            ),
            onPressed: () {
              setState(() {
                _showExternalInfo = !_showExternalInfo;
              });
            },
          ),
        ],
      ),
      body: Container(
        color: HackerColors.background,
        child: Column(
          children: [
            Container(
              color: HackerColors.surface.withOpacity(0.7),
              padding: EdgeInsets.all(8.w), // Gunakan ekstensi responsive
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8.w, // Gunakan ekstensi responsive
                    height: 8.h, // Gunakan ekstensi responsive
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _random.nextBool() 
                          ? HackerColors.primary 
                          : HackerColors.accent,
                    ),
                  ),
                  SizedBox(width: 8.w), // Gunakan ekstensi responsive
                  Text(
                    'RAHASIA - LEVEL AKSES 3 - SUBJEK: ${widget.subjectName}',
                    style: TextStyle(
                      color: HackerColors.highlight,
                      fontFamily: 'Courier',
                      fontSize: 12.sp, // Gunakan ekstensi responsive
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
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w), // Gunakan ekstensi responsive
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
                    )
                  : FutureBuilder<MahasiswaDetail>(
                      future: _mahasiswaFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: HackerLoadingIndicator());
                        } else if (snapshot.hasError) {
                          return TerminalWindow(
                            title: "ERROR",
                            child: Center(
                              child: Padding(
                                padding: ScreenUtils.responsivePadding(all: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: HackerColors.error,
                                      size: 48.iconSize,
                                    ),
                                    SizedBox(height: 16.h),
                                    FlexibleText(
                                      '${AppStrings.errorLoadingData} ${snapshot.error}',
                                      style: TextStyle(
                                        color: HackerColors.error,
                                        fontSize: 16.adaptiveFont,
                                        fontFamily: 'Courier',
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                    ),
                                    SizedBox(height: 24.h),
                                    ElevatedButton(
                                      onPressed: _simulateDecryption,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: HackerColors.surface,
                                        foregroundColor: HackerColors.primary,
                                        padding: ScreenUtils.responsivePadding(
                                          horizontal: 16, 
                                          vertical: 8
                                        ),
                                        side: BorderSide(color: HackerColors.primary),
                                      ),
                                      child: FlexibleText(
                                        AppStrings.retry,
                                        style: TextStyle(
                                          fontSize: 14.adaptiveFont,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData) {
                          return Center(
                            child: FlexibleText(
                              AppStrings.noDataAvailable,
                              style: TextStyle(
                                color: HackerColors.error,
                                fontFamily: 'Courier',
                                fontSize: 16.adaptiveFont,
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
                color: HackerColors.surface,
                padding: ScreenUtils.responsivePadding(
                  horizontal: 16, 
                  vertical: 8
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _random.nextBool() 
                                ? HackerColors.primary 
                                : HackerColors.accent,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        FlexibleText(
                          'KUNCI: ${_getRandomHexValue(8)}-${_getRandomHexValue(4)}-${_getRandomHexValue(4)}',
                          style: TextStyle(
                            color: HackerColors.text,
                            fontSize: 10.adaptiveFont,
                            fontFamily: 'Courier',
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                    FlexibleText(
                      'BY: TAMAENGS',
                      style: TextStyle(
                        color: HackerColors.text,
                        fontSize: 10.adaptiveFont,
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
      );
  }

  Widget _buildHackerDetailView(MahasiswaDetail mahasiswa) {
    final bool isMobile = ScreenUtils.isMobileScreen();
    
    return Padding(
      padding: ScreenUtils.responsivePadding(all: 12),
      child: Column(
        children: [
          Expanded(
            child: isMobile
                // Layout mobile: data pribadi di atas, data institusi di bawah
                ? Column(
                    children: [
                      Expanded(
                        child: _buildDataTerminal(
                          title: "DATA PRIBADI",
                          icon: Icons.person,
                          content: [
                            _buildDataRow("IDENTITAS", mahasiswa.nama),
                            _buildDataRow("ID SUBJEK", mahasiswa.nim),
                            _buildDataRow("JENIS KELAMIN", mahasiswa.jenisKelamin),
                            _buildDataRow("TAHUN MASUK", mahasiswa.tahunMasuk),
                            _buildDataRow("JENIS DAFTAR", mahasiswa.jenisDaftar),
                            _buildDataRow("STATUS", mahasiswa.statusSaatIni),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Expanded(
                        child: _buildDataTerminal(
                          title: "DATA INSTITUSI",
                          icon: Icons.school,
                          content: [
                            _buildDataRow("INSTITUSI", mahasiswa.namaPt),
                            _buildDataRow("KODE PT", mahasiswa.kodePt),
                            _buildDataRow("PROGRAM", mahasiswa.prodi),
                            _buildDataRow("KODE PRODI", mahasiswa.kodeProdi),
                            _buildDataRow("JENJANG", mahasiswa.jenjang),
                          ],
                        ),
                      ),
                    ],
                  )
                // Layout tablet/desktop: data pribadi di kiri, data institusi di kanan
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildDataTerminal(
                          title: "DATA PRIBADI",
                          icon: Icons.person,
                          content: [
                            _buildDataRow("IDENTITAS", mahasiswa.nama),
                            _buildDataRow("ID SUBJEK", mahasiswa.nim),
                            _buildDataRow("JENIS KELAMIN", mahasiswa.jenisKelamin),
                            _buildDataRow("TAHUN MASUK", mahasiswa.tahunMasuk),
                            _buildDataRow("JENIS DAFTAR", mahasiswa.jenisDaftar),
                            _buildDataRow("STATUS", mahasiswa.statusSaatIni),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        flex: 1,
                        child: _buildDataTerminal(
                          title: "DATA INSTITUSI",
                          icon: Icons.school,
                          content: [
                            _buildDataRow("INSTITUSI", mahasiswa.namaPt),
                            _buildDataRow("KODE PT", mahasiswa.kodePt),
                            _buildDataRow("PROGRAM", mahasiswa.prodi),
                            _buildDataRow("KODE PRODI", mahasiswa.kodeProdi),
                            _buildDataRow("JENJANG", mahasiswa.jenjang),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          SizedBox(height: 12.h),
          _buildSecurityTerminal(mahasiswa),
          
          // Tambahkan bagian informasi eksternal jika ada
          if (_showExternalInfo && _externalData.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _buildExternalDataTerminal(),
          ],
        ],
      ),
    );
  }

  Widget _buildDataTerminal({
    required String title,
    required IconData icon,
    required List<Widget> content,
  }) {
    return ResponsiveCard(
      color: HackerColors.surface,
      borderColor: HackerColors.accent,
      padding: ScreenUtils.responsivePadding(all: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: HackerColors.primary,
                size: 18.iconSize,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: FlexibleText(
                  title,
                  style: TextStyle(
                    color: HackerColors.primary,
                    fontFamily: 'Courier',
                    fontSize: 16.adaptiveFont,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          Divider(
            color: HackerColors.accent,
            height: 24.h,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: content,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Terminal untuk menampilkan data eksternal seperti Wikipedia
  Widget _buildExternalDataTerminal() {
    // Mengekstrak informasi dari Wikipedia
    final String title = _externalData['title'] ?? 'DATA EKSTERNAL';
    final String extract = _externalData['extract'] ?? 'Tidak ada data yang tersedia.';
    final String source = _externalData['source'] ?? 'SUMBER TIDAK DIKETAHUI';
    
    return ResponsiveCard(
      color: HackerColors.surface,
      borderColor: HackerColors.accent,
      padding: ScreenUtils.responsivePadding(all: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.language,
                color: HackerColors.primary,
                size: 18.iconSize,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: FlexibleText(
                  "DATA EKSTERNAL: $title",
                  style: TextStyle(
                    color: HackerColors.primary,
                    fontFamily: 'Courier',
                    fontSize: 16.adaptiveFont,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          Divider(
            color: HackerColors.accent,
            height: 24.h,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FlexibleText(
                    extract,
                    style: TextStyle(
                      color: HackerColors.text,
                      fontFamily: 'Courier',
                      fontSize: 12.adaptiveFont,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  FlexibleText(
                    "SUMBER: $source",
                    style: TextStyle(
                      color: HackerColors.accent,
                      fontFamily: 'Courier',
                      fontSize: 10.adaptiveFont,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTerminal(MahasiswaDetail mahasiswa) {
    // Adaptasi berdasarkan ukuran layar
    final bool isMobile = ScreenUtils.isMobileScreen();
    final double terminalHeight = isMobile ? 100.h : 120.h;
    
    return Container(
      height: terminalHeight,
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: HackerColors.accent),
      ),
      padding: ScreenUtils.responsivePadding(all: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: ScreenUtils.responsivePadding(
              vertical: 2, 
              horizontal: 8
            ),
            decoration: BoxDecoration(
              color: HackerColors.background,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FlexibleText(
              "ANALISIS KEAMANAN",
              style: TextStyle(
                color: HackerColors.warning,
                fontFamily: 'Courier',
                fontSize: 12.adaptiveFont,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return FlexibleText(
                  _generateRandomSecurityInfo(mahasiswa, index),
                  style: TextStyle(
                    color: _getSecurityColor(index),
                    fontFamily: 'Courier',
                    fontSize: 10.adaptiveFont,
                  ),
                  maxLines: 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _generateRandomSecurityInfo(MahasiswaDetail mahasiswa, int index) {
    final hexCode = _getRandomHexValue(16);
    
    switch (index) {
      case 0:
        return "LEVEL AKSES: ${_random.nextInt(3) + 2} | IP: 192.168.${_random.nextInt(255)}.${_random.nextInt(255)} | PORT: ${_random.nextInt(9000) + 1000}";
      case 1:
        return "INTEGRITAS DATA: ${_random.nextInt(30) + 70}% | ENKRIPSI: AES-256 | HASH: SHA3-${_random.nextInt(2) == 0 ? "256" : "512"}";
      case 2:
        return "SISTEM: MULTI-DB-SEC | NODE: ${_getRandomHexValue(4)}-${_getRandomHexValue(4)} | SESI: $hexCode"; // Updated
      case 3:
        int length = min(10, mahasiswa.id.length);
        String idPrefix = length > 0 ? mahasiswa.id.substring(0, length) : "UNKNOWN";
        return "UPDATE TERAKHIR: ${DateTime.now().toString().substring(0, 16)} | ID RECORD: $idPrefix...";
      case 4:
        return "STATUS: ${_random.nextBool() ? "AMAN" : "MONITOR"} | CHECKSUM: ${_getRandomHexValue(8)} | AUTH: ${_getRandomHexValue(6)}";
      default:
        return "";
    }
  }

  Color _getSecurityColor(int index) {
    switch (index) {
      case 0:
        return HackerColors.primary;
      case 1:
        return HackerColors.accent;
      case 2:
        return HackerColors.text;
      case 3:
        return HackerColors.warning;
      case 4:
        return HackerColors.primary;
      default:
        return HackerColors.text;
    }
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: ScreenUtils.responsivePadding(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlexibleText(
            label,
            style: TextStyle(
              color: HackerColors.text.withOpacity(0.7),
              fontFamily: 'Courier',
              fontSize: 10.adaptiveFont,
            ),
          ),
          Container(
            width: double.infinity,
            padding: ScreenUtils.responsivePadding(
              vertical: 6, 
              horizontal: 8
            ),
            decoration: BoxDecoration(
              color: HackerColors.background,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: HackerColors.accent.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: FlexibleText(
              value.isNotEmpty ? value : "-DISENSOR-",
              style: TextStyle(
                color: HackerColors.primary,
                fontFamily: 'Courier',
                fontSize: 14.adaptiveFont,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}