import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/utils/workout_translations.dart';
import '../../../home/presentation/providers/student_home_provider.dart';
import '../../../../shared/presentation/widgets/trainer_managed_banner.dart';
import '../providers/workout_provider.dart';

class WorkoutsPage extends ConsumerStatefulWidget {
  const WorkoutsPage({super.key});

  @override
  ConsumerState<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends ConsumerState<WorkoutsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _selectedFilter = 0;

  final _filters = ['Todos', 'Esta Semana', 'Favoritos'];

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

    return Scaffold(
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
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Meus Treinos',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Only show create button if student has NO trainer
                          Consumer(
                            builder: (context, ref, _) {
                              final hasTrainer = ref.watch(studentDashboardProvider).hasTrainer;
                              if (hasTrainer) return const SizedBox.shrink();

                              return GestureDetector(
                                onTap: () {
                                  HapticUtils.lightImpact();
                                  _showCreateWorkoutOptions(context, isDark);
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.primary : AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    LucideIcons.plus,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Search bar
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDark.withAlpha(150)
                              : AppColors.card.withAlpha(200),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(
                              LucideIcons.search,
                              size: 18,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Buscar treinos...',
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: isDark
                                        ? AppColors.mutedForegroundDark
                                        : AppColors.mutedForeground,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foreground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Show banner when student has a trainer
                      Consumer(
                        builder: (context, ref, _) {
                          final dashboardState = ref.watch(studentDashboardProvider);
                          if (!dashboardState.hasTrainer) return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: TrainerManagedBanner(
                              trainerName: dashboardState.trainer?.name,
                              isDark: isDark,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filters.asMap().entries.map((entry) {
                            final isSelected = entry.key == _selectedFilter;
                            return GestureDetector(
                              onTap: () {
                                HapticUtils.selectionClick();
                                setState(() => _selectedFilter = entry.key);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                                      : (isDark
                                          ? AppColors.cardDark.withAlpha(150)
                                          : AppColors.card.withAlpha(200)),
                                  border: Border.all(
                                    color: isSelected
                                        ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                                        : (isDark ? AppColors.borderDark : AppColors.border),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? (isDark ? AppColors.backgroundDark : AppColors.background)
                                        : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Workout list from API
                Expanded(
                  child: _WorkoutsList(
                    isDark: isDark,
                    onWorkoutTap: (workout) {
                      HapticUtils.lightImpact();
                      context.push('/workouts/${workout['id']}');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateWorkoutOptions(BuildContext context, bool isDark) {
    // Navigate directly to program wizard which handles method selection
    HapticUtils.lightImpact();
    context.push(RouteNames.planWizard);
  }
}

class _WorkoutCard extends StatelessWidget {
  final Map<String, dynamic> workout;
  final bool isDark;
  final VoidCallback onTap;

  const _WorkoutCard({
    required this.workout,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = workout['completed'] as bool;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Day badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withAlpha(25)
                          : AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              LucideIcons.check,
                              size: 20,
                              color: AppColors.success,
                            )
                          : Text(
                              workout['day'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.primaryDark : AppColors.primary,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Workout info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.clock,
                              size: 12,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              workout['duration'],
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              LucideIcons.dumbbell,
                              size: 12,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              workout['exercises'],
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

                  // Arrow
                  Icon(
                    LucideIcons.chevronRight,
                    size: 20,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ],
              ),
            ),

            // Muscle groups
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.mutedDark.withAlpha(100)
                    : AppColors.muted.withAlpha(100),
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: (workout['muscles'] as List<String>).map((muscle) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDark.withAlpha(150)
                          : AppColors.background.withAlpha(200),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      muscle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Workouts List Widget (uses API)
class _WorkoutsList extends ConsumerWidget {
  final bool isDark;
  final Function(Map<String, dynamic> workout) onWorkoutTap;

  const _WorkoutsList({
    required this.isDark,
    required this.onWorkoutTap,
  });

  String _formatDuration(int? minutes) {
    if (minutes == null) return '-';
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}min' : '${hours}h';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsState = ref.watch(workoutsNotifierProvider);
    final plansState = ref.watch(plansNotifierProvider);

    final isLoading = workoutsState.isLoading || plansState.isLoading;
    final hasError = workoutsState.error != null || plansState.error != null;
    final errorMsg = workoutsState.error ?? plansState.error;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.alertCircle, size: 48, color: AppColors.destructive),
            const SizedBox(height: 16),
            Text(
              errorMsg!,
              style: TextStyle(color: AppColors.destructive),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                ref.read(workoutsNotifierProvider.notifier).refresh();
                ref.read(plansNotifierProvider.notifier).refresh();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tentar novamente',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final plans = plansState.plans;
    final workouts = workoutsState.workouts;
    final hasTrainer = ref.watch(studentDashboardProvider).hasTrainer;

    if (plans.isEmpty && workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasTrainer ? LucideIcons.userCheck : LucideIcons.dumbbell,
              size: 64,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              hasTrainer
                  ? 'Aguardando prescrição'
                  : 'Nenhum treino encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasTrainer
                  ? 'Seu Personal ainda não prescreveu um plano de treino'
                  : 'Crie seu primeiro plano de treino',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasTrainer) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  context.go(RouteNames.chat);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Conversar com Personal',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        // Plans section
        if (plans.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 8),
            child: Row(
              children: [
                Icon(
                  hasTrainer ? LucideIcons.userCheck : LucideIcons.clipboard,
                  size: 18,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  hasTrainer ? 'Planos Prescritos' : 'Planos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const Spacer(),
                Text(
                  '${plans.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          ...plans.map((plan) => _PlanCard(
                plan: plan,
                isDark: isDark,
                isAssigned: plan['is_assigned'] == true,
                onTap: () {
                  HapticUtils.lightImpact();
                  context.push('/plans/${plan['id']}');
                },
              )),
          const SizedBox(height: 24),
        ],

        // Workouts section
        if (workouts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  LucideIcons.dumbbell,
                  size: 18,
                  color: isDark ? AppColors.secondaryDark : AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Treinos Individuais',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const Spacer(),
                Text(
                  '${workouts.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          ...workouts.asMap().entries.map((entry) {
            final index = entry.key;
            final apiWorkout = entry.value;
            final workout = {
              'id': apiWorkout['id'],
              'day': String.fromCharCode(65 + (index % 5)),
              'name': apiWorkout['name'] ?? 'Treino ${index + 1}',
              'duration': _formatDuration(apiWorkout['estimated_duration'] as int?),
              'exercises': '${(apiWorkout['exercises'] as List?)?.length ?? 0} exercícios',
              'muscles': (apiWorkout['muscle_groups'] as List?)?.cast<String>() ?? [],
              'completed': apiWorkout['completed'] ?? false,
            };
            return _WorkoutCard(
              workout: workout,
              isDark: isDark,
              onTap: () => onWorkoutTap(apiWorkout),
            );
          }),
        ],

        const SizedBox(height: 100), // Bottom padding for FAB
      ],
    );
  }
}

// Plan Card Widget
class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isDark;
  final bool isAssigned;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isDark,
    this.isAssigned = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = plan['name'] as String? ?? 'Plano';
    final goal = plan['goal'] as String?;
    final difficulty = plan['difficulty'] as String?;
    final splitType = plan['split_type'] as String?;
    final workoutsCount = (plan['workouts'] as List?)?.length ?? 0;
    final durationWeeks = plan['duration_weeks'] as int?;
    final trainerNotes = plan['trainer_notes'] as String?;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withAlpha(isDark ? 30 : 20),
              AppColors.secondary.withAlpha(isDark ? 20 : 15),
            ],
          ),
          border: Border.all(
            color: AppColors.primary.withAlpha(50),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.clipboard,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      if (goal != null)
                        Text(
                          translateGoal(goal),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (isAssigned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.success.withAlpha(50),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.userCheck,
                          size: 12,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Prescrito',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                _PlanBadge(
                  label: '$workoutsCount treinos',
                  icon: LucideIcons.dumbbell,
                  isDark: isDark,
                ),
                if (splitType != null)
                  _PlanBadge(
                    label: translateSplitType(splitType),
                    icon: LucideIcons.layoutGrid,
                    isDark: isDark,
                  ),
                if (difficulty != null)
                  _PlanBadge(
                    label: translateDifficulty(difficulty),
                    icon: LucideIcons.gauge,
                    isDark: isDark,
                  ),
                if (durationWeeks != null)
                  _PlanBadge(
                    label: '$durationWeeks semanas',
                    icon: LucideIcons.calendar,
                    isDark: isDark,
                  ),
              ],
            ),
            // Trainer notes if assigned
            if (isAssigned && trainerNotes != null && trainerNotes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(isDark ? 20 : 15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.info.withAlpha(30),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      LucideIcons.messageSquare,
                      size: 14,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trainerNotes,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.foregroundDark.withAlpha(200)
                              : AppColors.foreground.withAlpha(200),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;

  const _PlanBadge({
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark.withAlpha(150) : Colors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
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
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
