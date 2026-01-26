import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/domain/entities/entities.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../core/services/organization_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/animated_progress_bar.dart';
import 'student_steps/student_steps.dart';
import 'trainer_steps/trainer_steps.dart';

/// Main onboarding page that routes to trainer or student flow
class OnboardingPage extends ConsumerStatefulWidget {
  final String userType;
  final bool skipOrgCreation;
  final bool editMode;

  const OnboardingPage({
    super.key,
    this.userType = 'student',
    this.skipOrgCreation = false,
    this.editMode = false,
  });

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  bool get _isTrainer => widget.userType == 'trainer' || widget.userType == 'personal';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();

    // Reset to welcome step and load existing data when in edit mode
    if (widget.editMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isTrainer) {
          ref.read(trainerOnboardingProvider.notifier).reset();
        } else {
          ref.read(studentOnboardingProvider.notifier).reset();
        }
        _loadExistingData();
      });
    }
  }

  /// Load existing profile data and populate the onboarding providers
  Future<void> _loadExistingData() async {
    try {
      final userService = UserService();
      final profile = await userService.getProfile();
      debugPrint('Loaded profile data: $profile');

      if (_isTrainer) {
        final notifier = ref.read(trainerOnboardingProvider.notifier);

        // Parse CREF if exists (format: "012345-G/SP")
        final cref = profile['cref'] as String?;
        if (cref != null && cref.isNotEmpty) {
          final parts = cref.split('/');
          if (parts.length == 2) {
            final crefNumber = parts[0].replaceAll(RegExp(r'-[A-Z]$'), '');
            final stateStr = parts[1];
            final crefState = BrazilState.values.firstWhere(
              (s) => s.name == stateStr,
              orElse: () => BrazilState.SP,
            );
            notifier.setCrefData(crefNumber: crefNumber, crefState: crefState);
          }
        }

        // Load specialties
        final specialties = profile['specialties'] as List<dynamic>?;
        final yearsExp = profile['years_of_experience'] as int?;
        final bio = profile['bio'] as String?;
        notifier.setProfileData(
          specialties: specialties?.map((e) => e.toString()).toList(),
          yearsOfExperience: yearsExp,
          bio: bio,
        );
      } else {
        final notifier = ref.read(studentOnboardingProvider.notifier);

        // Load fitness goal
        final fitnessGoalStr = profile['fitness_goal'] as String?;
        if (fitnessGoalStr != null) {
          final fitnessGoal = FitnessGoal.values.firstWhere(
            (g) => g.name == fitnessGoalStr,
            orElse: () => FitnessGoal.maintainHealth,
          );
          notifier.setFitnessGoal(
            fitnessGoal,
            otherGoal: profile['fitness_goal_other'] as String?,
          );
        }

        // Load experience level
        final expLevelStr = profile['experience_level'] as String?;
        if (expLevelStr != null) {
          final expLevel = ExperienceLevel.values.firstWhere(
            (l) => l.name == expLevelStr,
            orElse: () => ExperienceLevel.beginner,
          );
          notifier.setExperienceLevel(expLevel);
        }

        // Load physical data
        final weight = profile['weight_kg'] as num?;
        final height = profile['height_cm'] as num?;
        final age = profile['age'] as int?;
        if (weight != null || height != null || age != null) {
          notifier.setPhysicalData(
            weight: weight?.toDouble(),
            height: height?.toDouble(),
            age: age,
          );
        }

        // Load weekly frequency
        final weeklyFreq = profile['weekly_frequency'] as int?;
        if (weeklyFreq != null) {
          notifier.setWeeklyFrequency(weeklyFreq);
        }

        // Load injuries
        final injuries = profile['injuries'] as List<dynamic>?;
        final injuriesOther = profile['injuries_other'] as String?;
        if (injuries != null || injuriesOther != null) {
          notifier.setInjuries(
            injuries?.map((e) => e.toString()).toList() ?? [],
            otherInjuries: injuriesOther,
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading existing data: $e');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _skip() async {
    HapticUtils.lightImpact();

    // If in edit mode, just go back
    if (widget.editMode) {
      if (mounted) context.pop();
      return;
    }

    if (_isTrainer) {
      ref.read(trainerOnboardingProvider.notifier).skip();
      // Create organization for trainer even on skip
      await _complete();
    } else {
      ref.read(studentOnboardingProvider.notifier).skip();
      context.go(RouteNames.orgSelector);
    }
  }

  bool _isCreatingOrg = false;
  bool _isSaving = false;

  /// Save onboarding data to the backend API
  Future<bool> _saveOnboardingData() async {
    if (_isSaving) return false;
    setState(() => _isSaving = true);

    try {
      final userService = UserService();
      final currentUser = ref.read(currentUserProvider);
      final bool completed;

      if (_isTrainer) {
        final state = ref.read(trainerOnboardingProvider);
        completed = !state.skipped;
        // Format CREF: combine number + state (e.g., "012345-G/SP")
        String? cref;
        if (state.crefNumber != null && state.crefState != null) {
          cref = '${state.crefNumber}-G/${state.crefState!.name}';
        }
        await userService.updateProfile(
          cref: cref,
          specialties: state.specialties,
          yearsOfExperience: state.yearsOfExperience,
          bio: state.bio,
          onboardingCompleted: completed,
        );
      } else {
        final state = ref.read(studentOnboardingProvider);
        completed = !state.skipped;
        debugPrint('Saving student onboarding data:');
        debugPrint('  fitnessGoal: ${state.fitnessGoal?.name}');
        debugPrint('  experienceLevel: ${state.experienceLevel?.name}');
        debugPrint('  weight: ${state.weight}');
        debugPrint('  height: ${state.height}');
        debugPrint('  age: ${state.age}');
        debugPrint('  weeklyFrequency: ${state.weeklyFrequency}');
        debugPrint('  injuries: ${state.injuries}');
        await userService.updateProfile(
          fitnessGoal: state.fitnessGoal?.name,
          fitnessGoalOther: state.otherGoal,
          experienceLevel: state.experienceLevel?.name,
          weightKg: state.weight,
          heightCm: state.height,
          age: state.age,
          weeklyFrequency: state.weeklyFrequency,
          injuries: state.injuries,
          injuriesOther: state.otherInjuries,
          onboardingCompleted: completed,
        );
      }

      // Update local user state with onboardingCompleted flag
      if (currentUser != null) {
        ref.read(currentUserProvider.notifier).state = currentUser.copyWith(
          onboardingCompleted: completed,
        );
        debugPrint('Updated currentUserProvider with onboardingCompleted: $completed');
      }

      return true;
    } catch (e) {
      debugPrint('Error saving onboarding data: $e');
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _complete() async {
    if (_isCreatingOrg) return;

    HapticUtils.mediumImpact();

    // Save onboarding data to API
    await _saveOnboardingData();

    // If in edit mode, just go back to previous screen
    if (widget.editMode) {
      if (mounted) {
        context.pop();
      }
      return;
    }

    // For trainers, create organization automatically (unless already created)
    if (_isTrainer) {
      // If org was already created (e.g., from create org page), just navigate
      if (widget.skipOrgCreation) {
        if (mounted) {
          context.go(RouteNames.trainerHome);
        }
        return;
      }

      setState(() => _isCreatingOrg = true);

      try {
        final user = ref.read(currentUserProvider);
        if (user == null) {
          if (mounted) context.go(RouteNames.orgSelector);
          return;
        }

        // Create organization with user's name
        final orgService = OrganizationService();
        final orgData = await orgService.createOrganization(
          name: 'Personal ${user.name}',
          type: 'personal',
        );

        // The API returns the organization with membership
        // Parse and set as active context
        if (orgData['membership'] != null) {
          final membership = OrganizationMembership.fromJson(
            orgData['membership'] as Map<String, dynamic>,
          );
          ref.read(activeContextProvider.notifier).setContext(
            ActiveContext(membership: membership),
          );
        }

        // Refresh memberships
        ref.invalidate(membershipsProvider);

        if (mounted) {
          // Go directly to trainer home
          context.go(RouteNames.trainerHome);
        }
      } catch (e) {
        debugPrint('Error creating organization: $e');
        // Fallback to org selector on error
        if (mounted) context.go(RouteNames.orgSelector);
      } finally {
        if (mounted) setState(() => _isCreatingOrg = false);
      }
    } else {
      // Students go to org selector to join a trainer
      context.go(RouteNames.orgSelector);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isTrainer) {
      return _buildTrainerOnboarding(context);
    } else {
      return _buildStudentOnboarding(context);
    }
  }

  Widget _buildTrainerOnboarding(BuildContext context) {
    final state = ref.watch(trainerOnboardingProvider);
    final notifier = ref.read(trainerOnboardingProvider.notifier);

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildTrainerStep(context, state, notifier),
      ),
    );
  }

  Widget _buildStudentOnboarding(BuildContext context) {
    final state = ref.watch(studentOnboardingProvider);
    final notifier = ref.read(studentOnboardingProvider.notifier);

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildStudentStep(context, state, notifier),
      ),
    );
  }

  Widget _buildTrainerStep(
    BuildContext context,
    TrainerOnboardingState state,
    TrainerOnboardingNotifier notifier,
  ) {
    // Calculate progress based on current step
    final progress = state.stepIndex / state.totalSteps;

    switch (state.currentStep) {
      case TrainerOnboardingStep.welcome:
        return TrainerWelcomeStep(
          progress: progress,
          onNext: () => notifier.nextStep(),
          onSkip: _skip,
        );
      case TrainerOnboardingStep.professionalProfile:
        return TrainerProfileStep(
          progress: progress,
          onNext: () => notifier.nextStep(),
          onBack: () => notifier.previousStep(),
          onSkip: _skip,
        );
      case TrainerOnboardingStep.inviteStudent:
        return TrainerInviteStep(
          progress: progress,
          onNext: () => notifier.nextStep(),
          onBack: () => notifier.previousStep(),
          onSkip: _skip,
        );
      case TrainerOnboardingStep.createPlan:
        return TrainerCreatePlanStep(
          progress: progress,
          onNext: () => notifier.nextStep(),
          onBack: () => notifier.previousStep(),
          onSkip: _skip,
        );
      case TrainerOnboardingStep.exploreTemplates:
        return TrainerTemplatesStep(
          progress: progress,
          onNext: () => notifier.nextStep(),
          onBack: () => notifier.previousStep(),
          onSkip: _skip,
        );
      case TrainerOnboardingStep.complete:
        return TrainerCompleteStep(
          onComplete: _complete,
          isLoading: _isCreatingOrg,
        );
    }
  }

  Widget _buildStudentStep(
    BuildContext context,
    StudentOnboardingState state,
    StudentOnboardingNotifier notifier,
  ) {
    switch (state.currentStep) {
      case StudentOnboardingStep.welcome:
        return StudentWelcomeStep(
          onNext: () => notifier.nextStep(),
          onSkip: _skip,
        );
      case StudentOnboardingStep.fitnessGoal:
        return StudentGoalStep(
          initialGoal: state.fitnessGoal,
          initialOtherGoal: state.otherGoal,
          onContinue: (goal, other) {
            notifier.setFitnessGoal(goal, otherGoal: other);
            notifier.nextStep();
          },
          onBack: () => notifier.previousStep(),
          onSkip: _skip,
          progress: 0.17,
        );
      case StudentOnboardingStep.experienceLevel:
        return StudentExperienceStep(
          initialLevel: state.experienceLevel,
          onContinue: (level) {
            notifier.setExperienceLevel(level);
            notifier.nextStep();
          },
          onBack: () => notifier.previousStep(),
          onSkip: _skip,
          progress: 0.33,
        );
      case StudentOnboardingStep.physicalData:
        return StudentPhysicalDataStep(
          initialWeight: state.weight,
          initialHeight: state.height,
          initialAge: state.age,
          onContinue: (weight, height, age) {
            notifier.setPhysicalData(weight: weight, height: height, age: age);
            notifier.nextStep();
          },
          onBack: () => notifier.previousStep(),
          onSkip: _skip,
          progress: 0.5,
        );
      case StudentOnboardingStep.weeklyFrequency:
        return StudentFrequencyStep(
          initialFrequency: state.weeklyFrequency,
          onContinue: (frequency) {
            notifier.setWeeklyFrequency(frequency);
            notifier.nextStep();
          },
          onBack: () => notifier.previousStep(),
          onSkip: _skip,
          progress: 0.67,
        );
      case StudentOnboardingStep.injuries:
        return StudentInjuriesStep(
          initialInjuries: state.injuries,
          onContinue: (injuries) {
            notifier.setInjuries(injuries);
            notifier.nextStep();
          },
          onBack: () => notifier.previousStep(),
          onSkip: _skip,
          progress: 0.83,
        );
      case StudentOnboardingStep.complete:
        return StudentCompleteStep(
          state: state,
          onComplete: _complete,
          isLoading: _isLoading,
        );
    }
  }
}

// ============ TRAINER STEPS ============

class _TrainerWelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TrainerWelcomeStep({
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _OnboardingStepScaffold(
      progress: 0.0,
      onSkip: onSkip,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.dumbbell,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Bem-vindo ao MyFit!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Vamos configurar sua conta de Personal Trainer e ajudá-lo a começar com o pé direito.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),
          _buildFeatureItem(
            context,
            LucideIcons.users,
            'Gerencie seus alunos',
            'Acompanhe o progresso de cada um',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            LucideIcons.clipboardList,
            'Crie planos personalizados',
            'Prescreva treinos sob medida',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            context,
            LucideIcons.messageSquare,
            'Comunique-se facilmente',
            'Chat integrado com seus alunos',
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Começar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainerProfessionalProfileStep extends StatefulWidget {
  final TrainerOnboardingState state;
  final Function(String?, BrazilState?, List<String>, int?, String?) onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const _TrainerProfessionalProfileStep({
    required this.state,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<_TrainerProfessionalProfileStep> createState() =>
      _TrainerProfessionalProfileStepState();
}

class _TrainerProfessionalProfileStepState
    extends State<_TrainerProfessionalProfileStep> {
  final _crefController = TextEditingController();
  final _bioController = TextEditingController();
  BrazilState? _selectedState;
  int _yearsOfExperience = 5;
  final Set<String> _selectedSpecialties = {};

  static const _specialties = [
    'Musculacao',
    'Funcional',
    'HIIT',
    'Crossfit',
    'Pilates',
    'Yoga',
    'Corrida',
    'Natacao',
    'Artes Marciais',
    'Reabilitacao',
    'Esportes',
    'Idosos',
  ];

  @override
  void initState() {
    super.initState();
    _crefController.text = widget.state.crefNumber ?? '';
    _bioController.text = widget.state.bio ?? '';
    _selectedState = widget.state.crefState;
    _yearsOfExperience = widget.state.yearsOfExperience ?? 5;
    _selectedSpecialties.addAll(widget.state.specialties);
  }

  @override
  void dispose() {
    _crefController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _OnboardingStepScaffold(
      progress: 1 / 5,
      onSkip: widget.onSkip,
      onBack: widget.onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perfil Profissional',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Suas credenciais ajudam a construir confianca com seus alunos.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 32),

            // CREF Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.badgeCheck,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Registro CREF',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Opcional',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // CREF Number
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _crefController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [_CrefInputFormatter()],
                          decoration: InputDecoration(
                            labelText: 'Número CREF',
                            hintText: '012345-G',
                            filled: true,
                            fillColor: isDark ? AppColors.mutedDark : AppColors.muted,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // State dropdown
                      Expanded(
                        child: DropdownButtonFormField<BrazilState>(
                          value: _selectedState,
                          decoration: InputDecoration(
                            labelText: 'UF',
                            filled: true,
                            fillColor: isDark ? AppColors.mutedDark : AppColors.muted,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: BrazilState.values.map((state) {
                            return DropdownMenuItem(
                              value: state,
                              child: Text(state.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedState = value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Specialties
            Text(
              'Especialidades',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _specialties.map((specialty) {
                final isSelected = _selectedSpecialties.contains(specialty);
                return GestureDetector(
                  onTap: () {
                    HapticUtils.selectionClick();
                    setState(() {
                      if (isSelected) {
                        _selectedSpecialties.remove(specialty);
                      } else {
                        _selectedSpecialties.add(specialty);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withAlpha(20)
                          : (isDark ? AppColors.cardDark : AppColors.card),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.borderDark : AppColors.border),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      specialty,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Years of experience
            Text(
              'Anos de experiencia: $_yearsOfExperience',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: isDark ? AppColors.mutedDark : AppColors.muted,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withAlpha(30),
              ),
              child: Slider(
                value: _yearsOfExperience.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                label: '$_yearsOfExperience anos',
                onChanged: (value) {
                  HapticUtils.selectionClick();
                  setState(() => _yearsOfExperience = value.toInt());
                },
              ),
            ),

            const SizedBox(height: 24),

            // Bio
            Text(
              'Sobre voce',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: 'Conte um pouco sobre sua experiencia e metodologia...',
                filled: true,
                fillColor: isDark ? AppColors.cardDark : AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final cref = _crefController.text.trim();
                  widget.onNext(
                    cref.isNotEmpty ? cref : null,
                    _selectedState,
                    _selectedSpecialties.toList(),
                    _yearsOfExperience,
                    _bioController.text.trim().isNotEmpty
                        ? _bioController.text.trim()
                        : null,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainerInviteStep extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const _TrainerInviteStep({
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  String _getOrgInviteLink(WidgetRef ref) {
    final orgId = ref.read(activeContextProvider)?.organization.id;
    if (orgId == null) {
      return 'https://myfitplatform.com/signup';
    }
    return 'https://myfitplatform.com/join/$orgId';
  }

  String _getInviteMessage(WidgetRef ref) {
    final orgName = ref.read(activeContextProvider)?.organization.name ?? 'MyFit';
    final link = _getOrgInviteLink(ref);
    return 'Olá! Estou te convidando para treinar comigo no $orgName. '
        'Clique no link para começar: $link';
  }

  Future<void> _copyInviteLink(BuildContext context, WidgetRef ref) async {
    final link = _getOrgInviteLink(ref);
    await Clipboard.setData(ClipboardData(text: link));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(LucideIcons.copy, color: Colors.white, size: 18),
            SizedBox(width: 12),
            Text('Link copiado!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showQRCode(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final link = _getOrgInviteLink(ref);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'QR Code de Convite',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Peça para seu aluno escanear',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: link,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareButton(
                  context,
                  icon: LucideIcons.messageCircle,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final message = _getInviteMessage(ref);
                    final whatsappUrl = Uri.parse(
                      'https://wa.me/?text=${Uri.encodeComponent(message)}',
                    );
                    if (await canLaunchUrl(whatsappUrl)) {
                      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                _buildShareButton(
                  context,
                  icon: LucideIcons.copy,
                  label: 'Copiar',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(ctx);
                    _copyInviteLink(context, ref);
                  },
                ),
                _buildShareButton(
                  context,
                  icon: LucideIcons.share2,
                  label: 'Outros',
                  color: AppColors.mutedForeground,
                  onTap: () async {
                    Navigator.pop(ctx);
                    final message = _getInviteMessage(ref);
                    await Share.share(message, subject: 'Convite MyFit');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark
                  ? AppColors.foregroundDark
                  : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _OnboardingStepScaffold(
      progress: 0.25,
      onSkip: onSkip,
      onBack: onBack,
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.userPlus,
              size: 48,
              color: AppColors.info,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Convide seu primeiro aluno',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Compartilhe um link de convite ou código QR para que seus alunos se conectem a você.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  _buildOptionTile(
                    context,
                    LucideIcons.link,
                    'Copiar link de convite',
                    'Envie via WhatsApp, email, etc.',
                    onTap: () => _copyInviteLink(context, ref),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionTile(
                    context,
                    LucideIcons.qrCode,
                    'Mostrar QR Code',
                    'Seu aluno escaneia e se conecta',
                    onTap: () => _showQRCode(context, ref),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onNext,
                  child: Text(
                    'Fazer isso depois',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        HapticUtils.lightImpact();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.mutedDark : AppColors.muted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainerCreatePlanStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const _TrainerCreatePlanStep({
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _OnboardingStepScaffold(
      progress: 0.5,
      onSkip: onSkip,
      onBack: onBack,
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.clipboardList,
              size: 48,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Crie seu primeiro plano',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Monte um plano de treino personalizado para seus alunos com nosso assistente inteligente.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildStepItem(context, '1', 'Defina o objetivo do plano'),
                const SizedBox(height: 12),
                _buildStepItem(context, '2', 'Escolha os treinos da semana'),
                const SizedBox(height: 12),
                _buildStepItem(context, '3', 'Adicione exercícios'),
                const SizedBox(height: 12),
                _buildStepItem(context, '4', 'Prescreva para seus alunos'),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onNext,
                  child: Text(
                    'Fazer isso depois',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(BuildContext context, String number, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.foregroundDark
                  : AppColors.foreground,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrainerExploreStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const _TrainerExploreStep({
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _OnboardingStepScaffold(
      progress: 0.75,
      onSkip: onSkip,
      onBack: onBack,
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.layoutTemplate,
              size: 48,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Explore os templates',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Use nossos templates prontos como base para criar planos de treino mais rapidamente.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildTemplateChip(context, 'Hipertrofia'),
                _buildTemplateChip(context, 'Emagrecimento'),
                _buildTemplateChip(context, 'Força'),
                _buildTemplateChip(context, 'Funcional'),
                _buildTemplateChip(context, 'Iniciante'),
                _buildTemplateChip(context, 'Avançado'),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Finalizar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ============ STUDENT STEPS ============

class _StudentWelcomeStep extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _StudentWelcomeStep({
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _OnboardingStepScaffold(
      progress: 0.0,
      onSkip: onSkip,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.trophy,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Vamos personalizar\nsua experiência!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Responda algumas perguntas rápidas para que possamos criar a melhor experiência de treino para você.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Começar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentGoalStep extends StatefulWidget {
  final StudentOnboardingState state;
  final Function(FitnessGoal, String?) onSelect;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const _StudentGoalStep({
    required this.state,
    required this.onSelect,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<_StudentGoalStep> createState() => _StudentGoalStepState();
}

class _StudentGoalStepState extends State<_StudentGoalStep> {
  FitnessGoal? _selectedGoal;
  final _otherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.state.fitnessGoal;
    _otherController.text = widget.state.otherGoal ?? '';
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final goals = [
      (FitnessGoal.loseWeight, 'Perder peso', LucideIcons.flame),
      (FitnessGoal.gainMuscle, 'Ganhar massa muscular', LucideIcons.dumbbell),
      (FitnessGoal.improveEndurance, 'Melhorar condicionamento', LucideIcons.activity),
      (FitnessGoal.maintainHealth, 'Manter a saúde', LucideIcons.heart),
      (FitnessGoal.flexibility, 'Flexibilidade', LucideIcons.move),
      (FitnessGoal.other, 'Outro objetivo', LucideIcons.target),
    ];

    return _OnboardingStepScaffold(
      progress: 1 / 6,
      onSkip: widget.onSkip,
      onBack: widget.onBack,
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Qual é seu principal objetivo?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Isso nos ajuda a personalizar suas recomendações.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final (goal, label, icon) = goals[index];
                final isSelected = _selectedGoal == goal;

                return GestureDetector(
                  onTap: () {
                    HapticUtils.selectionClick();
                    setState(() => _selectedGoal = goal);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withAlpha(15)
                          : (isDark ? AppColors.cardDark : AppColors.card),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.borderDark : AppColors.border),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 24,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foreground),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            LucideIcons.check,
                            size: 20,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedGoal == FitnessGoal.other)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: TextField(
                controller: _otherController,
                decoration: InputDecoration(
                  hintText: 'Descreva seu objetivo...',
                  filled: true,
                  fillColor: isDark ? AppColors.mutedDark : AppColors.muted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedGoal != null
                    ? () => widget.onSelect(
                          _selectedGoal!,
                          _selectedGoal == FitnessGoal.other
                              ? _otherController.text
                              : null,
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withAlpha(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentExperienceStep extends StatefulWidget {
  final StudentOnboardingState state;
  final Function(ExperienceLevel) onSelect;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const _StudentExperienceStep({
    required this.state,
    required this.onSelect,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<_StudentExperienceStep> createState() => _StudentExperienceStepState();
}

class _StudentExperienceStepState extends State<_StudentExperienceStep> {
  ExperienceLevel? _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.state.experienceLevel;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final levels = [
      (
        ExperienceLevel.beginner,
        'Iniciante',
        'Estou começando ou voltando após muito tempo',
        LucideIcons.sprout,
      ),
      (
        ExperienceLevel.intermediate,
        'Intermediário',
        'Treino há alguns meses regularmente',
        LucideIcons.trendingUp,
      ),
      (
        ExperienceLevel.advanced,
        'Avançado',
        'Treino há anos e conheço bem os exercícios',
        LucideIcons.award,
      ),
    ];

    return _OnboardingStepScaffold(
      progress: 2 / 6,
      onSkip: widget.onSkip,
      onBack: widget.onBack,
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Qual seu nível de experiência?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Seja honesto - isso nos ajuda a calibrar a intensidade.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: levels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final (level, title, subtitle, icon) = levels[index];
                final isSelected = _selectedLevel == level;

                return GestureDetector(
                  onTap: () {
                    HapticUtils.selectionClick();
                    setState(() => _selectedLevel = level);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withAlpha(15)
                          : (isDark ? AppColors.cardDark : AppColors.card),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.borderDark : AppColors.border),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withAlpha(25)
                                : (isDark ? AppColors.mutedDark : AppColors.muted),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            icon,
                            size: 28,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foreground),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
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
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    _selectedLevel != null ? () => widget.onSelect(_selectedLevel!) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withAlpha(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentPhysicalDataStep extends StatefulWidget {
  final StudentOnboardingState state;
  final Function(double?, double?, int?) onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const _StudentPhysicalDataStep({
    required this.state,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<_StudentPhysicalDataStep> createState() => _StudentPhysicalDataStepState();
}

class _StudentPhysicalDataStepState extends State<_StudentPhysicalDataStep> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.state.weight != null) {
      _weightController.text = widget.state.weight!.toStringAsFixed(1);
    }
    if (widget.state.height != null) {
      _heightController.text = widget.state.height!.toStringAsFixed(0);
    }
    if (widget.state.age != null) {
      _ageController.text = widget.state.age!.toString();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _OnboardingStepScaffold(
      progress: 3 / 6,
      onSkip: widget.onSkip,
      onBack: widget.onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dados físicos',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Opcional, mas ajuda a personalizar seus treinos.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 32),
            _buildInputField(
              context,
              controller: _weightController,
              label: 'Peso (kg)',
              icon: LucideIcons.scale,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            _buildInputField(
              context,
              controller: _heightController,
              label: 'Altura (cm)',
              icon: LucideIcons.ruler,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              context,
              controller: _ageController,
              label: 'Idade',
              icon: LucideIcons.calendar,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final weight = double.tryParse(_weightController.text);
                  final height = double.tryParse(_heightController.text);
                  final age = int.tryParse(_ageController.text);
                  widget.onNext(weight, height, age);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: isDark ? AppColors.cardDark : AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

class _StudentFrequencyStep extends StatefulWidget {
  final StudentOnboardingState state;
  final Function(int) onSelect;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const _StudentFrequencyStep({
    required this.state,
    required this.onSelect,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<_StudentFrequencyStep> createState() => _StudentFrequencyStepState();
}

class _StudentFrequencyStepState extends State<_StudentFrequencyStep> {
  int? _selectedFrequency;

  @override
  void initState() {
    super.initState();
    _selectedFrequency = widget.state.weeklyFrequency;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _OnboardingStepScaffold(
      progress: 4 / 6,
      onSkip: widget.onSkip,
      onBack: widget.onBack,
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantas vezes por semana\nvocê pretende treinar?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Seja realista com sua disponibilidade.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
              children: List.generate(7, (index) {
                final frequency = index + 1;
                final isSelected = _selectedFrequency == frequency;

                return GestureDetector(
                  onTap: () {
                    HapticUtils.selectionClick();
                    setState(() => _selectedFrequency = frequency);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.cardDark : AppColors.card),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.borderDark : AppColors.border),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$frequency',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground),
                          ),
                        ),
                        Text(
                          frequency == 1 ? 'vez' : 'vezes',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? Colors.white.withAlpha(200)
                                : (isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForeground),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedFrequency != null
                    ? () => widget.onSelect(_selectedFrequency!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withAlpha(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentInjuriesStep extends StatefulWidget {
  final StudentOnboardingState state;
  final Function(List<String>, String?) onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  const _StudentInjuriesStep({
    required this.state,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  @override
  State<_StudentInjuriesStep> createState() => _StudentInjuriesStepState();
}

class _StudentInjuriesStepState extends State<_StudentInjuriesStep> {
  final Set<String> _selectedInjuries = {};
  final _otherController = TextEditingController();

  final _commonInjuries = [
    'Ombro',
    'Joelho',
    'Lombar',
    'Cervical',
    'Tornozelo',
    'Punho',
    'Cotovelo',
    'Quadril',
  ];

  @override
  void initState() {
    super.initState();
    _selectedInjuries.addAll(widget.state.injuries);
    _otherController.text = widget.state.otherInjuries ?? '';
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _OnboardingStepScaffold(
      progress: 5 / 6,
      onSkip: widget.onSkip,
      onBack: widget.onBack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem alguma lesão ou\nrestrição de movimento?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecione todas que se aplicam ou deixe em branco.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _commonInjuries.map((injury) {
                final isSelected = _selectedInjuries.contains(injury);

                return GestureDetector(
                  onTap: () {
                    HapticUtils.selectionClick();
                    setState(() {
                      if (isSelected) {
                        _selectedInjuries.remove(injury);
                      } else {
                        _selectedInjuries.add(injury);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.warning.withAlpha(20)
                          : (isDark ? AppColors.cardDark : AppColors.card),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.warning
                            : (isDark ? AppColors.borderDark : AppColors.border),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          Icon(
                            LucideIcons.check,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          injury,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.warning
                                : (isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otherController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Outras lesões ou restrições...',
                filled: true,
                fillColor: isDark ? AppColors.cardDark : AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  widget.onNext(
                    _selectedInjuries.toList(),
                    _otherController.text.isNotEmpty
                        ? _otherController.text
                        : null,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ SHARED WIDGETS ============

class _CompleteStep extends StatelessWidget {
  final bool isTrainer;
  final VoidCallback onComplete;
  final bool isLoading;

  const _CompleteStep({
    required this.isTrainer,
    required this.onComplete,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.background,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.checkCircle2,
                size: 72,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Tudo pronto!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                isTrainer
                    ? 'Sua conta está configurada. Agora você pode começar a gerenciar seus alunos e criar planos de treino.'
                    : 'Seu perfil está configurado. Agora você pode começar sua jornada de treinos!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withAlpha(150),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isTrainer ? 'Ir para o Dashboard' : 'Começar a treinar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStepScaffold extends StatelessWidget {
  final double progress;
  final VoidCallback onSkip;
  final VoidCallback? onBack;
  final Widget child;

  const _OnboardingStepScaffold({
    required this.progress,
    required this.onSkip,
    this.onBack,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              // Header with progress and skip
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                  if (onBack != null)
                    GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        onBack!();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.card,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                isDark ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                        child: Icon(
                          LucideIcons.arrowLeft,
                          size: 20,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: isDark
                            ? AppColors.mutedDark
                            : AppColors.muted,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: onSkip,
                    child: Text(
                      'Pular',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
              // Content
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// CREF mask formatter: 000000-X (6 digits + dash + G/B/L/F)
/// G = Graduado, B = Bacharel, L = Licenciado, F = Formação antiga
class _CrefInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.toUpperCase();

    // Remove any non-alphanumeric characters except dash
    final cleaned = text.replaceAll(RegExp(r'[^0-9GBLF]'), '');

    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length && i < 7; i++) {
      final char = cleaned[i];

      if (i < 6) {
        // First 6 characters must be digits
        if (RegExp(r'[0-9]').hasMatch(char)) {
          buffer.write(char);
        }
      } else if (i == 6) {
        // 7th character must be G, B, L, or F only
        if (RegExp(r'[GBLF]').hasMatch(char)) {
          buffer.write('-$char');
        }
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
