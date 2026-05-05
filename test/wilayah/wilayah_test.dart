import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:db_cracker_tamaengs/api/wilayah/wilayah_models.dart';
import 'package:db_cracker_tamaengs/api/wilayah/wilayah_service.dart';
import 'package:db_cracker_tamaengs/api/cache/in_memory_cache_store.dart';

void main() {
  late InMemoryCacheStore cacheStore;

  setUp(() {
    cacheStore = InMemoryCacheStore();
  });

  group('WilayahModels', () {
    test('1. parse wilayah.id province schema', () {
      final json = {'code': '32', 'name': 'Jawa Barat'};
      final province = Province.fromWilayahId(json, 'wilayah_id');
      expect(province.code, '32');
      expect(province.name, 'Jawa Barat');
      expect(province.providerId, 'wilayah_id');
    });

    test('2. parse emsifa province schema (UPPERCASE)', () {
      final json = {'id': '32', 'name': 'JAWA BARAT'};
      final province = Province.fromEmsifa(json, 'emsifa_wilayah');
      expect(province.code, '32');
      expect(province.name, 'Jawa Barat'); // Title case normalized
      expect(province.providerId, 'emsifa_wilayah');
    });

    test('3. parse regency wilayah.id', () {
      final json = {'code': '32.01', 'name': 'Kab. Bogor'};
      final regency = Regency.fromWilayahId(json, '32', 'wilayah_id');
      expect(regency.code, '32.01');
      expect(regency.provinceCode, '32');
      expect(regency.name, 'Kab. Bogor');
    });

    test('4. parse regency emsifa', () {
      final json = {'id': '3201', 'province_id': '32', 'name': 'KABUPATEN BOGOR'};
      final regency = Regency.fromEmsifa(json, 'emsifa_wilayah');
      expect(regency.code, '3201');
      expect(regency.provinceCode, '32');
      expect(regency.name, 'Kabupaten Bogor');
    });
  });

  group('WilayahService', () {
    test('5. fallback provider saat primary gagal', () async {
      final client = MockClient((request) async {
        if (request.url.host == 'wilayah.id') {
          return http.Response('Server Error', 500);
        }
        // Emsifa fallback
        return http.Response(json.encode([
          {'id': '11', 'name': 'ACEH'},
          {'id': '12', 'name': 'SUMATERA UTARA'},
        ]), 200);
      });

      final service = WilayahService(httpClient: client, cacheStore: cacheStore);
      final provinces = await service.getProvinces();

      expect(provinces.length, 2);
      expect(provinces.first.name, 'Aceh');
      expect(provinces.first.providerId, 'emsifa_wilayah');
    });

    test('6. cache hit tidak memanggil network', () async {
      int requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        return http.Response(json.encode({'data': [
          {'code': '11', 'name': 'Aceh'},
        ]}), 200);
      });

      final service = WilayahService(httpClient: client, cacheStore: cacheStore);

      await service.getProvinces(); // First call — network
      await service.getProvinces(); // Second call — should be cache

      expect(requestCount, 1); // Only 1 network call
    });

    test('7. findProvinceByName case-insensitive', () async {
      final client = MockClient((request) async {
        return http.Response(json.encode({'data': [
          {'code': '32', 'name': 'Jawa Barat'},
          {'code': '33', 'name': 'Jawa Tengah'},
        ]}), 200);
      });

      final service = WilayahService(httpClient: client, cacheStore: cacheStore);
      final result = await service.findProvinceByName('jawa barat');

      expect(result, isNotNull);
      expect(result!.code, '32');
    });

    test('8. response kosong tidak crash', () async {
      final client = MockClient((request) async {
        return http.Response('[]', 200);
      });

      final service = WilayahService(httpClient: client, cacheStore: cacheStore);
      final provinces = await service.getProvinces();

      expect(provinces, isEmpty);
    });

    test('9. response schema berbeda tidak crash', () async {
      final client = MockClient((request) async {
        return http.Response(json.encode({'unexpected': 'format'}), 200);
      });

      final service = WilayahService(httpClient: client, cacheStore: cacheStore);
      final provinces = await service.getProvinces();

      expect(provinces, isEmpty);
    });
  });
}
