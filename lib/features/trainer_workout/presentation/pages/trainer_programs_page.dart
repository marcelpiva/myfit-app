import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/domain/entities/user_role.dart';
import '../../../../core/services/workout_service.dart';
import '../../../../shared/presentation/components/role_bottom_navigation.dart';

// Provider for trainer's own programs
final myWorkoutsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = WorkoutService();
  return service.getPrograms(templatesOnly: false);
});

// Provider for catalog templates (public templates from platform)
final catalogProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = WorkoutService();
  return service.getCatalogTemplates();
});

/// Page showing trainer's workout programs and catalog
class TrainerProgramsPage extends ConsumerStatefulWidget {
  const TrainerProgramsPage({super.key});

  @override
  ConsumerState<TrainerProgramsPage> createState() => _TrainerProgramsPageState();
}

class _TrainerProgramsPageState extends ConsumerState<TrainerProgramsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Treinos',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Crie e gerencie programas de treino',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.push(RouteNames.programWizard);
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

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.muted.withAlpha(100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: isDark ? AppColors.backgroundDark : AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 30 : 10),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                dividerColor: Colors.transparent,
                labelColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
                unselectedLabelColor: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Meus Treinos'),
                  Tab(text: 'Catalogo'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _MyWorkoutsList(),
                  _CatalogList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// List of user's own workouts
class _MyWorkoutsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final workoutsAsync = ref.watch(myWorkoutsProvider);

    return workoutsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _ErrorState(
        onRetry: () => ref.invalidate(myWorkoutsProvider),
      ),
      data: (programs) {
        if (programs.isEmpty) {
          return _EmptyState(
            icon: LucideIcons.dumbbell,
            message: 'Nenhum treino criado',
            subtitle: 'Crie seu primeiro programa de treino',
            actionLabel: 'Criar Programa',
            onAction: () {
              HapticFeedback.lightImpact();
              context.push(RouteNames.programWizard);
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myWorkoutsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: programs.length,
            itemBuilder: (context, index) {
              final program = programs[index];
              return _ProgramCard(
                program: program,
                isDark: isDark,
                showPublishBadge: program['is_public'] == true,
                onTap: () {
                  HapticFeedback.lightImpact();
                  final programId = program['id'] as String?;
                  if (programId != null) {
                    context.push('${RouteNames.programWizard}?edit=$programId');
                  }
                },
                onDelete: () => _handleDelete(context, ref, program),
                onPublish: () => _handlePublish(context, ref, program),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> program,
  ) async {
    final programId = program['id'] as String?;
    final programName = program['name'] as String? ?? 'Programa';
    if (programId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Programa'),
        content: Text('Deseja excluir "$programName"? Esta acao nao pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.destructive),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final service = WorkoutService();
        await service.deleteProgram(programId);
        // ignore: unused_result
        ref.refresh(myWorkoutsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Programa excluido com sucesso')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  Future<void> _handlePublish(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> program,
  ) async {
    final programId = program['id'] as String?;
    final programName = program['name'] as String? ?? 'Programa';
    final isPublic = program['is_public'] as bool? ?? false;
    if (programId == null) return;

    final action = isPublic ? 'despublicar' : 'publicar';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isPublic ? 'Despublicar do Catalogo' : 'Publicar no Catalogo'),
        content: Text(
          isPublic
              ? 'Deseja remover "$programName" do catalogo? Outros usuarios nao poderao mais importa-lo.'
              : 'Deseja publicar "$programName" no catalogo? Outros Personal Trainers poderao importa-lo.',
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
        await service.updateProgram(
          programId,
          isTemplate: true,
          isPublic: !isPublic,
        );
        // ignore: unused_result
        ref.refresh(myWorkoutsProvider);
        // ignore: unused_result
        ref.refresh(catalogProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Programa ${isPublic ? 'despublicado' : 'publicado'} com sucesso')),
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
}

/// List of catalog templates
class _CatalogList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catalogAsync = ref.watch(catalogProvider);

    return catalogAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _ErrorState(
        onRetry: () => ref.invalidate(catalogProvider),
      ),
      data: (templates) {
        if (templates.isEmpty) {
          return _EmptyState(
            icon: LucideIcons.library,
            message: 'Catalogo vazio',
            subtitle: 'Nenhum template disponivel no momento',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(catalogProvider),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return _CatalogCard(
                template: template,
                isDark: isDark,
                onImport: () => _handleImport(context, ref, template),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleImport(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> template,
  ) async {
    final templateId = template['id'] as String?;
    final templateName = template['name'] as String? ?? 'Template';
    if (templateId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Importar Template'),
        content: Text('Deseja importar "$templateName" para seus treinos? Uma copia editavel sera criada.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Importar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final service = WorkoutService();
        final newProgram = await service.duplicateProgram(templateId);
        // ignore: unused_result
        ref.refresh(myWorkoutsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template importado com sucesso')),
          );
          // Navigate to edit the imported program
          final newProgramId = newProgram['id'] as String?;
          if (newProgramId != null) {
            context.push('${RouteNames.programWizard}?edit=$newProgramId');
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao importar: $e')),
          );
        }
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

class _ProgramCard extends StatelessWidget {
  final Map<String, dynamic> program;
  final bool isDark;
  final bool showPublishBadge;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onPublish;

  const _ProgramCard({
    required this.program,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
    required this.onPublish,
    this.showPublishBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = program['name'] as String? ?? 'Programa';
    final goal = program['goal'] as String? ?? '';
    final difficulty = program['difficulty'] as String? ?? '';
    final splitType = program['split_type'] as String? ?? '';
    final workoutCount = program['workout_count'] as int? ?? 0;

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
                    if (showPublishBadge)
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
                        if (value == 'edit') onTap();
                        else if (value == 'delete') onDelete();
                        else if (value == 'publish') onPublish();
                      },
                      itemBuilder: (context) => [
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
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(LucideIcons.trash2, size: 18, color: AppColors.destructive),
                              const SizedBox(width: 8),
                              Text('Excluir', style: TextStyle(color: AppColors.destructive)),
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

class _CatalogCard extends StatelessWidget {
  final Map<String, dynamic> template;
  final bool isDark;
  final VoidCallback onImport;

  const _CatalogCard({
    required this.template,
    required this.isDark,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = template['name'] as String? ?? 'Template';
    final goal = template['goal'] as String? ?? '';
    final difficulty = template['difficulty'] as String? ?? '';
    final splitType = template['split_type'] as String? ?? '';
    final workoutCount = template['workout_count'] as int? ?? 0;
    final creatorName = template['creator_name'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? AppColors.cardDark : AppColors.card,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (creatorName != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                LucideIcons.user,
                                size: 12,
                                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'por $creatorName',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onImport();
                    },
                    icon: const Icon(LucideIcons.download, size: 16),
                    label: const Text('Importar'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    LucideIcons.dumbbell,
                    size: 14,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 4),
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
      return 'Forca';
    case 'fat_loss':
      return 'Emagrecimento';
    case 'endurance':
      return 'Resistencia';
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
      return 'Intermediario';
    case 'advanced':
      return 'Avancado';
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
