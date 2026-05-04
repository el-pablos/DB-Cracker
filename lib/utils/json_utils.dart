/// Shared utility class untuk JSON parsing yang aman
/// Menggantikan duplikasi _ensureString dan _getStringValue di semua model
class JsonUtils {
  /// Konversi dynamic value ke String, return '' jika null
  static String ensureString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  /// Ambil value dari Map dan konversi ke String, return '' jika null/tidak ada
  static String getStringValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }

  /// Ambil value dari Map dengan multiple possible keys
  static String getStringFromKeys(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }
}
