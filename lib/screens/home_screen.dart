import 'package:flutter/foundation.dart';
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
import '../widgets/filter_search_bar.dart';
import '../widgets/filter_status.dart';
// filter_overlay import removed — blocking dialogs replaced with instant setState
import '../widgets/dosen_search_button.dart'; // Tambahkan import
import '../utils/constants.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _filterController = TextEditingController();
  List<Mahasiswa> _searchResults = [];
  List<Mahasiswa> _filteredResults = [];
  bool _isLoading = false;
  bool _isSearchInProgress = false;
  String? _errorMessage;
  late AnimationController _animationController;
  bool _showIntro = true;
  List<String> _consoleMessages = [];
  final List<Timer> _activeTimers = [];
  late final bool _statusDotIsGreen;
  Timer? _consoleTimer;
  
  // Tambahkan instance MultiApiFactory
  late MultiApiFactory _multiApiFactory;
  
  // Tambahkan flag untuk menunjukkan pencarian multi-sumber
  bool _useMultiSource = true;

  // Tambahkan variabel untuk filter universitas
  List<String> _universities = [];
  String? _selectedUniversity;
  Timer? _filterDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // U4-FIX: pause animation on background
    _statusDotIsGreen = Random().nextBool();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animationController.repeat(reverse: true);
    
    // Inisialisasi MultiApiFactory
    _multiApiFactory = MultiApiFactory();
    
    // Tampilkan intro
    _runIntroSequence();
    
    // Untuk menunda filter saat pengetikan
    _filterController.addListener(_onFilterChanged);
  }
  
  void _onFilterChanged() {
    if (_filterDebounce?.isActive ?? false) {
      _filterDebounce!.cancel();
    }
    
    _filterDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_filterController.text.isNotEmpty) {
        _autoFilterResults(_filterController.text);
      }
    });
  }
  
  void _autoFilterResults(String query) {
    // Cari universitas yang sesuai dengan query
    final matchingUniversities = _universities
        .where((university) => 
            university.toLowerCase().contains(query.toLowerCase()))
        .toList();
    
    if (matchingUniversities.isNotEmpty) {
      _filterResults(matchingUniversities.first);
    }
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
    
    // BUG-U6 FIX: Timer harus setelah pesan terakhir (4500ms) + buffer
    // Sebelumnya 1500ms — intro hilang sebelum semua pesan tampil
    final introTimer = Timer(const Duration(milliseconds: 5000), () {
      if (mounted) {
        setState(() {
          _showIntro = false;
        });
      }
    });
    _activeTimers.add(introTimer);
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

  // U4-FIX: Pause/resume animation based on app lifecycle — saves battery
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
    _searchController.dispose();
    _filterController.dispose();
    _animationController.dispose();
    _consoleTimer?.cancel();
    _filterDebounce?.cancel();
    for (final timer in _activeTimers) { timer.cancel(); }
    _activeTimers.clear();
    super.dispose();
  }

  void _simulateHacking() {
    if (_isSearchInProgress) return;
    _isSearchInProgress = true; // PERF-FIX: flag properly reset in _actuallyPerformSearch finally block
    setState(() {
      _consoleMessages = [];
      _isLoading = true;
      // Reset filter saat melakukan pencarian baru
      _selectedUniversity = null;
      _filterController.clear();
      _universities = [];
      _filteredResults = [];
    });

    final String query = _searchController.text.trim();
    final sanitizedQuery = query.replaceAll('<', '').replaceAll('>', '').replaceAll('"', '').replaceAll("'", '');
    if (sanitizedQuery.length < 2) { setState(() { _errorMessage = 'Minimal 2 karakter untuk pencarian'; _isLoading = false; }); _isSearchInProgress = false; return; }
    
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
    // SECURITY-FIX: Whitelist sanitization + max length
    final sanitizedQuery = query.replaceAll(RegExp(r'[<>"' "'" r']'), '').trim();
    if (sanitizedQuery.length < 2) {
      setState(() { _errorMessage = 'Minimal 2 karakter untuk pencarian'; _isLoading = false; });
      _isSearchInProgress = false;
      return;
    }
    if (sanitizedQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _filteredResults = [];
        _errorMessage = AppStrings.pleaseEnterSearchTerm;
        _isLoading = false;
      });
      _isSearchInProgress = false;
      _addConsoleMessageWithDelay("ERROR: TARGET TIDAK DITENTUKAN", 500);
      return;
    }

    try {
      _addConsoleMessageWithDelay("MENGAKSES SERVER DATABASE...", 1000);
      _addConsoleMessageWithDelay("MENCOBA KONEKSI AMAN...", 2000);

      List<Mahasiswa> results = [];
      try {
        if (_useMultiSource) {
          // SECURITY-FIX: Gunakan sanitizedQuery, bukan raw query
          results = await _multiApiFactory.searchAllSources(sanitizedQuery);
          _addConsoleMessageWithDelay("MENGGABUNGKAN DATA DARI MULTIPLE SUMBER...", 2500);
        } else {
          final api = Provider.of<ApiFactory>(context, listen: false);
          results = await api.searchMahasiswa(sanitizedQuery);
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Error dalam pencarian: $e');
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
      
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _searchResults = results;
        _filteredResults = results;
        _isLoading = false;
        
        if (results.isEmpty) {
          _errorMessage = 'TIDAK DITEMUKAN HASIL UNTUK "$sanitizedQuery"';
          _addConsoleMessageWithDelay("TIDAK ADA DATA YANG COCOK", 300);
          _addConsoleMessageWithDelay("AKSES DITOLAK", 600);
        } else {
          _errorMessage = null;
          _addConsoleMessageWithDelay("DATA DITEMUKAN: ${results.length}", 300);
          _addConsoleMessageWithDelay("MENDEKRIPSI DATA...", 600);
          _addConsoleMessageWithDelay("AKSES DIBERIKAN", 900);
          _extractUniversities(results);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
        _filteredResults = [];
        String errorMsg = e.toString().replaceAll("Exception: ", "");
        _errorMessage = errorMsg;
      });
      _addConsoleMessageWithDelay("KONEKSI TERPUTUS", 300);
      _addConsoleMessageWithDelay("PERINGATAN KEAMANAN: DISCONNECT...", 600);
    } finally {
      // BUG-C3 FIX: ALWAYS reset flag — prevents app from locking after search
      _isSearchInProgress = false;
    }
  }

  // Ekstrak daftar universitas unik dari hasil pencarian
  void _extractUniversities(List<Mahasiswa> results) {
    Set<String> uniqueUniversities = {};
    
    for (var mahasiswa in results) {
      if (mahasiswa.namaPt.isNotEmpty) {
        uniqueUniversities.add(mahasiswa.namaPt);
      }
    }
    
    setState(() {
      _universities = uniqueUniversities.toList()..sort();
    });
  }

  // Filter hasil berdasarkan universitas yang dipilih
  // UX-FIX H5: Removed blocking dialog — filtering a local list is instant
  void _filterResults(String? university) {
    setState(() {
      _selectedUniversity = university;
      if (university == null) {
        _filteredResults = _searchResults;
      } else {
        _filteredResults = _searchResults
            .where((mahasiswa) => mahasiswa.namaPt == university)
            .toList();
      }
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedUniversity = null;
      _filteredResults = _searchResults;
      _filterController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          AppStrings.filterCleared,
          style: TextStyle(fontFamily: 'Courier', fontSize: 14),
        ),
        backgroundColor: CtOSColors.surface,
        duration: Duration(seconds: 1),
      ),
    );
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
      backgroundColor: CtOSColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _animationController.value > 0.5 
                        ? CtOSColors.primary 
                        : CtOSColors.error,
                  ),
                );
              },
            ),
            Flexible(
              child: Text(
                AppStrings.homeTitle,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  color: CtOSColors.primary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        backgroundColor: CtOSColors.surface,
        actions: [
          // Toggle switch untuk mengaktifkan/menonaktifkan multi-source
          Switch(
            value: _useMultiSource,
            activeColor: CtOSColors.primary,
            inactiveThumbColor: CtOSColors.secondary,
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
                  backgroundColor: CtOSColors.surface,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: isMobile ? 4 : 8),
            child: Text(
              _useMultiSource ? "MULTI-DB" : "PDDIKTI",
              style: const TextStyle(
                color: CtOSColors.secondary,
                fontFamily: 'Courier',
                fontSize: 10,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.monitor_heart, color: CtOSColors.secondary, size: 18),
            onPressed: () => Navigator.pushNamed(context, '/health'),
            tooltip: 'Status Sistem',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: CtOSColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: CtOSColors.surface.withValues(alpha: 0.7),
                padding: const EdgeInsets.all(8),
                child: const Text(
                  'KONEKSI AMAN TERSEDIA',
                  style: TextStyle(
                    color: CtOSColors.textAccent,
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
              // Tambahkan filter universitas jika ada hasil
              if (_searchResults.isNotEmpty && _universities.isNotEmpty)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FilterSearchBar(
                        universities: _universities,
                        selectedUniversity: _selectedUniversity,
                        onFilter: _filterResults,
                        onClear: _clearFilter,
                        controller: _filterController,
                      ),
                    ),
                    // Tampilkan status filter jika filter aktif
                    if (_selectedUniversity != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: FilterStatus(
                          university: _selectedUniversity!,
                          count: _filteredResults.length,
                          onClear: _clearFilter,
                        ),
                      ),
                  ],
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
                                  color: CtOSColors.error,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: CtOSColors.error,
                                    fontSize: 16,
                                    fontFamily: 'Courier',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _simulateHacking,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CtOSColors.surface,
                                    foregroundColor: CtOSColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16, 
                                      vertical: 8
                                    ),
                                    side: const BorderSide(color: CtOSColors.primary),
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
                                color: CtOSColors.secondary.withValues(alpha: 0.5),
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                AppStrings.emptySearchPrompt,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: CtOSColors.textPrimary,
                                  fontFamily: 'Courier',
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                              
                              // Tambahkan tombol-tombol menu disini
                              const SizedBox(height: 24),
                              
                              // Tambahkan tombol pencarian dosen
                              const DosenSearchButton(),
                              
                              const SizedBox(height: 8),
                              // Tombol NPSN Lookup
                              InkWell(
                                onTap: () => Navigator.pushNamed(context, '/sekolah'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: CtOSColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: CtOSColors.secondary.withValues(alpha: 0.3)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.school, color: CtOSColors.secondary, size: 20),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('NPSN LOOKUP', style: TextStyle(
                                              color: CtOSColors.secondary, fontFamily: 'Courier',
                                              fontSize: 13, fontWeight: FontWeight.bold,
                                            )),
                                            Text('Cari data sekolah via NPSN', style: TextStyle(
                                              color: CtOSColors.textPrimary, fontFamily: 'Courier', fontSize: 11,
                                            )),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.search, color: CtOSColors.secondary, size: 18),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),
                              const Text(
                                "SIAP UNTUK MEMULAI PERETASAN",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: CtOSColors.secondary,
                                  fontFamily: 'Courier',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : TerminalWindow(
                          title: _selectedUniversity != null 
                              ? AppStrings.filterResults 
                              : "REKAMAN TEREKSTRAK",
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Icon(
                                        _selectedUniversity != null
                                            ? Icons.filter_list
                                            : Icons.person_search,
                                        color: _selectedUniversity != null
                                            ? CtOSColors.warning
                                            : CtOSColors.primary,
                                        size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedUniversity != null
                                          ? 'DITEMUKAN ${_filteredResults.length} DARI ${_searchResults.length} SUBJEK'
                                          : 'DITEMUKAN ${_searchResults.length} SUBJEK YANG COCOK',
                                        style: TextStyle(
                                          color: _selectedUniversity != null
                                              ? CtOSColors.warning
                                              : CtOSColors.primary,
                                          fontFamily: 'Courier',
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_filteredResults.isEmpty && _selectedUniversity != null)
                                Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.filter_alt_off,
                                          color: CtOSColors.warning,
                                          size: 40,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          AppStrings.noFilterResultsFound,
                                          style: TextStyle(
                                            color: CtOSColors.warning,
                                            fontSize: 16,
                                            fontFamily: 'Courier',
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _clearFilter,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: CtOSColors.surface,
                                            foregroundColor: CtOSColors.warning,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16, 
                                              vertical: 8
                                            ),
                                            side: const BorderSide(color: CtOSColors.warning),
                                          ),
                                          child: const Text(
                                            AppStrings.clearFilter,
                                            style: TextStyle(
                                              fontSize: 14,
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
                                  child: ListView.builder(
                                    itemCount: _filteredResults.length,
                                    itemBuilder: (context, index) {
                                      final mahasiswa = _filteredResults[index];
                                      return HackerResultItem(
                                        mahasiswa: mahasiswa,
                                        onTap: () => _viewMahasiswaDetail(context, mahasiswa),
                                        isFiltered: _selectedUniversity != null,
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
              ),
              Container(
                color: CtOSColors.surface,
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
                            color: _statusDotIsGreen ? CtOSColors.primary : CtOSColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateTime.now().toString().substring(0, 19),
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
}