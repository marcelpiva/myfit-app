import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../../../workout/presentation/providers/workout_provider.dart';

/// Page for browsing and selecting workout templates
class WorkoutTemplatesPage extends ConsumerStatefulWidget {
  final String? initialCategory;

  const WorkoutTemplatesPage({super.key, this.initialCategory});

  @override
  ConsumerState<WorkoutTemplatesPage> createState() => _WorkoutTemplatesPageState();
}

class _WorkoutTemplatesPageState extends ConsumerState<WorkoutTemplatesPage> {
  String? _selectedCategory;
  _WorkoutTemplate? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    // Set initial category if provided via navigation
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }
  }

  final List<_TemplateCategory> _categories = [
    _TemplateCategory(
      id: 'hipertrofia',
      name: 'Hipertrofia',
      icon: LucideIcons.dumbbell,
      description: 'Ganho de massa muscular',
      templateCount: 6,
    ),
    _TemplateCategory(
      id: 'forca',
      name: 'Forca',
      icon: LucideIcons.gauge,
      description: 'Aumento de forca maxima',
      templateCount: 4,
    ),
    _TemplateCategory(
      id: 'emagrecimento',
      name: 'Emagrecimento',
      icon: LucideIcons.flame,
      description: 'Perda de gordura corporal',
      templateCount: 5,
    ),
    _TemplateCategory(
      id: 'resistencia',
      name: 'Resistencia',
      icon: LucideIcons.heart,
      description: 'Condicionamento cardiovascular',
      templateCount: 4,
    ),
    _TemplateCategory(
      id: 'funcional',
      name: 'Funcional',
      icon: LucideIcons.activity,
      description: 'Movimentos funcionais do dia a dia',
      templateCount: 3,
    ),
  ];

  List<_WorkoutTemplate> _getTemplatesForCategory(String categoryId) {
    switch (categoryId) {
      case 'hipertrofia':
        return [
          _WorkoutTemplate(
            id: 'hiper_iniciante',
            name: 'Hipertrofia Iniciante',
            description: 'Ganho de massa para iniciantes',
            difficulty: 'Iniciante',
            duration: 50,
            exerciseCount: 8,
            muscleGroups: ['Full Body'],
            exercises: [
              _TemplateExercise(name: 'Supino Maquina', sets: 3, reps: '10-12'),
              _TemplateExercise(name: 'Puxada Frontal', sets: 3, reps: '10-12'),
              _TemplateExercise(name: 'Leg Press', sets: 3, reps: '10-12'),
              _TemplateExercise(name: 'Desenvolvimento Maquina', sets: 3, reps: '10-12'),
              _TemplateExercise(name: 'Remada Baixa', sets: 3, reps: '10-12'),
              _TemplateExercise(name: 'Cadeira Extensora', sets: 3, reps: '10-12'),
              _TemplateExercise(name: 'Rosca Direta', sets: 2, reps: '10-12'),
              _TemplateExercise(name: 'Triceps Pulley', sets: 2, reps: '10-12'),
            ],
          ),
          _WorkoutTemplate(
            id: 'hiper_peito_triceps',
            name: 'Peito e Triceps - Volume',
            description: 'Treino de volume para peito e triceps',
            difficulty: 'Intermediario',
            duration: 55,
            exerciseCount: 6,
            muscleGroups: ['Peito', 'Triceps'],
            exercises: [
              _TemplateExercise(name: 'Supino Reto', sets: 4, reps: '8-12'),
              _TemplateExercise(name: 'Supino Inclinado', sets: 4, reps: '10-12'),
              _TemplateExercise(name: 'Crucifixo', sets: 3, reps: '12-15'),
              _TemplateExercise(name: 'Triceps Pulley', sets: 4, reps: '10-12'),
              _TemplateExercise(name: 'Triceps Frances', sets: 3, reps: '10-12'),
              _TemplateExercise(name: 'Triceps Testa', sets: 3, reps: '10-12'),
            ],
          ),
          _WorkoutTemplate(
            id: 'hiper_costas_biceps',
            name: 'Costas e Biceps - Volume',
            description: 'Treino de volume para costas e biceps',
            difficulty: 'Intermediario',
            duration: 55,
            exerciseCount: 6,
            muscleGroups: ['Costas', 'Biceps'],
            exercises: [
              _TemplateExercise(name: 'Puxada Frontal', sets: 4, reps: '8-12'),
              _TemplateExercise(name: 'Remada Curvada', sets: 4, reps: '8-12'),
              _TemplateExercise(name: 'Remada Baixa', sets: 3, reps: '10-12'),
              _TemplateExercise(name: 'Rosca Direta', sets: 4, reps: '10-12'),
              _TemplateExercise(name: 'Rosca Martelo', sets: 3, reps: '10-12'),
              _TemplateExercise(name: 'Rosca Scott', sets: 3, reps: '10-12'),
            ],
          ),
          _WorkoutTemplate(
            id: 'hiper_pernas',
            name: 'Pernas - Volume',
            description: 'Treino de volume para membros inferiores',
            difficulty: 'Intermediario',
            duration: 60,
            exerciseCount: 7,
            muscleGroups: ['Quadriceps', 'Posteriores', 'Gluteos'],
            exercises: [
              _TemplateExercise(name: 'Agachamento', sets: 4, reps: '8-12'),
              _TemplateExercise(name: 'Leg Press', sets: 4, reps: '10-12'),
              _TemplateExercise(name: 'Cadeira Extensora', sets: 3, reps: '12-15'),
              _TemplateExercise(name: 'Mesa Flexora', sets: 4, reps: '10-12'),
              _TemplateExercise(name: 'Stiff', sets: 3, reps: '10-12'),
              _TemplateExercise(name: 'Hip Thrust', sets: 3, reps: '10-12'),
              _TemplateExercise(name: 'Panturrilha', sets: 4, reps: '15-20'),
            ],
          ),
          _WorkoutTemplate(
            id: 'hiper_ombros',
            name: 'Ombros - Volume',
            description: 'Treino de volume para deltoides',
            difficulty: 'Intermediario',
            duration: 45,
            exerciseCount: 5,
            muscleGroups: ['Ombros'],
            exercises: [
              _TemplateExercise(name: 'Desenvolvimento', sets: 4, reps: '8-12'),
              _TemplateExercise(name: 'Elevacao Lateral', sets: 4, reps: '12-15'),
              _TemplateExercise(name: 'Elevacao Frontal', sets: 3, reps: '12-15'),
              _TemplateExercise(name: 'Face Pull', sets: 3, reps: '12-15'),
              _TemplateExercise(name: 'Encolhimento', sets: 3, reps: '10-12'),
            ],
          ),
          _WorkoutTemplate(
            id: 'hiper_avancado',
            name: 'Hipertrofia Avancado',
            description: 'Programa completo ABCDE para avancados',
            difficulty: 'Avancado',
            duration: 70,
            exerciseCount: 8,
            muscleGroups: ['Full Body'],
            exercises: [
              _TemplateExercise(name: 'Supino Reto', sets: 5, reps: '6-10'),
              _TemplateExercise(name: 'Supino Inclinado', sets: 4, reps: '8-10'),
              _TemplateExercise(name: 'Cross Over', sets: 4, reps: '10-12'),
              _TemplateExercise(name: 'Crucifixo Inclinado', sets: 3, reps: '12-15'),
              _TemplateExercise(name: 'Triceps Pulley', sets: 4, reps: '10-12'),
              _TemplateExercise(name: 'Triceps Frances', sets: 4, reps: '10-12'),
              _TemplateExercise(name: 'Triceps Testa', sets: 3, reps: '10-12'),
              _TemplateExercise(name: 'Mergulho', sets: 3, reps: 'max'),
            ],
          ),
        ];
      case 'forca':
        return [
          _WorkoutTemplate(
            id: 'forca_iniciante',
            name: 'Forca - Base',
            description: 'Construcao de base de forca',
            difficulty: 'Iniciante',
            duration: 45,
            exerciseCount: 5,
            muscleGroups: ['Full Body'],
            exercises: [
              _TemplateExercise(name: 'Agachamento', sets: 5, reps: '5'),
              _TemplateExercise(name: 'Supino Reto', sets: 5, reps: '5'),
              _TemplateExercise(name: 'Remada Curvada', sets: 5, reps: '5'),
              _TemplateExercise(name: 'Desenvolvimento', sets: 3, reps: '8'),
              _TemplateExercise(name: 'Stiff', sets: 3, reps: '8'),
            ],
          ),
          _WorkoutTemplate(
            id: 'forca_powerlifting',
            name: 'Powerlifting - Big 3',
            description: 'Foco nos 3 levantamentos principais',
            difficulty: 'Avancado',
            duration: 75,
            exerciseCount: 6,
            muscleGroups: ['Full Body'],
            exercises: [
              _TemplateExercise(name: 'Agachamento', sets: 5, reps: '3-5'),
              _TemplateExercise(name: 'Supino Reto', sets: 5, reps: '3-5'),
              _TemplateExercise(name: 'Levantamento Terra', sets: 5, reps: '3-5'),
              _TemplateExercise(name: 'Agachamento Frontal', sets: 3, reps: '6-8'),
              _TemplateExercise(name: 'Supino Fechado', sets: 3, reps: '6-8'),
              _TemplateExercise(name: 'Remada Curvada', sets: 3, reps: '6-8'),
            ],
          ),
          _WorkoutTemplate(
            id: 'forca_upper',
            name: 'Forca Superior',
            description: 'Forca para membros superiores',
            difficulty: 'Intermediario',
            duration: 55,
            exerciseCount: 6,
            muscleGroups: ['Peito', 'Costas', 'Ombros'],
            exercises: [
              _TemplateExercise(name: 'Supino Reto', sets: 5, reps: '5'),
              _TemplateExercise(name: 'Remada Curvada', sets: 5, reps: '5'),
              _TemplateExercise(name: 'Desenvolvimento', sets: 4, reps: '6'),
              _TemplateExercise(name: 'Puxada Frontal', sets: 4, reps: '6'),
              _TemplateExercise(name: 'Supino Inclinado', sets: 3, reps: '8'),
              _TemplateExercise(name: 'Remada Unilateral', sets: 3, reps: '8'),
            ],
          ),
          _WorkoutTemplate(
            id: 'forca_lower',
            name: 'Forca Inferior',
            description: 'Forca para membros inferiores',
            difficulty: 'Intermediario',
            duration: 60,
            exerciseCount: 5,
            muscleGroups: ['Quadriceps', 'Posteriores', 'Gluteos'],
            exercises: [
              _TemplateExercise(name: 'Agachamento', sets: 5, reps: '5'),
              _TemplateExercise(name: 'Levantamento Terra', sets: 5, reps: '5'),
              _TemplateExercise(name: 'Agachamento Frontal', sets: 4, reps: '6'),
              _TemplateExercise(name: 'Hip Thrust', sets: 4, reps: '6'),
              _TemplateExercise(name: 'Leg Press', sets: 3, reps: '8'),
            ],
          ),
        ];
      case 'emagrecimento':
        return [
          _WorkoutTemplate(
            id: 'emag_circuito',
            name: 'Circuito Queima Gordura',
            description: 'Treino em circuito para perda de gordura',
            difficulty: 'Iniciante',
            duration: 40,
            exerciseCount: 8,
            muscleGroups: ['Full Body', 'Cardio'],
            exercises: [
              _TemplateExercise(name: 'Agachamento', sets: 3, reps: '15'),
              _TemplateExercise(name: 'Flexao', sets: 3, reps: '12'),
              _TemplateExercise(name: 'Remada Unilateral', sets: 3, reps: '12'),
              _TemplateExercise(name: 'Afundo', sets: 3, reps: '12'),
              _TemplateExercise(name: 'Desenvolvimento', sets: 3, reps: '12'),
              _TemplateExercise(name: 'Prancha', sets: 3, reps: '30s'),
              _TemplateExercise(name: 'Polichinelo', sets: 3, reps: '30'),
              _TemplateExercise(name: 'Abdominal', sets: 3, reps: '15'),
            ],
          ),
          _WorkoutTemplate(
            id: 'emag_hiit',
            name: 'HIIT Queima Total',
            description: 'Treino intervalado de alta intensidade',
            difficulty: 'Avancado',
            duration: 30,
            exerciseCount: 8,
            muscleGroups: ['Full Body', 'Cardio'],
            exercises: [
              _TemplateExercise(name: 'Burpees', sets: 4, reps: '30s'),
              _TemplateExercise(name: 'Mountain Climbers', sets: 4, reps: '30s'),
              _TemplateExercise(name: 'Jump Squats', sets: 4, reps: '30s'),
              _TemplateExercise(name: 'High Knees', sets: 4, reps: '30s'),
              _TemplateExercise(name: 'Push Ups', sets: 4, reps: '30s'),
              _TemplateExercise(name: 'Jumping Jacks', sets: 4, reps: '30s'),
              _TemplateExercise(name: 'Plank', sets: 3, reps: '45s'),
              _TemplateExercise(name: 'Box Jumps', sets: 3, reps: '30s'),
            ],
          ),
          _WorkoutTemplate(
            id: 'emag_upper',
            name: 'Superior - Definicao',
            description: 'Treino de definicao para superiores',
            difficulty: 'Intermediario',
            duration: 45,
            exerciseCount: 7,
            muscleGroups: ['Peito', 'Costas', 'Ombros', 'Bracos'],
            exercises: [
              _TemplateExercise(name: 'Supino Reto', sets: 4, reps: '12-15'),
              _TemplateExercise(name: 'Puxada Frontal', sets: 4, reps: '12-15'),
              _TemplateExercise(name: 'Desenvolvimento', sets: 3, reps: '12-15'),
              _TemplateExercise(name: 'Remada Baixa', sets: 3, reps: '12-15'),
              _TemplateExercise(name: 'Cross Over', sets: 3, reps: '15-20'),
              _TemplateExercise(name: 'Rosca Direta', sets: 3, reps: '12-15'),
              _TemplateExercise(name: 'Triceps Pulley', sets: 3, reps: '12-15'),
            ],
          ),
          _WorkoutTemplate(
            id: 'emag_lower',
            name: 'Inferior - Definicao',
            description: 'Treino de definicao para inferiores',
            difficulty: 'Intermediario',
            duration: 45,
            exerciseCount: 6,
            muscleGroups: ['Quadriceps', 'Posteriores', 'Gluteos'],
            exercises: [
              _TemplateExercise(name: 'Agachamento', sets: 4, reps: '12-15'),
              _TemplateExercise(name: 'Leg Press', sets: 4, reps: '15'),
              _TemplateExercise(name: 'Cadeira Extensora', sets: 3, reps: '15'),
              _TemplateExercise(name: 'Mesa Flexora', sets: 3, reps: '15'),
              _TemplateExercise(name: 'Afundo', sets: 3, reps: '12'),
              _TemplateExercise(name: 'Panturrilha', sets: 4, reps: '20'),
            ],
          ),
          _WorkoutTemplate(
            id: 'emag_abdomen',
            name: 'Core e Abdomen',
            description: 'Treino focado em abdomen e core',
            difficulty: 'Intermediario',
            duration: 30,
            exerciseCount: 6,
            muscleGroups: ['Abdomen', 'Core'],
            exercises: [
              _TemplateExercise(name: 'Prancha', sets: 4, reps: '45s'),
              _TemplateExercise(name: 'Abdominal Infra', sets: 4, reps: '15'),
              _TemplateExercise(name: 'Abdominal Obliquo', sets: 3, reps: '15'),
              _TemplateExercise(name: 'Prancha Lateral', sets: 3, reps: '30s'),
              _TemplateExercise(name: 'Bicicleta', sets: 3, reps: '20'),
              _TemplateExercise(name: 'Escalador', sets: 3, reps: '30s'),
            ],
          ),
        ];
      case 'resistencia':
        return [
          _WorkoutTemplate(
            id: 'resist_iniciante',
            name: 'Resistencia - Base',
            description: 'Construcao de base de resistencia',
            difficulty: 'Iniciante',
            duration: 40,
            exerciseCount: 6,
            muscleGroups: ['Full Body', 'Cardio'],
            exercises: [
              _TemplateExercise(name: 'Corrida Leve', sets: 1, reps: '10min'),
              _TemplateExercise(name: 'Agachamento', sets: 3, reps: '20'),
              _TemplateExercise(name: 'Flexao', sets: 3, reps: '15'),
              _TemplateExercise(name: 'Remada', sets: 3, reps: '15'),
              _TemplateExercise(name: 'Afundo', sets: 3, reps: '15'),
              _TemplateExercise(name: 'Corrida Leve', sets: 1, reps: '10min'),
            ],
          ),
          _WorkoutTemplate(
            id: 'resist_crossfit',
            name: 'Estilo Crossfit',
            description: 'Treino de alta intensidade variado',
            difficulty: 'Avancado',
            duration: 50,
            exerciseCount: 8,
            muscleGroups: ['Full Body', 'Cardio'],
            exercises: [
              _TemplateExercise(name: 'Remo Ergometrico', sets: 1, reps: '500m'),
              _TemplateExercise(name: 'Thruster', sets: 5, reps: '10'),
              _TemplateExercise(name: 'Pull Up', sets: 5, reps: '10'),
              _TemplateExercise(name: 'Box Jump', sets: 5, reps: '15'),
              _TemplateExercise(name: 'Kettlebell Swing', sets: 5, reps: '15'),
              _TemplateExercise(name: 'Burpees', sets: 4, reps: '10'),
              _TemplateExercise(name: 'Wall Ball', sets: 4, reps: '15'),
              _TemplateExercise(name: 'Remo Ergometrico', sets: 1, reps: '500m'),
            ],
          ),
          _WorkoutTemplate(
            id: 'resist_cardio',
            name: 'Cardio Completo',
            description: 'Treino cardiovascular completo',
            difficulty: 'Intermediario',
            duration: 45,
            exerciseCount: 6,
            muscleGroups: ['Cardio'],
            exercises: [
              _TemplateExercise(name: 'Aquecimento', sets: 1, reps: '5min'),
              _TemplateExercise(name: 'Corrida Intervalada', sets: 8, reps: '1min/1min'),
              _TemplateExercise(name: 'Bicicleta', sets: 1, reps: '10min'),
              _TemplateExercise(name: 'Eliptico', sets: 1, reps: '10min'),
              _TemplateExercise(name: 'Escada', sets: 1, reps: '5min'),
              _TemplateExercise(name: 'Desaquecimento', sets: 1, reps: '5min'),
            ],
          ),
          _WorkoutTemplate(
            id: 'resist_circuito',
            name: 'Circuito Resistencia',
            description: 'Circuito para resistencia muscular',
            difficulty: 'Intermediario',
            duration: 40,
            exerciseCount: 8,
            muscleGroups: ['Full Body'],
            exercises: [
              _TemplateExercise(name: 'Agachamento', sets: 4, reps: '20'),
              _TemplateExercise(name: 'Flexao', sets: 4, reps: '15'),
              _TemplateExercise(name: 'Remada TRX', sets: 4, reps: '15'),
              _TemplateExercise(name: 'Step Up', sets: 4, reps: '15'),
              _TemplateExercise(name: 'Dips', sets: 4, reps: '12'),
              _TemplateExercise(name: 'Prancha', sets: 4, reps: '45s'),
              _TemplateExercise(name: 'Corda', sets: 4, reps: '1min'),
              _TemplateExercise(name: 'Mountain Climbers', sets: 4, reps: '30s'),
            ],
          ),
        ];
      case 'funcional':
        return [
          _WorkoutTemplate(
            id: 'func_iniciante',
            name: 'Funcional - Base',
            description: 'Movimentos funcionais basicos',
            difficulty: 'Iniciante',
            duration: 35,
            exerciseCount: 6,
            muscleGroups: ['Full Body'],
            exercises: [
              _TemplateExercise(name: 'Agachamento Livre', sets: 3, reps: '15'),
              _TemplateExercise(name: 'Flexao', sets: 3, reps: '10'),
              _TemplateExercise(name: 'Prancha', sets: 3, reps: '30s'),
              _TemplateExercise(name: 'Afundo', sets: 3, reps: '10'),
              _TemplateExercise(name: 'Remada TRX', sets: 3, reps: '12'),
              _TemplateExercise(name: 'Ponte de Gluteo', sets: 3, reps: '15'),
            ],
          ),
          _WorkoutTemplate(
            id: 'func_mobilidade',
            name: 'Mobilidade e Flexibilidade',
            description: 'Melhora de mobilidade articular',
            difficulty: 'Iniciante',
            duration: 30,
            exerciseCount: 8,
            muscleGroups: ['Full Body'],
            exercises: [
              _TemplateExercise(name: 'Cat-Cow', sets: 2, reps: '10'),
              _TemplateExercise(name: 'Alongamento Quadril', sets: 2, reps: '30s'),
              _TemplateExercise(name: 'Rotacao Torax', sets: 2, reps: '10'),
              _TemplateExercise(name: 'Alongamento Panturrilha', sets: 2, reps: '30s'),
              _TemplateExercise(name: 'World Greatest Stretch', sets: 2, reps: '8'),
              _TemplateExercise(name: 'Alongamento Ombro', sets: 2, reps: '30s'),
              _TemplateExercise(name: 'Hip 90/90', sets: 2, reps: '30s'),
              _TemplateExercise(name: 'Alongamento Posterior', sets: 2, reps: '30s'),
            ],
          ),
          _WorkoutTemplate(
            id: 'func_avancado',
            name: 'Funcional Avancado',
            description: 'Treino funcional de alta intensidade',
            difficulty: 'Avancado',
            duration: 50,
            exerciseCount: 8,
            muscleGroups: ['Full Body'],
            exercises: [
              _TemplateExercise(name: 'Turkish Get Up', sets: 3, reps: '5'),
              _TemplateExercise(name: 'Kettlebell Clean', sets: 4, reps: '8'),
              _TemplateExercise(name: 'Pistol Squat', sets: 3, reps: '6'),
              _TemplateExercise(name: 'Pull Up', sets: 4, reps: '8'),
              _TemplateExercise(name: 'Handstand Push Up', sets: 3, reps: '5'),
              _TemplateExercise(name: 'Single Leg RDL', sets: 3, reps: '8'),
              _TemplateExercise(name: 'Crawling', sets: 3, reps: '20m'),
              _TemplateExercise(name: 'Farmer Walk', sets: 3, reps: '30m'),
            ],
          ),
        ];
      default:
        return [];
    }
  }

  void _selectCategory(String categoryId) {
    HapticUtils.selectionClick();
    setState(() {
      _selectedCategory = categoryId;
      _selectedTemplate = null;
    });
  }

  void _selectTemplate(_WorkoutTemplate template) {
    HapticUtils.selectionClick();
    setState(() {
      _selectedTemplate = template;
    });
  }

  bool _isCreating = false;

  Future<void> _useTemplate() async {
    if (_selectedTemplate == null || _isCreating) return;

    HapticUtils.mediumImpact();
    setState(() {
      _isCreating = true;
    });

    try {
      final template = _selectedTemplate!;

      // Map Portuguese difficulty to English
      final difficultyMap = {
        'iniciante': 'beginner',
        'intermediario': 'intermediate',
        'avancado': 'advanced',
      };
      final mappedDifficulty = difficultyMap[template.difficulty.toLowerCase()] ?? 'intermediate';

      // Create workout via API
      await ref.read(workoutsNotifierProvider.notifier).createWorkout(
        name: template.name,
        description: template.description,
        difficulty: mappedDifficulty,
        estimatedDuration: template.duration,
        muscleGroups: template.muscleGroups,
      );

      // Get the created workout (it's added to the beginning of the list)
      final workouts = ref.read(workoutsProvider);
      if (workouts.isNotEmpty) {
        final createdWorkout = workouts.first;
        final workoutId = createdWorkout['id']?.toString();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Treino "${template.name}" criado com sucesso!',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
            ),
          );

          // Navigate to the created workout detail page
          if (workoutId != null && workoutId.isNotEmpty) {
            context.go('/workouts/$workoutId');
          } else {
            context.pop();
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Treino criado! Volte para a lista de treinos para visualizar.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao criar treino: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  void _goBack() {
    HapticUtils.lightImpact();
    if (_selectedTemplate != null) {
      setState(() {
        _selectedTemplate = null;
      });
    } else if (_selectedCategory != null) {
      setState(() {
        _selectedCategory = null;
      });
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(isDark ? 15 : 10),
              (isDark ? AppColors.secondaryDark : AppColors.secondary).withAlpha(isDark ? 12 : 8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              _buildAppBar(theme, isDark),

              // Content
              Expanded(
                child: _selectedTemplate != null
                    ? _buildTemplateDetailView(theme, isDark)
                    : _selectedCategory != null
                        ? _buildTemplateListView(theme, isDark)
                        : _buildCategoriesView(theme, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, bool isDark) {
    String title = 'Templates de Treino';
    if (_selectedCategory != null) {
      final category = _categories.firstWhere((c) => c.id == _selectedCategory);
      title = category.name;
    }
    if (_selectedTemplate != null) {
      title = _selectedTemplate!.name;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.arrowLeft, size: 20, color: isDark ? AppColors.foregroundDark : AppColors.foreground),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Icon(
                  LucideIcons.layoutTemplate,
                  size: 20,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesView(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          FadeInUp(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(26),
                    (isDark ? AppColors.secondaryDark : AppColors.secondary).withAlpha(26),
                  ],
                ),
                border: Border.all(
                  color: (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(77),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.layoutTemplate,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Escolha um Template',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        Text(
                          'Selecione uma categoria para ver os templates disponiveis',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Categories Section Title
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Row(
              children: [
                Icon(
                  LucideIcons.folder,
                  size: 18,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Categorias',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Categories Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return FadeInUp(
                delay: Duration(milliseconds: 150 + (index * 50)),
                child: _buildCategoryCard(theme, isDark, category),
              );
            },
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ThemeData theme, bool isDark, _TemplateCategory category) {
    return GestureDetector(
      onTap: () => _selectCategory(category.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.primaryDark : AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category.icon,
                size: 22,
                color: Colors.white,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${category.templateCount} templates',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateListView(ThemeData theme, bool isDark) {
    final templates = _getTemplatesForCategory(_selectedCategory!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Info
          FadeInUp(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 18,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _categories.firstWhere((c) => c.id == _selectedCategory).description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Templates
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Row(
              children: [
                Icon(
                  LucideIcons.fileText,
                  size: 18,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Templates Disponiveis',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          ...templates.asMap().entries.map((entry) {
            final index = entry.key;
            final template = entry.value;
            return FadeInUp(
              delay: Duration(milliseconds: 150 + (index * 50)),
              child: _buildTemplateCard(theme, isDark, template),
            );
          }),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(ThemeData theme, bool isDark, _WorkoutTemplate template) {
    return GestureDetector(
      onTap: () => _selectTemplate(template),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.dumbbell,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      Text(
                        template.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTemplateStatChip(
                  theme,
                  isDark,
                  '${template.exerciseCount} exercicios',
                  LucideIcons.listOrdered,
                ),
                const SizedBox(width: 8),
                _buildTemplateStatChip(
                  theme,
                  isDark,
                  '${template.duration} min',
                  LucideIcons.clock,
                ),
                const SizedBox(width: 8),
                _buildTemplateStatChip(
                  theme,
                  isDark,
                  template.difficulty,
                  LucideIcons.gauge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateStatChip(ThemeData theme, bool isDark, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.mutedDark.withAlpha(100)
            : AppColors.muted.withAlpha(150),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateDetailView(ThemeData theme, bool isDark) {
    final template = _selectedTemplate!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Template Header
                FadeInUp(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(26),
                          (isDark ? AppColors.secondaryDark : AppColors.secondary).withAlpha(26),
                        ],
                      ),
                      border: Border.all(
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.primaryDark : AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                LucideIcons.dumbbell,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                    ),
                                  ),
                                  Text(
                                    template.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildDetailStat(
                              theme,
                              isDark,
                              '${template.exerciseCount}',
                              'exercicios',
                              LucideIcons.listOrdered,
                            ),
                            const SizedBox(width: 24),
                            _buildDetailStat(
                              theme,
                              isDark,
                              '${template.duration}',
                              'minutos',
                              LucideIcons.clock,
                            ),
                            const SizedBox(width: 24),
                            _buildDetailStat(
                              theme,
                              isDark,
                              template.difficulty,
                              'nivel',
                              LucideIcons.gauge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Muscle Groups
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.activity,
                        size: 18,
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Grupos Musculares',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: template.muscleGroups.map((muscle) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(26),
                          border: Border.all(
                            color: (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(77),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          muscle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Exercises
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.listOrdered,
                        size: 18,
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Exercicios',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                ...template.exercises.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exercise = entry.value;
                  return FadeInUp(
                    delay: Duration(milliseconds: 250 + (index * 30)),
                    child: _buildExerciseItem(theme, isDark, exercise, index),
                  );
                }),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.backgroundDark.withAlpha(240)
                : AppColors.background.withAlpha(240),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isCreating ? null : _useTemplate,
                icon: _isCreating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(LucideIcons.check, size: 18),
                label: Text(_isCreating ? 'Criando...' : 'Usar Este Template'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailStat(
    ThemeData theme,
    bool isDark,
    String value,
    String label,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? AppColors.primaryDark : AppColors.primary,
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseItem(ThemeData theme, bool isDark, _TemplateExercise exercise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryDark : AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${index + 1}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              exercise.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          Text(
            '${exercise.sets}x${exercise.reps}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.primaryDark : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Template category model
class _TemplateCategory {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final int templateCount;

  _TemplateCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.templateCount,
  });
}

/// Workout template model
class _WorkoutTemplate {
  final String id;
  final String name;
  final String description;
  final String difficulty;
  final int duration;
  final int exerciseCount;
  final List<String> muscleGroups;
  final List<_TemplateExercise> exercises;

  _WorkoutTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.duration,
    required this.exerciseCount,
    required this.muscleGroups,
    required this.exercises,
  });
}

/// Template exercise model
class _TemplateExercise {
  final String name;
  final int sets;
  final String reps;

  _TemplateExercise({
    required this.name,
    required this.sets,
    required this.reps,
  });
}
