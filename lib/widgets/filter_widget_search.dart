import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FilterSearchWidget extends StatelessWidget {
  final TextEditingController ptFilterController;
  final String hintText;
  final VoidCallback onClearFilter;
  final bool isFilterActive;

  const FilterSearchWidget({
    Key? key,
    required this.ptFilterController,
    required this.hintText,
    required this.onClearFilter,
    required this.isFilterActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: HackerColors.accent, width: 1),
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
                  Icons.filter_list,
                  color: HackerColors.warning,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  "FILTER UNIVERSITAS",
                  style: TextStyle(
                    color: HackerColors.warning,
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
                  controller: ptFilterController,
                  style: const TextStyle(
                    color: HackerColors.warning,
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
                          color: HackerColors.warning,
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                  cursorColor: HackerColors.warning,
                ),
              ),
              if (isFilterActive) 
                InkWell(
                  onTap: onClearFilter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 48,
                    decoration: const BoxDecoration(
                      color: HackerColors.surface,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.clear,
                        color: HackerColors.warning,
                        size: 20,
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