class ProcurementPackageModel {
  final int id;
  final String sourceId;
  final String packageName;
  final String ownerName;
  final String ownerType;
  final String? satker;
  final String? locationRaw;
  final int? budget;
  final String? fundingSource;
  final String? procurementType;
  final String? procurementMethod;
  final String? selectionDate;
  final PackageAuditModel? audit;
  final PackageMetaModel? meta;

  const ProcurementPackageModel({
    required this.id,
    required this.sourceId,
    required this.packageName,
    required this.ownerName,
    required this.ownerType,
    this.satker,
    this.locationRaw,
    this.budget,
    this.fundingSource,
    this.procurementType,
    this.procurementMethod,
    this.selectionDate,
    this.audit,
    this.meta,
  });

  factory ProcurementPackageModel.fromJson(Map<String, dynamic> json) {
    return ProcurementPackageModel(
      id: json['id'] as int? ?? 0,
      sourceId: json['sourceId'] as String? ?? '',
      packageName: json['packageName'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      ownerType: json['ownerType'] as String? ?? '',
      satker: json['satker'] as String?,
      locationRaw: json['locationRaw'] as String?,
      budget: json['budget'] as int?,
      fundingSource: json['fundingSource'] as String?,
      procurementType: json['procurementType'] as String?,
      procurementMethod: json['procurementMethod'] as String?,
      selectionDate: json['selectionDate'] as String?,
      audit: json['audit'] != null
          ? PackageAuditModel.fromJson(json['audit'] as Map<String, dynamic>)
          : null,
      meta: json['meta'] != null
          ? PackageMetaModel.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceId': sourceId,
      'packageName': packageName,
      'ownerName': ownerName,
      'ownerType': ownerType,
      if (satker != null) 'satker': satker,
      if (locationRaw != null) 'locationRaw': locationRaw,
      if (budget != null) 'budget': budget,
      if (fundingSource != null) 'fundingSource': fundingSource,
      if (procurementType != null) 'procurementType': procurementType,
      if (procurementMethod != null) 'procurementMethod': procurementMethod,
      if (selectionDate != null) 'selectionDate': selectionDate,
      if (audit != null) 'audit': audit!.toJson(),
      if (meta != null) 'meta': meta!.toJson(),
    };
  }

  ProcurementPackageModel copyWith({
    int? id,
    String? sourceId,
    String? packageName,
    String? ownerName,
    String? ownerType,
    String? satker,
    String? locationRaw,
    int? budget,
    String? fundingSource,
    String? procurementType,
    String? procurementMethod,
    String? selectionDate,
    PackageAuditModel? audit,
    PackageMetaModel? meta,
  }) {
    return ProcurementPackageModel(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      packageName: packageName ?? this.packageName,
      ownerName: ownerName ?? this.ownerName,
      ownerType: ownerType ?? this.ownerType,
      satker: satker ?? this.satker,
      locationRaw: locationRaw ?? this.locationRaw,
      budget: budget ?? this.budget,
      fundingSource: fundingSource ?? this.fundingSource,
      procurementType: procurementType ?? this.procurementType,
      procurementMethod: procurementMethod ?? this.procurementMethod,
      selectionDate: selectionDate ?? this.selectionDate,
      audit: audit ?? this.audit,
      meta: meta ?? this.meta,
    );
  }

  @override
  String toString() => 'ProcurementPackageModel(id: $id, packageName: $packageName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProcurementPackageModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sourceId == other.sourceId;

  @override
  int get hashCode => id.hashCode ^ sourceId.hashCode;
}

class PackageAuditModel {
  final String? schemaVersion;
  final String severity;
  final double potensiPemborosan;
  final String? reason;
  final PackageFlagsModel? flags;

  const PackageAuditModel({
    this.schemaVersion,
    required this.severity,
    this.potensiPemborosan = 0,
    this.reason,
    this.flags,
  });

  factory PackageAuditModel.fromJson(Map<String, dynamic> json) {
    return PackageAuditModel(
      schemaVersion: json['schemaVersion'] as String?,
      severity: json['severity'] as String? ?? 'unknown',
      potensiPemborosan: (json['potensiPemborosan'] as num?)?.toDouble() ?? 0,
      reason: json['reason'] as String?,
      flags: json['flags'] != null
          ? PackageFlagsModel.fromJson(json['flags'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (schemaVersion != null) 'schemaVersion': schemaVersion,
      'severity': severity,
      'potensiPemborosan': potensiPemborosan,
      if (reason != null) 'reason': reason,
      if (flags != null) 'flags': flags!.toJson(),
    };
  }

  @override
  String toString() => 'PackageAuditModel(severity: $severity, potensiPemborosan: $potensiPemborosan)';
}

class PackageFlagsModel {
  final bool isMencurigakan;
  final bool isPemborosan;

  const PackageFlagsModel({
    this.isMencurigakan = false,
    this.isPemborosan = false,
  });

  factory PackageFlagsModel.fromJson(Map<String, dynamic> json) {
    return PackageFlagsModel(
      isMencurigakan: json['isMencurigakan'] as bool? ?? false,
      isPemborosan: json['isPemborosan'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isMencurigakan': isMencurigakan,
      'isPemborosan': isPemborosan,
    };
  }
}

class PackageMetaModel {
  final bool isPriority;
  final bool isFlagged;
  final double riskScore;
  final int activeTagCount;
  final int mappedRegionCount;

  const PackageMetaModel({
    this.isPriority = false,
    this.isFlagged = false,
    this.riskScore = 0,
    this.activeTagCount = 0,
    this.mappedRegionCount = 0,
  });

  factory PackageMetaModel.fromJson(Map<String, dynamic> json) {
    return PackageMetaModel(
      isPriority: json['isPriority'] as bool? ?? false,
      isFlagged: json['isFlagged'] as bool? ?? false,
      riskScore: (json['riskScore'] as num?)?.toDouble() ?? 0,
      activeTagCount: json['activeTagCount'] as int? ?? 0,
      mappedRegionCount: json['mappedRegionCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isPriority': isPriority,
      'isFlagged': isFlagged,
      'riskScore': riskScore,
      'activeTagCount': activeTagCount,
      'mappedRegionCount': mappedRegionCount,
    };
  }
}
