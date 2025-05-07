import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/pddikti_api.dart';
import '../models/mahasiswa.dart';
import '../widgets/hacker_loading_indicator.dart';
import '../widgets/console_text.dart';
import '../widgets/terminal_window.dart';
import '../utils/constants.dart';

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
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.repeat(reverse: true);
    
    // Start decryption sequence
    _simulateDecryption();
  }

  void _simulateDecryption() {
    setState(() {
      _consoleMessages = [];
      _isDecrypting = true;
    });

    _addConsoleMessageWithDelay("ACCESSING SECURE DATABASE...", 300);
    _addConsoleMessageWithDelay("LOCATING SUBJECT: ${widget.subjectName}", 800);
    _addConsoleMessageWithDelay("DECRYPTING PERSONAL DATA...", 1400);
    _addConsoleMessageWithDelay("APPLYING ENCRYPTION BYPASS...", 2000);
    _addConsoleMessageWithDelay("EXTRACTING INSTITUTIONAL RECORDS...", 2600);
    _addConsoleMessageWithDelay("CLEANING DATA STREAMS...", 3200);
    
    // After simulation, actually fetch the data
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
    final api = Provider.of<PddiktiApi>(context, listen: false);
    _mahasiswaFuture = api.getMahasiswaDetail(widget.mahasiswaId);
    _mahasiswaFuture.then((_) {
      setState(() {
        _isDecrypting = false;
      });
      _addConsoleMessageWithDelay("DATA EXTRACTION COMPLETE", 300);
      _addConsoleMessageWithDelay("ACCESS GRANTED", 600);
    }).catchError((error) {
      setState(() {
        _isDecrypting = false;
      });
      _addConsoleMessageWithDelay("ERROR: DATA EXTRACTION FAILED", 300);
      _addConsoleMessageWithDelay("ACCESS DENIED", 600);
    });
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

  @override
  Widget build(BuildContext context) {
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
              AppStrings.detailTitle,
              style: TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                color: HackerColors.primary,
              ),
            ),
          ],
        ),
        backgroundColor: HackerColors.surface,
        iconTheme: const IconThemeData(
          color: HackerColors.primary,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("/api/placeholder/400/800"),
            fit: BoxFit.cover,
            opacity: 0.08,
          ),
        ),
        child: Column(
          children: [
            Container(
              color: HackerColors.surface.withOpacity(0.7),
              padding: const EdgeInsets.all(8.0),
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
                    'CONFIDENTIAL - ACCESS LEVEL 3 - SUBJECT: ${widget.subjectName}',
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
              child: _isDecrypting
                ? TerminalWindow(
                    title: "DATA DECRYPTION",
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _consoleMessages.length,
                      itemBuilder: (context, index) {
                        bool isSuccess = index == _consoleMessages.length - 1 && 
                                      _consoleMessages[index].contains("COMPLETE");
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
                        return const Center(child: HackerLoadingIndicator());
                      } else if (snapshot.hasError) {
                        return TerminalWindow(
                          title: "ERROR",
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
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
                                    '${AppStrings.errorLoadingData} ${snapshot.error}',
                                    style: const TextStyle(
                                      color: HackerColors.error,
                                      fontSize: 16,
                                      fontFamily: 'Courier',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: _simulateDecryption,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: HackerColors.surface,
                                      foregroundColor: HackerColors.primary,
                                      side: const BorderSide(color: HackerColors.primary),
                                    ),
                                    child: const Text(AppStrings.retry),
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
                              color: HackerColors.error,
                              fontFamily: 'Courier',
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
                        'SECURITY KEY: ${_getRandomHexValue(8)}-${_getRandomHexValue(4)}-${_getRandomHexValue(4)}',
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
    );
  }

  Widget _buildHackerDetailView(MahasiswaDetail mahasiswa) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildDataTerminal(
                    title: "PERSONAL DATA",
                    icon: Icons.person,
                    content: [
                      _buildDataRow("IDENTITY", mahasiswa.nama),
                      _buildDataRow("SUBJECT ID", mahasiswa.nim),
                      _buildDataRow("BIOLOGICAL TYPE", mahasiswa.jenisKelamin),
                      _buildDataRow("RECRUITMENT DATE", mahasiswa.tahunMasuk),
                      _buildDataRow("ENTRY PROTOCOL", mahasiswa.jenisDaftar),
                      _buildDataRow("ACTIVE STATUS", mahasiswa.statusSaatIni),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _buildDataTerminal(
                    title: "INSTITUTIONAL DATA",
                    icon: Icons.school,
                    content: [
                      _buildDataRow("INSTITUTION", mahasiswa.namaPt),
                      _buildDataRow("INST CODE", mahasiswa.kodePt),
                      _buildDataRow("PROGRAM", mahasiswa.prodi),
                      _buildDataRow("PROG CODE", mahasiswa.kodeProdi),
                      _buildDataRow("EDUCATION TIER", mahasiswa.jenjang),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSecurityTerminal(mahasiswa),
        ],
      ),
    );
  }

  Widget _buildDataTerminal({
    required String title,
    required IconData icon,
    required List<Widget> content,
  }) {
    return TerminalWindow(
      title: title,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
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
                Text(
                  title,
                  style: const TextStyle(
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
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTerminal(MahasiswaDetail mahasiswa) {
    return Container(
      height: 120,
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
            child: const Text(
              "SECURITY ANALYSIS",
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
                return Text(
                  _generateRandomSecurityInfo(mahasiswa, index),
                  style: TextStyle(
                    color: _getSecurityColor(index),
                    fontFamily: 'Courier',
                    fontSize: 10,
                  ),
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
        return "ACCESS LEVEL: ${_random.nextInt(3) + 2} | IP: 192.168.${_random.nextInt(255)}.${_random.nextInt(255)} | PORT: ${_random.nextInt(9000) + 1000}";
      case 1:
        return "DATA INTEGRITY: ${_random.nextInt(30) + 70}% | ENCRYPTION: AES-256 | HASH: SHA3-${_random.nextInt(2) == 0 ? "256" : "512"}";
      case 2:
        return "SYSTEM: PDDIKTI-SEC | NODE: ${_getRandomHexValue(4)}-${_getRandomHexValue(4)} | SESSION: $hexCode";
      case 3:
        return "LAST UPDATE: ${DateTime.now().toString().substring(0, 16)} | RECORD ID: ${mahasiswa.id.substring(0, 10)}...";
      case 4:
        return "STATUS: ${_random.nextBool() ? "SECURE" : "MONITORING"} | CHECKSUM: ${_getRandomHexValue(8)} | AUTH: ${_getRandomHexValue(6)}";
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
              color: HackerColors.background,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: HackerColors.accent.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              value.isNotEmpty ? value : "-REDACTED-",
              style: const TextStyle(
                color: HackerColors.primary,
                fontFamily: 'Courier',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}