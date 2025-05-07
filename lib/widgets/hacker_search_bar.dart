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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              children: const [
                Icon(
                  Icons.search,
                  color: HackerColors.accent,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  "TARGET LOCATOR",
                  style: TextStyle(
                    color: HackerColors.accent,
                    fontSize: 12,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: HackerColors.primary,
                    fontFamily: 'Courier',
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: HackerColors.text.withOpacity(0.5),
                      fontFamily: 'Courier',
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        ">",
                        style: TextStyle(
                          color: HackerColors.primary,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.bold,
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
                height: 48,
                width: 1,
                color: HackerColors.accent.withOpacity(0.5),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
              InkWell(
                onTap: onSearch,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 56,
                  decoration: const BoxDecoration(
                    color: HackerColors.surface,
                  ),
                  child: const Center(
                    child: Text(
                      "HACK",
                      style: TextStyle(
                        color: HackerColors.primary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}