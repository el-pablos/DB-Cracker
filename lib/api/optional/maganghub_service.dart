import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../cache/cache_store.dart';
import '../cache/cache_entry.dart';

/// Model peluang magang
class InternshipOpportunity {
  final String title;
  final String company;
  final String location;
  final String? url;
  final String? type;
  final String providerId;

  const InternshipOpportunity({
    required this.title,
    required this.company,
    this.location = '',
    this.url,
    this.type,
    this.providerId = 'maganghub',
  });

  factory InternshipOpportunity.fromJson(Map<String, dynamic> json) {
    return InternshipOpportunity(
      title: json['title']?.toString() ?? json['position']?.toString() ?? '',
      company: json['company']?.toString() ?? json['perusahaan']?.toString() ?? '',
      location: json['location']?.toString() ?? json['lokasi']?.toString() ?? '',
      url: json['url']?.toString() ?? json['link']?.toString(),
      type: json['type']?.toString() ?? json['tipe']?.toString(),
    );
  }
}

/// Service MagangHub — optional career enrichment
/// Data magang dari provider eksternal, BUKAN afiliasi resmi kampus
class MagangHubService {
  final http.Client httpClient;
  final CacheStore cacheStore;

  static const _baseUrl = 'https://maganghub.ndav.my.id/api/scrape';
  static const _freshTtl = Duration(hours: 6);
  static const _staleTtl = Duration(days: 3);

  MagangHubService({required this.httpClient, required this.cacheStore});

  /// Ambil daftar peluang magang
  Future<List<InternshipOpportunity>> getInternships() async {
    const cacheKey = 'maganghub:internships';

    final cached = await cacheStore.get(cacheKey);
    if (cached != null && cached.isFresh) {
      try {
        return _parseInternships(json.decode(cached.body));
      } catch (_) {
        await cacheStore.delete(cacheKey);
      }
    }

    try {
      final response = await httpClient
          .get(Uri.parse('$_baseUrl/internships'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = _parseInternships(data);

        if (results.isNotEmpty) {
          await cacheStore.put(CacheEntry(
            key: cacheKey,
            body: response.body,
            createdAt: DateTime.now(),
            freshUntil: DateTime.now().add(_freshTtl),
            staleUntil: DateTime.now().add(_staleTtl),
            source: 'maganghub',
          ));
        }
        return results;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('MagangHubService error: $e');
    }

    // Stale fallback
    if (cached != null && cached.isStale) {
      try {
        return _parseInternships(json.decode(cached.body));
      } catch (_) {}
    }

    return [];
  }

  /// Ambil daftar perusahaan
  Future<List<String>> getCompanies() async {
    const cacheKey = 'maganghub:companies';

    final cached = await cacheStore.get(cacheKey);
    if (cached != null && cached.isFresh) {
      try {
        final data = json.decode(cached.body);
        if (data is List) return data.map((e) => e.toString()).toList();
      } catch (_) {}
    }

    try {
      final response = await httpClient
          .get(Uri.parse('$_baseUrl/companies'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<String> companies = [];

        if (data is List) {
          companies = data.map((e) {
            if (e is Map) return e['name']?.toString() ?? e.toString();
            return e.toString();
          }).where((s) => s.isNotEmpty).toList();
        }

        if (companies.isNotEmpty) {
          await cacheStore.put(CacheEntry(
            key: cacheKey,
            body: json.encode(companies),
            createdAt: DateTime.now(),
            freshUntil: DateTime.now().add(_freshTtl),
            staleUntil: DateTime.now().add(_staleTtl),
            source: 'maganghub',
          ));
        }
        return companies;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('MagangHub companies error: $e');
    }

    return [];
  }

  List<InternshipOpportunity> _parseInternships(dynamic data) {
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      list = data['data'] as List<dynamic>? ?? data['internships'] as List<dynamic>? ?? [];
    } else {
      return [];
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map((item) => InternshipOpportunity.fromJson(item))
        .where((i) => i.title.isNotEmpty)
        .toList();
  }
}
