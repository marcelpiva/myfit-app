import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../widgets/animated_progress_bar.dart';

/// Redesigned Physical Data step for student onboarding
class StudentPhysicalDataStep extends StatefulWidget {
  final double? initialWeight;
  final double? initialHeight;
  final DateTime? initialBirthDate;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final Function(double?, double?, DateTime?) onContinue;
  final double progress;

  const StudentPhysicalDataStep({
    super.key,
    this.initialWeight,
    this.initialHeight,
    this.initialBirthDate,
    required this.onBack,
    required this.onSkip,
    required this.onContinue,
    this.progress = 0.5,
  });

  @override
  State<StudentPhysicalDataStep> createState() => _StudentPhysicalDataStepState();
}

class _StudentPhysicalDataStepState extends State<StudentPhysicalDataStep> {
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.initialWeight?.toStringAsFixed(1) ?? '',
    );
    _heightController = TextEditingController(
      text: widget.initialHeight?.toStringAsFixed(0) ?? '',
    );
    _selectedBirthDate = widget.initialBirthDate;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  int? _calculateAge() {
    if (_selectedBirthDate == null) return null;
    final now = DateTime.now();
    int years = now.year - _selectedBirthDate!.year;
    if (now.month < _selectedBirthDate!.month ||
        (now.month == _selectedBirthDate!.month && now.day < _selectedBirthDate!.day)) {
      years--;
    }
    return years;
  }

  Future<void> _selectBirthDate(BuildContext context, bool isDark) async {
    HapticUtils.selectionClick();

    final now = DateTime.now();
    final minDate = DateTime(now.year - 100, 1, 1);
    final maxDate = DateTime(now.year - 10, 12, 31); // Minimum 10 years old

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(now.year - 25, 1, 1),
      firstDate: minDate,
      lastDate: maxDate,
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.cardDark,
                    onSurface: AppColors.foregroundDark,
                  )
                : ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.card,
                    onSurface: AppColors.foreground,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      HapticUtils.lightImpact();
      setState(() {
        _selectedBirthDate = picked;
      });
    }
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
                            color: AppColors.warning.withAlpha(isDark ? 30 : 20),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.ruler,
                            size: 40,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Title
                      Center(
                        child: Text(
                          'Seus dados físicos',
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
                          'Opcional - ajuda a personalizar recomendações',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Weight
                      _buildInputCard(
                        icon: LucideIcons.scale,
                        title: 'Peso',
                        suffix: 'kg',
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                        ],
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      // Height
                      _buildInputCard(
                        icon: LucideIcons.arrowUpDown,
                        title: 'Altura',
                        suffix: 'cm',
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      // Birth Date
                      _buildBirthDateCard(isDark),
                      const SizedBox(height: 24),
                      // Privacy note
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withAlpha(isDark ? 20 : 15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.info.withAlpha(40),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.shieldCheck,
                              size: 20,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Seus dados são privados e usados apenas para personalização',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildInputCard({
    required IconData icon,
    required String title,
    required String suffix,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required List<TextInputFormatter> inputFormatters,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(isDark ? 30 : 20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                  decoration: InputDecoration(
                    hintText: '---',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.mutedForegroundDark.withAlpha(100)
                          : AppColors.mutedForeground.withAlpha(100),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          Text(
            suffix,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthDateCard(bool isDark) {
    final age = _calculateAge();
    final dateFormat = DateFormat('dd/MM/yyyy');

    return GestureDetector(
      onTap: () => _selectBirthDate(context, isDark),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(isDark ? 30 : 20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.calendar,
                size: 24,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data de Nascimento',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedBirthDate != null
                        ? dateFormat.format(_selectedBirthDate!)
                        : 'Toque para selecionar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _selectedBirthDate != null
                          ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                          : (isDark
                              ? AppColors.mutedForegroundDark.withAlpha(100)
                              : AppColors.mutedForeground.withAlpha(100)),
                    ),
                  ),
                ],
              ),
            ),
            if (age != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$age anos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              )
            else
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                HapticUtils.mediumImpact();
                final weight = double.tryParse(_weightController.text);
                final height = double.tryParse(_heightController.text);
                widget.onContinue(weight, height, _selectedBirthDate);
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
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              widget.onContinue(null, null, null);
            },
            child: Text(
              'Pular este passo',
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
}
