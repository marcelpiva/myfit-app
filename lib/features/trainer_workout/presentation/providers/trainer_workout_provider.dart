import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/workout_service.dart';
import '../../domain/models/trainer_workout.dart';

// Service provider
final workoutServiceProvider = Provider<WorkoutService>((ref) {
  return WorkoutService();
});

// ==================== Trainer Workouts State ====================

class TrainerWorkoutsState {
  final List<TrainerWorkout> workouts;
  final bool isLoading;
  final String? error;

  const TrainerWorkoutsState({
    this.workouts = const [],
    this.isLoading = false,
    this.error,
  });

  TrainerWorkoutsState copyWith({
    List<TrainerWorkout>? workouts,
    bool? isLoading,
    String? error,
  }) {
    return TrainerWorkoutsState(
      workouts: workouts ?? this.workouts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ==================== Trainer Workouts Notifier ====================

class TrainerWorkoutsNotifier extends StateNotifier<TrainerWorkoutsState> {
  final WorkoutService _service;

  TrainerWorkoutsNotifier(this._service) : super(const TrainerWorkoutsState()) {
    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getWorkoutAssignments();
      final workouts = data.map((e) => _mapToTrainerWorkout(e)).toList();
      state = state.copyWith(workouts: workouts, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar treinos');
    }
  }

  Future<void> addWorkout(TrainerWorkout workout) async {
    try {
      final exercises = workout.exercises.map((e) => {
        'exercise_id': e.exerciseId,
        'sets': e.sets,
        'reps': e.repsMin,
        'weight': e.weightKg,
        'rest_seconds': e.restSeconds,
        'notes': e.notes,
      }).toList();

      final data = await _service.createWorkout(
        name: workout.name,
        description: workout.description,
        difficulty: workout.difficulty.name,
        estimatedDuration: workout.estimatedDurationMinutes,
        exercises: exercises,
      );

      final newWorkout = _mapToTrainerWorkout(data);
      state = state.copyWith(workouts: [newWorkout, ...state.workouts]);
    } on ApiException {
      rethrow;
    }
  }

  Future<void> updateWorkout(TrainerWorkout workout) async {
    try {
      final data = await _service.updateWorkout(
        workout.id,
        name: workout.name,
        description: workout.description,
        difficulty: workout.difficulty.name,
        estimatedDuration: workout.estimatedDurationMinutes,
      );

      final updated = _mapToTrainerWorkout(data);
      state = state.copyWith(
        workouts: state.workouts.map((w) => w.id == workout.id ? updated : w).toList(),
      );
    } on ApiException {
      rethrow;
    }
  }

  Future<void> deleteWorkout(String workoutId) async {
    try {
      await _service.deleteWorkout(workoutId);
      state = state.copyWith(
        workouts: state.workouts.where((w) => w.id != workoutId).toList(),
      );
    } on ApiException {
      rethrow;
    }
  }

  Future<TrainerWorkout?> duplicateWorkout(String workoutId, {String? newStudentId}) async {
    try {
      final data = await _service.duplicateWorkout(workoutId);
      final duplicate = _mapToTrainerWorkout(data);
      state = state.copyWith(workouts: [duplicate, ...state.workouts]);
      return duplicate;
    } on ApiException {
      rethrow;
    }
  }

  Future<void> evolveWorkout(String workoutId, List<WorkoutExercise> exercises) async {
    try {
      // For now, update the workout locally with evolved exercises
      // In the future, this would call a dedicated API endpoint
      final workout = state.workouts.firstWhere((w) => w.id == workoutId);
      final updated = workout.copyWith(exercises: exercises, version: workout.version + 1);
      state = state.copyWith(
        workouts: state.workouts.map((w) => w.id == workoutId ? updated : w).toList(),
      );
    } catch (_) {
      // Handle error silently for local operations
    }
  }

  void pauseWorkout(String workoutId) {
    state = state.copyWith(
      workouts: state.workouts.map((w) {
        if (w.id == workoutId) {
          return w.copyWith(status: WorkoutAssignmentStatus.paused);
        }
        return w;
      }).toList(),
    );
  }

  void activateWorkout(String workoutId) {
    state = state.copyWith(
      workouts: state.workouts.map((w) {
        if (w.id == workoutId) {
          return w.copyWith(status: WorkoutAssignmentStatus.active);
        }
        return w;
      }).toList(),
    );
  }

  void refresh() => loadWorkouts();
}

final trainerWorkoutsNotifierProvider = StateNotifierProvider<TrainerWorkoutsNotifier, TrainerWorkoutsState>((ref) {
  final service = ref.watch(workoutServiceProvider);
  return TrainerWorkoutsNotifier(service);
});

// Simple provider for backward compatibility
final trainerWorkoutsProvider = Provider<List<TrainerWorkout>>((ref) {
  return ref.watch(trainerWorkoutsNotifierProvider).workouts;
});

// ==================== Student Workouts Provider ====================

final studentWorkoutsProvider = Provider.family<List<TrainerWorkout>, String>((ref, studentId) {
  final allWorkouts = ref.watch(trainerWorkoutsProvider);
  return allWorkouts.where((w) => w.studentId == studentId).toList();
});

// ==================== Student Progress State ====================

class StudentProgressState {
  final StudentProgress progress;
  final bool isLoading;
  final String? error;

  const StudentProgressState({
    required this.progress,
    this.isLoading = false,
    this.error,
  });

  StudentProgressState copyWith({
    StudentProgress? progress,
    bool? isLoading,
    String? error,
  }) {
    return StudentProgressState(
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ==================== Student Progress Notifier ====================

class StudentProgressNotifier extends StateNotifier<StudentProgressState> {
  final WorkoutService _service;
  final String studentId;

  StudentProgressNotifier(this._service, this.studentId)
      : super(StudentProgressState(progress: _emptyProgress(studentId))) {
    loadProgress();
  }

  Future<void> loadProgress() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sessions = await _service.getWorkoutSessions();

      // Calculate progress from sessions
      final totalSessions = sessions.length;
      final totalMinutes = sessions.fold<int>(0, (sum, s) {
        final duration = s['duration_minutes'] as int? ?? 0;
        return sum + duration;
      });

      // Calculate streaks
      final streaks = _calculateStreaks(sessions);

      final progress = StudentProgress(
        studentId: studentId,
        studentName: '', // Would come from user service
        totalWorkouts: sessions.where((s) => s['status'] == 'completed').length,
        totalSessions: totalSessions,
        totalMinutes: totalMinutes,
        currentStreak: streaks['current'] ?? 0,
        longestStreak: streaks['longest'] ?? 0,
        sessionsThisWeek: _countSessionsThisWeek(sessions),
        sessionsThisMonth: _countSessionsThisMonth(sessions),
        averageSessionsPerWeek: totalSessions > 0 ? totalSessions / 4.0 : 0,
        exerciseProgress: {},
        milestones: [],
        aiSuggestions: [],
      );

      state = state.copyWith(progress: progress, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar progresso');
    }
  }

  int _countSessionsThisWeek(List<Map<String, dynamic>> sessions) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return sessions.where((s) {
      final date = DateTime.tryParse(s['started_at'] as String? ?? '');
      return date != null && date.isAfter(startOfWeek);
    }).length;
  }

  int _countSessionsThisMonth(List<Map<String, dynamic>> sessions) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return sessions.where((s) {
      final date = DateTime.tryParse(s['started_at'] as String? ?? '');
      return date != null && date.isAfter(startOfMonth);
    }).length;
  }

  Map<String, int> _calculateStreaks(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) {
      return {'current': 0, 'longest': 0};
    }

    // Get completed sessions and extract unique dates
    final completedSessions = sessions.where((s) => s['status'] == 'completed');
    final Set<DateTime> workoutDates = {};

    for (final session in completedSessions) {
      final dateStr = session['started_at'] as String?;
      if (dateStr != null) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          // Normalize to date only (no time)
          workoutDates.add(DateTime(date.year, date.month, date.day));
        }
      }
    }

    if (workoutDates.isEmpty) {
      return {'current': 0, 'longest': 0};
    }

    // Sort dates
    final sortedDates = workoutDates.toList()..sort();

    // Calculate streaks
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    // Calculate current streak (must include today or yesterday)
    final lastWorkoutDate = sortedDates.last;
    final daysSinceLastWorkout = todayNormalized.difference(lastWorkoutDate).inDays;

    if (daysSinceLastWorkout <= 1) {
      // Count backwards from most recent workout
      currentStreak = 1;
      for (int i = sortedDates.length - 2; i >= 0; i--) {
        final diff = sortedDates[i + 1].difference(sortedDates[i]).inDays;
        if (diff == 1) {
          currentStreak++;
        } else {
          break;
        }
      }
    }

    // Calculate longest streak
    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff == 1) {
        tempStreak++;
      } else {
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
        tempStreak = 1;
      }
    }
    // Check last streak
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }

  void addMilestone(ProgressMilestone milestone) {
    state = state.copyWith(
      progress: state.progress.copyWith(
        milestones: [...state.progress.milestones, milestone],
      ),
    );
  }

  void applySuggestion(String suggestionId) {
    state = state.copyWith(
      progress: state.progress.copyWith(
        aiSuggestions: state.progress.aiSuggestions.map((s) {
          if (s.id == suggestionId) {
            return s.copyWith(applied: true);
          }
          return s;
        }).toList(),
      ),
    );
  }

  void dismissSuggestion(String suggestionId, String reason) {
    state = state.copyWith(
      progress: state.progress.copyWith(
        aiSuggestions: state.progress.aiSuggestions.map((s) {
          if (s.id == suggestionId) {
            return s.copyWith(dismissed: true, dismissReason: reason);
          }
          return s;
        }).toList(),
      ),
    );
  }

  void refresh() => loadProgress();
}

final studentProgressNotifierProvider = StateNotifierProvider.family<StudentProgressNotifier, StudentProgressState, String>((ref, studentId) {
  final service = ref.watch(workoutServiceProvider);
  return StudentProgressNotifier(service, studentId);
});

// Simple provider for backward compatibility
final studentProgressProvider = Provider.family<StudentProgress, String>((ref, studentId) {
  return ref.watch(studentProgressNotifierProvider(studentId)).progress;
});

// ==================== AI Suggestions Provider ====================

final aiSuggestionsProvider = Provider.family<List<AISuggestion>, String>((ref, studentId) {
  final progress = ref.watch(studentProgressProvider(studentId));
  return progress.aiSuggestions.where((s) => !s.dismissed).toList();
});

// ==================== Helper Functions ====================

TrainerWorkout _mapToTrainerWorkout(Map<String, dynamic> data) {
  final exercisesData = data['exercises'] as List? ?? [];
  final exercises = exercisesData.map((e) {
    final map = e as Map<String, dynamic>;
    return WorkoutExercise(
      id: map['id'] as String? ?? '',
      exerciseId: map['exercise_id'] as String? ?? '',
      exerciseName: map['exercise_name'] as String? ?? '',
      sets: map['sets'] as int? ?? 0,
      repsMin: map['reps'] as int? ?? map['reps_min'] as int? ?? 0,
      repsMax: map['reps_max'] as int?,
      weightKg: (map['weight'] as num?)?.toDouble(),
      restSeconds: map['rest_seconds'] as int? ?? 60,
      tempo: map['tempo'] as String?,
      order: map['order_index'] as int? ?? 0,
      notes: map['notes'] as String?,
      progressionNote: map['progression_note'] as String?,
      weightNote: map['weight_note'] as String?,
    );
  }).toList();

  return TrainerWorkout(
    id: data['id'] as String,
    trainerId: data['trainer_id'] as String? ?? '',
    trainerName: data['trainer_name'] as String? ?? '',
    studentId: data['student_id'] as String? ?? '',
    studentName: data['student_name'] as String? ?? '',
    studentAvatarUrl: data['student_avatar_url'] as String?,
    name: data['name'] as String? ?? '',
    description: data['description'] as String?,
    difficulty: _parseDifficulty(data['difficulty'] as String?),
    status: _parseStatus(data['status'] as String?),
    exercises: exercises,
    periodization: _parsePeriodization(data['periodization'] as String?),
    weekNumber: data['week_number'] as int?,
    totalWeeks: data['total_weeks'] as int?,
    phase: data['phase'] as String?,
    createdAt: DateTime.tryParse(data['created_at'] as String? ?? '') ?? DateTime.now(),
    updatedAt: data['updated_at'] != null ? DateTime.tryParse(data['updated_at'] as String) : null,
    startDate: data['start_date'] != null ? DateTime.tryParse(data['start_date'] as String) : null,
    endDate: data['end_date'] != null ? DateTime.tryParse(data['end_date'] as String) : null,
    totalSessions: data['total_sessions'] as int? ?? 0,
    completedSessions: data['completed_sessions'] as int? ?? 0,
    estimatedDurationMinutes: data['estimated_duration'] as int? ?? 0,
    trainerNotes: data['trainer_notes'] as String?,
    studentFeedback: data['student_feedback'] as String?,
    aiGenerated: data['ai_generated'] as bool? ?? false,
    aiSuggestionId: data['ai_suggestion_id'] as String?,
    version: data['version'] as int? ?? 1,
    previousVersionId: data['previous_version_id'] as String?,
  );
}

WorkoutDifficulty _parseDifficulty(String? difficulty) {
  switch (difficulty?.toLowerCase()) {
    case 'beginner':
      return WorkoutDifficulty.beginner;
    case 'intermediate':
      return WorkoutDifficulty.intermediate;
    case 'advanced':
      return WorkoutDifficulty.advanced;
    case 'elite':
      return WorkoutDifficulty.elite;
    default:
      return WorkoutDifficulty.intermediate;
  }
}

WorkoutAssignmentStatus _parseStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'draft':
      return WorkoutAssignmentStatus.draft;
    case 'active':
      return WorkoutAssignmentStatus.active;
    case 'paused':
      return WorkoutAssignmentStatus.paused;
    case 'completed':
      return WorkoutAssignmentStatus.completed;
    case 'archived':
      return WorkoutAssignmentStatus.archived;
    default:
      return WorkoutAssignmentStatus.draft;
  }
}

PeriodizationType _parsePeriodization(String? periodization) {
  switch (periodization?.toLowerCase()) {
    case 'linear':
      return PeriodizationType.linear;
    case 'undulating':
      return PeriodizationType.undulating;
    case 'block':
      return PeriodizationType.block;
    case 'conjugate':
      return PeriodizationType.conjugate;
    case 'custom':
      return PeriodizationType.custom;
    default:
      return PeriodizationType.linear;
  }
}

StudentProgress _emptyProgress(String studentId) {
  return StudentProgress(
    studentId: studentId,
    studentName: '',
    totalWorkouts: 0,
    totalSessions: 0,
    totalMinutes: 0,
    currentStreak: 0,
    longestStreak: 0,
    sessionsThisWeek: 0,
    sessionsThisMonth: 0,
    averageSessionsPerWeek: 0,
    exerciseProgress: {},
    milestones: [],
    aiSuggestions: [],
  );
}

// ==================== Student Programs Provider ====================

class StudentProgramsState {
  final List<Map<String, dynamic>> programs;
  final bool isLoading;
  final String? error;

  const StudentProgramsState({
    this.programs = const [],
    this.isLoading = false,
    this.error,
  });

  StudentProgramsState copyWith({
    List<Map<String, dynamic>>? programs,
    bool? isLoading,
    String? error,
  }) {
    return StudentProgramsState(
      programs: programs ?? this.programs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StudentProgramsNotifier extends StateNotifier<StudentProgramsState> {
  final WorkoutService _service;
  final String studentId;

  StudentProgramsNotifier(this._service, this.studentId)
      : super(const StudentProgramsState()) {
    loadPrograms();
  }

  Future<void> loadPrograms() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Load programs - backend should filter by student if studentId is provided
      final programs = await _service.getPlans(studentId: studentId);
      state = state.copyWith(programs: programs, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e, stackTrace) {
      debugPrint('Erro ao carregar planos: $e');
      debugPrint('StackTrace: $stackTrace');
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar planos: ${e.runtimeType}');
    }
  }

  void refresh() => loadPrograms();
}

final studentProgramsNotifierProvider = StateNotifierProvider.family<
    StudentProgramsNotifier, StudentProgramsState, String>((ref, studentId) {
  final service = ref.watch(workoutServiceProvider);
  return StudentProgramsNotifier(service, studentId);
});

final studentProgramsProvider = Provider.family<List<Map<String, dynamic>>, String>((ref, studentId) {
  return ref.watch(studentProgramsNotifierProvider(studentId)).programs;
});
