import 'package:flutter/foundation.dart';
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
      if (kDebugMode) debugPrint('Error parsing Dosen: $e');
      if (kDebugMode) debugPrint('JSON data: $json');
      // Return objek dengan field kosong daripada melempar error
      return Dosen(
        id: '',
        nama:
            'Error: ${e.toString().substring(0, min(30, e.toString().length))}',
        nidn: '',
        namaPt: '',
        singkatanPt: '',
        namaProdi: '',
      );
    }
  }

  // Helper method untuk mengambil nilai string dengan aman

  Map<String, dynamic> toJson() => {
    'id': id, 'nama': nama, 'nidn': nidn,
    'nama_pt': namaPt, 'singkatan_pt': singkatanPt, 'nama_prodi': namaProdi,
  };

  @override
  String toString() => 'Dosen(id: $id, nama: $nama, nidn: $nidn)';

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
  // Profil Dosen Dasar
  final String idSdm;
  final String namaDosen;
  final String nidn;
  final String nidk;
  final String gelarDepan;
  final String gelarBelakang;
  final String jenisKelamin;
  final String statusIkatanKerja;
  final String statusAktivitas;
  final String tempatLahir;
  final String tanggalLahir;
  final String agama;

  // Perguruan Tinggi dan Program Studi
  final String namaPt;
  final String namaProdi;
  final String homePt;
  final String homeProdi;
  final String rasioHomebase;
  final String statusHomebase;

  // Jabatan Fungsional
  final String jabatanAkademik;
  final String tanggalSk;
  final String tmtJabatan;
  final String nomorSk;

  // Pendidikan Tertinggi
  final String pendidikanTertinggi;
  final String bidangIlmu;
  final String institusiPendidikan;
  final String tahunLulusTertinggi;

  // Sertifikasi Dosen
  final String statusSertifikasi;
  final String tahunSertifikasi;
  final String nomorSertifikat;
  final String bidangSertifikasi;

  // Data portofolio dan riwayat
  final List<DosenRiwayatStudi> riwayatStudi;
  final List<DosenRiwayatMengajar> riwayatMengajar;
  final List<DosenPortofolio> penelitian;
  final List<DosenPortofolio> pengabdian;
  final List<DosenPortofolio> karya;
  final List<DosenPortofolio> paten;
  final List<DosenPenugasan> riwayatPenugasan;
  final List<DosenJabatanFungsional> riwayatJabatan;

  DosenDetail({
    required this.idSdm,
    required this.namaDosen,
    this.nidn = '',
    this.nidk = '',
    this.gelarDepan = '',
    this.gelarBelakang = '',
    required this.jenisKelamin,
    required this.statusIkatanKerja,
    required this.statusAktivitas,
    this.tempatLahir = '',
    this.tanggalLahir = '',
    this.agama = '',
    required this.namaPt,
    required this.namaProdi,
    this.homePt = '',
    this.homeProdi = '',
    this.rasioHomebase = '',
    this.statusHomebase = '',
    required this.jabatanAkademik,
    this.tanggalSk = '',
    this.tmtJabatan = '',
    this.nomorSk = '',
    required this.pendidikanTertinggi,
    this.bidangIlmu = '',
    this.institusiPendidikan = '',
    this.tahunLulusTertinggi = '',
    this.statusSertifikasi = '',
    this.tahunSertifikasi = '',
    this.nomorSertifikat = '',
    this.bidangSertifikasi = '',
    this.riwayatStudi = const [],
    this.riwayatMengajar = const [],
    this.penelitian = const [],
    this.pengabdian = const [],
    this.karya = const [],
    this.paten = const [],
    this.riwayatPenugasan = const [],
    this.riwayatJabatan = const [],
  });

  factory DosenDetail.fromJson(Map<String, dynamic> json) {
    try {
      // Data dosen dasar — mapping SEMUA field dari JSON
      final dosenDetail = DosenDetail(
        idSdm: _getStringValue(json, 'id_sdm'),
        namaDosen: _getStringValue(json, 'nama_dosen'),
        nidn: _getStringValue(json, 'nidn'),
        nidk: _getStringValue(json, 'nidk'),
        gelarDepan: _getStringValue(json, 'gelar_depan'),
        gelarBelakang: _getStringValue(json, 'gelar_belakang'),
        jenisKelamin: _getStringValue(json, 'jenis_kelamin'),
        tempatLahir: _getStringValue(json, 'tempat_lahir'),
        tanggalLahir: _getStringValue(json, 'tanggal_lahir'),
        agama: _getStringValue(json, 'agama'),
        namaPt: _getStringValue(json, 'nama_pt'),
        namaProdi: _getStringValue(json, 'nama_prodi'),
        homePt: _getStringValue(json, 'home_pt'),
        homeProdi: _getStringValue(json, 'home_prodi'),
        rasioHomebase: _getStringValue(json, 'rasio_homebase'),
        statusHomebase: _getStringValue(json, 'status_homebase'),
        jabatanAkademik: _getStringValue(json, 'jabatan_akademik'),
        tanggalSk: _getStringValue(json, 'tanggal_sk'),
        tmtJabatan: _getStringValue(json, 'tmt_jabatan'),
        nomorSk: _getStringValue(json, 'nomor_sk'),
        pendidikanTertinggi: _getStringValue(json, 'pendidikan_tertinggi'),
        bidangIlmu: _getStringValue(json, 'bidang_ilmu'),
        institusiPendidikan: _getStringValue(json, 'institusi_pendidikan'),
        tahunLulusTertinggi: _getStringValue(json, 'tahun_lulus_tertinggi'),
        statusIkatanKerja: _getStringValue(json, 'status_ikatan_kerja'),
        statusAktivitas: _getStringValue(json, 'status_aktivitas'),
        statusSertifikasi: _getStringValue(json, 'status_sertifikasi'),
        tahunSertifikasi: _getStringValue(json, 'tahun_sertifikasi'),
        nomorSertifikat: _getStringValue(json, 'nomor_sertifikat'),
        bidangSertifikasi: _getStringValue(json, 'bidang_sertifikasi'),

        // Data portofolio akan diisi nanti jika ada
        penelitian: [],
        pengabdian: [],
        karya: [],
        paten: [],
        riwayatStudi: [],
        riwayatMengajar: [],
        riwayatPenugasan: [],
        riwayatJabatan: [],
      );

      return dosenDetail;
    } catch (e) {
      if (kDebugMode) debugPrint('Error parsing DosenDetail: $e');
      if (kDebugMode) debugPrint('JSON data: $json');
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

  // Versi dengan parameter-parameter portofolio
  factory DosenDetail.withPortfolio(
    Map<String, dynamic> json, {
    List<DosenPortofolio>? penelitian,
    List<DosenPortofolio>? pengabdian,
    List<DosenPortofolio>? karya,
    List<DosenPortofolio>? paten,
    List<DosenRiwayatStudi>? riwayatStudi,
    List<DosenRiwayatMengajar>? riwayatMengajar,
  }) {
    try {
      // Buat objek dasar
      final dasar = DosenDetail.fromJson(json);

      // Kembalikan objek dengan data portofolio
      return DosenDetail(
        idSdm: dasar.idSdm,
        namaDosen: dasar.namaDosen,
        namaPt: dasar.namaPt,
        namaProdi: dasar.namaProdi,
        jenisKelamin: dasar.jenisKelamin,
        jabatanAkademik: dasar.jabatanAkademik,
        pendidikanTertinggi: dasar.pendidikanTertinggi,
        statusIkatanKerja: dasar.statusIkatanKerja,
        statusAktivitas: dasar.statusAktivitas,
        homePt: dasar.homePt,
        homeProdi: dasar.homeProdi,
        rasioHomebase: dasar.rasioHomebase,
        penelitian: penelitian ?? const [],
        pengabdian: pengabdian ?? const [],
        karya: karya ?? const [],
        paten: paten ?? const [],
        riwayatStudi: riwayatStudi ?? const [],
        riwayatMengajar: riwayatMengajar ?? const [],
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error parsing DosenDetail with portfolio: $e');
      if (kDebugMode) debugPrint('JSON data: $json');
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

  Map<String, dynamic> toJson() => {'id_sdm': idSdm, 'nama_dosen': namaDosen, 'nidn': nidn, 'nidk': nidk, 'gelar_depan': gelarDepan, 'gelar_belakang': gelarBelakang, 'jenis_kelamin': jenisKelamin, 'tempat_lahir': tempatLahir, 'tanggal_lahir': tanggalLahir, 'agama': agama, 'nama_pt': namaPt, 'nama_prodi': namaProdi, 'jabatan_akademik': jabatanAkademik, 'pendidikan_tertinggi': pendidikanTertinggi, 'status_ikatan_kerja': statusIkatanKerja, 'status_aktivitas': statusAktivitas};
  @override
  String toString() => 'DosenDetail(id: $idSdm, nama: $namaDosen, nidn: $nidn)';

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
  final String detailKegiatan;
  final String statusKegiatan;

  DosenPortofolio({
    required this.idSdm,
    required this.jenisKegiatan,
    required this.judulKegiatan,
    required this.tahunKegiatan,
    this.detailKegiatan = '',
    this.statusKegiatan = '',
  });

  factory DosenPortofolio.fromJson(Map<String, dynamic> json) {
    try {
      return DosenPortofolio(
        idSdm: _getStringValue(json, 'id_sdm'),
        jenisKegiatan: _getStringValue(json, 'jenis_kegiatan'),
        judulKegiatan: _getStringValue(json, 'judul_kegiatan'),
        tahunKegiatan: _getStringValue(json, 'tahun_kegiatan'),
        detailKegiatan: _getStringValue(json, 'detail_kegiatan'),
        statusKegiatan: _getStringValue(json, 'status_kegiatan'),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error parsing DosenPortofolio: $e');
      if (kDebugMode) debugPrint('JSON data: $json');
      // Return objek dengan field kosong daripada melempar error
      return DosenPortofolio(
        idSdm: '',
        jenisKegiatan: '',
        judulKegiatan: 'Error: $e',
        tahunKegiatan: '',
      );
    }
  }

  Map<String, dynamic> toJson() => {'id_sdm': idSdm, 'jenis_kegiatan': jenisKegiatan, 'judul_kegiatan': judulKegiatan, 'tahun_kegiatan': tahunKegiatan, 'detail_kegiatan': detailKegiatan, 'status_kegiatan': statusKegiatan};
  @override
  String toString() => 'DosenPortofolio(judul: $judulKegiatan, tahun: $tahunKegiatan)';

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
      if (kDebugMode) debugPrint('Error parsing DosenRiwayatStudi: $e');
      if (kDebugMode) debugPrint('JSON data: $json');
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

  Map<String, dynamic> toJson() => {'id_sdm': idSdm, 'jenjang': jenjang, 'gelar': gelar, 'bidang_studi': bidangStudi, 'perguruan': perguruan, 'tahun_lulus': tahunLulus};
  @override
  String toString() => 'DosenRiwayatStudi(jenjang: $jenjang, perguruan: $perguruan)';

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
      if (kDebugMode) debugPrint('Error parsing DosenRiwayatMengajar: $e');
      if (kDebugMode) debugPrint('JSON data: $json');
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

  Map<String, dynamic> toJson() => {'id_sdm': idSdm, 'nama_semester': namaSemester, 'kode_matkul': kodeMatkul, 'nama_matkul': namaMatkul, 'nama_kelas': namaKelas, 'nama_pt': namaPt};
  @override
  String toString() => 'DosenRiwayatMengajar(matkul: $namaMatkul, semester: $namaSemester)';

  // Helper method untuk mengambil nilai string dengan aman
  static String _getStringValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }
}

class DosenPenugasan {
  final String idSdm;
  final String namaPt;
  final String namaProdi;
  final String statusPenugasan;
  final String tahunMulai;
  final String tahunSelesai;
  final String keterangan;

  DosenPenugasan({
    required this.idSdm,
    required this.namaPt,
    required this.namaProdi,
    required this.statusPenugasan,
    required this.tahunMulai,
    this.tahunSelesai = '',
    this.keterangan = '',
  });

  factory DosenPenugasan.fromJson(Map<String, dynamic> json) {
    try {
      return DosenPenugasan(
        idSdm: _getStringValue(json, 'id_sdm'),
        namaPt: _getStringValue(json, 'nama_pt'),
        namaProdi: _getStringValue(json, 'nama_prodi'),
        statusPenugasan: _getStringValue(json, 'status_penugasan'),
        tahunMulai: _getStringValue(json, 'tahun_mulai'),
        tahunSelesai: _getStringValue(json, 'tahun_selesai'),
        keterangan: _getStringValue(json, 'keterangan'),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error parsing DosenPenugasan: $e');
      if (kDebugMode) debugPrint('JSON data: $json');
      // Return objek dengan field kosong daripada melempar error
      return DosenPenugasan(
        idSdm: '',
        namaPt: '',
        namaProdi: '',
        statusPenugasan: 'Error: $e',
        tahunMulai: '',
      );
    }
  }

  Map<String, dynamic> toJson() => {'id_sdm': idSdm, 'nama_pt': namaPt, 'nama_prodi': namaProdi, 'status_penugasan': statusPenugasan, 'tahun_mulai': tahunMulai, 'tahun_selesai': tahunSelesai, 'keterangan': keterangan};
  @override
  String toString() => 'DosenPenugasan(pt: $namaPt, status: $statusPenugasan)';

  // Helper method untuk mengambil nilai string dengan aman
  static String _getStringValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }
}

class DosenJabatanFungsional {
  final String idSdm;
  final String jabatan;
  final String tanggalSk;
  final String nomorSk;
  final String tmtJabatan;
  final String statusJabatan;
  final String keterangan;

  DosenJabatanFungsional({
    required this.idSdm,
    required this.jabatan,
    required this.tanggalSk,
    required this.nomorSk,
    required this.tmtJabatan,
    this.statusJabatan = '',
    this.keterangan = '',
  });

  factory DosenJabatanFungsional.fromJson(Map<String, dynamic> json) {
    try {
      return DosenJabatanFungsional(
        idSdm: _getStringValue(json, 'id_sdm'),
        jabatan: _getStringValue(json, 'jabatan'),
        tanggalSk: _getStringValue(json, 'tanggal_sk'),
        nomorSk: _getStringValue(json, 'nomor_sk'),
        tmtJabatan: _getStringValue(json, 'tmt_jabatan'),
        statusJabatan: _getStringValue(json, 'status_jabatan'),
        keterangan: _getStringValue(json, 'keterangan'),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error parsing DosenJabatanFungsional: $e');
      if (kDebugMode) debugPrint('JSON data: $json');
      // Return objek dengan field kosong daripada melempar error
      return DosenJabatanFungsional(
        idSdm: '',
        jabatan: 'Error: $e',
        tanggalSk: '',
        nomorSk: '',
        tmtJabatan: '',
      );
    }
  }

  Map<String, dynamic> toJson() => {'id_sdm': idSdm, 'jabatan': jabatan, 'tanggal_sk': tanggalSk, 'nomor_sk': nomorSk, 'tmt_jabatan': tmtJabatan, 'status_jabatan': statusJabatan, 'keterangan': keterangan};
  @override
  String toString() => 'DosenJabatanFungsional(jabatan: $jabatan, tmt: $tmtJabatan)';

  // Helper method untuk mengambil nilai string dengan aman
  static String _getStringValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }
}
