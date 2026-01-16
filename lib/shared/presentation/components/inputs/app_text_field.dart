import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

/// A styled text field that follows the myfitplatform design system.
///
/// Features:
/// - Zero border radius (angular design)
/// - Border changes color on focus
/// - Label above the input
/// - Error state support
/// - Suffix widget support
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;
  final Widget? prefix;
  final int maxLines;
  final int? minLines;
  final int? maxLength;

  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
    this.suffix,
    this.prefix,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    // Border color based on state
    Color borderColor;
    if (hasError) {
      borderColor = AppColors.destructive;
    } else if (_hasFocus) {
      borderColor = isDark ? AppColors.foregroundDark : AppColors.foreground;
    } else {
      borderColor = isDark ? AppColors.borderDark : AppColors.border;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: hasError
                  ? AppColors.destructive
                  : (isDark ? AppColors.foregroundDark : AppColors.foreground),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          height: widget.maxLines == 1 ? 52 : null,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.card,
            border: Border.all(
              color: borderColor,
              width: _hasFocus ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            style: TextStyle(
              fontSize: 16,
              color: widget.enabled
                  ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                  : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: widget.prefix != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: widget.prefix,
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              suffixIcon: widget.suffix != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: widget.suffix,
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              counterText: '',
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.destructive,
            ),
          ),
        ],
      ],
    );
  }
}
