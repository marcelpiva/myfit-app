import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/workout_service.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Feedback type enum matching backend
enum ExerciseFeedbackType {
  liked('liked'),
  disliked('disliked'),
  swap('swap');

  final String value;
  const ExerciseFeedbackType(this.value);
}

/// Widget for exercise feedback (thumbs up, thumbs down, swap)
/// Shown after completing an exercise or all sets
class ExerciseFeedbackWidget extends ConsumerStatefulWidget {
  final String sessionId;
  final String workoutExerciseId;
  final String exerciseName;
  final VoidCallback? onFeedbackSubmitted;

  const ExerciseFeedbackWidget({
    super.key,
    required this.sessionId,
    required this.workoutExerciseId,
    required this.exerciseName,
    this.onFeedbackSubmitted,
  });

  @override
  ConsumerState<ExerciseFeedbackWidget> createState() => _ExerciseFeedbackWidgetState();
}

class _ExerciseFeedbackWidgetState extends ConsumerState<ExerciseFeedbackWidget> {
  ExerciseFeedbackType? _selectedFeedback;
  bool _isSubmitting = false;
  bool _showCommentField = false;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback(ExerciseFeedbackType type) async {
    if (_isSubmitting) return;

    // For swap, show comment field first
    if (type == ExerciseFeedbackType.swap && !_showCommentField) {
      setState(() {
        _selectedFeedback = type;
        _showCommentField = true;
      });
      return;
    }

    setState(() {
      _selectedFeedback = type;
      _isSubmitting = true;
    });

    HapticUtils.mediumImpact();

    try {
      final workoutService = WorkoutService();
      await workoutService.submitExerciseFeedback(
        widget.sessionId,
        widget.workoutExerciseId,
        feedbackType: type.value,
        comment: _showCommentField ? _commentController.text.trim() : null,
      );

      if (mounted) {
        widget.onFeedbackSubmitted?.call();

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  type == ExerciseFeedbackType.liked
                      ? LucideIcons.thumbsUp
                      : type == ExerciseFeedbackType.disliked
                          ? LucideIcons.thumbsDown
                          : LucideIcons.repeat,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  type == ExerciseFeedbackType.swap
                      ? 'Solicitação de troca enviada'
                      : 'Feedback enviado',
                ),
              ],
            ),
            backgroundColor: type == ExerciseFeedbackType.liked
                ? AppColors.success
                : type == ExerciseFeedbackType.disliked
                    ? AppColors.warning
                    : AppColors.info,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar feedback: $e'),
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

    if (_selectedFeedback != null && !_showCommentField) {
      // Already submitted - show confirmation
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.success.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withAlpha(40)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.checkCircle, size: 16, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              'Feedback enviado',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'O que achou deste exercício?',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ),

        // Feedback buttons
        Row(
          children: [
            // Liked button
            Expanded(
              child: _FeedbackButton(
                icon: LucideIcons.thumbsUp,
                label: 'Gostei',
                color: AppColors.success,
                isSelected: _selectedFeedback == ExerciseFeedbackType.liked,
                isDisabled: _isSubmitting,
                onTap: () => _submitFeedback(ExerciseFeedbackType.liked),
              ),
            ),
            const SizedBox(width: 8),

            // Disliked button
            Expanded(
              child: _FeedbackButton(
                icon: LucideIcons.thumbsDown,
                label: 'Não gostei',
                color: AppColors.warning,
                isSelected: _selectedFeedback == ExerciseFeedbackType.disliked,
                isDisabled: _isSubmitting,
                onTap: () => _submitFeedback(ExerciseFeedbackType.disliked),
              ),
            ),
            const SizedBox(width: 8),

            // Swap button
            Expanded(
              child: _FeedbackButton(
                icon: LucideIcons.repeat,
                label: 'Trocar',
                color: AppColors.info,
                isSelected: _selectedFeedback == ExerciseFeedbackType.swap,
                isDisabled: _isSubmitting,
                onTap: () => _submitFeedback(ExerciseFeedbackType.swap),
              ),
            ),
          ],
        ),

        // Comment field for swap requests
        if (_showCommentField) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 2,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Por que deseja trocar este exercício? (opcional)',
              hintStyle: TextStyle(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
              counterText: '',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _showCommentField = false;
                            _selectedFeedback = null;
                          });
                        },
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isSubmitting
                      ? null
                      : () => _submitFeedback(ExerciseFeedbackType.swap),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(LucideIcons.send, size: 16),
                  label: Text(_isSubmitting ? 'Enviando...' : 'Enviar'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Individual feedback button
class _FeedbackButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _FeedbackButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: isDisabled ? null : () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withAlpha(30)
              : (isDark ? AppColors.cardDark : AppColors.card),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? color
                  : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? color
                    : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact inline version for showing in exercise cards
class ExerciseFeedbackInline extends StatelessWidget {
  final String sessionId;
  final String workoutExerciseId;
  final String exerciseName;

  const ExerciseFeedbackInline({
    super.key,
    required this.sessionId,
    required this.workoutExerciseId,
    required this.exerciseName,
  });

  @override
  Widget build(BuildContext context) {
    return ExerciseFeedbackWidget(
      sessionId: sessionId,
      workoutExerciseId: workoutExerciseId,
      exerciseName: exerciseName,
    );
  }
}

/// Shows feedback dialog after completing all sets of an exercise
Future<void> showExerciseFeedbackDialog(
  BuildContext context, {
  required String sessionId,
  required String workoutExerciseId,
  required String exerciseName,
}) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.of(ctx).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            exerciseName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Feedback widget
          ExerciseFeedbackWidget(
            sessionId: sessionId,
            workoutExerciseId: workoutExerciseId,
            exerciseName: exerciseName,
            onFeedbackSubmitted: () {
              Navigator.of(ctx).pop();
            },
          ),

          const SizedBox(height: 16),

          // Skip button
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Pular',
              style: TextStyle(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
