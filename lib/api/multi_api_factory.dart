import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mahasiswa.dart';
import '../models/dosen.dart';
import '../models/pt.dart';
import '../models/prodi.dart';
import 'api_factory.dart';
import 'api_services_integration.dart';

/// Class untuk mengakses berbagai API pendidikan Indonesia selain PDDIKTI
/// Menggabungkan data dari berbagai sumber untuk meningkatkan hasil pencarian
class MultiApiFactory {
  /// Singleton instance
  static final MultiApiFactory _instance = MultiApiFactory._internal();

  /// Private constructor
  MultiApiFactory._internal();

  /// Factory constructor
  factory MultiApiFactory() {
    return _instance;
  }

  /// API Factory untuk PDDIKTI
  final ApiFactory _pddiktiApi = ApiFactory();

  /// API Services Integration
  final ApiServicesIntegration _apiServices = ApiServicesIntegration();

  /// Base URL untuk API Data Mahasiswa Kemdikbud
  /// NOTE: api-frontend.kemdikbud.go.id is DEAD (NXDOMAIN since ~2025).
  /// Disabled — searches now rely on PDDIKTI proxy providers only.
  final String _kemdikbudApiUrl = '';

  /// Header untuk request — cached as final to avoid Map recreation per access
  final Map<String, String> _headers = const {
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'en-US,en;q=0.9,id;q=0.8',
        'Origin': 'https://indonesia-public-static-api.vercel.app',
        'Referer': 'https://indonesia-public-static-api.vercel.app',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36',
      };

  /// Encode parameter URL
  String _parseString(String text) {
    return Uri.encodeComponent(text);
  }

  /// Wrap future dengan try-catch biar partial failure ga bikin semua gagal
  Future<List<Mahasiswa>> _safeSearch(Future<List<Mahasiswa>> future) async {
    try {
      return await future;
    } catch (e) {
      if (kDebugMode) debugPrint('Partial search failed: $e');
      return [];
    }
  }

  /// Metode utama untuk mencari data mahasiswa dari berbagai sumber API
  Future<List<Mahasiswa>> searchAllSources(String keyword) async {
    List<Mahasiswa> results = [];
    List<Future<List<Mahasiswa>>> futures = [];

    // Cari data dari PDDIKTI
    futures.add(_pddiktiApi.searchMahasiswa(keyword));

    // Cari data dari Kemdikbud
    futures.add(_searchKemdikbud(keyword));

    // Cari data dari API lain dan konversi ke model Mahasiswa
    futures.add(_searchFromEducationApis(keyword));

    // Jalankan semua pencarian secara paralel dengan error isolation
    final responses = await Future.wait(
      futures.map((f) => _safeSearch(f)).toList(),
    );

    // Gabungkan semua hasil
    for (var response in responses) {
      results.addAll(response);
    }

    // Hapus duplikat berdasarkan kombinasi nama dan nim
    final uniqueResults = <String, Mahasiswa>{};
    for (var mahasiswa in results) {
      final key = '${mahasiswa.nama}-${mahasiswa.nim}';
      uniqueResults[key] = mahasiswa;
    }

    return uniqueResults.values.toList();
  }

  /// Cari data mahasiswa dari API pendidikan lain
  Future<List<Mahasiswa>> _searchFromEducationApis(String keyword) async {
    try {
      // Dapatkan data dari API pendidikan
      final rawData = await _apiServices.searchEducationData(keyword);

      // Konversi ke model Mahasiswa
      return _apiServices.convertToMahasiswa(rawData);
    } catch (e) {
      if (kDebugMode) debugPrint('Error mencari dari API pendidikan: $e');
      return [];
    }
  }

  /// Cari data mahasiswa dari API Kemdikbud
  /// DISABLED: api-frontend.kemdikbud.go.id domain no longer exists (NXDOMAIN).
  /// Returns empty immediately to avoid DNS lookup timeout.
  Future<List<Mahasiswa>> _searchKemdikbud(String keyword) async {
    // Domain is dead (NXDOMAIN) — skip immediately to avoid 10s DNS timeout
    return [];

    try {
      final Uri url =
          Uri.parse('$_kemdikbudApiUrl/hit_mhs/${_parseString(keyword)}');

      final response = await http
          .get(
            url,
            headers: _headers,
          )
          .timeout(
            Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('mahasiswa') && data['mahasiswa'] is List) {
          final List mahasiswaList = data['mahasiswa'] as List;

          return mahasiswaList
              .map((item) {
                if (item is Map<String, dynamic>) {
                  return Mahasiswa(
                    id: item['id_mahasiswa'] ?? '',
                    nama: item['nm_mhs'] ?? '',
                    nim: item['nipd'] ?? '',
                    namaPt: item['nm_pt'] ?? '',
                    singkatanPt: item['kode_pt'] ?? '',
                    namaProdi: item['nm_prodi'] ?? '',
                  );
                }
                return Mahasiswa(
                  id: '',
                  nama: '',
                  nim: '',
                  namaPt: '',
                  singkatanPt: '',
                  namaProdi: '',
                );
              })
              .where((m) => m.id.isNotEmpty)
              .toList();
        }
      }

      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Error mencari dari Kemdikbud: $e');
      return [];
    }
  }

  /// Wrap future dengan try-catch biar partial failure ga bikin semua gagal
  Future<List<Dosen>> _safeSearchDosen(Future<List<Dosen>> future) async {
    try {
      return await future;
    } catch (e) {
      if (kDebugMode) debugPrint('Partial dosen search failed: $e');
      return [];
    }
  }

  /// Cari data dosen dari berbagai sumber
  Future<List<Dosen>> searchAllDosen(String keyword) async {
    try {
      List<Dosen> results = [];
      List<Future<List<Dosen>>> futures = [];

      // Cari dari PDDIKTI
      futures.add(_pddiktiApi.searchDosen(keyword));

      // Cari dari API lain
      futures.add(_searchDosenFromOtherSources(keyword));

      // BUG-C1 FIX: Jalankan dengan error isolation (sama kayak searchAllSources)
      final responses = await Future.wait(
        futures.map((f) => _safeSearchDosen(f)).toList(),
      );

      // Gabungkan semua hasil
      for (var response in responses) {
        results.addAll(response);
      }

      // Hapus duplikat berdasarkan kombinasi nama dan nidn
      final uniqueResults = <String, Dosen>{};
      for (var dosen in results) {
        final key = '${dosen.nama}-${dosen.nidn}';
        uniqueResults[key] = dosen;
      }

      return uniqueResults.values.toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error mencari dosen: $e');
      // Jika terjadi error, coba kembalikan apa saja yang berhasil
      List<Dosen> backupResults = [];

      try {
        // Coba dapatkan dari mock service sebagai fallback
        backupResults = await _pddiktiApi.searchDosen(keyword);
      } catch (e2) {
        if (kDebugMode) debugPrint('Error getting data from PDDIKTI: $e2');

        // Jika masih error, return empty list daripada data dummy
        backupResults = [];
      }

      return backupResults;
    }
  }

  /// Implementasi pencarian dosen dari sumber lain
  Future<List<Dosen>> _searchDosenFromOtherSources(String keyword) async {
    try {
      // Dapatkan data dari API pendidikan
      final rawData = await _apiServices.searchEducationData(keyword);

      // Konversi ke model Dosen
      return _apiServices.convertToDosen(rawData);
    } catch (e) {
      if (kDebugMode) debugPrint('Error mencari dosen dari sumber lain: $e');
      return [];
    }
  }

  /// Mendapatkan detail mahasiswa dari berbagai sumber (lengkap + enrichment)
  Future<MahasiswaDetail> getMahasiswaDetail(String mahasiswaId) async {
    try {
      // Gunakan getMahasiswaDetailLengkap untuk data lebih lengkap (termasuk riwayat)
      final detail = await _pddiktiApi.getMahasiswaDetailLengkap(mahasiswaId);

      // Enrichment: Coba lengkapi field kosong dari sumber tambahan
      return await _enrichMahasiswaDetail(detail);
    } catch (e) {
      if (kDebugMode) debugPrint('Error mendapatkan detail lengkap, fallback ke basic: $e');

      // Fallback ke basic detail
      try {
        final basicDetail = await _pddiktiApi.getMahasiswaDetail(mahasiswaId);
        return await _enrichMahasiswaDetail(basicDetail);
      } catch (e2) {
        if (kDebugMode) debugPrint('Error mendapatkan detail basic: $e2');

        // Fallback to minimal detail
        return MahasiswaDetail(
          id: mahasiswaId,
          namaPt: 'Data tidak tersedia (error)',
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

  /// Enrichment: Lengkapi field kosong dari sumber API tambahan
  Future<MahasiswaDetail> _enrichMahasiswaDetail(MahasiswaDetail detail) async {
    // Hitung IPK dan total SKS dari riwayat semester jika field kosong
    String enrichedIpk = detail.ipk;
    String enrichedTotalSks = detail.totalSks;
    String enrichedTahunMasuk = detail.tahunMasuk;

    // Kalkulasi IPK dari riwayat semester jika belum ada
    if (enrichedIpk.isEmpty && detail.riwayatSemester.isNotEmpty) {
      // IPK terakhir biasanya ada di semester terakhir
      final lastSemester = detail.riwayatSemester.last;
      if (lastSemester.ipk.isNotEmpty) {
        enrichedIpk = lastSemester.ipk;
      }
    }

    // Kalkulasi total SKS dari riwayat semester jika belum ada
    if (enrichedTotalSks.isEmpty && detail.riwayatSemester.isNotEmpty) {
      int totalSks = 0;
      for (var sem in detail.riwayatSemester) {
        final sks = int.tryParse(sem.sksLulus) ?? 0;
        totalSks += sks;
      }
      if (totalSks > 0) enrichedTotalSks = totalSks.toString();

      // Atau ambil dari semester terakhir jika ada sksTotal
      if (enrichedTotalSks.isEmpty) {
        final lastSem = detail.riwayatSemester.last;
        if (lastSem.sksTotal.isNotEmpty) enrichedTotalSks = lastSem.sksTotal;
      }
    }

    // Estimasi tahun masuk dari tanggal_masuk jika belum ada
    if (enrichedTahunMasuk.isEmpty && detail.riwayatSemester.isNotEmpty) {
      // Coba parse dari nama semester pertama (format: "20211" = 2021 ganjil)
      final firstSem = detail.riwayatSemester.first;
      if (firstSem.namaSemester.length >= 4) {
        final yearStr = firstSem.namaSemester.substring(0, 4);
        if (int.tryParse(yearStr) != null) {
          enrichedTahunMasuk = yearStr;
        }
      }
    }

    // Return enriched detail
    return MahasiswaDetail(
      id: detail.id,
      nama: detail.nama,
      nim: detail.nim,
      jenisKelamin: detail.jenisKelamin,
      statusSaatIni: detail.statusSaatIni,
      semesterSaatIni: detail.semesterSaatIni,
      tempatLahir: detail.tempatLahir,
      tanggalLahir: detail.tanggalLahir,
      agama: detail.agama,
      alamat: detail.alamat,
      namaPt: detail.namaPt,
      kodePt: detail.kodePt,
      idPt: detail.idPt,
      prodi: detail.prodi,
      kodeProdi: detail.kodeProdi,
      idSms: detail.idSms,
      jenjang: detail.jenjang,
      akreditasiProdi: detail.akreditasiProdi,
      jenisDaftar: detail.jenisDaftar,
      jalurMasuk: detail.jalurMasuk,
      tahunMasuk: enrichedTahunMasuk.isNotEmpty ? enrichedTahunMasuk : detail.tahunMasuk,
      tahunLulus: detail.tahunLulus,
      semesterAktifTerakhir: detail.semesterAktifTerakhir,
      statusAkhir: detail.statusAkhir,
      tanggalLulus: detail.tanggalLulus,
      nomorIjazah: detail.nomorIjazah,
      ipk: enrichedIpk.isNotEmpty ? enrichedIpk : detail.ipk,
      totalSks: enrichedTotalSks.isNotEmpty ? enrichedTotalSks : detail.totalSks,
      predikatKelulusan: detail.predikatKelulusan,
      judulSkripsi: detail.judulSkripsi,
      riwayatSemester: detail.riwayatSemester,
      riwayatNilai: detail.riwayatNilai,
      riwayatKelas: detail.riwayatKelas,
    );
  }

  /// Mendapatkan detail dosen lengkap dari berbagai sumber
  Future<DosenDetail> getDosenDetailFromAllSources(String dosenId) async {
    try {
      // Coba dapatkan detail lengkap dari PDDIKTI terlebih dahulu
      final detail = await _pddiktiApi.getDosenDetailLengkap(dosenId);

      // Tambahkan data eksternal jika ada
      try {
        // Coba untuk memperkaya data dengan sumber-sumber lain jika ada waktu
        // Ini bisa diimplementasikan di masa mendatang
      } catch (e) {
        if (kDebugMode) debugPrint('Gagal mendapatkan data tambahan: $e');
        // Tidak perlu melakukan apa-apa, gunakan data yang sudah ada
      }

      return detail;
    } catch (e) {
      if (kDebugMode) debugPrint('Error mendapatkan detail dari PDDIKTI: $e');

      // Fallback to minimal detail
      return DosenDetail(
        idSdm: dosenId,
        namaDosen: 'Data tidak tersedia (error)',
        namaPt: 'Data tidak tersedia',
        namaProdi: 'Data tidak tersedia',
        jenisKelamin: '-',
        jabatanAkademik: '-',
        pendidikanTertinggi: '-',
        statusIkatanKerja: '-',
        statusAktivitas: '-',
        penelitian: [],
        pengabdian: [],
        karya: [],
        paten: [],
        riwayatStudi: [],
        riwayatMengajar: [],
      );
    }
  }

  // BUG-C2 FIX: _searchKemdikbudDetail removed — endpoint likely dead (Kemdikbud → Kemdiktisaintek)
  // and it was overriding complete PDDIKTI data with minimal 12-field response

  /// Mendapatkan informasi Perguruan Tinggi
  Future<PerguruanTinggiDetail?> getDetailPT(String ptId) async {
    try {
      // Gunakan API PDDIKTI untuk mendapatkan detail PT
      final detail = await _pddiktiApi.getDetailPt(ptId);
      return detail;
    } catch (e) {
      if (kDebugMode) debugPrint('Error mendapatkan detail PT: $e');

      // Buat data dummy jika error
      return PerguruanTinggiDetail(
        kelompok: '-',
        pembina: '-',
        idSp: ptId,
        kodePt: '-',
        email: '-',
        noTel: '-',
        noFax: '-',
        website: '-',
        alamat: 'Data tidak tersedia',
        namaPt: 'Universitas tidak tersedia',
        nmSingkat: '-',
        kodePos: '-',
        provinsiPt: '-',
        kabKotaPt: '-',
        kecamatanPt: '-',
        lintangPt: '-',
        bujurPt: '-',
        tglBerdiriPt: '-',
        tglSkPendirianSp: '-',
        skPendirianSp: '-',
        statusPt: '-',
        akreditasiPt: '-',
        statusAkreditasi: '-',
      );
    }
  }

  /// Mendapatkan informasi Program Studi
  Future<ProdiDetail?> getDetailProdi(String prodiId) async {
    try {
      // Gunakan API PDDIKTI untuk mendapatkan detail Prodi
      final detail = await _pddiktiApi.getDetailProdi(prodiId);
      return detail;
    } catch (e) {
      if (kDebugMode) debugPrint('Error mendapatkan detail Prodi: $e');

      // Buat data dummy jika error
      return ProdiDetail(
        idSp: '-',
        idSms: prodiId,
        namaPt: 'Data tidak tersedia',
        kodePt: '-',
        namaProdi: 'Program Studi tidak tersedia',
        kodeProdi: '-',
        kelBidang: '-',
        jenjangDidik: '-',
        tglBerdiri: '-',
        tglSkSelenggara: '-',
        skSelenggara: '-',
        noTel: '-',
        noFax: '-',
        website: '-',
        email: '-',
        alamat: '-',
        provinsi: '-',
        kabKota: '-',
        kecamatan: '-',
        lintang: '-',
        bujur: '-',
        status: '-',
        akreditasi: '-',
        akreditasiInternasional: '-',
        statusAkreditasi: '-',
        deskripsiSingkat: '-',
        visi: '-',
        misi: '-',
        kompetensi: '-',
        capaianBelajar: '-',
        rataMasaStudi: '-',
      );
    }
  }

  /// Mencari data Program Studi
  Future<List<Prodi>> searchProdi(String keyword) async {
    try {
      // Gunakan API PDDIKTI untuk mencari Prodi
      return await _pddiktiApi.searchProdi(keyword);
    } catch (e) {
      if (kDebugMode) debugPrint('Error mencari Prodi: $e');
      return [];
    }
  }

  /// Mencari data Perguruan Tinggi
  Future<List<PerguruanTinggi>> searchPT(String keyword) async {
    try {
      // Gunakan API PDDIKTI untuk mencari PT
      return await _pddiktiApi.searchPt(keyword);
    } catch (e) {
      if (kDebugMode) debugPrint('Error mencari PT: $e');
      return [];
    }
  }

  /// Mendapatkan daftar Prodi di PT tertentu
  Future<List<ProdiPt>> getProdiInPT(String ptId, int tahun) async {
    try {
      // Gunakan API PDDIKTI untuk mendapatkan daftar Prodi
      return await _pddiktiApi.getProdiPt(ptId, tahun);
    } catch (e) {
      if (kDebugMode) debugPrint('Error mendapatkan daftar Prodi di PT: $e');
      return [];
    }
  }

  /// Mencari data lokasi prodi
  Future<Map<String, String>> getProdiLocation(String prodiId) async {
    try {
      // Gunakan detail Prodi untuk mendapatkan lokasinya
      final prodiDetail = await getDetailProdi(prodiId);
      if (prodiDetail != null) {
        return {
          'latitude': prodiDetail.lintang,
          'longitude': prodiDetail.bujur,
          'address': prodiDetail.alamat,
          'city': prodiDetail.kabKota,
          'province': prodiDetail.provinsi,
        };
      }
      return {};
    } catch (e) {
      if (kDebugMode) debugPrint('Error mendapatkan lokasi Prodi: $e');
      return {};
    }
  }
}
