import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/api/api_services_integration.dart';
import 'package:db_cracker_tamaengs/models/mahasiswa.dart';
import 'package:db_cracker_tamaengs/models/dosen.dart';

void main() {
  group('ApiServicesIntegration', () {
    test('singleton pattern returns same instance', () {
      final api1 = ApiServicesIntegration();
      final api2 = ApiServicesIntegration();
      expect(identical(api1, api2), true);
    });

    test('convertToMahasiswa with valid data', () {
      final api = ApiServicesIntegration();
      final data = [
        {
          'id': 'mhs001',
          'nama': 'Budi',
          'nim': '19102001',
          'perguruan_tinggi': 'UI',
          'singkatan_pt': 'UI',
          'program_studi': 'Informatika',
        },
        {
          'id': 'mhs002',
          'nama': 'Siti',
          'nim': '20102002',
          'perguruan_tinggi': 'ITB',
          'singkatan_pt': 'ITB',
          'program_studi': 'Teknik',
        },
      ];
      final result = api.convertToMahasiswa(data);
      expect(result.length, 2);
      expect(result[0].nama, 'Budi');
      expect(result[1].nama, 'Siti');
      expect(result[0], isA<Mahasiswa>());
    });

    test('convertToMahasiswa filters out empty nama/nim', () {
      final api = ApiServicesIntegration();
      final data = [
        {'id': '1', 'nama': 'Budi', 'nim': '123', 'perguruan_tinggi': '', 'singkatan_pt': '', 'program_studi': ''},
        {'id': '2', 'nama': '', 'nim': '456', 'perguruan_tinggi': '', 'singkatan_pt': '', 'program_studi': ''},
        {'id': '3', 'nama': 'Siti', 'nim': '', 'perguruan_tinggi': '', 'singkatan_pt': '', 'program_studi': ''},
      ];
      final result = api.convertToMahasiswa(data);
      expect(result.length, 1);
      expect(result[0].nama, 'Budi');
    });

    test('convertToDosen with valid data', () {
      final api = ApiServicesIntegration();
      final data = [
        {
          'id': 'dsn001',
          'nama': 'Dr. Bambang',
          'nidn': '0123456789',
          'perguruan_tinggi': 'UI',
          'singkatan_pt': 'UI',
          'program_studi': 'Informatika',
        },
      ];
      final result = api.convertToDosen(data);
      expect(result.length, 1);
      expect(result[0].nama, 'Dr. Bambang');
      expect(result[0], isA<Dosen>());
    });

    test('convertToDosen filters out empty nama/nidn', () {
      final api = ApiServicesIntegration();
      final data = [
        {'id': '1', 'nama': 'Dr. A', 'nidn': '123', 'perguruan_tinggi': '', 'singkatan_pt': '', 'program_studi': ''},
        {'id': '2', 'nama': '', 'nidn': '456', 'perguruan_tinggi': '', 'singkatan_pt': '', 'program_studi': ''},
      ];
      final result = api.convertToDosen(data);
      expect(result.length, 1);
    });

    test('convertToMahasiswa with alternative key names', () {
      final api = ApiServicesIntegration();
      final data = [
        {
          'mahasiswa_id': 'alt001',
          'name': 'John',
          'nomor_induk': '999',
          'universitas': 'UGM',
          'kode_pt': 'UGM',
          'jurusan': 'CS',
        },
      ];
      final result = api.convertToMahasiswa(data);
      expect(result.length, 1);
      expect(result[0].nama, 'John');
      expect(result[0].nim, '999');
    });
  });
}
