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
    return Mahasiswa(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      nim: json['nim'] ?? '',
      namaPt: json['nama_pt'] ?? '',
      singkatanPt: json['singkatan_pt'] ?? '',
      namaProdi: json['nama_prodi'] ?? '',
    );
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
    return MahasiswaDetail(
      id: json['id'] ?? '',
      namaPt: json['nama_pt'] ?? '',
      kodePt: json['kode_pt'] ?? '',
      kodeProdi: json['kode_prodi'] ?? '',
      prodi: json['prodi'] ?? '',
      nama: json['nama'] ?? '',
      nim: json['nim'] ?? '',
      jenisDaftar: json['jenis_daftar'] ?? '',
      idPt: json['id_pt'] ?? '',
      idSms: json['id_sms'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      jenjang: json['jenjang'] ?? '',
      statusSaatIni: json['status_saat_ini'] ?? '',
      tahunMasuk: json['tahun_masuk'] ?? '',
    );
  }
}