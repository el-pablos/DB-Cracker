import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TerminalWindow extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const TerminalWindow({
    Key? key,
    required this.child,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTerminalHeader(),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildTerminalHeader() {
    return Container(
      height: 32,
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
          const SizedBox(width: 8),
          _buildWindowButton(HackerColors.error),
          const SizedBox(width: 4),
          _buildWindowButton(HackerColors.warning),
          const SizedBox(width: 4),
          _buildWindowButton(HackerColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: HackerColors.accent,
                  fontFamily: 'Courier',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (actions != null) ...actions!,
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildWindowButton(Color color) {
    return Container(
      width: 12,
      height: 12,
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