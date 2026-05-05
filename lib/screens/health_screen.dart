import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api/health/health_service.dart';
import '../api/core/provider_registry.dart';
import '../api/cache/in_memory_cache_store.dart';
import '../api/cache/cache_store.dart';
import '../utils/constants.dart';

/// Health Dashboard Screen — status semua provider dan cache
/// Tema ctOS: terminal-style monitoring dashboard
class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  AppHealthReport? _report;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runHealthCheck();
  }

  Future<void> _runHealthCheck() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      final service = HealthService(
        httpClient: http.Client(),
        cacheStore: InMemoryCacheStore(), // Shared instance ideally via DI
      );
      final report = await service.checkAll();
      if (mounted) {
        setState(() { _report = report; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _error = e.toString(); _isLoading = false; });
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
            Icon(Icons.monitor_heart, color: CtOSColors.primary, size: 18),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'STATUS SISTEM',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  color: CtOSColors.primary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: CtOSColors.primary),
            onPressed: _isLoading ? null : _runHealthCheck,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: CtOSColors.primary),
            SizedBox(height: 16),
            Text(
              'SCANNING PROVIDERS...',
              style: TextStyle(
                color: CtOSColors.primary,
                fontFamily: 'Courier',
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: CtOSColors.error, size: 48),
            const SizedBox(height: 16),
            Text('Error: $_error', style: const TextStyle(color: CtOSColors.error, fontFamily: 'Courier', fontSize: 12)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _runHealthCheck, child: const Text('RETRY')),
          ],
        ),
      );
    }

    if (_report == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        _buildSummaryCard(),
        const SizedBox(height: 16),
        // Provider list
        const Text('PROVIDERS', style: TextStyle(color: CtOSColors.primary, fontFamily: 'Courier', fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._report!.providers.map(_buildProviderTile),
        const SizedBox(height: 16),
        // Cache stats
        _buildCacheCard(),
        const SizedBox(height: 16),
        // App info
        _buildAppInfoCard(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final r = _report!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CtOSColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CtOSColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('HEALTHY', r.healthyCount.toString(), CtOSColors.success),
          _buildStatColumn('DEGRADED', r.degradedCount.toString(), CtOSColors.warning),
          _buildStatColumn('DOWN', r.unavailableCount.toString(), CtOSColors.error),
          _buildStatColumn('TOTAL', r.providers.length.toString(), CtOSColors.textPrimary),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontFamily: 'Courier', fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontFamily: 'Courier', fontSize: 10)),
      ],
    );
  }

  Widget _buildProviderTile(ProviderHealthResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CtOSColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _statusColor(result.status).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _statusColor(result.status)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.providerName, style: const TextStyle(color: CtOSColors.textPrimary, fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  '${result.kind.name.toUpperCase()} • ${result.status.name} ${result.latency != null ? "• ${result.latency!.inMilliseconds}ms" : ""}',
                  style: TextStyle(color: CtOSColors.textPrimary.withValues(alpha: 0.6), fontFamily: 'Courier', fontSize: 10),
                ),
                if (result.message != null)
                  Text(result.message!, style: TextStyle(color: CtOSColors.textPrimary.withValues(alpha: 0.4), fontFamily: 'Courier', fontSize: 9)),
              ],
            ),
          ),
          Text(
            result.status.name.toUpperCase(),
            style: TextStyle(color: _statusColor(result.status), fontFamily: 'Courier', fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheCard() {
    final stats = _report!.cacheStats;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CtOSColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CtOSColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CACHE STATUS', style: TextStyle(color: CtOSColors.secondary, fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildCacheRow('Total Entries', stats.totalEntries.toString()),
          _buildCacheRow('Fresh', stats.freshEntries.toString()),
          _buildCacheRow('Stale', stats.staleEntries.toString()),
          _buildCacheRow('Expired', stats.expiredEntries.toString()),
        ],
      ),
    );
  }

  Widget _buildCacheRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: CtOSColors.textPrimary.withValues(alpha: 0.7), fontFamily: 'Courier', fontSize: 11)),
          Text(value, style: const TextStyle(color: CtOSColors.primary, fontFamily: 'Courier', fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CtOSColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('APP INFO', style: TextStyle(color: CtOSColors.textPrimary, fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildCacheRow('Version', _report!.appVersion),
          _buildCacheRow('Last Check', _report!.generatedAt.toString().substring(0, 19)),
          _buildCacheRow('Providers', _report!.providers.length.toString()),
        ],
      ),
    );
  }

  Color _statusColor(ProviderStatus status) {
    switch (status) {
      case ProviderStatus.healthy:
        return CtOSColors.success;
      case ProviderStatus.degraded:
      case ProviderStatus.rateLimited:
        return CtOSColors.warning;
      case ProviderStatus.unavailable:
      case ProviderStatus.malformed:
      case ProviderStatus.timeout:
        return CtOSColors.error;
      case ProviderStatus.unknown:
        return CtOSColors.secondary;
    }
  }
}
