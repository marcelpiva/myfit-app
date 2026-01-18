import 'package:myfit_app/features/trainer_workout/domain/models/trainer_workout.dart';

/// Fixtures for workout-related test data
class WorkoutFixtures {
  /// Creates a workout with exercises
  static TrainerWorkout withExercises({
    String id = 'workout-1',
    String name = 'Treino A - Peito e Tríceps',
    WorkoutAssignmentStatus status = WorkoutAssignmentStatus.active,
    int exerciseCount = 6,
  }) {
    return TrainerWorkout(
      id: id,
      trainerId: 'trainer-1',
      trainerName: 'Personal João',
      studentId: 'student-1',
      studentName: 'João Silva',
      name: name,
      description: 'Treino focado em peito e tríceps',
      difficulty: WorkoutDifficulty.intermediate,
      status: status,
      exercises: List.generate(
        exerciseCount,
        (index) => WorkoutExercise(
          id: 'exercise-$index',
          exerciseId: 'ex-$index',
          exerciseName: _exerciseNames[index % _exerciseNames.length],
          sets: 4,
          repsMin: 8,
          repsMax: 12,
          weightKg: 20.0 + (index * 5),
          restSeconds: 90,
          order: index,
        ),
      ),
      periodization: PeriodizationType.linear,
      weekNumber: 1,
      totalWeeks: 8,
      phase: 'Hipertrofia',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 49)),
      totalSessions: 24,
      completedSessions: 3,
      estimatedDurationMinutes: 60,
      trainerNotes: 'Manter foco na execução',
      aiGenerated: false,
      version: 1,
    );
  }

  /// Creates an empty workout (no exercises)
  static TrainerWorkout empty({
    String id = 'workout-2',
    String name = 'Treino Vazio',
  }) {
    return TrainerWorkout(
      id: id,
      trainerId: 'trainer-1',
      trainerName: 'Personal João',
      studentId: 'student-1',
      studentName: 'João Silva',
      name: name,
      description: null,
      difficulty: WorkoutDifficulty.beginner,
      status: WorkoutAssignmentStatus.draft,
      exercises: const [],
      createdAt: DateTime.now(),
      totalSessions: 0,
      completedSessions: 0,
    );
  }

  /// Creates a workout in draft status
  static TrainerWorkout draft({
    String id = 'workout-3',
    String name = 'Treino Rascunho',
  }) {
    return TrainerWorkout(
      id: id,
      trainerId: 'trainer-1',
      trainerName: 'Personal João',
      studentId: 'student-1',
      studentName: 'João Silva',
      name: name,
      description: 'Treino em elaboração',
      difficulty: WorkoutDifficulty.intermediate,
      status: WorkoutAssignmentStatus.draft,
      exercises: [
        const WorkoutExercise(
          id: 'ex-1',
          exerciseId: 'bench-press',
          exerciseName: 'Supino Reto',
          sets: 4,
          repsMin: 8,
          repsMax: 12,
        ),
      ],
      createdAt: DateTime.now(),
      totalSessions: 0,
      completedSessions: 0,
    );
  }

  /// Creates a completed workout
  static TrainerWorkout completed({
    String id = 'workout-4',
    String name = 'Treino Finalizado',
  }) {
    return TrainerWorkout(
      id: id,
      trainerId: 'trainer-1',
      trainerName: 'Personal João',
      studentId: 'student-1',
      studentName: 'João Silva',
      name: name,
      description: 'Ciclo de treino completado',
      difficulty: WorkoutDifficulty.advanced,
      status: WorkoutAssignmentStatus.completed,
      exercises: const [],
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      endDate: DateTime.now().subtract(const Duration(days: 4)),
      totalSessions: 24,
      completedSessions: 24,
    );
  }

  /// Creates an AI-generated workout
  static TrainerWorkout aiGenerated({
    String id = 'workout-5',
    String name = 'Treino IA - Push Pull Legs',
  }) {
    return TrainerWorkout(
      id: id,
      trainerId: 'trainer-1',
      trainerName: 'Personal João',
      studentId: 'student-1',
      studentName: 'João Silva',
      name: name,
      description: 'Treino gerado por IA',
      difficulty: WorkoutDifficulty.intermediate,
      status: WorkoutAssignmentStatus.active,
      exercises: [
        const WorkoutExercise(
          id: 'ex-1',
          exerciseId: 'bench-press',
          exerciseName: 'Supino Reto',
          sets: 4,
          repsMin: 8,
          repsMax: 12,
          weightKg: 60,
          progressionNote: 'Aumentar 2.5kg próxima semana',
        ),
        const WorkoutExercise(
          id: 'ex-2',
          exerciseId: 'overhead-press',
          exerciseName: 'Desenvolvimento',
          sets: 3,
          repsMin: 10,
          repsMax: 12,
          weightKg: 30,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      aiGenerated: true,
      aiSuggestionId: 'ai-suggestion-1',
    );
  }

  /// Creates a workout API response (uses camelCase keys to match freezed model)
  static Map<String, dynamic> apiResponse({
    String id = 'workout-1',
    String name = 'Treino A',
    String status = 'active',
    List<Map<String, dynamic>>? exercises,
  }) {
    return {
      'id': id,
      'trainerId': 'trainer-1',
      'trainerName': 'Personal João',
      'studentId': 'student-1',
      'studentName': 'João Silva',
      'name': name,
      'description': 'Treino de teste',
      'difficulty': 'intermediate',
      'status': status,
      'exercises': exercises ?? _defaultExercisesApiResponse(),
      'periodization': 'linear',
      'weekNumber': 1,
      'totalWeeks': 8,
      'phase': 'Hipertrofia',
      'createdAt': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      'updatedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'startDate': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      'endDate': DateTime.now().add(const Duration(days: 49)).toIso8601String(),
      'totalSessions': 24,
      'completedSessions': 3,
      'estimatedDurationMinutes': 60,
      'trainerNotes': 'Manter foco na execução',
      'aiGenerated': false,
      'version': 1,
    };
  }

  /// Creates a list of workout API responses
  static List<Map<String, dynamic>> apiResponseList({int count = 5}) {
    return List.generate(count, (index) => apiResponse(
      id: 'workout-$index',
      name: 'Treino ${String.fromCharCode(65 + index)}', // A, B, C...
      status: index == 0 ? 'active' : (index == 1 ? 'draft' : 'completed'),
    ));
  }

  /// Creates a workout assignment API response
  static Map<String, dynamic> assignmentApiResponse({
    String id = 'assignment-1',
    String workoutId = 'workout-1',
    String studentId = 'student-1',
    String status = 'active',
  }) {
    return {
      'id': id,
      'workout_id': workoutId,
      'student_id': studentId,
      'status': status,
      'start_date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      'end_date': DateTime.now().add(const Duration(days: 49)).toIso8601String(),
      'notes': 'Atribuição de treino',
    };
  }

  /// Creates a workout session API response
  static Map<String, dynamic> sessionApiResponse({
    String id = 'session-1',
    String workoutId = 'workout-1',
    String status = 'completed',
    int durationMinutes = 55,
  }) {
    return {
      'id': id,
      'workout_id': workoutId,
      'status': status,
      'started_at': DateTime.now().subtract(Duration(minutes: durationMinutes + 5)).toIso8601String(),
      'completed_at': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
      'duration_minutes': durationMinutes,
      'notes': 'Boa sessão',
      'rating': 4,
    };
  }

  /// Creates a list of session API responses
  static List<Map<String, dynamic>> sessionApiResponseList({int count = 10}) {
    return List.generate(count, (index) => sessionApiResponse(
      id: 'session-$index',
      status: index < 8 ? 'completed' : 'in_progress',
      durationMinutes: 45 + (index * 2),
    ));
  }

  /// Creates an exercise progress object
  static ExerciseProgress exerciseProgress({
    String id = 'progress-1',
    String exerciseId = 'bench-press',
    String exerciseName = 'Supino Reto',
  }) {
    return ExerciseProgress(
      id: id,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      studentId: 'student-1',
      logs: [
        ExerciseLog(
          id: 'log-1',
          date: DateTime.now().subtract(const Duration(days: 7)),
          sets: 4,
          reps: 10,
          weightKg: 60,
          rpe: 8,
          isPR: false,
        ),
        ExerciseLog(
          id: 'log-2',
          date: DateTime.now().subtract(const Duration(days: 3)),
          sets: 4,
          reps: 10,
          weightKg: 62.5,
          rpe: 9,
          isPR: true,
        ),
      ],
      pr1RM: 85.0,
      pr5RM: 72.5,
      pr10RM: 62.5,
      lastPrDate: DateTime.now().subtract(const Duration(days: 3)),
      trend: ProgressTrend.improving,
      averageWeightLast4Weeks: 61.25,
      averageRepsLast4Weeks: 10.0,
    );
  }

  /// Creates a student progress object
  static StudentProgress studentProgress({
    String studentId = 'student-1',
    String studentName = 'João Silva',
    int currentStreak = 5,
    int longestStreak = 12,
  }) {
    return StudentProgress(
      studentId: studentId,
      studentName: studentName,
      totalWorkouts: 24,
      totalSessions: 48,
      totalMinutes: 2400,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      sessionsThisWeek: 3,
      sessionsThisMonth: 12,
      averageSessionsPerWeek: 3.5,
      exerciseProgress: {
        'bench-press': exerciseProgress(),
      },
      milestones: [
        ProgressMilestone(
          id: 'milestone-1',
          title: 'Primeiro Treino',
          description: 'Completou o primeiro treino',
          achievedAt: DateTime.now().subtract(const Duration(days: 60)),
          icon: '🏆',
        ),
      ],
      trainerNotes: 'Aluno dedicado, progredindo bem',
      lastEvaluation: DateTime.now().subtract(const Duration(days: 7)),
      aiSuggestions: [],
    );
  }

  /// Creates an AI suggestion
  static AISuggestion aiSuggestion({
    String id = 'suggestion-1',
    AISuggestionType type = AISuggestionType.increaseWeight,
  }) {
    return AISuggestion(
      id: id,
      type: type,
      title: 'Aumentar carga no Supino',
      description: 'Baseado nas últimas 4 semanas, sugerimos aumentar a carga em 2.5kg',
      rationale: 'O aluno completou todas as séries com RPE < 8 consistentemente',
      exerciseId: 'bench-press',
      exerciseName: 'Supino Reto',
      suggestedWeight: 65.0,
      suggestedReps: 10,
      createdAt: DateTime.now(),
      applied: false,
      dismissed: false,
    );
  }

  static List<Map<String, dynamic>> _defaultExercisesApiResponse() {
    return [
      {
        'id': 'ex-1',
        'exerciseId': 'bench-press',
        'exerciseName': 'Supino Reto',
        'sets': 4,
        'repsMin': 8,
        'repsMax': 12,
        'weightKg': 60.0,
        'restSeconds': 90,
        'order': 0,
      },
      {
        'id': 'ex-2',
        'exerciseId': 'incline-press',
        'exerciseName': 'Supino Inclinado',
        'sets': 4,
        'repsMin': 8,
        'repsMax': 12,
        'weightKg': 50.0,
        'restSeconds': 90,
        'order': 1,
      },
      {
        'id': 'ex-3',
        'exerciseId': 'triceps-pushdown',
        'exerciseName': 'Tríceps Pulley',
        'sets': 3,
        'repsMin': 10,
        'repsMax': 15,
        'weightKg': 25.0,
        'restSeconds': 60,
        'order': 2,
      },
    ];
  }

  static const _exerciseNames = [
    'Supino Reto',
    'Supino Inclinado',
    'Crucifixo',
    'Tríceps Pulley',
    'Tríceps Francês',
    'Mergulho',
    'Flexão',
    'Cross-over',
  ];
}

/// Extension for WorkoutExercise tests
extension WorkoutExerciseTestExtensions on WorkoutExercise {
  /// Creates a copy with different values for testing
  WorkoutExercise withValues({
    int? sets,
    int? repsMin,
    int? repsMax,
    String? repsNote,
    double? weightKg,
    String? weightNote,
  }) {
    return copyWith(
      sets: sets ?? this.sets,
      repsMin: repsMin ?? this.repsMin,
      repsMax: repsMax ?? this.repsMax,
      repsNote: repsNote ?? this.repsNote,
      weightKg: weightKg ?? this.weightKg,
      weightNote: weightNote ?? this.weightNote,
    );
  }
}
