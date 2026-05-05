import 'dart:convert';
import 'dart:math' show min;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/mahasiswa.dart';
import '../models/dosen.dart';
import '../models/prodi.dart';
import '../models/pt.dart';
import 'providers/api_provider.dart';
import 'providers/provider_chain.dart';
import 'cache/cache_store.dart';
import 'cache/cache_policy.dart';
import 'cache/in_memory_cache_store.dart';

class PddiktiApi {
  // Base URL tetap dipakai untuk backward compat (beberapa method masih reference)
  static const String _proxyBaseUrl = 'https://pddikti.fastapicloud.dev/api';
  // Fallback URL handled by ProviderChainService (PddiktiProviders.defaults)
  final String baseUrl = _proxyBaseUrl;

  // Shared HTTP client
  final http.Client _client;

  // Shared cache store — unified, bukan Map primitif lagi
  final CacheStore _cacheStore;

  // Provider Chain — menggantikan _makeApiRequest manual
  late final ProviderChainService _chain;

  /// Constructor — bisa inject dependencies untuk testing
  PddiktiApi({http.Client? client, CacheStore? cacheStore})
      : _client = client ?? http.Client(),
        _cacheStore = cacheStore ?? InMemoryCacheStore() {
    _chain = ProviderChainService(
      providers: PddiktiProviders.defaults.map((p) => ApiProvider(
        id: p.id,
        name: p.name,
        baseUrl: p.baseUrl,
        priority: p.priority,
        enabled: p.enabled,
        timeout: p.timeout,
      )).toList(),
      cacheStore: _cacheStore,
      httpClient: _client,
    );
  }

  // Encode parameter URL
  String _parseString(String text) {
    return Uri.encodeComponent(text);
  }

  // PERF: Helper untuk extract list dari response yang bisa Map atau List
  List<dynamic> _extractList(dynamic responseData, String key) {
    if (responseData is List) return responseData;
    if (responseData is Map<String, dynamic> && responseData.containsKey(key)) {
      final value = responseData[key];
      return value is List ? value : <dynamic>[];
    }
    return <dynamic>[];
  }

  // Proses response API — decode JSON sekali, return parsed data
  dynamic _decodeResponse(http.Response response, String errorMessage) {
    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        if (kDebugMode) debugPrint('Error parsing JSON: $e');
        throw Exception('Format data tidak valid: $e');
      }
    } else {
      if (kDebugMode) debugPrint('HTTP Error: ${response.statusCode}');
      throw Exception('$errorMessage: ${response.statusCode}');
    }
  }

  // Request via ProviderChain — otomatis fallback + cache fresh/stale
  // Backward compat wrapper: return http.Response agar method lama tetap jalan
  Future<http.Response> _makeApiRequest(Uri url,
      {int timeoutSeconds = 15, bool useCache = false}) async {
    // Extract path dari URL (relative to baseUrl)
    final path = url.toString().replaceFirst(_proxyBaseUrl, '');
    final cachePolicy = useCache ? CachePolicy.searchMahasiswa : CachePolicy.health;

    try {
      final result = await _chain.request<String>(
        path: path,
        cachePolicy: cachePolicy,
        decoder: (dynamic data) => data is String ? data : jsonEncode(data),
      );
      // Reconstruct http.Response for backward compat
      return http.Response(result.data, 200);
    } on AllProvidersFailedException catch (e) {
      throw Exception(e.userMessage);
    }
  }

  String jsonEncode(dynamic data) => json.encode(data);

  // Pencarian mahasiswa
  Future<List<Mahasiswa>> searchMahasiswa(String keyword) async {
    try {
      if (kDebugMode) debugPrint('Mencari mahasiswa: $keyword');

      final Uri url =
          Uri.parse('$baseUrl/search/mhs/${_parseString(keyword)}/');

      // PERF: use cache for search results, removed print() debug statements
      final response = await _makeApiRequest(url, useCache: true);
      final dynamic responseData = _decodeResponse(response, 'Gagal mencari mahasiswa');

      final mhsList = _extractList(responseData, 'mahasiswa');
      if (mhsList.isEmpty && responseData is! List) return [];

      if (kDebugMode) debugPrint('Ditemukan ${mhsList.length} mahasiswa');

      return mhsList
          .map((item) {
            if (item is! Map<String, dynamic>) return Mahasiswa.fromJson({});
            try {
              return Mahasiswa.fromJson(item);
            } catch (e) {
              if (kDebugMode) debugPrint('Error parsing Mahasiswa: $e');
              return Mahasiswa.fromJson({});
            }
          })
          .where((m) => m.id.isNotEmpty)
          .toList();
    } on Exception {
      rethrow;
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
          Uri.parse('$baseUrl/search/dosen/${_parseString(keyword)}/');

      final response = await _makeApiRequest(url, useCache: true);

      // PERF: Single decode, no redundant statusCode check (_decodeResponse handles it)
      final dynamic responseData =
          _decodeResponse(response, 'Gagal mencari dosen');

      // PERF: Use _extractList helper — eliminates redundant double is-List checks
      final dosenList = _extractList(responseData, 'dosen');
      if (dosenList.isEmpty && responseData is! List) return [];

      return dosenList
          .map((item) {
            if (item is! Map<String, dynamic>) return Dosen.fromJson({});
            try {
              return Dosen.fromJson(item);
            } catch (e) {
              return Dosen.fromJson({});
            }
          })
          .where((d) => d.id.isNotEmpty)
          .toList();
    } on Exception {
      rethrow;
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
          Uri.parse('$baseUrl/search/pt/${_parseString(keyword)}/');

      final response = await _makeApiRequest(url, useCache: true);
      final dynamic responseData = _decodeResponse(
          response, 'Gagal mencari perguruan tinggi');

      final ptList = _extractList(responseData, 'pt');
      if (ptList.isEmpty && responseData is! List) return [];

      return ptList
          .map((item) {
            if (item is! Map<String, dynamic>) return PerguruanTinggi.fromJson({});
            try {
              return PerguruanTinggi.fromJson(item);
            } catch (e) {
              return PerguruanTinggi.fromJson({});
            }
          })
          .where((pt) => pt.id.isNotEmpty)
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

  // Pencarian prodi
  Future<List<Prodi>> searchProdi(String keyword) async {
    try {
      if (kDebugMode) debugPrint('Mencari program studi: $keyword');

      final Uri url =
          Uri.parse('$baseUrl/search/prodi/${_parseString(keyword)}/');

      final response = await _makeApiRequest(url, useCache: true);
      final dynamic responseData =
          _decodeResponse(response, 'Gagal mencari program studi');

      final prodiList = _extractList(responseData, 'prodi');
      if (prodiList.isEmpty && responseData is! List) return [];

      return prodiList
          .map((item) {
            if (item is! Map<String, dynamic>) return Prodi.fromJson({});
            try {
              return Prodi.fromJson(item);
            } catch (e) {
              return Prodi.fromJson({});
            }
          })
          .where((p) => p.id.isNotEmpty)
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

  // Detail mahasiswa
  Future<MahasiswaDetail> getMahasiswaDetail(String mahasiswaId) async {
    try {
      if (kDebugMode) debugPrint('Fetching mahasiswa detail for ID: $mahasiswaId');

      // The API might expect a different format of ID, let's try to handle both formats
      String processedId = mahasiswaId;
      // If the ID is base64, we keep it as is, otherwise we might need to encode it
      // This step is precautionary in case the ID format is different

      final Uri url =
          Uri.parse('$baseUrl/mhs/detail/${_parseString(processedId)}/');
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
    // BUG-FIX: Fetch profile dulu, simpan hasilnya — jangan re-fetch di catch
    late final DosenDetail profileDasar;
    try {
      if (kDebugMode) debugPrint('Fetching comprehensive dosen detail for ID: $dosenId');
      profileDasar = await getDosenProfile(dosenId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching dosen profile: $e');
      rethrow; // Kalau profile dasar gagal, ga ada fallback
    }

    try {
      // Ambil data tambahan secara paralel
      // BUG-H3 FIX: Wrap each future individually to handle partial failures safely
      final riwayatStudi = await getDosenRiwayatStudi(dosenId).catchError((_) => <DosenRiwayatStudi>[]);
      final futures = await Future.wait([
        getDosenRiwayatMengajar(dosenId).catchError((_) => <DosenRiwayatMengajar>[]),
        getDosenPenelitian(dosenId).catchError((_) => <DosenPortofolio>[]),
        getDosenPengabdian(dosenId).catchError((_) => <DosenPortofolio>[]),
        getDosenKarya(dosenId).catchError((_) => <DosenPortofolio>[]),
        getDosenPaten(dosenId).catchError((_) => <DosenPortofolio>[]),
        getDosenRiwayatJabatan(dosenId).catchError((_) => <DosenJabatanFungsional>[]),
        getDosenRiwayatPenugasan(dosenId).catchError((_) => <DosenPenugasan>[]),
      ]);

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
        riwayatStudi: riwayatStudi,
        riwayatMengajar: futures[0] as List<DosenRiwayatMengajar>,
        penelitian: futures[1] as List<DosenPortofolio>,
        pengabdian: futures[2] as List<DosenPortofolio>,
        karya: futures[3] as List<DosenPortofolio>,
        paten: futures[4] as List<DosenPortofolio>,
        riwayatJabatan: futures[5] as List<DosenJabatanFungsional>,
        riwayatPenugasan: futures[6] as List<DosenPenugasan>,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error in getDosenDetailLengkap: $e');
      // PERF-FIX: Return already-fetched profileDasar instead of re-fetching
      return profileDasar;
    }
  }

  // Detail dosen profil dasar
  // PERF-FIX C1: Parallel endpoint race via Future.any — worst case 5s instead of 45s
  Future<DosenDetail> getDosenProfile(String dosenId) async {
    try {
      if (kDebugMode) debugPrint('Fetching dosen profile for ID: $dosenId');

      final endpoints = [
        '$baseUrl/dosen/profile/${_parseString(dosenId)}/',
      ];

      // Single proxy endpoint — proper SSL, no cert issues
      final response = await _makeApiRequest(
        Uri.parse(endpoints.first),
        timeoutSeconds: 10,
      );
      if (response.statusCode != 200) {
        throw Exception('Gagal mendapatkan profil dosen: ${response.statusCode}');
      }

      final dynamic responseData = json.decode(response.body);
      Map<String, dynamic> dosenData = {};

      if (responseData is List && responseData.isNotEmpty) {
        dosenData = responseData[0] as Map<String, dynamic>;
      } else if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('dosen') && responseData['dosen'] is List) {
          final dosenList = responseData['dosen'] as List;
          if (dosenList.isNotEmpty) {
            dosenData = dosenList[0] as Map<String, dynamic>;
          }
        } else {
          dosenData = responseData;
        }
      }

      final idSdm = _getStringValue(dosenData, 'id_sdm');
      final namaDosen = _getStringValue(dosenData, 'nama_dosen');

      return DosenDetail(
        idSdm: idSdm.isNotEmpty ? idSdm : dosenId,
        namaDosen: namaDosen.isNotEmpty ? namaDosen
            : (_getStringValue(dosenData, 'nama').isNotEmpty
                ? _getStringValue(dosenData, 'nama') : 'Tidak tersedia'),
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
        namaProdi: _getStringValue(dosenData, 'nama_prodi').isNotEmpty
            ? _getStringValue(dosenData, 'nama_prodi')
            : _getStringValue(dosenData, 'prodi'),
        homePt: _getStringValue(dosenData, 'home_pt'),
        homeProdi: _getStringValue(dosenData, 'home_prodi'),
        rasioHomebase: _getStringValue(dosenData, 'rasio_homebase'),
        statusHomebase: _getStringValue(dosenData, 'status_homebase'),
        jabatanAkademik: _getStringValue(dosenData, 'jabatan_akademik'),
        tanggalSk: _getStringValue(dosenData, 'tanggal_sk'),
        tmtJabatan: _getStringValue(dosenData, 'tmt_jabatan'),
        nomorSk: _getStringValue(dosenData, 'nomor_sk'),
        pendidikanTertinggi: _getStringValue(dosenData, 'pendidikan_tertinggi'),
        bidangIlmu: _getStringValue(dosenData, 'bidang_ilmu'),
        institusiPendidikan: _getStringValue(dosenData, 'institusi_pendidikan'),
        tahunLulusTertinggi: _getStringValue(dosenData, 'tahun_lulus_tertinggi'),
        statusSertifikasi: _getStringValue(dosenData, 'status_sertifikasi'),
        tahunSertifikasi: _getStringValue(dosenData, 'tahun_sertifikasi'),
        nomorSertifikat: _getStringValue(dosenData, 'nomor_sertifikat'),
        bidangSertifikasi: _getStringValue(dosenData, 'bidang_sertifikasi'),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error in getDosenProfile: $e');
      // BUG-H2 FIX: Throw instead of silently returning mock data
      // Let the caller (ApiFactory) handle fallback with proper UI indication
      throw Exception('Gagal mendapatkan profil dosen: $e');
    }
  }

  // H2-FIX: _createMockDosenDetail removed — mock data should not be silently returned as real

  // Helper method untuk mengambil nilai string dengan aman
  static String _getStringValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }

  // Detail PT
  Future<PerguruanTinggiDetail> getDetailPt(String ptId) async {
    try {
      final Uri url = Uri.parse('$baseUrl/pt/detail/${_parseString(ptId)}/');

      final response = await _makeApiRequest(url);
      final dynamic responseData = _decodeResponse(
          response, 'Gagal mendapatkan detail perguruan tinggi');

      final ptList = _extractList(responseData, 'pt');
      if (ptList.isEmpty) throw Exception('Detail perguruan tinggi kosong');

      final item = ptList.first;
      if (item is! Map<String, dynamic>) throw Exception('Format data tidak valid');

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
          Uri.parse('$baseUrl/prodi/detail/${_parseString(prodiId)}/');

      final response = await _makeApiRequest(url);

      final dynamic responseData = _decodeResponse(
          response, 'Gagal mendapatkan detail program studi');

      final prodiList = _extractList(responseData, 'prodi');
      if (prodiList.isEmpty) throw Exception('Detail program studi kosong');

      final item = prodiList.first;
      if (item is! Map<String, dynamic>) throw Exception('Format data tidak valid');

      // Ambil deskripsi prodi jika tersedia
      Map<String, dynamic>? descJson;
      try {
        final descResponse = await _makeApiRequest(
            Uri.parse('$baseUrl/prodi/desc/${_parseString(prodiId)}/'),
            timeoutSeconds: 10);

        if (descResponse.statusCode == 200) {
          final dynamic descData = json.decode(descResponse.body);
          final descList = _extractList(descData, 'prodi');
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
          '$baseUrl/pt/prodi/${_parseString(ptId)}/${_parseString(tahun.toString())}');

      final response = await _makeApiRequest(url);
      final dynamic responseData = _decodeResponse(
          response, 'Gagal mendapatkan daftar program studi');

      final prodiList = _extractList(responseData, 'prodi');
      if (prodiList.isEmpty && responseData is! List) return [];

      return prodiList
          .map((item) {
            if (item is! Map<String, dynamic>) return ProdiPt.fromJson({});
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
          Uri.parse('$baseUrl/search/all/${_parseString(keyword)}/');

      final response = await _makeApiRequest(url, useCache: true);
      final dynamic responseData =
          _decodeResponse(response, 'Gagal mencari data');

      if (responseData is Map<String, dynamic>) {
        return responseData;
      } else if (responseData is List) {
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

  // PERF: Generic helper untuk fetch list data dosen — eliminates 8x copy-paste pattern
  Future<List<T>> _fetchDosenList<T>(
    String dosenId, String endpoint, String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final Uri url = Uri.parse('$baseUrl/dosen/$endpoint/${_parseString(dosenId)}/');
      final response = await _makeApiRequest(url);
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        final dataList = _extractList(responseData, key);
        return dataList
            .whereType<Map<String, dynamic>>()
            .map(fromJson)
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting dosen $endpoint: $e');
    }
    return [];
  }

  // Method untuk mengambil riwayat studi dosen
  // FIX: Proxy API uses 'study-history' instead of 'riwayat_studi'
  Future<List<DosenRiwayatStudi>> getDosenRiwayatStudi(String dosenId) =>
      _fetchDosenList(dosenId, 'study-history', 'riwayat_studi', DosenRiwayatStudi.fromJson);

  // Method untuk mengambil riwayat mengajar dosen
  // FIX: Proxy API uses 'teaching-history' instead of 'riwayat_mengajar'
  Future<List<DosenRiwayatMengajar>> getDosenRiwayatMengajar(String dosenId) =>
      _fetchDosenList(dosenId, 'teaching-history', 'riwayat_mengajar', DosenRiwayatMengajar.fromJson);

  // Method untuk mengambil penelitian dosen
  Future<List<DosenPortofolio>> getDosenPenelitian(String dosenId) =>
      _fetchDosenList(dosenId, 'penelitian', 'penelitian', DosenPortofolio.fromJson);

  // Method untuk mengambil pengabdian dosen
  Future<List<DosenPortofolio>> getDosenPengabdian(String dosenId) =>
      _fetchDosenList(dosenId, 'pengabdian', 'pengabdian', DosenPortofolio.fromJson);

  // Method untuk mengambil karya dosen
  Future<List<DosenPortofolio>> getDosenKarya(String dosenId) =>
      _fetchDosenList(dosenId, 'karya', 'karya', DosenPortofolio.fromJson);

  // Method untuk mengambil paten dosen
  Future<List<DosenPortofolio>> getDosenPaten(String dosenId) =>
      _fetchDosenList(dosenId, 'paten', 'paten', DosenPortofolio.fromJson);

  // Method untuk mengambil riwayat jabatan fungsional dosen
  Future<List<DosenJabatanFungsional>> getDosenRiwayatJabatan(String dosenId) =>
      _fetchDosenList(dosenId, 'riwayat_jabatan', 'riwayat_jabatan', DosenJabatanFungsional.fromJson);

  // Method untuk mengambil riwayat penugasan dosen
  Future<List<DosenPenugasan>> getDosenRiwayatPenugasan(String dosenId) =>
      _fetchDosenList(dosenId, 'riwayat_penugasan', 'riwayat_penugasan', DosenPenugasan.fromJson);

  // Method untuk mengambil detail lengkap mahasiswa
  // PERF-FIX: Same pattern as dosen — fetch profile first, use catchError per sub-future
  Future<MahasiswaDetail> getMahasiswaDetailLengkap(String mahasiswaId) async {
    late final MahasiswaDetail profileDasar;
    try {
      if (kDebugMode) debugPrint('Fetching comprehensive mahasiswa detail for ID: $mahasiswaId');
      profileDasar = await getMahasiswaDetail(mahasiswaId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching mahasiswa profile: $e');
      rethrow;
    }

    try {
      // Ambil data tambahan secara paralel — each wrapped with catchError for safety
      final results = await Future.wait([
        getMahasiswaRiwayatSemester(mahasiswaId).catchError((_) => <MahasiswaRiwayatSemester>[]),
        getMahasiswaRiwayatNilai(mahasiswaId).catchError((_) => <MahasiswaNilai>[]),
        getMahasiswaRiwayatKelas(mahasiswaId).catchError((_) => <MahasiswaKelas>[]),
      ]);

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
        riwayatSemester: results[0] as List<MahasiswaRiwayatSemester>,
        riwayatNilai: results[1] as List<MahasiswaNilai>,
        riwayatKelas: results[2] as List<MahasiswaKelas>,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error in getMahasiswaDetailLengkap: $e');
      // PERF-FIX: Return already-fetched profileDasar instead of re-fetching
      return profileDasar;
    }
  }

  // PERF: Generic helper untuk fetch list data mahasiswa
  Future<List<T>> _fetchMahasiswaList<T>(
    String mahasiswaId, String endpoint, String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final Uri url = Uri.parse('$baseUrl/mhs/$endpoint/${_parseString(mahasiswaId)}/');
      final response = await _makeApiRequest(url);
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        final dataList = _extractList(responseData, key);
        return dataList
            .whereType<Map<String, dynamic>>()
            .map(fromJson)
            .toList();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting mahasiswa $endpoint: $e');
    }
    return [];
  }

  // Method untuk mengambil riwayat semester mahasiswa
  Future<List<MahasiswaRiwayatSemester>> getMahasiswaRiwayatSemester(String mahasiswaId) =>
      _fetchMahasiswaList(mahasiswaId, 'riwayat_semester', 'riwayat_semester', MahasiswaRiwayatSemester.fromJson);

  // Method untuk mengambil riwayat nilai mahasiswa
  Future<List<MahasiswaNilai>> getMahasiswaRiwayatNilai(String mahasiswaId) =>
      _fetchMahasiswaList(mahasiswaId, 'riwayat_nilai', 'riwayat_nilai', MahasiswaNilai.fromJson);

  // Method untuk mengambil riwayat kelas mahasiswa
  Future<List<MahasiswaKelas>> getMahasiswaRiwayatKelas(String mahasiswaId) =>
      _fetchMahasiswaList(mahasiswaId, 'riwayat_kelas', 'riwayat_kelas', MahasiswaKelas.fromJson);

  // M2-FIX: Custom min() removed — using dart:math min() instead
}
