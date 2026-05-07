import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/features/procurement/data/models/region_model.dart';

void main() {
  group('RegionModel', () {
    group('fromJson', () {
      test('parses complete data with all fields', () {
        final json = {
          'regionKey': 'jawa-barat-kab-bandung',
          'code': '3204',
          'provinceName': 'Jawa Barat',
          'regionName': 'Kabupaten Bandung',
          'regionType': 'kabupaten',
          'displayName': 'Kab. Bandung',
          'totalPackages': 150,
          'totalPriorityPackages': 25,
          'totalFlaggedPackages': 10,
          'totalPotentialWaste': 2500000000.5,
          'totalBudget': 50000000000,
          'avgRiskScore': 0.45,
          'maxRiskScore': 0.92,
          'ownerMix': {'K/L': 30, 'Pemda': 120},
          'severityCounts': {'low': 80, 'med': 50, 'high': 15, 'absurd': 5},
          'dominantOwnerType': 'Pemda',
        };

        final model = RegionModel.fromJson(json);

        expect(model.regionKey, 'jawa-barat-kab-bandung');
        expect(model.code, '3204');
        expect(model.provinceName, 'Jawa Barat');
        expect(model.regionName, 'Kabupaten Bandung');
        expect(model.regionType, 'kabupaten');
        expect(model.displayName, 'Kab. Bandung');
        expect(model.totalPackages, 150);
        expect(model.totalPriorityPackages, 25);
        expect(model.totalFlaggedPackages, 10);
        expect(model.totalPotentialWaste, 2500000000.5);
        expect(model.totalBudget, 50000000000);
        expect(model.avgRiskScore, 0.45);
        expect(model.maxRiskScore, 0.92);
        expect(model.ownerMix, isNotNull);
        expect(model.ownerMix!['K/L'], 30);
        expect(model.severityCounts, isNotNull);
        expect(model.severityCounts!['high'], 15);
        expect(model.dominantOwnerType, 'Pemda');
      });

      test('parses minimal data with only regionKey', () {
        final json = {'regionKey': 'minimal-region'};

        final model = RegionModel.fromJson(json);

        expect(model.regionKey, 'minimal-region');
        expect(model.code, isNull);
        expect(model.provinceName, isNull);
        expect(model.regionName, isNull);
        expect(model.regionType, isNull);
        expect(model.displayName, isNull);
        expect(model.totalPackages, 0);
        expect(model.totalPriorityPackages, 0);
        expect(model.totalFlaggedPackages, 0);
        expect(model.totalPotentialWaste, 0);
        expect(model.totalBudget, 0);
        expect(model.avgRiskScore, 0);
        expect(model.maxRiskScore, 0);
        expect(model.ownerMix, isNull);
        expect(model.severityCounts, isNull);
        expect(model.dominantOwnerType, isNull);
      });

      test('defaults numeric fields to 0 when missing', () {
        final json = {
          'regionKey': 'empty-numerics',
          'regionName': 'Test Region',
        };

        final model = RegionModel.fromJson(json);

        expect(model.totalPackages, 0);
        expect(model.totalPriorityPackages, 0);
        expect(model.totalFlaggedPackages, 0);
        expect(model.totalPotentialWaste, 0.0);
        expect(model.totalBudget, 0);
        expect(model.avgRiskScore, 0.0);
        expect(model.maxRiskScore, 0.0);
      });

      test('defaults regionKey to empty string when null', () {
        final json = <String, dynamic>{'regionKey': null};

        final model = RegionModel.fromJson(json);
        expect(model.regionKey, '');
      });

      test('handles totalPotentialWaste as int from API', () {
        final json = {
          'regionKey': 'int-waste',
          'totalPotentialWaste': 5000000000,
        };

        final model = RegionModel.fromJson(json);
        expect(model.totalPotentialWaste, 5000000000.0);
        expect(model.totalPotentialWaste, isA<double>());
      });

      test('handles avgRiskScore and maxRiskScore as int', () {
        final json = {
          'regionKey': 'int-scores',
          'avgRiskScore': 0,
          'maxRiskScore': 1,
        };

        final model = RegionModel.fromJson(json);
        expect(model.avgRiskScore, 0.0);
        expect(model.maxRiskScore, 1.0);
      });
    });

    group('toJson', () {
      test('produces valid map with all fields', () {
        final model = RegionModel(
          regionKey: 'test-region',
          code: '1234',
          provinceName: 'Jawa Timur',
          regionName: 'Kota Surabaya',
          regionType: 'kota',
          displayName: 'Surabaya',
          totalPackages: 200,
          totalPriorityPackages: 30,
          totalFlaggedPackages: 5,
          totalPotentialWaste: 1000000000.0,
          totalBudget: 20000000000,
          avgRiskScore: 0.35,
          maxRiskScore: 0.8,
          ownerMix: {'Pemda': 180, 'K/L': 20},
          severityCounts: {'low': 150, 'med': 40, 'high': 10},
          dominantOwnerType: 'Pemda',
        );

        final json = model.toJson();

        expect(json['regionKey'], 'test-region');
        expect(json['code'], '1234');
        expect(json['provinceName'], 'Jawa Timur');
        expect(json['regionName'], 'Kota Surabaya');
        expect(json['regionType'], 'kota');
        expect(json['displayName'], 'Surabaya');
        expect(json['totalPackages'], 200);
        expect(json['totalPriorityPackages'], 30);
        expect(json['totalFlaggedPackages'], 5);
        expect(json['totalPotentialWaste'], 1000000000.0);
        expect(json['totalBudget'], 20000000000);
        expect(json['avgRiskScore'], 0.35);
        expect(json['maxRiskScore'], 0.8);
        expect(json['ownerMix'], isNotNull);
        expect(json['severityCounts'], isNotNull);
        expect(json['dominantOwnerType'], 'Pemda');
      });

      test('omits null optional fields', () {
        const model = RegionModel(regionKey: 'minimal');

        final json = model.toJson();

        expect(json['regionKey'], 'minimal');
        expect(json.containsKey('code'), isFalse);
        expect(json.containsKey('provinceName'), isFalse);
        expect(json.containsKey('regionName'), isFalse);
        expect(json.containsKey('regionType'), isFalse);
        expect(json.containsKey('displayName'), isFalse);
        expect(json.containsKey('ownerMix'), isFalse);
        expect(json.containsKey('severityCounts'), isFalse);
        expect(json.containsKey('dominantOwnerType'), isFalse);
        // Numeric fields always present
        expect(json['totalPackages'], 0);
        expect(json['totalBudget'], 0);
      });

      test('roundtrip fromJson → toJson → fromJson preserves data', () {
        final originalJson = {
          'regionKey': 'roundtrip-test',
          'code': '9999',
          'provinceName': 'Papua',
          'regionName': 'Kota Jayapura',
          'regionType': 'kota',
          'displayName': 'Jayapura',
          'totalPackages': 50,
          'totalPriorityPackages': 8,
          'totalFlaggedPackages': 3,
          'totalPotentialWaste': 750000000.0,
          'totalBudget': 5000000000,
          'avgRiskScore': 0.55,
          'maxRiskScore': 0.85,
          'dominantOwnerType': 'K/L',
        };

        final model1 = RegionModel.fromJson(originalJson);
        final json = model1.toJson();
        final model2 = RegionModel.fromJson(json);

        expect(model2.regionKey, model1.regionKey);
        expect(model2.code, model1.code);
        expect(model2.provinceName, model1.provinceName);
        expect(model2.totalPackages, model1.totalPackages);
        expect(model2.totalPotentialWaste, model1.totalPotentialWaste);
        expect(model2.avgRiskScore, model1.avgRiskScore);
        expect(model2.maxRiskScore, model1.maxRiskScore);
      });
    });

    group('computed properties', () {
      test('label returns displayName when available', () {
        const model = RegionModel(
          regionKey: 'key',
          displayName: 'Display',
          regionName: 'Region',
        );
        expect(model.label, 'Display');
      });

      test('label falls back to regionName when displayName is null', () {
        const model = RegionModel(
          regionKey: 'key',
          regionName: 'Region Name',
        );
        expect(model.label, 'Region Name');
      });

      test('label falls back to regionKey when both are null', () {
        const model = RegionModel(regionKey: 'fallback-key');
        expect(model.label, 'fallback-key');
      });

      test('isHighRisk returns true when maxRiskScore >= 0.7', () {
        const model = RegionModel(
          regionKey: 'risky',
          maxRiskScore: 0.75,
          totalFlaggedPackages: 0,
        );
        expect(model.isHighRisk, isTrue);
      });

      test('isHighRisk returns true when totalFlaggedPackages > 0', () {
        const model = RegionModel(
          regionKey: 'flagged',
          maxRiskScore: 0.3,
          totalFlaggedPackages: 1,
        );
        expect(model.isHighRisk, isTrue);
      });

      test('isHighRisk returns false when both conditions unmet', () {
        const model = RegionModel(
          regionKey: 'safe',
          maxRiskScore: 0.5,
          totalFlaggedPackages: 0,
        );
        expect(model.isHighRisk, isFalse);
      });
    });

    group('equality', () {
      test('two models with same regionKey are equal', () {
        const a = RegionModel(regionKey: 'same', totalPackages: 10);
        const b = RegionModel(regionKey: 'same', totalPackages: 99);
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('two models with different regionKey are not equal', () {
        const a = RegionModel(regionKey: 'alpha');
        const b = RegionModel(regionKey: 'beta');
        expect(a, isNot(equals(b)));
      });
    });
  });
}
