/// Data models for BPS strategic indicators and CKAN open data platform.

class StrategicIndicatorModel {
  final String title;
  final double value;
  final String unit;
  final String period;
  final String domain;
  final String source;

  const StrategicIndicatorModel({
    required this.title,
    required this.value,
    required this.unit,
    required this.period,
    required this.domain,
    required this.source,
  });

  factory StrategicIndicatorModel.fromJson(Map<String, dynamic> json) {
    return StrategicIndicatorModel(
      title: json['title'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '',
      period: json['period'] as String? ?? '',
      domain: json['domain'] as String? ?? '',
      source: json['source'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'value': value,
      'unit': unit,
      'period': period,
      'domain': domain,
      'source': source,
    };
  }

  StrategicIndicatorModel copyWith({
    String? title,
    double? value,
    String? unit,
    String? period,
    String? domain,
    String? source,
  }) {
    return StrategicIndicatorModel(
      title: title ?? this.title,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      period: period ?? this.period,
      domain: domain ?? this.domain,
      source: source ?? this.source,
    );
  }

  @override
  String toString() =>
      'StrategicIndicatorModel(title: $title, value: $value $unit)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StrategicIndicatorModel &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          period == other.period &&
          domain == other.domain;

  @override
  int get hashCode => title.hashCode ^ period.hashCode ^ domain.hashCode;
}

class CkanDatasetModel {
  final String id;
  final String name;
  final String title;
  final String? notes;
  final String? organization;
  final List<CkanResourceModel> resources;
  final List<String> tags;
  final int numResources;
  final String? metadataModified;

  const CkanDatasetModel({
    required this.id,
    required this.name,
    required this.title,
    this.notes,
    this.organization,
    this.resources = const [],
    this.tags = const [],
    this.numResources = 0,
    this.metadataModified,
  });

  factory CkanDatasetModel.fromJson(Map<String, dynamic> json) {
    return CkanDatasetModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      notes: json['notes'] as String?,
      organization: _extractOrganization(json['organization']),
      resources: _parseResources(json['resources']),
      tags: _parseTags(json['tags']),
      numResources: json['num_resources'] as int? ?? 0,
      metadataModified: json['metadata_modified'] as String?,
    );
  }

  static String? _extractOrganization(dynamic org) {
    if (org == null) return null;
    if (org is String) return org;
    if (org is Map<String, dynamic>) return org['title'] as String?;
    return null;
  }

  static List<CkanResourceModel> _parseResources(dynamic resources) {
    if (resources == null) return [];
    if (resources is! List) return [];
    return resources
        .map((e) => CkanResourceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<String> _parseTags(dynamic tags) {
    if (tags == null) return [];
    if (tags is! List) return [];
    return tags.map((e) {
      if (e is String) return e;
      if (e is Map<String, dynamic>) return e['display_name'] as String? ?? '';
      return '';
    }).where((t) => t.isNotEmpty).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      if (notes != null) 'notes': notes,
      if (organization != null) 'organization': organization,
      'resources': resources.map((r) => r.toJson()).toList(),
      'tags': tags,
      'num_resources': numResources,
      if (metadataModified != null) 'metadata_modified': metadataModified,
    };
  }

  CkanDatasetModel copyWith({
    String? id,
    String? name,
    String? title,
    String? notes,
    String? organization,
    List<CkanResourceModel>? resources,
    List<String>? tags,
    int? numResources,
    String? metadataModified,
  }) {
    return CkanDatasetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      organization: organization ?? this.organization,
      resources: resources ?? this.resources,
      tags: tags ?? this.tags,
      numResources: numResources ?? this.numResources,
      metadataModified: metadataModified ?? this.metadataModified,
    );
  }

  @override
  String toString() => 'CkanDatasetModel(id: $id, title: $title)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CkanDatasetModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CkanResourceModel {
  final String id;
  final String name;
  final String format;
  final String url;
  final int? size;
  final bool datastoreActive;

  const CkanResourceModel({
    required this.id,
    required this.name,
    required this.format,
    required this.url,
    this.size,
    this.datastoreActive = false,
  });

  factory CkanResourceModel.fromJson(Map<String, dynamic> json) {
    return CkanResourceModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      format: (json['format'] as String? ?? '').toUpperCase(),
      url: json['url'] as String? ?? '',
      size: json['size'] as int?,
      datastoreActive: json['datastore_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'format': format,
      'url': url,
      if (size != null) 'size': size,
      'datastore_active': datastoreActive,
    };
  }

  CkanResourceModel copyWith({
    String? id,
    String? name,
    String? format,
    String? url,
    int? size,
    bool? datastoreActive,
  }) {
    return CkanResourceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      format: format ?? this.format,
      url: url ?? this.url,
      size: size ?? this.size,
      datastoreActive: datastoreActive ?? this.datastoreActive,
    );
  }

  @override
  String toString() => 'CkanResourceModel(id: $id, name: $name, format: $format)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CkanResourceModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
