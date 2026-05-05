/// Model data wilayah Indonesia — normalized dari berbagai provider
/// Provider wilayah.id pakai field `code` + `name`
/// Provider emsifa pakai field `id` + `name` (UPPERCASE)

class Province {
  final String code;
  final String name;
  final String providerId;

  const Province({
    required this.code,
    required this.name,
    required this.providerId,
  });

  @override
  String toString() => 'Province($code: $name)';

  /// Parse dari wilayah.id format: {"code": "11", "name": "Aceh"}
  factory Province.fromWilayahId(Map<String, dynamic> json, String providerId) {
    return Province(
      code: (json['code'] ?? json['kode'] ?? '').toString(),
      name: _titleCase(json['name']?.toString() ?? json['nama']?.toString() ?? ''),
      providerId: providerId,
    );
  }

  /// Parse dari emsifa format: {"id": "11", "name": "ACEH"}
  factory Province.fromEmsifa(Map<String, dynamic> json, String providerId) {
    return Province(
      code: (json['id'] ?? json['code'] ?? '').toString(),
      name: _titleCase(json['name']?.toString() ?? json['nama']?.toString() ?? ''),
      providerId: providerId,
    );
  }
}

class Regency {
  final String code;
  final String provinceCode;
  final String name;
  final String providerId;

  const Regency({
    required this.code,
    required this.provinceCode,
    required this.name,
    required this.providerId,
  });

  @override
  String toString() => 'Regency($code: $name)';

  factory Regency.fromWilayahId(Map<String, dynamic> json, String provinceCode, String providerId) {
    return Regency(
      code: (json['code'] ?? json['kode'] ?? '').toString(),
      provinceCode: provinceCode,
      name: _titleCase(json['name']?.toString() ?? json['nama']?.toString() ?? ''),
      providerId: providerId,
    );
  }

  factory Regency.fromEmsifa(Map<String, dynamic> json, String providerId) {
    return Regency(
      code: (json['id'] ?? json['code'] ?? '').toString(),
      provinceCode: (json['province_id'] ?? '').toString(),
      name: _titleCase(json['name']?.toString() ?? json['nama']?.toString() ?? ''),
      providerId: providerId,
    );
  }
}

class District {
  final String code;
  final String regencyCode;
  final String name;
  final String providerId;

  const District({
    required this.code,
    required this.regencyCode,
    required this.name,
    required this.providerId,
  });

  factory District.fromWilayahId(Map<String, dynamic> json, String regencyCode, String providerId) {
    return District(
      code: (json['code'] ?? json['kode'] ?? '').toString(),
      regencyCode: regencyCode,
      name: _titleCase(json['name']?.toString() ?? json['nama']?.toString() ?? ''),
      providerId: providerId,
    );
  }

  factory District.fromEmsifa(Map<String, dynamic> json, String providerId) {
    return District(
      code: (json['id'] ?? json['code'] ?? '').toString(),
      regencyCode: (json['regency_id'] ?? '').toString(),
      name: _titleCase(json['name']?.toString() ?? json['nama']?.toString() ?? ''),
      providerId: providerId,
    );
  }
}

/// Helper: convert UPPERCASE atau lowercase ke Title Case
String _titleCase(String input) {
  if (input.isEmpty) return input;
  // Jika sudah mixed case, return as-is
  if (input != input.toUpperCase() && input != input.toLowerCase()) return input;
  return input.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}
