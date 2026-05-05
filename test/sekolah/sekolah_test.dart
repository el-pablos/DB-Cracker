import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:db_cracker_tamaengs/api/sekolah/sekolah_models.dart';
import 'package:db_cracker_tamaengs/api/sekolah/sekolah_service.dart';
import 'package:db_cracker_tamaengs/api/cache/in_memory_cache_store.dart';

void main() {
  late InMemoryCacheStore cacheStore;

  setUp(() {
    cacheStore = InMemoryCacheStore();
  });

  group('SekolahModels', () {
    test('1. parse response map dengan field standar', () {
      final json = {
        'npsn': '20100001',
        'nama': 'SMA Negeri 1 Bandung',
        'bentuk_pendidikan': 'SMA',
        'status_sekolah': 'Negeri',
        'alamat_jalan': 'Jl. Ir. H. Juanda No.93',
        'provinsi': 'Jawa Barat',
        'kabupaten_kota': 'Kota Bandung',
        'kecamatan': 'Coblong',
        'lintang': '-6.8934',
        'bujur': '107.6168',
      };
      final sekolah = Sekolah.fromJson(json);
      expect(sekolah.npsn, '20100001');
      expect(sekolah.nama, 'SMA Negeri 1 Bandung');
      expect(sekolah.bentukPendidikan, 'SMA');
      expect(sekolah.provinsi, 'Jawa Barat');
      expect(sekolah.lokasiLengkap, contains('Bandung'));
    });

    test('2. parse response dengan alternative keys', () {
      final json = {
        'npsn': '20200002',
        'nama_sekolah': 'SMK Telkom',
        'jenjang': 'SMK',
        'status': 'Swasta',
        'alamat': 'Jl. Telekomunikasi',
        'propinsi': 'Jawa Barat',
        'kab_kota': 'Kota Bandung',
        'latitude': '-6.97',
        'longitude': '107.63',
      };
      final sekolah = Sekolah.fromJson(json);
      expect(sekolah.nama, 'SMK Telkom');
      expect(sekolah.bentukPendidikan, 'SMK');
      expect(sekolah.lintang, '-6.97');
      expect(sekolah.bujur, '107.63');
    });

    test('3. field kosong tidak crash', () {
      final sekolah = Sekolah.fromJson({});
      expect(sekolah.npsn, '');
      expect(sekolah.nama, '');
      expect(sekolah.lokasiLengkap, '');
    });
  });

  group('SekolahService', () {
    test('4. NPSN kosong ditolak', () async {
      final client = MockClient((request) async => http.Response('', 200));
      final service = SekolahService(httpClient: client, cacheStore: cacheStore);
      final result = await service.lookupByNpsn('');
      expect(result, isNull);
    });

    test('5. NPSN non-numeric ditolak', () async {
      final client = MockClient((request) async => http.Response('', 200));
      final service = SekolahService(httpClient: client, cacheStore: cacheStore);
      final result = await service.lookupByNpsn('abc123');
      expect(result, isNull);
    });

    test('6. NPSN terlalu pendek ditolak', () async {
      final client = MockClient((request) async => http.Response('', 200));
      final service = SekolahService(httpClient: client, cacheStore: cacheStore);
      final result = await service.lookupByNpsn('123');
      expect(result, isNull);
    });

    test('7. lookup sukses dengan response nested data', () async {
      final client = MockClient((request) async {
        return http.Response(json.encode({
          'data': {
            'npsn': '20100001',
            'nama': 'SMA Negeri 1',
            'provinsi': 'Jawa Barat',
          }
        }), 200);
      });

      final service = SekolahService(httpClient: client, cacheStore: cacheStore);
      final result = await service.lookupByNpsn('20100001');

      expect(result, isNotNull);
      expect(result!.npsn, '20100001');
      expect(result.nama, 'SMA Negeri 1');
    });

    test('8. cache hit pada lookup kedua', () async {
      int requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        return http.Response(json.encode({
          'npsn': '20100001', 'nama': 'Test School'
        }), 200);
      });

      final service = SekolahService(httpClient: client, cacheStore: cacheStore);
      await service.lookupByNpsn('20100001');
      await service.lookupByNpsn('20100001');

      expect(requestCount, 1);
    });

    test('9. provider unavailable return null', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final service = SekolahService(httpClient: client, cacheStore: cacheStore);
      final result = await service.lookupByNpsn('99999999');
      expect(result, isNull);
    });
  });
}
