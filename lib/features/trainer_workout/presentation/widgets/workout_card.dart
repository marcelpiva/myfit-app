import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/models/trainer_workout.dart';

/// Card que exibe um treino criado pelo trainer
class WorkoutCard extends StatelessWidget {
  final TrainerWorkout workout;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onEvolve;
  final VoidCallback? onPause;
  final VoidCallback? onActivate;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final bool showProgress;

  const WorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
    this.onEdit,
    this.onEvolve,
    this.onPause,
    this.onActivate,
    this.onDelete,
    this.onDuplicate,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          border: Border.all(
            color: _getBorderColor(isDark),
            width: workout.status == WorkoutAssignmentStatus.active ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withAlpha(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(),
                        size: 12,
                        color: _getStatusColor(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusLabel(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Difficulty badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor().withAlpha(25),
                  ),
                  child: Text(
                    _getDifficultyLabel(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getDifficultyColor(),
                    ),
                  ),
                ),
                const Spacer(),
                // AI badge
                if (workout.aiGenerated)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                    ),
                    child: const Icon(LucideIcons.sparkles, size: 14, color: Colors.white),
                  ),
                // More options
                if (onEdit != null || onEvolve != null || onPause != null || onDelete != null)
                  PopupMenuButton(
                    icon: Icon(
                      LucideIcons.moreVertical,
                      size: 20,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    itemBuilder: (context) => [
                      if (onEdit != null)
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(LucideIcons.edit, size: 18),
                              const SizedBox(width: 12),
                              const Text('Editar'),
                            ],
                          ),
                        ),
                      if (onEvolve != null)
                        PopupMenuItem(
                          value: 'evolve',
                          child: Row(
                            children: [
                              const Icon(LucideIcons.trendingUp, size: 18),
                              const SizedBox(width: 12),
                              const Text('Evoluir'),
                            ],
                          ),
                        ),
                      if (onPause != null)
                        PopupMenuItem(
                          value: 'pause',
                          child: Row(
                            children: [
                              const Icon(LucideIcons.pause, size: 18),
                              const SizedBox(width: 12),
                              const Text('Pausar'),
                            ],
                          ),
                        ),
                      if (onActivate != null)
                        PopupMenuItem(
                          value: 'activate',
                          child: Row(
                            children: [
                              const Icon(LucideIcons.play, size: 18),
                              const SizedBox(width: 12),
                              const Text('Ativar'),
                            ],
                          ),
                        ),
                      if (onDuplicate != null)
                        PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              const Icon(LucideIcons.copy, size: 18),
                              const SizedBox(width: 12),
                              const Text('Duplicar'),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(LucideIcons.trash2, size: 18, color: AppColors.destructive),
                              const SizedBox(width: 12),
                              Text('Excluir', style: TextStyle(color: AppColors.destructive)),
                            ],
                          ),
                        ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'evolve':
                          onEvolve?.call();
                          break;
                        case 'pause':
                          onPause?.call();
                          break;
                        case 'activate':
                          onActivate?.call();
                          break;
                        case 'duplicate':
                          onDuplicate?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Title & description
            Text(
              workout.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            if (workout.description != null) ...[
              const SizedBox(height: 4),
              Text(
                workout.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                _buildStat(isDark, LucideIcons.list, '${workout.exerciseCount} exercícios'),
                const SizedBox(width: 16),
                _buildStat(isDark, LucideIcons.clock, '${workout.estimatedDurationMinutes} min'),
                if (workout.weekNumber != null) ...[
                  const SizedBox(width: 16),
                  _buildStat(
                    isDark,
                    LucideIcons.calendar,
                    'Semana ${workout.weekNumber}/${workout.totalWeeks ?? '?'}',
                  ),
                ],
              ],
            ),

            // Progress bar (if applicable)
            if (showProgress && workout.totalSessions > 0) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progresso',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                      Text(
                        '${workout.completedSessions}/${workout.totalSessions} sessões',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: workout.progressPercent / 100,
                    backgroundColor: isDark ? AppColors.mutedDark : AppColors.muted,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 6,
                  ),
                ],
              ),
            ],

            // Trainer notes (if available)
            if (workout.trainerNotes != null && workout.trainerNotes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(15),
                  border: Border.all(color: AppColors.info.withAlpha(30)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.messageSquare, size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        workout.trainerNotes!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.info,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Quick action buttons
            if (workout.status == WorkoutAssignmentStatus.active && onEvolve != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(LucideIcons.edit, size: 16),
                      label: const Text('Editar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onEvolve,
                      icon: const Icon(LucideIcons.trendingUp, size: 16),
                      label: const Text('Evoluir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Activate button for drafts
            if (workout.status == WorkoutAssignmentStatus.draft && onActivate != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onActivate,
                  icon: const Icon(LucideIcons.send, size: 16),
                  label: const Text('Enviar para Aluno'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(bool isDark, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Color _getBorderColor(bool isDark) {
    switch (workout.status) {
      case WorkoutAssignmentStatus.active:
        return AppColors.success;
      case WorkoutAssignmentStatus.draft:
        return AppColors.warning;
      case WorkoutAssignmentStatus.paused:
        return AppColors.warning;
      default:
        return isDark ? AppColors.borderDark : AppColors.border;
    }
  }

  Color _getStatusColor() {
    switch (workout.status) {
      case WorkoutAssignmentStatus.active:
        return AppColors.success;
      case WorkoutAssignmentStatus.draft:
        return AppColors.warning;
      case WorkoutAssignmentStatus.paused:
        return AppColors.warning;
      case WorkoutAssignmentStatus.completed:
        return AppColors.primary;
      case WorkoutAssignmentStatus.archived:
        return AppColors.mutedForeground;
    }
  }

  IconData _getStatusIcon() {
    switch (workout.status) {
      case WorkoutAssignmentStatus.active:
        return LucideIcons.play;
      case WorkoutAssignmentStatus.draft:
        return LucideIcons.fileEdit;
      case WorkoutAssignmentStatus.paused:
        return LucideIcons.pause;
      case WorkoutAssignmentStatus.completed:
        return LucideIcons.checkCircle;
      case WorkoutAssignmentStatus.archived:
        return LucideIcons.archive;
    }
  }

  String _getStatusLabel() {
    switch (workout.status) {
      case WorkoutAssignmentStatus.active:
        return 'Ativo';
      case WorkoutAssignmentStatus.draft:
        return 'Rascunho';
      case WorkoutAssignmentStatus.paused:
        return 'Pausado';
      case WorkoutAssignmentStatus.completed:
        return 'Completo';
      case WorkoutAssignmentStatus.archived:
        return 'Arquivado';
    }
  }

  Color _getDifficultyColor() {
    switch (workout.difficulty) {
      case WorkoutDifficulty.beginner:
        return AppColors.success;
      case WorkoutDifficulty.intermediate:
        return AppColors.info;
      case WorkoutDifficulty.advanced:
        return AppColors.warning;
      case WorkoutDifficulty.elite:
        return AppColors.destructive;
    }
  }

  String _getDifficultyLabel() {
    switch (workout.difficulty) {
      case WorkoutDifficulty.beginner:
        return 'Iniciante';
      case WorkoutDifficulty.intermediate:
        return 'Intermediário';
      case WorkoutDifficulty.advanced:
        return 'Avançado';
      case WorkoutDifficulty.elite:
        return 'Elite';
    }
  }
}
