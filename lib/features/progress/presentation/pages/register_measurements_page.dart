import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';

class RegisterMeasurementsPage extends ConsumerStatefulWidget {
  const RegisterMeasurementsPage({super.key});

  @override
  ConsumerState<RegisterMeasurementsPage> createState() =>
      _RegisterMeasurementsPageState();
}

class _RegisterMeasurementsPageState
    extends ConsumerState<RegisterMeasurementsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // Measurement controllers
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _bicepsController = TextEditingController();
  final _thighController = TextEditingController();
  final _calfController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  final List<_MeasurementField> _fields = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.entrance,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
    _controller.forward();

    _initFields();
  }

  void _initFields() {
    _fields.addAll([
      _MeasurementField(
        label: 'Peito',
        icon: LucideIcons.circle,
        controller: _chestController,
        previousValue: 98.5,
      ),
      _MeasurementField(
        label: 'Cintura',
        icon: LucideIcons.minus,
        controller: _waistController,
        previousValue: 82.0,
      ),
      _MeasurementField(
        label: 'Quadril',
        icon: LucideIcons.circleOff,
        controller: _hipsController,
        previousValue: 95.0,
      ),
      _MeasurementField(
        label: 'Biceps',
        icon: LucideIcons.zap,
        controller: _bicepsController,
        previousValue: 35.5,
      ),
      _MeasurementField(
        label: 'Coxa',
        icon: LucideIcons.arrowDown,
        controller: _thighController,
        previousValue: 58.0,
      ),
      _MeasurementField(
        label: 'Panturrilha',
        icon: LucideIcons.footprints,
        controller: _calfController,
        previousValue: 38.0,
      ),
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _bicepsController.dispose();
    _thighController.dispose();
    _calfController.dispose();
    super.dispose();
  }

  void _saveMeasurements() {
    final hasValue = _fields.any((f) => f.controller.text.isNotEmpty);

    if (!hasValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preencha pelo menos uma medida'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Medidas registradas com sucesso!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Hoje';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isDark ? AppColors.cardDark : AppColors.card,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.arrowLeft,
                            size: 18,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Registrar Medidas',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date selector
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark.withAlpha(150)
                                  : AppColors.card.withAlpha(200),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    LucideIcons.calendar,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Data do registro',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.mutedForegroundDark
                                              : AppColors.mutedForeground,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatDate(_selectedDate),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.foregroundDark
                                              : AppColors.foreground,
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
                        ),

                        const SizedBox(height: 24),

                        // Section title
                        Row(
                          children: [
                            Icon(
                              LucideIcons.ruler,
                              size: 18,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Medidas Corporais',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Deixe em branco os campos que nao deseja atualizar',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Measurement fields
                        ...List.generate(_fields.length, (index) {
                          return _buildMeasurementField(
                            isDark,
                            _fields[index],
                            index,
                          );
                        }),

                        const SizedBox(height: 24),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveMeasurements,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.secondaryDark
                                  : AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Salvar Medidas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementField(
    bool isDark,
    _MeasurementField field,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(100)
              : AppColors.card.withAlpha(150),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // Label
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Anterior: ${field.previousValue} cm',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),

            // Input
            SizedBox(
              width: 80,
              child: TextField(
                controller: field.controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.foregroundDark
                      : AppColors.foreground,
                ),
                decoration: InputDecoration(
                  hintText: '-',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.mutedDark.withAlpha(100)
                      : AppColors.muted.withAlpha(150),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            Text(
              'cm',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasurementField {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final double previousValue;

  _MeasurementField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.previousValue,
  });
}
