import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget search bar untuk filter universitas
class FilterSearchBar extends StatefulWidget {
  final List<String> universities;
  final String? selectedUniversity;
  final Function(String?) onFilter;
  final VoidCallback onClear;
  final TextEditingController controller;

  const FilterSearchBar({
    Key? key,
    required this.universities,
    required this.selectedUniversity,
    required this.onFilter,
    required this.onClear,
    required this.controller,
  }) : super(key: key);

  @override
  _FilterSearchBarState createState() => _FilterSearchBarState();
}

class _FilterSearchBarState extends State<FilterSearchBar> {
  List<String> _filteredUniversities = [];
  bool _showSuggestions = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _filteredUniversities = widget.universities;
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showSuggestions = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(FilterSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.universities != widget.universities) {
      _filteredUniversities = widget.universities;
    }
  }

  void _filterUniversities(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredUniversities = widget.universities;
      });
      return;
    }

    setState(() {
      _filteredUniversities = widget.universities
          .where((university) => 
              university.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _showSuggestions = true;
    });
  }

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
          // Header
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
          
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: HackerColors.background,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: HackerColors.warning.withOpacity(0.5),
                      ),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: HackerColors.warning,
                        fontFamily: 'Courier',
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        hintText: AppStrings.filterHint,
                        hintStyle: TextStyle(
                          color: HackerColors.text.withOpacity(0.5),
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, 
                          vertical: 10
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.search,
                            color: HackerColors.warning,
                            size: 14,
                          ),
                        ),
                        suffixIcon: widget.controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: HackerColors.warning,
                                size: 14,
                              ),
                              onPressed: () {
                                widget.controller.clear();
                                _filterUniversities('');
                              },
                            )
                          : null,
                      ),
                      onChanged: _filterUniversities,
                      onSubmitted: (value) {
                        if (value.isNotEmpty && _filteredUniversities.isNotEmpty) {
                          widget.onFilter(_filteredUniversities.first);
                          setState(() {
                            _showSuggestions = false;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    widget.onClear();
                    widget.controller.clear();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: HackerColors.background,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: HackerColors.warning.withOpacity(0.5),
                      ),
                    ),
                    child: const Text(
                      AppStrings.reset,
                      style: TextStyle(
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
          
          // Suggestions dropdown
          if (_showSuggestions && _filteredUniversities.isNotEmpty && _focusNode.hasFocus)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              decoration: BoxDecoration(
                color: HackerColors.surface,
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: HackerColors.warning.withOpacity(0.5),
                ),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _filteredUniversities.length,
                itemBuilder: (context, index) {
                  final university = _filteredUniversities[index];
                  final isSelected = university == widget.selectedUniversity;
                  
                  return InkWell(
                    onTap: () {
                      widget.controller.text = university;
                      widget.onFilter(university);
                      setState(() {
                        _showSuggestions = false;
                      });
                      _focusNode.unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? HackerColors.warning.withOpacity(0.2)
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: HackerColors.warning.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Text(
                        university,
                        style: TextStyle(
                          color: HackerColors.warning,
                          fontFamily: 'Courier',
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // Indicator of current filter
          if (widget.selectedUniversity != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
              child: Text(
                "UNIVERSITAS: ${widget.selectedUniversity}",
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
  
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}