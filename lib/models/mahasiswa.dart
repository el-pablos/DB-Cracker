class Mahasiswa {
  final String id;
  final String nama;
  final String nim;
  final String namaPt;
  final String singkatanPt;
  final String namaProdi;

  Mahasiswa({
    required this.id,
    required this.nama,
    required this.nim,
    required this.namaPt,
    required this.singkatanPt,
    required this.namaProdi,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    try {
      return Mahasiswa(
        id: _ensureString(json['id']),
        nama: _ensureString(json['nama']),
        nim: _ensureString(json['nim']),
        namaPt: _ensureString(json['nama_pt']),
        singkatanPt: _ensureString(json['singkatan_pt']),
        namaProdi: _ensureString(json['nama_prodi']),
      );
    } catch (e) {
      print('Error parsing Mahasiswa: $e');
      print('JSON data: $json');
      throw Exception('Failed to parse Mahasiswa data: $e');
    }
  }

  // Helper method to ensure all values are strings
  static String _ensureString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}

class MahasiswaDetail {
  final String id;
  final String namaPt;
  final String kodePt;
  final String kodeProdi;
  final String prodi;
  final String nama;
  final String nim;
  final String jenisDaftar;
  final String idPt;
  final String idSms;
  final String jenisKelamin;
  final String jenjang;
  final String statusSaatIni;
  final String tahunMasuk;

  MahasiswaDetail({
    required this.id,
    required this.namaPt,
    required this.kodePt,
    required this.kodeProdi,
    required this.prodi,
    required this.nama,
    required this.nim,
    required this.jenisDaftar,
    required this.idPt,
    required this.idSms,
    required this.jenisKelamin,
    required this.jenjang,
    required this.statusSaatIni,
    required this.tahunMasuk,
  });

  factory MahasiswaDetail.fromJson(Map<String, dynamic> json) {
    try {
      // Print keys for debugging
      print('Keys in MahasiswaDetail.fromJson: ${json.keys.toList()}');
      
      // More flexible field handling
      // Use alternative field names if primary ones don't exist
      return MahasiswaDetail(
        id: _ensureString(json['id'] ?? json['id_mahasiswa'] ?? json['mahasiswa_id'] ?? ''),
        namaPt: _ensureString(json['nama_pt'] ?? json['pt_nama'] ?? json['perguruan_tinggi'] ?? ''),
        kodePt: _ensureString(json['kode_pt'] ?? json['pt_kode'] ?? ''),
        kodeProdi: _ensureString(json['kode_prodi'] ?? json['prodi_kode'] ?? ''),
        prodi: _ensureString(json['prodi'] ?? json['nama_prodi'] ?? json['program_studi'] ?? ''),
        nama: _ensureString(json['nama'] ?? json['nama_mahasiswa'] ?? ''),
        nim: _ensureString(json['nim'] ?? json['nomor_induk'] ?? json['nomor_mahasiswa'] ?? ''),
        jenisDaftar: _ensureString(json['jenis_daftar'] ?? json['jalur_daftar'] ?? 'Reguler'),
        idPt: _ensureString(json['id_pt'] ?? json['pt_id'] ?? ''),
        idSms: _ensureString(json['id_sms'] ?? json['sms_id'] ?? ''),
        jenisKelamin: _ensureString(json['jenis_kelamin'] ?? json['gender'] ?? ''),
        jenjang: _ensureString(json['jenjang'] ?? json['jenjang_pendidikan'] ?? ''),
        statusSaatIni: _ensureString(json['status_saat_ini'] ?? json['status'] ?? json['status_mahasiswa'] ?? 'Aktif'),
        tahunMasuk: _ensureString(json['tahun_masuk'] ?? json['angkatan'] ?? ''),
      );
    } catch (e) {
      print('Error parsing MahasiswaDetail: $e');
      print('JSON data: $json');
      
      // Create a minimal valid object instead of throwing an exception
      return MahasiswaDetail(
        id: _ensureString(json['id'] ?? ''),
        namaPt: _ensureString(json['nama_pt'] ?? ''),
        kodePt: _ensureString(json['kode_pt'] ?? ''),
        kodeProdi: _ensureString(json['kode_prodi'] ?? ''),
        prodi: _ensureString(json['prodi'] ?? ''),
        nama: _ensureString(json['nama'] ?? 'Data Tidak Tersedia'),
        nim: _ensureString(json['nim'] ?? 'N/A'),
        jenisDaftar: 'Reguler',
        idPt: _ensureString(json['id_pt'] ?? ''),
        idSms: _ensureString(json['id_sms'] ?? ''),
        jenisKelamin: _ensureString(json['jenis_kelamin'] ?? 'N/A'),
        jenjang: _ensureString(json['jenjang'] ?? 'N/A'),
        statusSaatIni: 'N/A',
        tahunMasuk: _ensureString(json['tahun_masuk'] ?? 'N/A'),
      );
    }
  }

  // Helper method to ensure all values are strings
  static String _ensureString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}