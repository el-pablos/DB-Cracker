import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_factory.dart';
import '../models/dosen.dart';
import '../widgets/ctos_container.dart';
import '../widgets/ctos_layout.dart';
import '../widgets/error_boundary.dart';
import '../utils/constants.dart';

/// Screen untuk melakukan pencarian dosen dengan tema ctOS yang elegan
class DosenSearchScreenNew extends StatefulWidget {
  const DosenSearchScreenNew({Key? key}) : super(key: key);

  @override
  _DosenSearchScreenNewState createState() => _DosenSearchScreenNewState();
}

class _DosenSearchScreenNewState extends State<DosenSearchScreenNew>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final Random _random = Random();

  List<Dosen> _searchResults = [];
  List<Dosen> _filteredResults = [];
  List<String> _ptList = [];
  String? _selectedPt;
  String? _errorMessage;
  bool _isLoading = false;

  late AnimationController _animationController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animationController.repeat();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchDosen() async {
    final query = _searchController.text.trim();

    // Input validation
    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Masukkan nama dosen untuk mencari';
      });
      return;
    }

    if (query.length < 2) {
      setState(() {
        _errorMessage = 'Nama dosen minimal 2 karakter';
      });
      return;
    }

    // Input sanitization - remove special characters that might cause issues
    final sanitizedQuery = query
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '')
        .replaceAll("'", '');
    if (sanitizedQuery.isEmpty) {
      setState(() {
        _errorMessage = 'Nama dosen tidak valid';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults.clear();
      _filteredResults.clear();
      _ptList.clear();
      _selectedPt = null;
    });

    try {
      final apiFactory = Provider.of<ApiFactory>(context, listen: false);

      // Add timeout for the search request
      final results = await apiFactory
          .searchDosen(sanitizedQuery)
          .timeout(const Duration(seconds: 30));

      if (!mounted) return; // Check if widget is still mounted

      setState(() {
        _searchResults = results;
        _filteredResults = results;
        _ptList = results.map((d) => d.namaPt).toSet().toList()..sort();
        _isLoading = false;
      });

      // Show message if no results found
      if (results.isEmpty) {
        setState(() {
          _errorMessage = 'Tidak ditemukan dosen dengan nama "$sanitizedQuery"';
        });
      }
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted

      setState(() {
        String errorMsg = 'Terjadi kesalahan saat mencari data';

        if (e.toString().contains('TimeoutException')) {
          errorMsg = 'Koneksi timeout. Periksa koneksi internet Anda';
        } else if (e.toString().contains('SocketException')) {
          errorMsg =
              'Tidak dapat terhubung ke server. Periksa koneksi internet';
        } else if (e.toString().contains('403')) {
          errorMsg = 'Akses ditolak server. Coba lagi nanti';
        } else if (e.toString().contains('404')) {
          errorMsg = 'Data tidak ditemukan di server';
        }

        _errorMessage = errorMsg;
        _isLoading = false;
      });

      // Log error for debugging
      print('Search error: $e');
    }
  }

  void _filterResults(String? pt) {
    setState(() {
      _selectedPt = pt;
      if (pt == null) {
        _filteredResults = _searchResults;
      } else {
        _filteredResults = _searchResults.where((d) => d.namaPt == pt).toList();
      }
    });
  }

  void _clearFilter() {
    _filterResults(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CtOSColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _buildHeader(),
                _buildSearchSection(),
                if (_searchResults.isNotEmpty && _ptList.isNotEmpty)
                  _buildFilterSection(),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight -
                          200, // Reserve space for header/footer
                    ),
                    child: _buildMainContent(),
                  ),
                ),
                _buildFooter(),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 12.0,
                height: 12.0,
                margin: const EdgeInsets.only(right: 12.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _animationController.value > 0.5
                      ? CtOSColors.primary
                      : CtOSColors.error,
                  boxShadow: [
                    BoxShadow(
                      color: (_animationController.value > 0.5
                              ? CtOSColors.primary
                              : CtOSColors.error)
                          .withValues(alpha: 0.6),
                      blurRadius: 8.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
              );
            },
          ),
          const CtOSText(
            "ctOS DATABASE SCANNER",
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: CtOSColors.primary,
          ),
        ],
      ),
      backgroundColor: CtOSColors.surface,
      elevation: 0,
      actions: [
        if (_searchResults.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: CtOSColors.background,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: CtOSColors.primary),
                  boxShadow: [
                    BoxShadow(
                      color: CtOSColors.primary.withValues(alpha: 0.3),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
                child: CtOSText(
                  '${_filteredResults.length}/${_searchResults.length}',
                  fontSize: 12.0,
                  color: CtOSColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return CtOSContainer(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(16.0),
      backgroundColor: CtOSColors.surfaceVariant,
      showBorder: false,
      child: Row(
        children: [
          // Status indicator
          CtOSStatusIndicator(
            isActive: _isLoading,
            label: _isLoading ? "SCANNING" : "READY",
          ),

          const SizedBox(width: 16.0),

          // Title dengan flexible layout untuk mencegah overflow
          Expanded(
            child: Center(
              child: CtOSText(
                'ctOS FACULTY DATABASE ACCESS',
                fontSize: 14.0,
                color: CtOSColors.textAccent,
                fontWeight: FontWeight.bold,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(width: 16.0),

          // Spacer untuk balance layout
          SizedBox(width: 80.0), // Approximate width of status indicator
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return CtOSContainer(
      child: CtOSSearchBar(
        controller: _searchController,
        hintText: "masukkan nama dosen...",
        onSearch: _searchDosen,
        isLoading: _isLoading,
      ),
    );
  }

  Widget _buildFilterSection() {
    return CtOSContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CtOSHeader(
            title: "FILTER PERGURUAN TINGGI",
            showDivider: false,
          ),
          const SizedBox(height: 12.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: CtOSColors.background,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: CtOSColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedPt,
                hint: const CtOSText(
                  "PILIH PERGURUAN TINGGI",
                  fontSize: 12.0,
                  color: CtOSColors.textSecondary,
                ),
                dropdownColor: CtOSColors.surface,
                style: const TextStyle(
                  color: CtOSColors.primary,
                  fontFamily: 'Courier',
                  fontSize: 12.0,
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: CtOSColors.textSecondary,
                ),
                onChanged: _filterResults,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: CtOSText(
                      "SEMUA PERGURUAN TINGGI",
                      fontSize: 12.0,
                      color: CtOSColors.textPrimary,
                    ),
                  ),
                  ..._ptList.map<DropdownMenuItem<String>>((String pt) {
                    return DropdownMenuItem<String>(
                      value: pt,
                      child: CtOSText(
                        pt,
                        fontSize: 12.0,
                        color: CtOSColors.primary,
                        maxLines: 1,
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

  Widget _buildMainContent() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_errorMessage != null) {
      return _buildErrorState();
    } else if (_searchResults.isEmpty) {
      return _buildEmptyState();
    } else if (_filteredResults.isEmpty && _selectedPt != null) {
      return _buildNoFilterResultsState();
    } else {
      return _buildResultsList();
    }
  }

  Widget _buildLoadingState() {
    return CtOSContainer(
      showGlow: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CtOSColors.primary.withValues(
                      alpha: 0.3 + 0.7 * _glowController.value,
                    ),
                    width: 2.0,
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(CtOSColors.primary),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24.0),
          const CtOSText(
            "SCANNING DATABASE...",
            fontSize: 16.0,
            color: CtOSColors.primary,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8.0),
          const CtOSText(
            "Mengakses server PDDIKTI",
            fontSize: 12.0,
            color: CtOSColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return CtOSErrorBoundary(
      errorMessage: _errorMessage,
      onRetry: () {
        setState(() {
          _errorMessage = null;
        });
        _searchDosen();
      },
      child: Container(), // This won't be shown since errorMessage is not null
    );
  }

  Widget _buildEmptyState() {
    return CtOSContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            color: CtOSColors.textSecondary.withValues(alpha: 0.5),
            size: 80.0,
          ),
          const SizedBox(height: 24.0),
          const CtOSText(
            "MASUKKAN NAMA DOSEN",
            fontSize: 18.0,
            color: CtOSColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8.0),
          const CtOSText(
            "Sistem siap untuk memulai pencarian",
            fontSize: 12.0,
            color: CtOSColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoFilterResultsState() {
    return CtOSContainer(
      borderColor: CtOSColors.warning,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.filter_alt_off,
            color: CtOSColors.warning,
            size: 64.0,
          ),
          const SizedBox(height: 16.0),
          const CtOSText(
            "TIDAK ADA HASIL UNTUK FILTER INI",
            fontSize: 16.0,
            color: CtOSColors.warning,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),
          CtOSButton(
            text: "HAPUS FILTER",
            onPressed: _clearFilter,
            icon: Icons.clear,
            isPrimary: false,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return CtOSContainer(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CtOSHeader(
            title: "HASIL PENCARIAN",
            subtitle: _selectedPt != null
                ? 'Filter: $_selectedPt (${_filteredResults.length})'
                : 'Ditemukan ${_searchResults.length} dosen',
            trailing: _selectedPt != null
                ? IconButton(
                    icon: const Icon(Icons.clear, color: CtOSColors.warning),
                    onPressed: _clearFilter,
                  )
                : null,
          ),
          Expanded(
            child: _filteredResults.isEmpty
                ? const Center(
                    child: CtOSText(
                      "Tidak ada data dosen",
                      fontSize: 14.0,
                      color: CtOSColors.textSecondary,
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredResults.length,
                    itemBuilder: (context, index) => _buildDosenCard(index),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDosenCard(int index) {
    final dosen = _filteredResults[index];
    final isEven = index % 2 == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0), // Reduced padding
      decoration: BoxDecoration(
        color: CtOSColors.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isEven ? CtOSColors.primary : CtOSColors.secondary,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isEven ? CtOSColors.primary : CtOSColors.secondary)
                .withValues(alpha: 0.1),
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
            arguments: {'dosenName': dosen.nama},
          );
        },
        borderRadius: BorderRadius.circular(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Better alignment
          children: [
            // Avatar - smaller size for better space utilization
            Container(
              width: 50.0, // Reduced from 60.0
              height: 50.0, // Reduced from 60.0
              decoration: BoxDecoration(
                color: CtOSColors.background,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: isEven ? CtOSColors.primary : CtOSColors.secondary,
                  width: 2.0,
                ),
              ),
              child: Center(
                child: CtOSText(
                  dosen.nama.isNotEmpty ? dosen.nama[0].toUpperCase() : 'D',
                  fontSize: 20.0, // Reduced from 24.0
                  fontWeight: FontWeight.bold,
                  color: isEven ? CtOSColors.primary : CtOSColors.secondary,
                ),
              ),
            ),
            const SizedBox(width: 12.0), // Reduced from 16.0

            // Content - with better space management
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Prevent unnecessary expansion
                children: [
                  // Nama Dosen - with better text handling
                  CtOSText(
                    dosen.nama,
                    fontSize: 15.0, // Slightly reduced
                    fontWeight: FontWeight.bold,
                    color: CtOSColors.textPrimary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3.0), // Reduced spacing

                  // NIDN - with overflow protection
                  if (dosen.nidn.isNotEmpty)
                    CtOSText(
                      'NIDN: ${dosen.nidn}',
                      fontSize: 11.0, // Reduced from 12.0
                      color: isEven ? CtOSColors.primary : CtOSColors.secondary,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 3.0), // Reduced spacing

                  // Program Studi - with better overflow handling
                  CtOSText(
                    dosen.namaProdi,
                    fontSize: 12.0, // Reduced from 13.0
                    color: CtOSColors.textSecondary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6.0), // Reduced spacing

                  // Perguruan Tinggi - with flexible container
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 3.0), // Reduced padding
                      decoration: BoxDecoration(
                        color:
                            (isEven ? CtOSColors.primary : CtOSColors.secondary)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(
                          color: (isEven
                                  ? CtOSColors.primary
                                  : CtOSColors.secondary)
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: CtOSText(
                        dosen.namaPt,
                        fontSize: 10.0, // Reduced from 11.0
                        color:
                            isEven ? CtOSColors.primary : CtOSColors.secondary,
                        fontWeight: FontWeight.w600,
                        maxLines: 2, // Allow 2 lines for long university names
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8.0), // Reduced spacing

            // Arrow Icon - with padding for better touch target
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Icon(
                Icons.arrow_forward_ios,
                color: CtOSColors.textSecondary,
                size: 14.0, // Slightly reduced
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return CtOSContainer(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(12.0),
      backgroundColor: CtOSColors.surface,
      showBorder: false,
      child: Row(
        children: [
          // Status indicator dengan flexible space
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _random.nextBool()
                      ? CtOSColors.primary
                      : CtOSColors.secondary,
                ),
              );
            },
          ),
          const SizedBox(width: 8.0),

          // Timestamp dengan flexible layout
          Expanded(
            child: CtOSText(
              DateTime.now().toString().substring(0, 19),
              fontSize: 10.0,
              color: CtOSColors.textSecondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 8.0),

          // Author text dengan ukuran yang aman
          const CtOSText(
            'BY: TAMAENGS',
            fontSize: 10.0,
            color: CtOSColors.textSecondary,
            fontWeight: FontWeight.bold,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
