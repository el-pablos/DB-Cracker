import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget untuk menampilkan filter dropdown untuk universitas
class FilterBar extends StatelessWidget {
  final List<String> universities;
  final String? selectedUniversity;
  final Function(String?) onChanged;
  final VoidCallback onClear;

  const FilterBar({
    Key? key,
    required this.universities,
    required this.selectedUniversity,
    required this.onChanged,
    required this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: HackerColors.warning, width: 1),
        boxShadow: [
          BoxShadow(
            color: HackerColors.warning.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
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
                  color: HackerColors.warning,
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
                  AppStrings.filterTitle,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: HackerColors.background,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: HackerColors.warning.withOpacity(0.5),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedUniversity,
                        hint: Text(
                          AppStrings.selectUniversity,
                          style: const TextStyle(
                            color: HackerColors.text,
                            fontFamily: 'Courier',
                            fontSize: 12,
                          ),
                        ),
                        dropdownColor: HackerColors.surface,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: HackerColors.warning,
                        ),
                        isExpanded: true,
                        style: const TextStyle(
                          color: HackerColors.warning,
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                        onChanged: onChanged,
                        items: universities.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                color: HackerColors.warning,
                                fontFamily: 'Courier',
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onClear,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: HackerColors.background,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: HackerColors.warning.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      AppStrings.reset,
                      style: const TextStyle(
                        color: HackerColors.warning,
                        fontFamily: 'Courier',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Indicator jumlah hasil
          if (selectedUniversity != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
              child: Text(
                "UNIVERSITAS: $selectedUniversity",
                style: const TextStyle(
                  color: HackerColors.warning,
                  fontFamily: 'Courier',
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}