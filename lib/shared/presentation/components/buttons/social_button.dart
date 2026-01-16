import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../config/theme/tokens/animations.dart';

/// Social login button following platform branding guidelines
/// Google: https://developers.google.com/identity/branding-guidelines
/// Apple: https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple
class SocialButton extends StatefulWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool loading;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final EdgeInsets padding;

  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.loading = false,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  /// Google Sign-In button following branding guidelines
  /// Light theme: #FFFFFF fill, #747775 stroke (1px), #1F1F1F text
  /// Font: Roboto Medium 14/20
  /// Padding: 12px left, 10px after logo, 12px right
  factory SocialButton.google({
    Key? key,
    required String label,
    VoidCallback? onTap,
    bool enabled = true,
    bool loading = false,
  }) {
    return SocialButton(
      key: key,
      icon: SvgPicture.asset(
        'assets/icons/google_logo.svg',
        width: 20,
        height: 20,
      ),
      label: label,
      onTap: onTap,
      enabled: enabled,
      loading: loading,
      backgroundColor: const Color(0xFFFFFFFF),
      foregroundColor: const Color(0xFF1F1F1F),
      borderColor: const Color(0xFF747775),
      padding: const EdgeInsets.only(left: 12, right: 12),
    );
  }

  /// Apple Sign-In button following HIG
  /// Black background, white text/logo, no border radius
  factory SocialButton.apple({
    Key? key,
    required String label,
    VoidCallback? onTap,
    bool enabled = true,
    bool loading = false,
  }) {
    return SocialButton(
      key: key,
      icon: const Icon(Icons.apple, size: 24, color: Colors.white),
      label: label,
      onTap: onTap,
      enabled: enabled,
      loading: loading,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      borderColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.enabled && !widget.loading && widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: _isEnabled ? widget.onTap : null,
      child: AnimatedContainer(
        duration: AppAnimations.instant,
        curve: AppAnimations.easeOut,
        height: 52,
        transform: Matrix4.diagonal3Values(
          _isPressed ? AppAnimations.pressedScale : 1.0,
          _isPressed ? AppAnimations.pressedScale : 1.0,
          1.0,
        ),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isPressed
              ? widget.backgroundColor.withAlpha(240)
              : widget.backgroundColor,
          border: Border.all(
            color: widget.borderColor,
            width: 1,
          ),
        ),
        padding: widget.padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.loading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.foregroundColor,
                ),
              )
            else ...[
              widget.icon,
              const SizedBox(width: 10), // Google spec: 10px after logo
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500, // Roboto Medium
                  color: widget.foregroundColor,
                  height: 20 / 14, // 14/20 line height
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
