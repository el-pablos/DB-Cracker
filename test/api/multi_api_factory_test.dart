import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/api/multi_api_factory.dart';

void main() {
  group('MultiApiFactory', () {
    test('singleton pattern returns same instance', () {
      final factory1 = MultiApiFactory();
      final factory2 = MultiApiFactory();
      expect(identical(factory1, factory2), true);
    });

    test('instance is not null', () {
      final factory = MultiApiFactory();
      expect(factory, isNotNull);
    });
  });
}
