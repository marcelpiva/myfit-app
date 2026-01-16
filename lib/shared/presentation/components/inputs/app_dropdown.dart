import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';

/// Modern dropdown selector matching web design
class AppDropdown<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? errorText;
  final bool enabled;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  bool _isOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
    setState(() => _isOpen = !_isOpen);
  }

  void _showOverlay() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Dropdown menu
          Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 4),
              child: Material(
                color: isDark ? AppColors.cardDark : AppColors.background,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.items.map((item) {
                        final isSelected = item.value == widget.value;
                        return InkWell(
                          onTap: () {
                            widget.onChanged?.call(item.value);
                            _toggleDropdown();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            color: isSelected
                                ? (isDark ? AppColors.mutedDark : AppColors.muted)
                                : null,
                            child: Row(
                              children: [
                                if (item.icon != null) ...[
                                  Icon(
                                    item.icon,
                                    size: 20,
                                    color: isDark
                                        ? AppColors.foregroundDark
                                        : AppColors.foreground,
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    size: 18,
                                    color: isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    // Find selected item
    final selectedItem = widget.items.where((item) => item.value == widget.value).firstOrNull;

    Color borderColor;
    if (hasError) {
      borderColor = AppColors.destructive;
    } else if (_isOpen) {
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
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                border: Border.all(
                  color: borderColor,
                  width: _isOpen ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  if (selectedItem?.icon != null) ...[
                    Icon(
                      selectedItem!.icon,
                      size: 20,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      selectedItem?.label ?? widget.hint ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedItem != null
                            ? (isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground)
                            : (isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
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

class AppDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const AppDropdownItem({
    required this.value,
    required this.label,
    this.icon,
  });
}
