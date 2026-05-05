import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/api/core/data_result.dart';

void main() {
  group('DataResult', () {
    test('DataResult.live sets correct sourceType and isStale=false', () {
      final result = DataResult.live(
        data: 'test',
        providerId: 'pddikti_fastapicloud',
        providerName: 'FastAPI Cloud',
      );
      expect(result.sourceType, DataSourceType.live);
      expect(result.isStale, false);
      expect(result.providerId, 'pddikti_fastapicloud');
    });

    test('DataResult.cached(isStale: false) returns memoryCache', () {
      final result = DataResult.cached(
        data: 'cached',
        providerId: 'cache',
        providerName: 'Cache',
        isStale: false,
      );
      expect(result.sourceType, DataSourceType.memoryCache);
      expect(result.isStale, false);
      expect(result.warning, isNull);
    });

    test('DataResult.cached(isStale: true) returns staleCache with warning', () {
      final result = DataResult.cached(
        data: 'stale',
        providerId: 'cache',
        providerName: 'Cache',
        isStale: true,
      );
      expect(result.sourceType, DataSourceType.staleCache);
      expect(result.isStale, true);
      expect(result.warning, isNotNull);
      expect(result.warning, contains('tidak terbaru'));
    });

    test('sourceLabel returns correct string for each type', () {
      expect(
        DataResult.live(data: '', providerId: 'x', providerName: 'X').sourceLabel,
        contains('live'),
      );
      expect(
        DataResult.cached(data: '', providerId: 'x', providerName: 'X', isStale: true).sourceLabel,
        contains('lama'),
      );
    });

    test('all DataSourceType values have sourceLabel', () {
      for (final type in DataSourceType.values) {
        final result = DataResult(
          data: '',
          sourceType: type,
          providerId: 'test',
          providerName: 'Test',
          isStale: false,
          fetchedAt: DateTime.now(),
        );
        expect(result.sourceLabel.isNotEmpty, true, reason: '$type should have label');
      }
    });
  });
}
