import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../cache/cache_store.dart';
import '../cache/cache_entry.dart';

/// Glossary akademik lokal — fallback jika KBBI API mati
const Map<String, String> academicGlossaryFallback = {
  'akreditasi': 'Penilaian kelayakan dan mutu institusi atau program studi oleh badan akreditasi.',
  'sks': 'Satuan Kredit Semester — ukuran beban studi mahasiswa per semester.',
  'ipk': 'Indeks Prestasi Kumulatif — rata-rata nilai akademik selama kuliah.',
  'ips': 'Indeks Prestasi Semester — rata-rata nilai akademik per semester.',
  'nidn': 'Nomor Induk Dosen Nasional — identitas unik dosen di Indonesia.',
  'npsn': 'Nomor Pokok Sekolah Nasional — identitas unik sekolah di Indonesia.',
  'nim': 'Nomor Induk Mahasiswa — identitas unik mahasiswa di perguruan tinggi.',
  'prodi': 'Program Studi — jurusan atau bidang ilmu yang ditempuh mahasiswa.',
  'perguruan tinggi': 'Institusi pendidikan setelah SMA/SMK, termasuk universitas, institut, politeknik, dan akademi.',
  'dosen': 'Tenaga pengajar di perguruan tinggi yang memiliki kualifikasi akademik.',
  'mahasiswa': 'Peserta didik yang terdaftar di perguruan tinggi.',
  'semester': 'Periode waktu akademik, biasanya 6 bulan (ganjil/genap).',
  'skripsi': 'Karya tulis ilmiah sebagai syarat kelulusan program sarjana (S1).',
  'tesis': 'Karya tulis ilmiah sebagai syarat kelulusan program magister (S2).',
  'disertasi': 'Karya tulis ilmiah sebagai syarat kelulusan program doktor (S3).',
  'pddikti': 'Pangkalan Data Pendidikan Tinggi — database nasional pendidikan tinggi Indonesia.',
  'bkd': 'Beban Kerja Dosen — laporan aktivitas mengajar, penelitian, dan pengabdian.',
  'tri dharma': 'Tiga kewajiban perguruan tinggi: pendidikan, penelitian, dan pengabdian masyarakat.',
  'yudisium': 'Sidang penetapan kelulusan mahasiswa oleh perguruan tinggi.',
  'wisuda': 'Upacara pelantikan kelulusan mahasiswa dari perguruan tinggi.',
};

/// Model hasil KBBI
class KbbiResult {
  final String word;
  final String definition;
  final String source; // 'kbbi_api' atau 'local_fallback'

  const KbbiResult({
    required this.word,
    required this.definition,
    required this.source,
  });
}

/// Service KBBI — optional glossary untuk istilah akademik
/// Prioritas: local fallback → KBBI API (jika tersedia)
class KbbiService {
  final http.Client httpClient;
  final CacheStore cacheStore;

  static const _baseUrl = 'https://kbbi-api-amm.herokuapp.com';
  static const _freshTtl = Duration(days: 30);
  static const _staleTtl = Duration(days: 180);

  KbbiService({required this.httpClient, required this.cacheStore});

  /// Cari definisi istilah — prioritas local fallback, lalu API
  Future<KbbiResult?> lookup(String term) async {
    final cleanTerm = term.trim().toLowerCase();
    if (cleanTerm.isEmpty) return null;

    // 1. Cek local fallback dulu (instant, no network)
    final localDef = academicGlossaryFallback[cleanTerm];
    if (localDef != null) {
      return KbbiResult(word: cleanTerm, definition: localDef, source: 'local_fallback');
    }

    // 2. Cek cache
    final cacheKey = 'kbbi:term:$cleanTerm';
    final cached = await cacheStore.get(cacheKey);
    if (cached != null && cached.isFresh) {
      try {
        final data = json.decode(cached.body);
        return KbbiResult(
          word: cleanTerm,
          definition: data['definition']?.toString() ?? '',
          source: 'kbbi_api:cached',
        );
      } catch (_) {}
    }

    // 3. Coba KBBI API (optional, bisa mati)
    try {
      final url = '$_baseUrl/search?q=${Uri.encodeComponent(cleanTerm)}';
      final response = await httpClient
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        String? definition;

        if (data is List && data.isNotEmpty) {
          final first = data[0];
          if (first is Map<String, dynamic>) {
            definition = first['arti']?.toString() ?? first['definition']?.toString();
          }
        } else if (data is Map<String, dynamic>) {
          definition = data['arti']?.toString() ?? data['definition']?.toString();
        }

        if (definition != null && definition.isNotEmpty) {
          await cacheStore.put(CacheEntry(
            key: cacheKey,
            body: json.encode({'definition': definition}),
            createdAt: DateTime.now(),
            freshUntil: DateTime.now().add(_freshTtl),
            staleUntil: DateTime.now().add(_staleTtl),
            source: 'kbbi_api',
          ));
          return KbbiResult(word: cleanTerm, definition: definition, source: 'kbbi_api');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('KbbiService API error (non-critical): $e');
    }

    return null;
  }

  /// Ambil semua istilah dari local glossary
  List<KbbiResult> getAllLocalTerms() {
    return academicGlossaryFallback.entries
        .map((e) => KbbiResult(word: e.key, definition: e.value, source: 'local_fallback'))
        .toList();
  }
}
