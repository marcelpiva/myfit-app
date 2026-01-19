import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/widgets/video_player_page.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../../../shared_session/domain/models/shared_session.dart';
import '../../../shared_session/presentation/providers/shared_session_provider.dart';
import '../../../shared_session/presentation/widgets/live_indicator.dart';
import '../../../shared_session/presentation/widgets/session_chat.dart';
import '../../../workout/presentation/providers/workout_provider.dart';

/// Active workout session page - used when student is doing their workout
class ActiveWorkoutPage extends ConsumerStatefulWidget {
  final String workoutId;
  final String? sessionId; // For co-training mode

  const ActiveWorkoutPage({
    super.key,
    required this.workoutId,
    this.sessionId,
  });

  @override
  ConsumerState<ActiveWorkoutPage> createState() => _ActiveWorkoutPageState();
}

class _ActiveWorkoutPageState extends ConsumerState<ActiveWorkoutPage> {
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  bool _isResting = false;
  int _restTimeRemaining = 0;
  Timer? _restTimer;

  // Track completed sets per exercise
  List<List<_SetData>> _completedSets = [];

  // Stopwatch for workout duration
  final _stopwatch = Stopwatch();
  Timer? _durationTimer;
  String _workoutDuration = '00:00';

  // Text controllers for weight and reps input
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();

  // Co-training state
  bool _isChatOpen = false;
  TrainerAdjustment? _pendingAdjustment;

  bool get _isSharedSession => widget.sessionId != null;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          final minutes = _stopwatch.elapsed.inMinutes;
          final seconds = _stopwatch.elapsed.inSeconds % 60;
          _workoutDuration =
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
      }
    });

    // Set session status to active if in co-training mode
    if (_isSharedSession) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(sharedSessionProvider(widget.sessionId!).notifier)
            .updateStatus(SessionStatus.active);
      });
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _durationTimer?.cancel();
    _stopwatch.stop();
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _initializeCompletedSets(int exerciseCount) {
    if (_completedSets.isEmpty || _completedSets.length != exerciseCount) {
      _completedSets = List.generate(exerciseCount, (_) => []);
    }
  }

  Map<String, dynamic>? _getCurrentExercise(List<Map<String, dynamic>> exercises) {
    if (exercises.isEmpty || _currentExerciseIndex >= exercises.length) {
      return null;
    }
    return exercises[_currentExerciseIndex];
  }

  int _getExerciseSets(Map<String, dynamic>? exercise) {
    return (exercise?['sets'] ?? 3) as int;
  }

  String _getExerciseReps(Map<String, dynamic>? exercise) {
    final reps = exercise?['reps'];
    if (reps == null) return '10';
    if (reps is int) return reps.toString();
    return reps.toString();
  }

  double _getExerciseWeight(Map<String, dynamic>? exercise) {
    final weight = exercise?['weight'];
    if (weight == null) return 0;
    if (weight is int) return weight.toDouble();
    if (weight is double) return weight;
    return double.tryParse(weight.toString()) ?? 0;
  }

  int _getExerciseRest(Map<String, dynamic>? exercise) {
    return (exercise?['rest_seconds'] ?? exercise?['rest'] ?? 60) as int;
  }

  void _startRestTimer(int restSeconds) {
    setState(() {
      _isResting = true;
      _restTimeRemaining = restSeconds;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restTimeRemaining > 0) {
        setState(() => _restTimeRemaining--);
      } else {
        _skipRest();
      }
    });
  }

  void _skipRest() {
    HapticUtils.lightImpact();
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _restTimeRemaining = 0;
    });
  }

  void _completeSet(List<Map<String, dynamic>> exercises) {
    HapticUtils.mediumImpact();
    final exercise = _getCurrentExercise(exercises);
    final exerciseSets = _getExerciseSets(exercise);
    final exerciseRest = _getExerciseRest(exercise);
    final defaultWeight = _getExerciseWeight(exercise);
    final exerciseId = exercise?['id'] as String? ?? exercise?['exercise_id'] as String? ?? '';

    final weight = double.tryParse(_weightController.text) ?? defaultWeight;
    final reps = int.tryParse(_repsController.text) ?? 10;

    // Broadcast to shared session if in co-training mode
    if (_isSharedSession) {
      ref.read(sharedSessionProvider(widget.sessionId!).notifier).recordSet(
        exerciseId: exerciseId,
        setNumber: _currentSet,
        reps: reps,
        weight: weight,
      );
    }

    setState(() {
      _completedSets[_currentExerciseIndex].add(_SetData(
        setNumber: _currentSet,
        reps: reps,
        weight: weight,
      ));

      // Clear text fields and pending adjustment
      _weightController.clear();
      _repsController.clear();
      _pendingAdjustment = null;

      if (_currentSet < exerciseSets) {
        _currentSet++;
        _startRestTimer(exerciseRest);
      } else {
        // Exercise complete, move to next
        if (_currentExerciseIndex < exercises.length - 1) {
          _currentExerciseIndex++;
          _currentSet = 1;
        } else {
          // Workout complete!
          _showWorkoutComplete(exercises.length);
        }
      }
    });
  }

  void _showWorkoutComplete(int exerciseCount) {
    _stopwatch.stop();
    HapticUtils.heavyImpact();

    // Update shared session status if in co-training mode
    if (_isSharedSession) {
      ref.read(sharedSessionProvider(widget.sessionId!).notifier)
          .updateStatus(SessionStatus.completed);
    }
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) => _WorkoutCompleteSheet(
        duration: _workoutDuration,
        exercisesCompleted: exerciseCount,
        totalSets: _completedSets.fold(0, (sum, sets) => sum + sets.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final detailState = ref.watch(workoutDetailNotifierProvider(widget.workoutId));
    final exercises = detailState.exercises;
    final workoutName = detailState.name;

    // Co-training state
    SharedSessionState? sharedState;
    if (_isSharedSession) {
      sharedState = ref.watch(sharedSessionProvider(widget.sessionId!));
      // Check for new adjustments
      _checkForNewAdjustments(sharedState);
    }

    // Initialize completed sets tracking when exercises are loaded
    if (exercises.isNotEmpty) {
      _initializeCompletedSets(exercises.length);
    }

    // Show loading state
    if (detailState.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Carregando treino...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    // Show error state
    if (detailState.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.alertCircle, size: 48, color: AppColors.destructive),
              const SizedBox(height: 16),
              Text(
                detailState.error!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    // Show empty state
    if (exercises.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.dumbbell, size: 48, color: AppColors.mutedForeground),
              const SizedBox(height: 16),
              Text(
                'Nenhum exercício encontrado',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    final currentExercise = _getCurrentExercise(exercises);
    final exerciseSets = _getExerciseSets(currentExercise);
    final progress =
        (_currentExerciseIndex + (_currentSet - 1) / exerciseSets) / exercises.length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
        child: Column(
          children: [
            // Custom AppBar
            SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        _showExitConfirmation(context);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.cardDark : AppColors.card)
                              .withAlpha(isDark ? 150 : 200),
                          border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(LucideIcons.arrowLeft,
                            size: 20,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            workoutName.isNotEmpty ? workoutName : 'Treino',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _workoutDuration,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Co-training live indicator
                    if (_isSharedSession)
                      LiveIndicator(
                        isConnected: sharedState?.isConnected ?? false,
                        isShared: sharedState?.session?.isShared ?? false,
                      ),
                    // Chat button for co-training
                    if (_isSharedSession)
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () {
                              HapticUtils.lightImpact();
                              setState(() => _isChatOpen = !_isChatOpen);
                            },
                            icon: Icon(
                              _isChatOpen ? LucideIcons.x : LucideIcons.messageCircle,
                            ),
                          ),
                          if ((sharedState?.session?.messages.length ?? 0) > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.destructive,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${sharedState?.session?.messages.length ?? 0}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    if (!_isSharedSession)
                      IconButton(
                        onPressed: () {
                          HapticUtils.lightImpact();
                        },
                        icon: const Icon(LucideIcons.volumeX),
                      ),
                  ],
                ),
              ),
            ),
            // Progress bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.surfaceContainerLow,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 4,
                ),
              ),
            ),

            Expanded(
              child: Row(
                children: [
                  // Main workout content
                  Expanded(
                    child: _isResting
                        ? _buildRestScreen(theme, isDark, currentExercise, exerciseSets)
                        : _buildExerciseScreen(theme, isDark, exercises, currentExercise, sharedState),
                  ),
                  // Chat panel (side panel on larger screens)
                  if (_isSharedSession && _isChatOpen && MediaQuery.of(context).size.width > 600)
                    SizedBox(
                      width: 320,
                      child: SessionChat(
                        sessionId: widget.sessionId!,
                        messages: sharedState?.session?.messages ?? [],
                        onClose: () => setState(() => _isChatOpen = false),
                      ),
                    ),
                ],
              ),
            ),
            // Chat panel (bottom sheet on smaller screens)
            if (_isSharedSession && _isChatOpen && MediaQuery.of(context).size.width <= 600)
              SizedBox(
                height: 300,
                child: SessionChat(
                  sessionId: widget.sessionId!,
                  messages: sharedState?.session?.messages ?? [],
                  onClose: () => setState(() => _isChatOpen = false),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _checkForNewAdjustments(SharedSessionState? sharedState) {
    if (sharedState?.session?.adjustments.isEmpty ?? true) return;
    final latestAdjustment = sharedState!.session!.adjustments.last;
    if (_pendingAdjustment?.id != latestAdjustment.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _pendingAdjustment = latestAdjustment;
        });
        _showAdjustmentNotification(latestAdjustment);
      });
    }
  }

  void _showAdjustmentNotification(TrainerAdjustment adjustment) {
    final parts = <String>[];
    if (adjustment.suggestedWeightKg != null) {
      final sign = adjustment.suggestedWeightKg! > 0 ? '+' : '';
      parts.add('$sign${adjustment.suggestedWeightKg}kg');
    }
    if (adjustment.suggestedReps != null) {
      if (adjustment.suggestedReps == 99) {
        parts.add('AMRAP');
      } else {
        final sign = adjustment.suggestedReps! > 0 ? '+' : '';
        parts.add('$sign${adjustment.suggestedReps} reps');
      }
    }
    if (adjustment.note != null) {
      parts.add(adjustment.note!);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.userCheck, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ajuste do Personal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(parts.join(' • ')),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Aplicar',
          onPressed: () {
            // Apply the adjustment to the current inputs
            if (adjustment.suggestedWeightKg != null) {
              final currentWeight = double.tryParse(_weightController.text) ?? 0;
              _weightController.text = (currentWeight + adjustment.suggestedWeightKg!).toString();
            }
            if (adjustment.suggestedReps != null && adjustment.suggestedReps != 99) {
              final currentReps = int.tryParse(_repsController.text) ?? 10;
              _repsController.text = (currentReps + adjustment.suggestedReps!).toString();
            }
          },
        ),
      ),
    );
  }

  Widget _buildExerciseScreen(
    ThemeData theme,
    bool isDark,
    List<Map<String, dynamic>> exercises,
    Map<String, dynamic>? currentExercise,
    SharedSessionState? sharedState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Trainer adjustment banner (if pending)
          if (_isSharedSession && _pendingAdjustment != null)
            FadeInUp(
              child: _buildAdjustmentBanner(theme, _pendingAdjustment!),
            ),

          // Exercise navigation
          FadeInUp(
            child: _buildExerciseNav(theme, exercises),
          ),

          const SizedBox(height: 24),

          // Main exercise card
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: _buildExerciseCard(theme, isDark, currentExercise),
          ),

          const SizedBox(height: 24),

          // Set tracker
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildSetTracker(theme, isDark, currentExercise),
          ),

          const SizedBox(height: 24),

          // Log set section
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildLogSection(theme, isDark, exercises, currentExercise),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildAdjustmentBanner(ThemeData theme, TrainerAdjustment adjustment) {
    final parts = <String>[];
    if (adjustment.suggestedWeightKg != null) {
      final sign = adjustment.suggestedWeightKg! > 0 ? '+' : '';
      parts.add('$sign${adjustment.suggestedWeightKg}kg');
    }
    if (adjustment.suggestedReps != null) {
      if (adjustment.suggestedReps == 99) {
        parts.add('AMRAP');
      } else {
        final sign = adjustment.suggestedReps! > 0 ? '+' : '';
        parts.add('$sign${adjustment.suggestedReps} reps');
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.userCheck, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sugestão do Personal',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  parts.join(' • '),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (adjustment.note != null)
                  Text(
                    adjustment.note!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Apply the adjustment
              if (adjustment.suggestedWeightKg != null) {
                final currentWeight = double.tryParse(_weightController.text) ?? 0;
                _weightController.text = (currentWeight + adjustment.suggestedWeightKg!).toString();
              }
              if (adjustment.suggestedReps != null && adjustment.suggestedReps != 99) {
                final currentReps = int.tryParse(_repsController.text) ?? 10;
                _repsController.text = (currentReps + adjustment.suggestedReps!).toString();
              }
              setState(() {
                _pendingAdjustment = null;
              });
            },
            child: const Text('Aplicar'),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _pendingAdjustment = null;
              });
            },
            icon: const Icon(LucideIcons.x, size: 18),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseNav(ThemeData theme, List<Map<String, dynamic>> exercises) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: _currentExerciseIndex > 0
              ? () {
                  HapticUtils.lightImpact();
                  setState(() {
                    _currentExerciseIndex--;
                    _currentSet = _completedSets[_currentExerciseIndex].length + 1;
                    final exerciseSets =
                        _getExerciseSets(_getCurrentExercise(exercises));
                    if (_currentSet > exerciseSets) {
                      _currentSet = exerciseSets;
                    }
                  });
                }
              : null,
          icon: const Icon(LucideIcons.chevronLeft, size: 18),
          label: const Text('Anterior'),
        ),
        Text(
          '${_currentExerciseIndex + 1} de ${exercises.length}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton.icon(
          onPressed: _currentExerciseIndex < exercises.length - 1
              ? () {
                  HapticUtils.lightImpact();
                  setState(() {
                    _currentExerciseIndex++;
                    _currentSet = _completedSets[_currentExerciseIndex].length + 1;
                    final exerciseSets =
                        _getExerciseSets(_getCurrentExercise(exercises));
                    if (_currentSet > exerciseSets) {
                      _currentSet = exerciseSets;
                    }
                  });
                }
              : null,
          label: const Text('Próximo'),
          icon: const Icon(LucideIcons.chevronRight, size: 18),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(
    ThemeData theme,
    bool isDark,
    Map<String, dynamic>? exercise,
  ) {
    final name = exercise?['name'] ?? exercise?['exercise_name'] ?? 'Exercício';
    final muscleGroup = exercise?['muscle_group'] ?? exercise?['muscle'] ?? '';
    final notes = exercise?['notes'] ?? '';
    final sets = _getExerciseSets(exercise);
    final reps = _getExerciseReps(exercise);
    final weight = _getExerciseWeight(exercise);
    final rest = _getExerciseRest(exercise);
    // video_url and image_url can be at root level or nested in 'exercise'
    final exerciseData = exercise?['exercise'] as Map<String, dynamic>?;
    final videoUrl = exercise?['video_url'] as String? ?? exerciseData?['video_url'] as String?;
    final imageUrl = exercise?['image_url'] as String? ?? exerciseData?['image_url'] as String?;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLowest.withAlpha(150)
            : theme.colorScheme.surfaceContainerLowest.withAlpha(200),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Video/Image area
          GestureDetector(
            onTap: videoUrl != null && videoUrl.isNotEmpty
                ? () {
                    HapticUtils.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerPage(
                          videoUrl: videoUrl,
                          title: name,
                        ),
                      ),
                    );
                  }
                : null,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                    : theme.colorScheme.surfaceContainerLow.withAlpha(200),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: theme.colorScheme.surfaceContainerLow,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: theme.colorScheme.surfaceContainerLow,
                              child: Icon(
                                LucideIcons.image,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        if (videoUrl != null && videoUrl.isNotEmpty)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(150),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.play,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            videoUrl != null && videoUrl.isNotEmpty
                                ? LucideIcons.playCircle
                                : LucideIcons.image,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            videoUrl != null && videoUrl.isNotEmpty
                                ? 'Ver demonstração'
                                : 'Sem imagem',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          // Exercise info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (muscleGroup.isNotEmpty)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          muscleGroup,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.info,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          notes,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                // Target stats
                Row(
                  children: [
                    _buildTargetStat(theme, 'Séries', '$sets', LucideIcons.repeat),
                    const SizedBox(width: 24),
                    _buildTargetStat(theme, 'Reps', reps, LucideIcons.hash),
                    const SizedBox(width: 24),
                    _buildTargetStat(
                      theme,
                      'Peso',
                      weight > 0 ? '${weight.toStringAsFixed(weight.truncateToDouble() == weight ? 0 : 1)}kg' : '--',
                      LucideIcons.dumbbell,
                    ),
                    const SizedBox(width: 24),
                    _buildTargetStat(theme, 'Descanso', '${rest}s', LucideIcons.timer),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetStat(ThemeData theme, String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSetTracker(
    ThemeData theme,
    bool isDark,
    Map<String, dynamic>? exercise,
  ) {
    final exerciseSets = _getExerciseSets(exercise);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progresso das Séries',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(exerciseSets, (index) {
            final setNumber = index + 1;
            final isCompleted =
                _completedSets.isNotEmpty &&
                _currentExerciseIndex < _completedSets.length &&
                _completedSets[_currentExerciseIndex].any((s) => s.setNumber == setNumber);
            final isCurrent = setNumber == _currentSet;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticUtils.selectionClick();
                },
                child: Container(
                  margin: EdgeInsets.only(right: index < exerciseSets - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.success.withValues(alpha: 0.2)
                        : isCurrent
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : isDark
                                ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                                : theme.colorScheme.surfaceContainerLow.withAlpha(200),
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.success
                          : isCurrent
                              ? AppColors.primary
                              : theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: isCurrent ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      if (isCompleted)
                        Icon(LucideIcons.check, size: 16, color: AppColors.success)
                      else
                        Text(
                          '$setNumber',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? AppColors.primary : null,
                          ),
                        ),
                      if (isCompleted &&
                          _completedSets.isNotEmpty &&
                          _currentExerciseIndex < _completedSets.length &&
                          index < _completedSets[_currentExerciseIndex].length) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${_completedSets[_currentExerciseIndex][index].weight}kg',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLogSection(
    ThemeData theme,
    bool isDark,
    List<Map<String, dynamic>> exercises,
    Map<String, dynamic>? exercise,
  ) {
    final exerciseSets = _getExerciseSets(exercise);
    final reps = _getExerciseReps(exercise);
    final weight = _getExerciseWeight(exercise);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLowest.withAlpha(150)
            : theme.colorScheme.surfaceContainerLowest.withAlpha(200),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Série $_currentSet de $exerciseSets',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Peso (kg)',
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: weight > 0 ? weight.toStringAsFixed(weight.truncateToDouble() == weight ? 0 : 1) : '0',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Repetições',
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: reps,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _completeSet(exercises),
              icon: const Icon(LucideIcons.check, size: 18),
              label: const Text('Completar Série'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestScreen(
    ThemeData theme,
    bool isDark,
    Map<String, dynamic>? exercise,
    int exerciseSets,
  ) {
    final exerciseRest = _getExerciseRest(exercise);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Descanse',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 8,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: exerciseRest > 0 ? _restTimeRemaining / exerciseRest : 0,
                    strokeWidth: 8,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_restTimeRemaining',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'segundos',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Próxima: Série $_currentSet de $exerciseSets',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  HapticUtils.lightImpact();
                  setState(() {
                    _restTimeRemaining += 30;
                  });
                },
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('+30s'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: _skipRest,
                icon: const Icon(LucideIcons.skipForward, size: 18),
                label: const Text('Pular'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    HapticUtils.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Sair do treino?'),
        content: const Text('Seu progresso será salvo, mas o treino ficará incompleto.'),
        actions: [
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('Continuar'),
          ),
          FilledButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(context);
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCompleteSheet extends StatelessWidget {
  final String duration;
  final int exercisesCompleted;
  final int totalSets;

  const _WorkoutCompleteSheet({
    required this.duration,
    required this.exercisesCompleted,
    required this.totalSets,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withAlpha(150)
            : theme.colorScheme.surface.withAlpha(200),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.trophy,
              size: 48,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Treino Concluído!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Excelente trabalho! Continue assim.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCompleteStat(theme, duration, 'Duração', LucideIcons.clock),
              _buildCompleteStat(theme, '$exercisesCompleted', 'Exercícios', LucideIcons.dumbbell),
              _buildCompleteStat(theme, '$totalSets', 'Séries', LucideIcons.repeat),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                HapticUtils.mediumImpact();
                Navigator.pop(context);
                context.pop();
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Finalizar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteStat(ThemeData theme, String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SetData {
  final int setNumber;
  final int reps;
  final double weight;

  _SetData({required this.setNumber, required this.reps, required this.weight});
}
