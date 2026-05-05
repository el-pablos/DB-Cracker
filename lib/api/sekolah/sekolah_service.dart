import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../cache/cache_store.dart';
import '../cache/cache_entry.dart';
import '../core/provider_registry.dart';
import 'sekolah_models.dart';

/// Service untuk lookup sekolah berdasarkan NPSN
/// Provider: api.fazriansyah.eu.org (no-auth)
/// Cache: 7 hari fresh, 30 hari stale
class SekolahService {
  final http.Client httpClient;
  final CacheStore cacheStore;

  static const _freshTtl = Duration(days: 7);
  static const _staleTtl = Duration(days: 30);

  SekolahService({required this.httpClient, required this.cacheStore});

  /// Lookup sekolah berdasarkan NPSN
  /// NPSN harus numeric string, minimal 8 digit
  Future<Sekolah?> lookupByNpsn(String npsn) async {
    // Validasi input
    final cleanNpsn = npsn.trim();
    if (cleanNpsn.isEmpty || cleanNpsn.length < 6) return null;
    if (!RegExp(r'^\d+$').hasMatch(cleanNpsn)) return null;

    final cacheKey = 'sekolah:npsn:$cleanNpsn';

    // Cek cache
    final cached = await cacheStore.get(cacheKey);
    if (cached != null && cached.isFresh) {
      try {
        final data = json.decode(cached.body);
        if (data is Map<String, dynamic>) {
          return Sekolah.fromJson(data, providerId: cached.source);
        }
      } catch (_) {
        await cacheStore.delete(cacheKey);
      }
    }

    // Fetch dari provider
    final provider = ProviderRegistry.byId('fazriansyah_sekolah');
    if (provider == null || !provider.enabled) return null;

    try {
      final url = '${provider.baseUrl}/sekolah?npsn=${Uri.encodeComponent(cleanNpsn)}';
      final response = await httpClient
          .get(Uri.parse(url), headers: const {'Accept': 'application/json'})
          .timeout(provider.timeout);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        Map<String, dynamic>? sekolahData;

        // Parse response — format fazriansyah: {data: {satuanPendidikan: {...}}}
        if (responseData is Map<String, dynamic>) {
          final data = responseData['data'];
          if (data is Map<String, dynamic>) {
            // Check for error response
            if (data.containsKey('error')) return null;
            // Nested satuanPendidikan
            if (data.containsKey('satuanPendidikan') && data['satuanPendidikan'] is Map) {
              sekolahData = data['satuanPendidikan'] as Map<String, dynamic>;
            } else if (data.containsKey('npsn') || data.containsKey('nama')) {
              sekolahData = data;
            }
          } else if (responseData.containsKey('npsn') || responseData.containsKey('nama')) {
            sekolahData = responseData;
          }
        }

        if (sekolahData != null) {
          // Simpan ke cache
          await cacheStore.put(CacheEntry(
            key: cacheKey,
            body: json.encode(sekolahData),
            createdAt: DateTime.now(),
            freshUntil: DateTime.now().add(_freshTtl),
            staleUntil: DateTime.now().add(_staleTtl),
            source: provider.id,
          ));

          return Sekolah.fromJson(sekolahData, providerId: provider.id);
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('SekolahService error: $e');
    }

    // Fallback ke stale cache
    if (cached != null && cached.isStale) {
      try {
        final data = json.decode(cached.body);
        if (data is Map<String, dynamic>) {
          return Sekolah.fromJson(data, providerId: '${cached.source}:stale');
        }
      } catch (_) {}
    }

    return null;
  }
}
