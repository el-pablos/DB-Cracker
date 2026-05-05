import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../cache/cache_store.dart';
import '../cache/cache_entry.dart';

/// Model ringkasan Wikipedia
class WikipediaSummary {
  final String title;
  final String extract;
  final String? pageUrl;
  final String? thumbnailUrl;
  final String providerId;

  const WikipediaSummary({
    required this.title,
    required this.extract,
    this.pageUrl,
    this.thumbnailUrl,
    this.providerId = 'wikipedia_id',
  });

  factory WikipediaSummary.fromJson(Map<String, dynamic> json) {
    return WikipediaSummary(
      title: json['title']?.toString() ?? '',
      extract: json['extract']?.toString() ?? '',
      pageUrl: json['content_urls']?['desktop']?['page']?.toString(),
      thumbnailUrl: json['thumbnail']?['source']?.toString(),
    );
  }
}

/// Service Wikipedia — optional enrichment untuk ringkasan umum
/// BUKAN sumber data resmi PDDIKTI. Hanya konteks tambahan.
class WikipediaService {
  final http.Client httpClient;
  final CacheStore cacheStore;

  static const _baseUrl = 'https://id.wikipedia.org/api/rest_v1';
  static const _freshTtl = Duration(days: 7);
  static const _staleTtl = Duration(days: 30);

  WikipediaService({required this.httpClient, required this.cacheStore});

  /// Ambil ringkasan halaman Wikipedia berdasarkan keyword
  /// Return null jika tidak ditemukan atau error
  Future<WikipediaSummary?> getSummary(String keyword) async {
    final cleanKeyword = keyword.trim();
    if (cleanKeyword.isEmpty || cleanKeyword.length < 3) return null;

    final cacheKey = 'wikipedia:summary:${cleanKeyword.toLowerCase()}';

    // Cek cache
    final cached = await cacheStore.get(cacheKey);
    if (cached != null && cached.isFresh) {
      try {
        return WikipediaSummary.fromJson(json.decode(cached.body));
      } catch (_) {
        await cacheStore.delete(cacheKey);
      }
    }

    try {
      final encodedKeyword = Uri.encodeComponent(cleanKeyword);
      final url = '$_baseUrl/page/summary/$encodedKeyword';
      final response = await httpClient
          .get(Uri.parse(url), headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data['extract'] != null) {
          await cacheStore.put(CacheEntry(
            key: cacheKey,
            body: response.body,
            createdAt: DateTime.now(),
            freshUntil: DateTime.now().add(_freshTtl),
            staleUntil: DateTime.now().add(_staleTtl),
            source: 'wikipedia_id',
          ));
          return WikipediaSummary.fromJson(data);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('WikipediaService error: $e');
    }

    // Stale cache fallback
    if (cached != null && cached.isStale) {
      try {
        return WikipediaSummary.fromJson(json.decode(cached.body));
      } catch (_) {}
    }

    return null;
  }
}
