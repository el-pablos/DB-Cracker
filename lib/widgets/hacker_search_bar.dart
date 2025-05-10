import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/screen_utils.dart';
import 'flexible_text.dart';

class HackerSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSearch;

  const HackerSearchBar({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Adaptasi berdasarkan ukuran layar
    final bool isMobile = ScreenUtils.isMobileScreen();
    
    return Container(
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: HackerColors.accent, width: 1),
        boxShadow: [
          BoxShadow(
            color: HackerColors.primary.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: ScreenUtils.responsivePadding(
              horizontal: 8, 
              vertical: isMobile ? 3 : 4
            ),
            decoration: BoxDecoration(
              color: HackerColors.surface.withOpacity(0.8),
              border: const Border(
                bottom: BorderSide(
                  color: HackerColors.accent,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: HackerColors.accent,
                  size: 14.iconSize,
                ),
                SizedBox(width: 4.w),
                FlexibleText(
                  "TARGET LOCATOR",
                  style: TextStyle(
                    color: HackerColors.accent,
                    fontSize: 12.adaptiveFont,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: TextStyle(
                      color: HackerColors.primary,
                      fontFamily: 'Courier',
                      fontSize: 14.adaptiveFont,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: HackerColors.text.withOpacity(0.5),
                        fontFamily: 'Courier',
                        fontSize: 12.adaptiveFont,
                      ),
                      contentPadding: ScreenUtils.responsivePadding(
                        horizontal: 16, 
                        vertical: 14
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      prefixIcon: Padding(
                        padding: ScreenUtils.responsivePadding(horizontal: 12),
                        child: Text(
                          ">",
                          style: TextStyle(
                            color: HackerColors.primary,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.bold,
                            fontSize: 16.adaptiveFont,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    cursorColor: HackerColors.primary,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSearch(),
                  ),
                ),
                Container(
                  height: 48.h,
                  width: 1,
                  color: HackerColors.accent.withOpacity(0.5),
                  margin: ScreenUtils.responsivePadding(vertical: 4),
                ),
                InkWell(
                  onTap: onSearch,
                  child: Container(
                    padding: ScreenUtils.responsivePadding(horizontal: isMobile ? 12 : 16),
                    height: 56.h,
                    decoration: const BoxDecoration(
                      color: HackerColors.surface,
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "HACK",
                          style: TextStyle(
                            color: HackerColors.primary,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                            fontSize: 14.adaptiveFont,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}