import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/animated_progress_bar.dart';
import '../../widgets/template_carousel.dart';

/// Templates exploration step with carousel
class TrainerTemplatesStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final double progress;

  const TrainerTemplatesStep({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    this.progress = 0.8,
  });

  @override
  ConsumerState<TrainerTemplatesStep> createState() =>
      _TrainerTemplatesStepState();
}

class _TrainerTemplatesStepState extends ConsumerState<TrainerTemplatesStep> {
  String _selectedCategory = 'Popular';
  final List<String> _categories = [
    'Popular',
    'Por Objetivo',
    'Por Nível',
    'Todos',
  ];

  // Sample template data - in production, this would come from an API
  final List<TemplateCardData> _templates = [
    const TemplateCardData(
      id: '1',
      name: 'Hipertrofia Básica',
      description: 'Ideal para ganho de massa muscular',
      difficulty: 'Intermediário',
      workoutCount: 4,
      category: 'hipertrofia',
    ),
    const TemplateCardData(
      id: '2',
      name: 'Emagrecimento',
      description: 'Treino para perda de gordura',
      difficulty: 'Iniciante',
      workoutCount: 5,
      category: 'emagrecimento',
    ),
    const TemplateCardData(
      id: '3',
      name: 'Força Total',
      description: 'Desenvolvimento de força máxima',
      difficulty: 'Avançado',
      workoutCount: 3,
      category: 'força',
    ),
    const TemplateCardData(
      id: '4',
      name: 'Funcional',
      description: 'Treino funcional completo',
      difficulty: 'Intermediário',
      workoutCount: 4,
      category: 'funcional',
    ),
    const TemplateCardData(
      id: '5',
      name: 'HIIT Express',
      description: 'Treino de alta intensidade rápido',
      difficulty: 'Avançado',
      workoutCount: 3,
      category: 'cardio',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              // Header with progress
              _buildHeader(context, isDark),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            // Header icon
                            Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withAlpha(isDark ? 30 : 20),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  LucideIcons.layoutGrid,
                                  size: 40,
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Title
                            Center(
                              child: Text(
                                'Explore os Templates',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foreground,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Use templates prontos como base para criar planos personalizados',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Category tabs
                            TemplateCategoryTabs(
                              categories: _categories,
                              selectedCategory: _selectedCategory,
                              onCategorySelected: (category) {
                                setState(() => _selectedCategory = category);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Template carousel
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: TemplateCarousel(
                          templates: _templates,
                          onTemplateSelected: (template) {
                            HapticUtils.selectionClick();
                            ref
                                .read(trainerOnboardingProvider.notifier)
                                .markTemplatesExplored();
                            // TODO: Navigate to template detail or copy
                          },
                          onPreviewTap: (template) {
                            HapticUtils.lightImpact();
                            _showTemplatePreview(context, template, isDark);
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // View all button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ViewAllTemplatesButton(
                          onTap: () {
                            HapticUtils.lightImpact();
                            ref
                                .read(trainerOnboardingProvider.notifier)
                                .markTemplatesExplored();
                            // TODO: Navigate to full templates list
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Info card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildInfoCard(isDark),
                      ),
                      const SizedBox(height: 100), // Space for bottom actions
                    ],
                  ),
                ),
              ),
              // Bottom actions
              _buildBottomActions(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              widget.onBack();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SimpleProgressIndicator(progress: widget.progress),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              widget.onSkip();
            },
            child: Text(
              'Pular',
              style: TextStyle(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(isDark ? 20 : 15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.info.withAlpha(40),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(isDark ? 40 : 30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              LucideIcons.lightbulb,
              size: 22,
              color: AppColors.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dica',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Você pode duplicar e personalizar qualquer template para seus alunos',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: () {
            HapticUtils.mediumImpact();
            widget.onNext();
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Finalizar configuração',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showTemplatePreview(
    BuildContext context,
    TemplateCardData template,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TemplatePreviewSheet(
        template: template,
        isDark: isDark,
      ),
    );
  }
}

class _TemplatePreviewSheet extends StatelessWidget {
  final TemplateCardData template;
  final bool isDark;

  const _TemplatePreviewSheet({
    required this.template,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Template header
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      LucideIcons.layoutGrid,
                      size: 28,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _DifficultyChip(difficulty: template.difficulty),
                            const SizedBox(width: 8),
                            Text(
                              '${template.workoutCount} treinos',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Description
              if (template.description != null) ...[
                Text(
                  template.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              // Sample workout list (placeholder)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Treinos inclusos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildSampleWorkouts(isDark),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Fechar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () {
                        HapticUtils.mediumImpact();
                        Navigator.pop(context);
                        // TODO: Use template
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Usar template'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSampleWorkouts(bool isDark) {
    final workouts = ['Treino A - Peito/Tríceps', 'Treino B - Costas/Bíceps', 'Treino C - Pernas', 'Treino D - Ombros'];
    return workouts.take(template.workoutCount).map((workout) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(
              LucideIcons.clipboard,
              size: 16,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
            const SizedBox(width: 8),
            Text(
              workout,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.foregroundDark
                    : AppColors.foreground,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _DifficultyChip extends StatelessWidget {
  final String difficulty;

  const _DifficultyChip({required this.difficulty});

  Color get _color {
    switch (difficulty.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
