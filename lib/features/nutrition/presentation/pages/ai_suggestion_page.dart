import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';

class AISuggestionPage extends ConsumerStatefulWidget {
  const AISuggestionPage({super.key});

  @override
  ConsumerState<AISuggestionPage> createState() => _AISuggestionPageState();
}

class _AISuggestionPageState extends ConsumerState<AISuggestionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  String? _selectedGoal;
  final Set<String> _selectedRestrictions = {};
  bool _isGenerating = false;
  List<Map<String, dynamic>>? _suggestions;

  final _goals = [
    {'id': 'lose', 'label': 'Perder peso', 'icon': LucideIcons.trendingDown},
    {'id': 'gain', 'label': 'Ganhar massa', 'icon': LucideIcons.trendingUp},
    {'id': 'maintain', 'label': 'Manter peso', 'icon': LucideIcons.minus},
  ];

  final _restrictions = [
    {'id': 'vegetarian', 'label': 'Vegetariano'},
    {'id': 'vegan', 'label': 'Vegano'},
    {'id': 'lactose_free', 'label': 'Sem lactose'},
    {'id': 'gluten_free', 'label': 'Sem glúten'},
    {'id': 'low_carb', 'label': 'Low carb'},
    {'id': 'high_protein', 'label': 'Alto em proteína'},
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
    super.dispose();
  }

  void _selectGoal(String goalId) {
    HapticUtils.selectionClick();
    setState(() {
      _selectedGoal = goalId;
      _suggestions = null;
    });
  }

  void _toggleRestriction(String restrictionId) {
    HapticUtils.selectionClick();
    setState(() {
      if (_selectedRestrictions.contains(restrictionId)) {
        _selectedRestrictions.remove(restrictionId);
      } else {
        _selectedRestrictions.add(restrictionId);
      }
      _suggestions = null;
    });
  }

  Future<void> _generateSuggestions() async {
    if (_selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um objetivo primeiro', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    HapticUtils.mediumImpact();
    setState(() {
      _isGenerating = true;
    });

    // Simulate AI generation delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isGenerating = false;
      _suggestions = _getMockSuggestions();
    });
  }

  List<Map<String, dynamic>> _getMockSuggestions() {
    // Return suggestions based on selected goal
    if (_selectedGoal == 'lose') {
      return _loseSuggestions;
    } else if (_selectedGoal == 'gain') {
      return _gainSuggestions;
    } else {
      return _maintainSuggestions;
    }
  }

  void _addToPlan(Map<String, dynamic> suggestion) {
    HapticUtils.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${suggestion['name']} adicionado ao plano', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        context.pop();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.card,
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.arrowLeft,
                          size: 20,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.sparkles,
                          size: 20,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sugestão com IA',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _suggestions != null
                    ? _buildSuggestionsView(isDark)
                    : _buildConfigurationView(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurationView(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goal selection
          Text(
            'Qual é seu objetivo?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          ...(_goals.map((goal) => _GoalOption(
                goal: goal,
                isSelected: _selectedGoal == goal['id'],
                isDark: isDark,
                onTap: () => _selectGoal(goal['id'] as String),
              ))),

          const SizedBox(height: 28),

          // Restrictions
          Text(
            'Restrições alimentares (opcional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _restrictions.map((restriction) {
              final isSelected = _selectedRestrictions.contains(restriction['id']);
              return GestureDetector(
                onTap: () => _toggleRestriction(restriction['id'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withAlpha(25)
                        : (isDark
                            ? AppColors.cardDark.withAlpha(150)
                            : AppColors.card.withAlpha(200)),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.borderDark : AppColors.border),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          LucideIcons.check,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        restriction['label'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(15),
              border: Border.all(
                color: AppColors.info.withAlpha(50),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.brain,
                    size: 22,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inteligencia Artificial',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Nossas sugestões são personalizadas com base no seu objetivo e restrições',
                        style: TextStyle(
                          fontSize: 13,
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
          ),

          const SizedBox(height: 32),

          // Generate button
          GestureDetector(
            onTap: _isGenerating ? null : _generateSuggestions,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _selectedGoal != null && !_isGenerating
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.mutedDark.withAlpha(150)
                        : AppColors.muted.withAlpha(200)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isGenerating) ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          _selectedGoal != null
                              ? Colors.white
                              : (isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Gerando sugestões...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _selectedGoal != null
                            ? Colors.white
                            : (isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground),
                      ),
                    ),
                  ] else ...[
                    Icon(
                      LucideIcons.sparkles,
                      size: 20,
                      color: _selectedGoal != null
                          ? Colors.white
                          : (isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Gerar Sugestões',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _selectedGoal != null
                            ? Colors.white
                            : (isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSuggestionsView(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sugestões para você',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Baseado no objetivo: ${_getGoalLabel()}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  setState(() {
                    _suggestions = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.mutedDark.withAlpha(150)
                        : AppColors.muted.withAlpha(200),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.settings2,
                        size: 16,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Alterar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _suggestions!.length,
            itemBuilder: (context, index) {
              final suggestion = _suggestions![index];
              return _SuggestionCard(
                suggestion: suggestion,
                isDark: isDark,
                onAdd: () => _addToPlan(suggestion),
              );
            },
          ),
        ),

        // Regenerate button
        Padding(
          padding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: _generateSuggestions,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.mutedDark.withAlpha(150)
                    : AppColors.muted.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.refreshCw,
                    size: 18,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Gerar novas sugestões',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
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

  String _getGoalLabel() {
    final goal = _goals.firstWhere(
      (g) => g['id'] == _selectedGoal,
      orElse: () => {'label': ''},
    );
    return goal['label'] as String;
  }
}

class _GoalOption extends StatelessWidget {
  final Map<String, dynamic> goal;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _GoalOption({
    required this.goal,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(15)
              : (isDark
                  ? AppColors.cardDark.withAlpha(150)
                  : AppColors.card.withAlpha(200)),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(25)
                    : (isDark
                        ? AppColors.mutedDark.withAlpha(150)
                        : AppColors.muted.withAlpha(200)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                goal['icon'] as IconData,
                size: 24,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                goal['label'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                ),
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
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final Map<String, dynamic> suggestion;
  final bool isDark;
  final VoidCallback onAdd;

  const _SuggestionCard({
    required this.suggestion,
    required this.isDark,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final foods = suggestion['foods'] as List<String>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (suggestion['color'] as Color).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    suggestion['icon'] as IconData,
                    size: 22,
                    color: suggestion['color'] as Color,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion['name'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        suggestion['description'] as String,
                        style: TextStyle(
                          fontSize: 13,
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
          ),

          // Macros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _MacroBadge(
                  label: 'Calorias',
                  value: '${suggestion['calories']}',
                  unit: 'kcal',
                  color: AppColors.warning,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _MacroBadge(
                  label: 'Proteína',
                  value: '${suggestion['protein']}',
                  unit: 'g',
                  color: AppColors.primary,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _MacroBadge(
                  label: 'Carbs',
                  value: '${suggestion['carbs']}',
                  unit: 'g',
                  color: AppColors.secondary,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _MacroBadge(
                  label: 'Gordura',
                  value: '${suggestion['fat']}',
                  unit: 'g',
                  color: AppColors.accent,
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Foods
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.mutedDark.withAlpha(50)
                  : AppColors.muted.withAlpha(100),
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
            ),
            child: Column(
              children: foods.asMap().entries.map((entry) {
                final isLast = entry.key == foods.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Add button
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.plus,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Adicionar ao plano',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
}

class _MacroBadge extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final bool isDark;

  const _MacroBadge({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(width: 1),
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 9,
                      color: color.withAlpha(180),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Mock data for suggestions
final _loseSuggestions = [
  {
    'name': 'Café da Manhã Leve',
    'description': 'Baixo em calorias, alto em proteína',
    'icon': LucideIcons.coffee,
    'color': AppColors.warning,
    'calories': 320,
    'protein': 25,
    'carbs': 30,
    'fat': 10,
    'foods': [
      'Omelete com 3 claras e 1 gema',
      '1 fatia de pão integral',
      'Salada de frutas (100g)',
      'Chá verde sem açúcar',
    ],
  },
  {
    'name': 'Almoço Equilibrado',
    'description': 'Rico em fibras e proteínas magras',
    'icon': LucideIcons.utensils,
    'color': AppColors.primary,
    'calories': 420,
    'protein': 40,
    'carbs': 35,
    'fat': 12,
    'foods': [
      '150g peito de frango grelhado',
      '80g arroz integral',
      'Salada verde à vontade',
      'Legumes no vapor',
    ],
  },
  {
    'name': 'Jantar Leve',
    'description': 'Fácil digestão para a noite',
    'icon': LucideIcons.moon,
    'color': AppColors.secondary,
    'calories': 280,
    'protein': 30,
    'carbs': 15,
    'fat': 10,
    'foods': [
      '120g peixe grelhado',
      'Legumes salteados',
      'Salada de folhas',
      'Azeite extra virgem (1 colher)',
    ],
  },
];

final _gainSuggestions = [
  {
    'name': 'Café da Manhã Forte',
    'description': 'Alto em calorias e proteína',
    'icon': LucideIcons.coffee,
    'color': AppColors.warning,
    'calories': 650,
    'protein': 45,
    'carbs': 60,
    'fat': 25,
    'foods': [
      '4 ovos mexidos completos',
      '2 fatias de pão integral com pasta de amendoim',
      '1 banana grande',
      '300ml de leite integral',
    ],
  },
  {
    'name': 'Almoço Hipercalórico',
    'description': 'Denso em nutrientes para ganho',
    'icon': LucideIcons.utensils,
    'color': AppColors.primary,
    'calories': 850,
    'protein': 55,
    'carbs': 90,
    'fat': 28,
    'foods': [
      '200g carne vermelha magra',
      '150g arroz branco',
      '100g feijão',
      'Batata doce (100g)',
      'Azeite (2 colheres)',
    ],
  },
  {
    'name': 'Lanche Pré-Treino',
    'description': 'Energia para o treino',
    'icon': LucideIcons.dumbbell,
    'color': AppColors.accent,
    'calories': 450,
    'protein': 35,
    'carbs': 45,
    'fat': 15,
    'foods': [
      '1 scoop whey protein',
      '60g aveia',
      '1 banana',
      '20g pasta de amendoim',
    ],
  },
];

final _maintainSuggestions = [
  {
    'name': 'Café da Manhã Balanceado',
    'description': 'Equilíbrio de macros',
    'icon': LucideIcons.coffee,
    'color': AppColors.warning,
    'calories': 450,
    'protein': 30,
    'carbs': 45,
    'fat': 18,
    'foods': [
      '2 ovos mexidos',
      '2 fatias de pão integral',
      '1 fruta média',
      'Café com leite',
    ],
  },
  {
    'name': 'Almoço Completo',
    'description': 'Todos os grupos alimentares',
    'icon': LucideIcons.utensils,
    'color': AppColors.primary,
    'calories': 580,
    'protein': 45,
    'carbs': 55,
    'fat': 20,
    'foods': [
      '150g proteína (frango ou peixe)',
      '100g arroz',
      '80g feijão ou lentilha',
      'Salada variada',
      'Azeite (1 colher)',
    ],
  },
  {
    'name': 'Jantar Moderado',
    'description': 'Leve mas nutritivo',
    'icon': LucideIcons.moon,
    'color': AppColors.secondary,
    'calories': 420,
    'protein': 35,
    'carbs': 30,
    'fat': 18,
    'foods': [
      '130g proteína magra',
      'Legumes variados',
      'Salada verde',
      '1/2 batata doce',
    ],
  },
];
