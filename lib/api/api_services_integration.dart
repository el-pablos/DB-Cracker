// lib/api/api_services_integration.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mahasiswa.dart';
import '../models/dosen.dart';
import '../models/prodi.dart';
import '../models/pt.dart';

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
  
  /// API Pencarian Data Pendidikan (dari open API collection)
  Future<List<Map<String, dynamic>>> searchEducationData(String keyword) async {
    try {
      // List of education APIs to search
      final List<String> apiEndpoints = [
        'https://api.github.com/repos/IlhamriSKY/PDDIKTI-kemdikbud-API/contents/data', // Python 3 API wrapper PDDIKTI
        'https://animeapi.my.id/api/v1/anime/search?q=$keyword', // Menampilkan data anime (contoh API lain)
        'https://api.nashta.co.id/education/search?q=$keyword', // Contoh endpoint fiktif
      ];
      
      List<Map<String, dynamic>> results = [];
      
      for (var endpoint in apiEndpoints) {
        try {
          final response = await http.get(
            Uri.parse(endpoint),
            headers: _headers,
          ).timeout(
            Duration(seconds: 10),
          );
          
          if (response.statusCode == 200) {
            final dynamic data = jsonDecode(response.body);
            
            if (data is Map<String, dynamic>) {
              if (data.containsKey('results') && data['results'] is List) {
                for (var item in data['results']) {
                  if (item is Map<String, dynamic>) {
                    results.add(item);
                  }
                }
              } else if (data.containsKey('data') && data['data'] is List) {
                for (var item in data['data']) {
                  if (item is Map<String, dynamic>) {
                    results.add(item);
                  }
                }
              } else {
                // Add the whole data as an item if it doesn't follow expected structure
                results.add(data);
              }
            } else if (data is List) {
              for (var item in data) {
                if (item is Map<String, dynamic>) {
                  results.add(item);
                }
              }
            }
          }
        } catch (e) {
          print('Error searching from $endpoint: $e');
          // Continue to next API
        }
      }
      
      return results;
    } catch (e) {
      print('Error in education search: $e');
      return [];
    }
  }
  
  /// Mencari data dari Dayoff API (hari libur nasional)
  Future<List<Map<String, dynamic>>> searchNationalHolidays() async {
    try {
      final response = await http.get(
        Uri.parse('https://dayoffapi.vercel.app/api'),
        headers: _headers,
      ).timeout(
        Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map<String, dynamic> && data.containsKey('data') && data['data'] is List) {
          final List holidaysList = data['data'] as List;
          
          return holidaysList.map((item) {
            if (item is Map<String, dynamic>) {
              return item;
            }
            return <String, dynamic>{};
          }).toList();
        }
      }
      
      return [];
    } catch (e) {
      print('Error fetching holidays: $e');
      return [];
    }
  }
  
  /// Mencari data dari Indonesian Geographical Data API (Wilayah Indonesia)
  Future<List<Map<String, dynamic>>> searchGeographicalData(String province) async {
    try {
      final response = await http.get(
        Uri.parse('https://ibnux.github.io/data-indonesia/propinsi/$province.json'),
        headers: _headers,
      ).timeout(
        Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        
        return data.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          }
          return <String, dynamic>{};
        }).toList();
      }
      
      return [];
    } catch (e) {
      print('Error fetching geographical data: $e');
      return [];
    }
  }
  
  /// Mencari data dari Wikipedia API
  Future<Map<String, dynamic>> searchWikipedia(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('https://id.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(keyword)}'),
        headers: _headers,
      ).timeout(
        Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      
      return {};
    } catch (e) {
      print('Error fetching from Wikipedia: $e');
      return {};
    }
  }
  
  /// Convert data ke model Mahasiswa jika memungkinkan
  List<Mahasiswa> convertToMahasiswa(List<Map<String, dynamic>> data) {
    return data.map((item) {
      // Try to extract fields that might represent student data
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