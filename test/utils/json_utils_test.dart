import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/utils/json_utils.dart';

void main() {
  group('JsonUtils.ensureString', () {
    test('returns empty string for null', () {
      expect(JsonUtils.ensureString(null), '');
    });

    test('returns string for String input', () {
      expect(JsonUtils.ensureString('hello'), 'hello');
    });

    test('returns string for int input', () {
      expect(JsonUtils.ensureString(42), '42');
    });

    test('returns string for double input', () {
      expect(JsonUtils.ensureString(3.14), '3.14');
    });

    test('returns string for bool input', () {
      expect(JsonUtils.ensureString(true), 'true');
    });

    test('returns empty string for empty string', () {
      expect(JsonUtils.ensureString(''), '');
    });
  });

  group('JsonUtils.getStringValue', () {
    test('returns value for existing key', () {
      final json = {'name': 'John'};
      expect(JsonUtils.getStringValue(json, 'name'), 'John');
    });

    test('returns empty string for missing key', () {
      final json = {'name': 'John'};
      expect(JsonUtils.getStringValue(json, 'age'), '');
    });

    test('returns empty string for null value', () {
      final json = {'name': null};
      expect(JsonUtils.getStringValue(json, 'name'), '');
    });

    test('converts int value to string', () {
      final json = {'age': 25};
      expect(JsonUtils.getStringValue(json, 'age'), '25');
    });
  });

  group('JsonUtils.getStringFromKeys', () {
    test('returns first matching key value', () {
      final json = {'nama': 'John', 'name': 'Jane'};
      expect(JsonUtils.getStringFromKeys(json, ['nama', 'name']), 'John');
    });

    test('falls back to second key if first is null', () {
      final json = {'name': 'Jane'};
      expect(JsonUtils.getStringFromKeys(json, ['nama', 'name']), 'Jane');
    });

    test('returns empty string if no keys match', () {
      final json = {'foo': 'bar'};
      expect(JsonUtils.getStringFromKeys(json, ['nama', 'name']), '');
    });

    test('skips empty string values', () {
      final json = {'nama': '', 'name': 'Jane'};
      expect(JsonUtils.getStringFromKeys(json, ['nama', 'name']), 'Jane');
    });
  });
}
