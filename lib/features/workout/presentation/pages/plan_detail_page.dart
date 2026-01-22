import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/dev_screen_label.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../core/utils/workout_translations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../training_plan/domain/models/prescription_note.dart';
import '../../../training_plan/presentation/widgets/prescription_notes_section.dart';
import '../providers/workout_provider.dart';
import '../widgets/assign_plan_sheet.dart';

class PlanDetailPage extends ConsumerStatefulWidget {
  final String planId;

  const PlanDetailPage({super.key, required this.planId});

  @override
  ConsumerState<PlanDetailPage> createState() => _PlanDetailPageState();
}

class _PlanDetailPageState extends ConsumerState<PlanDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.entrance,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final detailState = ref.watch(planDetailNotifierProvider(widget.planId));
    final plan = detailState.plan;

    final workouts = (plan?['plan_workouts'] as List<dynamic>?) ?? [];
    final hasWorkouts = workouts.isNotEmpty;

    return DevScreenLabel(
      screenName: 'PlanDetailPage',
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withAlpha(isDark ? 15 : 10),
                AppColors.secondary.withAlpha(isDark ? 12 : 8),
              ],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: detailState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : detailState.error != null
                      ? _buildError(theme, detailState.error!)
                      : plan == null
                          ? _buildNotFound(theme)
                          : _buildContent(context, theme, isDark, plan),
            ),
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(
          hasWorkouts: hasWorkouts,
          isLoading: detailState.isLoading,
          plan: plan,
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(planDetailNotifierProvider(widget.planId).notifier)
                  .refresh(),
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton({
    required bool hasWorkouts,
    required bool isLoading,
    required Map<String, dynamic>? plan,
  }) {
    if (!hasWorkouts || isLoading || plan == null) {
      return null;
    }

    // Check if user is trainer - trainers should not start workouts
    final activeContext = ref.watch(activeContextProvider);
    final isTrainer = activeContext?.isTrainer ?? false;
    if (isTrainer) {
      return null;
    }

    // Check if plan is active (is_active=true and start_date <= today)
    final isActive = plan['is_active'] as bool? ?? true;
    if (!isActive) {
      return null;
    }

    // Check start_date - if in the future, plan is scheduled (not yet active)
    final startDateStr = plan['start_date'] as String?;
    if (startDateStr != null) {
      try {
        final startDate = DateTime.parse(startDateStr);
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        if (startDate.isAfter(todayDate)) {
          // Plan starts in the future - not active yet
          return null;
        }
      } catch (_) {
        // Invalid date format, allow starting
      }
    }

    return FloatingActionButton.extended(
      onPressed: () => _showStartWorkoutSheet(context, plan),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      icon: const Icon(LucideIcons.play, size: 20),
      label: const Text('Iniciar Treino'),
    );
  }

  Widget _buildNotFound(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.clipboard,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Plano não encontrado',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> plan,
  ) {
    final name = plan['name'] as String? ?? 'Plano';
    final goal = plan['goal'] as String? ?? '';
    final difficulty = plan['difficulty'] as String? ?? '';
    final splitType = plan['split_type'] as String? ?? '';
    final description = plan['description'] as String?;
    final durationWeeks = plan['duration_weeks'] as int?;
    final workouts = (plan['plan_workouts'] as List<dynamic>?) ?? [];

    return Column(
      children: [
        // Header
        _buildHeader(context, theme, name, goal, difficulty, splitType),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Row
                _buildStatsRow(theme, isDark, workouts.length, durationWeeks),

                const SizedBox(height: 24),

                // Description
                if (description != null && description.isNotEmpty) ...[
                  Text(
                    'Descrição',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                          : theme.colorScheme.surfaceContainerLow.withAlpha(200),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Notes Section
                _buildNotesSection(context),
                const SizedBox(height: 24),

                // Workouts
                Text(
                  'Treinos do Plano',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                if (workouts.isEmpty)
                  _buildEmptyWorkouts(theme, isDark)
                else
                  ...workouts.map((pw) => _buildWorkoutCard(
                        context,
                        theme,
                        isDark,
                        pw as Map<String, dynamic>,
                      )),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    String name,
    String goal,
    String difficulty,
    String splitType,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withAlpha(200),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.arrowLeft,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticUtils.lightImpact();
                      _showOptionsMenu(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.moreVertical,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Plan icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.clipboard,
              size: 24,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          // Badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(translateGoal(goal), LucideIcons.target),
              _buildBadge(translateDifficulty(difficulty), LucideIcons.barChart),
              _buildBadge(translateSplitType(splitType), LucideIcons.layoutGrid),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    ThemeData theme,
    bool isDark,
    int workoutCount,
    int? durationWeeks,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
            : theme.colorScheme.surfaceContainerLow.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            theme,
            LucideIcons.dumbbell,
            '$workoutCount',
            'Treinos',
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          _buildStatItem(
            theme,
            LucideIcons.timer,
            durationWeeks != null ? '$durationWeeks' : '-',
            'Semanas',
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          _buildStatItem(
            theme,
            LucideIcons.calendar,
            '${workoutCount}x',
            'por semana',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    final currentUser = ref.watch(userProvider);
    final activeContext = ref.watch(activeContextProvider);

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return PrescriptionNotesSection(
      contextType: NoteContextType.plan,
      contextId: widget.planId,
      organizationId: activeContext?.organization.id,
      currentUserId: currentUser.id,
      isTrainer: activeContext?.isTrainer ?? false,
      title: 'Notas do Plano',
      initiallyExpanded: false,
    );
  }

  Widget _buildEmptyWorkouts(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
            : theme.colorScheme.surfaceContainerLow.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.dumbbell,
            size: 32,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum treino no plano',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    Map<String, dynamic> planWorkout,
  ) {
    final label = planWorkout['label'] as String? ?? '';
    final workout = planWorkout['workout'] as Map<String, dynamic>?;
    final workoutName = workout?['name'] as String? ?? 'Treino $label';
    final exercises = (workout?['exercises'] as List<dynamic>?) ?? [];
    final estimatedDuration = workout?['estimated_duration_min'] as int? ?? 0;
    final targetMuscles = (workout?['target_muscles'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        final workoutId = workout?['id'] as String?;
        if (workoutId != null) {
          context.push('/workouts/$workoutId');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerLowest.withAlpha(150)
              : theme.colorScheme.surfaceContainerLowest.withAlpha(200),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Label badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workoutName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${exercises.length} exercícios - ~$estimatedDuration min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),

            // Muscle groups
            if (targetMuscles.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: targetMuscles.take(4).map((muscle) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      translateMuscleGroup(muscle),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Exercises preview
            if (exercises.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: exercises.take(3).map((ex) {
                  final exerciseData = ex as Map<String, dynamic>;
                  final exerciseName = exerciseData['exercise']?['name'] as String? ?? '';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      exerciseName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (exercises.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '+${exercises.length - 3} mais',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              context,
              LucideIcons.pencil,
              'Editar Plano',
              () {
                Navigator.pop(context);
                context.push('/plans/wizard?edit=${widget.planId}');
              },
            ),
            _buildMenuItem(
              context,
              LucideIcons.copy,
              'Duplicar Plano',
              () {
                Navigator.pop(context);
                _duplicatePlan();
              },
            ),
            _buildMenuItem(
              context,
              LucideIcons.userPlus,
              'Atribuir a Aluno',
              () {
                Navigator.pop(context);
                _showAssignSheet();
              },
            ),
            const Divider(),
            _buildMenuItem(
              context,
              LucideIcons.trash2,
              'Excluir Plano',
              () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
              isDestructive: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color),
      ),
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
    );
  }

  Future<void> _duplicatePlan() async {
    try {
      await ref.read(plansNotifierProvider.notifier).duplicatePlan(widget.planId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Plano duplicado com sucesso'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao duplicar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showAssignSheet() {
    final detailState = ref.read(planDetailNotifierProvider(widget.planId));
    final planName = detailState.plan?['name'] as String? ?? 'Plano';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignPlanSheet(
        planId: widget.planId,
        planName: planName,
      ),
    );
  }

  void _showStartWorkoutSheet(BuildContext context, Map<String, dynamic> plan) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final workouts = (plan['plan_workouts'] as List<dynamic>?) ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.play,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Iniciar Treino',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Escolha qual treino deseja iniciar',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...workouts.map((pw) {
              final pwMap = pw as Map<String, dynamic>;
              final label = pwMap['label'] as String? ?? '';
              final workout = pwMap['workout'] as Map<String, dynamic>?;
              final workoutId = workout?['id'] as String?;
              final workoutName = workout?['name'] as String? ?? 'Treino $label';
              final exerciseCount = (workout?['exercises'] as List<dynamic>?)?.length ?? 0;
              final duration = workout?['estimated_duration_min'] as int? ?? 0;

              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                title: Text(workoutName),
                subtitle: Text('$exerciseCount exercícios - ~$duration min'),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: workoutId != null
                    ? () {
                        HapticUtils.mediumImpact();
                        Navigator.pop(context);
                        context.push('/workouts/active/$workoutId');
                      }
                    : null,
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Plano'),
        content: const Text(
          'Tem certeza que deseja excluir este plano? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePlan();
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlan() async {
    try {
      await ref.read(plansNotifierProvider.notifier).deletePlan(widget.planId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Plano excluído com sucesso'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

}
