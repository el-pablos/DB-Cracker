import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class NeoDataRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool isCode;
  final bool copyable;

  const NeoDataRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.isCode = false,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 10),
          ],
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: isCode ? AppTypography.codeMedium : AppTypography.bodyMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
          if (copyable && value.isNotEmpty)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Disalin: $value'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.copy_rounded, size: 14, color: AppColors.textTertiary),
              ),
            ),
        ],
      ),
    );
  }
}
