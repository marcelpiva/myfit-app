import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';

class RegisterWeightPage extends ConsumerStatefulWidget {
  const RegisterWeightPage({super.key});

  @override
  ConsumerState<RegisterWeightPage> createState() => _RegisterWeightPageState();
}

class _RegisterWeightPageState extends ConsumerState<RegisterWeightPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final _weightController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Mock historical data
  final List<Map<String, dynamic>> _weightHistory = [
    {'date': DateTime.now().subtract(const Duration(days: 1)), 'weight': 75.2},
    {'date': DateTime.now().subtract(const Duration(days: 7)), 'weight': 75.8},
    {'date': DateTime.now().subtract(const Duration(days: 14)), 'weight': 76.1},
    {'date': DateTime.now().subtract(const Duration(days: 21)), 'weight': 76.5},
  ];

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
  }

  @override
  void dispose() {
    _controller.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _saveWeight() {
    if (_weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Informe o peso'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Peso registrado com sucesso!'),
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
                        'Registrar Peso',
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
                        // Weight input section
                        Container(
                          padding: const EdgeInsets.all(24),
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
                          child: Column(
                            children: [
                              // Icon
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  LucideIcons.scale,
                                  size: 28,
                                  color: isDark
                                      ? AppColors.primaryDark
                                      : AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Weight input
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: _weightController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.foregroundDark
                                            : AppColors.foreground,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '0.0',
                                        hintStyle: TextStyle(
                                          color: isDark
                                              ? AppColors.mutedForegroundDark
                                              : AppColors.mutedForeground,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      'kg',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.mutedForegroundDark
                                            : AppColors.mutedForeground,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Date selector
                              GestureDetector(
                                onTap: _selectDate,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
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
                                        LucideIcons.calendar,
                                        size: 18,
                                        color: isDark
                                            ? AppColors.mutedForegroundDark
                                            : AppColors.mutedForeground,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatDate(_selectedDate),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? AppColors.foregroundDark
                                              : AppColors.foreground,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        LucideIcons.chevronDown,
                                        size: 16,
                                        color: isDark
                                            ? AppColors.mutedForegroundDark
                                            : AppColors.mutedForeground,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveWeight,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Salvar Registro',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Recent history
                        Text(
                          'Historico Recente',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ...List.generate(_weightHistory.length, (index) {
                          final entry = _weightHistory[index];
                          final previousWeight = index < _weightHistory.length - 1
                              ? _weightHistory[index + 1]['weight'] as double
                              : entry['weight'] as double;
                          final diff =
                              (entry['weight'] as double) - previousWeight;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark.withAlpha(100)
                                  : AppColors.card.withAlpha(150),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _formatDate(entry['date'] as DateTime),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? AppColors.mutedForegroundDark
                                        : AppColors.mutedForeground,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${entry['weight']} kg',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.foregroundDark
                                        : AppColors.foreground,
                                  ),
                                ),
                                if (index < _weightHistory.length - 1) ...[
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: diff <= 0
                                          ? const Color(0xFF10B981).withAlpha(25)
                                          : const Color(0xFFEF4444).withAlpha(25),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          diff <= 0
                                              ? LucideIcons.trendingDown
                                              : LucideIcons.trendingUp,
                                          size: 12,
                                          color: diff <= 0
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFEF4444),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: diff <= 0
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFEF4444),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),

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
}
