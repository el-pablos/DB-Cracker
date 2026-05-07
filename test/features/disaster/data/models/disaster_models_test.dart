import 'package:flutter_test/flutter_test.dart';
import 'package:db_cracker_tamaengs/features/disaster/data/models/disaster_models.dart';

void main() {
  group('DisasterRiskModel', () {
    group('fromJson', () {
      test('parsing data lengkap menghasilkan model yang benar', () {
        final json = {
          'lat': -6.2088,
          'lon': 106.8456,
          'kabupaten': 'Kota Jakarta Selatan',
          'provinsi': 'DKI Jakarta',
          'risks': {
            'gempa_bumi': {'score': 28, 'risk_class': 'tinggi'},
            'banjir': {'score': 20, 'risk_class': 'sedang'},
            'longsor': {'score': 8, 'risk_class': 'rendah'},
          },
        };

        final model = DisasterRiskModel.fromJson(json);

        expect(model.lat, -6.2088);
        expect(model.lon, 106.8456);
        expect(model.kabupaten, 'Kota Jakarta Selatan');
        expect(model.provinsi, 'DKI Jakarta');
        expect(model.risks, hasLength(3));
        expect(model.risks['gempa_bumi']!.score, 28);
        expect(model.risks['banjir']!.riskClass, 'sedang');
      });

      test('parsing dengan field alternatif latitude/longitude', () {
        final json = {
          'latitude': -7.7956,
          'longitude': 110.3695,
          'kab_kota': 'Kota Yogyakarta',
          'provinsi': 'DI Yogyakarta',
          'risiko': {
            'gempa_bumi': {'skor': 30, 'kelas_risiko': 'tinggi'},
          },
        };

        final model = DisasterRiskModel.fromJson(json);

        expect(model.lat, -7.7956);
        expect(model.lon, 110.3695);
        expect(model.kabupaten, 'Kota Yogyakarta');
        expect(model.risks['gempa_bumi']!.score, 30);
        expect(model.risks['gempa_bumi']!.riskClass, 'tinggi');
      });

      test('parsing dengan risks map kosong', () {
        final json = {
          'lat': -6.0,
          'lon': 106.0,
          'kabupaten': 'Test',
          'provinsi': 'Test',
          'risks': <String, dynamic>{},
        };

        final model = DisasterRiskModel.fromJson(json);

        expect(model.risks, isEmpty);
      });

      test('parsing tanpa field risks menghasilkan map kosong', () {
        final json = {
          'lat': -6.0,
          'lon': 106.0,
          'kabupaten': 'Test',
          'provinsi': 'Test',
        };

        final model = DisasterRiskModel.fromJson(json);

        expect(model.risks, isEmpty);
      });

      test('parsing dengan field null menghasilkan default', () {
        final json = <String, dynamic>{};

        final model = DisasterRiskModel.fromJson(json);

        expect(model.lat, 0.0);
        expect(model.lon, 0.0);
        expect(model.kabupaten, '');
        expect(model.provinsi, '');
        expect(model.risks, isEmpty);
      });
    });

    group('dominantRisk', () {
      test('mengembalikan hazard dengan score tertinggi', () {
        final model = DisasterRiskModel(
          lat: -6.0,
          lon: 106.0,
          kabupaten: 'Test',
          provinsi: 'Test',
          risks: {
            'banjir': const RiskDetailModel(score: 15, riskClass: 'sedang'),
            'gempa_bumi': const RiskDetailModel(score: 28, riskClass: 'tinggi'),
            'longsor': const RiskDetailModel(score: 5, riskClass: 'rendah'),
          },
        );

        final dominant = model.dominantRisk;

        expect(dominant, isNotNull);
        expect(dominant!.key, 'gempa_bumi');
        expect(dominant.value.score, 28);
      });

      test('mengembalikan null jika risks kosong', () {
        const model = DisasterRiskModel(
          lat: -6.0,
          lon: 106.0,
          kabupaten: 'Test',
          provinsi: 'Test',
          risks: {},
        );

        expect(model.dominantRisk, isNull);
      });

      test('mengembalikan entry pertama jika semua score sama', () {
        final model = DisasterRiskModel(
          lat: -6.0,
          lon: 106.0,
          kabupaten: 'Test',
          provinsi: 'Test',
          risks: {
            'banjir': const RiskDetailModel(score: 20, riskClass: 'sedang'),
            'longsor': const RiskDetailModel(score: 20, riskClass: 'sedang'),
          },
        );

        final dominant = model.dominantRisk;

        expect(dominant, isNotNull);
        expect(dominant!.value.score, 20);
      });
    });

    group('activeHazardCount', () {
      test('menghitung hazard dengan score > 0', () {
        final model = DisasterRiskModel(
          lat: -6.0,
          lon: 106.0,
          kabupaten: 'Test',
          provinsi: 'Test',
          risks: {
            'banjir': const RiskDetailModel(score: 15, riskClass: 'sedang'),
            'gempa_bumi': const RiskDetailModel(score: 0, riskClass: 'rendah'),
            'longsor': const RiskDetailModel(score: 5, riskClass: 'rendah'),
          },
        );

        expect(model.activeHazardCount, 2);
      });

      test('mengembalikan 0 jika semua score nol', () {
        final model = DisasterRiskModel(
          lat: -6.0,
          lon: 106.0,
          kabupaten: 'Test',
          provinsi: 'Test',
          risks: {
            'banjir': const RiskDetailModel(score: 0, riskClass: 'rendah'),
            'gempa_bumi': const RiskDetailModel(score: 0, riskClass: 'rendah'),
          },
        );

        expect(model.activeHazardCount, 0);
      });
    });

    group('toJson', () {
      test('roundtrip serialization mempertahankan data', () {
        final original = DisasterRiskModel(
          lat: -6.2088,
          lon: 106.8456,
          kabupaten: 'Jakarta Selatan',
          provinsi: 'DKI Jakarta',
          risks: {
            'banjir': const RiskDetailModel(score: 20, riskClass: 'sedang'),
          },
        );

        final json = original.toJson();

        expect(json['lat'], -6.2088);
        expect(json['lon'], 106.8456);
        expect(json['kabupaten'], 'Jakarta Selatan');
        expect(json['provinsi'], 'DKI Jakarta');
        expect((json['risks'] as Map)['banjir']['score'], 20);
      });
    });

    group('all hazard types', () {
      test('model mendukung semua tipe hazard BNPB', () {
        final hazardTypes = [
          'gempa_bumi',
          'tsunami',
          'banjir',
          'longsor',
          'letusan_gunung_api',
          'kekeringan',
          'kebakaran_hutan',
          'angin_puting_beliung',
          'gelombang_ekstrim',
        ];

        final risks = <String, RiskDetailModel>{};
        for (final type in hazardTypes) {
          risks[type] = const RiskDetailModel(score: 10, riskClass: 'sedang');
        }

        final model = DisasterRiskModel(
          lat: -6.0,
          lon: 106.0,
          kabupaten: 'Test',
          provinsi: 'Test',
          risks: risks,
        );

        expect(model.risks.length, 9);
        expect(model.activeHazardCount, 9);
        for (final type in hazardTypes) {
          expect(model.risks.containsKey(type), isTrue);
        }
      });
    });

    group('equality', () {
      test('model dengan lat/lon sama dianggap equal', () {
        const a = DisasterRiskModel(
          lat: -6.2088,
          lon: 106.8456,
          kabupaten: 'A',
          provinsi: 'A',
          risks: {},
        );
        const b = DisasterRiskModel(
          lat: -6.2088,
          lon: 106.8456,
          kabupaten: 'B',
          provinsi: 'B',
          risks: {},
        );

        expect(a, equals(b));
      });
    });
  });

  group('RiskDetailModel', () {
    group('fromJson', () {
      test('parsing data lengkap menghasilkan model yang benar', () {
        final json = {
          'score': 24,
          'risk_class': 'tinggi',
        };

        final model = RiskDetailModel.fromJson(json);

        expect(model.score, 24);
        expect(model.riskClass, 'tinggi');
      });

      test('parsing dengan field alternatif bahasa Indonesia', () {
        final json = {
          'skor': 15,
          'kelas_risiko': 'sedang',
        };

        final model = RiskDetailModel.fromJson(json);

        expect(model.score, 15);
        expect(model.riskClass, 'sedang');
      });

      test('parsing dengan field class sebagai alternatif', () {
        final json = {
          'score': 8,
          'class': 'rendah',
        };

        final model = RiskDetailModel.fromJson(json);

        expect(model.riskClass, 'rendah');
      });

      test('parsing tanpa field menghasilkan default', () {
        final json = <String, dynamic>{};

        final model = RiskDetailModel.fromJson(json);

        expect(model.score, 0);
        expect(model.riskClass, 'rendah');
      });
    });

    group('score/class mapping', () {
      test('score >= 24 dianggap high risk', () {
        const model = RiskDetailModel(score: 24, riskClass: 'tinggi');

        expect(model.isHighRisk, isTrue);
        expect(model.isMediumRisk, isFalse);
      });

      test('score 30 dianggap high risk', () {
        const model = RiskDetailModel(score: 30, riskClass: 'tinggi');

        expect(model.isHighRisk, isTrue);
      });

      test('score 12-23 dianggap medium risk', () {
        const model = RiskDetailModel(score: 15, riskClass: 'sedang');

        expect(model.isHighRisk, isFalse);
        expect(model.isMediumRisk, isTrue);
      });

      test('score tepat 12 dianggap medium risk', () {
        const model = RiskDetailModel(score: 12, riskClass: 'sedang');

        expect(model.isMediumRisk, isTrue);
      });

      test('score < 12 bukan medium dan bukan high', () {
        const model = RiskDetailModel(score: 8, riskClass: 'rendah');

        expect(model.isHighRisk, isFalse);
        expect(model.isMediumRisk, isFalse);
      });

      test('score 0 bukan medium dan bukan high', () {
        const model = RiskDetailModel(score: 0, riskClass: 'rendah');

        expect(model.isHighRisk, isFalse);
        expect(model.isMediumRisk, isFalse);
      });
    });

    group('toJson', () {
      test('roundtrip serialization mempertahankan data', () {
        const original = RiskDetailModel(score: 20, riskClass: 'sedang');

        final json = original.toJson();
        final restored = RiskDetailModel.fromJson(json);

        expect(restored.score, original.score);
        expect(restored.riskClass, original.riskClass);
      });
    });

    group('equality', () {
      test('model dengan score dan riskClass sama dianggap equal', () {
        const a = RiskDetailModel(score: 20, riskClass: 'sedang');
        const b = RiskDetailModel(score: 20, riskClass: 'sedang');

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('model dengan score berbeda tidak equal', () {
        const a = RiskDetailModel(score: 20, riskClass: 'sedang');
        const b = RiskDetailModel(score: 25, riskClass: 'sedang');

        expect(a, isNot(equals(b)));
      });
    });
  });

  group('IrbiModel', () {
    group('fromJson', () {
      test('parsing data lengkap menghasilkan model yang benar', () {
        final json = {
          'kode_wilayah': '3201',
          'nama_wilayah': 'Kabupaten Bogor',
          'provinsi': 'Jawa Barat',
          'skor_total': 185.5,
          'dominant_hazard': 'banjir',
          'hazard_scores': {
            'gempa_bumi': 25.0,
            'banjir': 35.5,
            'longsor': 28.0,
            'kekeringan': 15.0,
          },
        };

        final model = IrbiModel.fromJson(json);

        expect(model.kodeWilayah, '3201');
        expect(model.namaWilayah, 'Kabupaten Bogor');
        expect(model.provinsi, 'Jawa Barat');
        expect(model.skorTotal, 185.5);
        expect(model.dominantHazard, 'banjir');
        expect(model.hazardScores, hasLength(4));
        expect(model.hazardScores['banjir'], 35.5);
      });

      test('parsing dengan field alternatif bahasa Indonesia', () {
        final json = {
          'kode': '3301',
          'nama': 'Kabupaten Cilacap',
          'provinsi': 'Jawa Tengah',
          'total_score': 150.0,
          'ancaman_dominan': 'tsunami',
          'skor_ancaman': {
            'tsunami': 30.0,
            'gempa_bumi': 25.0,
          },
        };

        final model = IrbiModel.fromJson(json);

        expect(model.kodeWilayah, '3301');
        expect(model.namaWilayah, 'Kabupaten Cilacap');
        expect(model.skorTotal, 150.0);
        expect(model.dominantHazard, 'tsunami');
        expect(model.hazardScores['tsunami'], 30.0);
      });

      test('parsing tanpa hazard_scores menghasilkan map kosong', () {
        final json = {
          'kode_wilayah': '9999',
          'nama_wilayah': 'Test',
          'provinsi': 'Test',
          'skor_total': 0,
          'dominant_hazard': '',
        };

        final model = IrbiModel.fromJson(json);

        expect(model.hazardScores, isEmpty);
      });

      test('parsing dengan semua field null menghasilkan default', () {
        final json = <String, dynamic>{};

        final model = IrbiModel.fromJson(json);

        expect(model.kodeWilayah, '');
        expect(model.namaWilayah, '');
        expect(model.provinsi, '');
        expect(model.skorTotal, 0.0);
        expect(model.dominantHazard, '');
        expect(model.hazardScores, isEmpty);
      });
    });

    group('dominant hazard detection', () {
      test('dominant hazard sesuai dengan score tertinggi di hazardScores', () {
        final model = IrbiModel(
          kodeWilayah: '3201',
          namaWilayah: 'Test',
          provinsi: 'Test',
          skorTotal: 100.0,
          dominantHazard: 'banjir',
          hazardScores: {
            'gempa_bumi': 20.0,
            'banjir': 40.0,
            'longsor': 15.0,
          },
        );

        expect(model.dominantHazard, 'banjir');
        final maxScore = model.hazardScores.values.reduce(
          (a, b) => a > b ? a : b,
        );
        expect(model.hazardScores[model.dominantHazard], maxScore);
      });
    });

    group('riskCategory', () {
      test('skor >= 168 dikategorikan Tinggi', () {
        const model = IrbiModel(
          kodeWilayah: '1',
          namaWilayah: 'A',
          provinsi: 'A',
          skorTotal: 200.0,
          dominantHazard: 'banjir',
          hazardScores: {},
        );

        expect(model.riskCategory, 'Tinggi');
      });

      test('skor tepat 168 dikategorikan Tinggi', () {
        const model = IrbiModel(
          kodeWilayah: '2',
          namaWilayah: 'B',
          provinsi: 'B',
          skorTotal: 168.0,
          dominantHazard: 'gempa',
          hazardScores: {},
        );

        expect(model.riskCategory, 'Tinggi');
      });

      test('skor 84-167 dikategorikan Sedang', () {
        const model = IrbiModel(
          kodeWilayah: '3',
          namaWilayah: 'C',
          provinsi: 'C',
          skorTotal: 120.0,
          dominantHazard: 'longsor',
          hazardScores: {},
        );

        expect(model.riskCategory, 'Sedang');
      });

      test('skor tepat 84 dikategorikan Sedang', () {
        const model = IrbiModel(
          kodeWilayah: '4',
          namaWilayah: 'D',
          provinsi: 'D',
          skorTotal: 84.0,
          dominantHazard: 'banjir',
          hazardScores: {},
        );

        expect(model.riskCategory, 'Sedang');
      });

      test('skor < 84 dikategorikan Rendah', () {
        const model = IrbiModel(
          kodeWilayah: '5',
          namaWilayah: 'E',
          provinsi: 'E',
          skorTotal: 50.0,
          dominantHazard: 'kekeringan',
          hazardScores: {},
        );

        expect(model.riskCategory, 'Rendah');
      });

      test('skor 0 dikategorikan Rendah', () {
        const model = IrbiModel(
          kodeWilayah: '6',
          namaWilayah: 'F',
          provinsi: 'F',
          skorTotal: 0.0,
          dominantHazard: '',
          hazardScores: {},
        );

        expect(model.riskCategory, 'Rendah');
      });
    });

    group('toJson', () {
      test('roundtrip serialization mempertahankan data', () {
        const original = IrbiModel(
          kodeWilayah: '3201',
          namaWilayah: 'Kabupaten Bogor',
          provinsi: 'Jawa Barat',
          skorTotal: 185.5,
          dominantHazard: 'banjir',
          hazardScores: {'banjir': 35.5, 'gempa_bumi': 25.0},
        );

        final json = original.toJson();

        expect(json['kode_wilayah'], '3201');
        expect(json['nama_wilayah'], 'Kabupaten Bogor');
        expect(json['provinsi'], 'Jawa Barat');
        expect(json['skor_total'], 185.5);
        expect(json['dominant_hazard'], 'banjir');
        expect((json['hazard_scores'] as Map)['banjir'], 35.5);
      });
    });

    group('equality', () {
      test('model dengan kodeWilayah sama dianggap equal', () {
        const a = IrbiModel(
          kodeWilayah: '3201',
          namaWilayah: 'A',
          provinsi: 'A',
          skorTotal: 100,
          dominantHazard: 'a',
          hazardScores: {},
        );
        const b = IrbiModel(
          kodeWilayah: '3201',
          namaWilayah: 'B',
          provinsi: 'B',
          skorTotal: 200,
          dominantHazard: 'b',
          hazardScores: {},
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('model dengan kodeWilayah berbeda tidak equal', () {
        const a = IrbiModel(
          kodeWilayah: '3201',
          namaWilayah: 'A',
          provinsi: 'A',
          skorTotal: 100,
          dominantHazard: 'a',
          hazardScores: {},
        );
        const b = IrbiModel(
          kodeWilayah: '3301',
          namaWilayah: 'A',
          provinsi: 'A',
          skorTotal: 100,
          dominantHazard: 'a',
          hazardScores: {},
        );

        expect(a, isNot(equals(b)));
      });
    });
  });
}
