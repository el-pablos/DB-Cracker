import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:db_cracker_tamaengs/core/error/exceptions.dart';
import 'package:db_cracker_tamaengs/features/procurement/data/datasources/nemesis_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late NemesisRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDio();
    dataSource = NemesisRemoteDataSourceImpl(dio: mockDio);
  });

  group('getBootstrap', () {
    test('returns BootstrapModel on 200 success', () async {
      final responseData = {
        'summary': {
          'totalPackages': 3000,
          'totalPriorityPackages': 500,
          'totalPotentialWaste': 10000000000.0,
          'totalBudget': 80000000000,
          'unmappedPackages': 100,
          'multiLocationPackages': 25,
        },
        'regions': [
          {
            'regionKey': 'jawa-barat-kab-bandung',
            'regionName': 'Kabupaten Bandung',
            'totalPackages': 150,
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

      final result = await dataSource.getBootstrap();

      expect(result.summary, isNotNull);
      expect(result.summary!.totalPackages, 3000);
      expect(result.regions, hasLength(1));
      expect(result.regions[0].regionKey, 'jawa-barat-kab-bandung');
      verify(() => mockDio.get('https://nemesis.tams.codes/api/bootstrap'))
          .called(1);
    });

    test('throws ServerException on 500 server error', () async {
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          response: Response(
            data: {'error': 'Internal Server Error'},
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
          message: 'Server error',
        ),
      );

      expect(
        () => dataSource.getBootstrap(),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws RateLimitException on 429 response', () async {
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            data: {'error': 'Too Many Requests'},
            statusCode: 429,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
          message: 'Rate limited',
        ),
      );

      expect(
        () => dataSource.getBootstrap(),
        throwsA(isA<RateLimitException>()),
      );
    });

    test('throws ServerException on non-200 status code', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {'error': 'Not Found'},
          statusCode: 404,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => dataSource.getBootstrap(),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws TimeoutException on connectionTimeout', () async {
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: ''),
          message: 'Connection timeout',
        ),
      );

      expect(
        () => dataSource.getBootstrap(),
        throwsA(isA<TimeoutException>()),
      );
    });
  });

  group('getRegionPackages', () {
    test('returns PaginatedResponse on 200 success with pagination', () async {
      final responseData = {
        'data': [
          {
            'id': 1,
            'sourceId': 'PKG-001',
            'packageName': 'Pengadaan Komputer',
            'ownerName': 'Dinas Pendidikan',
            'ownerType': 'Pemda',
            'budget': 500000000,
          },
          {
            'id': 2,
            'sourceId': 'PKG-002',
            'packageName': 'Pembangunan Jalan',
            'ownerName': 'Dinas PU',
            'ownerType': 'Pemda',
            'budget': 2000000000,
          },
        ],
        'pagination': {
          'page': 1,
          'pageSize': 25,
          'totalItems': 150,
          'totalPages': 6,
        },
      };

      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.getRegionPackages(
        regionKey: 'jawa-barat-kab-bandung',
        page: 1,
        pageSize: 25,
      );

      expect(result.data, hasLength(2));
      expect(result.data[0].packageName, 'Pengadaan Komputer');
      expect(result.data[1].packageName, 'Pembangunan Jalan');
      expect(result.pagination, isNotNull);
      expect(result.pagination!.page, 1);
      expect(result.pagination!.totalItems, 150);
      expect(result.pagination!.totalPages, 6);
    });

    test('passes filter parameters correctly', () async {
      final responseData = {
        'data': [
          {
            'id': 5,
            'sourceId': 'PKG-005',
            'packageName': 'Filtered Package',
            'ownerName': 'Kementerian',
            'ownerType': 'K/L',
          },
        ],
        'pagination': {
          'page': 1,
          'pageSize': 10,
          'totalItems': 1,
          'totalPages': 1,
        },
      };

      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      await dataSource.getRegionPackages(
        regionKey: 'test-region',
        page: 2,
        pageSize: 10,
        search: 'laptop',
        ownerType: 'K/L',
        severity: 'high',
        priorityOnly: true,
      );

      final captured = verify(
        () => mockDio.get(
          any(),
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured.last as Map<String, dynamic>;

      expect(captured['page'], 2);
      expect(captured['pageSize'], 10);
      expect(captured['search'], 'laptop');
      expect(captured['ownerType'], 'K/L');
      expect(captured['severity'], 'high');
      expect(captured['priorityOnly'], '1');
    });

    test('omits empty search and null filters from query params', () async {
      final responseData = {
        'data': <dynamic>[],
        'pagination': {
          'page': 1,
          'pageSize': 25,
          'totalItems': 0,
          'totalPages': 0,
        },
      };

      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      await dataSource.getRegionPackages(
        regionKey: 'test-region',
        search: '',
        ownerType: null,
        severity: null,
        priorityOnly: false,
      );

      final captured = verify(
        () => mockDio.get(
          any(),
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured.last as Map<String, dynamic>;

      expect(captured.containsKey('search'), isFalse);
      expect(captured.containsKey('ownerType'), isFalse);
      expect(captured.containsKey('severity'), isFalse);
      expect(captured.containsKey('priorityOnly'), isFalse);
    });

    test('throws RateLimitException on 429', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            data: {'error': 'Rate limited'},
            statusCode: 429,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => dataSource.getRegionPackages(regionKey: 'test'),
        throwsA(isA<RateLimitException>()),
      );
    });

    test('throws ServerException on non-200 response', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer(
        (_) async => Response(
          data: {'error': 'Forbidden'},
          statusCode: 403,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      expect(
        () => dataSource.getRegionPackages(regionKey: 'forbidden-region'),
        throwsA(isA<ServerException>()),
      );
    });

    test('handles empty data array gracefully', () async {
      final responseData = {
        'data': <dynamic>[],
        'pagination': null,
      };

      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.getRegionPackages(regionKey: 'empty');

      expect(result.data, isEmpty);
      expect(result.pagination, isNull);
    });

    test('calls correct URL with regionKey', () async {
      final responseData = {
        'data': <dynamic>[],
        'pagination': null,
      };

      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      await dataSource.getRegionPackages(regionKey: 'jawa-timur-kota-surabaya');

      verify(() => mockDio.get(
            'https://nemesis.tams.codes/api/regions/jawa-timur-kota-surabaya/packages',
            queryParameters: any(named: 'queryParameters'),
          )).called(1);
    });
  });

  group('healthCheck', () {
    test('returns true on 200 response', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {'status': 'ok'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.healthCheck();

      expect(result, isTrue);
      verify(() => mockDio.get('https://nemesis.tams.codes/api/health')).called(1);
    });

    test('returns false on non-200 response', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {'status': 'degraded'},
          statusCode: 503,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.healthCheck();

      expect(result, isFalse);
    });

    test('returns false on DioException', () async {
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final result = await dataSource.healthCheck();

      expect(result, isFalse);
    });

    test('returns false on generic exception', () async {
      when(() => mockDio.get(any())).thenThrow(Exception('Unknown error'));

      final result = await dataSource.healthCheck();

      expect(result, isFalse);
    });

    test('calls correct health endpoint URL', () async {
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: {'status': 'ok'},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      await dataSource.healthCheck();

      verify(() => mockDio.get('https://nemesis.tams.codes/api/health')).called(1);
    });
  });
}
