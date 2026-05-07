import 'package:flutter/foundation.dart';
import 'pddikti_api.dart';
import '../services/mock_pddikti_service.dart';
import '../models/mahasiswa.dart';
import '../models/dosen.dart';
import '../models/prodi.dart';
import '../models/pt.dart';

/// Factory class to provide the appropriate API implementation
/// This handles the switching between real API and mock data based on environment
class ApiFactory {
  /// Singleton instance
  static final ApiFactory _instance = ApiFactory._internal();

  /// Private constructor
  ApiFactory._internal();

  /// Factory constructor
  factory ApiFactory() {
    return _instance;
  }

  /// Real API instance
  final PddiktiApi _realApi = PddiktiApi();

  /// Mock API instance for web
  final MockPddiktiService _mockService = MockPddiktiService();

  /// Flag to force use of mock data
  bool _forceMock = false;

  /// Enable mock data for testing
  void enableMockData() {
    _forceMock = true;
  }

  /// Disable mock data
  void disableMockData() {
    _forceMock = false;
  }

  /// Should use mock data?
  bool get _useMockData {
    // Prioritaskan API asli, hanya gunakan mock jika dipaksa
    // Untuk web production, tetap coba API asli dulu
    final shouldUseMock = _forceMock;
    if (kDebugMode) debugPrint(
        'ApiFactory._useMockData: $shouldUseMock (forceMock: $_forceMock, kIsWeb: $kIsWeb, kDebugMode: $kDebugMode)');
    return shouldUseMock;
  }

  /// Pencarian mahasiswa
  Future<List<Mahasiswa>> searchMahasiswa(String keyword) async {
    if (kDebugMode) debugPrint(
        'ApiFactory.searchMahasiswa: keyword="$keyword", useMockData=$_useMockData');

    if (_useMockData) {
      if (kDebugMode) debugPrint('ApiFactory.searchMahasiswa: Using mock service');
      final results = await _mockService.searchMahasiswa(keyword);
      if (kDebugMode) debugPrint(
          'ApiFactory.searchMahasiswa: Mock service returned ${results.length} results');
      return results;
    } else {
      try {
        if (kDebugMode) debugPrint('ApiFactory.searchMahasiswa: Using real API');
        final results = await _realApi.searchMahasiswa(keyword);
        if (kDebugMode) debugPrint(
            'ApiFactory.searchMahasiswa: Real API returned ${results.length} results');
        return results;
      } catch (e) {
        if (kDebugMode) debugPrint('Error with real API: $e');
        // FACTORY-FIX: Tidak fallback ke mock diam-diam di production
        // Mock hanya boleh aktif jika _forceMock == true (eksplisit)
        // User harus lihat error state, bukan data palsu
        rethrow;
      }
    }
  }

  /// Detail mahasiswa (basic)
  Future<MahasiswaDetail> getMahasiswaDetail(String mahasiswaId) async {
    if (_useMockData) {
      return _mockService.getMahasiswaDetail(mahasiswaId);
    } else {
      try {
        if (kDebugMode) debugPrint('Requesting mahasiswa detail from real API for id: $mahasiswaId');
        return await _realApi.getMahasiswaDetail(mahasiswaId);
      } catch (e) {
        if (kDebugMode) debugPrint('Error with real API: $e');
        // FACTORY-FIX: Tidak fallback ke mock diam-diam — user harus lihat error state
        rethrow;
      }
    }
  }

  /// Detail mahasiswa lengkap (termasuk riwayat semester, nilai, kelas)
  Future<MahasiswaDetail> getMahasiswaDetailLengkap(String mahasiswaId) async {
    if (_useMockData) {
      return _mockService.getMahasiswaDetail(mahasiswaId);
    } else {
      try {
        if (kDebugMode) debugPrint('Requesting mahasiswa detail lengkap from real API for id: $mahasiswaId');
        return await _realApi.getMahasiswaDetailLengkap(mahasiswaId);
      } catch (e) {
        if (kDebugMode) debugPrint('Error with real API lengkap: $e');
        rethrow;
      }
    }
  }

  /// Pencarian dosen
  Future<List<Dosen>> searchDosen(String keyword) async {
    if (kDebugMode) debugPrint(
        'ApiFactory.searchDosen: keyword="$keyword", useMockData=$_useMockData');

    if (_useMockData) {
      if (kDebugMode) debugPrint('ApiFactory.searchDosen: Using mock service');
      final results = await _mockService.searchDosen(keyword);
      if (kDebugMode) debugPrint(
          'ApiFactory.searchDosen: Mock service returned ${results.length} results');
      for (int i = 0; i < results.length && i < 3; i++) {
        if (kDebugMode) debugPrint(
            'ApiFactory.searchDosen: Mock result $i: ${results[i].nama} (${results[i].nidn})');
      }
      return results;
    } else {
      try {
        if (kDebugMode) debugPrint('ApiFactory.searchDosen: Using real API');
        final results = await _realApi.searchDosen(keyword);
        if (kDebugMode) debugPrint(
            'ApiFactory.searchDosen: Real API returned ${results.length} results');
        for (int i = 0; i < results.length && i < 3; i++) {
          if (kDebugMode) debugPrint(
              'ApiFactory.searchDosen: Real result $i: ${results[i].nama} (${results[i].nidn})');
        }
        return results;
      } catch (e) {
        if (kDebugMode) debugPrint('Error with real API, fallback to mock: $e');
        // Fallback to mock data if the real API fails with specific errors
        if (e.toString().contains('403') ||
            e.toString().contains('CORS') ||
            e.toString().contains('XMLHttpRequest')) {
          if (kDebugMode) debugPrint(
              'ApiFactory.searchDosen: Fallback to mock service due to API error');
          final results = await _mockService.searchDosen(keyword);
          if (kDebugMode) debugPrint(
              'ApiFactory.searchDosen: Mock fallback returned ${results.length} results');
          return results;
        }
        rethrow;
      }
    }
  }

  /// Pencarian program studi
  Future<List<Prodi>> searchProdi(String keyword) async {
    if (_useMockData) {
      // Implementasi mock untuk prodi jika diperlukan
      return [];
    } else {
      try {
        return await _realApi.searchProdi(keyword);
      } catch (e) {
        if (kDebugMode) debugPrint('Error with real API, fallback to mock: $e');
        // Fallback to mock data if the real API fails with specific errors
        if (e.toString().contains('403') ||
            e.toString().contains('CORS') ||
            e.toString().contains('XMLHttpRequest')) {
          // Implementasi mock untuk prodi jika diperlukan
          return [];
        }
        rethrow;
      }
    }
  }

  /// Pencarian perguruan tinggi
  Future<List<PerguruanTinggi>> searchPt(String keyword) async {
    if (_useMockData) {
      // Implementasi mock untuk PT jika diperlukan
      return [];
    } else {
      try {
        return await _realApi.searchPt(keyword);
      } catch (e) {
        if (kDebugMode) debugPrint('Error with real API, fallback to mock: $e');
        // Fallback to mock data if the real API fails with specific errors
        if (e.toString().contains('403') ||
            e.toString().contains('CORS') ||
            e.toString().contains('XMLHttpRequest')) {
          // Implementasi mock untuk PT jika diperlukan
          return [];
        }
        rethrow;
      }
    }
  }

  /// Mendapatkan detail program studi
  Future<ProdiDetail> getDetailProdi(String prodiId) async {
    if (_useMockData) {
      // Implementasi mock untuk detail prodi jika diperlukan
      return ProdiDetail(
        idSp: '',
        idSms: prodiId,
        namaPt: 'Perguruan Tinggi (Mock)',
        kodePt: 'PT001',
        namaProdi: 'Program Studi (Mock)',
        kodeProdi: 'PS001',
        kelBidang: 'Teknologi',
        jenjangDidik: 'S1',
        tglBerdiri: '2000-01-01',
        tglSkSelenggara: '2000-01-01',
        skSelenggara: 'SK/001/2000',
        noTel: '021-1234567',
        noFax: '021-7654321',
        website: 'www.example.com',
        email: 'info@example.com',
        alamat: 'Jl. Contoh No. 123',
        provinsi: 'DKI Jakarta',
        kabKota: 'Jakarta Pusat',
        kecamatan: 'Menteng',
        lintang: '-6.2088',
        bujur: '106.8456',
        status: 'Aktif',
        akreditasi: 'A',
        akreditasiInternasional: '',
        statusAkreditasi: 'Aktif',
        deskripsiSingkat: 'Ini adalah program studi contoh',
        visi: 'Menjadi program studi terbaik',
        misi: 'Menghasilkan lulusan berkualitas',
        kompetensi: 'Memiliki kemampuan di bidang teknologi',
        capaianBelajar: 'Lulusan mampu bekerja di berbagai sektor',
        rataMasaStudi: '4',
      );
    } else {
      try {
        return await _realApi.getDetailProdi(prodiId);
      } catch (e) {
        if (kDebugMode) debugPrint('Error with real API, fallback to mock: $e');

        // Fallback to mock data
        return ProdiDetail(
          idSp: '',
          idSms: prodiId,
          namaPt: 'Perguruan Tinggi (Mock)',
          kodePt: 'PT001',
          namaProdi: 'Program Studi (Mock)',
          kodeProdi: 'PS001',
          kelBidang: 'Teknologi',
          jenjangDidik: 'S1',
          tglBerdiri: '2000-01-01',
          tglSkSelenggara: '2000-01-01',
          skSelenggara: 'SK/001/2000',
          noTel: '021-1234567',
          noFax: '021-7654321',
          website: 'www.example.com',
          email: 'info@example.com',
          alamat: 'Jl. Contoh No. 123',
          provinsi: 'DKI Jakarta',
          kabKota: 'Jakarta Pusat',
          kecamatan: 'Menteng',
          lintang: '-6.2088',
          bujur: '106.8456',
          status: 'Aktif',
          akreditasi: 'A',
          akreditasiInternasional: '',
          statusAkreditasi: 'Aktif',
          deskripsiSingkat: 'Ini adalah program studi contoh',
          visi: 'Menjadi program studi terbaik',
          misi: 'Menghasilkan lulusan berkualitas',
          kompetensi: 'Memiliki kemampuan di bidang teknologi',
          capaianBelajar: 'Lulusan mampu bekerja di berbagai sektor',
          rataMasaStudi: '4',
        );
      }
    }
  }

  /// Mendapatkan detail perguruan tinggi
  Future<PerguruanTinggiDetail> getDetailPt(String ptId) async {
    if (_useMockData) {
      // Implementasi mock untuk detail PT jika diperlukan
      return PerguruanTinggiDetail(
        kelompok: 'Universitas',
        pembina: 'Kementerian Pendidikan',
        idSp: ptId,
        kodePt: 'PT001',
        email: 'info@example.com',
        noTel: '021-1234567',
        noFax: '021-7654321',
        website: 'www.example.com',
        alamat: 'Jl. Contoh No. 123',
        namaPt: 'Universitas Contoh (Mock)',
        nmSingkat: 'UNCON',
        kodePos: '12345',
        provinsiPt: 'DKI Jakarta',
        kabKotaPt: 'Jakarta Pusat',
        kecamatanPt: 'Menteng',
        lintangPt: '-6.2088',
        bujurPt: '106.8456',
        tglBerdiriPt: '1990-01-01',
        tglSkPendirianSp: '1990-01-01',
        skPendirianSp: 'SK/001/1990',
        statusPt: 'Aktif',
        akreditasiPt: 'A',
        statusAkreditasi: 'Aktif',
      );
    } else {
      try {
        return await _realApi.getDetailPt(ptId);
      } catch (e) {
        if (kDebugMode) debugPrint('Error with real API, fallback to mock: $e');

        // Fallback to mock data
        return PerguruanTinggiDetail(
          kelompok: 'Universitas',
          pembina: 'Kementerian Pendidikan',
          idSp: ptId,
          kodePt: 'PT001',
          email: 'info@example.com',
          noTel: '021-1234567',
          noFax: '021-7654321',
          website: 'www.example.com',
          alamat: 'Jl. Contoh No. 123',
          namaPt: 'Universitas Contoh (Mock)',
          nmSingkat: 'UNCON',
          kodePos: '12345',
          provinsiPt: 'DKI Jakarta',
          kabKotaPt: 'Jakarta Pusat',
          kecamatanPt: 'Menteng',
          lintangPt: '-6.2088',
          bujurPt: '106.8456',
          tglBerdiriPt: '1990-01-01',
          tglSkPendirianSp: '1990-01-01',
          skPendirianSp: 'SK/001/1990',
          statusPt: 'Aktif',
          akreditasiPt: 'A',
          statusAkreditasi: 'Aktif',
        );
      }
    }
  }

  /// Mendapatkan daftar program studi di perguruan tinggi
  Future<List<ProdiPt>> getProdiPt(String ptId, int tahun) async {
    if (_useMockData) {
      // Implementasi mock untuk daftar prodi di PT jika diperlukan
      return [];
    } else {
      try {
        return await _realApi.getProdiPt(ptId, tahun);
      } catch (e) {
        if (kDebugMode) debugPrint('Error with real API, fallback to mock: $e');
        // Fallback to mock data if the real API fails with specific errors
        if (e.toString().contains('403') ||
            e.toString().contains('CORS') ||
            e.toString().contains('XMLHttpRequest')) {
          // Implementasi mock untuk daftar prodi di PT jika diperlukan
          return [];
        }
        rethrow;
      }
    }
  }

  /// Getter untuk mendapatkan MockPddiktiService
  MockPddiktiService getMockService() {
    return _mockService;
  }

  /// Mencari dosen dan mendapatkan detail dosen
  Future<DosenDetail> getDosenProfile(String dosenId) async {
    if (_useMockData) {
      // Gunakan mock service untuk testing
      try {
        return await _mockService.getDosenProfile(dosenId);
      } catch (e) {
        if (kDebugMode) debugPrint('Error dengan mock service: $e');
        rethrow;
      }
    } else {
      try {
        if (kDebugMode) debugPrint('Meminta profil dosen dari API asli untuk id: $dosenId');
        return await _realApi.getDosenProfile(dosenId);
      } catch (e) {
        if (kDebugMode) debugPrint('Error dengan API asli, fallback ke mock: $e');

        // Fallback ke mock data
        // FACTORY-FIX: Tidak fallback ke mock — rethrow agar UI tampilkan error
        rethrow;
      }
    }
  }

  /// Mendapatkan detail lengkap dosen dengan semua data
  Future<DosenDetail> getDosenDetailLengkap(String dosenId) async {
    if (_useMockData) {
      // Gunakan mock service untuk testing
      try {
        return await _mockService.getDosenProfile(dosenId);
      } catch (e) {
        if (kDebugMode) debugPrint('Error dengan mock service: $e');
        rethrow;
      }
    } else {
      try {
        if (kDebugMode) debugPrint('Meminta detail lengkap dosen dari API asli untuk id: $dosenId');
        return await _realApi.getDosenDetailLengkap(dosenId);
      } catch (e) {
        if (kDebugMode) debugPrint('Error dengan API asli: $e');
        // FACTORY-FIX: Tidak fallback ke mock — user harus lihat error state
        rethrow;
      }
    }
  }
}
