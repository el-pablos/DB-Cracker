import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_factory.dart';
import '../api/multi_api_factory.dart';
import '../models/mahasiswa.dart';
import '../widgets/hacker_search_bar.dart';
import '../widgets/hacker_result_item.dart';
import '../widgets/console_text.dart';
import '../widgets/terminal_window.dart';
import '../utils/constants.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Mahasiswa> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  bool _showIntro = true;
  List<String> _consoleMessages = [];
  final Random _random = Random();
  Timer? _consoleTimer;
  
  // Tambahkan instance MultiApiFactory
  late MultiApiFactory _multiApiFactory;
  
  // Tambahkan flag untuk menunjukkan pencarian multi-sumber
  bool _useMultiSource = true;

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
    
    // Tampilkan intro
    _runIntroSequence();
  }

  void _runIntroSequence() {
    setState(() {
      _consoleMessages = [];
    });

    _addConsoleMessageWithDelay("MEMULAI SISTEM DB CRACKER...", 300);
    _addConsoleMessageWithDelay("MENGHUBUNGKAN KE SERVER...", 800);
    _addConsoleMessageWithDelay("MELEWATI PROTOKOL KEAMANAN...", 1500);
    _addConsoleMessageWithDelay("MEMBUAT KONEKSI DATABASE...", 2300);
    _addConsoleMessageWithDelay("MEMINDAI CELAH FIREWALL...", 3000);
    _addConsoleMessageWithDelay("MENGAKTIFKAN SUMBER DATA TAMBAHAN...", 3500);
    _addConsoleMessageWithDelay("AKSES DIBERIKAN KE MULTIPLE DATABASE", 4000);
    _addConsoleMessageWithDelay("DB CRACKER v3.0 SIAP - Author: Tamaengs", 4500);
    
    // Sembunyikan intro setelah selesai
    Timer(const Duration(milliseconds: 5000), () {
      if (mounted) {
        setState(() {
          _showIntro = false;
        });
      }
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
    
    _addConsoleMessageWithDelay("MEMULAI PEMINDAIAN DATABASE UNTUK TARGET: $query", 300);
    _addConsoleMessageWithDelay("MELEWATI LAPISAN KEAMANAN 1...", 800);
    _addConsoleMessageWithDelay("MENYUNTIKKAN QUERY SQL...", 1200);
    _addConsoleMessageWithDelay("MENCOBA MEMECAHKAN ENKRIPSI...", 1800);
    _addConsoleMessageWithDelay("MENEMBUS FIREWALL...", 2400);
    
    if (_useMultiSource) {
      _addConsoleMessageWithDelay("MENGAKSES BERBAGAI DATABASE PENDIDIKAN...", 3000);
      _addConsoleMessageWithDelay("MENGGABUNGKAN HASIL DARI MULTIPLE SUMBER...", 3600);
    } else {
      _addConsoleMessageWithDelay("MENGAKSES DATABASE MAHASISWA...", 3000);
    }
    
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
      List<Mahasiswa> results = [];
      try {
        if (_useMultiSource) {
          // Gunakan multi-source pencarian
          results = await _multiApiFactory.searchAllSources(query);
          _addConsoleMessageWithDelay("MENGGABUNGKAN DATA DARI MULTIPLE SUMBER...", 2500);
        } else {
          // Gunakan hanya API PDDIKTI
          final api = Provider.of<ApiFactory>(context, listen: false);
          results = await api.searchMahasiswa(query);
        }
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

  void _viewMahasiswaDetail(BuildContext context, Mahasiswa mahasiswa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(mahasiswaId: mahasiswa.id, subjectName: mahasiswa.nama),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;
    
    if (_showIntro) {
      return TerminalWindow(
        title: "BOOT SEQUENCE DB CRACKER",
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _consoleMessages.length,
          itemBuilder: (context, index) {
            return ConsoleText(text: _consoleMessages[index]);
          },
        ),
      );
    }

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
                        : HackerColors.error,
                  ),
                );
              },
            ),
            const Text(
              "DB CRACKER v3.0",
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
        actions: [
          // Toggle switch untuk mengaktifkan/menonaktifkan multi-source
          Switch(
            value: _useMultiSource,
            activeColor: HackerColors.primary,
            inactiveThumbColor: HackerColors.accent,
            onChanged: (bool value) {
              setState(() {
                _useMultiSource = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value 
                      ? "MODE MULTI-SOURCE DIAKTIFKAN" 
                      : "MODE HANYA PDDIKTI DIAKTIFKAN",
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 14,
                    ),
                  ),
                  backgroundColor: HackerColors.surface,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: isMobile ? 8 : 16),
            child: Text(
              _useMultiSource ? "MULTI-DB" : "PDDIKTI",
              style: const TextStyle(
                color: HackerColors.accent,
                fontFamily: 'Courier',
                fontSize: 12,
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
                padding: const EdgeInsets.all(8),
                child: const Text(
                  'KONEKSI AMAN TERSEDIA',
                  style: TextStyle(
                    color: HackerColors.highlight,
                    fontFamily: 'Courier',
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: HackerSearchBar(
                  controller: _searchController,
                  hintText: AppStrings.searchHint,
                  onSearch: _simulateHacking,
                ),
              ),
              Expanded(
                child: _isLoading
                  ? TerminalWindow(
                      title: "HACKING SEDANG BERJALAN",
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
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
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: HackerColors.error,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: HackerColors.error,
                                    fontSize: 16,
                                    fontFamily: 'Courier',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _simulateHacking,
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
                                    'COBA LAGI',
                                    style: TextStyle(
                                      fontSize: 14,
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
                                Icons.search,
                                color: HackerColors.accent.withOpacity(0.5),
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                AppStrings.emptySearchPrompt,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: HackerColors.text,
                                  fontFamily: 'Courier',
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "SIAP UNTUK MEMULAI PERETASAN",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: HackerColors.accent,
                                  fontFamily: 'Courier',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : TerminalWindow(
                          title: "REKAMAN TEREKSTRAK",
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person_search, 
                                        color: HackerColors.primary, 
                                        size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'DITEMUKAN ${_searchResults.length} SUBJEK YANG COCOK',
                                        style: const TextStyle(
                                          color: HackerColors.primary,
                                          fontFamily: 'Courier',
                                          fontSize: 14,
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
                                    final mahasiswa = _searchResults[index];
                                    return HackerResultItem(
                                      mahasiswa: mahasiswa,
                                      onTap: () => _viewMahasiswaDetail(context, mahasiswa),
                                    );
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
                  horizontal: 16, 
                  vertical: 8
                ),
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
                            color: _random.nextBool() ? HackerColors.primary : HackerColors.accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateTime.now().toString().substring(0, 19),
                          style: const TextStyle(
                            color: HackerColors.text,
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
}