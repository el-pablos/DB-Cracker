import 'dart:convert';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/mahasiswa.dart';
import '../models/dosen.dart';
import '../models/prodi.dart';
import '../models/pt.dart';

class PddiktiApi {
  // Base URL API
  final String baseUrl = 'https://api-pddikti.kemdiktisaintek.go.id';
  
  // Header untuk request - ini sangat penting untuk menghindari 403
  Map<String, String> get _headers => {
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'en-US,en;q=0.9,id;q=0.8',
    'Origin': 'https://pddikti.kemdiktisaintek.go.id',
    'Referer': 'https://pddikti.kemdiktisaintek.go.id/',
    'sec-ch-ua': '"Chromium";v="116", "Not)A;Brand";v="24", "Google Chrome";v="116"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'same-site',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36',
  };

  // Encode parameter URL
  String _parseString(String text) {
    return Uri.encodeComponent(text);
  }

  // Ambil list data aman
  List<dynamic> _safeGetList(dynamic data, String key) {
    // If data is already a List, return it directly
    if (data is List) {
      return data;
    }
    
    // If data is a Map, try to extract the list
    if (data is Map<String, dynamic>) {
      final value = data[key];
      if (value == null) return [];
      if (value is List) return value;
    }
    
    // Default empty list if nothing works
    return [];
  }

  // Proses response API
  Future<dynamic> _processApiResponse(http.Response response, String errorMessage) async {
    if (response.statusCode == 200) {
      try {
        // Decode the response, could be a List or a Map
        return json.decode(response.body);
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Format data tidak valid: $e');
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('$errorMessage: ${response.statusCode}');
    }
  }

  // Cara untuk melewati CORS issue dengan simulasi permintaan dari web asli
  Future<http.Response> _makeApiRequest(Uri url, {int timeoutSeconds = 15}) async {
    try {
      // Untuk Flutter Web, kita perlu pendekatan khusus
      if (kIsWeb) {
        // Opsi 1: Gunakan direct request (dengan header yang lengkap)
        // Ini berpeluang sukses jika request berasal dari localhost development
        try {
          return await http.get(
            url,
            headers: _headers,
          ).timeout(
            Duration(seconds: timeoutSeconds),
          );
        } catch (e) {
          print('Direct web request failed: $e');
          // Jika direct request gagal, kita bisa mencoba pendekatan lain
          
          // Opsi 2: Gunakan JSONp atau backend proxy Anda sendiri
          // Untuk implementasi produksi, Anda perlu menggunakan server backend Anda sendiri
          // sebagai proxy untuk melewati CORS
          throw Exception('Akses web API terblokir. Gunakan versi mobile atau gunakan backend proxy.');
        }
      } else {
        // Untuk aplikasi mobile, kita bisa langsung melakukan request
        return await http.get(
          url,
          headers: _headers,
        ).timeout(
          Duration(seconds: timeoutSeconds),
        );
      }
    } catch (e) {
      print('Error in _makeApiRequest: $e');
      
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('Terjadi error CORS. Silakan gunakan versi mobile app atau gunakan backend proxy.');
      } else if (e.toString().contains('403')) {
        throw Exception('Server menolak akses (403 Forbidden). Coba lagi nanti atau gunakan VPN.');
      } else if (e.toString().contains('Timeout')) {
        throw Exception('Koneksi timeout. Server mungkin sibuk, silakan coba lagi.');
      } else {
        throw Exception('Error koneksi: ${e.toString()}');
      }
    }
  }

  // Pencarian mahasiswa
  Future<List<Mahasiswa>> searchMahasiswa(String keyword) async {
    try {
      print('Mencari mahasiswa: $keyword');
      
      final Uri url = Uri.parse('$baseUrl/pencarian/mhs/${_parseString(keyword)}');
      print('URL Request: ${url.toString()}');
      
      // Request dengan error handling yang lebih baik
      final response = await _makeApiRequest(url);
      
      print('Status kode: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // Parse response - could be a List or a Map
        final dynamic responseData = json.decode(response.body);
        List<dynamic> mhsList = [];
        
        // Handle different response structures
        if (responseData is List) {
          // Response is already a list of mahasiswa
          print('Response is a direct List');
          mhsList = responseData;
        } else if (responseData is Map<String, dynamic>) {
          // Response is a Map with mahasiswa field
          print('Response is a Map with mahasiswa field');
          if (responseData.containsKey('mahasiswa')) {
            mhsList = responseData['mahasiswa'] as List<dynamic>;
          } else {
            print('Data mahasiswa tidak ditemukan dalam Map');
            return [];
          }
        } else {
          print('Unknown response type: ${responseData.runtimeType}');
          return [];
        }
        
        print('Ditemukan ${mhsList.length} mahasiswa');
        
        return mhsList.map((item) {
          if (item is! Map<String, dynamic>) {
            print('Item is not a Map: $item');
            return Mahasiswa.fromJson({});
          }
          
          try {
            return Mahasiswa.fromJson(item);
          } catch (e) {
            print('Error parsing Mahasiswa: $e');
            return Mahasiswa.fromJson({});
          }
        }).where((m) => m.id.isNotEmpty).toList();
        
      } else if (response.statusCode == 403) {
        throw Exception('Akses ditolak oleh server. Silakan coba gunakan VPN atau gunakan aplikasi mobile.');
      } else {
        throw Exception('Gagal mencari data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      // Buat pesan error yang lebih informatif
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception('Error CORS: Aplikasi web tidak diizinkan untuk mengakses API secara langsung. Gunakan versi mobile.');
      } else if (e.toString().contains('403')) {
        throw Exception('Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
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
      
      final response = await _makeApiRequest(url);
      
      if (response.statusCode == 200) {
        // Parse response - handle both Map and List formats
        final dynamic responseData = await _processApiResponse(
          response, 
          'Gagal mencari dosen'
        );
        
        List<dynamic> dosenList = [];
        
        if (responseData is List) {
          dosenList = responseData;
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('dosen')) {
          dosenList = responseData['dosen'] as List<dynamic>;
        } else {
          return [];
        }
        
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
      if (e.toString().contains('403')) {
        throw Exception('Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
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
      
      final response = await _makeApiRequest(url);
      
      if (response.statusCode == 200) {
        // Parse response - handle both Map and List formats
        final dynamic responseData = await _processApiResponse(
          response, 
          'Gagal mencari perguruan tinggi'
        );
        
        List<dynamic> ptList = [];
        
        if (responseData is List) {
          ptList = responseData;
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('pt')) {
          ptList = responseData['pt'] as List<dynamic>;
        } else {
          return [];
        }
        
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
      if (e.toString().contains('403')) {
        throw Exception('Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
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
      
      final response = await _makeApiRequest(url);
      
      if (response.statusCode == 200) {
        // Parse response - handle both Map and List formats
        final dynamic responseData = await _processApiResponse(
          response, 
          'Gagal mencari program studi'
        );
        
        List<dynamic> prodiList = [];
        
        if (responseData is List) {
          prodiList = responseData;
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('prodi')) {
          prodiList = responseData['prodi'] as List<dynamic>;
        } else {
          return [];
        }
        
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
      if (e.toString().contains('403')) {
        throw Exception('Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Detail mahasiswa
  Future<MahasiswaDetail> getMahasiswaDetail(String mahasiswaId) async {
    try {
      print('Fetching mahasiswa detail for ID: $mahasiswaId');
      
      // The API might expect a different format of ID, let's try to handle both formats
      String processedId = mahasiswaId;
      // If the ID is base64, we keep it as is, otherwise we might need to encode it
      // This step is precautionary in case the ID format is different

      final Uri url = Uri.parse('$baseUrl/detail/mhs/${_parseString(processedId)}');
      print('Detail URL: ${url.toString()}');
      
      final response = await _makeApiRequest(url);
      print('Detail response status: ${response.statusCode}');
      
      // Log the response body for debugging
      print('Response body: ${response.body.substring(0, min(100, response.body.length))}...');

      if (response.statusCode == 200) {
        // Try to parse the response
        final dynamic responseData = json.decode(response.body);
        print('Response type: ${responseData.runtimeType}');
        
        // Handle different response formats
        if (responseData is List) {
          // Direct list response
          print('Detail response is a List with ${responseData.length} items');
          if (responseData.isEmpty) {
            throw Exception('Detail mahasiswa kosong');
          }
          
          final item = responseData[0];
          if (item is! Map<String, dynamic>) {
            throw Exception('Format data tidak valid (item bukan Map)');
          }
          
          // Log the keys available in the item
          print('Available keys: ${(item as Map<String, dynamic>).keys.toList()}');
          
          return MahasiswaDetail.fromJson(item);
        } 
        else if (responseData is Map<String, dynamic>) {
          // Map with mahasiswa field
          print('Detail response is a Map');
          
          // Check for mahasiswa field
          if (!responseData.containsKey('mahasiswa')) {
            // Try direct parsing if no mahasiswa field
            print('No mahasiswa field, trying direct parsing');
            
            // Log the keys available in the response
            print('Available keys: ${responseData.keys.toList()}');
            
            // Some APIs might return the detail directly without a mahasiswa field
            // Let's try to parse it directly if it has essential fields
            if (responseData.containsKey('nama') || responseData.containsKey('nim')) {
              return MahasiswaDetail.fromJson(responseData);
            }
            
            throw Exception('Data mahasiswa tidak ditemukan dalam respons');
          }
          
          final mahasiswaData = responseData['mahasiswa'];
          if (mahasiswaData is! List || mahasiswaData.isEmpty) {
            throw Exception('Data mahasiswa kosong atau tidak valid');
          }
          
          final item = mahasiswaData[0];
          if (item is! Map<String, dynamic>) {
            throw Exception('Format data tidak valid');
          }
          
          return MahasiswaDetail.fromJson(item);
        }
        else {
          throw Exception('Format respons tidak dikenali: ${responseData.runtimeType}');
        }
      } else {
        throw Exception('Gagal mendapatkan detail: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getMahasiswaDetail: $e');
      if (e.toString().contains('403')) {
        throw Exception('Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Detail dosen
  Future<DosenDetail> getDosenProfile(String dosenId) async {
    try {
      print('Fetching dosen profile for ID: $dosenId');
      
      // The API might expect a different format of ID
      String processedId = dosenId;

      final Uri url = Uri.parse('$baseUrl/dosen/profile/${_parseString(processedId)}');
      print('Profile URL: ${url.toString()}');
      
      final response = await _makeApiRequest(url);
      print('Profile response status: ${response.statusCode}');
      
      // Log the response body for debugging
      print('Response body: ${response.body.substring(0, min(100, response.body.length))}...');

      if (response.statusCode == 200) {
        // Try to parse the response
        final dynamic responseData = json.decode(response.body);
        print('Response type: ${responseData.runtimeType}');
        
        // Handle different response formats
        if (responseData is List) {
          // Direct list response
          print('Profile response is a List with ${responseData.length} items');
          if (responseData.isEmpty) {
            throw Exception('Detail dosen kosong');
          }
          
          final item = responseData[0];
          if (item is! Map<String, dynamic>) {
            throw Exception('Format data tidak valid (item bukan Map)');
          }
          
          // Log the keys available in the item
          print('Available keys: ${(item as Map<String, dynamic>).keys.toList()}');
          
          return DosenDetail(
            idSdm: item['id_sdm'] ?? dosenId,
            namaDosen: item['nama_dosen'] ?? 'Tidak tersedia',
            namaPt: item['nama_pt'] ?? 'Tidak tersedia',
            namaProdi: item['nama_prodi'] ?? 'Tidak tersedia',
            jenisKelamin: item['jenis_kelamin'] ?? '-',
            jabatanAkademik: item['jabatan_akademik'] ?? '-',
            pendidikanTertinggi: item['pendidikan_tertinggi'] ?? '-',
            statusIkatanKerja: item['status_ikatan_kerja'] ?? '-',
            statusAktivitas: item['status_aktivitas'] ?? '-',
            penelitian: [], // Bisa ditambahkan nanti
            pengabdian: [],
            karya: [],
            paten: [],
            riwayatStudi: [],
            riwayatMengajar: [],
          );
        } 
        else if (responseData is Map<String, dynamic>) {
          // Map with dosen field
          print('Profile response is a Map');
          
          // Check for dosen field
          if (!responseData.containsKey('dosen')) {
            // Try direct parsing if no dosen field
            print('No dosen field, trying direct parsing');
            
            // Log the keys available in the response
            print('Available keys: ${responseData.keys.toList()}');
            
            // Some APIs might return the detail directly without a dosen field
            return DosenDetail(
              idSdm: responseData['id_sdm'] ?? dosenId,
              namaDosen: responseData['nama_dosen'] ?? responseData['nama'] ?? 'Tidak tersedia',
              namaPt: responseData['nama_pt'] ?? 'Tidak tersedia',
              namaProdi: responseData['nama_prodi'] ?? responseData['prodi'] ?? 'Tidak tersedia',
              jenisKelamin: responseData['jenis_kelamin'] ?? '-',
              jabatanAkademik: responseData['jabatan_akademik'] ?? '-',
              pendidikanTertinggi: responseData['pendidikan_tertinggi'] ?? '-',
              statusIkatanKerja: responseData['status_ikatan_kerja'] ?? '-',
              statusAktivitas: responseData['status_aktivitas'] ?? '-',
              penelitian: [],
              pengabdian: [],
              karya: [],
              paten: [],
              riwayatStudi: [],
              riwayatMengajar: [],
            );
          }
          
          final dosenData = responseData['dosen'];
          if (dosenData is! List || dosenData.isEmpty) {
            throw Exception('Data dosen kosong atau tidak valid');
          }
          
          final item = dosenData[0];
          if (item is! Map<String, dynamic>) {
            throw Exception('Format data tidak valid');
          }
          
          return DosenDetail(
            idSdm: item['id_sdm'] ?? dosenId,
            namaDosen: item['nama_dosen'] ?? 'Tidak tersedia',
            namaPt: item['nama_pt'] ?? 'Tidak tersedia',
            namaProdi: item['nama_prodi'] ?? 'Tidak tersedia',
            jenisKelamin: item['jenis_kelamin'] ?? '-',
            jabatanAkademik: item['jabatan_akademik'] ?? '-',
            pendidikanTertinggi: item['pendidikan_tertinggi'] ?? '-',
            statusIkatanKerja: item['status_ikatan_kerja'] ?? '-',
            statusAktivitas: item['status_aktivitas'] ?? '-',
            penelitian: [],
            pengabdian: [],
            karya: [],
            paten: [],
            riwayatStudi: [],
            riwayatMengajar: [],
          );
        }
        else {
          throw Exception('Format respons tidak dikenali: ${responseData.runtimeType}');
        }
      } else {
        throw Exception('Gagal mendapatkan detail dosen: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getDosenProfile: $e');
      // For now, create a mock response until API is working
      return DosenDetail(
        idSdm: dosenId,
        namaDosen: 'Dosen Mock',
        namaPt: 'Universitas Indonesia',
        namaProdi: 'Informatika',
        jenisKelamin: 'Laki-laki',
        jabatanAkademik: 'Lektor Kepala',
        pendidikanTertinggi: 'S3',
        statusIkatanKerja: 'Tetap',
        statusAktivitas: 'Aktif',
        penelitian: [],
        pengabdian: [],
        karya: [],
        paten: [],
        riwayatStudi: [],
        riwayatMengajar: [],
      );
    }
  }

  // Detail PT
  Future<PerguruanTinggiDetail> getDetailPt(String ptId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/pt/detail/${_parseString(ptId)}');
      
      final response = await _makeApiRequest(url);

      // Parse response - handle both Map and List formats
      final dynamic responseData = await _processApiResponse(
        response, 
        'Gagal mendapatkan detail perguruan tinggi'
      );
      
      List<dynamic> ptList = [];
      
      if (responseData is List) {
        ptList = responseData;
      } else if (responseData is Map<String, dynamic> && responseData.containsKey('pt')) {
        ptList = responseData['pt'] as List<dynamic>;
      } else {
        throw Exception('Data perguruan tinggi tidak ditemukan');
      }
      
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
      if (e.toString().contains('403')) {
        throw Exception('Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Detail program studi
  Future<ProdiDetail> getDetailProdi(String prodiId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/prodi/detail/${_parseString(prodiId)}');
      
      final response = await _makeApiRequest(url);

      // Parse response - handle both Map and List formats
      final dynamic responseData = await _processApiResponse(
        response, 
        'Gagal mendapatkan detail program studi'
      );
      
      List<dynamic> prodiList = [];
      
      if (responseData is List) {
        prodiList = responseData;
      } else if (responseData is Map<String, dynamic> && responseData.containsKey('prodi')) {
        prodiList = responseData['prodi'] as List<dynamic>;
      } else {
        throw Exception('Data program studi tidak ditemukan');
      }
      
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
        final descResponse = await _makeApiRequest(
          Uri.parse('$baseUrl/prodi/desc/${_parseString(prodiId)}'),
          timeoutSeconds: 10
        );
        
        if (descResponse.statusCode == 200) {
          final dynamic descData = json.decode(descResponse.body);
          
          List<dynamic> descList = [];
          
          if (descData is List) {
            descList = descData;
          } else if (descData is Map<String, dynamic> && descData.containsKey('prodi')) {
            descList = descData['prodi'] as List<dynamic>;
          }
          
          if (descList.isNotEmpty && descList.first is Map<String, dynamic>) {
            descJson = descList.first as Map<String, dynamic>;
          }
        }
      } catch (e) {
        print('Error mendapatkan deskripsi prodi: $e');
      }
      
      return ProdiDetail.fromJson(item, descJson);
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('403')) {
        throw Exception('Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // List prodi untuk PT tertentu
  Future<List<ProdiPt>> getProdiPt(String ptId, int tahun) async {
    try {
      final Uri url = Uri.parse('$baseUrl/pt/detail/${_parseString(ptId)}/${_parseString(tahun.toString())}');
      
      final response = await _makeApiRequest(url);

      // Parse response - handle both Map and List formats
      final dynamic responseData = await _processApiResponse(
        response, 
        'Gagal mendapatkan daftar program studi'
      );
      
      List<dynamic> prodiList = [];
      
      if (responseData is List) {
        prodiList = responseData;
      } else if (responseData is Map<String, dynamic> && responseData.containsKey('prodi')) {
        prodiList = responseData['prodi'] as List<dynamic>;
      } else {
        return [];
      }
      
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
      if (e.toString().contains('403')) {
        throw Exception('Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Pencarian semua entitas
  Future<Map<String, dynamic>> searchAll(String keyword) async {
    try {
      final Uri url = Uri.parse('$baseUrl/pencarian/all/${_parseString(keyword)}');
      
      final response = await _makeApiRequest(url);
      
      // Handle case where response might be a list
      final dynamic responseData = await _processApiResponse(response, 'Gagal mencari data');
      
      if (responseData is Map<String, dynamic>) {
        return responseData;
      } else if (responseData is List) {
        // Convert list to map format
        return {'results': responseData};
      } else {
        return {};
      }
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('403')) {
        throw Exception('Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
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