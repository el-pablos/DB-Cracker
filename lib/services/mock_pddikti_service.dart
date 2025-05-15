import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/mahasiswa.dart';
import '../models/dosen.dart';
import '../models/prodi.dart';
import '../models/pt.dart';

/// Mock service to replace the PDDIKTI API for web development
/// This is useful when developing the web app without a backend proxy
class MockPddiktiService {
  // Random generator for creating sample data
  final Random _random = Random();
  
  // Sample data untuk testing
  final List<Map<String, dynamic>> _sampleMahasiswa = [
    {
      "id": "NDg1MjE1NS0zNWZhLTQ0MzQtYmU3Yi1jNzdiZGZjZjk4YWI=",
      "nama": "Muhammad Akbar",
      "nim": "19102001",
      "nama_pt": "Universitas Indonesia",
      "singkatan_pt": "UI",
      "nama_prodi": "Ilmu Komputer"
    },
    {
      "id": "MmIzODJiNy05MDUxLTRmYjUtYmVlZC02ZDVjYmQ2MjM3Nzc=",
      "nama": "Dewi Sartika",
      "nim": "20102002",
      "nama_pt": "Institut Teknologi Bandung",
      "singkatan_pt": "ITB",
      "nama_prodi": "Teknik Informatika"
    },
    {
      "id": "NjJkMzA3Yi01ZjQ2LTQ4NjYtOWVlZC02NWFjYzk0YWY3M2M=",
      "nama": "Ahmad Rizki",
      "nim": "21102003",
      "nama_pt": "Universitas Gadjah Mada",
      "singkatan_pt": "UGM",
      "nama_prodi": "Sistem Informasi"
    },
    {
      "id": "MGQ2MjdlNS0xYmQ1LTRmZjgtOWUzZC0wZmJlY2EyYTBhMDQ=",
      "nama": "Siti Nurhaliza",
      "nim": "22102004",
      "nama_pt": "Universitas Padjadjaran",
      "singkatan_pt": "UNPAD",
      "nama_prodi": "Manajemen Informatika"
    },
    {
      "id": "YjUyZDA3NS1lNTg4LTRlZDktYWE5Mi1jOWQ2Y2MwZWU2NDc=",
      "nama": "Muhammad Tama",
      "nim": "23102005",
      "nama_pt": "Universitas Diponegoro",
      "singkatan_pt": "UNDIP",
      "nama_prodi": "Teknik Komputer"
    }
  ];

  // Sample data untuk prodi
  final List<Map<String, dynamic>> _sampleProdi = [
    {
      "id": "UEREMDgxNDAxMjE=",
      "nama": "Ilmu Komputer",
      "jenjang": "S1",
      "pt": "Universitas Indonesia",
      "pt_singkat": "UI"
    },
    {
      "id": "UEREMDgyNDAxMjE=",
      "nama": "Teknik Informatika",
      "jenjang": "S1",
      "pt": "Institut Teknologi Bandung",
      "pt_singkat": "ITB"
    },
    {
      "id": "UEREMDgzNDAxMjE=",
      "nama": "Sistem Informasi",
      "jenjang": "S1",
      "pt": "Universitas Gadjah Mada",
      "pt_singkat": "UGM"
    },
    {
      "id": "UEREMDg0NDAxMjE=",
      "nama": "Manajemen Informatika",
      "jenjang": "D3",
      "pt": "Universitas Padjadjaran",
      "pt_singkat": "UNPAD"
    },
    {
      "id": "UEREMDg1NDAxMjE=",
      "nama": "Teknik Komputer",
      "jenjang": "S1",
      "pt": "Universitas Diponegoro",
      "pt_singkat": "UNDIP"
    }
  ];

  // Sample data untuk PT
  final List<Map<String, dynamic>> _samplePT = [
    {
      "id": "UEREUFQxMDAwMQ==",
      "kode": "001031",
      "nama_singkat": "UI",
      "nama": "Universitas Indonesia"
    },
    {
      "id": "UEREUFQxMDAwMg==",
      "kode": "001032",
      "nama_singkat": "ITB",
      "nama": "Institut Teknologi Bandung"
    },
    {
      "id": "UEREUFQxMDAwMw==",
      "kode": "001033",
      "nama_singkat": "UGM",
      "nama": "Universitas Gadjah Mada"
    },
    {
      "id": "UEREUFQxMDAwNA==",
      "kode": "001034",
      "nama_singkat": "UNPAD",
      "nama": "Universitas Padjadjaran"
    },
    {
      "id": "UEREUFQxMDAwNQ==",
      "kode": "001035",
      "nama_singkat": "UNDIP",
      "nama": "Universitas Diponegoro"
    }
  ];

  // Pencarian mahasiswa (mock)
  Future<List<Mahasiswa>> searchMahasiswa(String keyword) async {
    // Simulasi delay jaringan
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
    
    if (kIsWeb) {
      print('Using mock data for web');
    }
    
    // Filter berdasarkan keyword
    final filteredData = _sampleMahasiswa.where((item) {
      final nama = item['nama'].toString().toLowerCase();
      final nim = item['nim'].toString().toLowerCase();
      final pt = item['nama_pt'].toString().toLowerCase();
      final prodi = item['nama_prodi'].toString().toLowerCase();
      
      return nama.contains(keyword.toLowerCase()) || 
             nim.contains(keyword.toLowerCase()) || 
             pt.contains(keyword.toLowerCase()) || 
             prodi.contains(keyword.toLowerCase());
    }).toList();
    
    // Konversi ke model Mahasiswa
    return filteredData.map((item) => Mahasiswa.fromJson(item)).toList();
  }

  // Pencarian prodi (mock)
  Future<List<Prodi>> searchProdi(String keyword) async {
    // Simulasi delay jaringan
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
    
    if (kIsWeb) {
      print('Using mock data for prodi search (web)');
    }
    
    // Filter berdasarkan keyword
    final filteredData = _sampleProdi.where((item) {
      final nama = item['nama'].toString().toLowerCase();
      final jenjang = item['jenjang'].toString().toLowerCase();
      final pt = item['pt'].toString().toLowerCase();
      final ptSingkat = item['pt_singkat'].toString().toLowerCase();
      
      return nama.contains(keyword.toLowerCase()) || 
             jenjang.contains(keyword.toLowerCase()) || 
             pt.contains(keyword.toLowerCase()) || 
             ptSingkat.contains(keyword.toLowerCase());
    }).toList();
    
    // Konversi ke model Prodi
    return filteredData.map((item) => Prodi.fromJson(item)).toList();
  }

  // Pencarian PT (mock)
  Future<List<PerguruanTinggi>> searchPt(String keyword) async {
    // Simulasi delay jaringan
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
    
    if (kIsWeb) {
      print('Using mock data for PT search (web)');
    }
    
    // Filter berdasarkan keyword
    final filteredData = _samplePT.where((item) {
      final kode = item['kode'].toString().toLowerCase();
      final namaSingkat = item['nama_singkat'].toString().toLowerCase();
      final nama = item['nama'].toString().toLowerCase();
      
      return kode.contains(keyword.toLowerCase()) || 
             namaSingkat.contains(keyword.toLowerCase()) || 
             nama.contains(keyword.toLowerCase());
    }).toList();
    
    // Konversi ke model PerguruanTinggi
    return filteredData.map((item) => PerguruanTinggi.fromJson(item)).toList();
  }

  // Detail mahasiswa (mock)
  Future<MahasiswaDetail> getMahasiswaDetail(String mahasiswaId) async {
    // Simulasi delay jaringan
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
    
    if (kIsWeb) {
      print('Using mock data for mahasiswa detail (web)');
    }
    
    // Cari mahasiswa berdasarkan ID di data sample
    final mahasiswaData = _sampleMahasiswa.firstWhere(
      (item) => item['id'] == mahasiswaId,
      orElse: () {
        // If not found by exact ID, create a sample data for any ID
        // This ensures we always return something for any ID
        print('Creating sample data for unknown mahasiswa ID: $mahasiswaId');
        return {
          "id": mahasiswaId,
          "nama": "Mahasiswa ${mahasiswaId.substring(0, min(5, mahasiswaId.length))}",
          "nim": "${10000 + _random.nextInt(90000)}",
          "nama_pt": "Universitas ${_random.nextInt(10)}",
          "singkatan_pt": "UNIV${_random.nextInt(10)}",
          "nama_prodi": "Program Studi ${_random.nextInt(5)}"
        };
      },
    );
    
    // Tambahkan data detail yang tidak ada di data dasar
    final detailData = {
      ...mahasiswaData,
      'id_pt': 'PT${_random.nextInt(10000)}',
      'id_sms': 'SMS${_random.nextInt(10000)}',
      'kode_pt': mahasiswaData['singkatan_pt'] ?? "PT-X",
      'kode_prodi': 'KP${_random.nextInt(100)}',
      'prodi': mahasiswaData['nama_prodi'] ?? "Program Studi X",
      'jenis_daftar': 'Reguler',
      'jenis_kelamin': _random.nextBool() ? 'Laki-laki' : 'Perempuan',
      'jenjang': ['S1', 'D3', 'D4', 'S2', 'S3'][_random.nextInt(5)],
      'status_saat_ini': ['Aktif', 'Lulus', 'Cuti'][_random.nextInt(3)],
      'tahun_masuk': (2015 + _random.nextInt(8)).toString(),
    };
    
    return MahasiswaDetail.fromJson(detailData);
  }

  // Detail prodi (mock)
  Future<ProdiDetail> getDetailProdi(String prodiId) async {
    // Simulasi delay jaringan
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
    
    if (kIsWeb) {
      print('Using mock data for prodi detail (web)');
    }
    
    // Cari prodi berdasarkan ID di data sample
    final prodiData = _sampleProdi.firstWhere(
      (item) => item['id'] == prodiId,
      orElse: () {
        // Jika tidak ditemukan dengan ID yang tepat, buat data sampel
        print('Creating sample data for unknown prodi ID: $prodiId');
        return {
          "id": prodiId,
          "nama": "Program Studi ${prodiId.substring(0, min(5, prodiId.length))}",
          "jenjang": ["S1", "S2", "S3", "D3", "D4"][_random.nextInt(5)],
          "pt": "Universitas Sample ${_random.nextInt(10)}",
          "pt_singkat": "UNSAM${_random.nextInt(10)}"
        };
      },
    );
    
    // Buat data detail prodi dengan beberapa data sesuai kebutuhan
    final Map<String, dynamic> detailData = {
      "id_sp": "SP${_random.nextInt(10000)}",
      "id_sms": prodiId,
      "nama_pt": prodiData['pt'],
      "kode_pt": prodiData['pt_singkat'],
      "nama_prodi": prodiData['nama'],
      "kode_prodi": "KP${_random.nextInt(1000)}",
      "kel_bidang": ["Teknologi", "Sains", "Sosial", "Humaniora", "Ekonomi"][_random.nextInt(5)],
      "jenj_didik": prodiData['jenjang'],
      "tgl_berdiri": "20${10 + _random.nextInt(10)}-${1 + _random.nextInt(12)}-${1 + _random.nextInt(28)}",
      "tgl_sk_selenggara": "20${10 + _random.nextInt(10)}-${1 + _random.nextInt(12)}-${1 + _random.nextInt(28)}",
      "sk_selenggara": "SK/PRODI/${_random.nextInt(1000)}/20${10 + _random.nextInt(10)}",
      "no_tel": "021-${1000000 + _random.nextInt(9000000)}",
      "no_fax": "021-${1000000 + _random.nextInt(9000000)}",
      "website": "www.${prodiData['pt_singkat'].toString().toLowerCase()}.ac.id",
      "email": "info@${prodiData['pt_singkat'].toString().toLowerCase()}.ac.id",
      "alamat": "Jl. Pendidikan No. ${1 + _random.nextInt(100)}",
      "provinsi": ["DKI Jakarta", "Jawa Barat", "Jawa Tengah", "Jawa Timur", "Yogyakarta"][_random.nextInt(5)],
      "kab_kota": ["Jakarta Pusat", "Bandung", "Semarang", "Surabaya", "Yogyakarta"][_random.nextInt(5)],
      "kecamatan": ["Kecamatan ${1 + _random.nextInt(10)}"],
      "lintang": "${-7 - _random.nextDouble()}",
      "bujur": "${110 + _random.nextDouble() * 10}",
      "status": ["Aktif", "Pembinaan"][_random.nextInt(2)],
      "akreditasi": ["A", "B", "C", "Unggul", "Baik Sekali"][_random.nextInt(5)],
      "akreditasi_internasional": _random.nextBool() ? "ISO 9001" : "",
      "status_akreditasi": ["Aktif", "Proses"][_random.nextInt(2)],
      "deskripsi_singkat": "Program studi ${prodiData['nama']} didirikan untuk mendidik mahasiswa dalam bidang ${["teknologi", "sains", "sosial", "humaniora", "ekonomi"][_random.nextInt(5)]}.",
      "visi": "Menjadi program studi ${prodiData['nama']} terkemuka di ${["Indonesia", "Asia Tenggara", "Asia", "dunia"][_random.nextInt(4)]} dalam bidang pendidikan, penelitian, dan pengabdian masyarakat.",
      "misi": "1. Menyelenggarakan pendidikan tinggi yang berkualitas\n2. Melakukan penelitian inovatif\n3. Melaksanakan pengabdian masyarakat yang bermanfaat\n4. Menjalin kerjasama dengan berbagai institusi",
      "kompetensi": "Lulusan program studi ${prodiData['nama']} diharapkan memiliki kemampuan:\n1. Analisis dan pemecahan masalah\n2. Komunikasi efektif\n3. Penguasaan teknologi informasi\n4. Kemampuan bekerja dalam tim",
      "capaian_belajar": "Setelah menyelesaikan program studi, mahasiswa diharapkan mampu:\n1. Mengaplikasikan pengetahuan teoritis dalam praktik\n2. Mengembangkan solusi inovatif\n3. Beradaptasi dengan perubahan teknologi\n4. Berkomunikasi secara efektif",
      "rata_masa_studi": (3 + _random.nextInt(3)).toString(),
    };
    
    return ProdiDetail.fromJson(detailData);
  }

  // Detail PT (mock)
  Future<PerguruanTinggiDetail> getDetailPt(String ptId) async {
    // Simulasi delay jaringan
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
    
    if (kIsWeb) {
      print('Using mock data for PT detail (web)');
    }
    
    // Cari PT berdasarkan ID di data sample
    final ptData = _samplePT.firstWhere(
      (item) => item['id'] == ptId,
      orElse: () {
        // Jika tidak ditemukan dengan ID yang tepat, buat data sampel
        print('Creating sample data for unknown PT ID: $ptId');
        return {
          "id": ptId,
          "kode": "${100000 + _random.nextInt(900000)}",
          "nama_singkat": "PT${_random.nextInt(100)}",
          "nama": "Perguruan Tinggi ${ptId.substring(0, min(5, ptId.length))}"
        };
      },
    );
    
    // Buat data detail PT dengan beberapa data sesuai kebutuhan
    final Map<String, dynamic> detailData = {
      "kelompok": ["Universitas", "Institut", "Sekolah Tinggi", "Politeknik", "Akademi"][_random.nextInt(5)],
      "pembina": ["Kementerian Pendidikan dan Kebudayaan", "Kementerian Agama", "Kementerian Riset dan Teknologi"][_random.nextInt(3)],
      "id_sp": ptId,
      "kode_pt": ptData['kode'],
      "email": "info@${ptData['nama_singkat'].toString().toLowerCase()}.ac.id",
      "no_tel": "021-${1000000 + _random.nextInt(9000000)}",
      "no_fax": "021-${1000000 + _random.nextInt(9000000)}",
      "website": "www.${ptData['nama_singkat'].toString().toLowerCase()}.ac.id",
      "alamat": "Jl. Pendidikan No. ${1 + _random.nextInt(100)}",
      "nama_pt": ptData['nama'],
      "nm_singkat": ptData['nama_singkat'],
      "kode_pos": "${10000 + _random.nextInt(90000)}",
      "provinsi_pt": ["DKI Jakarta", "Jawa Barat", "Jawa Tengah", "Jawa Timur", "Yogyakarta"][_random.nextInt(5)],
      "kab_kota_pt": ["Jakarta Pusat", "Bandung", "Semarang", "Surabaya", "Yogyakarta"][_random.nextInt(5)],
      "kecamatan_pt": ["Kecamatan ${1 + _random.nextInt(10)}"],
      "lintang_pt": "${-7 - _random.nextDouble()}",
      "bujur_pt": "${110 + _random.nextDouble() * 10}",
      "tgl_berdiri_pt": "19${50 + _random.nextInt(50)}-${1 + _random.nextInt(12)}-${1 + _random.nextInt(28)}",
      "tgl_sk_pendirian_sp": "19${50 + _random.nextInt(50)}-${1 + _random.nextInt(12)}-${1 + _random.nextInt(28)}",
      "sk_pendirian_sp": "SK/PT/${_random.nextInt(1000)}/19${50 + _random.nextInt(50)}",
      "status_pt": ["Aktif", "Pembinaan"][_random.nextInt(2)],
      "akreditasi_pt": ["A", "B", "C", "Unggul", "Baik Sekali"][_random.nextInt(5)],
      "status_akreditasi": ["Aktif", "Proses"][_random.nextInt(2)],
    };
    
    return PerguruanTinggiDetail.fromJson(detailData);
  }

  // Mencari daftar prodi di PT
  Future<List<ProdiPt>> getProdiPt(String ptId, int tahun) async {
    // Simulasi delay jaringan
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
    
    if (kIsWeb) {
      print('Using mock data for PT prodi list (web)');
    }
    
    // Buat 5 program studi acak untuk PT ini
    List<ProdiPt> prodiList = [];
    
    // Ambil nama PT dari sample
    final ptData = _samplePT.firstWhere(
      (item) => item['id'] == ptId,
      orElse: () => {"nama": "Perguruan Tinggi Sample"},
    );
    
    for (int i = 0; i < 5; i++) {
      // Buat data prodi acak
      final String idSms = "SMS${_random.nextInt(100000)}";
      final String kodeProdi = "KP${_random.nextInt(1000)}";
      final List<String> prodiNames = [
        "Teknik Informatika",
        "Sistem Informasi",
        "Ilmu Komputer",
        "Manajemen Informatika",
        "Teknik Komputer",
        "Akuntansi",
        "Manajemen",
        "Ekonomi",
        "Hukum",
        "Kedokteran"
      ];
      final String namaProdi = prodiNames[_random.nextInt(prodiNames.length)];
      final List<String> akreditasi = ["A", "B", "C", "Unggul", "Baik Sekali"];
      final List<String> jenjang = ["S1", "S2", "S3", "D3", "D4"];
      
      // Buat objek ProdiPt
      prodiList.add(ProdiPt(
        idSms: idSms,
        kodeProdi: kodeProdi,
        namaProdi: namaProdi,
        akreditasi: akreditasi[_random.nextInt(akreditasi.length)],
        jenjangProdi: jenjang[_random.nextInt(jenjang.length)],
        statusProdi: "Aktif",
        jumlahDosenNidn: "${10 + _random.nextInt(40)}",
        jumlahDosenNidk: "${1 + _random.nextInt(10)}",
        jumlahDosen: "${15 + _random.nextInt(50)}",
        jumlahDosenAjar: "${15 + _random.nextInt(50)}",
        jumlahMahasiswa: "${100 + _random.nextInt(900)}",
        rasio: "${(10 + _random.nextInt(30)) / 10}",
        indikatorKelengkapanData: "${50 + _random.nextInt(50)}%",
      ));
    }
    
    return prodiList;
  }

  // Profil detail dosen
  Future<DosenDetail> getDosenProfile(String dosenId) async {
    // Simulasi delay jaringan
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));

    // Data dosen detail standard
    final Map<String, dynamic> dosenData = {
      "id_sdm": dosenId,
      "nama_dosen": "Dr. Mock Profile ${dosenId.substring(0, min(4, dosenId.length))}",
      "nama_pt": "Universitas Indonesia",
      "nama_prodi": "Ilmu Komputer",
      "jenis_kelamin": _random.nextBool() ? "Laki-laki" : "Perempuan",
      "jabatan_akademik": ["Asisten Ahli", "Lektor", "Lektor Kepala", "Guru Besar"][_random.nextInt(4)],
      "pendidikan_tertinggi": ["S2", "S3"][_random.nextInt(2)],
      "status_ikatan_kerja": ["Tetap", "Tidak Tetap"][_random.nextInt(2)],
      "status_aktivitas": ["Aktif", "Tugas Belajar", "Cuti"][_random.nextInt(3)],
    };
    
    // Generate beberapa penelitian dan pengabdian
    List<DosenPortofolio> penelitian = List.generate(
      _random.nextInt(5) + 1, 
      (i) => DosenPortofolio(
        idSdm: dosenId,
        jenisKegiatan: "Penelitian",
        judulKegiatan: "Penelitian ke-${i+1} Bidang ${["Komputer", "Informatika", "AI", "Machine Learning", "Cyber Security"][_random.nextInt(5)]}",
        tahunKegiatan: (2015 + _random.nextInt(9)).toString(),
      )
    );
    
    List<DosenPortofolio> pengabdian = List.generate(
      _random.nextInt(3) + 1, 
      (i) => DosenPortofolio(
        idSdm: dosenId,
        jenisKegiatan: "Pengabdian",
        judulKegiatan: "Pengabdian Masyarakat: ${["Pelatihan", "Pendampingan", "Workshop", "Seminar"][_random.nextInt(4)]} ${["Komputer", "Internet", "Teknologi", "Digital"][_random.nextInt(4)]}",
        tahunKegiatan: (2018 + _random.nextInt(6)).toString(),
      )
    );
    
    // Tambahkan riwayat studi
    List<DosenRiwayatStudi> riwayatStudi = [
      DosenRiwayatStudi(
        idSdm: dosenId,
        jenjang: "S1",
        gelar: "S.Kom.",
        bidangStudi: "Teknik Informatika",
        perguruan: "Universitas Indonesia",
        tahunLulus: (1990 + _random.nextInt(10)).toString(),
      ),
      DosenRiwayatStudi(
        idSdm: dosenId,
        jenjang: "S2",
        gelar: "M.Kom.",
        bidangStudi: "Ilmu Komputer",
        perguruan: "Institut Teknologi Bandung",
        tahunLulus: (2000 + _random.nextInt(5)).toString(),
      ),
    ];
    
    // Jika pendidikan tertinggi S3, tambahkan data S3
    if (dosenData["pendidikan_tertinggi"] == "S3") {
      riwayatStudi.add(
        DosenRiwayatStudi(
          idSdm: dosenId,
          jenjang: "S3",
          gelar: "Dr.",
          bidangStudi: "Ilmu Komputer",
          perguruan: "Universitas Gadjah Mada",
          tahunLulus: (2010 + _random.nextInt(10)).toString(),
        )
      );
    }
    
    // Tambahkan riwayat mengajar
    List<DosenRiwayatMengajar> riwayatMengajar = List.generate(
      _random.nextInt(4) + 2, 
      (i) => DosenRiwayatMengajar(
        idSdm: dosenId,
        namaSemester: "20${20 + _random.nextInt(4)}${_random.nextInt(2) + 1}",
        kodeMatkul: "IF${100 + _random.nextInt(400)}",
        namaMatkul: ["Pemrograman Dasar", "Struktur Data", "Algoritma", "Sistem Operasi", "Database", "Jaringan Komputer", "Machine Learning"][_random.nextInt(7)],
        namaKelas: ["A", "B", "C", "D"][_random.nextInt(4)],
        namaPt: dosenData["nama_pt"],
      )
    );
    
    // Buat dan kembalikan objek DosenDetail
    return DosenDetail(
      idSdm: dosenData["id_sdm"],
      namaDosen: dosenData["nama_dosen"],
      namaPt: dosenData["nama_pt"],
      namaProdi: dosenData["nama_prodi"],
      jenisKelamin: dosenData["jenis_kelamin"],
      jabatanAkademik: dosenData["jabatan_akademik"],
      pendidikanTertinggi: dosenData["pendidikan_tertinggi"],
      statusIkatanKerja: dosenData["status_ikatan_kerja"],
      statusAktivitas: dosenData["status_aktivitas"],
      penelitian: penelitian,
      pengabdian: pengabdian,
      karya: [],
      paten: [],
      riwayatStudi: riwayatStudi,
      riwayatMengajar: riwayatMengajar,
    );
  }

  // Pencarian dosen (mock)
  Future<List<Dosen>> searchDosen(String keyword) async {
    // Simulasi delay jaringan
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
    
    // Data sample dosen
    final List<Map<String, dynamic>> sampleDosen = [
      {
        "id": "NDg1MjE1NS0zNWZhLTQ0MzQtYmU3Yi1jNzdiZGZjZjk4YWI=",
        "nama": "Dr. Bambang Supriadi",
        "nidn": "0123456789",
        "nama_pt": "Universitas Indonesia",
        "singkatan_pt": "UI",
        "nama_prodi": "Ilmu Komputer"
      },
      {
        "id": "MmIzODJiNy05MDUxLTRmYjUtYmVlZC02ZDVjYmQ2MjM3Nzc=",
        "nama": "Prof. Dr. Siti Rahma",
        "nidn": "9876543210",
        "nama_pt": "Institut Teknologi Bandung",
        "singkatan_pt": "ITB",
        "nama_prodi": "Teknik Informatika"
      }
    ];
    
    // Filter berdasarkan keyword
    final filteredData = sampleDosen.where((item) {
      final nama = item['nama'].toString().toLowerCase();
      final nidn = item['nidn'].toString().toLowerCase();
      final pt = item['nama_pt'].toString().toLowerCase();
      final prodi = item['nama_prodi'].toString().toLowerCase();
      
      return nama.contains(keyword.toLowerCase()) || 
             nidn.contains(keyword.toLowerCase()) || 
             pt.contains(keyword.toLowerCase()) || 
             prodi.contains(keyword.toLowerCase());
    }).toList();
    
    // Konversi ke model Dosen
    return filteredData.map((item) => Dosen.fromJson(item)).toList();
  }
  
  // Helper function to limit string length
  int min(int a, int b) {
    return (a < b) ? a : b;
  }
}