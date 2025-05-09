import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/pddikti_api.dart';
import '../models/mahasiswa.dart';
import '../widgets/hacker_search_bar.dart';
import '../widgets/hacker_result_item.dart';
import '../widgets/hacker_loading_indicator.dart';
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animationController.repeat(reverse: true);

    // Show intro sequence
    _runIntroSequence();
  }

  void _runIntroSequence() {
    setState(() {
      _consoleMessages = [];
    });

    _addConsoleMessageWithDelay("INITIALIZING DB CRACKER SYSTEM...", 300);
    _addConsoleMessageWithDelay("CONNECTING TO SECURE SERVER...", 800);
    _addConsoleMessageWithDelay("BYPASSING SECURITY PROTOCOLS...", 1500);
    _addConsoleMessageWithDelay("ESTABLISHING DATABASE CONNECTION...", 2300);
    _addConsoleMessageWithDelay("SCANNING FIREWALL VULNERABILITIES...", 3000);
    _addConsoleMessageWithDelay("ACCESS GRANTED TO EDUCATIONAL DATABASE", 4000);
    _addConsoleMessageWithDelay("DB CRACKER v2.5 READY - Author: Tamaengs", 4500);
    
    // Hide intro sequence after a delay
    Timer(const Duration(milliseconds: 5000), () {
      setState(() {
        _showIntro = false;
      });
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
    
    _addConsoleMessageWithDelay("INITIATING DATABASE SCAN FOR TARGET: $query", 300);
    _addConsoleMessageWithDelay("BYPASSING SECURITY LAYER 1...", 800);
    _addConsoleMessageWithDelay("INJECTING SQL QUERIES...", 1200);
    _addConsoleMessageWithDelay("ATTEMPTING TO CRACK ENCRYPTION...", 1800);
    _addConsoleMessageWithDelay("BREACHING FIREWALL...", 2400);
    _addConsoleMessageWithDelay("ACCESSING STUDENT RECORDS DATABASE...", 3000);
    
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
      _addConsoleMessageWithDelay("ERROR: NO TARGET SPECIFIED", 500);
      return;
    }

    try {
      final api = Provider.of<PddiktiApi>(context, listen: false);

      // Lakukan pencarian dengan penanganan kesalahan yang lebih baik
      List<Mahasiswa> results = [];
      try {
        results = await api.searchMahasiswa(query);
      } catch (e) {
        print('Error dalam pencarian: $e');
        throw Exception('Terjadi kesalahan dalam pencarian: $e');
      }
      
      // Delay showing results to simulate "hacking"
      await Future.delayed(const Duration(milliseconds: 3500));
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
        
        if (results.isEmpty) {
          _errorMessage = '${AppStrings.noResultsFound} "$query"';
          _addConsoleMessageWithDelay("NO MATCH FOUND IN DATABASE", 300);
          _addConsoleMessageWithDelay("ACCESS DENIED", 600);
        } else {
          _errorMessage = null;
          _addConsoleMessageWithDelay("MATCHING RECORDS FOUND: ${results.length}", 300);
          _addConsoleMessageWithDelay("DECRYPTING SUBJECT DATA...", 600);
          _addConsoleMessageWithDelay("ACCESS GRANTED", 900);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
        _errorMessage = '${AppStrings.errorSearching} ${e.toString()}';
      });
      _addConsoleMessageWithDelay("CONNECTION BREACH DETECTED", 300);
      _addConsoleMessageWithDelay("SECURITY ALERT: DISCONNECTING...", 600);
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
    if (_showIntro) {
      return TerminalWindow(
        title: "DB CRACKER BOOT SEQUENCE",
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
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
            Text(
              AppStrings.homeTitle,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                color: HackerColors.primary,
              ),
            ),
          ],
        ),
        backgroundColor: HackerColors.surface,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              "v2.5",
              style: TextStyle(
                color: HackerColors.accent,
                fontFamily: 'Courier',
              ),
            ),
          ),
        ],
      ),
      body: Container(
        // PERBAIKAN: Ganti NetworkImage dengan warna latar belakang
        color: HackerColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: HackerColors.surface.withOpacity(0.7),
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'SECURE CONNECTION ESTABLISHED',
                style: TextStyle(
                  color: HackerColors.highlight,
                  fontFamily: 'Courier',
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: HackerSearchBar(
                controller: _searchController,
                hintText: AppStrings.searchHint,
                onSearch: _simulateHacking,
              ),
            ),
            Expanded(
              child: _isLoading
                ? TerminalWindow(
                    title: "HACK IN PROGRESS",
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
                      title: "SYSTEM ALERT",
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
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
                                  side: const BorderSide(color: HackerColors.primary),
                                ),
                                child: const Text('RETRY HACK'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : _searchResults.isEmpty
                    ? TerminalWindow(
                        title: "AWAITING INPUT",
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
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "READY FOR DATABASE BREACH",
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
                        title: "EXTRACTED RECORDS",
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.person_search, color: HackerColors.primary, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'FOUND ${_searchResults.length} MATCHING SUBJECTS',
                                    style: const TextStyle(
                                      color: HackerColors.primary,
                                      fontFamily: 'Courier',
                                      fontSize: 14,
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
}