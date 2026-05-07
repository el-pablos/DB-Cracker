import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:db_cracker_tamaengs/core/error/exceptions.dart';
import 'package:db_cracker_tamaengs/features/statistics/data/datasources/ckan_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late CkanRemoteDataSourceImpl dataSource;

  const baseUrl = 'https://data.go.id/api/3/action';

  setUp(() {
    mockDio = MockDio();
    dataSource = CkanRemoteDataSourceImpl(dio: mockDio);
  });

  group('searchPackages', () {
    test('mengembalikan list CkanDatasetModel pada response 200', () async {
      final responseData = {
        'result': {
          'results': [
            {
              'id': 'pkg-001',
              'name': 'kemiskinan-2024',
              'title': 'Data Kemiskinan 2024',
              'num_resources': 2,
            },
            {
              'id': 'pkg-002',
              'name': 'inflasi-2024',
              'title': 'Data Inflasi 2024',
              'num_resources': 1,
            },
          ],
          'count': 2,
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

      final result = await dataSource.searchPackages(
        baseUrl: baseUrl,
        query: 'kemiskinan',
        rows: 10,
        start: 0,
      );

      expect(result, hasLength(2));
      expect(result[0].id, 'pkg-001');
      expect(result[0].name, 'kemiskinan-2024');
      expect(result[1].id, 'pkg-002');
    });

    test('mengembalikan list kosong jika results kosong', () async {
      final responseData = {
        'result': {
          'results': [],
          'count': 0,
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

      final result = await dataSource.searchPackages(
        baseUrl: baseUrl,
        query: 'nonexistent',
      );

      expect(result, isEmpty);
    });

    test('mengembalikan list kosong jika result null', () async {
      final responseData = {'result': null};

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

      final result = await dataSource.searchPackages(
        baseUrl: baseUrl,
        query: 'test',
      );

      expect(result, isEmpty);
    });

    test('melempar ServerException pada status code non-200', () async {
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
        () => dataSource.searchPackages(baseUrl: baseUrl, query: 'test'),
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
        () => dataSource.searchPackages(baseUrl: baseUrl, query: 'test'),
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
        () => dataSource.searchPackages(baseUrl: baseUrl, query: 'test'),
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
        () => dataSource.searchPackages(baseUrl: baseUrl, query: 'test'),
        throwsA(isA<RateLimitException>()),
      );
    });
  });

  group('getPackage', () {
    test('mengembalikan CkanDatasetModel pada response 200', () async {
      final responseData = {
        'result': {
          'id': 'pkg-detail-001',
          'name': 'detail-dataset',
          'title': 'Detail Dataset',
          'notes': 'Deskripsi lengkap dataset',
          'resources': [
            {
              'id': 'res-1',
              'name': 'data.csv',
              'format': 'CSV',
              'url': 'https://data.go.id/res/data.csv',
              'datastore_active': true,
            },
          ],
          'num_resources': 1,
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

      final result = await dataSource.getPackage(
        baseUrl: baseUrl,
        id: 'pkg-detail-001',
      );

      expect(result.id, 'pkg-detail-001');
      expect(result.name, 'detail-dataset');
      expect(result.notes, 'Deskripsi lengkap dataset');
      expect(result.resources, hasLength(1));
    });

    test('melempar ServerException jika result null (not found)', () async {
      final responseData = {'result': null};

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
        () => dataSource.getPackage(baseUrl: baseUrl, id: 'nonexistent'),
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
            statusMessage: 'Not Found',
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => dataSource.getPackage(baseUrl: baseUrl, id: 'missing'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('queryDatastore', () {
    test('mengembalikan records dan metadata pada response 200', () async {
      final responseData = {
        'result': {
          'records': [
            {'id': 1, 'provinsi': 'DKI Jakarta', 'nilai': 9.5},
            {'id': 2, 'provinsi': 'Jawa Barat', 'nilai': 7.8},
          ],
          'fields': [
            {'id': 'id', 'type': 'int'},
            {'id': 'provinsi', 'type': 'text'},
            {'id': 'nilai', 'type': 'float'},
          ],
          'total': 100,
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

      final result = await dataSource.queryDatastore(
        baseUrl: baseUrl,
        resourceId: 'res-001',
        limit: 100,
        offset: 0,
      );

      expect((result['records'] as List), hasLength(2));
      expect((result['fields'] as List), hasLength(3));
      expect(result['total'], 100);
    });

    test('mengembalikan default kosong jika result null', () async {
      final responseData = {'result': null};

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

      final result = await dataSource.queryDatastore(
        baseUrl: baseUrl,
        resourceId: 'res-empty',
      );

      expect(result['records'], isEmpty);
      expect(result['fields'], isEmpty);
      expect(result['total'], 0);
    });

    test('menyertakan filters dalam query parameters', () async {
      final responseData = {
        'result': {
          'records': [
            {'provinsi': 'DKI Jakarta', 'nilai': 9.5},
          ],
          'fields': [],
          'total': 1,
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

      final result = await dataSource.queryDatastore(
        baseUrl: baseUrl,
        resourceId: 'res-001',
        filters: '{"provinsi":"DKI Jakarta"}',
        sort: 'nilai desc',
      );

      expect((result['records'] as List), hasLength(1));

      // Verify correct query parameters were passed
      final captured = verify(() => mockDio.get(
            any(),
            queryParameters: captureAny(named: 'queryParameters'),
          )).captured.last as Map<String, dynamic>;

      expect(captured['filters'], '{"provinsi":"DKI Jakarta"}');
      expect(captured['sort'], 'nilai desc');
    });

    test('melempar ServerException pada status code non-200', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => Response(
          data: {'error': 'Bad Request'},
          statusCode: 400,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => dataSource.queryDatastore(
          baseUrl: baseUrl,
          resourceId: 'invalid',
        ),
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
        () => dataSource.queryDatastore(
          baseUrl: baseUrl,
          resourceId: 'slow-resource',
        ),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
