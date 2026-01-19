import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';

/// Meal Log Page for logging food intake
class MealLogPage extends ConsumerStatefulWidget {
  final String? mealType;

  const MealLogPage({super.key, this.mealType});

  @override
  ConsumerState<MealLogPage> createState() => _MealLogPageState();
}

class _MealLogPageState extends ConsumerState<MealLogPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  String _selectedMealType = 'breakfast';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _notesController = TextEditingController();
  final List<Map<String, dynamic>> _selectedFoods = [];

  final _mealTypes = [
    {'id': 'breakfast', 'name': 'Café da Manhã', 'icon': LucideIcons.coffee},
    {'id': 'morning_snack', 'name': 'Lanche Manhã', 'icon': LucideIcons.apple},
    {'id': 'lunch', 'name': 'Almoço', 'icon': LucideIcons.utensils},
    {'id': 'afternoon_snack', 'name': 'Lanche Tarde', 'icon': LucideIcons.cookie},
    {'id': 'dinner', 'name': 'Jantar', 'icon': LucideIcons.moon},
    {'id': 'evening_snack', 'name': 'Ceia', 'icon': LucideIcons.star},
  ];

  // Mock recent foods
  final _recentFoods = [
    {'id': '1', 'name': 'Frango grelhado', 'portion': '100g', 'calories': 165, 'protein': 31, 'carbs': 0, 'fat': 4},
    {'id': '2', 'name': 'Arroz integral', 'portion': '100g', 'calories': 130, 'protein': 3, 'carbs': 28, 'fat': 1},
    {'id': '3', 'name': 'Ovo cozido', 'portion': '1 unidade', 'calories': 78, 'protein': 6, 'carbs': 1, 'fat': 5},
    {'id': '4', 'name': 'Banana', 'portion': '1 média', 'calories': 105, 'protein': 1, 'carbs': 27, 'fat': 0},
    {'id': '5', 'name': 'Whey Protein', 'portion': '30g', 'calories': 120, 'protein': 24, 'carbs': 3, 'fat': 1},
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

    if (widget.mealType != null) {
      _selectedMealType = widget.mealType!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _totalCalories => _selectedFoods.fold<int>(
        0,
        (sum, food) => sum + (food['calories'] as int),
      );

  int get _totalProtein => _selectedFoods.fold<int>(
        0,
        (sum, food) => sum + (food['protein'] as int),
      );

  int get _totalCarbs => _selectedFoods.fold<int>(
        0,
        (sum, food) => sum + (food['carbs'] as int),
      );

  int get _totalFat => _selectedFoods.fold<int>(
        0,
        (sum, food) => sum + (food['fat'] as int),
      );

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hoje';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Ontem';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  void _saveMealLog() {
    if (_selectedFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Adicione pelo menos um alimento'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    HapticUtils.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Refeição registrada com sucesso!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    Navigator.pop(context);
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
                _buildHeader(isDark, theme),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meal type selector
                        _buildMealTypeSelector(isDark),

                        const SizedBox(height: 20),

                        // Date and time
                        _buildDateTimeSelector(isDark),

                        const SizedBox(height: 24),

                        // Selected foods
                        _buildSelectedFoodsSection(isDark),

                        const SizedBox(height: 24),

                        // Add food options
                        _buildAddFoodOptions(isDark),

                        const SizedBox(height: 24),

                        // Recent foods
                        _buildRecentFoodsSection(isDark),

                        const SizedBox(height: 24),

                        // Notes
                        _buildNotesSection(isDark),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Bottom bar with totals and save button
                _buildBottomBar(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? AppColors.cardDark : AppColors.card,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Icon(
                LucideIcons.arrowLeft,
                size: 18,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Registrar Refeição',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildMealTypeSelector(bool isDark) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _mealTypes.length,
        itemBuilder: (context, index) {
          final type = _mealTypes[index];
          final isSelected = _selectedMealType == type['id'];

          return GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              setState(() => _selectedMealType = type['id'] as String);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 85,
              margin: EdgeInsets.only(right: index < _mealTypes.length - 1 ? 10 : 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(20)
                    : (isDark ? AppColors.cardDark : AppColors.card),
                borderRadius: BorderRadius.circular(12),
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
                  Icon(
                    type['icon'] as IconData,
                    size: 24,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    type['name'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateTimeSelector(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 18,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 10),
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
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (picked != null) {
                setState(() => _selectedTime = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.clock,
                    size: 18,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFoodsSection(bool isDark) {
    if (_selectedFoods.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(100)
              : AppColors.card.withAlpha(150),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              LucideIcons.utensils,
              size: 40,
              color: isDark
                  ? AppColors.mutedForegroundDark.withAlpha(100)
                  : AppColors.mutedForeground.withAlpha(100),
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhum alimento adicionado',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Adicione alimentos usando as opções abaixo',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.mutedForegroundDark.withAlpha(150)
                    : AppColors.mutedForeground.withAlpha(150),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alimentos Selecionados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            Text(
              '${_selectedFoods.length} itens',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(_selectedFoods.length, (index) {
          final food = _selectedFoods[index];
          return _buildSelectedFoodItem(food, index, isDark);
        }),
      ],
    );
  }

  Widget _buildSelectedFoodItem(Map<String, dynamic> food, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food['name'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  food['portion'] as String,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${food['calories']} kcal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
              Text(
                'P: ${food['protein']}g  C: ${food['carbs']}g  G: ${food['fat']}g',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              setState(() => _selectedFoods.removeAt(index));
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.destructive.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                LucideIcons.x,
                size: 14,
                color: AppColors.destructive,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFoodOptions(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildAddOption(
            'Buscar',
            LucideIcons.search,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Abrindo busca de alimentos...'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildAddOption(
            'Barcode',
            LucideIcons.scanLine,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Abrindo scanner...'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildAddOption(
            'Manual',
            LucideIcons.plus,
            () {
              // Add mock food
              setState(() {
                _selectedFoods.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'name': 'Alimento manual',
                  'portion': '100g',
                  'calories': 100,
                  'protein': 10,
                  'carbs': 10,
                  'fat': 5,
                });
              });
            },
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildAddOption(String label, IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withAlpha(30),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDark ? AppColors.primaryDark : AppColors.primary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFoodsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alimentos Recentes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(_recentFoods.length, (index) {
          final food = _recentFoods[index];
          return _buildRecentFoodItem(food, isDark);
        }),
      ],
    );
  }

  Widget _buildRecentFoodItem(Map<String, dynamic> food, bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        setState(() {
          _selectedFoods.add({...food});
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(100)
              : AppColors.card.withAlpha(150),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                  Text(
                    food['portion'] as String,
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
            Text(
              '${food['calories']} kcal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              LucideIcons.plus,
              size: 18,
              color: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observações (opcional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 2,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
          decoration: InputDecoration(
            hintText: 'Ex: Refeição pós-treino',
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.mutedForegroundDark.withAlpha(150)
                  : AppColors.mutedForeground.withAlpha(150),
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.cardDark.withAlpha(100)
                : AppColors.card.withAlpha(150),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Totals row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroTotal('Calorias', '$_totalCalories', 'kcal', AppColors.warning, isDark),
                _buildMacroTotal('Proteína', '$_totalProtein', 'g', AppColors.destructive, isDark),
                _buildMacroTotal('Carbos', '$_totalCarbs', 'g', AppColors.info, isDark),
                _buildMacroTotal('Gordura', '$_totalFat', 'g', AppColors.warning, isDark),
              ],
            ),
            const SizedBox(height: 16),
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveMealLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.primaryDark
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.check, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Registrar Refeição',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroTotal(String label, String value, String unit, Color color, bool isDark) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                unit,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withAlpha(180),
                ),
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
