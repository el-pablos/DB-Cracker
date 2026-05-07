import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/features/procurement/data/models/package_model.dart';

void main() {
  group('ProcurementPackageModel', () {
    group('fromJson', () {
      test('parses complete valid data correctly', () {
        final json = {
          'id': 42,
          'sourceId': 'SRC-001',
          'packageName': 'Pengadaan Laptop Dinas',
          'ownerName': 'Kementerian Pendidikan',
          'ownerType': 'K/L',
          'satker': 'Satker Jakarta Pusat',
          'locationRaw': 'DKI Jakarta',
          'budget': 5000000000,
          'fundingSource': 'APBN',
          'procurementType': 'Barang',
          'procurementMethod': 'Tender',
          'selectionDate': '2024-06-15',
          'audit': {
            'schemaVersion': '1.0',
            'severity': 'high',
            'potensiPemborosan': 0.85,
            'reason': 'Harga di atas rata-rata pasar',
            'flags': {
              'isMencurigakan': true,
              'isPemborosan': true,
            },
          },
          'meta': {
            'isPriority': true,
            'isFlagged': true,
            'riskScore': 0.92,
            'activeTagCount': 3,
            'mappedRegionCount': 2,
          },
        };

        final model = ProcurementPackageModel.fromJson(json);

        expect(model.id, 42);
        expect(model.sourceId, 'SRC-001');
        expect(model.packageName, 'Pengadaan Laptop Dinas');
        expect(model.ownerName, 'Kementerian Pendidikan');
        expect(model.ownerType, 'K/L');
        expect(model.satker, 'Satker Jakarta Pusat');
        expect(model.locationRaw, 'DKI Jakarta');
        expect(model.budget, 5000000000);
        expect(model.fundingSource, 'APBN');
        expect(model.procurementType, 'Barang');
        expect(model.procurementMethod, 'Tender');
        expect(model.selectionDate, '2024-06-15');
        expect(model.audit, isNotNull);
        expect(model.meta, isNotNull);
      });

      test('parses null optional fields gracefully', () {
        final json = {
          'id': 1,
          'sourceId': 'SRC-002',
          'packageName': 'Paket Minimal',
          'ownerName': 'Pemda',
          'ownerType': 'Pemda',
          'satker': null,
          'locationRaw': null,
          'budget': null,
          'fundingSource': null,
          'procurementType': null,
          'procurementMethod': null,
          'selectionDate': null,
          'audit': null,
          'meta': null,
        };

        final model = ProcurementPackageModel.fromJson(json);

        expect(model.id, 1);
        expect(model.sourceId, 'SRC-002');
        expect(model.satker, isNull);
        expect(model.locationRaw, isNull);
        expect(model.budget, isNull);
        expect(model.fundingSource, isNull);
        expect(model.procurementType, isNull);
        expect(model.procurementMethod, isNull);
        expect(model.selectionDate, isNull);
        expect(model.audit, isNull);
        expect(model.meta, isNull);
      });

      test('handles missing fields with defensive defaults', () {
        final json = <String, dynamic>{};

        final model = ProcurementPackageModel.fromJson(json);

        expect(model.id, 0);
        expect(model.sourceId, '');
        expect(model.packageName, '');
        expect(model.ownerName, '');
        expect(model.ownerType, '');
        expect(model.satker, isNull);
        expect(model.budget, isNull);
        expect(model.audit, isNull);
        expect(model.meta, isNull);
      });

      test('handles budget edge cases: zero value', () {
        final json = {
          'id': 10,
          'sourceId': 'SRC-ZERO',
          'packageName': 'Zero Budget',
          'ownerName': 'Test',
          'ownerType': 'Test',
          'budget': 0,
        };

        final model = ProcurementPackageModel.fromJson(json);
        expect(model.budget, 0);
      });

      test('handles budget edge cases: very large number', () {
        final json = {
          'id': 11,
          'sourceId': 'SRC-BIG',
          'packageName': 'Mega Project',
          'ownerName': 'Kementerian PUPR',
          'ownerType': 'K/L',
          'budget': 999999999999999,
        };

        final model = ProcurementPackageModel.fromJson(json);
        expect(model.budget, 999999999999999);
      });
    });

    group('toJson', () {
      test('produces valid map with all fields', () {
        const model = ProcurementPackageModel(
          id: 5,
          sourceId: 'SRC-005',
          packageName: 'Test Package',
          ownerName: 'Owner',
          ownerType: 'K/L',
          satker: 'Satker A',
          budget: 100000000,
          fundingSource: 'APBD',
        );

        final json = model.toJson();

        expect(json['id'], 5);
        expect(json['sourceId'], 'SRC-005');
        expect(json['packageName'], 'Test Package');
        expect(json['ownerName'], 'Owner');
        expect(json['ownerType'], 'K/L');
        expect(json['satker'], 'Satker A');
        expect(json['budget'], 100000000);
        expect(json['fundingSource'], 'APBD');
      });

      test('omits null optional fields from output', () {
        const model = ProcurementPackageModel(
          id: 6,
          sourceId: 'SRC-006',
          packageName: 'Minimal',
          ownerName: 'Owner',
          ownerType: 'Pemda',
        );

        final json = model.toJson();

        expect(json.containsKey('satker'), isFalse);
        expect(json.containsKey('locationRaw'), isFalse);
        expect(json.containsKey('budget'), isFalse);
        expect(json.containsKey('fundingSource'), isFalse);
        expect(json.containsKey('procurementType'), isFalse);
        expect(json.containsKey('procurementMethod'), isFalse);
        expect(json.containsKey('selectionDate'), isFalse);
        expect(json.containsKey('audit'), isFalse);
        expect(json.containsKey('meta'), isFalse);
      });

      test('roundtrip fromJson → toJson preserves data', () {
        final originalJson = {
          'id': 99,
          'sourceId': 'ROUND-001',
          'packageName': 'Roundtrip Test',
          'ownerName': 'Tester',
          'ownerType': 'K/L',
          'satker': 'Satker X',
          'budget': 250000000,
          'audit': {
            'severity': 'med',
            'potensiPemborosan': 0.45,
          },
          'meta': {
            'isPriority': true,
            'isFlagged': false,
            'riskScore': 0.6,
            'activeTagCount': 2,
            'mappedRegionCount': 1,
          },
        };

        final model = ProcurementPackageModel.fromJson(originalJson);
        final outputJson = model.toJson();

        expect(outputJson['id'], originalJson['id']);
        expect(outputJson['sourceId'], originalJson['sourceId']);
        expect(outputJson['packageName'], originalJson['packageName']);
        expect(outputJson['budget'], originalJson['budget']);
      });
    });

    group('equality', () {
      test('two models with same id and sourceId are equal', () {
        const a = ProcurementPackageModel(
          id: 1,
          sourceId: 'X',
          packageName: 'A',
          ownerName: 'O',
          ownerType: 'T',
        );
        const b = ProcurementPackageModel(
          id: 1,
          sourceId: 'X',
          packageName: 'B',
          ownerName: 'P',
          ownerType: 'U',
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('two models with different id are not equal', () {
        const a = ProcurementPackageModel(
          id: 1,
          sourceId: 'X',
          packageName: 'A',
          ownerName: 'O',
          ownerType: 'T',
        );
        const b = ProcurementPackageModel(
          id: 2,
          sourceId: 'X',
          packageName: 'A',
          ownerName: 'O',
          ownerType: 'T',
        );
        expect(a, isNot(equals(b)));
      });
    });
  });

  group('PackageAuditModel', () {
    group('fromJson', () {
      test('parses all severity values correctly', () {
        for (final severity in ['low', 'med', 'high', 'absurd']) {
          final json = {
            'severity': severity,
            'potensiPemborosan': 0.5,
          };
          final model = PackageAuditModel.fromJson(json);
          expect(model.severity, severity);
        }
      });

      test('defaults severity to unknown when missing', () {
        final json = <String, dynamic>{};
        final model = PackageAuditModel.fromJson(json);
        expect(model.severity, 'unknown');
        expect(model.potensiPemborosan, 0);
      });

      test('parses flags correctly', () {
        final json = {
          'severity': 'high',
          'potensiPemborosan': 0.9,
          'reason': 'Markup berlebihan',
          'flags': {
            'isMencurigakan': true,
            'isPemborosan': false,
          },
        };

        final model = PackageAuditModel.fromJson(json);

        expect(model.flags, isNotNull);
        expect(model.flags!.isMencurigakan, isTrue);
        expect(model.flags!.isPemborosan, isFalse);
        expect(model.reason, 'Markup berlebihan');
      });

      test('handles null flags gracefully', () {
        final json = {
          'severity': 'low',
          'potensiPemborosan': 0.1,
          'flags': null,
        };

        final model = PackageAuditModel.fromJson(json);
        expect(model.flags, isNull);
      });

      test('handles numeric potensiPemborosan as int', () {
        final json = {
          'severity': 'med',
          'potensiPemborosan': 1,
        };

        final model = PackageAuditModel.fromJson(json);
        expect(model.potensiPemborosan, 1.0);
        expect(model.potensiPemborosan, isA<double>());
      });
    });

    group('toJson', () {
      test('produces valid map', () {
        const model = PackageAuditModel(
          schemaVersion: '2.0',
          severity: 'absurd',
          potensiPemborosan: 0.99,
          reason: 'Extreme waste',
          flags: PackageFlagsModel(
            isMencurigakan: true,
            isPemborosan: true,
          ),
        );

        final json = model.toJson();

        expect(json['schemaVersion'], '2.0');
        expect(json['severity'], 'absurd');
        expect(json['potensiPemborosan'], 0.99);
        expect(json['reason'], 'Extreme waste');
        expect(json['flags'], isA<Map<String, dynamic>>());
        expect(json['flags']['isMencurigakan'], isTrue);
        expect(json['flags']['isPemborosan'], isTrue);
      });

      test('omits null optional fields', () {
        const model = PackageAuditModel(severity: 'low');

        final json = model.toJson();

        expect(json.containsKey('schemaVersion'), isFalse);
        expect(json.containsKey('reason'), isFalse);
        expect(json.containsKey('flags'), isFalse);
        expect(json['severity'], 'low');
        expect(json['potensiPemborosan'], 0);
      });
    });
  });

  group('PackageMetaModel', () {
    group('fromJson', () {
      test('parses complete data', () {
        final json = {
          'isPriority': true,
          'isFlagged': true,
          'riskScore': 0.88,
          'activeTagCount': 5,
          'mappedRegionCount': 3,
        };

        final model = PackageMetaModel.fromJson(json);

        expect(model.isPriority, isTrue);
        expect(model.isFlagged, isTrue);
        expect(model.riskScore, 0.88);
        expect(model.activeTagCount, 5);
        expect(model.mappedRegionCount, 3);
      });

      test('defaults all fields when json is empty', () {
        final json = <String, dynamic>{};

        final model = PackageMetaModel.fromJson(json);

        expect(model.isPriority, isFalse);
        expect(model.isFlagged, isFalse);
        expect(model.riskScore, 0);
        expect(model.activeTagCount, 0);
        expect(model.mappedRegionCount, 0);
      });

      test('handles riskScore as int from API', () {
        final json = {
          'riskScore': 1,
          'activeTagCount': 0,
          'mappedRegionCount': 0,
        };

        final model = PackageMetaModel.fromJson(json);
        expect(model.riskScore, 1.0);
        expect(model.riskScore, isA<double>());
      });
    });

    group('toJson', () {
      test('produces complete map', () {
        const model = PackageMetaModel(
          isPriority: true,
          isFlagged: false,
          riskScore: 0.75,
          activeTagCount: 2,
          mappedRegionCount: 4,
        );

        final json = model.toJson();

        expect(json['isPriority'], isTrue);
        expect(json['isFlagged'], isFalse);
        expect(json['riskScore'], 0.75);
        expect(json['activeTagCount'], 2);
        expect(json['mappedRegionCount'], 4);
      });
    });
  });

  group('PackageFlagsModel', () {
    test('fromJson with both true', () {
      final json = {'isMencurigakan': true, 'isPemborosan': true};
      final model = PackageFlagsModel.fromJson(json);
      expect(model.isMencurigakan, isTrue);
      expect(model.isPemborosan, isTrue);
    });

    test('fromJson defaults to false when missing', () {
      final json = <String, dynamic>{};
      final model = PackageFlagsModel.fromJson(json);
      expect(model.isMencurigakan, isFalse);
      expect(model.isPemborosan, isFalse);
    });

    test('toJson roundtrip', () {
      const model = PackageFlagsModel(
        isMencurigakan: true,
        isPemborosan: false,
      );
      final json = model.toJson();
      final restored = PackageFlagsModel.fromJson(json);
      expect(restored.isMencurigakan, model.isMencurigakan);
      expect(restored.isPemborosan, model.isPemborosan);
    });
  });
}
