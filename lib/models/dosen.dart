import 'package:flutter/material.dart';

class Dosen {
  final String id;
  final String nama;
  final String nidn;
  final String namaPt;
  final String singkatanPt;
  final String namaProdi;

  Dosen({
    required this.id,
    required this.nama,
    required this.nidn,
    required this.namaPt,
    required this.singkatanPt,
    required this.namaProdi,
  });

  factory Dosen.fromJson(Map<String, dynamic> json) {
    try {
      return Dosen(
        id: _getStringValue(json, 'id'),
        nama: _getStringValue(json, 'nama'),
        nidn: _getStringValue(json, 'nidn'),
        namaPt: _getStringValue(json, 'nama_pt'),
        singkatanPt: _getStringValue(json, 'singkatan_pt'),
        namaProdi: _getStringValue(json, 'nama_prodi'),
      );
    } catch (e) {
      print('Error parsing Dosen: $e');
      print('JSON data: $json');
      // Return objek dengan field kosong daripada melempar error
      return Dosen(
        id: '',
        nama: 'Error: ${e.toString().substring(0, min(30, e.toString().length))}',
        nidn: '',
        namaPt: '',
        singkatanPt: '',
        namaProdi: '',
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

class DosenDetail {
  final String idSdm;
  final String namaDosen;
  final String namaPt;
  final String namaProdi;
  final String jenisKelamin;
  final String jabatanAkademik;
  final String pendidikanTertinggi;
  final String statusIkatanKerja;
  final String statusAktivitas;
  
  // Data portofolio (opsional)
  final List<DosenPortofolio> penelitian;
  final List<DosenPortofolio> pengabdian;
  final List<DosenPortofolio> karya;
  final List<DosenPortofolio> paten;
  final List<DosenRiwayatStudi> riwayatStudi;
  final List<DosenRiwayatMengajar> riwayatMengajar;

  DosenDetail({
    required this.idSdm,
    required this.namaDosen,
    required this.namaPt,
    required this.namaProdi,
    required this.jenisKelamin,
    required this.jabatanAkademik,
    required this.pendidikanTertinggi,
    required this.statusIkatanKerja,
    required this.statusAktivitas,
    this.penelitian = const [],
    this.pengabdian = const [],
    this.karya = const [],
    this.paten = const [],
    this.riwayatStudi = const [],
    this.riwayatMengajar = const [],
  });

  factory DosenDetail.fromJson(Map<String, dynamic> json) {
    try {
      return DosenDetail(
        idSdm: _getStringValue(json, 'id_sdm'),
        namaDosen: _getStringValue(json, 'nama_dosen'),
        namaPt: _getStringValue(json, 'nama_pt'),
        namaProdi: _getStringValue(json, 'nama_prodi'),
        jenisKelamin: _getStringValue(json, 'jenis_kelamin'),
        jabatanAkademik: _getStringValue(json, 'jabatan_akademik'),
        pendidikanTertinggi: _getStringValue(json, 'pendidikan_tertinggi'),
        statusIkatanKerja: _getStringValue(json, 'status_ikatan_kerja'),
        statusAktivitas: _getStringValue(json, 'status_aktivitas'),
      );
    } catch (e) {
      print('Error parsing DosenDetail: $e');
      print('JSON data: $json');
      // Return objek dengan field kosong daripada melempar error
      return DosenDetail(
        idSdm: '',
        namaDosen: 'Error: $e',
        namaPt: '',
        namaProdi: '',
        jenisKelamin: '',
        jabatanAkademik: '',
        pendidikanTertinggi: '',
        statusIkatanKerja: '',
        statusAktivitas: '',
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

class DosenPortofolio {
  final String idSdm;
  final String jenisKegiatan;
  final String judulKegiatan;
  final String tahunKegiatan;

  DosenPortofolio({
    required this.idSdm,
    required this.jenisKegiatan,
    required this.judulKegiatan,
    required this.tahunKegiatan,
  });

  factory DosenPortofolio.fromJson(Map<String, dynamic> json) {
    try {
      return DosenPortofolio(
        idSdm: _getStringValue(json, 'id_sdm'),
        jenisKegiatan: _getStringValue(json, 'jenis_kegiatan'),
        judulKegiatan: _getStringValue(json, 'judul_kegiatan'),
        tahunKegiatan: _getStringValue(json, 'tahun_kegiatan'),
      );
    } catch (e) {
      print('Error parsing DosenPortofolio: $e');
      print('JSON data: $json');
      // Return objek dengan field kosong daripada melempar error
      return DosenPortofolio(
        idSdm: '',
        jenisKegiatan: '',
        judulKegiatan: 'Error: $e',
        tahunKegiatan: '',
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

class DosenRiwayatStudi {
  final String idSdm;
  final String jenjang;
  final String gelar;
  final String bidangStudi;
  final String perguruan;
  final String tahunLulus;

  DosenRiwayatStudi({
    required this.idSdm,
    required this.jenjang,
    required this.gelar,
    required this.bidangStudi,
    required this.perguruan,
    required this.tahunLulus,
  });

  factory DosenRiwayatStudi.fromJson(Map<String, dynamic> json) {
    try {
      return DosenRiwayatStudi(
        idSdm: _getStringValue(json, 'id_sdm'),
        jenjang: _getStringValue(json, 'jenjang'),
        gelar: _getStringValue(json, 'gelar'),
        bidangStudi: _getStringValue(json, 'bidang_studi'),
        perguruan: _getStringValue(json, 'perguruan'),
        tahunLulus: _getStringValue(json, 'tahun_lulus'),
      );
    } catch (e) {
      print('Error parsing DosenRiwayatStudi: $e');
      print('JSON data: $json');
      // Return objek dengan field kosong daripada melempar error
      return DosenRiwayatStudi(
        idSdm: '',
        jenjang: '',
        gelar: '',
        bidangStudi: '',
        perguruan: 'Error: $e',
        tahunLulus: '',
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

class DosenRiwayatMengajar {
  final String idSdm;
  final String namaSemester;
  final String kodeMatkul;
  final String namaMatkul;
  final String namaKelas;
  final String namaPt;

  DosenRiwayatMengajar({
    required this.idSdm,
    required this.namaSemester,
    required this.kodeMatkul,
    required this.namaMatkul,
    required this.namaKelas,
    required this.namaPt,
  });

  factory DosenRiwayatMengajar.fromJson(Map<String, dynamic> json) {
    try {
      return DosenRiwayatMengajar(
        idSdm: _getStringValue(json, 'id_sdm'),
        namaSemester: _getStringValue(json, 'nama_semester'),
        kodeMatkul: _getStringValue(json, 'kode_matkul'),
        namaMatkul: _getStringValue(json, 'nama_matkul'),
        namaKelas: _getStringValue(json, 'nama_kelas'),
        namaPt: _getStringValue(json, 'nama_pt'),
      );
    } catch (e) {
      print('Error parsing DosenRiwayatMengajar: $e');
      print('JSON data: $json');
      // Return objek dengan field kosong daripada melempar error
      return DosenRiwayatMengajar(
        idSdm: '',
        namaSemester: '',
        kodeMatkul: '',
        namaMatkul: 'Error: $e',
        namaKelas: '',
        namaPt: '',
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