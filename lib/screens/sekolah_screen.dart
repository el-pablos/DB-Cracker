import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api/sekolah/sekolah_service.dart';
import '../api/sekolah/sekolah_models.dart';
import '../api/cache/in_memory_cache_store.dart';
import '../utils/constants.dart';
import '../widgets/source_badge.dart';
import '../api/core/data_result.dart';

/// Screen pencarian sekolah berdasarkan NPSN
/// Tema ctOS — terminal style lookup
class SekolahLookupScreen extends StatefulWidget {
  const SekolahLookupScreen({super.key});

  @override
  State<SekolahLookupScreen> createState() => _SekolahLookupScreenState();
}

class _SekolahLookupScreenState extends State<SekolahLookupScreen> {
  final _npsnController = TextEditingController();
  Sekolah? _result;
  bool _isLoading = false;
  String? _error;
  DataSourceType _sourceType = DataSourceType.unavailable;

  Future<void> _lookup() async {
    final npsn = _npsnController.text.trim();
    if (npsn.isEmpty || npsn.length < 6) {
      setState(() => _error = 'NPSN harus minimal 6 digit angka');
      return;
    }
    if (!RegExp(r'^\d+$').hasMatch(npsn)) {
      setState(() => _error = 'NPSN harus berupa angka');
      return;
    }

    setState(() { _isLoading = true; _error = null; _result = null; });

    try {
      final service = SekolahService(
        httpClient: http.Client(),
        cacheStore: InMemoryCacheStore(),
      );
      final result = await service.lookupByNpsn(npsn);
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
          _sourceType = result != null ? DataSourceType.live : DataSourceType.unavailable;
          if (result == null) _error = 'Sekolah dengan NPSN "$npsn" tidak ditemukan';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoading = false; _error = 'Error: $e'; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CtOSColors.background,
      appBar: AppBar(
        backgroundColor: CtOSColors.surface,
        title: const Row(
          children: [
            Icon(Icons.school, color: CtOSColors.primary, size: 18),
            SizedBox(width: 8),
            Flexible(
              child: Text('NPSN LOOKUP', style: TextStyle(
                fontFamily: 'Courier', fontWeight: FontWeight.bold,
                color: CtOSColors.primary, fontSize: 14,
              ), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input NPSN
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CtOSColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CtOSColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MASUKKAN NPSN', style: TextStyle(
                    color: CtOSColors.primary, fontFamily: 'Courier',
                    fontSize: 12, fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _npsnController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: CtOSColors.primary, fontFamily: 'Courier'),
                          decoration: const InputDecoration(
                            hintText: 'contoh: 69952935',
                            hintStyle: TextStyle(color: CtOSColors.secondary),
                            border: InputBorder.none,
                            prefixText: '> ',
                            prefixStyle: TextStyle(color: CtOSColors.primary, fontWeight: FontWeight.bold),
                          ),
                          onSubmitted: (_) => _lookup(),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _lookup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CtOSColors.primary,
                          foregroundColor: CtOSColors.background,
                        ),
                        child: const Text('SCAN', style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Result area
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: CtOSColors.primary))
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CtOSColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CtOSColors.error.withValues(alpha: 0.3)),
                ),
                child: Text(_error!, style: const TextStyle(
                  color: CtOSColors.error, fontFamily: 'Courier', fontSize: 12,
                )),
              )
            else if (_result != null)
              Expanded(child: _buildResult(_result!)),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(Sekolah sekolah) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CtOSColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CtOSColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('DATA SEKOLAH', style: TextStyle(
                    color: CtOSColors.primary, fontFamily: 'Courier',
                    fontSize: 14, fontWeight: FontWeight.bold,
                  )),
                ),
                SourceBadge(sourceType: _sourceType, compact: true),
              ],
            ),
            const Divider(color: CtOSColors.secondary),
            const SizedBox(height: 8),
            _row('NPSN', sekolah.npsn),
            _row('Nama', sekolah.nama),
            _row('Bentuk', sekolah.bentukPendidikan),
            _row('Status', sekolah.statusSekolah),
            _row('Alamat', sekolah.alamat),
            _row('Provinsi', sekolah.provinsi),
            _row('Kab/Kota', sekolah.kabupatenKota),
            _row('Kecamatan', sekolah.kecamatan),
            _row('Kelurahan', sekolah.kelurahan),
            if (sekolah.lintang.isNotEmpty) _row('Koordinat', '${sekolah.lintang}, ${sekolah.bujur}'),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text('$label:', style: TextStyle(
              color: CtOSColors.secondary, fontFamily: 'Courier', fontSize: 11,
            )),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(
              color: CtOSColors.textPrimary, fontFamily: 'Courier', fontSize: 12,
            )),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _npsnController.dispose();
    super.dispose();
  }
}
