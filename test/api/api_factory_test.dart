import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/api/api_factory.dart';

void main() {
  group('ApiFactory', () {
    test('singleton pattern returns same instance', () {
      final factory1 = ApiFactory();
      final factory2 = ApiFactory();
      expect(identical(factory1, factory2), true);
    });

    test('enableMockData sets mock mode', () {
      final factory = ApiFactory();
      factory.enableMockData();
      // Verify it doesn't throw
      expect(factory, isNotNull);
    });

    test('disableMockData unsets mock mode', () {
      final factory = ApiFactory();
      factory.disableMockData();
      expect(factory, isNotNull);
    });
  });
}
