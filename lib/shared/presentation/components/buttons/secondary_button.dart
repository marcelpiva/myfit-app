import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';

/// Secondary button with outline style
/// Used for less prominent actions
class SecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;
  final bool fullWidth;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.fullWidth = true,
    this.icon,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.enabled && !widget.loading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final textColor = isDark ? AppColors.foregroundDark : AppColors.foreground;
    final pressedBg = isDark ? AppColors.cardDark : AppColors.card;

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
          color: _isPressed ? pressedBg : Colors.transparent,
          border: Border.all(
            color: _isEnabled ? borderColor : borderColor.withAlpha(128),
            width: 1,
          ),
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
                  color: textColor,
                ),
              )
            else ...[
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 20,
                  color: _isEnabled ? textColor : textColor.withAlpha(128),
                ),
                const SizedBox(width: 8),
              ],
              if (!widget.fullWidth) const SizedBox(width: 24),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _isEnabled ? textColor : textColor.withAlpha(128),
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
