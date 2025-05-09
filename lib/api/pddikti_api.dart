import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/mahasiswa.dart';
import '../models/dosen.dart';
import '../models/prodi.dart';
import '../models/pt.dart';

class PddiktiApi {
  // Base URL API
  final String baseUrl = 'https://api-pddikti.kemdiktisaintek.go.id';
  
  // Header untuk request
  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Origin': 'https://pddikti.kemdiktisaintek.go.id',
    'Referer': 'https://pddikti.kemdiktisaintek.go.id/',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'Content-Type': 'application/json',
  };

  // Encode parameter URL
  String _parseString(String text) {
    return Uri.encodeComponent(text);
  }

  // Ambil list data aman
  List<dynamic> _safeGetList(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return [];
    if (value is List) return value;
    return [];
  }

  // Proses response API
  Future<Map<String, dynamic>> _processApiResponse(http.Response response, String errorMessage) async {
    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Format data tidak valid: $e');
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
      throw Exception('$errorMessage: ${response.statusCode}');
    }
  }

  // Pencarian mahasiswa
  Future<List<Mahasiswa>> searchMahasiswa(String keyword) async {
    try {
      print('Mencari mahasiswa: $keyword');
      
      final Uri url = Uri.parse('$baseUrl/pencarian/mhs/${_parseString(keyword)}');
      print('URL Request: ${url.toString()}');
      
      // Request dengan timeout
      final response = await http.get(
        url,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Koneksi timeout - Coba lagi nanti');
        },
      );

      print('Status kode: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Cek field mahasiswa
        if (!data.containsKey('mahasiswa')) {
          print('Data mahasiswa tidak ditemukan');
          return [];
        }
        
        // Ambil dan olah data mahasiswa
        final List<dynamic> mhsList = _safeGetList(data, 'mahasiswa');
        print('Ditemukan ${mhsList.length} mahasiswa');
        
        return mhsList.map((item) {
          if (item is! Map<String, dynamic>) {
            return Mahasiswa.fromJson({});
          }
          
          try {
            return Mahasiswa.fromJson(item);
          } catch (e) {
            print('Error: $e');
            return Mahasiswa.fromJson({});
          }
        }).where((m) => m.id.isNotEmpty).toList();
        
      } else {
        throw Exception('Gagal mencari data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet atau coba lagi nanti.');
      } else if (e.toString().contains('Timeout')) {
        throw Exception('Koneksi timeout. Server mungkin sibuk, silakan coba lagi.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Pencarian dosen
  Future<List<Dosen>> searchDosen(String keyword) async {
    try {
      print('Mencari dosen: $keyword');
      
      final Uri url = Uri.parse('$baseUrl/pencarian/dosen/${_parseString(keyword)}');
      
      final response = await http.get(
        url,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Koneksi timeout - Coba lagi nanti');
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = await _processApiResponse(
          response, 
          'Gagal mencari dosen'
        );
        
        if (!data.containsKey('dosen')) {
          return [];
        }
        
        final List<dynamic> dosenList = _safeGetList(data, 'dosen');
        
        return dosenList.map((item) {
          if (item is! Map<String, dynamic>) {
            return Dosen.fromJson({});
          }
          
          try {
            return Dosen.fromJson(item);
          } catch (e) {
            return Dosen.fromJson({});
          }
        }).where((d) => d.id.isNotEmpty).toList();
      } else {
        throw Exception('Gagal mencari dosen: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet atau coba lagi nanti.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Pencarian PT
  Future<List<PerguruanTinggi>> searchPt(String keyword) async {
    try {
      print('Mencari perguruan tinggi: $keyword');
      
      final Uri url = Uri.parse('$baseUrl/pencarian/pt/${_parseString(keyword)}');
      
      final response = await http.get(
        url,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Koneksi timeout - Coba lagi nanti');
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = await _processApiResponse(
          response, 
          'Gagal mencari perguruan tinggi'
        );
        
        if (!data.containsKey('pt')) {
          return [];
        }
        
        final List<dynamic> ptList = _safeGetList(data, 'pt');
        
        return ptList.map((item) {
          if (item is! Map<String, dynamic>) {
            return PerguruanTinggi.fromJson({});
          }
          
          try {
            return PerguruanTinggi.fromJson(item);
          } catch (e) {
            return PerguruanTinggi.fromJson({});
          }
        }).where((pt) => pt.id.isNotEmpty).toList();
      } else {
        throw Exception('Gagal mencari perguruan tinggi: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet atau coba lagi nanti.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Pencarian prodi
  Future<List<Prodi>> searchProdi(String keyword) async {
    try {
      print('Mencari program studi: $keyword');
      
      final Uri url = Uri.parse('$baseUrl/pencarian/prodi/${_parseString(keyword)}');
      
      final response = await http.get(
        url,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Koneksi timeout - Coba lagi nanti');
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = await _processApiResponse(
          response, 
          'Gagal mencari program studi'
        );
        
        if (!data.containsKey('prodi')) {
          return [];
        }
        
        final List<dynamic> prodiList = _safeGetList(data, 'prodi');
        
        return prodiList.map((item) {
          if (item is! Map<String, dynamic>) {
            return Prodi.fromJson({});
          }
          
          try {
            return Prodi.fromJson(item);
          } catch (e) {
            return Prodi.fromJson({});
          }
        }).where((p) => p.id.isNotEmpty).toList();
      } else {
        throw Exception('Gagal mencari program studi: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet atau coba lagi nanti.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Detail mahasiswa
  Future<MahasiswaDetail> getMahasiswaDetail(String mahasiswaId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/detail/mhs/${_parseString(mahasiswaId)}');
      
      final response = await http.get(
        url,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Koneksi timeout - Coba lagi nanti');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (!data.containsKey('mahasiswa')) {
          throw Exception('Data mahasiswa tidak ditemukan');
        }
        
        final List<dynamic> mahasiswaList = _safeGetList(data, 'mahasiswa');
        
        if (mahasiswaList.isEmpty) {
          throw Exception('Detail mahasiswa kosong');
        }
        
        final item = mahasiswaList.first;
        
        if (item is! Map<String, dynamic>) {
          throw Exception('Format data tidak valid');
        }
        
        return MahasiswaDetail.fromJson(item);
      } else {
        throw Exception('Gagal mendapatkan detail: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet atau coba lagi nanti.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Detail dosen
  Future<DosenDetail> getDosenProfile(String dosenId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/dosen/profile/${_parseString(dosenId)}');
      
      final response = await http.get(
        url,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Koneksi timeout - Coba lagi nanti');
        },
      );

      final Map<String, dynamic> data = await _processApiResponse(
        response, 
        'Gagal mendapatkan profil dosen'
      );
      
      if (!data.containsKey('dosen')) {
        throw Exception('Data dosen tidak ditemukan');
      }
      
      final List<dynamic> dosenList = _safeGetList(data, 'dosen');
      
      if (dosenList.isEmpty) {
        throw Exception('Detail dosen kosong');
      }
      
      final item = dosenList.first;
      
      if (item is! Map<String, dynamic>) {
        throw Exception('Format data tidak valid');
      }
      
      return DosenDetail.fromJson(item);
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet atau coba lagi nanti.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Detail perguruan tinggi
  Future<PerguruanTinggiDetail> getDetailPt(String ptId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/pt/detail/${_parseString(ptId)}');
      
      final response = await http.get(
        url,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Koneksi timeout - Coba lagi nanti');
        },
      );

      final Map<String, dynamic> data = await _processApiResponse(
        response, 
        'Gagal mendapatkan detail perguruan tinggi'
      );
      
      if (!data.containsKey('pt')) {
        throw Exception('Data perguruan tinggi tidak ditemukan');
      }
      
      final List<dynamic> ptList = _safeGetList(data, 'pt');
      
      if (ptList.isEmpty) {
        throw Exception('Detail perguruan tinggi kosong');
      }
      
      final item = ptList.first;
      
      if (item is! Map<String, dynamic>) {
        throw Exception('Format data tidak valid');
      }
      
      return PerguruanTinggiDetail.fromJson(item);
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet atau coba lagi nanti.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Detail program studi
  Future<ProdiDetail> getDetailProdi(String prodiId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/prodi/detail/${_parseString(prodiId)}');
      
      final response = await http.get(
        url,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Koneksi timeout - Coba lagi nanti');
        },
      );

      final Map<String, dynamic> data = await _processApiResponse(
        response, 
        'Gagal mendapatkan detail program studi'
      );
      
      if (!data.containsKey('prodi')) {
        throw Exception('Data program studi tidak ditemukan');
      }
      
      final List<dynamic> prodiList = _safeGetList(data, 'prodi');
      
      if (prodiList.isEmpty) {
        throw Exception('Detail program studi kosong');
      }
      
      final item = prodiList.first;
      
      if (item is! Map<String, dynamic>) {
        throw Exception('Format data tidak valid');
      }
      
      // Ambil deskripsi prodi jika tersedia
      Map<String, dynamic>? descJson;
      try {
        final descResponse = await http.get(
          Uri.parse('$baseUrl/prodi/desc/${_parseString(prodiId)}'),
          headers: _headers,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('Timeout mengambil deskripsi prodi');
            return http.Response('{"error": "timeout"}', 408);
          },
        );
        
        if (descResponse.statusCode == 200) {
          final descData = json.decode(descResponse.body);
          if (descData.containsKey('prodi') && 
              descData['prodi'] is List && 
              (descData['prodi'] as List).isNotEmpty &&
              (descData['prodi'] as List).first is Map<String, dynamic>) {
            descJson = (descData['prodi'] as List).first;
          }
        }
      } catch (e) {
        print('Error mendapatkan deskripsi prodi: $e');
      }
      
      return ProdiDetail.fromJson(item, descJson);
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet atau coba lagi nanti.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // List prodi untuk PT tertentu
  Future<List<ProdiPt>> getProdiPt(String ptId, int tahun) async {
    try {
      final Uri url = Uri.parse('$baseUrl/pt/detail/${_parseString(ptId)}/${_parseString(tahun.toString())}');
      
      final response = await http.get(
        url,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Koneksi timeout - Coba lagi nanti');
        },
      );

      final Map<String, dynamic> data = await _processApiResponse(
        response, 
        'Gagal mendapatkan daftar program studi'
      );
      
      if (!data.containsKey('prodi')) {
        return [];
      }
      
      final List<dynamic> prodiList = _safeGetList(data, 'prodi');
      
      return prodiList.map((item) {
        if (item is! Map<String, dynamic>) {
          return ProdiPt.fromJson({});
        }
        
        try {
          return ProdiPt.fromJson(item);
        } catch (e) {
          return ProdiPt.fromJson({});
        }
      }).where((p) => p.idSms.isNotEmpty).toList();
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet atau coba lagi nanti.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Pencarian semua entitas
  Future<Map<String, dynamic>> searchAll(String keyword) async {
    try {
      final Uri url = Uri.parse('$baseUrl/pencarian/all/${_parseString(keyword)}');
      
      final response = await http.get(
        url,
        headers: _headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Koneksi timeout - Coba lagi nanti');
        },
      );

      return await _processApiResponse(response, 'Gagal mencari data');
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('Gagal terhubung ke server. Periksa koneksi internet atau coba lagi nanti.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Helper untuk limit string
  int min(int a, int b) {
    return (a < b) ? a : b;
  }
}