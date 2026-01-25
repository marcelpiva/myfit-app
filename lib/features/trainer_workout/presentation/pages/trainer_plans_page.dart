import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/domain/entities/user_role.dart';
import '../../../../core/services/workout_service.dart';
import '../../../../shared/presentation/components/role_bottom_navigation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Provider for all user's models (templates only - not direct prescriptions)
final allPlansProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = WorkoutService();
  final plans = await service.getPlans(templatesOnly: false);
  final currentUser = ref.read(currentUserProvider);
  final userId = currentUser?.id;
  if (userId == null) return [];
  // Filter plans created by current user that are templates (models)
  // Direct prescriptions (is_template=false) should not appear here
  return plans.where((p) {
    final createdById = p['created_by_id'];
    final isTemplate = p['is_template'] as bool? ?? true;
    return createdById != null && createdById.toString() == userId && isTemplate;
  }).toList();
});

/// Page showing trainer's training plans
class TrainerPlansPage extends ConsumerWidget {
  const TrainerPlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      bottomNavigationBar: const RoleBottomNavigation(
        role: UserRole.trainer,
        currentIndex: 2,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meus Modelos',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Crie e gerencie seus modelos de treino',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      HapticUtils.lightImpact();
                      context.push(RouteNames.planWizard);
                    },
                    icon: const Icon(LucideIcons.plus, size: 18),
                    label: const Text('Novo'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Programs List
            Expanded(
              child: _PlansList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Unified list of all user's plans
class _PlansList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final plansAsync = ref.watch(allPlansProvider);

    return plansAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _ErrorState(
        onRetry: () => ref.invalidate(allPlansProvider),
      ),
      data: (plans) {
        if (plans.isEmpty) {
          return _EmptyState(
            icon: LucideIcons.dumbbell,
            message: 'Nenhum modelo criado',
            subtitle: 'Crie seu primeiro modelo de treino',
            actionLabel: 'Criar Modelo',
            onAction: () {
              HapticUtils.lightImpact();
              context.push(RouteNames.planWizard);
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(allPlansProvider),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              final isImported = plan['source_template_id'] != null;

              return _UnifiedPlanCard(
                plan: plan,
                isDark: isDark,
                isImported: isImported,
                showPublishBadge: plan['is_public'] == true && !isImported,
                onTap: () {
                  HapticUtils.lightImpact();
                  final planId = plan['id'] as String?;
                  if (planId != null) {
                    if (isImported) {
                      // Show view-only detail for imported plans
                      _showPlanDetail(context, ref, plan);
                    } else {
                      // Edit own plans
                      context.push('${RouteNames.planWizard}?edit=$planId');
                    }
                  }
                },
                onDelete: () => _handleDelete(context, ref, plan, isImported),
                onPublish: isImported ? null : () => _handlePublish(context, ref, plan),
                onDuplicate: isImported ? () => _handleDuplicate(context, ref, plan) : null,
              );
            },
          ),
        );
      },
    );
  }

  void _showPlanDetail(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> plan,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final name = plan['name'] as String? ?? 'Modelo';
    final description = plan['description'] as String?;
    final goal = plan['goal'] as String? ?? '';
    final difficulty = plan['difficulty'] as String? ?? '';
    final splitType = plan['split_type'] as String? ?? '';
    final workoutCount = plan['workout_count'] as int? ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withAlpha(40),
                        AppColors.secondary.withAlpha(30),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.dumbbell, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.download, size: 12, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Importado',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Não editável - use como base para criar novo',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Info chips
            Row(
              children: [
                _InfoChip(icon: LucideIcons.target, label: _getGoalDisplay(goal), isDark: isDark),
                const SizedBox(width: 8),
                _InfoChip(icon: LucideIcons.gauge, label: _getDifficultyDisplay(difficulty), isDark: isDark),
                const SizedBox(width: 8),
                _InfoChip(icon: LucideIcons.layoutGrid, label: _getSplitDisplay(splitType), isDark: isDark),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(LucideIcons.dumbbell, size: 16, color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                const SizedBox(width: 6),
                Text(
                  '$workoutCount treino${workoutCount != 1 ? 's' : ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),

            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Descrição',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ],

            const Spacer(),

            // Action button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _handleDuplicate(context, ref, plan);
                },
                icon: const Icon(LucideIcons.copy),
                label: const Text('Criar novo a partir deste'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> plan,
    bool isImported,
  ) async {
    final planId = plan['id'] as String?;
    final planName = plan['name'] as String? ?? 'Modelo';
    if (planId == null) return;

    final title = isImported ? 'Remover Modelo' : 'Excluir Modelo';
    final message = isImported
        ? 'Deseja remover "$planName" da sua lista?'
        : 'Deseja excluir "$planName"? Esta ação não pode ser desfeita.';
    final buttonLabel = isImported ? 'Remover' : 'Excluir';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.destructive),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final service = WorkoutService();
        await service.deletePlan(planId);
        ref.invalidate(allPlansProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Modelo ${isImported ? 'removido' : 'excluído'} com sucesso')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      }
    }
  }

  Future<void> _handlePublish(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> plan,
  ) async {
    final planId = plan['id'] as String?;
    final planName = plan['name'] as String? ?? 'Modelo';
    final isPublic = plan['is_public'] as bool? ?? false;
    if (planId == null) return;

    final action = isPublic ? 'despublicar' : 'publicar';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isPublic ? 'Despublicar do Catálogo' : 'Publicar no Catálogo'),
        content: Text(
          isPublic
              ? 'Deseja remover "$planName" do catálogo? Outros usuários não poderão mais importá-lo.'
              : 'Deseja publicar "$planName" no catálogo? Outros Personal Trainers poderão importá-lo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isPublic ? 'Despublicar' : 'Publicar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final service = WorkoutService();
        await service.updatePlan(
          planId,
          isTemplate: true,
          isPublic: !isPublic,
        );
        ref.invalidate(allPlansProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Modelo ${isPublic ? 'despublicado' : 'publicado'} com sucesso')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao $action: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleDuplicate(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> plan,
  ) async {
    final planId = plan['id'] as String?;
    final planName = plan['name'] as String? ?? 'Modelo';
    if (planId == null) return;

    // Show dialog to get new model name
    final nameController = TextEditingController(text: '$planName (Cópia)');
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Duplicar Modelo'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome do novo modelo',
            hintText: 'Digite o nome do modelo',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
            child: const Text('Duplicar'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || !context.mounted) return;

    try {
      final service = WorkoutService();
      final newPlan = await service.duplicatePlan(planId, newName: newName);
      final newPlanId = newPlan['id'] as String?;

      ref.invalidate(allPlansProvider);

      if (context.mounted && newPlanId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Modelo "$newName" duplicado com sucesso'),
            action: SnackBarAction(
              label: 'Editar',
              onPressed: () {
                context.push('${RouteNames.planWizard}?edit=$newPlanId');
              },
            ),
          ),
        );
        // Navigate to edit the new plan
        context.push('${RouteNames.planWizard}?edit=$newPlanId');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao duplicar: $e')),
        );
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(LucideIcons.plus, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.alertCircle, size: 48, color: AppColors.destructive),
          const SizedBox(height: 16),
          Text('Erro ao carregar', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _UnifiedPlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isDark;
  final bool isImported;
  final bool showPublishBadge;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback? onPublish;
  final VoidCallback? onDuplicate;

  const _UnifiedPlanCard({
    required this.plan,
    required this.isDark,
    required this.isImported,
    required this.onTap,
    required this.onDelete,
    this.showPublishBadge = false,
    this.onPublish,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = plan['name'] as String? ?? 'Modelo';
    final goal = plan['goal'] as String? ?? '';
    final difficulty = plan['difficulty'] as String? ?? '';
    final splitType = plan['split_type'] as String? ?? '';
    final workoutCount = plan['workout_count'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Imported badge
                    if (isImported)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.download, size: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Importado',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Published badge (only for own plans)
                    if (showPublishBadge && !isImported)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(isDark ? 30 : 20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.globe, size: 12, color: AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              'Publicado',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: Icon(
                        LucideIcons.moreVertical,
                        size: 20,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'view':
                            onTap();
                            break;
                          case 'edit':
                            onTap();
                            break;
                          case 'delete':
                            onDelete();
                            break;
                          case 'publish':
                            onPublish?.call();
                            break;
                          case 'duplicate':
                            onDuplicate?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (isImported) ...[
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(LucideIcons.eye, size: 18),
                                SizedBox(width: 8),
                                Text('Visualizar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                Icon(LucideIcons.copy, size: 18),
                                SizedBox(width: 8),
                                Text('Criar novo a partir deste'),
                              ],
                            ),
                          ),
                        ] else ...[
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(LucideIcons.pencil, size: 18),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                Icon(LucideIcons.copy, size: 18),
                                SizedBox(width: 8),
                                Text('Criar novo a partir deste'),
                              ],
                            ),
                          ),
                          if (onPublish != null)
                            PopupMenuItem(
                              value: 'publish',
                              child: Row(
                                children: [
                                  Icon(showPublishBadge ? LucideIcons.eyeOff : LucideIcons.globe, size: 18),
                                  const SizedBox(width: 8),
                                  Text(showPublishBadge ? 'Despublicar' : 'Publicar no Catalogo'),
                                ],
                              ),
                            ),
                        ],
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(LucideIcons.trash2, size: 18, color: AppColors.destructive),
                              const SizedBox(width: 8),
                              Text(isImported ? 'Remover' : 'Excluir', style: TextStyle(color: AppColors.destructive)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoChip(icon: LucideIcons.target, label: _getGoalDisplay(goal), isDark: isDark),
                    const SizedBox(width: 8),
                    _InfoChip(icon: LucideIcons.gauge, label: _getDifficultyDisplay(difficulty), isDark: isDark),
                    const SizedBox(width: 8),
                    _InfoChip(icon: LucideIcons.layoutGrid, label: _getSplitDisplay(splitType), isDark: isDark),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      LucideIcons.dumbbell,
                      size: 16,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$workoutCount treino${workoutCount != 1 ? 's' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.mutedDark.withAlpha(50) : AppColors.muted.withAlpha(100),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

String _getGoalDisplay(String goal) {
  switch (goal.toLowerCase()) {
    case 'hypertrophy':
      return 'Hipertrofia';
    case 'strength':
      return 'Força';
    case 'fat_loss':
      return 'Emagrecimento';
    case 'endurance':
      return 'Resistência';
    case 'functional':
      return 'Funcional';
    case 'general_fitness':
      return 'Condicionamento';
    default:
      return goal;
  }
}

String _getDifficultyDisplay(String difficulty) {
  switch (difficulty.toLowerCase()) {
    case 'beginner':
      return 'Iniciante';
    case 'intermediate':
      return 'Intermediário';
    case 'advanced':
      return 'Avançado';
    default:
      return difficulty;
  }
}

String _getSplitDisplay(String splitType) {
  switch (splitType.toLowerCase()) {
    case 'abc':
      return 'ABC';
    case 'abcd':
      return 'ABCD';
    case 'abcde':
      return 'ABCDE';
    case 'push_pull_legs':
      return 'PPL';
    case 'upper_lower':
      return 'Upper/Lower';
    case 'full_body':
      return 'Full Body';
    case 'custom':
      return 'Personalizado';
    default:
      return splitType;
  }
}
