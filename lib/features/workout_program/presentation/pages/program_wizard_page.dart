import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../providers/program_wizard_provider.dart';
import '../widgets/step_ai_questionnaire.dart';
import '../widgets/step_method_selection.dart';
import '../widgets/step_program_info.dart';
import '../widgets/step_review.dart';
import '../widgets/step_split_selection.dart';
import '../widgets/step_workouts_config.dart';
import '../widgets/template_browser_sheet.dart';

/// Main wizard page for creating workout programs
class ProgramWizardPage extends ConsumerStatefulWidget {
  final String? studentId;
  final String? programId;

  const ProgramWizardPage({super.key, this.studentId, this.programId});

  /// Check if this is an edit operation
  bool get isEditing => programId != null;

  @override
  ConsumerState<ProgramWizardPage> createState() => _ProgramWizardPageState();
}

class _ProgramWizardPageState extends ConsumerState<ProgramWizardPage> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load program for editing if programId is provided
      if (widget.programId != null) {
        ref.read(programWizardProvider.notifier).loadProgramForEdit(widget.programId!);
        // Jump to step 1 (skip method selection in edit mode)
        _pageController.jumpToPage(1);
      }
      // Set student ID if provided
      if (widget.studentId != null) {
        ref.read(programWizardProvider.notifier).setStudentId(widget.studentId);
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
    ref.read(programWizardProvider.notifier).goToStep(step);
  }

  void _nextStep() {
    final state = ref.read(programWizardProvider);
    if (state.currentStep < state.totalSteps - 1) {
      _goToStep(state.currentStep + 1);
    }
  }

  void _previousStep() {
    final state = ref.read(programWizardProvider);
    // In edit mode, step 1 is the first step (skip method selection)
    final firstStep = state.isEditing ? 1 : 0;

    if (state.currentStep > firstStep) {
      _goToStep(state.currentStep - 1);
    } else if (state.isEditing) {
      // In edit mode, just navigate back without confirmation
      Navigator.of(context).pop();
    } else {
      _showExitConfirmation();
    }
  }

  void _showExitConfirmation() {
    final pageContext = context; // Store page context
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair do Wizard?'),
        content: const Text(
            'Todas as informacoes nao salvas serao perdidas. Deseja continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              ref.read(programWizardProvider.notifier).reset();
              pageContext.pop(); // Use page context for navigation
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
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
          ref.read(programWizardProvider.notifier).loadFromTemplate(template);
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
      isDismissible: false,
      enableDrag: false,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.of(sheetContext).size.height * 0.9,
        child: StepAIQuestionnaire(
          onComplete: () {
            Navigator.pop(sheetContext);
            _nextStep();
          },
        ),
      ),
    );
  }

  Future<void> _createProgram() async {
    final notifier = ref.read(programWizardProvider.notifier);
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final programId = await notifier.createProgram();

    if (programId != null && mounted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Programa criado com sucesso!')),
      );
      // Navigate back to previous screen
      if (mounted) {
        navigator.pop(true);
      }
    } else {
      final error = ref.read(programWizardProvider).error;
      if (mounted && error != null) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Erro: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(programWizardProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                        HapticFeedback.lightImpact();
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
                          state.currentStep == 0
                              ? LucideIcons.x
                              : LucideIcons.arrowLeft,
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
                            'Criar Programa',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _getStepTitle(state.currentStep),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
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
                  final isActive = index <= state.currentStep;
                  final isCurrent = index == state.currentStep;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
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
                  ref.read(programWizardProvider.notifier).goToStep(index);
                },
                children: [
                  StepMethodSelection(onMethodSelected: (method) {
                    ref.read(programWizardProvider.notifier).selectMethod(method);
                    if (method == CreationMethod.template) {
                      _showTemplateBrowser();
                    } else if (method == CreationMethod.ai) {
                      _showAIQuestionnaire();
                    } else {
                      _nextStep();
                    }
                  }),
                  const StepProgramInfo(),
                  const StepSplitSelection(),
                  const StepWorkoutsConfig(),
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
              if (state.currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
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
              if (state.currentStep > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : (state.isLastStep ? _createProgram : _nextStep),
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
                  label: Text(state.isLastStep ? 'Criar Programa' : 'Continuar'),
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

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Passo 1 de 5 - Metodo de Criacao';
      case 1:
        return 'Passo 2 de 5 - Informacoes do Programa';
      case 2:
        return 'Passo 3 de 5 - Divisao de Treino';
      case 3:
        return 'Passo 4 de 5 - Configurar Treinos';
      case 4:
        return 'Passo 5 de 5 - Revisao Final';
      default:
        return '';
    }
  }
}
