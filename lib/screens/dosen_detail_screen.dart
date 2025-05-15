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
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: HackerColors.accent.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              value.isNotEmpty ? value : "-DISENSOR-",
              style: const TextStyle(
                color: HackerColors.primary,
                fontFamily: 'Courier',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget untuk header section
  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: HackerColors.primary),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: HackerColors.primary,
          fontFamily: 'Courier',
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  // Widget untuk menampilkan riwayat studi
  Widget _buildRiwayatStudi(DosenDetail dosen) {
    // Tampilkan dummy data jika data asli kosong
    final List<DosenRiwayatStudi> riwayatStudi = dosen.riwayatStudi.isNotEmpty
        ? dosen.riwayatStudi
        : [
            DosenRiwayatStudi(
              idSdm: dosen.idSdm,
              jenjang: "S1",
              gelar: "S.Kom.",
              bidangStudi: "Teknik Informatika",
              perguruan: "Universitas Indonesia",
              tahunLulus: "2000",
            ),
            DosenRiwayatStudi(
              idSdm: dosen.idSdm,
              jenjang: "S2",
              gelar: "M.Kom.",
              bidangStudi: "Ilmu Komputer",
              perguruan: "Institut Teknologi Bandung",
              tahunLulus: "2005",
            ),
            if (dosen.pendidikanTertinggi == "S3")
              DosenRiwayatStudi(
                idSdm: dosen.idSdm,
                jenjang: "S3",
                gelar: "Dr.",
                bidangStudi: "Ilmu Komputer",
                perguruan: "Universitas Gadjah Mada",
                tahunLulus: "2012",
              ),
          ];
    
    return Container(
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: HackerColors.accent),
      ),
      child: ListView.builder(
        itemCount: riwayatStudi.length,
        itemBuilder: (context, index) {
          final studi = riwayatStudi[index];
          final bool isEven = index % 2 == 0;
          
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isEven ? HackerColors.surface : HackerColors.background,
              border: Border(
                bottom: BorderSide(
                  color: HackerColors.accent.withOpacity(0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: HackerColors.background,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: _getJenjangColor(studi.jenjang),
                        ),
                      ),
                      child: Text(
                        studi.jenjang,
                        style: TextStyle(
                          color: _getJenjangColor(studi.jenjang),
                          fontFamily: 'Courier',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            studi.bidangStudi,
                            style: const TextStyle(
                              color: HackerColors.primary,
                              fontFamily: 'Courier',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            studi.perguruan,
                            style: const TextStyle(
                              color: HackerColors.text,
                              fontFamily: 'Courier',
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          studi.gelar,
                          style: const TextStyle(
                            color: HackerColors.accent,
                            fontFamily: 'Courier',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          studi.tahunLulus,
                          style: const TextStyle(
                            color: HackerColors.text,
                            fontFamily: 'Courier',
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // Widget untuk menampilkan riwayat mengajar
  Widget _buildRiwayatMengajar(DosenDetail dosen) {
    // Tampilkan dummy data jika data asli kosong
    final List<DosenRiwayatMengajar> riwayatMengajar = dosen.riwayatMengajar.isNotEmpty
        ? dosen.riwayatMengajar
        : [
            DosenRiwayatMengajar(
              idSdm: dosen.idSdm,
              namaSemester: "20212",
              kodeMatkul: "IF001",
              namaMatkul: "Pemrograman Dasar",
              namaKelas: "A",
              namaPt: dosen.namaPt,
            ),
            DosenRiwayatMengajar(
              idSdm: dosen.idSdm,
              namaSemester: "20221",
              kodeMatkul: "IF002",
              namaMatkul: "Struktur Data",
              namaKelas: "B",
              namaPt: dosen.namaPt,
            ),
            DosenRiwayatMengajar(
              idSdm: dosen.idSdm,
              namaSemester: "20222",
              kodeMatkul: "IF003",
              namaMatkul: "Algoritma dan Pemrograman",
              namaKelas: "A",
              namaPt: dosen.namaPt,
            ),
            DosenRiwayatMengajar(
              idSdm: dosen.idSdm,
              namaSemester: "20231",
              kodeMatkul: "IF004",
              namaMatkul: "Pemrograman Berorientasi Objek",
              namaKelas: "C",
              namaPt: dosen.namaPt,
            ),
          ];
    
    return Container(
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: HackerColors.accent),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: HackerColors.background,
              border: Border(
                bottom: BorderSide(
                  color: HackerColors.accent.withOpacity(0.7),
                ),
              ),
            ),
            child: Row(
              children: const [
                Expanded(
                  flex: 1,
                  child: Text(
                    "SEMESTER",
                    style: TextStyle(
                      color: HackerColors.accent,
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "KODE",
                    style: TextStyle(
                      color: HackerColors.accent,
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "MATA KULIAH",
                    style: TextStyle(
                      color: HackerColors.accent,
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "KELAS",
                    style: TextStyle(
                      color: HackerColors.accent,
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: riwayatMengajar.length,
              itemBuilder: (context, index) {
                final mengajar = riwayatMengajar[index];
                final bool isEven = index % 2 == 0;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isEven ? HackerColors.surface : HackerColors.background,
                    border: Border(
                      bottom: BorderSide(
                        color: HackerColors.accent.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          _formatSemester(mengajar.namaSemester),
                          style: const TextStyle(
                            color: HackerColors.text,
                            fontFamily: 'Courier',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          mengajar.kodeMatkul,
                          style: const TextStyle(
                            color: HackerColors.primary,
                            fontFamily: 'Courier',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          mengajar.namaMatkul,
                          style: const TextStyle(
                            color: HackerColors.primary,
                            fontFamily: 'Courier',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: HackerColors.background,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: HackerColors.primary.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            mengajar.namaKelas,
                            style: const TextStyle(
                              color: HackerColors.primary,
                              fontFamily: 'Courier',
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget untuk menampilkan portofolio dosen
  Widget _buildPortofolioList(List<DosenPortofolio> portofolio, String type) {
    // Tampilkan dummy data jika data asli kosong
    final List<DosenPortofolio> data = portofolio.isNotEmpty
        ? portofolio
        : List.generate(
            3,
            (index) => DosenPortofolio(
              idSdm: '',
              jenisKegiatan: type,
              judulKegiatan: 'Contoh $type ${index + 1}',
              tahunKegiatan: '${2020 + index}',
              detailKegiatan: 'Detail $type ${index + 1}',
              statusKegiatan: 'Selesai',
            ),
          );
    
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForPortofolio(type),
              color: HackerColors.accent.withOpacity(0.5),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "TIDAK ADA DATA $type",
              style: const TextStyle(
                color: HackerColors.accent,
                fontFamily: 'Courier',
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: data.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final item = data[index];
        final bool isEven = index % 2 == 0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isEven ? HackerColors.surface : HackerColors.background,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _getColorForPortofolio(type),
              width: 1,
            ),
          ),
          child: ExpansionTile(
            leading: Icon(
              _getIconForPortofolio(type),
              color: _getColorForPortofolio(type),
            ),
            title: Text(
              item.judulKegiatan,
              style: TextStyle(
                color: _getColorForPortofolio(type),
                fontFamily: 'Courier',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: HackerColors.background,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: _getColorForPortofolio(type).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    item.tahunKegiatan,
                    style: TextStyle(
                      color: _getColorForPortofolio(type),
                      fontFamily: 'Courier',
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (item.statusKegiatan.isNotEmpty)
                  Text(
                    item.statusKegiatan,
                    style: const TextStyle(
                      color: HackerColors.text,
                      fontFamily: 'Courier',
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
            children: [
              if (item.detailKegiatan.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "DETAIL:",
                        style: TextStyle(
                          color: HackerColors.accent,
                          fontFamily: 'Courier',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.detailKegiatan,
                        style: const TextStyle(
                          color: HackerColors.text,
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  // Helper method untuk mendapatkan warna berdasarkan jenjang
  Color _getJenjangColor(String jenjang) {
    switch (jenjang) {
      case 'S1':
        return HackerColors.accent;
      case 'S2':
        return HackerColors.primary;
      case 'S3':
        return HackerColors.warning;
      default:
        return HackerColors.text;
    }
  }
  
  // Helper method untuk memformat semester
  String _formatSemester(String semester) {
    if (semester.length != 5) return semester;
    
    final tahun = semester.substring(0, 4);
    final periode = semester.substring(4);
    
    return '$tahun/$periode';
  }
  
  // Helper method untuk mendapatkan warna berdasarkan jenis portofolio
  Color _getColorForPortofolio(String type) {
    switch (type) {
      case 'PENELITIAN':
        return HackerColors.primary;
      case 'PENGABDIAN':
        return HackerColors.accent;
      case 'KARYA':
        return HackerColors.warning;
      case 'PATEN':
        return Colors.deepOrange;
      default:
        return HackerColors.text;
    }
  }
  
  // Helper method untuk mendapatkan icon berdasarkan jenis portofolio
  IconData _getIconForPortofolio(String type) {
    switch (type) {
      case 'PENELITIAN':
        return Icons.science;
      case 'PENGABDIAN':
        return Icons.groups;
      case 'KARYA':
        return Icons.article;
      case 'PATEN':
        return Icons.verified;
      default:
        return Icons.description;
    }
  }
}
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