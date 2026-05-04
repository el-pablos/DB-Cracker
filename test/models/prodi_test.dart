import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/models/prodi.dart';

void main() {
  group('Prodi.fromJson', () {
    test('parsing JSON valid', () {
      final json = {'id': 'p001', 'nama': 'Teknik Informatika', 'jenjang': 'S1', 'pt': 'ITB', 'pt_singkat': 'ITB'};
      final prodi = Prodi.fromJson(json);
      expect(prodi.id, 'p001');
      expect(prodi.nama, 'Teknik Informatika');
      expect(prodi.jenjang, 'S1');
    });

    test('parsing JSON kosong return fallback', () {
      final prodi = Prodi.fromJson({});
      expect(prodi.id, '');
      expect(prodi.nama, '');
    });

    test('null values return empty string', () {
      final prodi = Prodi.fromJson({'id': null, 'nama': null, 'jenjang': null, 'pt': null, 'pt_singkat': null});
      expect(prodi.id, '');
      expect(prodi.jenjang, '');
    });
  });

  group('Prodi.toJson', () {
    test('toJson menghasilkan map yang benar', () {
      final prodi = Prodi(id: 'p001', nama: 'TI', jenjang: 'S1', pt: 'ITB', ptSingkat: 'ITB');
      final json = prodi.toJson();
      expect(json['id'], 'p001');
      expect(json['nama'], 'TI');
      expect(json['jenjang'], 'S1');
    });
  });

  group('Prodi.toString', () {
    test('toString menghasilkan representasi yang readable', () {
      final prodi = Prodi(id: 'p001', nama: 'TI', jenjang: 'S1', pt: 'ITB', ptSingkat: 'ITB');
      expect(prodi.toString(), contains('Prodi'));
      expect(prodi.toString(), contains('TI'));
    });
  });

  group('ProdiDetail.fromJson', () {
    test('parsing JSON valid', () {
      final json = {
        'id_sp': 'sp001', 'id_sms': 'sms001', 'nama_pt': 'ITB', 'kode_pt': '001',
        'nama_prodi': 'Informatika', 'kode_prodi': 'IF', 'kel_bidang': 'Teknik',
        'jenj_didik': 'S1', 'tgl_berdiri': '2000-01-01', 'tgl_sk_selenggara': '2000-01-01',
        'sk_selenggara': 'SK001', 'no_tel': '021-123', 'no_fax': '021-456',
        'website': 'https://if.itb.ac.id', 'email': 'if@itb.ac.id', 'alamat': 'Bandung',
        'provinsi': 'Jawa Barat', 'kab_kota': 'Bandung', 'kecamatan': 'Coblong',
        'lintang': '-6.89', 'bujur': '107.61', 'status': 'Aktif', 'akreditasi': 'A',
        'akreditasi_internasional': 'ABET', 'status_akreditasi': 'Berlaku',
      };
      final detail = ProdiDetail.fromJson(json);
      expect(detail.namaProdi, 'Informatika');
      expect(detail.akreditasi, 'A');
      expect(detail.status, 'Aktif');
    });

    test('parsing dengan descJson', () {
      final json = {'id_sp': 'sp001', 'id_sms': 'sms001', 'nama_pt': 'ITB', 'kode_pt': '001',
        'nama_prodi': 'IF', 'kode_prodi': 'IF', 'kel_bidang': '', 'jenj_didik': 'S1',
        'tgl_berdiri': '', 'tgl_sk_selenggara': '', 'sk_selenggara': '', 'no_tel': '',
        'no_fax': '', 'website': '', 'email': '', 'alamat': '', 'provinsi': '',
        'kab_kota': '', 'kecamatan': '', 'lintang': '', 'bujur': '', 'status': '',
        'akreditasi': '', 'akreditasi_internasional': '', 'status_akreditasi': ''};
      final descJson = {'deskripsi_singkat': 'Program studi terbaik', 'visi': 'Menjadi yang terbaik',
        'misi': 'Mendidik', 'kompetensi': 'IT', 'capaian_belajar': 'Mampu', 'rata_masa_studi': '4.5'};
      final detail = ProdiDetail.fromJson(json, descJson);
      expect(detail.deskripsiSingkat, 'Program studi terbaik');
      expect(detail.visi, 'Menjadi yang terbaik');
      expect(detail.rataMasaStudi, '4.5');
    });
  });
}
