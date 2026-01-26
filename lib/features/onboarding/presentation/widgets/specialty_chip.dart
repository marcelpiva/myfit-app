import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Data class for specialty options
class SpecialtyOption {
  final String id;
  final String label;
  final IconData icon;

  const SpecialtyOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// Predefined specialty options with icons
class SpecialtyOptions {
  static const List<SpecialtyOption> all = [
    SpecialtyOption(id: 'musculacao', label: 'Musculação', icon: LucideIcons.dumbbell),
    SpecialtyOption(id: 'funcional', label: 'Funcional', icon: LucideIcons.activity),
    SpecialtyOption(id: 'hiit', label: 'HIIT', icon: LucideIcons.zap),
    SpecialtyOption(id: 'crossfit', label: 'Crossfit', icon: LucideIcons.flame),
    SpecialtyOption(id: 'pilates', label: 'Pilates', icon: LucideIcons.heart),
    SpecialtyOption(id: 'yoga', label: 'Yoga', icon: LucideIcons.sparkles),
    SpecialtyOption(id: 'corrida', label: 'Corrida', icon: LucideIcons.footprints),
    SpecialtyOption(id: 'natacao', label: 'Natação', icon: LucideIcons.waves),
    SpecialtyOption(id: 'artes_marciais', label: 'Artes Marciais', icon: LucideIcons.swords),
    SpecialtyOption(id: 'reabilitacao', label: 'Reabilitação', icon: LucideIcons.stethoscope),
    SpecialtyOption(id: 'esportes', label: 'Esportes', icon: LucideIcons.trophy),
    SpecialtyOption(id: 'idosos', label: 'Idosos', icon: LucideIcons.users),
  ];

  static SpecialtyOption? getById(String id) {
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// A chip widget for selecting specialties with icon
class SpecialtyChip extends StatelessWidget {
  final SpecialtyOption specialty;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool enabled;

  const SpecialtyChip({
    super.key,
    required this.specialty,
    required this.isSelected,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: enabled
          ? () {
              HapticUtils.selectionClick();
              onTap?.call();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : AppColors.card),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(30),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              specialty.icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.foregroundDark : AppColors.foreground),
            ),
            const SizedBox(width: 8),
            Text(
              specialty.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(
                LucideIcons.check,
                size: 16,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Grid of specialty chips with selection management
class SpecialtySelector extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  final int maxSelection;
  final bool showCounter;

  const SpecialtySelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.maxSelection = 5,
    this.showCounter = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showCounter)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(
                  '${selected.length}/$maxSelection selecionadas',
                  style: TextStyle(
                    fontSize: 12,
                    color: selected.length >= maxSelection
                        ? AppColors.warning
                        : (isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground),
                    fontWeight:
                        selected.length >= maxSelection ? FontWeight.w600 : null,
                  ),
                ),
                if (selected.length >= maxSelection) ...[
                  const SizedBox(width: 4),
                  Icon(
                    LucideIcons.alertCircle,
                    size: 14,
                    color: AppColors.warning,
                  ),
                ],
              ],
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SpecialtyOptions.all.map((specialty) {
            final isSelected = selected.contains(specialty.id);
            final canSelect = isSelected || selected.length < maxSelection;

            return SpecialtyChip(
              specialty: specialty,
              isSelected: isSelected,
              enabled: canSelect,
              onTap: () {
                final newSelected = List<String>.from(selected);
                if (isSelected) {
                  newSelected.remove(specialty.id);
                } else if (canSelect) {
                  newSelected.add(specialty.id);
                }
                onChanged(newSelected);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
