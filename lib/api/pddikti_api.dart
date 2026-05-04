import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/mahasiswa.dart';
import '../models/dosen.dart';
import '../models/prodi.dart';
import '../models/pt.dart';

class PddiktiApi {
  // Base URL API
  final String baseUrl = 'https://api-pddikti.kemdiktisaintek.go.id';

  // Cache public IP biar ga fetch terus
  String _cachedIp = '103.0.0.1';
  bool _ipFetched = false;

  /// Fetch public IP dari ipify (sama kayak frontend PDDIKTI)
  Future<String> _getPublicIp() async {
    if (_ipFetched) return _cachedIp;
    try {
      final response = await http.get(
        Uri.parse('https://api.ipify.org/?format=json'),
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cachedIp = data['ip'] ?? '103.0.0.1';
        _ipFetched = true;
      }
    } catch (_) {
      // Fallback ke default IP
    }
    return _cachedIp;
  }

  // Header untuk request - wajib ada x-api-key dan X-User-IP
  Map<String, String> get _headers => {
        'Accept': 'application/json, text/plain, */*',
        'Accept-Encoding': 'gzip, deflate, br, zstd',
        'Accept-Language': 'en-US,en;q=0.9,id;q=0.8',
        'Connection': 'keep-alive',
        'Content-Type': 'application/json',
        'DNT': '1',
        'Host': 'api-pddikti.kemdiktisaintek.go.id',
        'Origin': 'https://pddikti.kemdiktisaintek.go.id',
        'Referer': 'https://pddikti.kemdiktisaintek.go.id/',
        'sec-ch-ua': '"Microsoft Edge";v="131", "Chromium";v="131", "Not_A Brand";v="24"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"',
        'sec-fetch-dest': 'empty',
        'sec-fetch-mode': 'cors',
        'sec-fetch-site': 'same-site',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0',
        'x-api-key': 'undefined',
        'X-User-IP': '103.0.0.1',
      };

  // Encode parameter URL
  String _parseString(String text) {
    return Uri.encodeComponent(text);
  }

  // Ambil list data aman

  // Proses response API
  Future<dynamic> _processApiResponse(
      http.Response response, String errorMessage) async {
    if (response.statusCode == 200) {
      try {
        // Decode the response, could be a List or a Map
        return json.decode(response.body);
      } catch (e) {
        if (kDebugMode) debugPrint('Error parsing JSON: $e');
        throw Exception('Format data tidak valid: $e');
      }
    } else {
      if (kDebugMode) debugPrint('HTTP Error: ${response.statusCode}');
      if (kDebugMode) debugPrint('Response body: ${response.body}');
      throw Exception('$errorMessage: ${response.statusCode}');
    }
  }

  // Cara untuk melewati CORS issue dengan simulasi permintaan dari web asli
  Future<http.Response> _makeApiRequest(Uri url,
      {int timeoutSeconds = 15}) async {
    try {
      // Fetch public IP dulu buat header X-User-IP
      final ip = await _getPublicIp();
      final headers = Map<String, String>.from(_headers);
      headers['X-User-IP'] = ip;

      // Untuk Flutter Web, kita perlu pendekatan khusus
      if (kIsWeb) {
        // Opsi 1: Gunakan direct request (dengan header yang lengkap)
        // Ini berpeluang sukses jika request berasal dari localhost development
        try {
          return await http
              .get(
                url,
                headers: headers,
              )
              .timeout(
                Duration(seconds: timeoutSeconds),
              );
        } catch (e) {
          if (kDebugMode) debugPrint('Direct web request failed: $e');
          // Jika direct request gagal, kita bisa mencoba pendekatan lain

          // Opsi 2: Gunakan JSONp atau backend proxy Anda sendiri
          // Untuk implementasi produksi, Anda perlu menggunakan server backend Anda sendiri
          // sebagai proxy untuk melewati CORS
          throw Exception(
              'Akses web API terblokir. Gunakan versi mobile atau gunakan backend proxy.');
        }
      } else {
        // Untuk aplikasi mobile, kita bisa langsung melakukan request
        return await http
            .get(
              url,
              headers: headers,
            )
            .timeout(
              Duration(seconds: timeoutSeconds),
            );
      }
    } catch (e) {
      print('PDDIKTI_DEBUG: _makeApiRequest ERROR: $e');
      if (kDebugMode) debugPrint('Error in _makeApiRequest: $e');

      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'Terjadi error CORS. Silakan gunakan versi mobile app atau gunakan backend proxy.');
      } else if (e.toString().contains('403')) {
        throw Exception(
            'Server menolak akses (403 Forbidden). Coba lagi nanti atau gunakan VPN.');
      } else if (e.toString().contains('Timeout')) {
        throw Exception(
            'Koneksi timeout. Server mungkin sibuk, silakan coba lagi.');
      } else {
        throw Exception('Error koneksi: ${e.toString()}');
      }
    }
  }

  // Pencarian mahasiswa
  Future<List<Mahasiswa>> searchMahasiswa(String keyword) async {
    try {
      if (kDebugMode) debugPrint('Mencari mahasiswa: $keyword');

      final Uri url =
          Uri.parse('$baseUrl/pencarian/mhs/${_parseString(keyword)}');
      if (kDebugMode) debugPrint('URL Request: ${url.toString()}');

      // Request dengan error handling yang lebih baik
      final response = await _makeApiRequest(url);

      if (kDebugMode) debugPrint('Status kode: ${response.statusCode}');
      // TEMP DEBUG - remove after testing
      print('PDDIKTI_DEBUG: statusCode=${response.statusCode}, bodyLen=${response.body.length}');

      if (response.statusCode == 200) {
        // Parse response - could be a List or a Map
        final dynamic responseData = json.decode(response.body);
        List<dynamic> mhsList = [];

        // Handle different response structures
        if (responseData is List) {
          // Response is already a list of mahasiswa
          print('PDDIKTI_DEBUG: responseData is List, length=${responseData.length}');
          mhsList = responseData;
        } else if (responseData is Map<String, dynamic>) {
          // Response is a Map with mahasiswa field
          if (kDebugMode) debugPrint('Response is a Map with mahasiswa field');
          if (responseData.containsKey('mahasiswa')) {
            mhsList = (responseData['mahasiswa'] is List ? (responseData['mahasiswa'] is List ? responseData['mahasiswa'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
          } else {
            if (kDebugMode) debugPrint('Data mahasiswa tidak ditemukan dalam Map');
            return [];
          }
        } else {
          if (kDebugMode) debugPrint('Unknown response type: ${responseData.runtimeType}');
          return [];
        }

        if (kDebugMode) debugPrint('Ditemukan ${mhsList.length} mahasiswa');

        return mhsList
            .map((item) {
              if (item is! Map<String, dynamic>) {
                if (kDebugMode) debugPrint('Item is not a Map: $item');
                return Mahasiswa.fromJson({});
              }

              try {
                return Mahasiswa.fromJson(item);
              } catch (e) {
                if (kDebugMode) debugPrint('Error parsing Mahasiswa: $e');
                return Mahasiswa.fromJson({});
              }
            })
            .where((m) => m.id.isNotEmpty)
            .toList();
      } else if (response.statusCode == 403) {
        throw Exception(
            'Akses ditolak oleh server. Silakan coba gunakan VPN atau gunakan aplikasi mobile.');
      } else {
        throw Exception('Gagal mencari data: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error: $e');
      // Buat pesan error yang lebih informatif
      if (e.toString().contains('XMLHttpRequest')) {
        throw Exception(
            'Error CORS: Aplikasi web tidak diizinkan untuk mengakses API secara langsung. Gunakan versi mobile.');
      } else if (e.toString().contains('403')) {
        throw Exception(
            'Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception(
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Pencarian dosen
  Future<List<Dosen>> searchDosen(String keyword) async {
    try {
      if (kDebugMode) debugPrint('Mencari dosen: $keyword');

      final Uri url =
          Uri.parse('$baseUrl/pencarian/dosen/${_parseString(keyword)}');

      final response = await _makeApiRequest(url);

      if (response.statusCode == 200) {
        // Parse response - handle both Map and List formats
        final dynamic responseData =
            await _processApiResponse(response, 'Gagal mencari dosen');

        List<dynamic> dosenList = [];

        if (responseData is List) {
          dosenList = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('dosen')) {
          dosenList = (responseData['dosen'] is List ? (responseData['dosen'] is List ? responseData['dosen'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
        } else {
          return [];
        }

        return dosenList
            .map((item) {
              if (item is! Map<String, dynamic>) {
                return Dosen.fromJson({});
              }

              try {
                return Dosen.fromJson(item);
              } catch (e) {
                return Dosen.fromJson({});
              }
            })
            .where((d) => d.id.isNotEmpty)
            .toList();
      } else {
        throw Exception('Gagal mencari dosen: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error: $e');
      if (e.toString().contains('403')) {
        throw Exception(
            'Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Pencarian PT
  Future<List<PerguruanTinggi>> searchPt(String keyword) async {
    try {
      if (kDebugMode) debugPrint('Mencari perguruan tinggi: $keyword');

      final Uri url =
          Uri.parse('$baseUrl/pencarian/pt/${_parseString(keyword)}');

      final response = await _makeApiRequest(url);

      if (response.statusCode == 200) {
        // Parse response - handle both Map and List formats
        final dynamic responseData = await _processApiResponse(
            response, 'Gagal mencari perguruan tinggi');

        List<dynamic> ptList = [];

        if (responseData is List) {
          ptList = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('pt')) {
          ptList = (responseData['pt'] is List ? (responseData['pt'] is List ? responseData['pt'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
        } else {
          return [];
        }

        return ptList
            .map((item) {
              if (item is! Map<String, dynamic>) {
                return PerguruanTinggi.fromJson({});
              }

              try {
                return PerguruanTinggi.fromJson(item);
              } catch (e) {
                return PerguruanTinggi.fromJson({});
              }
            })
            .where((pt) => pt.id.isNotEmpty)
            .toList();
      } else {
        throw Exception(
            'Gagal mencari perguruan tinggi: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error: $e');
      if (e.toString().contains('403')) {
        throw Exception(
            'Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Pencarian prodi
  Future<List<Prodi>> searchProdi(String keyword) async {
    try {
      if (kDebugMode) debugPrint('Mencari program studi: $keyword');

      final Uri url =
          Uri.parse('$baseUrl/pencarian/prodi/${_parseString(keyword)}');

      final response = await _makeApiRequest(url);

      if (response.statusCode == 200) {
        // Parse response - handle both Map and List formats
        final dynamic responseData =
            await _processApiResponse(response, 'Gagal mencari program studi');

        List<dynamic> prodiList = [];

        if (responseData is List) {
          prodiList = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('prodi')) {
          prodiList = (responseData['prodi'] is List ? (responseData['prodi'] is List ? responseData['prodi'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
        } else {
          return [];
        }

        return prodiList
            .map((item) {
              if (item is! Map<String, dynamic>) {
                return Prodi.fromJson({});
              }

              try {
                return Prodi.fromJson(item);
              } catch (e) {
                return Prodi.fromJson({});
              }
            })
            .where((p) => p.id.isNotEmpty)
            .toList();
      } else {
        throw Exception('Gagal mencari program studi: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error: $e');
      if (e.toString().contains('403')) {
        throw Exception(
            'Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Detail mahasiswa
  Future<MahasiswaDetail> getMahasiswaDetail(String mahasiswaId) async {
    try {
      if (kDebugMode) debugPrint('Fetching mahasiswa detail for ID: $mahasiswaId');

      // The API might expect a different format of ID, let's try to handle both formats
      String processedId = mahasiswaId;
      // If the ID is base64, we keep it as is, otherwise we might need to encode it
      // This step is precautionary in case the ID format is different

      final Uri url =
          Uri.parse('$baseUrl/detail/mhs/${_parseString(processedId)}');
      if (kDebugMode) debugPrint('Detail URL: ${url.toString()}');

      final response = await _makeApiRequest(url);
      if (kDebugMode) debugPrint('Detail response status: ${response.statusCode}');

      // Log the response body for debugging
      if (kDebugMode) debugPrint(
          'Response body: ${response.body.substring(0, min(100, response.body.length))}...');

      if (response.statusCode == 200) {
        // Try to parse the response
        final dynamic responseData = json.decode(response.body);
        if (kDebugMode) debugPrint('Response type: ${responseData.runtimeType}');

        // Handle different response formats
        if (responseData is List) {
          // Direct list response
          if (kDebugMode) debugPrint('Detail response is a List with ${responseData.length} items');
          if (responseData.isEmpty) {
            throw Exception('Detail mahasiswa kosong');
          }

          final item = responseData[0];
          if (item is! Map<String, dynamic>) {
            throw Exception('Format data tidak valid (item bukan Map)');
          }

          // Log the keys available in the item
          if (kDebugMode) debugPrint('Available keys: ${(item).keys.toList()}');

          return MahasiswaDetail.fromJson(item);
        } else if (responseData is Map<String, dynamic>) {
          // Map with mahasiswa field
          if (kDebugMode) debugPrint('Detail response is a Map');

          // Check for mahasiswa field
          if (!responseData.containsKey('mahasiswa')) {
            // Try direct parsing if no mahasiswa field
            if (kDebugMode) debugPrint('No mahasiswa field, trying direct parsing');

            // Log the keys available in the response
            if (kDebugMode) debugPrint('Available keys: ${responseData.keys.toList()}');

            // Some APIs might return the detail directly without a mahasiswa field
            // Let's try to parse it directly if it has essential fields
            if (responseData.containsKey('nama') ||
                responseData.containsKey('nim')) {
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
        } else {
          throw Exception(
              'Format respons tidak dikenali: ${responseData.runtimeType}');
        }
      } else {
        throw Exception('Gagal mendapatkan detail: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error in getMahasiswaDetail: $e');
      if (e.toString().contains('403')) {
        throw Exception(
            'Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Detail dosen lengkap dengan semua data
  Future<DosenDetail> getDosenDetailLengkap(String dosenId) async {
    try {
      if (kDebugMode) debugPrint('Fetching comprehensive dosen detail for ID: $dosenId');

      // Ambil profil dasar dosen
      final DosenDetail profileDasar = await getDosenProfile(dosenId);

      // Ambil data tambahan secara paralel
      final List<Future> futures = [
        getDosenRiwayatStudi(dosenId),
        getDosenRiwayatMengajar(dosenId),
        getDosenPenelitian(dosenId),
        getDosenPengabdian(dosenId),
        getDosenKarya(dosenId),
        getDosenPaten(dosenId),
        getDosenRiwayatJabatan(dosenId),
        getDosenRiwayatPenugasan(dosenId),
      ];

      final results = await Future.wait(futures, eagerError: false);

      // Gabungkan semua data
      return DosenDetail(
        idSdm: profileDasar.idSdm,
        namaDosen: profileDasar.namaDosen,
        nidn: profileDasar.nidn,
        nidk: profileDasar.nidk,
        gelarDepan: profileDasar.gelarDepan,
        gelarBelakang: profileDasar.gelarBelakang,
        jenisKelamin: profileDasar.jenisKelamin,
        statusIkatanKerja: profileDasar.statusIkatanKerja,
        statusAktivitas: profileDasar.statusAktivitas,
        tempatLahir: profileDasar.tempatLahir,
        tanggalLahir: profileDasar.tanggalLahir,
        agama: profileDasar.agama,
        namaPt: profileDasar.namaPt,
        namaProdi: profileDasar.namaProdi,
        homePt: profileDasar.homePt,
        homeProdi: profileDasar.homeProdi,
        rasioHomebase: profileDasar.rasioHomebase,
        statusHomebase: profileDasar.statusHomebase,
        jabatanAkademik: profileDasar.jabatanAkademik,
        tanggalSk: profileDasar.tanggalSk,
        tmtJabatan: profileDasar.tmtJabatan,
        nomorSk: profileDasar.nomorSk,
        pendidikanTertinggi: profileDasar.pendidikanTertinggi,
        bidangIlmu: profileDasar.bidangIlmu,
        institusiPendidikan: profileDasar.institusiPendidikan,
        tahunLulusTertinggi: profileDasar.tahunLulusTertinggi,
        statusSertifikasi: profileDasar.statusSertifikasi,
        tahunSertifikasi: profileDasar.tahunSertifikasi,
        nomorSertifikat: profileDasar.nomorSertifikat,
        bidangSertifikasi: profileDasar.bidangSertifikasi,
        riwayatStudi: results[0] as List<DosenRiwayatStudi>? ?? [],
        riwayatMengajar: results[1] as List<DosenRiwayatMengajar>? ?? [],
        penelitian: results[2] as List<DosenPortofolio>? ?? [],
        pengabdian: results[3] as List<DosenPortofolio>? ?? [],
        karya: results[4] as List<DosenPortofolio>? ?? [],
        paten: results[5] as List<DosenPortofolio>? ?? [],
        riwayatJabatan: results[6] as List<DosenJabatanFungsional>? ?? [],
        riwayatPenugasan: results[7] as List<DosenPenugasan>? ?? [],
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error in getDosenDetailLengkap: $e');
      // Fallback ke profil dasar jika ada error
      return await getDosenProfile(dosenId);
    }
  }

  // Detail dosen profil dasar
  Future<DosenDetail> getDosenProfile(String dosenId) async {
    try {
      if (kDebugMode) debugPrint('Fetching dosen profile for ID: $dosenId');

      // Coba beberapa endpoint yang mungkin
      List<String> possibleEndpoints = [
        '$baseUrl/dosen/profile/${_parseString(dosenId)}',
        '$baseUrl/detail/dosen/${_parseString(dosenId)}',
        '$baseUrl/dosen/${_parseString(dosenId)}',
      ];

      http.Response? response;
      String? workingEndpoint;

      // Coba setiap endpoint sampai ada yang berhasil
      for (String endpoint in possibleEndpoints) {
        try {
          if (kDebugMode) debugPrint('Trying endpoint: $endpoint');
          final Uri url = Uri.parse(endpoint);
          response = await _makeApiRequest(url);

          if (response.statusCode == 200) {
            workingEndpoint = endpoint;
            if (kDebugMode) debugPrint('Success with endpoint: $endpoint');
            break;
          } else {
            if (kDebugMode) debugPrint('Failed with endpoint: $endpoint (${response.statusCode})');
          }
        } catch (e) {
          if (kDebugMode) debugPrint('Error with endpoint: $endpoint - $e');
          continue;
        }
      }

      if (response == null || response.statusCode != 200) {
        throw Exception('All endpoints failed for dosen ID: $dosenId');
      }

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        Map<String, dynamic> dosenData = {};

        if (responseData is List && responseData.isNotEmpty) {
          dosenData = responseData[0] as Map<String, dynamic>;
        } else if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('dosen') &&
              responseData['dosen'] is List) {
            final dosenList = responseData['dosen'] as List;
            if (dosenList.isNotEmpty) {
              dosenData = dosenList[0] as Map<String, dynamic>;
            }
          } else {
            dosenData = responseData;
          }
        }

        return DosenDetail(
          idSdm: _getStringValue(dosenData, 'id_sdm') ?? dosenId,
          namaDosen: _getStringValue(dosenData, 'nama_dosen') ??
              _getStringValue(dosenData, 'nama') ??
              'Tidak tersedia',
          nidn: _getStringValue(dosenData, 'nidn'),
          nidk: _getStringValue(dosenData, 'nidk'),
          gelarDepan: _getStringValue(dosenData, 'gelar_depan'),
          gelarBelakang: _getStringValue(dosenData, 'gelar_belakang'),
          jenisKelamin: _getStringValue(dosenData, 'jenis_kelamin'),
          statusIkatanKerja: _getStringValue(dosenData, 'status_ikatan_kerja'),
          statusAktivitas: _getStringValue(dosenData, 'status_aktivitas'),
          tempatLahir: _getStringValue(dosenData, 'tempat_lahir'),
          tanggalLahir: _getStringValue(dosenData, 'tanggal_lahir'),
          agama: _getStringValue(dosenData, 'agama'),
          namaPt: _getStringValue(dosenData, 'nama_pt'),
          namaProdi: _getStringValue(dosenData, 'nama_prodi') ??
              _getStringValue(dosenData, 'prodi'),
          homePt: _getStringValue(dosenData, 'home_pt'),
          homeProdi: _getStringValue(dosenData, 'home_prodi'),
          rasioHomebase: _getStringValue(dosenData, 'rasio_homebase'),
          statusHomebase: _getStringValue(dosenData, 'status_homebase'),
          jabatanAkademik: _getStringValue(dosenData, 'jabatan_akademik'),
          tanggalSk: _getStringValue(dosenData, 'tanggal_sk'),
          tmtJabatan: _getStringValue(dosenData, 'tmt_jabatan'),
          nomorSk: _getStringValue(dosenData, 'nomor_sk'),
          pendidikanTertinggi:
              _getStringValue(dosenData, 'pendidikan_tertinggi'),
          bidangIlmu: _getStringValue(dosenData, 'bidang_ilmu'),
          institusiPendidikan:
              _getStringValue(dosenData, 'institusi_pendidikan'),
          tahunLulusTertinggi:
              _getStringValue(dosenData, 'tahun_lulus_tertinggi'),
          statusSertifikasi: _getStringValue(dosenData, 'status_sertifikasi'),
          tahunSertifikasi: _getStringValue(dosenData, 'tahun_sertifikasi'),
          nomorSertifikat: _getStringValue(dosenData, 'nomor_sertifikat'),
          bidangSertifikasi: _getStringValue(dosenData, 'bidang_sertifikasi'),
        );
      } else {
        throw Exception(
            'Gagal mendapatkan detail dosen: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error in getDosenProfile: $e');
      // Return mock data untuk development
      return _createMockDosenDetail(dosenId);
    }
  }

  // Helper method untuk membuat mock data dosen
  DosenDetail _createMockDosenDetail(String dosenId) {
    return DosenDetail(
      idSdm: dosenId,
      namaDosen: 'Dr. John Doe, M.Kom',
      nidn: '0123456789',
      jenisKelamin: 'Laki-laki',
      statusIkatanKerja: 'Tetap',
      statusAktivitas: 'Aktif',
      namaPt: 'Universitas Indonesia',
      namaProdi: 'Teknik Informatika',
      jabatanAkademik: 'Lektor Kepala',
      pendidikanTertinggi: 'S3',
      statusSertifikasi: 'Sudah Sertifikasi',
      tahunSertifikasi: '2015',
    );
  }

  // Helper method untuk mengambil nilai string dengan aman
  static String _getStringValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }

  // Detail PT
  Future<PerguruanTinggiDetail> getDetailPt(String ptId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/pt/detail/${_parseString(ptId)}');

      final response = await _makeApiRequest(url);

      // Parse response - handle both Map and List formats
      final dynamic responseData = await _processApiResponse(
          response, 'Gagal mendapatkan detail perguruan tinggi');

      List<dynamic> ptList = [];

      if (responseData is List) {
        ptList = responseData;
      } else if (responseData is Map<String, dynamic> &&
          responseData.containsKey('pt')) {
        ptList = (responseData['pt'] is List ? (responseData['pt'] is List ? responseData['pt'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
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
      if (kDebugMode) debugPrint('Error: $e');
      if (e.toString().contains('403')) {
        throw Exception(
            'Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Detail program studi
  Future<ProdiDetail> getDetailProdi(String prodiId) async {
    try {
      final Uri url =
          Uri.parse('$baseUrl/prodi/detail/${_parseString(prodiId)}');

      final response = await _makeApiRequest(url);

      // Parse response - handle both Map and List formats
      final dynamic responseData = await _processApiResponse(
          response, 'Gagal mendapatkan detail program studi');

      List<dynamic> prodiList = [];

      if (responseData is List) {
        prodiList = responseData;
      } else if (responseData is Map<String, dynamic> &&
          responseData.containsKey('prodi')) {
        prodiList = (responseData['prodi'] is List ? (responseData['prodi'] is List ? responseData['prodi'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
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
            timeoutSeconds: 10);

        if (descResponse.statusCode == 200) {
          final dynamic descData = json.decode(descResponse.body);

          List<dynamic> descList = [];

          if (descData is List) {
            descList = descData;
          } else if (descData is Map<String, dynamic> &&
              descData.containsKey('prodi')) {
            descList = (descData['prodi'] is List ? descData['prodi'] as List<dynamic> : <dynamic>[]);
          }

          if (descList.isNotEmpty && descList.first is Map<String, dynamic>) {
            descJson = descList.first as Map<String, dynamic>;
          }
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Error mendapatkan deskripsi prodi: $e');
      }

      return ProdiDetail.fromJson(item, descJson);
    } catch (e) {
      if (kDebugMode) debugPrint('Error: $e');
      if (e.toString().contains('403')) {
        throw Exception(
            'Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // List prodi untuk PT tertentu
  Future<List<ProdiPt>> getProdiPt(String ptId, int tahun) async {
    try {
      final Uri url = Uri.parse(
          '$baseUrl/pt/detail/${_parseString(ptId)}/${_parseString(tahun.toString())}');

      final response = await _makeApiRequest(url);

      // Parse response - handle both Map and List formats
      final dynamic responseData = await _processApiResponse(
          response, 'Gagal mendapatkan daftar program studi');

      List<dynamic> prodiList = [];

      if (responseData is List) {
        prodiList = responseData;
      } else if (responseData is Map<String, dynamic> &&
          responseData.containsKey('prodi')) {
        prodiList = (responseData['prodi'] is List ? (responseData['prodi'] is List ? responseData['prodi'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
      } else {
        return [];
      }

      return prodiList
          .map((item) {
            if (item is! Map<String, dynamic>) {
              return ProdiPt.fromJson({});
            }

            try {
              return ProdiPt.fromJson(item);
            } catch (e) {
              return ProdiPt.fromJson({});
            }
          })
          .where((p) => p.idSms.isNotEmpty)
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error: $e');
      if (e.toString().contains('403')) {
        throw Exception(
            'Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Pencarian semua entitas
  Future<Map<String, dynamic>> searchAll(String keyword) async {
    try {
      final Uri url =
          Uri.parse('$baseUrl/pencarian/all/${_parseString(keyword)}');

      final response = await _makeApiRequest(url);

      // Handle case where response might be a list
      final dynamic responseData =
          await _processApiResponse(response, 'Gagal mencari data');

      if (responseData is Map<String, dynamic>) {
        return responseData;
      } else if (responseData is List) {
        // Convert list to map format
        return {'results': responseData};
      } else {
        return {};
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error: $e');
      if (e.toString().contains('403')) {
        throw Exception(
            'Server menolak akses (403 Forbidden). Coba gunakan VPN atau gunakan versi mobile.');
      } else {
        throw Exception('Error: $e');
      }
    }
  }

  // Method untuk mengambil riwayat studi dosen
  Future<List<DosenRiwayatStudi>> getDosenRiwayatStudi(String dosenId) async {
    try {
      final Uri url =
          Uri.parse('$baseUrl/dosen/riwayat_studi/${_parseString(dosenId)}');
      final response = await _makeApiRequest(url);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> dataList = [];

        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('riwayat_studi')) {
          dataList = (responseData['riwayat_studi'] is List ? (responseData['riwayat_studi'] is List ? responseData['riwayat_studi'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
        }

        return dataList
            .map((item) =>
                DosenRiwayatStudi.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting dosen riwayat studi: $e');
    }
    return [];
  }

  // Method untuk mengambil riwayat mengajar dosen
  Future<List<DosenRiwayatMengajar>> getDosenRiwayatMengajar(
      String dosenId) async {
    try {
      final Uri url =
          Uri.parse('$baseUrl/dosen/riwayat_mengajar/${_parseString(dosenId)}');
      final response = await _makeApiRequest(url);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> dataList = [];

        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('riwayat_mengajar')) {
          dataList = (responseData['riwayat_mengajar'] is List ? (responseData['riwayat_mengajar'] is List ? responseData['riwayat_mengajar'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
        }

        return dataList
            .map((item) =>
                DosenRiwayatMengajar.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting dosen riwayat mengajar: $e');
    }
    return [];
  }

  // Method untuk mengambil penelitian dosen
  Future<List<DosenPortofolio>> getDosenPenelitian(String dosenId) async {
    try {
      final Uri url =
          Uri.parse('$baseUrl/dosen/penelitian/${_parseString(dosenId)}');
      final response = await _makeApiRequest(url);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> dataList = [];

        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('penelitian')) {
          dataList = (responseData['penelitian'] is List ? (responseData['penelitian'] is List ? responseData['penelitian'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
        }

        return dataList
            .map((item) =>
                DosenPortofolio.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting dosen penelitian: $e');
    }
    return [];
  }

  // Method untuk mengambil pengabdian dosen
  Future<List<DosenPortofolio>> getDosenPengabdian(String dosenId) async {
    try {
      final Uri url =
          Uri.parse('$baseUrl/dosen/pengabdian/${_parseString(dosenId)}');
      final response = await _makeApiRequest(url);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> dataList = [];

        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('pengabdian')) {
          dataList = (responseData['pengabdian'] is List ? (responseData['pengabdian'] is List ? responseData['pengabdian'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
        }

        return dataList
            .map((item) =>
                DosenPortofolio.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting dosen pengabdian: $e');
    }
    return [];
  }

  // Method untuk mengambil karya dosen
  Future<List<DosenPortofolio>> getDosenKarya(String dosenId) async {
    try {
      final Uri url =
          Uri.parse('$baseUrl/dosen/karya/${_parseString(dosenId)}');
      final response = await _makeApiRequest(url);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> dataList = [];

        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('karya')) {
          dataList = (responseData['karya'] is List ? (responseData['karya'] is List ? responseData['karya'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
        }

        return dataList
            .map((item) =>
                DosenPortofolio.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting dosen karya: $e');
    }
    return [];
  }

  // Method untuk mengambil paten dosen
  Future<List<DosenPortofolio>> getDosenPaten(String dosenId) async {
    try {
      final Uri url =
          Uri.parse('$baseUrl/dosen/paten/${_parseString(dosenId)}');
      final response = await _makeApiRequest(url);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> dataList = [];

        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('paten')) {
          dataList = (responseData['paten'] is List ? (responseData['paten'] is List ? responseData['paten'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
        }

        return dataList
            .map((item) =>
                DosenPortofolio.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting dosen paten: $e');
    }
    return [];
  }

  // Method untuk mengambil riwayat jabatan fungsional dosen
  Future<List<DosenJabatanFungsional>> getDosenRiwayatJabatan(
      String dosenId) async {
    try {
      final Uri url =
          Uri.parse('$baseUrl/dosen/riwayat_jabatan/${_parseString(dosenId)}');
      final response = await _makeApiRequest(url);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> dataList = [];

        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('riwayat_jabatan')) {
          dataList = (responseData['riwayat_jabatan'] is List ? (responseData['riwayat_jabatan'] is List ? responseData['riwayat_jabatan'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
        }

        return dataList
            .map((item) =>
                DosenJabatanFungsional.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting dosen riwayat jabatan: $e');
    }
    return [];
  }

  // Method untuk mengambil riwayat penugasan dosen
  Future<List<DosenPenugasan>> getDosenRiwayatPenugasan(String dosenId) async {
    try {
      final Uri url = Uri.parse(
          '$baseUrl/dosen/riwayat_penugasan/${_parseString(dosenId)}');
      final response = await _makeApiRequest(url);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> dataList = [];

        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('riwayat_penugasan')) {
          dataList = (responseData['riwayat_penugasan'] is List ? (responseData['riwayat_penugasan'] is List ? responseData['riwayat_penugasan'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
        }

        return dataList
            .map(
                (item) => DosenPenugasan.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting dosen riwayat penugasan: $e');
    }
    return [];
  }

  // Method untuk mengambil detail lengkap mahasiswa
  Future<MahasiswaDetail> getMahasiswaDetailLengkap(String mahasiswaId) async {
    try {
      if (kDebugMode) debugPrint('Fetching comprehensive mahasiswa detail for ID: $mahasiswaId');

      // Ambil profil dasar mahasiswa
      final MahasiswaDetail profileDasar =
          await getMahasiswaDetail(mahasiswaId);

      // Ambil data tambahan secara paralel
      final List<Future> futures = [
        getMahasiswaRiwayatSemester(mahasiswaId),
        getMahasiswaRiwayatNilai(mahasiswaId),
        getMahasiswaRiwayatKelas(mahasiswaId),
      ];

      final results = await Future.wait(futures, eagerError: false);

      // Gabungkan semua data
      return MahasiswaDetail(
        id: profileDasar.id,
        nama: profileDasar.nama,
        nim: profileDasar.nim,
        jenisKelamin: profileDasar.jenisKelamin,
        statusSaatIni: profileDasar.statusSaatIni,
        semesterSaatIni: profileDasar.semesterSaatIni,
        tempatLahir: profileDasar.tempatLahir,
        tanggalLahir: profileDasar.tanggalLahir,
        agama: profileDasar.agama,
        alamat: profileDasar.alamat,
        namaPt: profileDasar.namaPt,
        kodePt: profileDasar.kodePt,
        idPt: profileDasar.idPt,
        prodi: profileDasar.prodi,
        kodeProdi: profileDasar.kodeProdi,
        idSms: profileDasar.idSms,
        jenjang: profileDasar.jenjang,
        akreditasiProdi: profileDasar.akreditasiProdi,
        jenisDaftar: profileDasar.jenisDaftar,
        jalurMasuk: profileDasar.jalurMasuk,
        tahunMasuk: profileDasar.tahunMasuk,
        tahunLulus: profileDasar.tahunLulus,
        semesterAktifTerakhir: profileDasar.semesterAktifTerakhir,
        statusAkhir: profileDasar.statusAkhir,
        tanggalLulus: profileDasar.tanggalLulus,
        nomorIjazah: profileDasar.nomorIjazah,
        ipk: profileDasar.ipk,
        totalSks: profileDasar.totalSks,
        predikatKelulusan: profileDasar.predikatKelulusan,
        judulSkripsi: profileDasar.judulSkripsi,
        riwayatSemester: results[0] as List<MahasiswaRiwayatSemester>? ?? [],
        riwayatNilai: results[1] as List<MahasiswaNilai>? ?? [],
        riwayatKelas: results[2] as List<MahasiswaKelas>? ?? [],
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error in getMahasiswaDetailLengkap: $e');
      // Fallback ke profil dasar jika ada error
      return await getMahasiswaDetail(mahasiswaId);
    }
  }

  // Method untuk mengambil riwayat semester mahasiswa
  Future<List<MahasiswaRiwayatSemester>> getMahasiswaRiwayatSemester(
      String mahasiswaId) async {
    try {
      final Uri url = Uri.parse(
          '$baseUrl/mahasiswa/riwayat_semester/${_parseString(mahasiswaId)}');
      final response = await _makeApiRequest(url);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> dataList = [];

        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('riwayat_semester')) {
          dataList = (responseData['riwayat_semester'] is List ? (responseData['riwayat_semester'] is List ? responseData['riwayat_semester'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
        }

        return dataList
            .map((item) =>
                MahasiswaRiwayatSemester.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting mahasiswa riwayat semester: $e');
    }
    return [];
  }

  // Method untuk mengambil riwayat nilai mahasiswa
  Future<List<MahasiswaNilai>> getMahasiswaRiwayatNilai(
      String mahasiswaId) async {
    try {
      final Uri url = Uri.parse(
          '$baseUrl/mahasiswa/riwayat_nilai/${_parseString(mahasiswaId)}');
      final response = await _makeApiRequest(url);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> dataList = [];

        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('riwayat_nilai')) {
          dataList = (responseData['riwayat_nilai'] is List ? (responseData['riwayat_nilai'] is List ? responseData['riwayat_nilai'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
        }

        return dataList
            .map(
                (item) => MahasiswaNilai.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting mahasiswa riwayat nilai: $e');
    }
    return [];
  }

  // Method untuk mengambil riwayat kelas mahasiswa
  Future<List<MahasiswaKelas>> getMahasiswaRiwayatKelas(
      String mahasiswaId) async {
    try {
      final Uri url = Uri.parse(
          '$baseUrl/mahasiswa/riwayat_kelas/${_parseString(mahasiswaId)}');
      final response = await _makeApiRequest(url);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> dataList = [];

        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map<String, dynamic> &&
            responseData.containsKey('riwayat_kelas')) {
          dataList = (responseData['riwayat_kelas'] is List ? (responseData['riwayat_kelas'] is List ? responseData['riwayat_kelas'] as List<dynamic> : <dynamic>[]) : <dynamic>[]);
        }

        return dataList
            .map(
                (item) => MahasiswaKelas.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting mahasiswa riwayat kelas: $e');
    }
    return [];
  }

  // Helper untuk limit string
  int min(int a, int b) {
    return (a < b) ? a : b;
  }
}
