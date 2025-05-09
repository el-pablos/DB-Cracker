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
    // In web environments, we might want to use mock data to avoid CORS issues
    // Also use mock if it's explicitly forced
    return _forceMock || (kIsWeb && !kDebugMode);
  }
  
  /// Pencarian mahasiswa
  Future<List<Mahasiswa>> searchMahasiswa(String keyword) async {
    if (_useMockData) {
      return _mockService.searchMahasiswa(keyword);
    } else {
      try {
        return await _realApi.searchMahasiswa(keyword);
      } catch (e) {
        print('Error with real API, fallback to mock: $e');
        // Fallback to mock data if the real API fails with specific errors
        if (e.toString().contains('403') || 
            e.toString().contains('CORS') ||
            e.toString().contains('XMLHttpRequest')) {
          return _mockService.searchMahasiswa(keyword);
        }
        rethrow;
      }
    }
  }
  
/// Detail mahasiswa
  Future<MahasiswaDetail> getMahasiswaDetail(String mahasiswaId) async {
    if (_useMockData) {
      return _mockService.getMahasiswaDetail(mahasiswaId);
    } else {
      try {
        print('Requesting mahasiswa detail from real API for id: $mahasiswaId');
        return await _realApi.getMahasiswaDetail(mahasiswaId);
      } catch (e) {
        print('Error with real API, fallback to mock: $e');
        
        // Always fallback to mock on detail errors to ensure the UI can show something
        try {
          return _mockService.getMahasiswaDetail(mahasiswaId);
        } catch (mockError) {
          print('Error with mock service too: $mockError');
          
          // If even the mock service fails, create a minimal valid object
          return MahasiswaDetail(
            id: mahasiswaId,
            namaPt: 'Data tidak tersedia',
            kodePt: '-',
            kodeProdi: '-',
            prodi: 'Data tidak tersedia',
            nama: 'Data tidak tersedia (error)',
            nim: '-',
            jenisDaftar: '-',
            idPt: '-',
            idSms: '-',
            jenisKelamin: '-',
            jenjang: '-',
            statusSaatIni: '-',
            tahunMasuk: '-',
          );
        }
      }
    }
  }
  
  /// Pencarian dosen
  Future<List<Dosen>> searchDosen(String keyword) async {
    if (_useMockData) {
      return _mockService.searchDosen(keyword);
    } else {
      try {
        return await _realApi.searchDosen(keyword);
      } catch (e) {
        print('Error with real API, fallback to mock: $e');
        // Fallback to mock data if the real API fails with specific errors
        if (e.toString().contains('403') || 
            e.toString().contains('CORS') ||
            e.toString().contains('XMLHttpRequest')) {
          return _mockService.searchDosen(keyword);
        }
        rethrow;
      }
    }
  }
  
  // Tambahkan method lain sesuai kebutuhan, dengan pola yang sama
}