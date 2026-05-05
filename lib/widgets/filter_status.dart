import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget untuk menampilkan informasi status filter yang sedang aktif
class FilterStatus extends StatelessWidget {
  final String university;
  final int count;
  final VoidCallback onClear;

  const FilterStatus({
    Key? key,
    required this.university,
    required this.count,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: CtOSColors.background,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: CtOSColors.warning.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt,
            color: CtOSColors.warning,
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FILTER AKTIF: $university',
                  style: const TextStyle(
                    color: CtOSColors.warning,
                    fontFamily: 'Courier',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'HASIL: $count MAHASISWA',
                  style: const TextStyle(
                    color: CtOSColors.textPrimary,
                    fontFamily: 'Courier',
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: CtOSColors.surface,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Icon(
                Icons.close,
                color: CtOSColors.warning,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}