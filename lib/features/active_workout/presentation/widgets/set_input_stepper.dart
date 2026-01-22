import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Stepper input widget for weight and reps with +/- buttons
class SetInputStepper extends StatefulWidget {
  final String label;
  final IconData icon;
  final double value;
  final double step;
  final double minValue;
  final double maxValue;
  final bool isDecimal;
  final String? hint;
  final ValueChanged<double> onChanged;
  final bool isDark;

  const SetInputStepper({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.minValue = 0,
    this.maxValue = 999,
    this.isDecimal = false,
    this.hint,
    this.isDark = false,
  });

  @override
  State<SetInputStepper> createState() => _SetInputStepperState();
}

class _SetInputStepperState extends State<SetInputStepper> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _parseAndUpdate();
      }
    });
  }

  @override
  void didUpdateWidget(SetInputStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _controller.text = _formatValue(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatValue(double value) {
    if (value == 0 && widget.hint != null) return '';
    if (widget.isDecimal) {
      return value.truncateToDouble() == value
          ? value.toInt().toString()
          : value.toStringAsFixed(1);
    }
    return value.toInt().toString();
  }

  void _parseAndUpdate() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      widget.onChanged(0);
      return;
    }
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    if (parsed != null) {
      final clamped = parsed.clamp(widget.minValue, widget.maxValue);
      widget.onChanged(clamped);
      _controller.text = _formatValue(clamped);
    }
  }

  void _increment() {
    HapticUtils.selectionClick();
    final current = double.tryParse(_controller.text.replaceAll(',', '.')) ?? widget.value;
    final newValue = (current + widget.step).clamp(widget.minValue, widget.maxValue);
    widget.onChanged(newValue);
    _controller.text = _formatValue(newValue);
  }

  void _decrement() {
    HapticUtils.selectionClick();
    final current = double.tryParse(_controller.text.replaceAll(',', '.')) ?? widget.value;
    final newValue = (current - widget.step).clamp(widget.minValue, widget.maxValue);
    widget.onChanged(newValue);
    _controller.text = _formatValue(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with icon
        Row(
          children: [
            Icon(
              widget.icon,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Stepper input
        Container(
          decoration: BoxDecoration(
            color: widget.isDark
                ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                : theme.colorScheme.surfaceContainerLow.withAlpha(200),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppColors.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Decrement button
              _StepperButton(
                icon: LucideIcons.minus,
                onTap: widget.value > widget.minValue ? _decrement : null,
                isDark: widget.isDark,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  bottomLeft: Radius.circular(11),
                ),
              ),

              // Text input
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: widget.isDecimal,
                  ),
                  inputFormatters: widget.isDecimal
                      ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))]
                      : [FilteringTextInputFormatter.digitsOnly],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _parseAndUpdate(),
                ),
              ),

              // Increment button
              _StepperButton(
                icon: LucideIcons.plus,
                onTap: widget.value < widget.maxValue ? _increment : null,
                isDark: widget.isDark,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(11),
                  bottomRight: Radius.circular(11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;
  final BorderRadius borderRadius;

  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.primary.withAlpha(20)
              : Colors.transparent,
          borderRadius: borderRadius,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isEnabled
              ? (isDark ? AppColors.primaryDark : AppColors.primary)
              : theme.colorScheme.onSurfaceVariant.withAlpha(80),
        ),
      ),
    );
  }
}

/// Quick preset buttons for common values
class QuickPresetRow extends StatelessWidget {
  final List<double> presets;
  final String suffix;
  final ValueChanged<double> onSelect;
  final double? currentValue;
  final bool isDark;

  const QuickPresetRow({
    super.key,
    required this.presets,
    required this.onSelect,
    this.suffix = '',
    this.currentValue,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((value) {
        final isSelected = currentValue == value;
        final displayValue = value.truncateToDouble() == value
            ? value.toInt().toString()
            : value.toStringAsFixed(1);

        return GestureDetector(
          onTap: () {
            HapticUtils.selectionClick();
            onSelect(value);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withAlpha(30)
                  : (isDark
                      ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                      : theme.colorScheme.surfaceContainerLow.withAlpha(200)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              '$displayValue$suffix',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
