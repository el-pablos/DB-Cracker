import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../cache/cache_store.dart';
import '../cache/cache_entry.dart';
import '../cache/cache_policy.dart';
import '../core/provider_registry.dart';
import 'wilayah_models.dart';

/// Service untuk fetch data wilayah Indonesia
/// Menggunakan provider chain: wilayah.id → emsifa (fallback)
/// Cache agresif karena data wilayah jarang berubah
class WilayahService {
  final http.Client httpClient;
  final CacheStore cacheStore;

  WilayahService({required this.httpClient, required this.cacheStore});

  /// Ambil daftar provinsi
  Future<List<Province>> getProvinces() async {
    const cacheKey = 'wilayah:provinces';

    // Cek cache dulu
    final cached = await cacheStore.get(cacheKey);
    if (cached != null && cached.isFresh) {
      try {
        return _parseProvinces(json.decode(cached.body), cached.source);
      } catch (_) {
        await cacheStore.delete(cacheKey);
      }
    }

    // Coba provider berdasarkan priority
    final providers = ProviderRegistry.byKind(ProviderKind.wilayah);

    for (final provider in providers) {
      try {
        final url = _buildProvincesUrl(provider);
        final response = await httpClient
            .get(Uri.parse(url))
            .timeout(provider.timeout);

        if (response.statusCode == 200) {
          final dynamic data = json.decode(response.body);
          final provinces = _parseProvinces(data, provider.id);

          if (provinces.isNotEmpty) {
            // Simpan ke cache
            await cacheStore.put(CacheEntry(
              key: cacheKey,
              body: response.body,
              createdAt: DateTime.now(),
              freshUntil: DateTime.now().add(CachePolicy.wilayah.freshTtl),
              staleUntil: DateTime.now().add(CachePolicy.wilayah.staleTtl),
              source: provider.id,
            ));
            return provinces;
          }
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Wilayah provider ${provider.id} gagal: $e');
        continue;
      }
    }

    // Semua provider gagal — cek stale cache
    if (cached != null && cached.isStale) {
      try {
        return _parseProvinces(json.decode(cached.body), cached.source);
      } catch (_) {}
    }

    return [];
  }

  /// Ambil daftar kabupaten/kota berdasarkan kode provinsi
  Future<List<Regency>> getRegencies(String provinceCode) async {
    final cacheKey = 'wilayah:regencies:$provinceCode';

    final cached = await cacheStore.get(cacheKey);
    if (cached != null && cached.isFresh) {
      try {
        return _parseRegencies(json.decode(cached.body), provinceCode, cached.source);
      } catch (_) {
        await cacheStore.delete(cacheKey);
      }
    }

    final providers = ProviderRegistry.byKind(ProviderKind.wilayah);

    for (final provider in providers) {
      try {
        final url = _buildRegenciesUrl(provider, provinceCode);
        final response = await httpClient
            .get(Uri.parse(url))
            .timeout(provider.timeout);

        if (response.statusCode == 200) {
          final dynamic data = json.decode(response.body);
          final regencies = _parseRegencies(data, provinceCode, provider.id);

          if (regencies.isNotEmpty) {
            await cacheStore.put(CacheEntry(
              key: cacheKey,
              body: response.body,
              createdAt: DateTime.now(),
              freshUntil: DateTime.now().add(CachePolicy.wilayah.freshTtl),
              staleUntil: DateTime.now().add(CachePolicy.wilayah.staleTtl),
              source: provider.id,
            ));
            return regencies;
          }
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Wilayah regencies ${provider.id} gagal: $e');
        continue;
      }
    }

    if (cached != null && cached.isStale) {
      try {
        return _parseRegencies(json.decode(cached.body), provinceCode, cached.source);
      } catch (_) {}
    }

    return [];
  }

  /// Cari provinsi berdasarkan nama (case-insensitive)
  Future<Province?> findProvinceByName(String name) async {
    final provinces = await getProvinces();
    final normalized = name.toLowerCase().trim()
        .replaceAll('provinsi ', '')
        .replaceAll('prov. ', '');

    for (final p in provinces) {
      if (p.name.toLowerCase() == normalized) return p;
    }
    // Partial match
    for (final p in provinces) {
      if (p.name.toLowerCase().contains(normalized) ||
          normalized.contains(p.name.toLowerCase())) return p;
    }
    return null;
  }

  // === Private helpers ===

  String _buildProvincesUrl(ApiProviderConfig provider) {
    switch (provider.id) {
      case 'wilayah_id':
        return '${provider.baseUrl}/provinces.json';
      case 'emsifa_wilayah':
        return '${provider.baseUrl}/provinces.json';
      default:
        return '${provider.baseUrl}/provinces.json';
    }
  }

  String _buildRegenciesUrl(ApiProviderConfig provider, String provinceCode) {
    switch (provider.id) {
      case 'wilayah_id':
        return '${provider.baseUrl}/regencies/$provinceCode.json';
      case 'emsifa_wilayah':
        return '${provider.baseUrl}/regencies/$provinceCode.json';
      default:
        return '${provider.baseUrl}/regencies/$provinceCode.json';
    }
  }

  List<Province> _parseProvinces(dynamic data, String providerId) {
    List<dynamic> list;

    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      list = data['data'] as List<dynamic>? ?? [];
    } else {
      return [];
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map((item) {
          // Detect format berdasarkan field
          if (item.containsKey('code')) {
            return Province.fromWilayahId(item, providerId);
          } else {
            return Province.fromEmsifa(item, providerId);
          }
        })
        .where((p) => p.code.isNotEmpty && p.name.isNotEmpty)
        .toList();
  }

  List<Regency> _parseRegencies(dynamic data, String provinceCode, String providerId) {
    List<dynamic> list;

    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      list = data['data'] as List<dynamic>? ?? [];
    } else {
      return [];
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map((item) {
          if (item.containsKey('code')) {
            return Regency.fromWilayahId(item, provinceCode, providerId);
          } else {
            return Regency.fromEmsifa(item, providerId);
          }
        })
        .where((r) => r.code.isNotEmpty && r.name.isNotEmpty)
        .toList();
  }
}
