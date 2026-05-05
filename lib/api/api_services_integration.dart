// lib/api/api_services_integration.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/mahasiswa.dart';
import '../models/dosen.dart';

/// Class untuk mengintegrasikan berbagai API publik terkait pendidikan dari Indonesia
class ApiServicesIntegration {
  /// Singleton instance
  static final ApiServicesIntegration _instance = ApiServicesIntegration._internal();
  
  /// Private constructor
  ApiServicesIntegration._internal();
  
  /// Factory constructor
  factory ApiServicesIntegration() {
    return _instance;
  }
  
  /// Header untuk request
  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'User-Agent': 'DB-Cracker-App/1.0',
  };
  
  /// API Pencarian Data Pendidikan
  /// BUG-H4 FIX: GitHub API endpoint removed — it returned repo file listings,
  /// NOT actual education data. The keyword was never used in the request URL.
  /// This was a dead network call adding 10s latency with zero useful results.
  Future<List<Map<String, dynamic>>> searchEducationData(String keyword) async {
    // No valid external education API endpoints available currently.
    // PDDIKTI is the primary source, handled by PddiktiApi directly.
    // This method kept for interface compatibility with MultiApiFactory.
    return [];
  }
  
  /// Mencari data dari Wikipedia API
  Future<Map<String, dynamic>> searchWikipedia(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('https://id.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(keyword)}'),
        headers: _headers,
      ).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      return {};
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching from Wikipedia: $e');
      return {};
    }
  }
  
  /// Convert data ke model Mahasiswa jika memungkinkan
  List<Mahasiswa> convertToMahasiswa(List<Map<String, dynamic>> data) {
    return data.map((item) {
      return Mahasiswa(
        id: item['id'] ?? item['mahasiswa_id'] ?? item['ID'] ?? '',
        nama: item['nama'] ?? item['name'] ?? item['nama_mahasiswa'] ?? '',
        nim: item['nim'] ?? item['nomor_induk'] ?? item['no_mahasiswa'] ?? '',
        namaPt: item['perguruan_tinggi'] ?? item['universitas'] ?? item['kampus'] ?? '',
        singkatanPt: item['singkatan_pt'] ?? item['kode_pt'] ?? '',
        namaProdi: item['program_studi'] ?? item['jurusan'] ?? item['prodi'] ?? '',
      );
    }).where((m) => m.nama.isNotEmpty && m.nim.isNotEmpty).toList();
  }
  
  /// Convert data ke model Dosen jika memungkinkan
  List<Dosen> convertToDosen(List<Map<String, dynamic>> data) {
    return data.map((item) {
      return Dosen(
        id: item['id'] ?? item['dosen_id'] ?? item['ID'] ?? '',
        nama: item['nama'] ?? item['name'] ?? item['nama_dosen'] ?? '',
        nidn: item['nidn'] ?? item['nomor_induk'] ?? '',
        namaPt: item['perguruan_tinggi'] ?? item['universitas'] ?? item['kampus'] ?? '',
        singkatanPt: item['singkatan_pt'] ?? item['kode_pt'] ?? '',
        namaProdi: item['program_studi'] ?? item['jurusan'] ?? item['prodi'] ?? '',
      );
    }).where((d) => d.nama.isNotEmpty && d.nidn.isNotEmpty).toList();
  }
}
