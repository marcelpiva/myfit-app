import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../providers/plan_wizard_provider.dart';

/// Step 1: Method selection for creating a workout program
class StepMethodSelection extends StatelessWidget {
  final Function(CreationMethod) onMethodSelected;

  const StepMethodSelection({
    super.key,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Como deseja criar seu plano?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha a opção que melhor se adapta às suas necessidades',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),

          // Scratch option
          _MethodCard(
            icon: LucideIcons.pencil,
            iconColor: AppColors.primary,
            title: 'Criar do Zero',
            description:
                'Controle total sobre cada detalhe. Selecione exercícios, séries e repetições manualmente.',
            isRecommended: false,
            isDark: isDark,
            theme: theme,
            onTap: () {
              HapticUtils.selectionClick();
              onMethodSelected(CreationMethod.scratch);
            },
          ),
          const SizedBox(height: 16),

          // AI option
          _MethodCard(
            icon: LucideIcons.sparkles,
            iconColor: AppColors.secondary,
            title: 'Assistido por IA',
            description:
                'A IA sugere exercícios baseado nos seus objetivos. Você pode ajustar como preferir.',
            isRecommended: true,
            isDark: isDark,
            theme: theme,
            onTap: () {
              HapticUtils.selectionClick();
              onMethodSelected(CreationMethod.ai);
            },
          ),
          const SizedBox(height: 16),

          // Template option
          _MethodCard(
            icon: LucideIcons.copy,
            iconColor: Colors.orange,
            title: 'A partir dos meus planos',
            description:
                'Use um dos seus planos de treino como base para criar um novo.',
            isRecommended: false,
            isDark: isDark,
            theme: theme,
            onTap: () {
              HapticUtils.selectionClick();
              onMethodSelected(CreationMethod.template);
            },
          ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool isRecommended;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.isRecommended,
    required this.isDark,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerLowest.withAlpha(150)
              : theme.colorScheme.surfaceContainerLowest.withAlpha(200),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Recomendado',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
