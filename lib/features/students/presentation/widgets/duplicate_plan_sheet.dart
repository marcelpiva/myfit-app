import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/workout_service.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'assign_existing_plan_sheet.dart' show trainerPlansListProvider;

/// Sheet for duplicating an existing plan and assigning to a student
class DuplicatePlanSheet extends ConsumerStatefulWidget {
  final String studentUserId;
  final String studentName;

  const DuplicatePlanSheet({
    super.key,
    required this.studentUserId,
    required this.studentName,
  });

  @override
  ConsumerState<DuplicatePlanSheet> createState() => _DuplicatePlanSheetState();
}

class _DuplicatePlanSheetState extends ConsumerState<DuplicatePlanSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _duplicateAndEdit(Map<String, dynamic> plan) async {
    final planId = plan['id'] as String;
    final planName = plan['name'] as String? ?? 'Plano';

    // Show dialog to get new plan name
    final nameController = TextEditingController(text: '$planName (${widget.studentName})');

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Duplicar Plano'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O plano "$planName" será duplicado e você poderá editá-lo para ${widget.studentName}.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do novo plano',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, nameController.text),
            child: const Text('Duplicar'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || !mounted) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final service = WorkoutService();
      final newPlan = await service.duplicatePlan(planId, newName: newName);
      final newPlanId = newPlan['id'] as String?;

      if (mounted) {
        // Close loading
        Navigator.pop(context);
        // Close sheet
        Navigator.pop(context);

        if (newPlanId != null) {
          // Navigate to wizard with the duplicated plan for editing
          // and pre-selected student
          context.push('/plans/wizard?edit=$newPlanId&studentId=${widget.studentUserId}');
        }
      }
    } catch (e) {
      if (mounted) {
        // Close loading
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao duplicar: $e'),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final plansAsync = ref.watch(trainerPlansListProvider);
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(isDark ? 30 : 20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.copy,
                    color: AppColors.info,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duplicar Plano Existente',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Para ${widget.studentName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
          ),

          // Info banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(isDark ? 20 : 15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.info.withAlpha(isDark ? 40 : 30),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.info,
                  size: 18,
                  color: AppColors.info,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Selecione um plano para criar uma cópia editável',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar plano...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                filled: true,
                fillColor: isDark ? AppColors.cardDark : AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          const SizedBox(height: 12),

          // Plans list
          Expanded(
            child: plansAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
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
                      'Erro ao carregar planos',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(trainerPlansListProvider),
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
              data: (plans) {
                // Filter plans by search
                final search = _searchController.text.toLowerCase();
                final filteredPlans = search.isEmpty
                    ? plans
                    : plans.where((p) {
                        final name = (p['name'] as String? ?? '').toLowerCase();
                        final objective = (p['objective'] as String? ?? '').toLowerCase();
                        return name.contains(search) || objective.contains(search);
                      }).toList();

                if (filteredPlans.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.clipboardList,
                          size: 48,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          search.isEmpty
                              ? 'Nenhum plano criado'
                              : 'Nenhum plano encontrado',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          search.isEmpty
                              ? 'Crie um plano primeiro para duplicar'
                              : 'Tente uma busca diferente',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomPadding),
                  itemCount: filteredPlans.length,
                  itemBuilder: (context, index) {
                    final plan = filteredPlans[index];
                    final planName = plan['name'] as String? ?? 'Plano sem nome';
                    final objective = plan['objective'] as String?;
                    final difficulty = plan['difficulty'] as String?;
                    final workoutsCount = (plan['workouts'] as List?)?.length ?? 0;

                    return GestureDetector(
                      onTap: () {
                        HapticUtils.selectionClick();
                        _duplicateAndEdit(plan);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                LucideIcons.clipboardList,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    planName,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (objective != null)
                                    Text(
                                      objective,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: isDark
                                            ? AppColors.mutedForegroundDark
                                            : AppColors.mutedForeground,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (difficulty != null) ...[
                                        _PlanChip(
                                          label: difficulty,
                                          isDark: isDark,
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      _PlanChip(
                                        label: '$workoutsCount treino${workoutsCount == 1 ? '' : 's'}',
                                        isDark: isDark,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              LucideIcons.copy,
                              size: 20,
                              color: AppColors.info,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  final String label;
  final bool isDark;

  const _PlanChip({
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.mutedDark : AppColors.muted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
        ),
      ),
    );
  }
}
