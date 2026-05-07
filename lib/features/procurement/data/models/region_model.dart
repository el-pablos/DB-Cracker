class RegionModel {
  final String regionKey;
  final String? code;
  final String? provinceName;
  final String? regionName;
  final String? regionType;
  final String? displayName;
  final int totalPackages;
  final int totalPriorityPackages;
  final int totalFlaggedPackages;
  final double totalPotentialWaste;
  final int totalBudget;
  final double avgRiskScore;
  final double maxRiskScore;
  final Map<String, dynamic>? ownerMix;
  final Map<String, dynamic>? severityCounts;
  final String? dominantOwnerType;

  const RegionModel({
    required this.regionKey,
    this.code,
    this.provinceName,
    this.regionName,
    this.regionType,
    this.displayName,
    this.totalPackages = 0,
    this.totalPriorityPackages = 0,
    this.totalFlaggedPackages = 0,
    this.totalPotentialWaste = 0,
    this.totalBudget = 0,
    this.avgRiskScore = 0,
    this.maxRiskScore = 0,
    this.ownerMix,
    this.severityCounts,
    this.dominantOwnerType,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      regionKey: json['regionKey'] as String? ?? '',
      code: json['code'] as String?,
      provinceName: json['provinceName'] as String?,
      regionName: json['regionName'] as String?,
      regionType: json['regionType'] as String?,
      displayName: json['displayName'] as String?,
      totalPackages: json['totalPackages'] as int? ?? 0,
      totalPriorityPackages: json['totalPriorityPackages'] as int? ?? 0,
      totalFlaggedPackages: json['totalFlaggedPackages'] as int? ?? 0,
      totalPotentialWaste:
          (json['totalPotentialWaste'] as num?)?.toDouble() ?? 0,
      totalBudget: json['totalBudget'] as int? ?? 0,
      avgRiskScore: (json['avgRiskScore'] as num?)?.toDouble() ?? 0,
      maxRiskScore: (json['maxRiskScore'] as num?)?.toDouble() ?? 0,
      ownerMix: json['ownerMix'] as Map<String, dynamic>?,
      severityCounts: json['severityCounts'] as Map<String, dynamic>?,
      dominantOwnerType: json['dominantOwnerType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regionKey': regionKey,
      if (code != null) 'code': code,
      if (provinceName != null) 'provinceName': provinceName,
      if (regionName != null) 'regionName': regionName,
      if (regionType != null) 'regionType': regionType,
      if (displayName != null) 'displayName': displayName,
      'totalPackages': totalPackages,
      'totalPriorityPackages': totalPriorityPackages,
      'totalFlaggedPackages': totalFlaggedPackages,
      'totalPotentialWaste': totalPotentialWaste,
      'totalBudget': totalBudget,
      'avgRiskScore': avgRiskScore,
      'maxRiskScore': maxRiskScore,
      if (ownerMix != null) 'ownerMix': ownerMix,
      if (severityCounts != null) 'severityCounts': severityCounts,
      if (dominantOwnerType != null) 'dominantOwnerType': dominantOwnerType,
    };
  }

  RegionModel copyWith({
    String? regionKey,
    String? code,
    String? provinceName,
    String? regionName,
    String? regionType,
    String? displayName,
    int? totalPackages,
    int? totalPriorityPackages,
    int? totalFlaggedPackages,
    double? totalPotentialWaste,
    int? totalBudget,
    double? avgRiskScore,
    double? maxRiskScore,
    Map<String, dynamic>? ownerMix,
    Map<String, dynamic>? severityCounts,
    String? dominantOwnerType,
  }) {
    return RegionModel(
      regionKey: regionKey ?? this.regionKey,
      code: code ?? this.code,
      provinceName: provinceName ?? this.provinceName,
      regionName: regionName ?? this.regionName,
      regionType: regionType ?? this.regionType,
      displayName: displayName ?? this.displayName,
      totalPackages: totalPackages ?? this.totalPackages,
      totalPriorityPackages:
          totalPriorityPackages ?? this.totalPriorityPackages,
      totalFlaggedPackages: totalFlaggedPackages ?? this.totalFlaggedPackages,
      totalPotentialWaste: totalPotentialWaste ?? this.totalPotentialWaste,
      totalBudget: totalBudget ?? this.totalBudget,
      avgRiskScore: avgRiskScore ?? this.avgRiskScore,
      maxRiskScore: maxRiskScore ?? this.maxRiskScore,
      ownerMix: ownerMix ?? this.ownerMix,
      severityCounts: severityCounts ?? this.severityCounts,
      dominantOwnerType: dominantOwnerType ?? this.dominantOwnerType,
    );
  }

  /// Computed: effective display label
  String get label => displayName ?? regionName ?? regionKey;

  /// Computed: has high risk
  bool get isHighRisk => maxRiskScore >= 0.7 || totalFlaggedPackages > 0;

  @override
  String toString() =>
      'RegionModel(regionKey: $regionKey, totalPackages: $totalPackages)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegionModel &&
          runtimeType == other.runtimeType &&
          regionKey == other.regionKey;

  @override
  int get hashCode => regionKey.hashCode;
}
