// lib/screens/pt_detail_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_factory.dart';
import '../api/multi_api_factory.dart';
import '../models/pt.dart';
import '../widgets/hacker_loading_indicator.dart';
import '../widgets/console_text.dart';
import '../widgets/terminal_window.dart';
import '../widgets/flexible_text.dart';
import '../widgets/responsive_card.dart';
import '../utils/constants.dart';
import '../utils/screen_utils.dart';

/// Screen untuk menampilkan detail perguruan tinggi
class PTDetailScreen extends StatefulWidget {
  final String ptId;
  final String ptName;

  const PTDetailScreen({
    Key? key,
    required this.ptId,
    required this.ptName,
  }) : super(key: key);

  @override
  _PTDetailScreenState createState() => _PTDetailScreenState();
}

class _PTDetailScreenState extends State<PTDetailScreen> with SingleTickerProviderStateMixin {
  late Future<PerguruanTinggiDetail?> _ptFuture;
  bool _isLoading = true;
  List<String> _consoleMessages = [];
  final Random _random = Random();
  Timer? _loadTimer;
  late AnimationController _animationController;
  
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
    _addConsoleMessageWithDelay("MENCARI INSTITUSI: ${widget.ptName}", 800);
    _addConsoleMessageWithDelay("MENDAPATKAN DATA INSTITUSI...", 1400);
    _addConsoleMessageWithDelay("EKSTRAKSI INFO AKREDITASI...", 2000);
    _addConsoleMessageWithDelay("MEMBUAT PETA LOKASI...", 2600);
    
    // Fetch data setelah simulasi
    _loadTimer = Timer(const Duration(milliseconds: 3000), () {
      _fetchPTDetail();
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

  void _fetchPTDetail() {
    // Gunakan MultiApiFactory untuk mendapatkan detail PT
    _ptFuture = _multiApiFactory.getDetailPT(widget.ptId);
    
    _ptFuture.then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
            FlexibleText(
              "PROFIL INSTITUSI",
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
                    Expanded(
                      child: FlexibleText(
                        'INFO SISTEM: ${widget.ptName}',
                        style: const TextStyle(
                          color: HackerColors.highlight,
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                  ? TerminalWindow(
                      title: "DATA LOADING",
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _consoleMessages.length,
                        itemBuilder: (context, index) {
                          return ConsoleText(text: _consoleMessages[index]);
                        },
                      ),
                    )
                  : FutureBuilder<PerguruanTinggiDetail?>(
                      future: _ptFuture,
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
                                    FlexibleText(
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
                                      child: const FlexibleText(
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
                          return Center(
                            child: const FlexibleText(
                              'Data PT tidak tersedia',
                              style: TextStyle(
                                color: HackerColors.error,
                                fontFamily: 'Courier',
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        final pt = snapshot.data!;
                        return _buildPTDetailView(pt);
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
                        FlexibleText(
                          'KODE: ${_getRandomHexValue(8)}-${_getRandomHexValue(4)}',
                          style: const TextStyle(
                            color: HackerColors.text,
                            fontSize: 10,
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

  Widget _buildPTDetailView(PerguruanTinggiDetail pt) {
    final bool isMobile = ScreenUtils.isMobileScreen();
    
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: isMobile
                // Layout mobile: info umum di atas, info detail di bawah
                ? Column(
                    children: [
                      Expanded(
                        child: _buildInfoSection(
                          title: "INFO UMUM",
                          icon: Icons.info,
                          content: [
                            _buildDataRow("NAMA", pt.namaPt),
                            _buildDataRow("KODE", pt.kodePt),
                            _buildDataRow("SINGKATAN", pt.nmSingkat),
                            _buildDataRow("STATUS", pt.statusPt),
                            _buildDataRow("AKREDITASI", pt.akreditasiPt),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _buildInfoSection(
                          title: "DETAIL",
                          icon: Icons.school,
                          content: [
                            _buildDataRow("ALAMAT", pt.alamat),
                            _buildDataRow("KOTA", pt.kabKotaPt),
                            _buildDataRow("PROVINSI", pt.provinsiPt),
                            _buildDataRow("KONTAK", pt.noTel),
                            _buildDataRow("WEBSITE", pt.website),
                            _buildDataRow("EMAIL", pt.email),
                          ],
                        ),
                      ),
                    ],
                  )
                // Layout tablet/desktop: info umum di kiri, info detail di kanan
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildInfoSection(
                          title: "INFO UMUM",
                          icon: Icons.info,
                          content: [
                            _buildDataRow("NAMA", pt.namaPt),
                            _buildDataRow("KODE", pt.kodePt),
                            _buildDataRow("SINGKATAN", pt.nmSingkat),
                            _buildDataRow("STATUS", pt.statusPt),
                            _buildDataRow("AKREDITASI", pt.akreditasiPt),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: _buildInfoSection(
                          title: "DETAIL",
                          icon: Icons.school,
                          content: [
                            _buildDataRow("ALAMAT", pt.alamat),
                            _buildDataRow("KOTA", pt.kabKotaPt),
                            _buildDataRow("PROVINSI", pt.provinsiPt),
                            _buildDataRow("KONTAK", pt.noTel),
                            _buildDataRow("WEBSITE", pt.website),
                            _buildDataRow("EMAIL", pt.email),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          _buildSecuritySection(pt),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> content,
  }) {
    return ResponsiveCard(
      color: HackerColors.surface,
      borderColor: HackerColors.accent,
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
                child: FlexibleText(
                  title,
                  style: const TextStyle(
                    color: HackerColors.primary,
                    fontFamily: 'Courier',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const Divider(
            color: HackerColors.accent,
            height: 24,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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

  Widget _buildSecuritySection(PerguruanTinggiDetail pt) {
    // Adaptasi berdasarkan ukuran layar
    final bool isMobile = ScreenUtils.isMobileScreen();
    final double terminalHeight = isMobile ? 100 : 120;
    
    return Container(
      height: terminalHeight,
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: HackerColors.accent),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: BoxDecoration(
              color: HackerColors.background,
              borderRadius: BorderRadius.circular(2),
            ),
            child: const FlexibleText(
              "DATA INSTITUSI",
              style: TextStyle(
                color: HackerColors.warning,
                fontFamily: 'Courier',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return FlexibleText(
                  _generateRandomPTInfo(pt, index),
                  style: TextStyle(
                    color: _getInfoColor(index),
                    fontFamily: 'Courier',
                    fontSize: 10,
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

  String _generateRandomPTInfo(PerguruanTinggiDetail pt, int index) {
    final hexCode = _getRandomHexValue(8);
    
    switch (index) {
      case 0:
        return "STATUS: ${pt.statusPt} | AKREDITASI: ${pt.akreditasiPt} | KODE: ${pt.kodePt}";
      case 1:
        return "TAHUN BERDIRI: ${pt.tglBerdiriPt} | SK PENDIRIAN: ${pt.skPendirianSp.isNotEmpty ? pt.skPendirianSp.substring(0, min(pt.skPendirianSp.length, 15)) : '-'}...";
      case 2:
        return "LOKASI: LAT ${pt.lintangPt}, LONG ${pt.bujurPt} | KODE POS: ${pt.kodePos}";
      case 3:
        return "KONTAK: ${pt.noTel} | FAX: ${pt.noFax} | WEBSITE: ${pt.website}";
      case 4:
        return "SISTEM: PT-SCANNER | ID: ${hexCode} | WAKTU: ${DateTime.now().toString().substring(0, 16)}";
      default:
        return "";
    }
  }

  Color _getInfoColor(int index) {
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlexibleText(
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
              color: HackerColors.background,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: HackerColors.accent.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: FlexibleText(
              value.isNotEmpty ? value : "-DISENSOR-",
              style: const TextStyle(
                color: HackerColors.primary,
                fontFamily: 'Courier',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}