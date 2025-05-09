import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mahasiswa.dart';
import '../models/dosen.dart';
import '../models/prodi.dart';
import '../models/pt.dart';

class PddiktiApi {
  // Base URL for the API
  final String baseUrl = 'https://api-pddikti.kemdiktisaintek.go.id';
  
  // Headers to mimic the browser request
  Map<String, String> get _headers => {
    'Accept': 'application/json, text/plain, */*',
    'Accept-Encoding': 'gzip, deflate, br, zstd',
    'Accept-Language': 'en-US,en;q=0.9,mt;q=0.8',
    'Connection': 'keep-alive',
    'DNT': '1',
    'Host': 'api-pddikti.kemdiktisaintek.go.id',
    'Origin': 'https://pddikti.kemdiktisaintek.go.id',
    'Referer': 'https://pddikti.kemdiktisaintek.go.id/',
    'Sec-Fetch-Dest': 'empty',
    'Sec-Fetch-Mode': 'cors',
    'Sec-Fetch-Site': 'same-site',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0',
    'X-User-IP': '103.47.132.29', // This should be dynamic in a real app
    'sec-ch-ua': '"Microsoft Edge";v="131", "Chromium";v="131", "Not_A Brand";v="24"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"'
  };

  // Helper method to parse strings for URL
  String _parseString(String text) {
    return Uri.encodeComponent(text);
  }

  // Fungsi aman untuk mengambil list dari JSON
  List<dynamic> _safeGetList(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return [];
    if (value is List) return value;
    return []; // Return list kosong jika bukan list
  }

  // Helper method untuk mengecek respons API
  Future<Map<String, dynamic>> _processApiResponse(http.Response response, String errorMessage) async {
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        return data;
      } catch (e) {
        print('Error parsing JSON: $e');
        print('Response body: ${response.body.substring(0, min(200, response.body.length))}...');
        throw Exception('Error parsing JSON: $e');
      }
    } else {
      throw Exception('$errorMessage: ${response.statusCode}');
    }
  }

  // Search for all entities (mahasiswa, dosen, pt, prodi)
  Future<Map<String, dynamic>> searchAll(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pencarian/all/${_parseString(keyword)}'),
        headers: _headers,
      );

      return await _processApiResponse(response, 'Gagal mencari data');
    } catch (e) {
      print('Error dalam searchAll: $e');
      throw Exception('Error mencari semua data: $e');
    }
  }

  // Search specifically for students
  Future<List<Mahasiswa>> searchMahasiswa(String keyword) async {
    try {
      print('Mencari mahasiswa: $keyword');
      
      final response = await http.get(
        Uri.parse('$baseUrl/pencarian/mhs/${_parseString(keyword)}'),
        headers: _headers,
      );

      print('Status kode response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final String jsonString = response.body;
        
        try {
          // Coba parse JSON
          final Map<String, dynamic> data = json.decode(jsonString);
          
          // Periksa apakah field 'mahasiswa' ada dan berupa list
          if (!data.containsKey('mahasiswa')) {
            print('Tidak ada field mahasiswa dalam respons');
            return [];
          }
          
          // Dapatkan list mahasiswa dengan aman
          final List<dynamic> mahasiswaList = _safeGetList(data, 'mahasiswa');
          print('Ditemukan ${mahasiswaList.length} record mahasiswa');
          
          // Konversi setiap item ke objek Mahasiswa
          return mahasiswaList.map((item) {
            if (item is! Map<String, dynamic>) {
              print('Item bukan Map: $item');
              // Buat Map kosong untuk menghindari error
              return Mahasiswa.fromJson({});
            }
            
            try {
              return Mahasiswa.fromJson(item);
            } catch (e) {
              print('Error membuat objek Mahasiswa: $e');
              print('Data item: $item');
              // Return objek kosong daripada melempar error
              return Mahasiswa.fromJson({});
            }
          }).where((m) => m.id.isNotEmpty).toList(); // Filter objek kosong
          
        } catch (e) {
          print('Error parsing JSON: $e');
          print('Raw JSON: ${jsonString.substring(0, min(200, jsonString.length))}...');
          throw Exception('Error parsing JSON: $e');
        }
      } else {
        throw Exception('Gagal mencari mahasiswa: ${response.statusCode}');
      }
    } catch (e) {
      print('Error dalam searchMahasiswa: $e');
      throw Exception('Error mencari mahasiswa: $e');
    }
  }

  // Search specifically for lecturers
  Future<List<Dosen>> searchDosen(String keyword) async {
    try {
      print('Mencari dosen: $keyword');
      
      final response = await http.get(
        Uri.parse('$baseUrl/pencarian/dosen/${_parseString(keyword)}'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = await _processApiResponse(
          response, 
          'Gagal mencari dosen'
        );
        
        if (!data.containsKey('dosen')) {
          print('Tidak ada field dosen dalam respons');
          return [];
        }
        
        final List<dynamic> dosenList = _safeGetList(data, 'dosen');
        print('Ditemukan ${dosenList.length} record dosen');
        
        return dosenList.map((item) {
          if (item is! Map<String, dynamic>) {
            print('Item bukan Map: $item');
            return Dosen.fromJson({});
          }
          
          try {
            return Dosen.fromJson(item);
          } catch (e) {
            print('Error membuat objek Dosen: $e');
            return Dosen.fromJson({});
          }
        }).where((d) => d.id.isNotEmpty).toList();
      } else {
        throw Exception('Gagal mencari dosen: ${response.statusCode}');
      }
    } catch (e) {
      print('Error dalam searchDosen: $e');
      throw Exception('Error mencari dosen: $e');
    }
  }

  // Search specifically for universities
  Future<List<PerguruanTinggi>> searchPt(String keyword) async {
    try {
      print('Mencari perguruan tinggi: $keyword');
      
      final response = await http.get(
        Uri.parse('$baseUrl/pencarian/pt/${_parseString(keyword)}'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = await _processApiResponse(
          response, 
          'Gagal mencari perguruan tinggi'
        );
        
        if (!data.containsKey('pt')) {
          print('Tidak ada field pt dalam respons');
          return [];
        }
        
        final List<dynamic> ptList = _safeGetList(data, 'pt');
        print('Ditemukan ${ptList.length} record perguruan tinggi');
        
        return ptList.map((item) {
          if (item is! Map<String, dynamic>) {
            print('Item bukan Map: $item');
            return PerguruanTinggi.fromJson({});
          }
          
          try {
            return PerguruanTinggi.fromJson(item);
          } catch (e) {
            print('Error membuat objek PerguruanTinggi: $e');
            return PerguruanTinggi.fromJson({});
          }
        }).where((pt) => pt.id.isNotEmpty).toList();
      } else {
        throw Exception('Gagal mencari perguruan tinggi: ${response.statusCode}');
      }
    } catch (e) {
      print('Error dalam searchPt: $e');
      throw Exception('Error mencari perguruan tinggi: $e');
    }
  }

  // Search specifically for study programs
  Future<List<Prodi>> searchProdi(String keyword) async {
    try {
      print('Mencari program studi: $keyword');
      
      final response = await http.get(
        Uri.parse('$baseUrl/pencarian/prodi/${_parseString(keyword)}'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = await _processApiResponse(
          response, 
          'Gagal mencari program studi'
        );
        
        if (!data.containsKey('prodi')) {
          print('Tidak ada field prodi dalam respons');
          return [];
        }
        
        final List<dynamic> prodiList = _safeGetList(data, 'prodi');
        print('Ditemukan ${prodiList.length} record program studi');
        
        return prodiList.map((item) {
          if (item is! Map<String, dynamic>) {
            print('Item bukan Map: $item');
            return Prodi.fromJson({});
          }
          
          try {
            return Prodi.fromJson(item);
          } catch (e) {
            print('Error membuat objek Prodi: $e');
            return Prodi.fromJson({});
          }
        }).where((p) => p.id.isNotEmpty).toList();
      } else {
        throw Exception('Gagal mencari program studi: ${response.statusCode}');
      }
    } catch (e) {
      print('Error dalam searchProdi: $e');
      throw Exception('Error mencari program studi: $e');
    }
  }

  // Get detailed information about a specific student
  Future<MahasiswaDetail> getMahasiswaDetail(String mahasiswaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/detail/mhs/${_parseString(mahasiswaId)}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Periksa apakah field 'mahasiswa' ada
        if (!data.containsKey('mahasiswa')) {
          throw Exception('Data mahasiswa tidak ditemukan');
        }
        
        // Dapatkan list mahasiswa dengan aman
        final List<dynamic> mahasiswaList = _safeGetList(data, 'mahasiswa');
        
        if (mahasiswaList.isEmpty) {
          throw Exception('Detail mahasiswa kosong');
        }
        
        // Ambil item pertama dari list
        final item = mahasiswaList.first;
        
        if (item is! Map<String, dynamic>) {
          throw Exception('Format data mahasiswa tidak valid');
        }
        
        return MahasiswaDetail.fromJson(item);
      } else {
        throw Exception('Gagal mendapatkan detail mahasiswa: ${response.statusCode}');
      }
    } catch (e) {
      print('Error dalam getMahasiswaDetail: $e');
      throw Exception('Error mendapatkan detail mahasiswa: $e');
    }
  }

  // Get detailed information about a specific lecturer
  Future<DosenDetail> getDosenProfile(String dosenId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dosen/profile/${_parseString(dosenId)}'),
        headers: _headers,
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
        throw Exception('Format data dosen tidak valid');
      }
      
      return DosenDetail.fromJson(item);
    } catch (e) {
      print('Error dalam getDosenProfile: $e');
      throw Exception('Error mendapatkan profil dosen: $e');
    }
  }

  // Get detailed information about a specific university
  Future<PerguruanTinggiDetail> getDetailPt(String ptId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pt/detail/${_parseString(ptId)}'),
        headers: _headers,
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
        throw Exception('Format data perguruan tinggi tidak valid');
      }
      
      return PerguruanTinggiDetail.fromJson(item);
    } catch (e) {
      print('Error dalam getDetailPt: $e');
      throw Exception('Error mendapatkan detail perguruan tinggi: $e');
    }
  }

  // Get detailed information about a specific study program
  Future<ProdiDetail> getDetailProdi(String prodiId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prodi/detail/${_parseString(prodiId)}'),
        headers: _headers,
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
        throw Exception('Format data program studi tidak valid');
      }
      
      // Coba ambil deskripsi prodi
      Map<String, dynamic>? descJson;
      try {
        final descResponse = await http.get(
          Uri.parse('$baseUrl/prodi/desc/${_parseString(prodiId)}'),
          headers: _headers,
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
        // Lanjutkan meskipun gagal mendapatkan deskripsi
      }
      
      return ProdiDetail.fromJson(item, descJson);
    } catch (e) {
      print('Error dalam getDetailProdi: $e');
      throw Exception('Error mendapatkan detail program studi: $e');
    }
  }

  // Get list of study programs for a specific university
  Future<List<ProdiPt>> getProdiPt(String ptId, int tahun) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pt/detail/${_parseString(ptId)}/${_parseString(tahun.toString())}'),
        headers: _headers,
      );

      final Map<String, dynamic> data = await _processApiResponse(
        response, 
        'Gagal mendapatkan daftar program studi'
      );
      
      if (!data.containsKey('prodi')) {
        print('Tidak ada field prodi dalam respons');
        return [];
      }
      
      final List<dynamic> prodiList = _safeGetList(data, 'prodi');
      print('Ditemukan ${prodiList.length} program studi');
      
      return prodiList.map((item) {
        if (item is! Map<String, dynamic>) {
          print('Item bukan Map: $item');
          return ProdiPt.fromJson({});
        }
        
        try {
          return ProdiPt.fromJson(item);
        } catch (e) {
          print('Error membuat objek ProdiPt: $e');
          return ProdiPt.fromJson({});
        }
      }).where((p) => p.idSms.isNotEmpty).toList();
    } catch (e) {
      print('Error dalam getProdiPt: $e');
      throw Exception('Error mendapatkan daftar program studi: $e');
    }
  }

  // Helper function to limit string length for debugging
  int min(int a, int b) {
    return (a < b) ? a : b;
  }
}