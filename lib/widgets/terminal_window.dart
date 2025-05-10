import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/screen_utils.dart';
import 'flexible_text.dart';

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
    // Pastikan ScreenUtils diinisialisasi
    if (ScreenUtils.screenWidth == 0) {
      ScreenUtils.init(context);
    }
    
    // Adaptasi berdasarkan ukuran layar dengan nilai default yang aman
    final bool isMobile = ScreenUtils.isMobileScreen();
    final double headerHeight = isMobile ? 28.0 : 32.0;
    final double buttonSize = isMobile ? 8.0 : 12.0;
    final double buttonSpacing = isMobile ? 2.0 : 4.0;
    final double margin = isMobile ? 4.0 : 8.0;
    
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
      margin: EdgeInsets.all(margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTerminalHeader(headerHeight, buttonSize, buttonSpacing),
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

  Widget _buildTerminalHeader(double height, double buttonSize, double buttonSpacing) {
    return Container(
      height: height,
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
          SizedBox(width: buttonSpacing * 2),
          _buildWindowButton(HackerColors.error, buttonSize),
          SizedBox(width: buttonSpacing),
          _buildWindowButton(HackerColors.warning, buttonSize),
          SizedBox(width: buttonSpacing),
          _buildWindowButton(HackerColors.success, buttonSize),
          SizedBox(width: buttonSpacing * 2),
          Expanded(
            child: Center(
              child: FlexibleText(
                title,
                style: TextStyle(
                  color: HackerColors.accent,
                  fontFamily: 'Courier',
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
          ),
          if (actions != null) ...actions!,
          SizedBox(width: buttonSpacing * 2),
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