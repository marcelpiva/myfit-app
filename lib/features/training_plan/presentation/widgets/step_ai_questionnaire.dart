import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/workout_service.dart';
import '../../domain/models/training_plan.dart';
import '../providers/plan_wizard_provider.dart';

/// Step for AI-powered program generation questionnaire
class StepAIQuestionnaire extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onCancel;

  const StepAIQuestionnaire({
    super.key,
    required this.onComplete,
    this.onCancel,
  });

  @override
  ConsumerState<StepAIQuestionnaire> createState() => _StepAIQuestionnaireState();
}

class _StepAIQuestionnaireState extends ConsumerState<StepAIQuestionnaire> {
  final PageController _pageController = PageController();
  int _currentQuestion = 0;
  bool _isGenerating = false;
  String? _error;

  // Questionnaire answers
  WorkoutGoal _goal = WorkoutGoal.hypertrophy;
  PlanDifficulty _difficulty = PlanDifficulty.intermediate;
  int _daysPerWeek = 4;
  int _minutesPerSession = 60;
  String _equipment = 'full_gym';
  final List<String> _injuries = [];
  String _preferences = 'mixed';
  int _durationWeeks = 8;

  final List<_Question> _questions = [
    _Question(
      title: 'Qual o objetivo principal?',
      subtitle: 'Isso nos ajuda a selecionar os exercícios e configurar séries/repetições',
      icon: LucideIcons.target,
    ),
    _Question(
      title: 'Qual o nível de experiência?',
      subtitle: 'Ajustamos a complexidade dos exercícios e volume de treino',
      icon: LucideIcons.gauge,
    ),
    _Question(
      title: 'Quantos dias por semana?',
      subtitle: 'Isso determina a divisão do treino (split)',
      icon: LucideIcons.calendar,
    ),
    _Question(
      title: 'Quanto tempo por treino?',
      subtitle: 'Ajustamos a quantidade de exercícios',
      icon: LucideIcons.clock,
    ),
    _Question(
      title: 'Quais equipamentos disponíveis?',
      subtitle: 'Selecionamos exercícios compatíveis',
      icon: LucideIcons.dumbbell,
    ),
    _Question(
      title: 'Alguma lesão ou restrição?',
      subtitle: 'Evitamos exercícios que possam agravar',
      icon: LucideIcons.heartPulse,
    ),
    _Question(
      title: 'Preferências de treino?',
      subtitle: 'Priorizamos o tipo de exercício preferido',
      icon: LucideIcons.settings,
    ),
    _Question(
      title: 'Duração do plano?',
      subtitle: 'Tempo total do ciclo de treinamento',
      icon: LucideIcons.calendarDays,
    ),
  ];

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      HapticUtils.selectionClick();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentQuestion++;
      });
    } else {
      _generateProgram();
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      HapticUtils.selectionClick();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentQuestion--;
      });
    }
  }

  Future<void> _generateProgram() async {
    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      final workoutService = WorkoutService();
      final result = await workoutService.generatePlanWithAI(
        goal: _goal.toApiValue(),
        difficulty: _difficulty.toApiValue(),
        daysPerWeek: _daysPerWeek,
        minutesPerSession: _minutesPerSession,
        equipment: _equipment,
        injuries: _injuries.isNotEmpty ? _injuries : null,
        preferences: _preferences,
        durationWeeks: _durationWeeks,
      );

      // Fill wizard with AI-generated data
      final notifier = ref.read(planWizardProvider.notifier);
      notifier.loadFromAIGenerated(result);

      // Check if there was an error in loading
      final state = ref.read(planWizardProvider);
      if (state.error != null) {
        throw Exception(state.error);
      }

      if (mounted) {
        widget.onComplete();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        // Keep _isGenerating = true so error is shown in the loading screen
        // User can tap "Voltar" to go back to questionnaire
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isGenerating) {
      return SafeArea(
        child: Column(
          children: [
            // Header with close button (also in generating state)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      HapticUtils.lightImpact();
                      setState(() {
                        _isGenerating = false;
                        _error = null;
                      });
                    },
                    icon: const Icon(LucideIcons.x),
                    tooltip: 'Cancelar',
                  ),
                ],
              ),
            ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(30),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Gerando plano...',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A IA está selecionando os melhores exercícios',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.destructive.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(color: AppColors.destructive),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _isGenerating = false;
                          _error = null;
                        });
                      },
                      child: const Text('Voltar'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          // Header with close button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gerar com IA',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    if (widget.onCancel != null) {
                      widget.onCancel!();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(LucideIcons.x),
                  tooltip: 'Fechar',
                ),
              ],
            ),
          ),
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(_questions.length, (index) {
                final isActive = index <= _currentQuestion;
                final isCurrent = index == _currentQuestion;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < _questions.length - 1 ? 4 : 0),
                    height: 3,
                    decoration: BoxDecoration(
                      color: isActive
                          ? (isCurrent
                              ? AppColors.secondary
                              : AppColors.secondary.withAlpha(150))
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Question pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildGoalQuestion(theme, isDark),
                _buildDifficultyQuestion(theme, isDark),
                _buildDaysQuestion(theme, isDark),
                _buildDurationQuestion(theme, isDark),
                _buildEquipmentQuestion(theme, isDark),
                _buildInjuriesQuestion(theme, isDark),
                _buildPreferencesQuestion(theme, isDark),
                _buildWeeksQuestion(theme, isDark),
              ],
            ),
          ),

          // Navigation buttons
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentQuestion > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousQuestion,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Voltar'),
                      ),
                    ),
                  if (_currentQuestion > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _nextQuestion,
                      icon: Icon(
                        _currentQuestion == _questions.length - 1
                            ? LucideIcons.sparkles
                            : LucideIcons.arrowRight,
                        size: 18,
                      ),
                      label: Text(
                        _currentQuestion == _questions.length - 1
                            ? 'Gerar Plano'
                            : 'Continuar',
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(_Question question, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(30),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(question.icon, color: AppColors.secondary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            question.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            question.subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalQuestion(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildQuestionHeader(_questions[0], theme),
          const SizedBox(height: 16),
          ...WorkoutGoal.values.map((goal) => _OptionCard(
                title: _getGoalTitle(goal),
                description: _getGoalDescription(goal),
                isSelected: _goal == goal,
                isDark: isDark,
                theme: theme,
                onTap: () {
                  HapticUtils.selectionClick();
                  setState(() => _goal = goal);
                },
              )),
        ],
      ),
    );
  }

  String _getGoalTitle(WorkoutGoal goal) {
    switch (goal) {
      case WorkoutGoal.hypertrophy:
        return 'Hipertrofia';
      case WorkoutGoal.strength:
        return 'Força';
      case WorkoutGoal.fatLoss:
        return 'Emagrecimento';
      case WorkoutGoal.endurance:
        return 'Resistência';
      case WorkoutGoal.generalFitness:
        return 'Condicionamento Geral';
      case WorkoutGoal.functional:
        return 'Funcional';
    }
  }

  String _getGoalDescription(WorkoutGoal goal) {
    switch (goal) {
      case WorkoutGoal.hypertrophy:
        return 'Aumento de massa muscular';
      case WorkoutGoal.strength:
        return 'Aumento de força máxima';
      case WorkoutGoal.fatLoss:
        return 'Queima de gordura';
      case WorkoutGoal.endurance:
        return 'Resistência muscular';
      case WorkoutGoal.generalFitness:
        return 'Saúde e condicionamento';
      case WorkoutGoal.functional:
        return 'Movimentos funcionais do dia a dia';
    }
  }

  Widget _buildDifficultyQuestion(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildQuestionHeader(_questions[1], theme),
          const SizedBox(height: 16),
          ...PlanDifficulty.values.map((diff) => _OptionCard(
                title: _getDifficultyTitle(diff),
                description: _getDifficultyDescription(diff),
                isSelected: _difficulty == diff,
                isDark: isDark,
                theme: theme,
                onTap: () {
                  HapticUtils.selectionClick();
                  setState(() => _difficulty = diff);
                },
              )),
        ],
      ),
    );
  }

  String _getDifficultyTitle(PlanDifficulty diff) {
    switch (diff) {
      case PlanDifficulty.beginner:
        return 'Iniciante';
      case PlanDifficulty.intermediate:
        return 'Intermediário';
      case PlanDifficulty.advanced:
        return 'Avançado';
    }
  }

  String _getDifficultyDescription(PlanDifficulty diff) {
    switch (diff) {
      case PlanDifficulty.beginner:
        return 'Menos de 6 meses de treino';
      case PlanDifficulty.intermediate:
        return '6 meses a 2 anos de treino';
      case PlanDifficulty.advanced:
        return 'Mais de 2 anos de treino consistente';
    }
  }

  Widget _buildDaysQuestion(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildQuestionHeader(_questions[2], theme),
          const SizedBox(height: 16),
          ...[2, 3, 4, 5, 6].map((days) => _OptionCard(
                title: '$days dias por semana',
                description: _getDaysDescription(days),
                isSelected: _daysPerWeek == days,
                isDark: isDark,
                theme: theme,
                onTap: () {
                  HapticUtils.selectionClick();
                  setState(() => _daysPerWeek = days);
                },
              )),
        ],
      ),
    );
  }

  String _getDaysDescription(int days) {
    switch (days) {
      case 2:
        return 'Full Body - Corpo inteiro a cada treino';
      case 3:
        return 'ABC - Divisão em 3 treinos diferentes';
      case 4:
        return 'Upper/Lower - Superior e inferior alternados';
      case 5:
        return 'ABCDE - Um grupo muscular por dia';
      case 6:
        return 'Push/Pull/Legs 2x - Alta frequência';
      default:
        return '';
    }
  }

  Widget _buildDurationQuestion(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildQuestionHeader(_questions[3], theme),
          const SizedBox(height: 16),
          ...[30, 45, 60, 75, 90].map((minutes) => _OptionCard(
                title: '$minutes minutos',
                description: _getMinutesDescription(minutes),
                isSelected: _minutesPerSession == minutes,
                isDark: isDark,
                theme: theme,
                onTap: () {
                  HapticUtils.selectionClick();
                  setState(() => _minutesPerSession = minutes);
                },
              )),
        ],
      ),
    );
  }

  String _getMinutesDescription(int minutes) {
    if (minutes <= 30) return 'Treino rápido - 4 a 5 exercícios';
    if (minutes <= 45) return 'Treino moderado - 5 a 6 exercícios';
    if (minutes <= 60) return 'Treino padrão - 6 a 7 exercícios';
    if (minutes <= 75) return 'Treino completo - 7 a 8 exercícios';
    return 'Treino extenso - 8+ exercícios';
  }

  Widget _buildEquipmentQuestion(ThemeData theme, bool isDark) {
    final options = [
      ('full_gym', 'Academia Completa', 'Todos os equipamentos disponíveis'),
      ('home_full', 'Home Gym Completa', 'Halteres, barra e banco'),
      ('home_dumbbells', 'Halteres em Casa', 'Apenas halteres ajustáveis'),
      ('home_basic', 'Equipamento Básico', 'Elásticos e peso corporal'),
      ('bodyweight', 'Peso Corporal', 'Sem equipamentos'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildQuestionHeader(_questions[4], theme),
          const SizedBox(height: 16),
          ...options.map((opt) => _OptionCard(
                title: opt.$2,
                description: opt.$3,
                isSelected: _equipment == opt.$1,
                isDark: isDark,
                theme: theme,
                onTap: () {
                  HapticUtils.selectionClick();
                  setState(() => _equipment = opt.$1);
                },
              )),
        ],
      ),
    );
  }

  Widget _buildInjuriesQuestion(ThemeData theme, bool isDark) {
    final options = [
      ('none', 'Nenhuma', 'Sem lesões ou restrições'),
      ('shoulder', 'Ombro', 'Evitar exercícios de ombro'),
      ('knee', 'Joelho', 'Evitar agachamentos profundos'),
      ('back', 'Coluna', 'Evitar carga axial'),
      ('wrist', 'Punho', 'Evitar pegadas pesadas'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildQuestionHeader(_questions[5], theme),
          const SizedBox(height: 16),
          ...options.map((opt) => _OptionCard(
                title: opt.$2,
                description: opt.$3,
                isSelected: opt.$1 == 'none'
                    ? _injuries.isEmpty
                    : _injuries.contains(opt.$1),
                isDark: isDark,
                theme: theme,
                onTap: () {
                  HapticUtils.selectionClick();
                  setState(() {
                    if (opt.$1 == 'none') {
                      _injuries.clear();
                    } else {
                      if (_injuries.contains(opt.$1)) {
                        _injuries.remove(opt.$1);
                      } else {
                        _injuries.add(opt.$1);
                      }
                    }
                  });
                },
              )),
        ],
      ),
    );
  }

  Widget _buildPreferencesQuestion(ThemeData theme, bool isDark) {
    final options = [
      ('mixed', 'Misto', 'Combinação de máquinas e pesos livres'),
      ('free_weights', 'Pesos Livres', 'Halteres e barras'),
      ('machines', 'Máquinas', 'Equipamentos guiados'),
      ('bodyweight', 'Calistenia', 'Exercícios com peso corporal'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildQuestionHeader(_questions[6], theme),
          const SizedBox(height: 16),
          ...options.map((opt) => _OptionCard(
                title: opt.$2,
                description: opt.$3,
                isSelected: _preferences == opt.$1,
                isDark: isDark,
                theme: theme,
                onTap: () {
                  HapticUtils.selectionClick();
                  setState(() => _preferences = opt.$1);
                },
              )),
        ],
      ),
    );
  }

  Widget _buildWeeksQuestion(ThemeData theme, bool isDark) {
    final options = [
      (4, '4 semanas', 'Ciclo curto - Introdução ou manutenção'),
      (8, '8 semanas', 'Ciclo padrão - Tempo ideal para progressão'),
      (12, '12 semanas', 'Ciclo longo - Transformação completa'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildQuestionHeader(_questions[7], theme),
          const SizedBox(height: 16),
          ...options.map((opt) => _OptionCard(
                title: opt.$2,
                description: opt.$3,
                isSelected: _durationWeeks == opt.$1,
                isDark: isDark,
                theme: theme,
                onTap: () {
                  HapticUtils.selectionClick();
                  setState(() => _durationWeeks = opt.$1);
                },
              )),
        ],
      ),
    );
  }
}

class _Question {
  final String title;
  final String subtitle;
  final IconData icon;

  const _Question({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.isDark,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withAlpha(20)
              : (isDark
                  ? theme.colorScheme.surfaceContainerLowest.withAlpha(150)
                  : theme.colorScheme.surfaceContainerLowest.withAlpha(200)),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.secondary : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
