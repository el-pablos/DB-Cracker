import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/features/economy/data/models/economy_models.dart';

void main() {
  group('ExchangeRateModel', () {
    group('fromJson', () {
      test('parsing data lengkap menghasilkan model yang benar', () {
        final json = {
          'currency': 'USD',
          'date': '2024-03-15',
          'buy': 15750.0,
          'sell': 15850.0,
          'middle': 15800.0,
        };

        final model = ExchangeRateModel.fromJson(json);

        expect(model.currency, 'USD');
        expect(model.date, '2024-03-15');
        expect(model.buy, 15750.0);
        expect(model.sell, 15850.0);
        expect(model.middle, 15800.0);
      });

      test('parsing dengan field null menghasilkan default values', () {
        final json = <String, dynamic>{};

        final model = ExchangeRateModel.fromJson(json);

        expect(model.currency, '');
        expect(model.date, '');
        expect(model.buy, 0.0);
        expect(model.sell, 0.0);
        expect(model.middle, 0.0);
      });

      test('parsing value integer dikonversi ke double', () {
        final json = {
          'currency': 'EUR',
          'date': '2024-01-01',
          'buy': 17000,
          'sell': 17200,
          'middle': 17100,
        };

        final model = ExchangeRateModel.fromJson(json);

        expect(model.buy, 17000.0);
        expect(model.sell, 17200.0);
        expect(model.middle, 17100.0);
      });
    });

    group('fromBiResponse', () {
      test('parsing format BI dengan field bahasa Indonesia', () {
        final json = {
          'mata_uang': 'USD',
          'tanggal': '2024-03-15',
          'beli': 15750.0,
          'jual': 15850.0,
          'tengah': 15800.0,
        };

        final model = ExchangeRateModel.fromBiResponse(json);

        expect(model.currency, 'USD');
        expect(model.date, '2024-03-15');
        expect(model.buy, 15750.0);
        expect(model.sell, 15850.0);
        expect(model.middle, 15800.0);
      });

      test('middle dihitung otomatis jika tidak ada', () {
        final json = {
          'mata_uang': 'JPY',
          'tanggal': '2024-03-15',
          'beli': 100.0,
          'jual': 110.0,
        };

        final model = ExchangeRateModel.fromBiResponse(json);

        expect(model.middle, 105.0);
      });

      test('parsing format nested jual_beli', () {
        final json = {
          'mata_uang': 'SGD',
          'tanggal': '2024-03-15',
          'jual_beli': {'beli': 11500.0, 'jual': 11700.0},
          'tengah': 11600.0,
        };

        final model = ExchangeRateModel.fromBiResponse(json);

        expect(model.buy, 11500.0);
        expect(model.sell, 11700.0);
        expect(model.middle, 11600.0);
      });
    });

    group('spread calculation', () {
      test('spread dihitung dari selisih sell dan buy', () {
        const model = ExchangeRateModel(
          currency: 'USD',
          date: '2024-01-01',
          buy: 15700.0,
          sell: 15900.0,
          middle: 15800.0,
        );

        expect(model.spread, 200.0);
      });

      test('spread nol ketika buy sama dengan sell', () {
        const model = ExchangeRateModel(
          currency: 'USD',
          date: '2024-01-01',
          buy: 15800.0,
          sell: 15800.0,
          middle: 15800.0,
        );

        expect(model.spread, 0.0);
      });

      test('spread negatif jika buy lebih besar dari sell (anomali)', () {
        const model = ExchangeRateModel(
          currency: 'USD',
          date: '2024-01-01',
          buy: 16000.0,
          sell: 15800.0,
          middle: 15900.0,
        );

        expect(model.spread, -200.0);
      });
    });

    group('toJson', () {
      test('roundtrip serialization mempertahankan data', () {
        const original = ExchangeRateModel(
          currency: 'AUD',
          date: '2024-06-01',
          buy: 10500.0,
          sell: 10700.0,
          middle: 10600.0,
        );

        final json = original.toJson();
        final restored = ExchangeRateModel.fromJson(json);

        expect(restored.currency, original.currency);
        expect(restored.date, original.date);
        expect(restored.buy, original.buy);
        expect(restored.sell, original.sell);
        expect(restored.middle, original.middle);
      });
    });

    group('equality', () {
      test('model dengan currency dan date sama dianggap equal', () {
        const a = ExchangeRateModel(
          currency: 'USD',
          date: '2024-01-01',
          buy: 15000,
          sell: 15200,
          middle: 15100,
        );
        const b = ExchangeRateModel(
          currency: 'USD',
          date: '2024-01-01',
          buy: 16000,
          sell: 16200,
          middle: 16100,
        );

        expect(a, equals(b));
      });
    });
  });

  group('MinimumWageModel', () {
    group('fromJson', () {
      test('parsing data lengkap menghasilkan model yang benar', () {
        final json = {
          'provinsi': 'DKI Jakarta',
          'ump': 5067381,
          'tahun': 2024,
        };

        final model = MinimumWageModel.fromJson(json);

        expect(model.provinsi, 'DKI Jakarta');
        expect(model.ump, 5067381);
        expect(model.tahun, 2024);
      });

      test('parsing dengan field alternatif upah_minimum', () {
        final json = {
          'provinsi': 'Jawa Barat',
          'upah_minimum': 2057495,
          'tahun': 2024,
        };

        final model = MinimumWageModel.fromJson(json);

        expect(model.ump, 2057495);
      });

      test('parsing dengan field alternatif year', () {
        final json = {
          'provinsi': 'Bali',
          'ump': 2813000,
          'year': 2024,
        };

        final model = MinimumWageModel.fromJson(json);

        expect(model.tahun, 2024);
      });

      test('parsing dengan field null menghasilkan default', () {
        final json = <String, dynamic>{};

        final model = MinimumWageModel.fromJson(json);

        expect(model.provinsi, '');
        expect(model.ump, 0);
        expect(model.tahun, 0);
      });
    });

    group('formattedUmp', () {
      test('format UMP jutaan dengan separator titik', () {
        const model = MinimumWageModel(
          provinsi: 'DKI Jakarta',
          ump: 5067381,
          tahun: 2024,
        );

        expect(model.formattedUmp, 'Rp 5.067.381');
      });

      test('format UMP ratusan ribu', () {
        const model = MinimumWageModel(
          provinsi: 'Test',
          ump: 500000,
          tahun: 2024,
        );

        expect(model.formattedUmp, 'Rp 500.000');
      });

      test('format UMP nol', () {
        const model = MinimumWageModel(
          provinsi: 'Test',
          ump: 0,
          tahun: 2024,
        );

        expect(model.formattedUmp, 'Rp 0');
      });

      test('format UMP puluhan juta', () {
        const model = MinimumWageModel(
          provinsi: 'Test',
          ump: 15000000,
          tahun: 2024,
        );

        expect(model.formattedUmp, 'Rp 15.000.000');
      });
    });

    group('toJson', () {
      test('roundtrip serialization mempertahankan data', () {
        const original = MinimumWageModel(
          provinsi: 'Jawa Tengah',
          ump: 2032000,
          tahun: 2024,
        );

        final json = original.toJson();
        final restored = MinimumWageModel.fromJson(json);

        expect(restored.provinsi, original.provinsi);
        expect(restored.ump, original.ump);
        expect(restored.tahun, original.tahun);
      });
    });

    group('equality', () {
      test('model dengan provinsi dan tahun sama dianggap equal', () {
        const a = MinimumWageModel(
          provinsi: 'DKI Jakarta',
          ump: 5000000,
          tahun: 2024,
        );
        const b = MinimumWageModel(
          provinsi: 'DKI Jakarta',
          ump: 6000000,
          tahun: 2024,
        );

        expect(a, equals(b));
      });

      test('model dengan tahun berbeda tidak equal', () {
        const a = MinimumWageModel(
          provinsi: 'DKI Jakarta',
          ump: 5000000,
          tahun: 2024,
        );
        const b = MinimumWageModel(
          provinsi: 'DKI Jakarta',
          ump: 5000000,
          tahun: 2023,
        );

        expect(a, isNot(equals(b)));
      });
    });
  });

  group('BiRateModel', () {
    group('fromJson', () {
      test('parsing data lengkap menghasilkan model yang benar', () {
        final json = {
          'rate': 6.25,
          'effective_date': '2024-03-20',
          'description': 'BI-7 Day Reverse Repo Rate',
        };

        final model = BiRateModel.fromJson(json);

        expect(model.rate, 6.25);
        expect(model.effectiveDate, '2024-03-20');
        expect(model.description, 'BI-7 Day Reverse Repo Rate');
      });

      test('parsing dengan field alternatif bahasa Indonesia', () {
        final json = {
          'suku_bunga': 6.0,
          'tanggal_efektif': '2024-01-15',
          'keterangan': 'Suku bunga acuan',
        };

        final model = BiRateModel.fromJson(json);

        expect(model.rate, 6.0);
        expect(model.effectiveDate, '2024-01-15');
        expect(model.description, 'Suku bunga acuan');
      });

      test('parsing dengan field alternatif bi_rate', () {
        final json = {
          'bi_rate': 5.75,
          'effective_date': '2023-12-01',
        };

        final model = BiRateModel.fromJson(json);

        expect(model.rate, 5.75);
        expect(model.description, '');
      });

      test('parsing dengan semua field null menghasilkan default', () {
        final json = <String, dynamic>{};

        final model = BiRateModel.fromJson(json);

        expect(model.rate, 0.0);
        expect(model.effectiveDate, '');
        expect(model.description, '');
      });
    });

    group('formattedRate', () {
      test('format rate sebagai persentase dengan 2 desimal', () {
        const model = BiRateModel(
          rate: 6.25,
          effectiveDate: '2024-03-20',
        );

        expect(model.formattedRate, '6.25%');
      });

      test('format rate bulat tetap 2 desimal', () {
        const model = BiRateModel(
          rate: 6.0,
          effectiveDate: '2024-01-01',
        );

        expect(model.formattedRate, '6.00%');
      });

      test('format rate nol', () {
        const model = BiRateModel(
          rate: 0.0,
          effectiveDate: '2024-01-01',
        );

        expect(model.formattedRate, '0.00%');
      });
    });

    group('toJson', () {
      test('roundtrip serialization mempertahankan data', () {
        const original = BiRateModel(
          rate: 6.25,
          effectiveDate: '2024-03-20',
          description: 'BI Rate',
        );

        final json = original.toJson();
        final restored = BiRateModel.fromJson(json);

        expect(restored.rate, original.rate);
        expect(restored.effectiveDate, original.effectiveDate);
        expect(restored.description, original.description);
      });
    });

    group('equality', () {
      test('model dengan rate dan effectiveDate sama dianggap equal', () {
        const a = BiRateModel(
          rate: 6.25,
          effectiveDate: '2024-03-20',
          description: 'A',
        );
        const b = BiRateModel(
          rate: 6.25,
          effectiveDate: '2024-03-20',
          description: 'B',
        );

        expect(a, equals(b));
      });

      test('model dengan rate berbeda tidak equal', () {
        const a = BiRateModel(
          rate: 6.25,
          effectiveDate: '2024-03-20',
        );
        const b = BiRateModel(
          rate: 6.00,
          effectiveDate: '2024-03-20',
        );

        expect(a, isNot(equals(b)));
      });
    });

    group('copyWith', () {
      test('copyWith mengubah field yang ditentukan saja', () {
        const original = BiRateModel(
          rate: 6.25,
          effectiveDate: '2024-03-20',
          description: 'Original',
        );

        final copied = original.copyWith(rate: 6.50);

        expect(copied.rate, 6.50);
        expect(copied.effectiveDate, '2024-03-20');
        expect(copied.description, 'Original');
      });
    });
  });
}
