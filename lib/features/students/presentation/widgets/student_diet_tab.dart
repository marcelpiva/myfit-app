import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/nutrition_service.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Provider for student's diet plan data
final studentDietProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, studentUserId) async {
  final service = NutritionService();
  try {
    final plan = await service.getPatientDietPlan(studentUserId);
    return plan;
  } catch (e) {
    // No diet plan assigned or no access
    return null;
  }
});

/// Provider for student's diet history
final studentDietHistoryProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, studentUserId) async {
  final service = NutritionService();
  try {
    final history = await service.getPatientDietHistory(studentUserId);
    return history;
  } catch (e) {
    return [];
  }
});

/// Tab showing student's diet plan and nutrition info (Trainer view)
class StudentDietTab extends ConsumerWidget {
  final String studentUserId;
  final String studentName;

  const StudentDietTab({
    super.key,
    required this.studentUserId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dietAsync = ref.watch(studentDietProvider(studentUserId));
    final historyAsync = ref.watch(studentDietHistoryProvider(studentUserId));

    return dietAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, ref, theme, isDark),
      data: (diet) {
        if (diet == null) {
          return _buildNoPlanState(context, theme, isDark);
        }
        return _buildDietContent(context, ref, theme, isDark, diet, historyAsync);
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: AppColors.destructive,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar dieta',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => ref.invalidate(studentDietProvider(studentUserId)),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPlanState(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(isDark ? 30 : 20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.utensils,
                size: 48,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum plano alimentar',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$studentName ainda não possui um plano alimentar atribuído',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                HapticUtils.lightImpact();
                _showAssignDietSheet(context);
              },
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Atribuir Plano'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> diet,
    AsyncValue<List<Map<String, dynamic>>> historyAsync,
  ) {
    final planName = diet['name'] as String? ?? 'Plano Alimentar';
    final description = diet['description'] as String?;
    final targetCalories = diet['target_calories'] as int? ?? 0;
    final targetProtein = diet['target_protein_g'] as num? ?? 0;
    final targetCarbs = diet['target_carbs_g'] as num? ?? 0;
    final targetFat = diet['target_fat_g'] as num? ?? 0;
    final meals = (diet['meals'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final adherence = (diet['adherence'] as num?)?.toDouble() ?? 0;
    final startDate = diet['start_date'] as String?;
    final endDate = diet['end_date'] as String?;

    return RefreshIndicator(
      onRefresh: () async {
        HapticUtils.lightImpact();
        ref.invalidate(studentDietProvider(studentUserId));
        ref.invalidate(studentDietHistoryProvider(studentUserId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current plan card
            _buildCurrentPlanCard(
              context,
              theme,
              isDark,
              planName: planName,
              description: description,
              adherence: adherence,
              startDate: startDate,
              endDate: endDate,
            ),

            const SizedBox(height: 20),

            // Macros section
            _buildMacrosSection(
              theme,
              isDark,
              calories: targetCalories,
              protein: targetProtein.toDouble(),
              carbs: targetCarbs.toDouble(),
              fat: targetFat.toDouble(),
            ),

            const SizedBox(height: 20),

            // Meals section
            if (meals.isNotEmpty)
              _buildMealsSection(context, theme, isDark, meals),

            const SizedBox(height: 20),

            // History section
            historyAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
              data: (history) {
                if (history.isEmpty) return const SizedBox.shrink();
                return _buildHistorySection(theme, isDark, history);
              },
            ),

            // Quick actions
            const SizedBox(height: 20),
            _buildQuickActions(context, theme, isDark),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(
    BuildContext context,
    ThemeData theme,
    bool isDark, {
    required String planName,
    String? description,
    required double adherence,
    String? startDate,
    String? endDate,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withAlpha(isDark ? 40 : 30),
            AppColors.success.withAlpha(isDark ? 20 : 10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withAlpha(isDark ? 60 : 40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(isDark ? 50 : 40),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.utensils,
                  size: 22,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ATIVO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      planName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticUtils.lightImpact();
                  _showPlanOptions(context);
                },
                icon: Icon(
                  LucideIcons.moreVertical,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ],
          ),

          if (description != null) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Adherence progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Aderência',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                        Text(
                          '${adherence.toStringAsFixed(0)}%',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getAdherenceColor(adherence),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: adherence / 100,
                        backgroundColor: isDark
                            ? AppColors.mutedDark
                            : AppColors.muted,
                        valueColor: AlwaysStoppedAnimation(
                          _getAdherenceColor(adherence),
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (startDate != null || endDate != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 14,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDateRange(startDate, endDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMacrosSection(
    ThemeData theme,
    bool isDark, {
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metas Diárias',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MacroCard(
                icon: LucideIcons.flame,
                iconColor: AppColors.warning,
                value: '$calories',
                unit: 'kcal',
                label: 'Calorias',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MacroCard(
                icon: LucideIcons.beef,
                iconColor: AppColors.destructive,
                value: '${protein.toStringAsFixed(0)}g',
                unit: '',
                label: 'Proteína',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MacroCard(
                icon: LucideIcons.wheat,
                iconColor: AppColors.info,
                value: '${carbs.toStringAsFixed(0)}g',
                unit: '',
                label: 'Carboidratos',
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MacroCard(
                icon: LucideIcons.droplet,
                iconColor: AppColors.secondary,
                value: '${fat.toStringAsFixed(0)}g',
                unit: '',
                label: 'Gordura',
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealsSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    List<Map<String, dynamic>> meals,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Refeições',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...meals.map((meal) {
          final mealName = meal['name'] as String? ?? 'Refeição';
          final mealType = meal['meal_type'] as String? ?? '';
          final time = meal['time'] as String?;
          final calories = meal['calories'] as int? ?? 0;
          final foods = (meal['foods'] as List?)?.cast<Map<String, dynamic>>() ?? [];

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getMealTypeColor(mealType).withAlpha(isDark ? 30 : 20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getMealTypeIcon(mealType),
                        size: 18,
                        color: _getMealTypeColor(mealType),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mealName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (time != null)
                            Text(
                              time,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForeground,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$calories',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'kcal',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (foods.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: foods.take(4).map((food) {
                      final foodName = food['name'] as String? ?? '';
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.mutedDark : AppColors.muted,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          foodName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (foods.length > 4)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '+${foods.length - 4} mais',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHistorySection(
    ThemeData theme,
    bool isDark,
    List<Map<String, dynamic>> history,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histórico de Planos',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...history.take(3).map((plan) {
          final name = plan['name'] as String? ?? 'Plano';
          final startDate = plan['start_date'] as String?;
          final endDate = plan['end_date'] as String?;
          final adherence = (plan['adherence'] as num?)?.toInt() ?? 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.history,
                  size: 18,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatDateRange(startDate, endDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getAdherenceColor(adherence.toDouble()).withAlpha(isDark ? 30 : 20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$adherence%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getAdherenceColor(adherence.toDouble()),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: LucideIcons.edit,
                label: 'Editar Plano',
                isDark: isDark,
                onTap: () {
                  HapticUtils.lightImpact();
                  _showComingSoon(context, 'Editar plano alimentar');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: LucideIcons.refreshCw,
                label: 'Trocar Plano',
                isDark: isDark,
                onTap: () {
                  HapticUtils.lightImpact();
                  _showAssignDietSheet(context);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: LucideIcons.barChart2,
                label: 'Ver Consumo',
                isDark: isDark,
                onTap: () {
                  HapticUtils.lightImpact();
                  _showComingSoon(context, 'Histórico de consumo');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: LucideIcons.stickyNote,
                label: 'Adicionar Nota',
                isDark: isDark,
                onTap: () {
                  HapticUtils.lightImpact();
                  _showAddNoteSheet(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getAdherenceColor(double adherence) {
    if (adherence >= 80) return AppColors.success;
    if (adherence >= 60) return AppColors.warning;
    return AppColors.destructive;
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
      case 'cafe_manha':
        return AppColors.warning;
      case 'lunch':
      case 'almoco':
        return AppColors.success;
      case 'snack':
      case 'lanche':
        return AppColors.info;
      case 'dinner':
      case 'jantar':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
      case 'cafe_manha':
        return LucideIcons.sunrise;
      case 'lunch':
      case 'almoco':
        return LucideIcons.sun;
      case 'snack':
      case 'lanche':
        return LucideIcons.cookie;
      case 'dinner':
      case 'jantar':
        return LucideIcons.moon;
      default:
        return LucideIcons.utensils;
    }
  }

  String _formatDateRange(String? start, String? end) {
    if (start == null && end == null) return '';

    String formatDate(String? dateStr) {
      if (dateStr == null) return '';
      final date = DateTime.tryParse(dateStr);
      if (date == null) return '';
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    final startFormatted = formatDate(start);
    final endFormatted = formatDate(end);

    if (startFormatted.isNotEmpty && endFormatted.isNotEmpty) {
      return '$startFormatted - $endFormatted';
    } else if (startFormatted.isNotEmpty) {
      return 'Início: $startFormatted';
    } else if (endFormatted.isNotEmpty) {
      return 'Término: $endFormatted';
    }
    return '';
  }

  void _showPlanOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.eye),
              title: const Text('Ver detalhes'),
              onTap: () {
                Navigator.pop(ctx);
                _showComingSoon(context, 'Detalhes do plano');
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.edit),
              title: const Text('Editar plano'),
              onTap: () {
                Navigator.pop(ctx);
                _showComingSoon(context, 'Editar plano');
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.copy),
              title: const Text('Duplicar plano'),
              onTap: () {
                Navigator.pop(ctx);
                _showComingSoon(context, 'Duplicar plano');
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.trash2, color: AppColors.destructive),
              title: Text('Remover plano', style: TextStyle(color: AppColors.destructive)),
              onTap: () {
                Navigator.pop(ctx);
                _showComingSoon(context, 'Remover plano');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDietSheet(BuildContext context) {
    _showComingSoon(context, 'Atribuir plano alimentar');
  }

  void _showAddNoteSheet(BuildContext context) {
    _showComingSoon(context, 'Adicionar nota');
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Em breve!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String unit;
  final String label;
  final bool isDark;

  const _MacroCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.unit,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
