import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

/// A password text field with visibility toggle.
///
/// Features:
/// - Zero border radius (angular design)
/// - Toggle visibility icon
/// - Secure text entry by default
/// - Border changes color on focus
class AppPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool enabled;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AppPasswordField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  late FocusNode _focusNode;
  bool _obscureText = true;
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

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
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
          height: 52,
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
            obscureText: _obscureText,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: TextStyle(
              fontSize: 16,
              color: widget.enabled
                  ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                  : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
            ),
            decoration: InputDecoration(
              hintText: widget.hint ?? '••••••••',
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
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: _toggleVisibility,
                  child: Icon(
                    _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 20,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
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
