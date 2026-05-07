/// Data models for BNPB InaRISK disaster risk assessment.

class DisasterRiskModel {
  final double lat;
  final double lon;
  final Map<String, RiskDetailModel> risks;
  final String kabupaten;
  final String provinsi;

  const DisasterRiskModel({
    required this.lat,
    required this.lon,
    required this.risks,
    required this.kabupaten,
    required this.provinsi,
  });

  factory DisasterRiskModel.fromJson(Map<String, dynamic> json) {
    final risksRaw = json['risks'] ?? json['risiko'] ?? {};
    final Map<String, RiskDetailModel> parsedRisks = {};

    if (risksRaw is Map<String, dynamic>) {
      for (final entry in risksRaw.entries) {
        parsedRisks[entry.key] = RiskDetailModel.fromJson(
          entry.value as Map<String, dynamic>,
        );
      }
    }

    return DisasterRiskModel(
      lat: (json['lat'] ?? json['latitude'] ?? 0 as num).toDouble(),
      lon: (json['lon'] ?? json['longitude'] ?? 0 as num).toDouble(),
      risks: parsedRisks,
      kabupaten: (json['kabupaten'] ?? json['kab_kota'] ?? '') as String,
      provinsi: (json['provinsi'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lon': lon,
      'risks': risks.map((k, v) => MapEntry(k, v.toJson())),
      'kabupaten': kabupaten,
      'provinsi': provinsi,
    };
  }

  DisasterRiskModel copyWith({
    double? lat,
    double? lon,
    Map<String, RiskDetailModel>? risks,
    String? kabupaten,
    String? provinsi,
  }) {
    return DisasterRiskModel(
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      risks: risks ?? this.risks,
      kabupaten: kabupaten ?? this.kabupaten,
      provinsi: provinsi ?? this.provinsi,
    );
  }

  /// Get the highest risk hazard at this location.
  MapEntry<String, RiskDetailModel>? get dominantRisk {
    if (risks.isEmpty) return null;
    return risks.entries.reduce(
      (a, b) => a.value.score >= b.value.score ? a : b,
    );
  }

  /// Total number of hazards with score > 0.
  int get activeHazardCount =>
      risks.values.where((r) => r.score > 0).length;

  @override
  String toString() =>
      'DisasterRiskModel($kabupaten, $provinsi: ${risks.length} hazards)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisasterRiskModel &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lon == other.lon;

  @override
  int get hashCode => lat.hashCode ^ lon.hashCode;
}

class RiskDetailModel {
  final int score;
  final String riskClass;

  const RiskDetailModel({
    required this.score,
    required this.riskClass,
  });

  factory RiskDetailModel.fromJson(Map<String, dynamic> json) {
    return RiskDetailModel(
      score: (json['score'] ?? json['skor'] ?? 0) as int,
      riskClass: (json['risk_class'] ?? json['kelas_risiko'] ?? json['class'] ?? 'rendah') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'risk_class': riskClass,
    };
  }

  RiskDetailModel copyWith({
    int? score,
    String? riskClass,
  }) {
    return RiskDetailModel(
      score: score ?? this.score,
      riskClass: riskClass ?? this.riskClass,
    );
  }

  /// Whether this hazard is high risk (score >= 24 based on BNPB scale).
  bool get isHighRisk => score >= 24;

  /// Whether this hazard is medium risk.
  bool get isMediumRisk => score >= 12 && score < 24;

  @override
  String toString() => 'RiskDetailModel(score: $score, class: $riskClass)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RiskDetailModel &&
          runtimeType == other.runtimeType &&
          score == other.score &&
          riskClass == other.riskClass;

  @override
  int get hashCode => score.hashCode ^ riskClass.hashCode;
}

class IrbiModel {
  final String kodeWilayah;
  final String namaWilayah;
  final String provinsi;
  final double skorTotal;
  final String dominantHazard;
  final Map<String, double> hazardScores;

  const IrbiModel({
    required this.kodeWilayah,
    required this.namaWilayah,
    required this.provinsi,
    required this.skorTotal,
    required this.dominantHazard,
    required this.hazardScores,
  });

  factory IrbiModel.fromJson(Map<String, dynamic> json) {
    final scoresRaw = json['hazard_scores'] ?? json['skor_ancaman'] ?? {};
    final Map<String, double> parsedScores = {};

    if (scoresRaw is Map<String, dynamic>) {
      for (final entry in scoresRaw.entries) {
        parsedScores[entry.key] = (entry.value as num).toDouble();
      }
    }

    return IrbiModel(
      kodeWilayah: (json['kode_wilayah'] ?? json['kode'] ?? '') as String,
      namaWilayah: (json['nama_wilayah'] ?? json['nama'] ?? '') as String,
      provinsi: (json['provinsi'] ?? '') as String,
      skorTotal: (json['skor_total'] ?? json['total_score'] ?? 0 as num).toDouble(),
      dominantHazard: (json['dominant_hazard'] ?? json['ancaman_dominan'] ?? '') as String,
      hazardScores: parsedScores,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode_wilayah': kodeWilayah,
      'nama_wilayah': namaWilayah,
      'provinsi': provinsi,
      'skor_total': skorTotal,
      'dominant_hazard': dominantHazard,
      'hazard_scores': hazardScores,
    };
  }

  IrbiModel copyWith({
    String? kodeWilayah,
    String? namaWilayah,
    String? provinsi,
    double? skorTotal,
    String? dominantHazard,
    Map<String, double>? hazardScores,
  }) {
    return IrbiModel(
      kodeWilayah: kodeWilayah ?? this.kodeWilayah,
      namaWilayah: namaWilayah ?? this.namaWilayah,
      provinsi: provinsi ?? this.provinsi,
      skorTotal: skorTotal ?? this.skorTotal,
      dominantHazard: dominantHazard ?? this.dominantHazard,
      hazardScores: hazardScores ?? this.hazardScores,
    );
  }

  /// Risk category based on IRBI total score.
  String get riskCategory {
    if (skorTotal >= 168) return 'Tinggi';
    if (skorTotal >= 84) return 'Sedang';
    return 'Rendah';
  }

  @override
  String toString() =>
      'IrbiModel($namaWilayah, $provinsi: skor=$skorTotal, dominant=$dominantHazard)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IrbiModel &&
          runtimeType == other.runtimeType &&
          kodeWilayah == other.kodeWilayah;

  @override
  int get hashCode => kodeWilayah.hashCode;
}
