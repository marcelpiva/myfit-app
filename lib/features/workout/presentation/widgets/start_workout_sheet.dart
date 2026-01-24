import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../home/data/models/student_dashboard.dart';
import '../../../home/presentation/providers/student_home_provider.dart';

/// Bottom sheet for choosing how to start a workout
/// Options: Train Alone vs Train with Personal
class StartWorkoutSheet extends ConsumerStatefulWidget {
  final String workoutId;
  final String workoutName;
  final String? assignmentId;

  const StartWorkoutSheet({
    super.key,
    required this.workoutId,
    required this.workoutName,
    this.assignmentId,
  });

  @override
  ConsumerState<StartWorkoutSheet> createState() => _StartWorkoutSheetState();
}

class _StartWorkoutSheetState extends ConsumerState<StartWorkoutSheet> {
  bool _isLoading = false;

  Future<void> _startAlone() async {
    HapticUtils.mediumImpact();
    Navigator.pop(context);
    context.push('/workouts/active/${widget.workoutId}');
  }

  Future<void> _requestCoTraining() async {
    HapticUtils.mediumImpact();
    setState(() => _isLoading = true);

    // Navigate to waiting screen, which will create the co-training session
    Navigator.pop(context);
    context.push(
      '/workouts/waiting-trainer/${widget.workoutId}',
      extra: {
        'workoutName': widget.workoutName,
        'assignmentId': widget.assignmentId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dashboardState = ref.watch(studentDashboardProvider);

    final canTrainWithPersonal = dashboardState.canTrainWithPersonal;
    final hasTrainer = dashboardState.hasTrainer;
    final trainer = dashboardState.trainer;
    final trainingMode = dashboardState.trainingMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
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

              // Title
              Text(
                'Iniciar Treino',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Workout name
              Text(
                widget.workoutName,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Option 1: Train Alone
              Semantics(
                label: 'start-workout-solo',
                button: true,
                child: _OptionCard(
                  icon: LucideIcons.user,
                  title: 'Treinar Sozinho',
                  subtitle: 'Registre seu treino de forma independente',
                  onTap: _isLoading ? null : _startAlone,
                  isDark: isDark,
                  isEnabled: true,
                ),
              ),

              const SizedBox(height: 12),

              // Option 2: Train with Personal
              Semantics(
                label: 'cotraining-mode',
                button: true,
                child: _OptionCard(
                  icon: LucideIcons.users,
                  title: 'Treinar com Personal',
                  subtitle: canTrainWithPersonal && hasTrainer
                      ? 'Solicitar acompanhamento de ${trainer?.name ?? "seu personal"}'
                      : trainingMode == TrainingMode.online
                          ? 'Seu plano é consultoria online'
                          : 'Você não possui um personal vinculado',
                  onTap: canTrainWithPersonal && hasTrainer && !_isLoading
                      ? _requestCoTraining
                      : null,
                  isDark: isDark,
                  isEnabled: canTrainWithPersonal && hasTrainer,
                  showBadge: canTrainWithPersonal && hasTrainer && (trainer?.isOnline ?? false),
                  badgeText: 'Online',
                ),
              ),

              if (_isLoading) ...[
                const SizedBox(height: 24),
                const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Training mode info
              if (trainingMode == TrainingMode.hibrido) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withAlpha(50),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.info,
                        size: 16,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Seu plano é híbrido: você pode treinar sozinho ou com acompanhamento presencial.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDark;
  final bool isEnabled;
  final bool showBadge;
  final String? badgeText;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
    required this.isEnabled,
    this.showBadge = false,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.backgroundDark.withAlpha(150)
                : AppColors.background.withAlpha(200),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? AppColors.primary.withAlpha(25)
                      : (isDark
                          ? AppColors.mutedDark.withAlpha(100)
                          : AppColors.muted.withAlpha(150)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isEnabled
                      ? (isDark ? AppColors.primaryDark : AppColors.primary)
                      : (isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground),
                ),
              ),

              const SizedBox(width: 14),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                        ),
                        if (showBadge && badgeText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  badgeText!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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

              const SizedBox(width: 8),

              // Arrow
              Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: isEnabled
                    ? (isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground)
                    : (isDark
                        ? AppColors.mutedDark
                        : AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
