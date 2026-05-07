/// Data models for Bank Indonesia exchange rates, BI Rate, and minimum wages.

class ExchangeRateModel {
  final String currency;
  final String date;
  final double buy;
  final double sell;
  final double middle;

  const ExchangeRateModel({
    required this.currency,
    required this.date,
    required this.buy,
    required this.sell,
    required this.middle,
  });

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      currency: json['currency'] as String? ?? '',
      date: json['date'] as String? ?? '',
      buy: (json['buy'] as num?)?.toDouble() ?? 0,
      sell: (json['sell'] as num?)?.toDouble() ?? 0,
      middle: (json['middle'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Parse from BI API response format (may differ from standard).
  factory ExchangeRateModel.fromBiResponse(Map<String, dynamic> json) {
    final buy = (json['beli'] ?? json['buy'] ?? json['jual_beli']?['beli']) as num?;
    final sell = (json['jual'] ?? json['sell'] ?? json['jual_beli']?['jual']) as num?;
    final middle = (json['tengah'] ?? json['middle']) as num?;

    final buyVal = buy?.toDouble() ?? 0;
    final sellVal = sell?.toDouble() ?? 0;
    final middleVal = middle?.toDouble() ?? ((buyVal + sellVal) / 2);

    return ExchangeRateModel(
      currency: (json['mata_uang'] ?? json['currency'] ?? '') as String,
      date: (json['tanggal'] ?? json['date'] ?? '') as String,
      buy: buyVal,
      sell: sellVal,
      middle: middleVal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'date': date,
      'buy': buy,
      'sell': sell,
      'middle': middle,
    };
  }

  ExchangeRateModel copyWith({
    String? currency,
    String? date,
    double? buy,
    double? sell,
    double? middle,
  }) {
    return ExchangeRateModel(
      currency: currency ?? this.currency,
      date: date ?? this.date,
      buy: buy ?? this.buy,
      sell: sell ?? this.sell,
      middle: middle ?? this.middle,
    );
  }

  /// Spread between sell and buy rate.
  double get spread => sell - buy;

  @override
  String toString() =>
      'ExchangeRateModel($currency $date: buy=$buy, sell=$sell, mid=$middle)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExchangeRateModel &&
          runtimeType == other.runtimeType &&
          currency == other.currency &&
          date == other.date;

  @override
  int get hashCode => currency.hashCode ^ date.hashCode;
}

class MinimumWageModel {
  final String provinsi;
  final int ump;
  final int tahun;

  const MinimumWageModel({
    required this.provinsi,
    required this.ump,
    required this.tahun,
  });

  factory MinimumWageModel.fromJson(Map<String, dynamic> json) {
    return MinimumWageModel(
      provinsi: json['provinsi'] as String? ?? '',
      ump: (json['ump'] ?? json['upah_minimum'] ?? 0) as int,
      tahun: (json['tahun'] ?? json['year'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provinsi': provinsi,
      'ump': ump,
      'tahun': tahun,
    };
  }

  MinimumWageModel copyWith({
    String? provinsi,
    int? ump,
    int? tahun,
  }) {
    return MinimumWageModel(
      provinsi: provinsi ?? this.provinsi,
      ump: ump ?? this.ump,
      tahun: tahun ?? this.tahun,
    );
  }

  /// Format UMP as Indonesian Rupiah string.
  String get formattedUmp {
    final str = ump.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp $buffer';
  }

  @override
  String toString() => 'MinimumWageModel($provinsi: $formattedUmp/$tahun)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MinimumWageModel &&
          runtimeType == other.runtimeType &&
          provinsi == other.provinsi &&
          tahun == other.tahun;

  @override
  int get hashCode => provinsi.hashCode ^ tahun.hashCode;
}

class BiRateModel {
  final double rate;
  final String effectiveDate;
  final String description;

  const BiRateModel({
    required this.rate,
    required this.effectiveDate,
    this.description = '',
  });

  factory BiRateModel.fromJson(Map<String, dynamic> json) {
    return BiRateModel(
      rate: (json['rate'] ?? json['bi_rate'] ?? json['suku_bunga'] ?? 0 as num)
          .toDouble(),
      effectiveDate:
          (json['effective_date'] ?? json['tanggal_efektif'] ?? '') as String,
      description: (json['description'] ?? json['keterangan'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'effective_date': effectiveDate,
      'description': description,
    };
  }

  BiRateModel copyWith({
    double? rate,
    String? effectiveDate,
    String? description,
  }) {
    return BiRateModel(
      rate: rate ?? this.rate,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      description: description ?? this.description,
    );
  }

  /// Format rate as percentage string.
  String get formattedRate => '${rate.toStringAsFixed(2)}%';

  @override
  String toString() => 'BiRateModel($formattedRate from $effectiveDate)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiRateModel &&
          runtimeType == other.runtimeType &&
          rate == other.rate &&
          effectiveDate == other.effectiveDate;

  @override
  int get hashCode => rate.hashCode ^ effectiveDate.hashCode;
}
