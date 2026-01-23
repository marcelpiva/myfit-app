import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/exercise_theme.dart';
import '../../../training_plan/domain/models/training_plan.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../../../shared_session/domain/models/shared_session.dart';
import '../../../shared_session/presentation/providers/shared_session_provider.dart';
import '../../../shared_session/presentation/widgets/live_indicator.dart';
import '../../../shared_session/presentation/widgets/session_chat.dart';
import '../../../workout/presentation/providers/workout_provider.dart';
import '../widgets/exercise_card_compact.dart';
import '../widgets/exercise_page_view.dart';
import '../widgets/pr_indicator.dart';
import '../widgets/rest_timer_overlay.dart';
import '../widgets/set_input_stepper.dart';
import '../widgets/workout_celebration.dart';
import '../widgets/workout_notes_banner.dart';

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

  // Weight and reps values (using steppers instead of text controllers)
  double _currentWeight = 0;
  double _currentReps = 10;

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

  /// Get the TechniqueType from the current exercise for theming
  TechniqueType _getExerciseTechnique(Map<String, dynamic>? exercise) {
    final techniqueStr = exercise?['technique_type'] as String?;
    if (techniqueStr == null || techniqueStr.isEmpty) {
      return TechniqueType.normal;
    }
    switch (techniqueStr.toLowerCase()) {
      case 'bi_set':
      case 'bi-set':
      case 'biset':
        return TechniqueType.biset;
      case 'tri_set':
      case 'tri-set':
      case 'triset':
        return TechniqueType.triset;
      case 'superset':
      case 'super_set':
        return TechniqueType.superset;
      case 'giant_set':
      case 'giant-set':
      case 'giantset':
        return TechniqueType.giantset;
      case 'dropset':
      case 'drop_set':
        return TechniqueType.dropset;
      case 'rest_pause':
      case 'rest-pause':
      case 'restpause':
        return TechniqueType.restPause;
      case 'cluster':
      case 'cluster_set':
        return TechniqueType.cluster;
      default:
        return TechniqueType.normal;
    }
  }

  /// Check if the current exercise has a group technique (superset, biset, etc.)
  bool _hasGroupTechnique(Map<String, dynamic>? exercise) {
    final technique = _getExerciseTechnique(exercise);
    return ExerciseTheme.isGroupTechnique(technique);
  }

  /// Get the accent color for the current exercise (based on technique)
  Color _getExerciseAccentColor(Map<String, dynamic>? exercise) {
    final technique = _getExerciseTechnique(exercise);
    if (technique == TechniqueType.normal) {
      return AppColors.primary;
    }
    return ExerciseTheme.getColor(technique);
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
    final defaultReps = int.tryParse(_getExerciseReps(exercise)) ?? 10;
    final exerciseId = exercise?['id'] as String? ?? exercise?['exercise_id'] as String? ?? '';

    final weight = _currentWeight > 0 ? _currentWeight : defaultWeight;
    final reps = _currentReps > 0 ? _currentReps.toInt() : defaultReps;

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

      // Reset input values and pending adjustment
      _currentWeight = 0;
      _currentReps = defaultReps.toDouble();
      _pendingAdjustment = null;

      if (_currentSet < exerciseSets) {
        _currentSet++;
        _startRestTimer(exerciseRest);
      } else {
        // Exercise complete, move to next
        if (_currentExerciseIndex < exercises.length - 1) {
          _currentExerciseIndex++;
          _currentSet = 1;
          // Reset to new exercise defaults
          final nextExercise = _getCurrentExercise(exercises);
          _currentWeight = _getExerciseWeight(nextExercise);
          _currentReps = (int.tryParse(_getExerciseReps(nextExercise)) ?? 10).toDouble();
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

    // Get accent color based on current exercise technique
    final accentColor = _getExerciseAccentColor(currentExercise);
    final hasGroupTechnique = _hasGroupTechnique(currentExercise);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withAlpha(isDark ? 20 : 15),
              (hasGroupTechnique ? accentColor : AppColors.secondary)
                  .withAlpha(isDark ? 12 : 8),
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
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(begin: accentColor, end: accentColor),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, color, child) => LinearProgressIndicator(
                    value: progress,
                    backgroundColor: theme.colorScheme.surfaceContainerLow,
                    valueColor: AlwaysStoppedAnimation<Color>(color ?? accentColor),
                    minHeight: 4,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  // Main workout content
                  Row(
                    children: [
                      Expanded(
                        child: _buildExerciseScreen(theme, isDark, exercises, currentExercise, sharedState, accentColor: accentColor),
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
                  // Rest timer overlay (with blur)
                  if (_isResting)
                    Positioned.fill(
                      child: RestTimerOverlay(
                        timeRemaining: _restTimeRemaining,
                        totalTime: _getExerciseRest(currentExercise),
                        currentSet: _currentSet,
                        totalSets: exerciseSets,
                        onSkip: _skipRest,
                        onAddTime: () {
                          setState(() {
                            _restTimeRemaining += 30;
                          });
                        },
                        isDark: isDark,
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
            setState(() {
              if (adjustment.suggestedWeightKg != null) {
                _currentWeight = _currentWeight + adjustment.suggestedWeightKg!;
              }
              if (adjustment.suggestedReps != null && adjustment.suggestedReps != 99) {
                _currentReps = _currentReps + adjustment.suggestedReps!;
              }
            });
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
    SharedSessionState? sharedState, {
    required Color accentColor,
  }) {
    final completedIndices = <int>[];
    for (var i = 0; i < _completedSets.length; i++) {
      if (_completedSets[i].length >= _getExerciseSets(exercises[i])) {
        completedIndices.add(i);
      }
    }

    // Get organization ID for notes
    final activeContext = ref.watch(activeContextProvider);
    final organizationId = activeContext?.organization.id;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Workout notes banner (prescription notes from trainer)
          FadeInUp(
            child: WorkoutNotesBanner(
              workoutId: widget.workoutId,
              organizationId: organizationId,
              isDark: isDark,
            ),
          ),

          // Trainer adjustment banner (if pending)
          if (_isSharedSession && _pendingAdjustment != null)
            FadeInUp(
              child: _buildAdjustmentBanner(theme, _pendingAdjustment!),
            ),

          // Exercise navigation with arrows
          FadeInUp(
            child: ExerciseNavigationArrows(
              currentIndex: _currentExerciseIndex,
              totalExercises: exercises.length,
              onPrevious: _currentExerciseIndex > 0
                  ? () {
                      setState(() {
                        _currentExerciseIndex--;
                        _currentSet = _completedSets[_currentExerciseIndex].length + 1;
                        final exerciseSets = _getExerciseSets(_getCurrentExercise(exercises));
                        if (_currentSet > exerciseSets) _currentSet = exerciseSets;
                        _updateInputDefaults(exercises);
                      });
                    }
                  : null,
              onNext: _currentExerciseIndex < exercises.length - 1
                  ? () {
                      setState(() {
                        _currentExerciseIndex++;
                        _currentSet = _completedSets[_currentExerciseIndex].length + 1;
                        final exerciseSets = _getExerciseSets(_getCurrentExercise(exercises));
                        if (_currentSet > exerciseSets) _currentSet = exerciseSets;
                        _updateInputDefaults(exercises);
                      });
                    }
                  : null,
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 12),

          // Page indicator dots
          FadeInUp(
            child: ExercisePageIndicator(
              totalExercises: exercises.length,
              currentIndex: _currentExerciseIndex,
              completedExerciseIndices: completedIndices,
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 20),

          // Main exercise card - COMPACT version
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: ExerciseCardCompact(
              exercise: currentExercise,
              currentSet: _currentSet,
              totalSets: _getExerciseSets(currentExercise),
              isDark: isDark,
            ),
          ),

          const SizedBox(height: 12),

          // PR indicator - shows current PR to beat
          FadeInUp(
            delay: const Duration(milliseconds: 150),
            child: PRIndicator(
              exerciseId: currentExercise?['exercise_id']?.toString(),
              exerciseName: currentExercise?['name'] as String? ??
                  currentExercise?['exercise_name'] as String? ??
                  'Exercício',
              isDark: isDark,
              currentWeight: _currentWeight,
            ),
          ),

          const SizedBox(height: 8),

          // Set tracker
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildSetTracker(theme, isDark, currentExercise),
          ),

          const SizedBox(height: 20),

          // Log set section with steppers
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildLogSectionWithSteppers(theme, isDark, exercises, currentExercise, accentColor: accentColor),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _updateInputDefaults(List<Map<String, dynamic>> exercises) {
    final exercise = _getCurrentExercise(exercises);
    _currentWeight = _getExerciseWeight(exercise);
    _currentReps = (int.tryParse(_getExerciseReps(exercise)) ?? 10).toDouble();
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
              setState(() {
                if (adjustment.suggestedWeightKg != null) {
                  _currentWeight = _currentWeight + adjustment.suggestedWeightKg!;
                }
                if (adjustment.suggestedReps != null && adjustment.suggestedReps != 99) {
                  _currentReps = _currentReps + adjustment.suggestedReps!;
                }
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

  Widget _buildLogSectionWithSteppers(
    ThemeData theme,
    bool isDark,
    List<Map<String, dynamic>> exercises,
    Map<String, dynamic>? exercise, {
    required Color accentColor,
  }) {
    final exerciseSets = _getExerciseSets(exercise);
    final defaultReps = _getExerciseReps(exercise);
    final defaultWeight = _getExerciseWeight(exercise);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLowest.withAlpha(150)
            : theme.colorScheme.surfaceContainerLowest.withAlpha(200),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Série $_currentSet',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'de $exerciseSets',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stepper inputs row
          Row(
            children: [
              // Weight stepper
              Expanded(
                child: SetInputStepper(
                  label: 'Peso (kg)',
                  icon: LucideIcons.dumbbell,
                  value: _currentWeight > 0 ? _currentWeight : defaultWeight,
                  step: 2.5,
                  minValue: 0,
                  maxValue: 500,
                  isDecimal: true,
                  hint: defaultWeight > 0
                      ? defaultWeight.toStringAsFixed(
                          defaultWeight.truncateToDouble() == defaultWeight ? 0 : 1)
                      : '0',
                  onChanged: (value) {
                    setState(() => _currentWeight = value);
                  },
                  isDark: isDark,
                ),
              ),

              const SizedBox(width: 16),

              // Reps stepper
              Expanded(
                child: SetInputStepper(
                  label: 'Repetições',
                  icon: LucideIcons.hash,
                  value: _currentReps > 0 ? _currentReps : (int.tryParse(defaultReps) ?? 10).toDouble(),
                  step: 1,
                  minValue: 1,
                  maxValue: 100,
                  isDecimal: false,
                  hint: defaultReps,
                  onChanged: (value) {
                    setState(() => _currentReps = value);
                  },
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Complete button with animation - uses accent color based on technique
          SizedBox(
            width: double.infinity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: () => _completeSet(exercises),
                icon: const Icon(LucideIcons.check, size: 20),
                label: const Text(
                  'Completar Série',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext pageContext) {
    HapticUtils.lightImpact();
    showDialog(
      context: pageContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text('Sair do treino?'),
        content: const Text('Seu progresso será salvo, mas o treino ficará incompleto.'),
        actions: [
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(dialogContext);
            },
            child: const Text('Continuar'),
          ),
          FilledButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(dialogContext); // Close dialog
              pageContext.pop(); // Exit page using the page context
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

class _WorkoutCompleteSheet extends StatefulWidget {
  final String duration;
  final int exercisesCompleted;
  final int totalSets;

  const _WorkoutCompleteSheet({
    required this.duration,
    required this.exercisesCompleted,
    required this.totalSets,
  });

  @override
  State<_WorkoutCompleteSheet> createState() => _WorkoutCompleteSheetState();
}

class _WorkoutCompleteSheetState extends State<_WorkoutCompleteSheet> {
  bool _showCelebration = true;

  @override
  void initState() {
    super.initState();
    // Stop celebration after animation completes
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() => _showCelebration = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return WorkoutCelebration(
      isPlaying: _showCelebration,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surface
              : theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated trophy
            const AnimatedTrophy(
              size: 64,
              color: AppColors.success,
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
              _getMotivationalMessage(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Animated stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedStatCounter(
                  value: widget.duration,
                  label: 'Duração',
                  icon: LucideIcons.clock,
                  color: AppColors.primary,
                  delay: const Duration(milliseconds: 200),
                ),
                AnimatedStatCounter(
                  value: '${widget.exercisesCompleted}',
                  label: 'Exercícios',
                  icon: LucideIcons.dumbbell,
                  color: AppColors.secondary,
                  delay: const Duration(milliseconds: 400),
                ),
                AnimatedStatCounter(
                  value: '${widget.totalSets}',
                  label: 'Séries',
                  icon: LucideIcons.repeat,
                  color: AppColors.accent,
                  delay: const Duration(milliseconds: 600),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // CTA button
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Finalizar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMotivationalMessage() {
    final messages = [
      'Excelente trabalho! Continue assim.',
      'Você arrasou! Mais um passo rumo aos seus objetivos.',
      'Parabéns pela dedicação! Seu corpo agradece.',
      'Incrível! Cada treino te deixa mais forte.',
      'Muito bem! A consistência é a chave do sucesso.',
    ];
    return messages[DateTime.now().millisecond % messages.length];
  }
}

class _SetData {
  final int setNumber;
  final int reps;
  final double weight;

  _SetData({required this.setNumber, required this.reps, required this.weight});
}
