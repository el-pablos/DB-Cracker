import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/features/statistics/data/models/statistics_models.dart';

void main() {
  group('CkanDatasetModel', () {
    group('fromJson', () {
      test('parsing data lengkap menghasilkan model yang benar', () {
        final json = {
          'id': 'dataset-001',
          'name': 'penduduk-miskin-2024',
          'title': 'Data Penduduk Miskin 2024',
          'notes': 'Dataset kemiskinan per provinsi',
          'organization': {'title': 'BPS'},
          'resources': [
            {
              'id': 'res-001',
              'name': 'data.csv',
              'format': 'csv',
              'url': 'https://data.go.id/res/data.csv',
              'size': 1024,
              'datastore_active': true,
            }
          ],
          'tags': [
            {'display_name': 'kemiskinan'},
            {'display_name': 'bps'},
          ],
          'num_resources': 1,
          'metadata_modified': '2024-03-15T10:00:00',
        };

        final model = CkanDatasetModel.fromJson(json);

        expect(model.id, 'dataset-001');
        expect(model.name, 'penduduk-miskin-2024');
        expect(model.title, 'Data Penduduk Miskin 2024');
        expect(model.notes, 'Dataset kemiskinan per provinsi');
        expect(model.organization, 'BPS');
        expect(model.resources, hasLength(1));
        expect(model.tags, ['kemiskinan', 'bps']);
        expect(model.numResources, 1);
        expect(model.metadataModified, '2024-03-15T10:00:00');
      });

      test('parsing dengan field null menghasilkan default values', () {
        final json = <String, dynamic>{};

        final model = CkanDatasetModel.fromJson(json);

        expect(model.id, '');
        expect(model.name, '');
        expect(model.title, '');
        expect(model.notes, isNull);
        expect(model.organization, isNull);
        expect(model.resources, isEmpty);
        expect(model.tags, isEmpty);
        expect(model.numResources, 0);
        expect(model.metadataModified, isNull);
      });

      test('parsing organization sebagai string langsung', () {
        final json = {
          'id': 'ds-1',
          'name': 'test',
          'title': 'Test',
          'organization': 'Kementerian Kesehatan',
        };

        final model = CkanDatasetModel.fromJson(json);

        expect(model.organization, 'Kementerian Kesehatan');
      });

      test('parsing tags sebagai list of string', () {
        final json = {
          'id': 'ds-2',
          'name': 'test',
          'title': 'Test',
          'tags': ['ekonomi', 'inflasi', 'bps'],
        };

        final model = CkanDatasetModel.fromJson(json);

        expect(model.tags, ['ekonomi', 'inflasi', 'bps']);
      });

      test('parsing tags dengan display_name kosong difilter', () {
        final json = {
          'id': 'ds-3',
          'name': 'test',
          'title': 'Test',
          'tags': [
            {'display_name': 'valid'},
            {'display_name': ''},
            {'display_name': 'juga-valid'},
          ],
        };

        final model = CkanDatasetModel.fromJson(json);

        expect(model.tags, ['valid', 'juga-valid']);
      });

      test('parsing resources null menghasilkan list kosong', () {
        final json = {
          'id': 'ds-4',
          'name': 'test',
          'title': 'Test',
          'resources': null,
        };

        final model = CkanDatasetModel.fromJson(json);

        expect(model.resources, isEmpty);
      });
    });

    group('toJson', () {
      test('roundtrip serialization mempertahankan data', () {
        final original = CkanDatasetModel(
          id: 'roundtrip-001',
          name: 'test-roundtrip',
          title: 'Test Roundtrip',
          notes: 'Catatan test',
          organization: 'BPS',
          resources: const [
            CkanResourceModel(
              id: 'r-1',
              name: 'file.csv',
              format: 'CSV',
              url: 'https://example.com/file.csv',
              size: 2048,
              datastoreActive: true,
            ),
          ],
          tags: const ['tag1', 'tag2'],
          numResources: 1,
          metadataModified: '2024-01-01',
        );

        final json = original.toJson();

        expect(json['id'], 'roundtrip-001');
        expect(json['name'], 'test-roundtrip');
        expect(json['title'], 'Test Roundtrip');
        expect(json['notes'], 'Catatan test');
        expect(json['organization'], 'BPS');
        expect(json['num_resources'], 1);
        expect(json['metadata_modified'], '2024-01-01');
        expect(json['tags'], ['tag1', 'tag2']);
        expect((json['resources'] as List), hasLength(1));
      });

      test('toJson tidak menyertakan field null', () {
        const model = CkanDatasetModel(
          id: 'no-null',
          name: 'test',
          title: 'Test',
        );

        final json = model.toJson();

        expect(json.containsKey('notes'), isFalse);
        expect(json.containsKey('organization'), isFalse);
        expect(json.containsKey('metadata_modified'), isFalse);
      });
    });

    group('equality', () {
      test('dua model dengan id sama dianggap equal', () {
        const a = CkanDatasetModel(id: 'same', name: 'a', title: 'A');
        const b = CkanDatasetModel(id: 'same', name: 'b', title: 'B');

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('dua model dengan id berbeda tidak equal', () {
        const a = CkanDatasetModel(id: 'id-1', name: 'a', title: 'A');
        const b = CkanDatasetModel(id: 'id-2', name: 'a', title: 'A');

        expect(a, isNot(equals(b)));
      });
    });
  });

  group('CkanResourceModel', () {
    group('fromJson', () {
      test('parsing data lengkap menghasilkan model yang benar', () {
        final json = {
          'id': 'res-abc',
          'name': 'data-kemiskinan.xlsx',
          'format': 'xlsx',
          'url': 'https://data.go.id/files/data-kemiskinan.xlsx',
          'size': 4096,
          'datastore_active': true,
        };

        final model = CkanResourceModel.fromJson(json);

        expect(model.id, 'res-abc');
        expect(model.name, 'data-kemiskinan.xlsx');
        expect(model.format, 'XLSX');
        expect(model.url, 'https://data.go.id/files/data-kemiskinan.xlsx');
        expect(model.size, 4096);
        expect(model.datastoreActive, isTrue);
      });

      test('format dikonversi ke uppercase', () {
        final json = {
          'id': 'r-1',
          'name': 'file',
          'format': 'json',
          'url': 'http://x.com/f',
        };

        final model = CkanResourceModel.fromJson(json);

        expect(model.format, 'JSON');
      });

      test('format kosong tetap string kosong', () {
        final json = {
          'id': 'r-2',
          'name': 'file',
          'url': 'http://x.com/f',
        };

        final model = CkanResourceModel.fromJson(json);

        expect(model.format, '');
      });

      test('size null dihandle dengan benar', () {
        final json = {
          'id': 'r-3',
          'name': 'file',
          'format': 'csv',
          'url': 'http://x.com/f',
          'size': null,
        };

        final model = CkanResourceModel.fromJson(json);

        expect(model.size, isNull);
      });

      test('datastore_active default false jika tidak ada', () {
        final json = {
          'id': 'r-4',
          'name': 'file',
          'format': 'csv',
          'url': 'http://x.com/f',
        };

        final model = CkanResourceModel.fromJson(json);

        expect(model.datastoreActive, isFalse);
      });
    });

    group('toJson', () {
      test('roundtrip serialization mempertahankan data', () {
        const original = CkanResourceModel(
          id: 'res-rt',
          name: 'roundtrip.csv',
          format: 'CSV',
          url: 'https://example.com/roundtrip.csv',
          size: 8192,
          datastoreActive: true,
        );

        final json = original.toJson();

        expect(json['id'], 'res-rt');
        expect(json['name'], 'roundtrip.csv');
        expect(json['format'], 'CSV');
        expect(json['url'], 'https://example.com/roundtrip.csv');
        expect(json['size'], 8192);
        expect(json['datastore_active'], isTrue);
      });

      test('toJson tidak menyertakan size jika null', () {
        const model = CkanResourceModel(
          id: 'no-size',
          name: 'file',
          format: 'PDF',
          url: 'http://x.com/f',
        );

        final json = model.toJson();

        expect(json.containsKey('size'), isFalse);
      });
    });

    group('format detection', () {
      test('mendeteksi format CSV', () {
        final model = CkanResourceModel.fromJson({
          'id': 'f1',
          'name': 'data',
          'format': 'csv',
          'url': 'http://x.com/f',
        });
        expect(model.format, 'CSV');
      });

      test('mendeteksi format JSON', () {
        final model = CkanResourceModel.fromJson({
          'id': 'f2',
          'name': 'data',
          'format': 'JSON',
          'url': 'http://x.com/f',
        });
        expect(model.format, 'JSON');
      });

      test('mendeteksi format mixed case XLS', () {
        final model = CkanResourceModel.fromJson({
          'id': 'f3',
          'name': 'data',
          'format': 'Xls',
          'url': 'http://x.com/f',
        });
        expect(model.format, 'XLS');
      });
    });
  });

  group('StrategicIndicatorModel', () {
    group('fromJson', () {
      test('parsing data lengkap menghasilkan model yang benar', () {
        final json = {
          'title': 'Tingkat Kemiskinan',
          'value': 9.54,
          'unit': 'persen',
          'period': 'Maret 2024',
          'domain': 'Kemiskinan',
          'source': 'BPS',
        };

        final model = StrategicIndicatorModel.fromJson(json);

        expect(model.title, 'Tingkat Kemiskinan');
        expect(model.value, 9.54);
        expect(model.unit, 'persen');
        expect(model.period, 'Maret 2024');
        expect(model.domain, 'Kemiskinan');
        expect(model.source, 'BPS');
      });

      test('parsing dengan semua field null menghasilkan default', () {
        final json = <String, dynamic>{};

        final model = StrategicIndicatorModel.fromJson(json);

        expect(model.title, '');
        expect(model.value, 0);
        expect(model.unit, '');
        expect(model.period, '');
        expect(model.domain, '');
        expect(model.source, '');
      });

      test('value integer dikonversi ke double', () {
        final json = {
          'title': 'Jumlah Penduduk',
          'value': 275000000,
          'unit': 'jiwa',
          'period': '2024',
          'domain': 'Kependudukan',
          'source': 'BPS',
        };

        final model = StrategicIndicatorModel.fromJson(json);

        expect(model.value, 275000000.0);
        expect(model.value, isA<double>());
      });

      test('value null menjadi 0', () {
        final json = {
          'title': 'Test',
          'value': null,
          'unit': '',
          'period': '',
          'domain': '',
          'source': '',
        };

        final model = StrategicIndicatorModel.fromJson(json);

        expect(model.value, 0.0);
      });
    });

    group('toJson', () {
      test('roundtrip serialization mempertahankan data', () {
        const original = StrategicIndicatorModel(
          title: 'Inflasi',
          value: 3.05,
          unit: 'persen',
          period: 'April 2024',
          domain: 'Harga',
          source: 'BPS',
        );

        final json = original.toJson();
        final restored = StrategicIndicatorModel.fromJson(json);

        expect(restored.title, original.title);
        expect(restored.value, original.value);
        expect(restored.unit, original.unit);
        expect(restored.period, original.period);
        expect(restored.domain, original.domain);
        expect(restored.source, original.source);
      });
    });

    group('equality', () {
      test('model dengan title, period, domain sama dianggap equal', () {
        const a = StrategicIndicatorModel(
          title: 'Inflasi',
          value: 3.0,
          unit: 'persen',
          period: '2024',
          domain: 'Harga',
          source: 'BPS',
        );
        const b = StrategicIndicatorModel(
          title: 'Inflasi',
          value: 5.0,
          unit: 'percent',
          period: '2024',
          domain: 'Harga',
          source: 'BI',
        );

        expect(a, equals(b));
      });

      test('model dengan title berbeda tidak equal', () {
        const a = StrategicIndicatorModel(
          title: 'Inflasi',
          value: 3.0,
          unit: 'persen',
          period: '2024',
          domain: 'Harga',
          source: 'BPS',
        );
        const b = StrategicIndicatorModel(
          title: 'Deflasi',
          value: 3.0,
          unit: 'persen',
          period: '2024',
          domain: 'Harga',
          source: 'BPS',
        );

        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copyWith mengubah field yang ditentukan saja', () {
        const original = StrategicIndicatorModel(
          title: 'Original',
          value: 1.0,
          unit: 'unit',
          period: 'Jan',
          domain: 'D',
          source: 'S',
        );

        final copied = original.copyWith(value: 99.9, unit: 'baru');

        expect(copied.title, 'Original');
        expect(copied.value, 99.9);
        expect(copied.unit, 'baru');
        expect(copied.period, 'Jan');
      });
    });
  });
}
