import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';

/// Diet Plan Builder Page for Nutritionists
/// Allows creating and editing diet plans with meals
class DietPlanBuilderPage extends ConsumerStatefulWidget {
  final String? planId; // null for new plan, id for editing

  const DietPlanBuilderPage({super.key, this.planId});

  @override
  ConsumerState<DietPlanBuilderPage> createState() => _DietPlanBuilderPageState();
}

class _DietPlanBuilderPageState extends ConsumerState<DietPlanBuilderPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController(text: '2000');
  final _proteinController = TextEditingController(text: '150');
  final _carbsController = TextEditingController(text: '200');
  final _fatController = TextEditingController(text: '70');

  bool _isTemplate = false;
  final List<String> _selectedTags = [];
  final List<Map<String, dynamic>> _meals = [];

  final _availableTags = [
    'Low Carb', 'High Protein', 'Vegetariano', 'Vegano',
    'Sem Gluten', 'Sem Lactose', 'Cutting', 'Bulking',
    'Manutencao', 'Iniciante',
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

    // Initialize with default meals if new plan
    if (widget.planId == null) {
      _meals.addAll([
        {'name': 'Cafe da Manha', 'time': '07:00', 'foods': <Map<String, dynamic>>[]},
        {'name': 'Lanche da Manha', 'time': '10:00', 'foods': <Map<String, dynamic>>[]},
        {'name': 'Almoco', 'time': '12:30', 'foods': <Map<String, dynamic>>[]},
        {'name': 'Lanche da Tarde', 'time': '15:30', 'foods': <Map<String, dynamic>>[]},
        {'name': 'Jantar', 'time': '19:00', 'foods': <Map<String, dynamic>>[]},
      ]);
    } else {
      // Load existing plan data (mock)
      _loadExistingPlan();
    }
  }

  void _loadExistingPlan() {
    // Mock loading existing plan
    _nameController.text = 'Plano Cutting 2000kcal';
    _descriptionController.text = 'Plano focado em perda de gordura com preservacao muscular';
    _caloriesController.text = '2000';
    _proteinController.text = '180';
    _carbsController.text = '150';
    _fatController.text = '60';
    _selectedTags.addAll(['Low Carb', 'High Protein', 'Cutting']);
    _meals.addAll([
      {
        'name': 'Cafe da Manha',
        'time': '07:00',
        'foods': [
          {'name': 'Ovos mexidos', 'portion': '3 unidades', 'calories': 210},
          {'name': 'Pao integral', 'portion': '2 fatias', 'calories': 140},
        ],
      },
      {
        'name': 'Almoco',
        'time': '12:30',
        'foods': [
          {'name': 'Frango grelhado', 'portion': '200g', 'calories': 330},
          {'name': 'Arroz integral', 'portion': '100g', 'calories': 130},
          {'name': 'Brocolis', 'portion': '100g', 'calories': 35},
        ],
      },
      {
        'name': 'Jantar',
        'time': '19:00',
        'foods': [
          {'name': 'Salmao grelhado', 'portion': '150g', 'calories': 280},
          {'name': 'Salada verde', 'portion': '150g', 'calories': 25},
        ],
      },
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _savePlan() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Informe o nome do plano'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    HapticUtils.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.planId == null
            ? 'Plano criado com sucesso!'
            : 'Plano atualizado com sucesso!'),
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

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic info
                        _buildBasicInfoSection(isDark),

                        const SizedBox(height: 24),

                        // Macro targets
                        _buildMacroTargetsSection(isDark),

                        const SizedBox(height: 24),

                        // Tags
                        _buildTagsSection(isDark),

                        const SizedBox(height: 24),

                        // Meals
                        _buildMealsSection(isDark),

                        const SizedBox(height: 24),

                        // Save button
                        _buildSaveButton(isDark),

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
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.planId == null ? 'Novo Plano' : 'Editar Plano',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Template toggle
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              setState(() => _isTemplate = !_isTemplate);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isTemplate
                    ? AppColors.primary.withAlpha(20)
                    : (isDark ? AppColors.cardDark : AppColors.card),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isTemplate
                      ? AppColors.primary
                      : (isDark ? AppColors.borderDark : AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isTemplate ? LucideIcons.checkSquare : LucideIcons.square,
                    size: 16,
                    color: _isTemplate
                        ? AppColors.primary
                        : (isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Template',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _isTemplate
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground),
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

  Widget _buildBasicInfoSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informacoes Basicas', LucideIcons.fileText, isDark),
          const SizedBox(height: 16),

          // Name
          _buildTextField(
            controller: _nameController,
            label: 'Nome do Plano',
            hint: 'Ex: Plano Cutting 2000kcal',
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Description
          _buildTextField(
            controller: _descriptionController,
            label: 'Descricao',
            hint: 'Descreva o objetivo do plano',
            isDark: isDark,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroTargetsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Metas de Macros', LucideIcons.target, isDark),
          const SizedBox(height: 16),

          // Calories (full width)
          _buildMacroInput(
            controller: _caloriesController,
            label: 'Calorias',
            suffix: 'kcal',
            icon: LucideIcons.flame,
            color: AppColors.warning,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Protein, Carbs, Fat in row
          Row(
            children: [
              Expanded(
                child: _buildMacroInput(
                  controller: _proteinController,
                  label: 'Proteinas',
                  suffix: 'g',
                  icon: LucideIcons.beef,
                  color: AppColors.destructive,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroInput(
                  controller: _carbsController,
                  label: 'Carbos',
                  suffix: 'g',
                  icon: LucideIcons.wheat,
                  color: AppColors.info,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroInput(
                  controller: _fatController,
                  label: 'Gorduras',
                  suffix: 'g',
                  icon: LucideIcons.droplet,
                  color: AppColors.warning,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.tag,
              size: 18,
              color: isDark ? AppColors.primaryDark : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Tags',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withAlpha(20)
                      : (isDark ? AppColors.cardDark : AppColors.card),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.border),
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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
      ],
    );
  }

  Widget _buildMealsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.utensils,
                  size: 18,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Refeicoes',
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
            GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                _showAddMealDialog(isDark);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.plus,
                      size: 16,
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Adicionar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.primaryDark
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Meals list
        ...List.generate(_meals.length, (index) {
          final meal = _meals[index];
          return _buildMealCard(meal, index, isDark);
        }),
      ],
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal, int index, bool isDark) {
    final foods = meal['foods'] as List<Map<String, dynamic>>;
    final totalCalories = foods.fold<int>(
      0,
      (sum, food) => sum + (food['calories'] as int? ?? 0),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                meal['time'] as String,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
            ),
          ),
          title: Text(
            meal['name'] as String,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          subtitle: Text(
            '${foods.length} alimentos - $totalCalories kcal',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  _showAddFoodDialog(index, isDark);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    LucideIcons.plus,
                    size: 16,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                LucideIcons.chevronDown,
                size: 18,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ],
          ),
          children: [
            if (foods.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.mutedDark.withAlpha(50)
                      : AppColors.muted.withAlpha(100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.utensils,
                      size: 16,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Nenhum alimento adicionado',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...foods.map((food) => _buildFoodItem(food, index, isDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItem(Map<String, dynamic> food, int mealIndex, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.mutedDark.withAlpha(50)
            : AppColors.muted.withAlpha(100),
        borderRadius: BorderRadius.circular(8),
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
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.primaryDark : AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              setState(() {
                (_meals[mealIndex]['foods'] as List).remove(food);
              });
            },
            child: Icon(
              LucideIcons.x,
              size: 16,
              color: AppColors.destructive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _savePlan,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.planId == null ? LucideIcons.plus : LucideIcons.save,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              widget.planId == null ? 'Criar Plano' : 'Salvar Alteracoes',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.primaryDark : AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.mutedForegroundDark.withAlpha(150)
                  : AppColors.mutedForeground.withAlpha(150),
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.mutedDark.withAlpha(100)
                : AppColors.muted.withAlpha(150),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroInput({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.mutedDark.withAlpha(100)
                : AppColors.muted.withAlpha(150),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  suffix,
                  style: TextStyle(
                    fontSize: 12,
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
    );
  }

  void _showAddMealDialog(bool isDark) {
    final nameController = TextEditingController();
    final timeController = TextEditingController(text: '08:00');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
        title: const Text('Nova Refeicao'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Ex: Lanche Pre-Treino',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Horario',
                hintText: 'Ex: 16:00',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _meals.add({
                    'name': nameController.text,
                    'time': timeController.text,
                    'foods': <Map<String, dynamic>>[],
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showAddFoodDialog(int mealIndex, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adicionar Alimento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 20),

            // Quick add options
            _buildQuickAddOption(
              'Buscar alimento',
              LucideIcons.search,
              () {
                Navigator.pop(ctx);
                // Navigate to food search
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
            const SizedBox(height: 8),
            _buildQuickAddOption(
              'Escanear codigo de barras',
              LucideIcons.scanLine,
              () {
                Navigator.pop(ctx);
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
            const SizedBox(height: 8),
            _buildQuickAddOption(
              'Adicionar manualmente',
              LucideIcons.plus,
              () {
                Navigator.pop(ctx);
                // Add mock food for demo
                setState(() {
                  (_meals[mealIndex]['foods'] as List).add({
                    'name': 'Alimento adicionado',
                    'portion': '100g',
                    'calories': 150,
                  });
                });
              },
              isDark,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddOption(
    String label,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.mutedDark.withAlpha(100)
              : AppColors.muted.withAlpha(150),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.primaryDark : AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const Spacer(),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
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
