import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:db_cracker_tamaengs/core/error/exceptions.dart';
import 'package:db_cracker_tamaengs/features/economy/data/datasources/bi_remote_datasource.dart';
import 'package:db_cracker_tamaengs/features/economy/data/datasources/kemnaker_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('BiRemoteDataSourceImpl', () {
    late MockDio mockDio;
    late BiRemoteDataSourceImpl dataSource;

    setUp(() {
      mockDio = MockDio();
      dataSource = BiRemoteDataSourceImpl(dio: mockDio);
    });

    group('getExchangeRate', () {
      test('mengembalikan ExchangeRateModel pada response 200', () async {
        final responseData = {
          'data': [
            {
              'mata_uang': 'USD',
              'tanggal': '2024-03-15',
              'beli': 15750.0,
              'jual': 15850.0,
              'tengah': 15800.0,
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

        final result = await dataSource.getExchangeRate(
          currency: 'USD',
          date: '2024-03-15',
        );

        expect(result.currency, 'USD');
        expect(result.date, '2024-03-15');
        expect(result.buy, 15750.0);
        expect(result.sell, 15850.0);
        expect(result.middle, 15800.0);
      });

      test('melempar ServerException jika data kosong (weekend)', () async {
        final responseData = {
          'data': [],
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

        expect(
          () => dataSource.getExchangeRate(
            currency: 'USD',
            date: '2024-03-16', // Saturday
          ),
          throwsA(isA<ServerException>()),
        );
      });

      test('melempar TimeoutException pada timeout', () async {
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
          () => dataSource.getExchangeRate(
            currency: 'USD',
            date: '2024-03-15',
          ),
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
          () => dataSource.getExchangeRate(
            currency: 'USD',
            date: '2024-03-15',
          ),
          throwsA(isA<NetworkException>()),
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
          () => dataSource.getExchangeRate(
            currency: 'USD',
            date: '2024-03-15',
          ),
          throwsA(isA<ServerException>()),
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
          () => dataSource.getExchangeRate(
            currency: 'USD',
            date: '2024-03-15',
          ),
          throwsA(isA<RateLimitException>()),
        );
      });

      test('melempar ServerException pada 401 authentication failed', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 401,
              requestOptions: RequestOptions(path: ''),
            ),
            requestOptions: RequestOptions(path: ''),
          ),
        );

        expect(
          () => dataSource.getExchangeRate(
            currency: 'USD',
            date: '2024-03-15',
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('getBiRate', () {
      test('mengembalikan BiRateModel pada response 200', () async {
        final responseData = {
          'data': [
            {
              'rate': 6.25,
              'effective_date': '2024-03-20',
              'description': 'BI-7 Day Reverse Repo Rate',
            },
          ],
        };

        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getBiRate();

        expect(result.rate, 6.25);
        expect(result.effectiveDate, '2024-03-20');
        expect(result.description, 'BI-7 Day Reverse Repo Rate');
      });

      test('melempar ServerException jika data null', () async {
        final responseData = {'data': null};

        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        expect(
          () => dataSource.getBiRate(),
          throwsA(isA<ServerException>()),
        );
      });

      test('melempar ServerException pada status non-200', () async {
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 503,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        expect(
          () => dataSource.getBiRate(),
          throwsA(isA<ServerException>()),
        );
      });
    });
  });

  group('KemnakerRemoteDataSourceImpl', () {
    late MockDio mockDio;
    late KemnakerRemoteDataSourceImpl dataSource;

    setUp(() {
      mockDio = MockDio();
      dataSource = KemnakerRemoteDataSourceImpl(dio: mockDio);
    });

    group('getUmp', () {
      test('mengembalikan list MinimumWageModel pada response 200', () async {
        final responseData = {
          'data': [
            {'provinsi': 'DKI Jakarta', 'ump': 5067381, 'tahun': 2024},
            {'provinsi': 'Jawa Barat', 'ump': 2057495, 'tahun': 2024},
            {'provinsi': 'Jawa Tengah', 'ump': 2032000, 'tahun': 2024},
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

        final result = await dataSource.getUmp(tahun: 2024);

        expect(result, hasLength(3));
        expect(result[0].provinsi, 'DKI Jakarta');
        expect(result[0].ump, 5067381);
        expect(result[1].provinsi, 'Jawa Barat');
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

        final result = await dataSource.getUmp(tahun: 1990);

        expect(result, isEmpty);
      });

      test('melempar ServerException pada status non-200', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer(
          (_) async => Response(
            data: {'error': 'Internal Server Error'},
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        expect(
          () => dataSource.getUmp(tahun: 2024),
          throwsA(isA<ServerException>()),
        );
      });

      test('melempar TimeoutException pada send timeout', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(
          DioException(
            type: DioExceptionType.sendTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        expect(
          () => dataSource.getUmp(tahun: 2024),
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
          () => dataSource.getUmp(tahun: 2024),
          throwsA(isA<NetworkException>()),
        );
      });

      test('parsing response dengan format result.records', () async {
        final responseData = {
          'result': {
            'records': [
              {'provinsi': 'Bali', 'ump': 2813000, 'tahun': 2024},
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

        final result = await dataSource.getUmp(tahun: 2024);

        expect(result, hasLength(1));
        expect(result[0].provinsi, 'Bali');
      });
    });

    group('getUmpByProvinsi', () {
      test('mengembalikan MinimumWageModel untuk provinsi tertentu', () async {
        final responseData = {
          'data': [
            {'provinsi': 'DKI Jakarta', 'ump': 5067381, 'tahun': 2024},
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

        final result = await dataSource.getUmpByProvinsi(
          provinsi: 'DKI Jakarta',
          tahun: 2024,
        );

        expect(result.provinsi, 'DKI Jakarta');
        expect(result.ump, 5067381);
        expect(result.tahun, 2024);
      });

      test('melempar ServerException jika data tidak ditemukan', () async {
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

        expect(
          () => dataSource.getUmpByProvinsi(
            provinsi: 'Provinsi Tidak Ada',
            tahun: 2024,
          ),
          throwsA(isA<ServerException>()),
        );
      });

      test('melempar ServerException pada 404', () async {
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
          () => dataSource.getUmpByProvinsi(
            provinsi: 'Unknown',
            tahun: 2024,
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });
  });
}
