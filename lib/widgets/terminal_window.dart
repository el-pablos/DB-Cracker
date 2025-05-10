import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TerminalWindow extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final bool scrollable;

  const TerminalWindow({
    Key? key,
    required this.child,
    required this.title,
    this.actions,
    this.scrollable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Gunakan ukuran tetap untuk mencegah error layout
    const double headerHeight = 32.0; 
    const double buttonSize = 10.0;
    const double buttonSpacing = 4.0;
    const double margin = 8.0;
    
    return Container(
      decoration: BoxDecoration(
        color: HackerColors.background,
        border: Border.all(
          color: HackerColors.accent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: HackerColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.all(margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: headerHeight,
            decoration: const BoxDecoration(
              color: HackerColors.surface,
              border: Border(
                bottom: BorderSide(
                  color: HackerColors.accent,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: buttonSpacing * 2),
                _buildWindowButton(HackerColors.error, buttonSize),
                const SizedBox(width: buttonSpacing),
                _buildWindowButton(HackerColors.warning, buttonSize),
                const SizedBox(width: buttonSpacing),
                _buildWindowButton(HackerColors.success, buttonSize),
                const SizedBox(width: buttonSpacing * 2),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: HackerColors.accent,
                        fontFamily: 'Courier',
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (actions != null) ...actions!,
                const SizedBox(width: buttonSpacing * 2),
              ],
            ),
          ),
          Expanded(
            child: scrollable 
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: child,
                  )
                : child,
          ),
        ],
      ),
    );
  }

  Widget _buildWindowButton(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.7),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
    );
  }
}