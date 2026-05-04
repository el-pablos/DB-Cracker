import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/models/pt.dart';

void main() {
  group('PerguruanTinggi.fromJson', () {
    test('parsing JSON valid', () {
      final json = {'id': 'pt001', 'kode': '001', 'nama_singkat': 'UI', 'nama': 'Universitas Indonesia'};
      final pt = PerguruanTinggi.fromJson(json);
      expect(pt.id, 'pt001');
      expect(pt.kode, '001');
      expect(pt.namaSingkat, 'UI');
      expect(pt.nama, 'Universitas Indonesia');
    });

    test('parsing JSON kosong return fallback', () {
      final pt = PerguruanTinggi.fromJson({});
      expect(pt.id, '');
      expect(pt.nama, '');
    });

    test('null values return empty string', () {
      final pt = PerguruanTinggi.fromJson({'id': null, 'kode': null, 'nama_singkat': null, 'nama': null});
      expect(pt.id, '');
      expect(pt.kode, '');
    });
  });

  group('PerguruanTinggi.toJson', () {
    test('toJson menghasilkan map yang benar', () {
      final pt = PerguruanTinggi(id: 'pt001', kode: '001', namaSingkat: 'UI', nama: 'Universitas Indonesia');
      final json = pt.toJson();
      expect(json['id'], 'pt001');
      expect(json['nama'], 'Universitas Indonesia');
    });
  });

  group('PerguruanTinggiDetail.fromJson', () {
    test('parsing JSON valid', () {
      final json = {
        'kelompok': 'PTN', 'pembina': 'Kemdikbud', 'id_sp': 'sp001', 'kode_pt': '001',
        'email': 'info@ui.ac.id', 'no_tel': '021-123', 'no_fax': '021-456',
        'website': 'https://ui.ac.id', 'alamat': 'Depok', 'nama_pt': 'Universitas Indonesia',
        'nm_singkat': 'UI', 'kode_pos': '16424', 'provinsi_pt': 'Jawa Barat',
        'kab_kota_pt': 'Depok', 'kecamatan_pt': 'Beji', 'lintang_pt': '-6.36',
        'bujur_pt': '106.83', 'tgl_berdiri_pt': '1950-02-02', 'tgl_sk_pendirian_sp': '1950-02-02',
        'sk_pendirian_sp': 'SK001', 'status_pt': 'Aktif', 'akreditasi_pt': 'A',
        'status_akreditasi': 'Berlaku',
      };
      final detail = PerguruanTinggiDetail.fromJson(json);
      expect(detail.namaPt, 'Universitas Indonesia');
      expect(detail.nmSingkat, 'UI');
      expect(detail.akreditasiPt, 'A');
      expect(detail.statusPt, 'Aktif');
    });

    test('parsing JSON kosong return fallback', () {
      final detail = PerguruanTinggiDetail.fromJson({});
      expect(detail.namaPt, '');
      expect(detail.kodePt, '');
    });
  });

  group('ProdiPt.fromJson', () {
    test('parsing JSON valid', () {
      final json = {
        'id_sms': 'sms001', 'kode_prodi': 'IF', 'nama_prodi': 'Informatika',
        'akreditasi': 'A', 'jenjang_prodi': 'S1', 'status_prodi': 'Aktif',
        'jumlah_dosen_nidn': '50', 'jumlah_dosen_nidk': '10', 'jumlah_dosen': '60',
        'jumlah_dosen_ajar': '55', 'jumlah_mahasiswa': '500', 'rasio': '1:8',
        'indikator_kelengkapan_data': '95%',
      };
      final prodiPt = ProdiPt.fromJson(json);
      expect(prodiPt.namaProdi, 'Informatika');
      expect(prodiPt.akreditasi, 'A');
      expect(prodiPt.jumlahMahasiswa, '500');
    });

    test('toJson roundtrip', () {
      final json = {
        'id_sms': 'sms001', 'kode_prodi': 'IF', 'nama_prodi': 'Informatika',
        'akreditasi': 'A', 'jenjang_prodi': 'S1', 'status_prodi': 'Aktif',
        'jumlah_dosen_nidn': '50', 'jumlah_dosen_nidk': '10', 'jumlah_dosen': '60',
        'jumlah_dosen_ajar': '55', 'jumlah_mahasiswa': '500', 'rasio': '1:8',
        'indikator_kelengkapan_data': '95%',
      };
      final prodiPt = ProdiPt.fromJson(json);
      final output = prodiPt.toJson();
      expect(output['nama_prodi'], 'Informatika');
      expect(output['akreditasi'], 'A');
    });
  });
}
