import 'package:flutter/material.dart';
import '../utils/constants.dart';

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
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;
    
    return Container(
      decoration: BoxDecoration(
        color: CtOSColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: CtOSColors.secondary, width: 1),
        boxShadow: [
          BoxShadow(
            color: CtOSColors.primary.withOpacity(0.3),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 8, 
              vertical: 4
            ),
            decoration: BoxDecoration(
              color: CtOSColors.surface.withOpacity(0.8),
              border: const Border(
                bottom: BorderSide(
                  color: CtOSColors.secondary,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.search,
                  color: CtOSColors.secondary,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  "TARGET LOCATOR",
                  style: TextStyle(
                    color: CtOSColors.secondary,
                    fontSize: 12,
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
                    style: const TextStyle(
                      color: CtOSColors.primary,
                      fontFamily: 'Courier',
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: CtOSColors.textPrimary.withOpacity(0.5),
                        fontFamily: 'Courier',
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, 
                        vertical: 14
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          ">",
                          style: TextStyle(
                            color: CtOSColors.primary,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    cursorColor: CtOSColors.primary,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSearch(),
                  ),
                ),
                Container(
                  height: 48,
                  width: 1,
                  color: CtOSColors.secondary.withOpacity(0.5),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
                InkWell(
                  onTap: onSearch,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
                    height: 56,
                    decoration: const BoxDecoration(
                      color: CtOSColors.surface,
                    ),
                    child: const Center(
                      child: Text(
                        "HACK",
                        style: TextStyle(
                          color: CtOSColors.primary,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                          fontSize: 14,
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