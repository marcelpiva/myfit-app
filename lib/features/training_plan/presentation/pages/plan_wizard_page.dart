import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../trainer_workout/presentation/pages/trainer_plans_page.dart';
import '../../../workout/presentation/providers/workout_provider.dart';
import '../providers/plan_wizard_provider.dart';
import '../widgets/step_ai_questionnaire.dart';
import '../widgets/step_diet_configuration.dart';
import '../widgets/step_method_selection.dart';
import '../widgets/step_plan_info.dart';
import '../widgets/step_review.dart';
import '../widgets/step_split_selection.dart';
import '../widgets/step_student_assignment.dart';
import '../widgets/step_workouts_config.dart';
import '../widgets/template_browser_sheet.dart';

/// Main wizard page for creating workout programs
class PlanWizardPage extends ConsumerStatefulWidget {
  final String? studentId;
  final String? planId;
  final String? basePlanId; // For periodization: the source plan to base new plan on
  final String? phaseType; // For periodization: 'progress', 'deload', or 'new_cycle'

  const PlanWizardPage({
    super.key,
    this.studentId,
    this.planId,
    this.basePlanId,
    this.phaseType,
  });

  /// Check if this is an edit operation
  bool get isEditing => planId != null;

  /// Check if this is a periodization operation
  bool get isPeriodization => basePlanId != null && phaseType != null;

  @override
  ConsumerState<PlanWizardPage> createState() => _PlanWizardPageState();
}

class _PlanWizardPageState extends ConsumerState<PlanWizardPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Initialize PageController with correct initial page
    // Edit mode starts at step 3 (workouts config)
    _pageController = PageController(initialPage: widget.planId != null ? 3 : 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load program for editing if planId is provided
      if (widget.planId != null) {
        ref.read(planWizardProvider.notifier).loadPlanForEdit(widget.planId!);
      }
      // Load program for periodization if basePlanId and phaseType are provided
      else if (widget.isPeriodization) {
        final phase = widget.phaseType!.toPeriodizationPhase();
        if (phase != null) {
          ref.read(planWizardProvider.notifier).loadPlanForPeriodization(
            widget.basePlanId!,
            phase,
          );
          // Jump to step 1 (skip method selection in periodization mode)
          _pageController.jumpToPage(1);
        }
      }
      // Set student ID if provided
      if (widget.studentId != null) {
        ref.read(planWizardProvider.notifier).setStudentId(widget.studentId);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    ref.read(planWizardProvider.notifier).goToStep(step);
  }

  void _nextStep() {
    final state = ref.read(planWizardProvider);

    // Validate current step before proceeding
    final validationError = _validateCurrentStep(state);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    if (!state.isLastStep) {
      _goToStep(state.currentStep + 1);
    }
  }

  String? _validateCurrentStep(PlanWizardState state) {
    switch (state.currentStep) {
      case 0: // Method selection
        if (state.method == null) {
          return 'Selecione um método de criação';
        }
        break;
      case 1: // Program info
        if (state.planName.trim().isEmpty) {
          return 'Informe o nome do plano';
        }
        if (state.planName.trim().length < 3) {
          return 'O nome deve ter pelo menos 3 caracteres';
        }
        break;
      case 2: // Split selection
        // Split has a default value, always valid
        break;
      case 3: // Workouts config
        if (state.workouts.isEmpty) {
          return 'Adicione pelo menos um treino';
        }
        final emptyWorkout = state.workouts.where((w) => w.exercises.isEmpty).firstOrNull;
        if (emptyWorkout != null) {
          return 'O treino "${emptyWorkout.name}" precisa de pelo menos um exercício';
        }
        break;
      case 4: // Diet (optional)
        // Diet is optional, always valid
        break;
      case 5: // Review
        // Review step, always valid
        break;
    }
    return null;
  }

  void _previousStep() {
    final state = ref.read(planWizardProvider);

    if (state.currentStep > state.firstStep) {
      _goToStep(state.currentStep - 1);
    } else {
      // Just navigate back without confirmation
      ref.read(planWizardProvider.notifier).reset();
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmClose() async {
    final state = ref.read(planWizardProvider);

    // If no changes made (still on step 0 or no name entered), just close
    if (state.currentStep == 0 && state.planName.isEmpty) {
      ref.read(planWizardProvider.notifier).reset();
      Navigator.of(context).pop();
      return;
    }

    // Show confirmation dialog
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar plano?'),
        content: const Text('As alterações não salvas serão perdidas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
            ),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );

    if (shouldClose == true && mounted) {
      ref.read(planWizardProvider.notifier).reset();
      Navigator.of(context).pop();
    }
  }

  void _showTemplateBrowser() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TemplateBrowserSheet(
        onTemplateSelected: (template) {
          // Clone template into wizard state
          ref.read(planWizardProvider.notifier).loadFromTemplate(template);
          _nextStep();
        },
      ),
    );
  }

  void _showAIQuestionnaire() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.of(sheetContext).size.height,
        child: StepAIQuestionnaire(
          onComplete: () {
            Navigator.pop(sheetContext);
            // AI generation sets currentStep to 2 (workouts config)
            // Animate PageController to the correct step
            final state = ref.read(planWizardProvider);
            _pageController.jumpToPage(state.currentStep);
          },
          onCancel: () {
            Navigator.pop(sheetContext);
          },
        ),
      ),
    );
  }

  Future<void> _createPlan() async {
    final state = ref.read(planWizardProvider);
    final notifier = ref.read(planWizardProvider.notifier);
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Validate all required fields before creating
    final validationError = _validateAllSteps(state);
    if (validationError != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final planId = await notifier.createPlan();

    if (planId != null && mounted) {
      // Invalidate providers to refresh data
      ref.invalidate(allPlansProvider);
      ref.invalidate(planDetailNotifierProvider(planId));

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(state.isEditing ? 'Plano atualizado com sucesso!' : 'Plano criado com sucesso!')),
      );
      // Navigate back to previous screen
      if (mounted) {
        navigator.pop(true);
      }
    } else {
      final error = ref.read(planWizardProvider).error;
      if (mounted && error != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Erro: $error')),
        );
      }
    }
  }

  String? _validateAllSteps(PlanWizardState state) {
    // Validate program name
    if (state.planName.trim().isEmpty) {
      return 'O nome do plano é obrigatório';
    }
    if (state.planName.trim().length < 3) {
      return 'O nome do plano deve ter pelo menos 3 caracteres';
    }
    // Validate workouts
    if (state.workouts.isEmpty) {
      return 'Adicione pelo menos um treino ao plano';
    }
    for (final workout in state.workouts) {
      if (workout.exercises.isEmpty) {
        return 'O treino "${workout.name}" precisa de pelo menos um exercício';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(planWizardProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Show loading indicator while loading plan data for editing or periodization
    final isLoadingPlanData = (widget.isEditing || widget.isPeriodization) && state.planName.isEmpty;
    if (state.isLoading && isLoadingPlanData) {
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
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Carregando plano...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(180),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show error state if loading failed
    if (state.error != null && isLoadingPlanData) {
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    size: 48,
                    color: AppColors.destructive,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar plano',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.arrowLeft, size: 18),
                    label: const Text('Voltar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        _previousStep();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.cardDark : AppColors.card)
                              .withAlpha(isDark ? 150 : 200),
                          border: Border.all(
                            color:
                                isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.arrowLeft,
                          size: 20,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPageTitle(state),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _getStepTitle(state.currentStep, state),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Close button
                    GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        _confirmClose();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.cardDark : AppColors.card)
                              .withAlpha(isDark ? 150 : 200),
                          border: Border.all(
                            color:
                                isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.x,
                          size: 20,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: List.generate(state.totalSteps, (index) {
                  final isActive = index <= state.displayStep;
                  final isCurrent = index == state.displayStep;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < state.totalSteps - 1 ? 4 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: isActive
                            ? (isCurrent
                                ? AppColors.primary
                                : AppColors.primary.withAlpha(150))
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page View with Steps
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  ref.read(planWizardProvider.notifier).goToStep(index);
                },
                children: [
                  StepMethodSelection(onMethodSelected: (method) {
                    ref.read(planWizardProvider.notifier).selectMethod(method);
                    if (method == CreationMethod.template) {
                      _showTemplateBrowser();
                    } else if (method == CreationMethod.ai) {
                      _showAIQuestionnaire();
                    } else {
                      _nextStep();
                    }
                  }),
                  const StepPlanInfo(),
                  const StepSplitSelection(),
                  const StepWorkoutsConfig(),
                  const StepDietConfiguration(),
                  const StepStudentAssignment(),
                  const StepReview(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surface.withAlpha(150)
                : theme.colorScheme.surface.withAlpha(200),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              if (state.currentStep > state.firstStep)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticUtils.lightImpact();
                      _previousStep();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Voltar'),
                  ),
                ),
              if (state.currentStep > state.firstStep) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: state.isLoading || !state.isCurrentStepValid
                      ? null
                      : (state.isLastStep ? _createPlan : _nextStep),
                  icon: state.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          state.isLastStep ? LucideIcons.check : LucideIcons.arrowRight,
                          size: 18,
                        ),
                  label: Text(state.isLastStep ? (state.isEditing ? 'Salvar Alterações' : 'Criar Plano') : 'Continuar'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  String _getPageTitle(PlanWizardState state) {
    if (state.isEditing) {
      return 'Editar Plano';
    }
    if (state.phaseType != null) {
      return state.phaseType!.displayName;
    }
    return 'Criar Plano';
  }

  String _getStepTitle(int step, PlanWizardState state) {
    final displayStep = state.displayStep + 1; // 1-based for display
    final total = state.totalSteps;

    // Step titles (description only, number is dynamic)
    final titles = {
      0: 'Método de Criação',
      1: 'Informações do Plano',
      2: 'Divisão de Treino',
      3: 'Configurar Treinos',
      4: 'Dieta (Opcional)',
      5: 'Atribuir a Aluno',
      6: 'Revisão Final',
    };

    final title = titles[step] ?? '';
    return 'Passo $displayStep de $total - $title';
  }
}
