import 'package:flutter/material.dart';
import '../api/core/data_result.dart';
import '../utils/constants.dart';

/// Badge kecil yang menampilkan sumber data (live/cache/stale/external)
/// Sesuai tema ctOS — compact dan informatif
class SourceBadge extends StatelessWidget {
  final DataSourceType sourceType;
  final String? providerName;
  final bool compact;

  const SourceBadge({
    super.key,
    required this.sourceType,
    this.providerName,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _borderColor, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: compact ? 10 : 12, color: _textColor),
          SizedBox(width: compact ? 3 : 4),
          Text(
            _label,
            style: TextStyle(
              color: _textColor,
              fontSize: compact ? 9 : 10,
              fontFamily: 'Courier',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String get _label {
    switch (sourceType) {
      case DataSourceType.live:
        return compact ? 'LIVE' : 'LIVE${providerName != null ? " • $providerName" : ""}';
      case DataSourceType.memoryCache:
        return 'CACHE';
      case DataSourceType.persistentCache:
        return 'SAVED';
      case DataSourceType.staleCache:
        return compact ? 'STALE' : 'STALE CACHE';
      case DataSourceType.mock:
        return 'DEMO';
      case DataSourceType.externalLink:
        return compact ? 'LINK' : 'EXTERNAL';
      case DataSourceType.unavailable:
        return 'N/A';
    }
  }

  IconData get _icon {
    switch (sourceType) {
      case DataSourceType.live:
        return Icons.cloud_done;
      case DataSourceType.memoryCache:
      case DataSourceType.persistentCache:
        return Icons.storage;
      case DataSourceType.staleCache:
        return Icons.history;
      case DataSourceType.mock:
        return Icons.science;
      case DataSourceType.externalLink:
        return Icons.open_in_new;
      case DataSourceType.unavailable:
        return Icons.cloud_off;
    }
  }

  Color get _textColor {
    switch (sourceType) {
      case DataSourceType.live:
        return CtOSColors.primary;
      case DataSourceType.memoryCache:
      case DataSourceType.persistentCache:
        return CtOSColors.secondary;
      case DataSourceType.staleCache:
        return CtOSColors.warning;
      case DataSourceType.mock:
        return CtOSColors.error;
      case DataSourceType.externalLink:
        return CtOSColors.textPrimary;
      case DataSourceType.unavailable:
        return CtOSColors.error;
    }
  }

  Color get _backgroundColor => _textColor.withValues(alpha: 0.1);
  Color get _borderColor => _textColor.withValues(alpha: 0.3);
}
