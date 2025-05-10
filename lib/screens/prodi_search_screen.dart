import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../api/multi_api_factory.dart';
import '../models/prodi.dart';
import '../widgets/prodi_navigation_button.dart';
import '../widgets/hacker_search_bar.dart';
import '../widgets/console_text.dart';
import '../widgets/terminal_window.dart';
import '../widgets/flexible_text.dart';
import '../utils/constants.dart';
import '../utils/screen_utils.dart';

/// Screen untuk melakukan pencarian program studi
class ProdiSearchScreen extends StatefulWidget {
  const ProdiSearchScreen({Key? key}) : super(key: key);

  @override
  _ProdiSearchScreenState createState() => _ProdiSearchScreenState();
}

class _ProdiSearchScreenState extends State<ProdiSearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Prodi> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  List<String> _consoleMessages = [];
  final Random _random = Random();
  Timer? _consoleTimer;
  
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
    _animationController.dispose();
    _consoleTimer?.cancel();
    super.dispose();
  }

  void _simulateHacking() {
    setState(() {
      _consoleMessages = [];
      _isLoading = true;
    });

    final String query = _searchController.text.trim();
    
    _addConsoleMessageWithDelay("MEMULAI PEMINDAIAN DATABASE PRODI UNTUK: $query", 300);
    _addConsoleMessageWithDelay("MELEWATI LAPISAN KEAMANAN 1...", 800);
    _addConsoleMessageWithDelay("MENYUNTIKKAN QUERY SQL...", 1200);
    _addConsoleMessageWithDelay("MENCOBA MEMECAHKAN ENKRIPSI...", 1800);
    _addConsoleMessageWithDelay("MENEMBUS FIREWALL...", 2400);
    _addConsoleMessageWithDelay("MENGAKSES DATABASE PROGRAM STUDI...", 3000);
    
    _actuallyPerformSearch();
  }

  Future<void> _actuallyPerformSearch() async {
    final String query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = AppStrings.pleaseEnterSearchTerm;
        _isLoading = false;
      });
      _addConsoleMessageWithDelay("ERROR: TARGET TIDAK DITENTUKAN", 500);
      return;
    }

    try {
      // Tambahan indikator loading
      _addConsoleMessageWithDelay("MENGAKSES SERVER DATABASE...", 1000);
      _addConsoleMessageWithDelay("MENCOBA KONEKSI AMAN...", 2000);

      // Cari data dengan error handling
      List<Prodi> results = [];
      try {
        // Gunakan API MultiApiFactory untuk mencari Prodi
        results = await _multiApiFactory.searchProdi(query);
        _addConsoleMessageWithDelay("MENDAPATKAN DATA PROGRAM STUDI...", 2500);
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
              "PROGRAM STUDI SCANNER",
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
                  'AKSES DATABASE PROGRAM STUDI',
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
                  hintText: "masukkan nama program studi...",
                  onSearch: _simulateHacking,
                ),
              ),
              Expanded(
                child: _isLoading
                  ? TerminalWindow(
                      title: "PENCARIAN SEDANG BERJALAN",
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _consoleMessages.length,
                        itemBuilder: (context, index) {
                          return ConsoleText(text: _consoleMessages[index]);
                        },
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
                                Icons.school,
                                color: HackerColors.accent.withOpacity(0.5),
                                size: 64.0,
                              ),
                              const SizedBox(height: 16.0),
                              const FlexibleText(
                                "MASUKKAN NAMA PROGRAM STUDI UNTUK MENCARI",
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
                                    const Icon(Icons.school, 
                                        color: HackerColors.primary, 
                                        size: 16.0),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: FlexibleText(
                                        'DITEMUKAN ${_searchResults.length} PROGRAM STUDI',
                                        style: const TextStyle(
                                          color: HackerColors.primary,
                                          fontFamily: 'Courier',
                                          fontSize: 14.0,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _searchResults.length,
                                  itemBuilder: (context, index) {
                                    final prodi = _searchResults[index];
                                    return ProdiNavigationButton(prodi: prodi);
                                  },
                                ),
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
}