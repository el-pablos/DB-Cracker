import 'package:flutter/material.dart';

class PerguruanTinggi {
  final String id;
  final String kode;
  final String namaSingkat;
  final String nama;

  PerguruanTinggi({
    required this.id,
    required this.kode,
    required this.namaSingkat,
    required this.nama,
  });

  factory PerguruanTinggi.fromJson(Map<String, dynamic> json) {
    try {
      return PerguruanTinggi(
        id: _getStringValue(json, 'id'),
        kode: _getStringValue(json, 'kode'),
        namaSingkat: _getStringValue(json, 'nama_singkat'),
        nama: _getStringValue(json, 'nama'),
      );
    } catch (e) {
      print('Error parsing PerguruanTinggi: $e');
      print('JSON data: $json');
      // Return objek dengan field kosong daripada melempar error
      return PerguruanTinggi(
        id: '',
        kode: '',
        namaSingkat: '',
        nama: 'Error: ${e.toString().substring(0, min(30, e.toString().length))}',
      );
    }
  }

  // Helper method untuk mengambil nilai string dengan aman
  static String _getStringValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }
  
  // Helper function to limit string length
  static int min(int a, int b) {
    return (a < b) ? a : b;
  }
}

class PerguruanTinggiDetail {
  final String kelompok;
  final String pembina;
  final String idSp;
  final String kodePt;
  final String email;
  final String noTel;
  final String noFax;
  final String website;
  final String alamat;
  final String namaPt;
  final String nmSingkat;
  final String kodePos;
  final String provinsiPt;
  final String kabKotaPt;
  final String kecamatanPt;
  final String lintangPt;
  final String bujurPt;
  final String tglBerdiriPt;
  final String tglSkPendirianSp;
  final String skPendirianSp;
  final String statusPt;
  final String akreditasiPt;
  final String statusAkreditasi;
  
  // Data tambahan
  final String rasio;
  final String jumlahMahasiswa;
  final String jumlahDosen;
  final String rangeBiayaKuliah;
  final String graduationRate;
  final String jumlahProdi;

  PerguruanTinggiDetail({
    required this.kelompok,
    required this.pembina,
    required this.idSp,
    required this.kodePt,
    required this.email,
    required this.noTel,
    required this.noFax,
    required this.website,
    required this.alamat,
    required this.namaPt,
    required this.nmSingkat,
    required this.kodePos,
    required this.provinsiPt,
    required this.kabKotaPt,
    required this.kecamatanPt,
    required this.lintangPt,
    required this.bujurPt,
    required this.tglBerdiriPt,
    required this.tglSkPendirianSp,
    required this.skPendirianSp,
    required this.statusPt,
    required this.akreditasiPt,
    required this.statusAkreditasi,
    this.rasio = '',
    this.jumlahMahasiswa = '',
    this.jumlahDosen = '',
    this.rangeBiayaKuliah = '',
    this.graduationRate = '',
    this.jumlahProdi = '',
  });

  factory PerguruanTinggiDetail.fromJson(Map<String, dynamic> json, {
    Map<String, dynamic>? rasioJson,
    Map<String, dynamic>? mahasiswaJson,
    Map<String, dynamic>? dosenJson,
    Map<String, dynamic>? biayaJson,
    Map<String, dynamic>? graduationJson,
    Map<String, dynamic>? prodiJson,
  }) {
    try {
      return PerguruanTinggiDetail(
        kelompok: _getStringValue(json, 'kelompok'),
        pembina: _getStringValue(json, 'pembina'),
        idSp: _getStringValue(json, 'id_sp'),
        kodePt: _getStringValue(json, 'kode_pt'),
        email: _getStringValue(json, 'email'),
        noTel: _getStringValue(json, 'no_tel'),
        noFax: _getStringValue(json, 'no_fax'),
        website: _getStringValue(json, 'website'),
        alamat: _getStringValue(json, 'alamat'),
        namaPt: _getStringValue(json, 'nama_pt'),
        nmSingkat: _getStringValue(json, 'nm_singkat'),
        kodePos: _getStringValue(json, 'kode_pos'),
        provinsiPt: _getStringValue(json, 'provinsi_pt'),
        kabKotaPt: _getStringValue(json, 'kab_kota_pt'),
        kecamatanPt: _getStringValue(json, 'kecamatan_pt'),
        lintangPt: _getStringValue(json, 'lintang_pt'),
        bujurPt: _getStringValue(json, 'bujur_pt'),
        tglBerdiriPt: _getStringValue(json, 'tgl_berdiri_pt'),
        tglSkPendirianSp: _getStringValue(json, 'tgl_sk_pendirian_sp'),
        skPendirianSp: _getStringValue(json, 'sk_pendirian_sp'),
        statusPt: _getStringValue(json, 'status_pt'),
        akreditasiPt: _getStringValue(json, 'akreditasi_pt'),
        statusAkreditasi: _getStringValue(json, 'status_akreditasi'),
        // Tambahkan data dari JSON tambahan jika tersedia
        rasio: rasioJson != null ? _getStringValue(rasioJson, 'rasio') : '',
        jumlahMahasiswa: mahasiswaJson != null ? _getStringValue(mahasiswaJson, 'jumlah_mahasiswa') : '',
        jumlahDosen: dosenJson != null ? _getStringValue(dosenJson, 'jumlah_dosen') : '',
        rangeBiayaKuliah: biayaJson != null ? _getStringValue(biayaJson, 'range_biaya_kuliah') : '',
        graduationRate: graduationJson != null ? _getStringValue(graduationJson, 'graduation_rate') : '',
        jumlahProdi: prodiJson != null ? _getStringValue(prodiJson, 'jumlah_prodi') : '',
      );
    } catch (e) {
      print('Error parsing PerguruanTinggiDetail: $e');
      print('JSON data: $json');
      // Return objek dengan data minimal untuk mencegah error
      return PerguruanTinggiDetail(
        kelompok: '',
        pembina: '',
        idSp: '',
        kodePt: '',
        email: '',
        noTel: '',
        noFax: '',
        website: '',
        alamat: '',
        namaPt: 'Error: $e',
        nmSingkat: '',
        kodePos: '',
        provinsiPt: '',
        kabKotaPt: '',
        kecamatanPt: '',
        lintangPt: '',
        bujurPt: '',
        tglBerdiriPt: '',
        tglSkPendirianSp: '',
        skPendirianSp: '',
        statusPt: '',
        akreditasiPt: '',
        statusAkreditasi: '',
      );
    }
  }

  // Helper method untuk mengambil nilai string dengan aman
  static String _getStringValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }
}

class ProdiPt {
  final String idSms;
  final String kodeProdi;
  final String namaProdi;
  final String akreditasi;
  final String jenjangProdi;
  final String statusProdi;
  final String jumlahDosenNidn;
  final String jumlahDosenNidk;
  final String jumlahDosen;
  final String jumlahDosenAjar;
  final String jumlahMahasiswa;
  final String rasio;
  final String indikatorKelengkapanData;

  ProdiPt({
    required this.idSms,
    required this.kodeProdi,
    required this.namaProdi,
    required this.akreditasi,
    required this.jenjangProdi,
    required this.statusProdi,
    required this.jumlahDosenNidn,
    required this.jumlahDosenNidk,
    required this.jumlahDosen,
    required this.jumlahDosenAjar,
    required this.jumlahMahasiswa,
    required this.rasio,
    required this.indikatorKelengkapanData,
  });

  factory ProdiPt.fromJson(Map<String, dynamic> json) {
    try {
      return ProdiPt(
        idSms: _getStringValue(json, 'id_sms'),
        kodeProdi: _getStringValue(json, 'kode_prodi'),
        namaProdi: _getStringValue(json, 'nama_prodi'),
        akreditasi: _getStringValue(json, 'akreditasi'),
        jenjangProdi: _getStringValue(json, 'jenjang_prodi'),
        statusProdi: _getStringValue(json, 'status_prodi'),
        jumlahDosenNidn: _getStringValue(json, 'jumlah_dosen_nidn'),
        jumlahDosenNidk: _getStringValue(json, 'jumlah_dosen_nidk'),
        jumlahDosen: _getStringValue(json, 'jumlah_dosen'),
        jumlahDosenAjar: _getStringValue(json, 'jumlah_dosen_ajar'),
        jumlahMahasiswa: _getStringValue(json, 'jumlah_mahasiswa'),
        rasio: _getStringValue(json, 'rasio'),
        indikatorKelengkapanData: _getStringValue(json, 'indikator_kelengkapan_data'),
      );
    } catch (e) {
      print('Error parsing ProdiPt: $e');
      print('JSON data: $json');
      // Return objek dengan field kosong daripada melempar error
      return ProdiPt(
        idSms: '',
        kodeProdi: '',
        namaProdi: 'Error: $e',
        akreditasi: '',
        jenjangProdi: '',
        statusProdi: '',
        jumlahDosenNidn: '',
        jumlahDosenNidk: '',
        jumlahDosen: '',
        jumlahDosenAjar: '',
        jumlahMahasiswa: '',
        rasio: '',
        indikatorKelengkapanData: '',
      );
    }
  }

  // Helper method untuk mengambil nilai string dengan aman
  static String _getStringValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }
}

// Model untuk data statistik PT
class PTStatistik {
  final String idSp;
  final double? meanJumlahLulus;
  final double? meanJumlahBaru;
  final String? jenjang;
  final double? meanMasaStudi;

  PTStatistik({
    required this.idSp,
    this.meanJumlahLulus,
    this.meanJumlahBaru,
    this.jenjang,
    this.meanMasaStudi,
  });

  factory PTStatistik.fromMahasiswaJson(Map<String, dynamic> json) {
    try {
      return PTStatistik(
        idSp: _getStringValue(json, 'id_sp'),
        meanJumlahLulus: _parseDouble(json['mean_jumlah_lulus']),
        meanJumlahBaru: _parseDouble(json['mean_jumlah_baru']),
      );
    } catch (e) {
      print('Error parsing PTStatistik (Mahasiswa): $e');
      print('JSON data: $json');
      return PTStatistik(idSp: _getStringValue(json, 'id_sp'));
    }
  }
  
  factory PTStatistik.fromWaktuStudiJson(Map<String, dynamic> json) {
    try {
      return PTStatistik(
        idSp: _getStringValue(json, 'id_sp'),
        jenjang: _getStringValue(json, 'jenjang'),
        meanMasaStudi: _parseDouble(json['mean_masa_studi']),
      );
    } catch (e) {
      print('Error parsing PTStatistik (Waktu Studi): $e');
      print('JSON data: $json');
      return PTStatistik(idSp: _getStringValue(json, 'id_sp'));
    }
  }

  // Helper method untuk mengambil nilai string dengan aman
  static String _getStringValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }
  
  // Helper method untuk mengambil nilai double dengan aman
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}