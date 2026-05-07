import 'region_model.dart';

class BootstrapModel {
  final BootstrapSummaryModel? summary;
  final List<RegionModel> regions;
  final Map<String, dynamic>? legend;
  final Map<String, dynamic>? geo;
  final Map<String, dynamic>? provinceView;

  const BootstrapModel({
    this.summary,
    this.regions = const [],
    this.legend,
    this.geo,
    this.provinceView,
  });

  factory BootstrapModel.fromJson(Map<String, dynamic> json) {
    return BootstrapModel(
      summary: json['summary'] != null
          ? BootstrapSummaryModel.fromJson(
              json['summary'] as Map<String, dynamic>)
          : null,
      regions: (json['regions'] as List<dynamic>?)
              ?.map((e) => RegionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      legend: json['legend'] as Map<String, dynamic>?,
      geo: json['geo'] as Map<String, dynamic>?,
      provinceView: json['provinceView'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (summary != null) 'summary': summary!.toJson(),
      'regions': regions.map((e) => e.toJson()).toList(),
      if (legend != null) 'legend': legend,
      if (geo != null) 'geo': geo,
      if (provinceView != null) 'provinceView': provinceView,
    };
  }

  BootstrapModel copyWith({
    BootstrapSummaryModel? summary,
    List<RegionModel>? regions,
    Map<String, dynamic>? legend,
    Map<String, dynamic>? geo,
    Map<String, dynamic>? provinceView,
  }) {
    return BootstrapModel(
      summary: summary ?? this.summary,
      regions: regions ?? this.regions,
      legend: legend ?? this.legend,
      geo: geo ?? this.geo,
      provinceView: provinceView ?? this.provinceView,
    );
  }

  /// Computed: total regions loaded
  int get regionCount => regions.length;

  /// Computed: has data
  bool get hasData => regions.isNotEmpty;

  @override
  String toString() =>
      'BootstrapModel(regions: ${regions.length}, summary: $summary)';
}

class BootstrapSummaryModel {
  final int totalPackages;
  final int totalPriorityPackages;
  final double totalPotentialWaste;
  final int totalBudget;
  final int unmappedPackages;
  final int multiLocationPackages;

  const BootstrapSummaryModel({
    this.totalPackages = 0,
    this.totalPriorityPackages = 0,
    this.totalPotentialWaste = 0,
    this.totalBudget = 0,
    this.unmappedPackages = 0,
    this.multiLocationPackages = 0,
  });

  factory BootstrapSummaryModel.fromJson(Map<String, dynamic> json) {
    return BootstrapSummaryModel(
      totalPackages: json['totalPackages'] as int? ?? 0,
      totalPriorityPackages: json['totalPriorityPackages'] as int? ?? 0,
      totalPotentialWaste:
          (json['totalPotentialWaste'] as num?)?.toDouble() ?? 0,
      totalBudget: json['totalBudget'] as int? ?? 0,
      unmappedPackages: json['unmappedPackages'] as int? ?? 0,
      multiLocationPackages: json['multiLocationPackages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPackages': totalPackages,
      'totalPriorityPackages': totalPriorityPackages,
      'totalPotentialWaste': totalPotentialWaste,
      'totalBudget': totalBudget,
      'unmappedPackages': unmappedPackages,
      'multiLocationPackages': multiLocationPackages,
    };
  }

  /// Computed: waste percentage relative to budget
  double get wastePercentage =>
      totalBudget > 0 ? (totalPotentialWaste / totalBudget) * 100 : 0;

  /// Computed: mapped percentage
  double get mappedPercentage => totalPackages > 0
      ? ((totalPackages - unmappedPackages) / totalPackages) * 100
      : 0;

  @override
  String toString() =>
      'BootstrapSummaryModel(totalPackages: $totalPackages, totalBudget: $totalBudget)';
}
