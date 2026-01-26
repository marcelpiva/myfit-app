import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/animated_progress_bar.dart';
import '../../widgets/experience_slider.dart';
import '../../widgets/onboarding_step_card.dart';
import '../../widgets/specialty_chip.dart';

/// Redesigned Professional Profile step with expandable sections
class TrainerProfileStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final double progress;

  const TrainerProfileStep({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    this.progress = 0.2,
  });

  @override
  ConsumerState<TrainerProfileStep> createState() => _TrainerProfileStepState();
}

class _TrainerProfileStepState extends ConsumerState<TrainerProfileStep> {
  final _crefController = TextEditingController();
  final _bioController = TextEditingController();
  final _bioFocusNode = FocusNode();
  bool _hasCref = false;
  BrazilState? _selectedState;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final state = ref.read(trainerOnboardingProvider);
    _crefController.text = state.crefNumber ?? '';
    _bioController.text = state.bio ?? '';
    _hasCref = state.hasCrefToggle;
    _selectedState = state.crefState;
  }

  @override
  void dispose() {
    _crefController.dispose();
    _bioController.dispose();
    _bioFocusNode.dispose();
    super.dispose();
  }

  bool get _canContinue {
    final state = ref.watch(trainerOnboardingProvider);
    // Can continue if has at least one specialty
    if (state.specialties.isEmpty) return false;
    // If CREF toggle is on, must have valid CREF
    if (_hasCref) {
      if (_crefController.text.isEmpty || _selectedState == null) return false;
    }
    return true;
  }

  void _handleNext() {
    if (!_canContinue) return;

    final notifier = ref.read(trainerOnboardingProvider.notifier);

    // Save CREF data if enabled
    if (_hasCref && _selectedState != null) {
      notifier.setCrefData(
        crefNumber: _crefController.text,
        crefState: _selectedState!,
      );
    } else {
      notifier.toggleCref(false);
    }

    // Save bio
    notifier.setBio(_bioController.text);

    HapticUtils.mediumImpact();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(trainerOnboardingProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              // Header with progress
              _buildHeader(context, isDark),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Step header
                      OnboardingStepHeader(
                        icon: LucideIcons.userCog,
                        iconColor: AppColors.primary,
                        title: 'Perfil Profissional',
                        subtitle: 'Configure suas informações de personal trainer',
                      ),

                      // CREF Section
                      _buildCrefSection(context, isDark, state),
                      const SizedBox(height: 24),

                      // Specialties Section
                      _buildSpecialtiesSection(context, isDark, state),
                      const SizedBox(height: 24),

                      // Experience Section
                      _buildExperienceSection(context, isDark, state),
                      const SizedBox(height: 24),

                      // Bio Section
                      _buildBioSection(context, isDark),

                      const SizedBox(height: 100), // Space for bottom actions
                    ],
                  ),
                ),
              ),
              // Bottom actions
              _buildBottomActions(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              widget.onBack();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SimpleProgressIndicator(progress: widget.progress),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              widget.onSkip();
            },
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
    );
  }

  Widget _buildCrefSection(
    BuildContext context,
    bool isDark,
    TrainerOnboardingState state,
  ) {
    return _ExpandableSection(
      title: 'Registro CREF',
      subtitle: 'Opcional - valida sua credencial',
      icon: LucideIcons.badgeCheck,
      iconColor: AppColors.success,
      isDark: isDark,
      trailing: Switch.adaptive(
        value: _hasCref,
        onChanged: (value) {
          HapticUtils.selectionClick();
          setState(() => _hasCref = value);
          ref.read(trainerOnboardingProvider.notifier).toggleCref(value);
        },
        activeColor: AppColors.success,
      ),
      isExpanded: _hasCref,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // CREF Number
          TextFormField(
            controller: _crefController,
            decoration: InputDecoration(
              labelText: 'Número do CREF',
              hintText: '012345',
              prefixIcon: const Icon(LucideIcons.hash),
              suffixIcon: state.isCrefValid
                  ? Icon(LucideIcons.checkCircle2, color: AppColors.success)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              errorText: state.crefValidationError,
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            onChanged: (value) {
              ref.read(trainerOnboardingProvider.notifier).setCrefNumber(value);
            },
          ),
          const SizedBox(height: 16),
          // State dropdown
          DropdownButtonFormField<BrazilState>(
            value: _selectedState,
            decoration: InputDecoration(
              labelText: 'Estado',
              prefixIcon: const Icon(LucideIcons.mapPin),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: BrazilState.values.map((state) {
              return DropdownMenuItem(
                value: state,
                child: Text(state.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                HapticUtils.selectionClick();
                setState(() => _selectedState = value);
                ref.read(trainerOnboardingProvider.notifier).setCrefState(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtiesSection(
    BuildContext context,
    bool isDark,
    TrainerOnboardingState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingSectionTitle(
          title: 'Especialidades',
          badge: 'Obrigatório',
          badgeColor: AppColors.warning,
        ),
        const SizedBox(height: 4),
        Text(
          'Selecione até 5 áreas de atuação',
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        SpecialtySelector(
          selected: state.specialties,
          onChanged: (specialties) {
            ref.read(trainerOnboardingProvider.notifier).setProfileData(
              specialties: specialties,
            );
          },
          maxSelection: 5,
          showCounter: true,
        ),
      ],
    );
  }

  Widget _buildExperienceSection(
    BuildContext context,
    bool isDark,
    TrainerOnboardingState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OnboardingSectionTitle(
          title: 'Anos de Experiência',
        ),
        const SizedBox(height: 12),
        ExperienceSlider(
          value: state.yearsOfExperience ?? 5,
          onChanged: (years) {
            ref.read(trainerOnboardingProvider.notifier).setYearsOfExperience(years);
          },
          min: 1,
          max: 30,
        ),
      ],
    );
  }

  Widget _buildBioSection(BuildContext context, bool isDark) {
    final maxChars = 280;
    final currentLength = _bioController.text.length;
    final isNearLimit = currentLength > maxChars * 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            OnboardingSectionTitle(title: 'Bio'),
            const Spacer(),
            Text(
              '$currentLength/$maxChars',
              style: TextStyle(
                fontSize: 12,
                color: isNearLimit
                    ? AppColors.warning
                    : (isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground),
                fontWeight: isNearLimit ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Uma breve descrição sobre você e seu trabalho',
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _bioController,
          focusNode: _bioFocusNode,
          maxLines: 4,
          maxLength: maxChars,
          decoration: InputDecoration(
            hintText: 'Ex: Personal trainer especializado em hipertrofia e emagrecimento, com foco em resultados sustentáveis...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            counterText: '',
          ),
          onChanged: (value) {
            setState(() {}); // Update character count
          },
        ),
        const SizedBox(height: 8),
        // AI suggestion button (placeholder for now)
        GestureDetector(
          onTap: () {
            HapticUtils.lightImpact();
            // TODO: Implement AI bio generation
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(isDark ? 20 : 15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.sparkles,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Gerar bio com IA',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: OnboardingStepActions(
        onBack: widget.onBack,
        onNext: _canContinue ? _handleNext : null,
        nextLabel: 'Continuar',
        showBack: true,
      ),
    );
  }
}

/// Expandable section widget with toggle
class _ExpandableSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget? trailing;
  final bool isExpanded;
  final Widget child;
  final bool isDark;

  const _ExpandableSection({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.trailing,
    required this.isExpanded,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? iconColor.withAlpha(60)
              : (isDark ? AppColors.borderDark : AppColors.border),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(isDark ? 30 : 20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: child,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
