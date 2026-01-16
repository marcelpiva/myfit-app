import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../config/theme/tokens/shadows.dart';

/// Primary CTA button with modern animations
/// Matches web design: scale on tap, shadow glow on hover
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;
  final bool fullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.fullWidth = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  bool get _isEnabled => widget.enabled && !widget.loading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = widget.backgroundColor ??
        (isDark ? AppColors.foregroundDark : AppColors.foreground);
    final fgColor = widget.foregroundColor ??
        (isDark ? AppColors.backgroundDark : AppColors.background);

    return GestureDetector(
      onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: _isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: AppAnimations.instant,
        curve: AppAnimations.easeOut,
        width: widget.fullWidth ? double.infinity : null,
        height: 56,
        transform: Matrix4.diagonal3Values(
          _isPressed ? AppAnimations.tapScale : 1.0,
          _isPressed ? AppAnimations.tapScale : 1.0,
          1.0,
        ),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isEnabled ? bgColor : bgColor.withAlpha(128),
          boxShadow: _isPressed ? AppShadows.md : AppShadows.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (widget.loading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fgColor,
                ),
              )
            else ...[
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: fgColor),
                const SizedBox(width: 8),
              ],
              if (!widget.fullWidth) const SizedBox(width: 24),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
              ),
              if (!widget.fullWidth) const SizedBox(width: 24),
            ],
          ],
        ),
      ),
    );
  }
}
