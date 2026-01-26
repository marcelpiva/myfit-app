import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Template card data model
class TemplateCardData {
  final String id;
  final String name;
  final String? description;
  final String difficulty;
  final int workoutCount;
  final String? category;
  final IconData? icon;

  const TemplateCardData({
    required this.id,
    required this.name,
    this.description,
    required this.difficulty,
    required this.workoutCount,
    this.category,
    this.icon,
  });
}

/// Horizontal carousel of template cards
class TemplateCarousel extends StatelessWidget {
  final List<TemplateCardData> templates;
  final ValueChanged<TemplateCardData>? onTemplateSelected;
  final ValueChanged<TemplateCardData>? onPreviewTap;
  final double cardWidth;
  final double cardHeight;

  const TemplateCarousel({
    super.key,
    required this.templates,
    this.onTemplateSelected,
    this.onPreviewTap,
    this.cardWidth = 260,
    this.cardHeight = 180,
  });

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) {
      return const _EmptyTemplateState();
    }

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < templates.length - 1 ? 12 : 0,
            ),
            child: TemplateCard(
              template: templates[index],
              width: cardWidth,
              height: cardHeight,
              onTap: () => onTemplateSelected?.call(templates[index]),
              onPreviewTap: () => onPreviewTap?.call(templates[index]),
            ),
          );
        },
      ),
    );
  }
}

/// Individual template card
class TemplateCard extends StatelessWidget {
  final TemplateCardData template;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final VoidCallback? onPreviewTap;

  const TemplateCard({
    super.key,
    required this.template,
    this.width = 260,
    this.height = 180,
    this.onTap,
    this.onPreviewTap,
  });

  Color get _difficultyColor {
    switch (template.difficulty.toLowerCase()) {
      case 'iniciante':
      case 'beginner':
        return AppColors.success;
      case 'intermediário':
      case 'intermediate':
        return AppColors.warning;
      case 'avançado':
      case 'advanced':
        return AppColors.destructive;
      default:
        return AppColors.info;
    }
  }

  IconData get _categoryIcon {
    if (template.icon != null) return template.icon!;

    switch (template.category?.toLowerCase()) {
      case 'força':
      case 'strength':
        return LucideIcons.dumbbell;
      case 'cardio':
        return LucideIcons.heart;
      case 'hipertrofia':
      case 'hypertrophy':
        return LucideIcons.zap;
      case 'emagrecimento':
      case 'weight_loss':
        return LucideIcons.flame;
      case 'funcional':
      case 'functional':
        return LucideIcons.activity;
      default:
        return LucideIcons.layoutGrid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        onTap?.call();
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.primary).withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and difficulty badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(isDark ? 20 : 10),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(isDark ? 40 : 25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _categoryIcon,
                      size: 24,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  _DifficultyBadge(
                    label: template.difficulty,
                    color: _difficultyColor,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (template.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        template.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.clipboard,
                          size: 14,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${template.workoutCount} treinos',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            HapticUtils.selectionClick();
                            onPreviewTap?.call();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.eye,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Preview',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _DifficultyBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyTemplateState extends StatelessWidget {
  const _EmptyTemplateState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 160,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.mutedDark : AppColors.muted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.layoutGrid,
            size: 32,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum template disponível',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Category tabs for filtering templates
class TemplateCategoryTabs extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const TemplateCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticUtils.selectionClick();
                onCategorySelected(category);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.cardDark : AppColors.card),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.border),
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// "View all templates" button
class ViewAllTemplatesButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ViewAllTemplatesButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ver todos os templates',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.arrowRight,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
