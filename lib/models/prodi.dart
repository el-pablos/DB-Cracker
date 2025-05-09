import 'package:flutter/material.dart';

class Prodi {
  final String id;
  final String nama;
  final String jenjang;
  final String pt;
  final String ptSingkat;

  Prodi({
    required this.id,
    required this.nama,
    required this.jenjang,
    required this.pt,
    required this.ptSingkat,
  });

  factory Prodi.fromJson(Map<String, dynamic> json) {
    try {
      return Prodi(
        id: _getStringValue(json, 'id'),
        nama: _getStringValue(json, 'nama'),
        jenjang: _getStringValue(json, 'jenjang'),
        pt: _getStringValue(json, 'pt'),
        ptSingkat: _getStringValue(json, 'pt_singkat'),
      );
    } catch (e) {
      print('Error parsing Prodi: $e');
      print('JSON data: $json');
      // Return objek dengan field kosong daripada melempar error
      return Prodi(
        id: '',
        nama: 'Error: ${e.toString().substring(0, min(30, e.toString().length))}',
        jenjang: '',
        pt: '',
        ptSingkat: '',
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

class ProdiDetail {
  final String idSp;
  final String idSms;
  final String namaPt;
  final String kodePt;
  final String namaProdi;
  final String kodeProdi;
  final String kelBidang;
  final String jenjangDidik;
  final String tglBerdiri;
  final String tglSkSelenggara;
  final String skSelenggara;
  final String noTel;
  final String noFax;
  final String website;
  final String email;
  final String alamat;
  final String provinsi;
  final String kabKota;
  final String kecamatan;
  final String lintang;
  final String bujur;
  final String status;
  final String akreditasi;
  final String akreditasiInternasional;
  final String statusAkreditasi;
  
  // Deskripsi tambahan
  final String deskripsiSingkat;
  final String visi;
  final String misi;
  final String kompetensi;
  final String capaianBelajar;
  final String rataMasaStudi;

  ProdiDetail({
    required this.idSp,
    required this.idSms,
    required this.namaPt,
    required this.kodePt,
    required this.namaProdi,
    required this.kodeProdi,
    required this.kelBidang,
    required this.jenjangDidik,
    required this.tglBerdiri,
    required this.tglSkSelenggara,
    required this.skSelenggara,
    required this.noTel,
    required this.noFax,
    required this.website,
    required this.email,
    required this.alamat,
    required this.provinsi,
    required this.kabKota,
    required this.kecamatan,
    required this.lintang,
    required this.bujur,
    required this.status,
    required this.akreditasi,
    required this.akreditasiInternasional,
    required this.statusAkreditasi,
    required this.deskripsiSingkat,
    required this.visi,
    required this.misi,
    required this.kompetensi,
    required this.capaianBelajar,
    required this.rataMasaStudi,
  });

  factory ProdiDetail.fromJson(Map<String, dynamic> json, [Map<String, dynamic>? descJson]) {
    try {
      return ProdiDetail(
        idSp: _getStringValue(json, 'id_sp'),
        idSms: _getStringValue(json, 'id_sms'),
        namaPt: _getStringValue(json, 'nama_pt'),
        kodePt: _getStringValue(json, 'kode_pt'),
        namaProdi: _getStringValue(json, 'nama_prodi'),
        kodeProdi: _getStringValue(json, 'kode_prodi'),
        kelBidang: _getStringValue(json, 'kel_bidang'),
        jenjangDidik: _getStringValue(json, 'jenj_didik'),
        tglBerdiri: _getStringValue(json, 'tgl_berdiri'),
        tglSkSelenggara: _getStringValue(json, 'tgl_sk_selenggara'),
        skSelenggara: _getStringValue(json, 'sk_selenggara'),
        noTel: _getStringValue(json, 'no_tel'),
        noFax: _getStringValue(json, 'no_fax'),
        website: _getStringValue(json, 'website'),
        email: _getStringValue(json, 'email'),
        alamat: _getStringValue(json, 'alamat'),
        provinsi: _getStringValue(json, 'provinsi'),
        kabKota: _getStringValue(json, 'kab_kota'),
        kecamatan: _getStringValue(json, 'kecamatan'),
        lintang: _getStringValue(json, 'lintang'),
        bujur: _getStringValue(json, 'bujur'),
        status: _getStringValue(json, 'status'),
        akreditasi: _getStringValue(json, 'akreditasi'),
        akreditasiInternasional: _getStringValue(json, 'akreditasi_internasional'),
        statusAkreditasi: _getStringValue(json, 'status_akreditasi'),
        // Ambil deskripsi tambahan jika ada
        deskripsiSingkat: descJson != null ? _getStringValue(descJson, 'deskripsi_singkat') : '',
        visi: descJson != null ? _getStringValue(descJson, 'visi') : '',
        misi: descJson != null ? _getStringValue(descJson, 'misi') : '',
        kompetensi: descJson != null ? _getStringValue(descJson, 'kompetensi') : '',
        capaianBelajar: descJson != null ? _getStringValue(descJson, 'capaian_belajar') : '',
        rataMasaStudi: descJson != null ? _getStringValue(descJson, 'rata_masa_studi') : '',
      );
    } catch (e) {
      print('Error parsing ProdiDetail: $e');
      print('JSON data: $json');
      // Return objek dengan data minimal untuk mencegah error
      return ProdiDetail(
        idSp: '',
        idSms: '',
        namaPt: '',
        kodePt: '',
        namaProdi: 'Error: $e',
        kodeProdi: '',
        kelBidang: '',
        jenjangDidik: '',
        tglBerdiri: '',
        tglSkSelenggara: '',
        skSelenggara: '',
        noTel: '',
        noFax: '',
        website: '',
        email: '',
        alamat: '',
        provinsi: '',
        kabKota: '',
        kecamatan: '',
        lintang: '',
        bujur: '',
        status: '',
        akreditasi: '',
        akreditasiInternasional: '',
        statusAkreditasi: '',
        deskripsiSingkat: '',
        visi: '',
        misi: '',
        kompetensi: '',
        capaianBelajar: '',
        rataMasaStudi: '',
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