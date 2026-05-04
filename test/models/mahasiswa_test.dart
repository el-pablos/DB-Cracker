import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/models/mahasiswa.dart';

void main() {
  group('Mahasiswa.fromJson', () {
    test('parsing JSON valid', () {
      final json = {
        'id': 'mhs001',
        'nama': 'Budi Santoso',
        'nim': '19102001',
        'nama_pt': 'Universitas Indonesia',
        'singkatan_pt': 'UI',
        'nama_prodi': 'Teknik Informatika',
      };
      final mhs = Mahasiswa.fromJson(json);
      expect(mhs.id, 'mhs001');
      expect(mhs.nama, 'Budi Santoso');
      expect(mhs.nim, '19102001');
      expect(mhs.namaPt, 'Universitas Indonesia');
    });

    test('parsing JSON dengan null values return empty string', () {
      final json = {'id': null, 'nama': null, 'nim': null, 'nama_pt': null, 'singkatan_pt': null, 'nama_prodi': null};
      final mhs = Mahasiswa.fromJson(json);
      expect(mhs.id, '');
      expect(mhs.nama, '');
      expect(mhs.nim, '');
    });

    test('error handling return fallback object bukan throw', () {
      // Setelah fix, fromJson harus return fallback bukan throw
      final mhs = Mahasiswa.fromJson({});
      expect(mhs.id, '');
      expect(mhs.nama, '');
    });

    test('parsing JSON dengan tipe data non-string', () {
      final json = {'id': 123, 'nama': true, 'nim': 456.7, 'nama_pt': null, 'singkatan_pt': '', 'nama_prodi': 'IT'};
      final mhs = Mahasiswa.fromJson(json);
      expect(mhs.id, '123');
      expect(mhs.nama, 'true');
      expect(mhs.nim, '456.7');
    });
  });

  group('MahasiswaDetail.fromJson', () {
    test('parsing JSON valid dengan semua field', () {
      final json = {
        'id': 'mhs001',
        'nama': 'Budi',
        'nim': '19102001',
        'jenis_kelamin': 'Laki-laki',
        'status_saat_ini': 'Aktif',
        'nama_pt': 'UI',
        'kode_pt': '001',
        'prodi': 'Informatika',
        'kode_prodi': 'IF',
        'tahun_masuk': '2019',
        'semester_saat_ini': '8',
        'tempat_lahir': 'Jakarta',
        'tanggal_lahir': '2001-01-01',
        'agama': 'Islam',
        'alamat': 'Jl. Merdeka 1',
        'ipk': '3.85',
        'total_sks': '144',
        'judul_skripsi': 'Machine Learning untuk Prediksi',
      };
      final detail = MahasiswaDetail.fromJson(json);
      expect(detail.id, 'mhs001');
      expect(detail.nama, 'Budi');
      expect(detail.semesterSaatIni, '8');
      expect(detail.tempatLahir, 'Jakarta');
      expect(detail.agama, 'Islam');
      expect(detail.ipk, '3.85');
      expect(detail.totalSks, '144');
      expect(detail.judulSkripsi, 'Machine Learning untuk Prediksi');
    });

    test('parsing JSON kosong return fallback tanpa crash', () {
      final detail = MahasiswaDetail.fromJson({});
      expect(detail.id, '');
      expect(detail.nama, '');
      expect(detail.ipk, '');
    });

    test('field alternatif key berfungsi', () {
      final json = {
        'id_mahasiswa': 'alt001',
        'nama_mahasiswa': 'Siti',
        'nomor_induk': '20201001',
        'pt_nama': 'UGM',
        'angkatan': '2020',
        'sks_total': '120',
      };
      final detail = MahasiswaDetail.fromJson(json);
      expect(detail.id, 'alt001');
      expect(detail.nama, 'Siti');
      expect(detail.nim, '20201001');
      expect(detail.namaPt, 'UGM');
      expect(detail.tahunMasuk, '2020');
      expect(detail.totalSks, '120');
    });
  });

  group('MahasiswaRiwayatSemester.fromJson', () {
    test('parsing valid JSON', () {
      final json = {
        'id_sms': 'sms001',
        'nama_semester': '2023/2024 Ganjil',
        'status_semester': 'Aktif',
        'ips': '3.75',
        'ipk': '3.80',
        'sks_total': '120',
        'sks_diambil': '21',
        'sks_lulus': '21',
      };
      final semester = MahasiswaRiwayatSemester.fromJson(json);
      expect(semester.namaSemester, '2023/2024 Ganjil');
      expect(semester.ips, '3.75');
      expect(semester.ipk, '3.80');
    });
  });

  group('MahasiswaNilai.fromJson', () {
    test('parsing valid JSON', () {
      final json = {
        'id_sms': 'sms001',
        'kode_matkul': 'IF001',
        'nama_matkul': 'Algoritma',
        'sks': '3',
        'nilai_huruf': 'A',
        'nilai_angka': '4.0',
        'nama_semester': '2023/2024 Ganjil',
      };
      final nilai = MahasiswaNilai.fromJson(json);
      expect(nilai.namaMatkul, 'Algoritma');
      expect(nilai.nilaiHuruf, 'A');
      expect(nilai.nilaiAngka, '4.0');
    });
  });

  group('MahasiswaKelas.fromJson', () {
    test('parsing valid JSON', () {
      final json = {
        'id_sms': 'sms001',
        'kode_matkul': 'IF001',
        'nama_matkul': 'Algoritma',
        'nama_kelas': 'A',
        'nama_dosen': 'Dr. Bambang',
        'nama_semester': '2023/2024 Ganjil',
      };
      final kelas = MahasiswaKelas.fromJson(json);
      expect(kelas.namaMatkul, 'Algoritma');
      expect(kelas.namaDosen, 'Dr. Bambang');
    });
  });
}
