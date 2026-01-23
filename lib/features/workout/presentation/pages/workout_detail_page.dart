import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../shared/presentation/components/components.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../training_plan/domain/models/prescription_note.dart';
import '../../../training_plan/presentation/widgets/prescription_notes_section.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_list_with_techniques.dart';
import '../widgets/start_workout_sheet.dart';

class WorkoutDetailPage extends ConsumerStatefulWidget {
  final String workoutId;

  const WorkoutDetailPage({super.key, required this.workoutId});

  @override
  ConsumerState<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends ConsumerState<WorkoutDetailPage>
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

    // Load workout detail
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutDetailNotifierProvider(widget.workoutId).notifier).loadDetail();
    });
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
    final detailState = ref.watch(workoutDetailNotifierProvider(widget.workoutId));
    final exercises = detailState.exercises;

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
                Container(
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
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(30),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    LucideIcons.heart,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  HapticUtils.lightImpact();
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

                      // Program badge (if workout belongs to a program)
                      if (detailState.workout?['program_name'] != null) ...[
                        GestureDetector(
                          onTap: () {
                            final programId = detailState.workout?['program_id'];
                            if (programId != null) {
                              HapticUtils.lightImpact();
                              context.push('/programs/$programId');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(50),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withAlpha(30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  LucideIcons.clipboard,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  detailState.workout!['program_name'] as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  LucideIcons.chevronRight,
                                  size: 12,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Badge - difficulty
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getDifficultyLabel(detailState.difficulty),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Title - workout name
                      Text(
                        detailState.name.isNotEmpty ? detailState.name : 'Carregando...',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Stats row - dynamic data
                      Row(
                        children: [
                          _buildHeaderStat(
                            LucideIcons.clock,
                            detailState.estimatedDuration > 0
                                ? '${detailState.estimatedDuration} min'
                                : '--',
                          ),
                          const SizedBox(width: 24),
                          _buildHeaderStat(
                            LucideIcons.flame,
                            '${detailState.exerciseCount} exercícios',
                          ),
                          const SizedBox(width: 24),
                          _buildHeaderStat(
                            LucideIcons.zap,
                            _estimateCalories(detailState.estimatedDuration),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Exercise list with notes section
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Notes section
                        Builder(
                          builder: (context) {
                            final currentUser = ref.watch(userProvider);
                            final activeContext = ref.watch(activeContextProvider);

                            if (currentUser == null) {
                              return const SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: PrescriptionNotesSection(
                                contextType: NoteContextType.workout,
                                contextId: widget.workoutId,
                                organizationId: activeContext?.organization.id,
                                currentUserId: currentUser.id,
                                isTrainer: activeContext?.isTrainer ?? false,
                                title: 'Notas do Treino',
                                initiallyExpanded: false,
                              ),
                            );
                          },
                        ),

                        // Exercise list with technique grouping
                        ExerciseListWithTechniques(
                          exercises: exercises,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom CTA - Only show for students, not trainers
                Builder(
                  builder: (context) {
                    final activeContext = ref.watch(activeContextProvider);
                    final isTrainer = activeContext?.isTrainer ?? false;

                    // Trainers should not see "Iniciar Treino" button
                    if (isTrainer) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.backgroundDark.withAlpha(150)
                            : AppColors.background.withAlpha(200),
                        border: Border(
                          top: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: PrimaryButton(
                        label: 'Iniciar Treino',
                        icon: LucideIcons.play,
                        onPressed: () {
                          HapticUtils.mediumImpact();
                          _showStartWorkoutSheet(context, detailState.name);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'INICIANTE';
      case 'intermediate':
        return 'INTERMEDIÁRIO';
      case 'advanced':
        return 'AVANÇADO';
      default:
        return difficulty.toUpperCase();
    }
  }

  String _estimateCalories(int durationMinutes) {
    if (durationMinutes <= 0) return '-- kcal';
    // Estimativa aproximada: ~7 kcal/min para treino de musculação
    final calories = (durationMinutes * 7).round();
    return '~$calories kcal';
  }

  void _showStartWorkoutSheet(BuildContext context, String workoutName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StartWorkoutSheet(
        workoutId: widget.workoutId,
        workoutName: workoutName.isNotEmpty ? workoutName : 'Treino',
      ),
    );
  }
}

