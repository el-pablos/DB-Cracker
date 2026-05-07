import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:db_cracker_tamaengs/core/error/exceptions.dart';
import 'package:db_cracker_tamaengs/features/disaster/data/datasources/bnpb_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late BnpbRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDio();
    dataSource = BnpbRemoteDataSourceImpl(dio: mockDio);
  });

  group('getRiskScore', () {
    test('mengembalikan DisasterRiskModel pada response 200', () async {
      final responseData = {
        'data': {
          'lat': -6.2088,
          'lon': 106.8456,
          'kabupaten': 'Kota Jakarta Selatan',
          'provinsi': 'DKI Jakarta',
          'risks': {
            'gempa_bumi': {'score': 24, 'risk_class': 'tinggi'},
            'banjir': {'score': 20, 'risk_class': 'sedang'},
            'longsor': {'score': 5, 'risk_class': 'rendah'},
          },
        },
      };

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.getRiskScore(
        lat: -6.2088,
        lon: 106.8456,
      );

      expect(result.lat, -6.2088);
      expect(result.lon, 106.8456);
      expect(result.kabupaten, 'Kota Jakarta Selatan');
      expect(result.provinsi, 'DKI Jakarta');
      expect(result.risks, hasLength(3));
      expect(result.risks['gempa_bumi']!.score, 24);
      expect(result.risks['gempa_bumi']!.isHighRisk, isTrue);
      expect(result.risks['banjir']!.isMediumRisk, isTrue);
    });

    test('melempar ServerException jika data null (koordinat invalid)', () async {
      final responseData = {'data': null};

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => dataSource.getRiskScore(lat: 999.0, lon: 999.0),
        throwsA(isA<ServerException>()),
      );
    });

    test('melempar ServerException pada status non-200', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: {'error': 'Server Error'},
          statusCode: 500,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => dataSource.getRiskScore(lat: -6.2, lon: 106.8),
        throwsA(isA<ServerException>()),
      );
    });

    test('melempar TimeoutException pada connection timeout', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => dataSource.getRiskScore(lat: -6.2, lon: 106.8),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('melempar NetworkException pada connection error', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => dataSource.getRiskScore(lat: -6.2, lon: 106.8),
        throwsA(isA<NetworkException>()),
      );
    });

    test('melempar RateLimitException pada status 429', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 429,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => dataSource.getRiskScore(lat: -6.2, lon: 106.8),
        throwsA(isA<RateLimitException>()),
      );
    });

    test('parsing response dengan format data sebagai list', () async {
      final responseData = {
        'data': [
          {
            'lat': -7.25,
            'lon': 112.75,
            'kabupaten': 'Kota Surabaya',
            'provinsi': 'Jawa Timur',
            'risks': {
              'banjir': {'score': 18, 'risk_class': 'sedang'},
            },
          },
        ],
      };

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.getRiskScore(
        lat: -7.25,
        lon: 112.75,
      );

      expect(result.kabupaten, 'Kota Surabaya');
      expect(result.risks['banjir']!.score, 18);
    });
  });

  group('getIrbi', () {
    test('mengembalikan list IrbiModel pada response 200', () async {
      final responseData = {
        'data': [
          {
            'kode_wilayah': '3201',
            'nama_wilayah': 'Kabupaten Bogor',
            'provinsi': 'Jawa Barat',
            'skor_total': 185.5,
            'dominant_hazard': 'banjir',
            'hazard_scores': {
              'banjir': 35.5,
              'longsor': 28.0,
              'gempa_bumi': 25.0,
            },
          },
          {
            'kode_wilayah': '3301',
            'nama_wilayah': 'Kabupaten Cilacap',
            'provinsi': 'Jawa Tengah',
            'skor_total': 170.0,
            'dominant_hazard': 'tsunami',
            'hazard_scores': {
              'tsunami': 40.0,
              'gempa_bumi': 30.0,
            },
          },
        ],
      };

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.getIrbi(tahun: 2023);

      expect(result, hasLength(2));
      expect(result[0].kodeWilayah, '3201');
      expect(result[0].namaWilayah, 'Kabupaten Bogor');
      expect(result[0].skorTotal, 185.5);
      expect(result[0].riskCategory, 'Tinggi');
      expect(result[1].dominantHazard, 'tsunami');
    });

    test('mengembalikan list kosong jika data kosong', () async {
      final responseData = {'data': []};

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.getIrbi(tahun: 1990);

      expect(result, isEmpty);
    });

    test('melempar ServerException pada status non-200', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: {'error': 'Server Error'},
          statusCode: 500,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => dataSource.getIrbi(tahun: 2023),
        throwsA(isA<ServerException>()),
      );
    });

    test('melempar TimeoutException pada receive timeout', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => dataSource.getIrbi(tahun: 2023),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('parsing response dengan format result.records', () async {
      final responseData = {
        'result': {
          'records': [
            {
              'kode_wilayah': '5101',
              'nama_wilayah': 'Kabupaten Jembrana',
              'provinsi': 'Bali',
              'skor_total': 95.0,
              'dominant_hazard': 'gempa_bumi',
              'hazard_scores': {'gempa_bumi': 30.0},
            },
          ],
        },
      };

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.getIrbi(tahun: 2023);

      expect(result, hasLength(1));
      expect(result[0].kodeWilayah, '5101');
      expect(result[0].riskCategory, 'Sedang');
    });
  });

  group('getIrbiByProvinsi', () {
    test('mengembalikan list IrbiModel untuk provinsi tertentu', () async {
      final responseData = {
        'data': [
          {
            'kode_wilayah': '3201',
            'nama_wilayah': 'Kabupaten Bogor',
            'provinsi': 'Jawa Barat',
            'skor_total': 185.5,
            'dominant_hazard': 'banjir',
            'hazard_scores': {'banjir': 35.5},
          },
          {
            'kode_wilayah': '3202',
            'nama_wilayah': 'Kabupaten Sukabumi',
            'provinsi': 'Jawa Barat',
            'skor_total': 175.0,
            'dominant_hazard': 'longsor',
            'hazard_scores': {'longsor': 32.0},
          },
        ],
      };

      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.getIrbiByProvinsi(
        tahun: 2023,
        provinsi: 'Jawa Barat',
      );

      expect(result, hasLength(2));
      expect(result[0].provinsi, 'Jawa Barat');
      expect(result[1].provinsi, 'Jawa Barat');
    });

    test('melempar ServerException pada status non-200', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: {},
          statusCode: 503,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => dataSource.getIrbiByProvinsi(
          tahun: 2023,
          provinsi: 'Test',
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('melempar ServerException pada 404 DioException', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => dataSource.getIrbiByProvinsi(
          tahun: 2023,
          provinsi: 'Provinsi Tidak Ada',
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
