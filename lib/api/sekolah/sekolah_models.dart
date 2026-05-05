/// Model data sekolah Indonesia — dari API Sekolah (fazriansyah)
/// Parser defensif: toleran terhadap field yang beda nama antar provider

class Sekolah {
  final String npsn;
  final String nama;
  final String bentukPendidikan;
  final String statusSekolah;
  final String alamat;
  final String provinsi;
  final String kabupatenKota;
  final String kecamatan;
  final String kelurahan;
  final String lintang;
  final String bujur;
  final String providerId;

  const Sekolah({
    required this.npsn,
    required this.nama,
    this.bentukPendidikan = '',
    this.statusSekolah = '',
    this.alamat = '',
    this.provinsi = '',
    this.kabupatenKota = '',
    this.kecamatan = '',
    this.kelurahan = '',
    this.lintang = '',
    this.bujur = '',
    this.providerId = 'fazriansyah_sekolah',
  });

  /// Parser defensif — support multiple candidate keys
  factory Sekolah.fromJson(Map<String, dynamic> json, {String providerId = 'fazriansyah_sekolah'}) {
    return Sekolah(
      npsn: _str(json, ['npsn', 'NPSN']),
      nama: _str(json, ['nama', 'nama_sekolah', 'sekolah', 'name']),
      bentukPendidikan: _str(json, ['bentuk_pendidikan', 'bentuk', 'jenjang', 'bp']),
      statusSekolah: _str(json, ['status_sekolah', 'status', 'status_kepemilikan']),
      alamat: _str(json, ['alamat_jalan', 'alamat', 'address']),
      provinsi: _str(json, ['provinsi', 'propinsi', 'province']),
      kabupatenKota: _str(json, ['kabupaten_kota', 'kab_kota', 'kabupaten', 'kota', 'city']),
      kecamatan: _str(json, ['kecamatan', 'kec', 'district']),
      kelurahan: _str(json, ['kelurahan', 'desa', 'desa_kelurahan', 'village']),
      lintang: _str(json, ['lintang', 'latitude', 'lat']),
      bujur: _str(json, ['bujur', 'longitude', 'lng', 'lon']),
      providerId: providerId,
    );
  }

  /// Helper: ambil string dari multiple candidate keys
  static String _str(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  /// Lokasi lengkap gabungan
  String get lokasiLengkap {
    final parts = [kelurahan, kecamatan, kabupatenKota, provinsi]
        .where((s) => s.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  @override
  String toString() => 'Sekolah($npsn: $nama)';
}
