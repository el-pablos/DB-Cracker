import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/models/dosen.dart';

void main() {
  group('Dosen.fromJson', () {
    test('parsing JSON valid dengan semua field', () {
      final json = {
        'id': 'abc123',
        'nama': 'Dr. Bambang',
        'nidn': '0123456789',
        'nama_pt': 'Universitas Indonesia',
        'singkatan_pt': 'UI',
        'nama_prodi': 'Teknik Informatika',
      };
      final dosen = Dosen.fromJson(json);
      expect(dosen.id, 'abc123');
      expect(dosen.nama, 'Dr. Bambang');
      expect(dosen.nidn, '0123456789');
      expect(dosen.namaPt, 'Universitas Indonesia');
      expect(dosen.singkatanPt, 'UI');
      expect(dosen.namaProdi, 'Teknik Informatika');
    });

    test('parsing JSON dengan null values return empty string', () {
      final json = {
        'id': null,
        'nama': null,
        'nidn': null,
        'nama_pt': null,
        'singkatan_pt': null,
        'nama_prodi': null,
      };
      final dosen = Dosen.fromJson(json);
      expect(dosen.id, '');
      expect(dosen.nama, '');
      expect(dosen.nidn, '');
    });

    test('parsing JSON kosong return fallback object', () {
      final dosen = Dosen.fromJson({});
      expect(dosen.id, '');
      expect(dosen.nama, '');
    });

    test('parsing JSON dengan tipe data int return string', () {
      final json = {'id': 123, 'nama': 456, 'nidn': 789, 'nama_pt': true, 'singkatan_pt': 3.14, 'nama_prodi': null};
      final dosen = Dosen.fromJson(json);
      expect(dosen.id, '123');
      expect(dosen.nama, '456');
      expect(dosen.nidn, '789');
      expect(dosen.namaPt, 'true');
    });
  });

  group('DosenDetail.fromJson', () {
    test('parsing JSON valid dengan field dasar', () {
      final json = {
        'id_sdm': 'sdm001',
        'nama_dosen': 'Prof. Siti',
        'nidn': '9876543210',
        'nidk': 'NIDK001',
        'gelar_depan': 'Prof.',
        'gelar_belakang': 'M.Sc.',
        'jenis_kelamin': 'Perempuan',
        'tempat_lahir': 'Jakarta',
        'tanggal_lahir': '1980-01-01',
        'agama': 'Islam',
        'nama_pt': 'ITB',
        'nama_prodi': 'Informatika',
        'jabatan_akademik': 'Guru Besar',
        'pendidikan_tertinggi': 'S3',
        'status_ikatan_kerja': 'Tetap',
        'status_aktivitas': 'Aktif',
        'bidang_ilmu': 'Computer Science',
        'institusi_pendidikan': 'MIT',
        'tahun_lulus_tertinggi': '2010',
        'status_sertifikasi': 'Sudah',
        'tahun_sertifikasi': '2015',
        'nomor_sertifikat': 'CERT001',
        'bidang_sertifikasi': 'Informatika',
      };
      final detail = DosenDetail.fromJson(json);
      expect(detail.idSdm, 'sdm001');
      expect(detail.namaDosen, 'Prof. Siti');
      expect(detail.nidn, '9876543210');
      expect(detail.nidk, 'NIDK001');
      expect(detail.gelarDepan, 'Prof.');
      expect(detail.gelarBelakang, 'M.Sc.');
      expect(detail.tempatLahir, 'Jakarta');
      expect(detail.tanggalLahir, '1980-01-01');
      expect(detail.agama, 'Islam');
      expect(detail.bidangIlmu, 'Computer Science');
      expect(detail.statusSertifikasi, 'Sudah');
      expect(detail.tahunSertifikasi, '2015');
    });

    test('parsing JSON kosong return fallback tanpa crash', () {
      final detail = DosenDetail.fromJson({});
      expect(detail.idSdm, '');
      expect(detail.namaDosen, '');
      expect(detail.penelitian, isEmpty);
      expect(detail.riwayatStudi, isEmpty);
    });

    test('error handling return fallback object bukan throw', () {
      // Passing invalid data that might cause issues
      final detail = DosenDetail.fromJson({'invalid': true});
      expect(detail.idSdm, '');
    });
  });

  group('DosenPortofolio.fromJson', () {
    test('parsing valid JSON', () {
      final json = {
        'id_sdm': 'sdm001',
        'jenis_kegiatan': 'Penelitian',
        'judul_kegiatan': 'AI Research',
        'tahun_kegiatan': '2023',
        'detail_kegiatan': 'Deep learning',
        'status_kegiatan': 'Selesai',
      };
      final porto = DosenPortofolio.fromJson(json);
      expect(porto.idSdm, 'sdm001');
      expect(porto.judulKegiatan, 'AI Research');
      expect(porto.tahunKegiatan, '2023');
    });
  });

  group('DosenRiwayatStudi.fromJson', () {
    test('parsing valid JSON', () {
      final json = {
        'id_sdm': 'sdm001',
        'jenjang': 'S3',
        'gelar': 'Ph.D.',
        'bidang_studi': 'Computer Science',
        'perguruan': 'MIT',
        'tahun_lulus': '2010',
      };
      final riwayat = DosenRiwayatStudi.fromJson(json);
      expect(riwayat.jenjang, 'S3');
      expect(riwayat.gelar, 'Ph.D.');
      expect(riwayat.perguruan, 'MIT');
    });
  });

  group('DosenRiwayatMengajar.fromJson', () {
    test('parsing valid JSON', () {
      final json = {
        'id_sdm': 'sdm001',
        'nama_semester': '2023/2024 Ganjil',
        'kode_matkul': 'IF001',
        'nama_matkul': 'Algoritma',
        'nama_kelas': 'A',
        'nama_pt': 'ITB',
      };
      final riwayat = DosenRiwayatMengajar.fromJson(json);
      expect(riwayat.namaMatkul, 'Algoritma');
      expect(riwayat.namaKelas, 'A');
    });
  });

  group('DosenPenugasan.fromJson', () {
    test('parsing valid JSON', () {
      final json = {
        'id_sdm': 'sdm001',
        'nama_pt': 'ITB',
        'nama_prodi': 'Informatika',
        'status_penugasan': 'Aktif',
        'tahun_mulai': '2015',
        'tahun_selesai': '',
        'keterangan': 'Dosen tetap',
      };
      final penugasan = DosenPenugasan.fromJson(json);
      expect(penugasan.statusPenugasan, 'Aktif');
      expect(penugasan.tahunMulai, '2015');
    });
  });

  group('DosenJabatanFungsional.fromJson', () {
    test('parsing valid JSON', () {
      final json = {
        'id_sdm': 'sdm001',
        'jabatan': 'Guru Besar',
        'tanggal_sk': '2020-01-01',
        'nomor_sk': 'SK001',
        'tmt_jabatan': '2020-02-01',
        'status_jabatan': 'Aktif',
        'keterangan': '',
      };
      final jabatan = DosenJabatanFungsional.fromJson(json);
      expect(jabatan.jabatan, 'Guru Besar');
      expect(jabatan.nomorSk, 'SK001');
    });
  });
}
