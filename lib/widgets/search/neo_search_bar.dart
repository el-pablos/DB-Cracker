import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';

class NeoSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final bool isLoading;

  const NeoSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Cari mahasiswa, dosen, atau prodi...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.isLoading = false,
  });

  @override
  State<NeoSearchBar> createState() => _NeoSearchBarState();
}

class _NeoSearchBarState extends State<NeoSearchBar> {
  late final TextEditingController _controller;
  bool _hasText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final has = _controller.text.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppSpacing.durationFast,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: _isFocused ? AppColors.primary : AppColors.border,
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused ? AppSpacing.shadowGlow : AppSpacing.shadowNone,
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(
            Icons.search_rounded,
            size: 20,
            color: _isFocused ? AppColors.primary : AppColors.textTertiary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Focus(
              onFocusChange: (f) => setState(() => _isFocused = f),
              child: TextField(
                controller: _controller,
                autofocus: widget.autofocus,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          if (widget.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            )
          else if (_hasText)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppColors.textTertiary,
              onPressed: () {
                _controller.clear();
                widget.onClear?.call();
              },
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}
