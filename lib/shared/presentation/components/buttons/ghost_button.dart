import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';

/// Ghost button - text only, no background
/// Used for tertiary actions
class GhostButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool fullWidth;
  final IconData? icon;
  final bool underline;

  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.fullWidth = false,
    this.icon,
    this.underline = false,
  });

  @override
  State<GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<GhostButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.enabled && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? AppColors.foregroundDark : AppColors.foreground;

    return GestureDetector(
      onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: _isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: AppAnimations.instant,
        curve: AppAnimations.easeOut,
        height: 56,
        transform: Matrix4.diagonal3Values(
          _isPressed ? AppAnimations.tapScale : 1.0,
          _isPressed ? AppAnimations.tapScale : 1.0,
          1.0,
        ),
        transformAlignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 20,
                color: _isEnabled
                    ? (_isPressed ? textColor.withAlpha(179) : textColor)
                    : textColor.withAlpha(128),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _isEnabled
                    ? (_isPressed ? textColor.withAlpha(179) : textColor)
                    : textColor.withAlpha(128),
                decoration: widget.underline ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
