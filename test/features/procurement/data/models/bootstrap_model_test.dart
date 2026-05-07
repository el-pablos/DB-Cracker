import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/features/procurement/data/models/bootstrap_model.dart';
import 'package:db_cracker_tamaengs/features/procurement/data/models/region_model.dart';

void main() {
  group('BootstrapModel', () {
    group('fromJson', () {
      test('parses full bootstrap payload correctly', () {
        final json = {
          'summary': {
            'totalPackages': 5000,
            'totalPriorityPackages': 800,
            'totalPotentialWaste': 15000000000.0,
            'totalBudget': 100000000000,
            'unmappedPackages': 200,
            'multiLocationPackages': 50,
          },
          'regions': [
            {
              'regionKey': 'jawa-barat-kab-bandung',
              'regionName': 'Kabupaten Bandung',
              'totalPackages': 150,
            },
            {
              'regionKey': 'jawa-timur-kota-surabaya',
              'regionName': 'Kota Surabaya',
              'totalPackages': 200,
            },
          ],
          'legend': {'low': '#green', 'high': '#red'},
          'geo': {'center': [-6.2, 106.8], 'zoom': 5},
          'provinceView': {'totalProvinces': 34},
        };

        final model = BootstrapModel.fromJson(json);

        expect(model.summary, isNotNull);
        expect(model.summary!.totalPackages, 5000);
        expect(model.summary!.totalPriorityPackages, 800);
        expect(model.summary!.totalPotentialWaste, 15000000000.0);
        expect(model.summary!.totalBudget, 100000000000);
        expect(model.summary!.unmappedPackages, 200);
        expect(model.summary!.multiLocationPackages, 50);
        expect(model.regions, hasLength(2));
        expect(model.regions[0].regionKey, 'jawa-barat-kab-bandung');
        expect(model.regions[1].regionKey, 'jawa-timur-kota-surabaya');
        expect(model.legend, isNotNull);
        expect(model.geo, isNotNull);
        expect(model.provinceView, isNotNull);
      });

      test('parses with empty regions list', () {
        final json = {
          'summary': {
            'totalPackages': 0,
            'totalBudget': 0,
          },
          'regions': <dynamic>[],
        };

        final model = BootstrapModel.fromJson(json);

        expect(model.regions, isEmpty);
        expect(model.regionCount, 0);
        expect(model.hasData, isFalse);
      });

      test('parses with null summary', () {
        final json = {
          'summary': null,
          'regions': [
            {'regionKey': 'test-region', 'totalPackages': 10},
          ],
        };

        final model = BootstrapModel.fromJson(json);

        expect(model.summary, isNull);
        expect(model.regions, hasLength(1));
        expect(model.hasData, isTrue);
      });

      test('handles completely empty json', () {
        final json = <String, dynamic>{};

        final model = BootstrapModel.fromJson(json);

        expect(model.summary, isNull);
        expect(model.regions, isEmpty);
        expect(model.legend, isNull);
        expect(model.geo, isNull);
        expect(model.provinceView, isNull);
        expect(model.regionCount, 0);
        expect(model.hasData, isFalse);
      });

      test('handles null regions field', () {
        final json = {
          'regions': null,
          'summary': {'totalPackages': 100},
        };

        final model = BootstrapModel.fromJson(json);

        expect(model.regions, isEmpty);
        expect(model.summary, isNotNull);
        expect(model.summary!.totalPackages, 100);
      });

      test('parses multiple regions with varying completeness', () {
        final json = {
          'regions': [
            {
              'regionKey': 'full-region',
              'code': '1234',
              'provinceName': 'Jawa Barat',
              'regionName': 'Kab. Bogor',
              'totalPackages': 500,
              'totalBudget': 99000000000,
            },
            {
              'regionKey': 'minimal-region',
            },
            {
              'regionKey': 'partial-region',
              'totalPackages': 10,
            },
          ],
        };

        final model = BootstrapModel.fromJson(json);

        expect(model.regions, hasLength(3));
        expect(model.regions[0].totalPackages, 500);
        expect(model.regions[1].totalPackages, 0);
        expect(model.regions[2].totalPackages, 10);
      });
    });

    group('toJson', () {
      test('produces valid map with all fields', () {
        final model = BootstrapModel(
          summary: const BootstrapSummaryModel(
            totalPackages: 100,
            totalBudget: 5000000000,
          ),
          regions: const [
            RegionModel(regionKey: 'region-a', totalPackages: 50),
            RegionModel(regionKey: 'region-b', totalPackages: 50),
          ],
          legend: {'low': 'green'},
          geo: {'zoom': 7},
          provinceView: {'count': 34},
        );

        final json = model.toJson();

        expect(json['summary'], isA<Map<String, dynamic>>());
        expect(json['regions'], isA<List>());
        expect((json['regions'] as List), hasLength(2));
        expect(json['legend'], isNotNull);
        expect(json['geo'], isNotNull);
        expect(json['provinceView'], isNotNull);
      });

      test('omits null optional fields', () {
        const model = BootstrapModel(
          regions: [RegionModel(regionKey: 'only-region')],
        );

        final json = model.toJson();

        expect(json.containsKey('summary'), isFalse);
        expect(json.containsKey('legend'), isFalse);
        expect(json.containsKey('geo'), isFalse);
        expect(json.containsKey('provinceView'), isFalse);
        expect(json['regions'], hasLength(1));
      });
    });

    group('computed properties', () {
      test('regionCount returns correct count', () {
        const model = BootstrapModel(
          regions: [
            RegionModel(regionKey: 'a'),
            RegionModel(regionKey: 'b'),
            RegionModel(regionKey: 'c'),
          ],
        );
        expect(model.regionCount, 3);
      });

      test('hasData returns true when regions not empty', () {
        const model = BootstrapModel(
          regions: [RegionModel(regionKey: 'x')],
        );
        expect(model.hasData, isTrue);
      });

      test('hasData returns false when regions empty', () {
        const model = BootstrapModel(regions: []);
        expect(model.hasData, isFalse);
      });
    });
  });

  group('BootstrapSummaryModel', () {
    group('fromJson', () {
      test('parses complete summary data', () {
        final json = {
          'totalPackages': 10000,
          'totalPriorityPackages': 1500,
          'totalPotentialWaste': 25000000000.0,
          'totalBudget': 200000000000,
          'unmappedPackages': 500,
          'multiLocationPackages': 120,
        };

        final model = BootstrapSummaryModel.fromJson(json);

        expect(model.totalPackages, 10000);
        expect(model.totalPriorityPackages, 1500);
        expect(model.totalPotentialWaste, 25000000000.0);
        expect(model.totalBudget, 200000000000);
        expect(model.unmappedPackages, 500);
        expect(model.multiLocationPackages, 120);
      });

      test('defaults all fields to 0 when json is empty', () {
        final json = <String, dynamic>{};

        final model = BootstrapSummaryModel.fromJson(json);

        expect(model.totalPackages, 0);
        expect(model.totalPriorityPackages, 0);
        expect(model.totalPotentialWaste, 0.0);
        expect(model.totalBudget, 0);
        expect(model.unmappedPackages, 0);
        expect(model.multiLocationPackages, 0);
      });

      test('handles totalPotentialWaste as int', () {
        final json = {
          'totalPotentialWaste': 5000000000,
          'totalBudget': 10000000000,
        };

        final model = BootstrapSummaryModel.fromJson(json);
        expect(model.totalPotentialWaste, 5000000000.0);
        expect(model.totalPotentialWaste, isA<double>());
      });

      test('handles partial data gracefully', () {
        final json = {
          'totalPackages': 250,
          'totalBudget': 8000000000,
        };

        final model = BootstrapSummaryModel.fromJson(json);

        expect(model.totalPackages, 250);
        expect(model.totalBudget, 8000000000);
        expect(model.totalPriorityPackages, 0);
        expect(model.unmappedPackages, 0);
        expect(model.multiLocationPackages, 0);
      });
    });

    group('toJson', () {
      test('produces complete map', () {
        const model = BootstrapSummaryModel(
          totalPackages: 500,
          totalPriorityPackages: 75,
          totalPotentialWaste: 3000000000.0,
          totalBudget: 40000000000,
          unmappedPackages: 30,
          multiLocationPackages: 15,
        );

        final json = model.toJson();

        expect(json['totalPackages'], 500);
        expect(json['totalPriorityPackages'], 75);
        expect(json['totalPotentialWaste'], 3000000000.0);
        expect(json['totalBudget'], 40000000000);
        expect(json['unmappedPackages'], 30);
        expect(json['multiLocationPackages'], 15);
      });

      test('roundtrip preserves all values', () {
        const original = BootstrapSummaryModel(
          totalPackages: 999,
          totalPriorityPackages: 111,
          totalPotentialWaste: 7777777.77,
          totalBudget: 88888888,
          unmappedPackages: 22,
          multiLocationPackages: 33,
        );

        final json = original.toJson();
        final restored = BootstrapSummaryModel.fromJson(json);

        expect(restored.totalPackages, original.totalPackages);
        expect(restored.totalPriorityPackages, original.totalPriorityPackages);
        expect(restored.totalPotentialWaste, original.totalPotentialWaste);
        expect(restored.totalBudget, original.totalBudget);
        expect(restored.unmappedPackages, original.unmappedPackages);
        expect(restored.multiLocationPackages, original.multiLocationPackages);
      });
    });

    group('computed properties', () {
      test('wastePercentage calculates correctly', () {
        const model = BootstrapSummaryModel(
          totalPotentialWaste: 25000000000,
          totalBudget: 100000000000,
        );
        expect(model.wastePercentage, 25.0);
      });

      test('wastePercentage returns 0 when totalBudget is 0', () {
        const model = BootstrapSummaryModel(
          totalPotentialWaste: 5000000,
          totalBudget: 0,
        );
        expect(model.wastePercentage, 0);
      });

      test('mappedPercentage calculates correctly', () {
        const model = BootstrapSummaryModel(
          totalPackages: 1000,
          unmappedPackages: 200,
        );
        // (1000 - 200) / 1000 * 100 = 80%
        expect(model.mappedPercentage, 80.0);
      });

      test('mappedPercentage returns 0 when totalPackages is 0', () {
        const model = BootstrapSummaryModel(
          totalPackages: 0,
          unmappedPackages: 0,
        );
        expect(model.mappedPercentage, 0);
      });

      test('mappedPercentage handles all mapped (0 unmapped)', () {
        const model = BootstrapSummaryModel(
          totalPackages: 500,
          unmappedPackages: 0,
        );
        expect(model.mappedPercentage, 100.0);
      });
    });
  });
}
