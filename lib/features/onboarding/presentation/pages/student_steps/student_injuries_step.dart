import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../widgets/animated_progress_bar.dart';

/// Redesigned Injuries step for student onboarding
class StudentInjuriesStep extends StatefulWidget {
  final List<String>? initialInjuries;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final Function(List<String>) onContinue;
  final double progress;

  const StudentInjuriesStep({
    super.key,
    this.initialInjuries,
    required this.onBack,
    required this.onSkip,
    required this.onContinue,
    this.progress = 0.83,
  });

  @override
  State<StudentInjuriesStep> createState() => _StudentInjuriesStepState();
}

class _StudentInjuriesStepState extends State<StudentInjuriesStep> {
  late Set<String> _selectedInjuries;
  final _otherController = TextEditingController();
  bool _hasNoInjuries = false;

  final _commonInjuries = [
    ('Joelho', LucideIcons.footprints),
    ('Ombro', LucideIcons.armchair),
    ('Coluna', LucideIcons.bone),
    ('Quadril', LucideIcons.accessibility),
    ('Tornozelo', LucideIcons.footprints),
    ('Punho', LucideIcons.hand),
  ];

  @override
  void initState() {
    super.initState();
    _selectedInjuries = Set.from(widget.initialInjuries ?? []);
    _hasNoInjuries = _selectedInjuries.isEmpty && widget.initialInjuries != null;
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, isDark),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Icon
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.destructive.withAlpha(isDark ? 30 : 20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.heartPulse,
                            size: 40,
                            color: AppColors.destructive,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title
                      Center(
                        child: Text(
                          'Alguma lesão ou limitação?',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Opcional - ajuda a evitar exercícios que possam causar desconforto',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // No injuries option
                      _buildNoInjuriesCard(isDark),
                      const SizedBox(height: 16),
                      // Section title
                      if (!_hasNoInjuries) ...[
                        Text(
                          'Áreas comuns',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Injury chips
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _commonInjuries.map((injury) {
                            final (label, icon) = injury;
                            return _buildInjuryChip(
                              label: label,
                              icon: icon,
                              isDark: isDark,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        // Other injury input
                        Text(
                          'Outra lesão ou observação',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _otherController,
                          decoration: InputDecoration(
                            hintText: 'Descreva aqui...',
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
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          maxLines: 2,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (value) {
                            if (value.trim().isNotEmpty) {
                              setState(() {
                                _selectedInjuries.add('Outro: ${value.trim()}');
                              });
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              // Bottom action
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

  Widget _buildNoInjuriesCard(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        setState(() {
          _hasNoInjuries = !_hasNoInjuries;
          if (_hasNoInjuries) {
            _selectedInjuries.clear();
            _otherController.clear();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hasNoInjuries
              ? AppColors.success.withAlpha(isDark ? 30 : 20)
              : (isDark ? AppColors.cardDark : AppColors.card),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hasNoInjuries
                ? AppColors.success
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: _hasNoInjuries ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _hasNoInjuries
                    ? AppColors.success.withAlpha(isDark ? 50 : 30)
                    : AppColors.success.withAlpha(isDark ? 20 : 15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.checkCircle,
                size: 24,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Não tenho lesões ou limitações',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: _hasNoInjuries ? FontWeight.w600 : FontWeight.w500,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),
            if (_hasNoInjuries)
              Icon(
                LucideIcons.checkCircle2,
                size: 24,
                color: AppColors.success,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInjuryChip({
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedInjuries.contains(label);

    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        setState(() {
          if (isSelected) {
            _selectedInjuries.remove(label);
          } else {
            _selectedInjuries.add(label);
            _hasNoInjuries = false;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.destructive.withAlpha(isDark ? 30 : 20)
              : (isDark ? AppColors.cardDark : AppColors.card),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.destructive
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppColors.destructive
                  : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.destructive
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ],
        ),
      ),
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
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: () {
            HapticUtils.mediumImpact();
            // Add other injury if filled
            final otherText = _otherController.text.trim();
            if (otherText.isNotEmpty && !_hasNoInjuries) {
              _selectedInjuries.add('Outro: $otherText');
            }
            widget.onContinue(_hasNoInjuries ? [] : _selectedInjuries.toList());
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
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
    );
  }
}
