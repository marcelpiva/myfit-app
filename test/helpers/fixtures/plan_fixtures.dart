/// Fixtures for plan-related test data
class PlanFixtures {
  /// Creates a basic ABC split program API response
  static Map<String, dynamic> abcSplit({
    String id = 'program-1',
    String name = 'Programa ABC - Hipertrofia',
  }) {
    return {
      'id': id,
      'name': name,
      'goal': 'hypertrophy',
      'difficulty': 'intermediate',
      'split_type': 'ABC',
      'duration_weeks': 8,
      'is_template': true,
      'is_public': false,
      'creator_id': 'trainer-1',
      'creator_name': 'Personal João',
      'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'updated_at': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      'workouts': [
        _workoutResponse('A', 'Peito e Tríceps', 0),
        _workoutResponse('B', 'Costas e Bíceps', 1),
        _workoutResponse('C', 'Pernas e Ombros', 2),
      ],
      'tags': ['hipertrofia', 'intermediário', '3x semana'],
    };
  }

  /// Creates a Push/Pull/Legs program API response
  static Map<String, dynamic> pushPullLegs({
    String id = 'program-2',
    String name = 'Push Pull Legs',
  }) {
    return {
      'id': id,
      'name': name,
      'goal': 'strength',
      'difficulty': 'advanced',
      'split_type': 'PPL',
      'duration_weeks': 12,
      'is_template': true,
      'is_public': false,
      'creator_id': 'trainer-1',
      'creator_name': 'Personal João',
      'created_at': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
      'workouts': [
        _workoutResponse('Push', 'Empurrar - Peito, Ombro, Tríceps', 0),
        _workoutResponse('Pull', 'Puxar - Costas e Bíceps', 1),
        _workoutResponse('Legs', 'Pernas', 2),
      ],
      'tags': ['força', 'avançado', '6x semana'],
    };
  }

  /// Creates a full body program API response
  static Map<String, dynamic> fullBody({
    String id = 'program-3',
    String name = 'Full Body Iniciante',
  }) {
    return {
      'id': id,
      'name': name,
      'goal': 'general_fitness',
      'difficulty': 'beginner',
      'split_type': 'full_body',
      'duration_weeks': 4,
      'is_template': true,
      'is_public': true,
      'creator_id': 'trainer-1',
      'creator_name': 'Personal João',
      'created_at': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
      'workouts': [
        _workoutResponse('A', 'Full Body A', 0),
        _workoutResponse('B', 'Full Body B', 1),
      ],
      'tags': ['iniciante', 'full body', '2-3x semana'],
    };
  }

  /// Creates an AI-generated program API response
  static Map<String, dynamic> aiGenerated({
    String id = 'program-4',
    String name = 'Programa IA - Personalizado',
  }) {
    return {
      'id': id,
      'name': name,
      'goal': 'hypertrophy',
      'difficulty': 'intermediate',
      'split_type': 'ABCD',
      'duration_weeks': 8,
      'is_template': false,
      'is_public': false,
      'ai_generated': true,
      'creator_id': 'trainer-1',
      'creator_name': 'Personal João',
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'workouts': [
        _workoutResponse('A', 'Peito e Tríceps', 0),
        _workoutResponse('B', 'Costas e Bíceps', 1),
        _workoutResponse('C', 'Pernas Anterior', 2),
        _workoutResponse('D', 'Ombros e Posterior', 3),
      ],
      'questionnaire': {
        'goal': 'hypertrophy',
        'days_per_week': 4,
        'minutes_per_session': 60,
        'equipment': 'full_gym',
        'injuries': [],
      },
      'tags': ['IA', 'personalizado', 'hipertrofia'],
    };
  }

  /// Creates a catalog template program
  static Map<String, dynamic> catalogTemplate({
    String id = 'catalog-1',
    String name = 'Programa Popular - Hipertrofia',
  }) {
    return {
      'id': id,
      'name': name,
      'goal': 'hypertrophy',
      'difficulty': 'intermediate',
      'split_type': 'ABC',
      'duration_weeks': 8,
      'is_template': true,
      'is_public': true,
      'creator_id': 'official',
      'creator_name': 'MyFit Team',
      'download_count': 1500,
      'rating': 4.8,
      'review_count': 245,
      'created_at': DateTime.now().subtract(const Duration(days: 180)).toIso8601String(),
      'workouts': [
        _workoutResponse('A', 'Peito e Tríceps', 0),
        _workoutResponse('B', 'Costas e Bíceps', 1),
        _workoutResponse('C', 'Pernas e Ombros', 2),
      ],
      'tags': ['popular', 'hipertrofia', 'intermediário'],
    };
  }

  /// Creates a list of program API responses
  static List<Map<String, dynamic>> apiResponseList({int count = 5}) {
    final programs = <Map<String, dynamic>>[];
    if (count > 0) programs.add(abcSplit(id: 'program-0'));
    if (count > 1) programs.add(pushPullLegs(id: 'program-1'));
    if (count > 2) programs.add(fullBody(id: 'program-2'));
    if (count > 3) programs.add(aiGenerated(id: 'program-3'));
    if (count > 4) {
      for (var i = 4; i < count; i++) {
        programs.add(abcSplit(id: 'program-$i', name: 'Programa $i'));
      }
    }
    return programs;
  }

  /// Creates a list of catalog template API responses
  static List<Map<String, dynamic>> catalogResponseList({int count = 10}) {
    return List.generate(count, (index) => {
      'id': 'catalog-$index',
      'name': 'Template $index - ${_goals[index % _goals.length]}',
      'goal': _goalKeys[index % _goalKeys.length],
      'difficulty': _difficulties[index % _difficulties.length],
      'split_type': _splitTypes[index % _splitTypes.length],
      'duration_weeks': 4 + (index % 3) * 4,
      'is_template': true,
      'is_public': true,
      'creator_id': 'official',
      'creator_name': 'MyFit Team',
      'download_count': 100 * (count - index),
      'rating': 4.0 + (index % 10) / 10,
      'review_count': 50 + index * 10,
      'created_at': DateTime.now().subtract(Duration(days: 30 + index * 5)).toIso8601String(),
    });
  }

  /// Creates a program assignment API response
  static Map<String, dynamic> assignmentApiResponse({
    String id = 'assignment-1',
    String programId = 'program-1',
    String studentId = 'student-1',
    String status = 'active',
  }) {
    return {
      'id': id,
      'program_id': programId,
      'student_id': studentId,
      'student_name': 'João Silva',
      'status': status,
      'start_date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      'end_date': DateTime.now().add(const Duration(days: 49)).toIso8601String(),
      'notes': 'Programa atribuído com sucesso',
      'progress_percent': 12.5,
      'completed_workouts': 3,
      'total_workouts': 24,
    };
  }

  /// Creates an AI generation request payload
  static Map<String, dynamic> aiGenerationRequest({
    String goal = 'hypertrophy',
    String difficulty = 'intermediate',
    int daysPerWeek = 4,
    int minutesPerSession = 60,
    String equipment = 'full_gym',
    List<String>? injuries,
  }) {
    return {
      'goal': goal,
      'difficulty': difficulty,
      'days_per_week': daysPerWeek,
      'minutes_per_session': minutesPerSession,
      'equipment': equipment,
      'injuries': injuries ?? [],
      'preferences': 'mixed',
      'duration_weeks': 8,
    };
  }

  /// Creates an AI generation response
  static Map<String, dynamic> aiGenerationResponse({
    String id = 'ai-program-1',
    String name = 'Programa Personalizado',
  }) {
    return {
      'id': id,
      'name': name,
      'program': aiGenerated(id: id, name: name),
      'suggestions': [
        {
          'type': 'workout_order',
          'message': 'Sugerimos começar com treinos compostos',
        },
        {
          'type': 'rest_day',
          'message': 'Incluímos dias de descanso entre sessões intensas',
        },
      ],
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> _workoutResponse(String label, String name, int order) {
    return {
      'id': 'workout-$label',
      'label': label,
      'name': name,
      'order': order,
      'day_of_week': order + 1, // Monday = 1, etc.
      'exercises': _exercisesForWorkout(label),
    };
  }

  static List<Map<String, dynamic>> _exercisesForWorkout(String label) {
    final exerciseSets = {
      'A': [
        {'name': 'Supino Reto', 'sets': 4, 'reps': '8-12'},
        {'name': 'Supino Inclinado', 'sets': 4, 'reps': '10-12'},
        {'name': 'Crucifixo', 'sets': 3, 'reps': '12-15'},
        {'name': 'Tríceps Pulley', 'sets': 3, 'reps': '12-15'},
        {'name': 'Tríceps Francês', 'sets': 3, 'reps': '10-12'},
      ],
      'B': [
        {'name': 'Puxada Frontal', 'sets': 4, 'reps': '8-12'},
        {'name': 'Remada Curvada', 'sets': 4, 'reps': '8-12'},
        {'name': 'Remada Baixa', 'sets': 3, 'reps': '10-12'},
        {'name': 'Rosca Direta', 'sets': 3, 'reps': '10-12'},
        {'name': 'Rosca Martelo', 'sets': 3, 'reps': '10-12'},
      ],
      'C': [
        {'name': 'Agachamento', 'sets': 4, 'reps': '8-12'},
        {'name': 'Leg Press', 'sets': 4, 'reps': '10-12'},
        {'name': 'Extensora', 'sets': 3, 'reps': '12-15'},
        {'name': 'Desenvolvimento', 'sets': 4, 'reps': '10-12'},
        {'name': 'Elevação Lateral', 'sets': 3, 'reps': '12-15'},
      ],
    };

    final exercises = exerciseSets[label] ?? exerciseSets['A']!;
    return exercises.asMap().entries.map((entry) {
      return {
        'id': 'ex-$label-${entry.key}',
        'exercise_id': 'exercise-${entry.key}',
        'exercise_name': entry.value['name'],
        'sets': entry.value['sets'],
        'reps': entry.value['reps'],
        'order_index': entry.key,
      };
    }).toList();
  }

  static const _goals = ['Hipertrofia', 'Força', 'Condicionamento', 'Emagrecimento'];
  static const _goalKeys = ['hypertrophy', 'strength', 'general_fitness', 'weight_loss'];
  static const _difficulties = ['beginner', 'intermediate', 'advanced'];
  static const _splitTypes = ['ABC', 'PPL', 'full_body', 'upper_lower', 'ABCD'];
}
