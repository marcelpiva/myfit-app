import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../core/widgets/video_player_page.dart';
import '../../../../shared/presentation/components/components.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../training_plan/domain/models/prescription_note.dart';
import '../../../training_plan/presentation/widgets/prescription_notes_section.dart';
import '../providers/workout_provider.dart';

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
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: exercises.length + 1, // +1 for notes section
                    itemBuilder: (context, index) {
                      // First item is the notes section
                      if (index == 0) {
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
                      }

                      // Exercise cards (adjusted index)
                      final exercise = exercises[index - 1];
                      return _ExerciseCard(
                        exercise: exercise,
                        index: index, // index is already 1-based due to notes section
                        isDark: isDark,
                      );
                    },
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
                          context.push('/workouts/active/${widget.workoutId}');
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
}

class _ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final int index;
  final bool isDark;

  const _ExerciseCard({
    required this.exercise,
    required this.index,
    required this.isDark,
  });

  void _showExerciseDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.dumbbell,
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                        Text(
                          exercise['muscle'] ?? 'Peito',
                          style: TextStyle(
                            fontSize: 14,
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Séries',
                      '${exercise['sets']}',
                      LucideIcons.repeat,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Repetições',
                      '${exercise['reps']}',
                      LucideIcons.hash,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      'Descanso',
                      '${exercise['rest']}s',
                      LucideIcons.timer,
                    ),
                  ),
                ],
              ),
              if (exercise['notes'] != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Observações',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.mutedDark.withAlpha(100)
                        : AppColors.muted.withAlpha(150),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    exercise['notes'] ?? 'Manter a forma correta durante todo o movimento.',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Video button - only show if video_url exists
              // video_url can be at exercise['video_url'] or exercise['exercise']['video_url']
              Builder(
                builder: (context) {
                  final videoUrl = exercise['video_url'] as String? ??
                      (exercise['exercise'] as Map<String, dynamic>?)?['video_url'] as String?;
                  if (videoUrl == null || videoUrl.isEmpty) return const SizedBox.shrink();
                  return Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticUtils.lightImpact();
                            Navigator.pop(ctx);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VideoPlayerPage(
                                  videoUrl: videoUrl,
                                  title: exercise['name'] as String? ??
                                      (exercise['exercise'] as Map<String, dynamic>?)?['name'] as String?,
                                ),
                              ),
                            );
                          },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isDark
                                ? AppColors.primaryDark.withAlpha(30)
                                : AppColors.primary.withAlpha(30),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.playCircle,
                                size: 18,
                                color: isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ver Vídeo',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.primaryDark
                                      : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.mutedDark.withAlpha(150)
                : AppColors.muted.withAlpha(200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.primaryDark : AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        _showExerciseDetail(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Index
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Exercise info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise['name'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercise['sets']} séries x ${exercise['reps']}',
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

              // Rest time
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.mutedDark.withAlpha(150)
                      : AppColors.muted.withAlpha(200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.timer,
                      size: 12,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      exercise['rest'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // More button
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
