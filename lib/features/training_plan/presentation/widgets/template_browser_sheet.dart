import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/workout_service.dart';

/// Template browser sheet for selecting a program template
class TemplateBrowserSheet extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic> template) onTemplateSelected;

  const TemplateBrowserSheet({
    super.key,
    required this.onTemplateSelected,
  });

  @override
  ConsumerState<TemplateBrowserSheet> createState() => _TemplateBrowserSheetState();
}

class _TemplateBrowserSheetState extends ConsumerState<TemplateBrowserSheet> {
  final _searchController = TextEditingController();
  final _workoutService = WorkoutService();

  List<Map<String, dynamic>> _templates = [];
  bool _isLoading = true;
  String? _error;

  // Filters
  String? _selectedGoal;
  String? _selectedDifficulty;
  String? _selectedSplit;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get only user's own programs (not public templates from others)
      final templates = await _workoutService.getPlans(templatesOnly: false);
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectTemplate(Map<String, dynamic> basicTemplate) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Fetch full template details including program_workouts
      final templateId = basicTemplate['id'] as String?;
      if (templateId == null) {
        throw Exception('Template ID não encontrado');
      }

      final fullTemplate = await _workoutService.getPlan(templateId);

      if (mounted) {
        Navigator.pop(context); // Close loading
        widget.onTemplateSelected(fullTemplate);
        Navigator.pop(context); // Close sheet
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar template: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredTemplates {
    var filtered = _templates;

    // Filter by search
    final search = _searchController.text.toLowerCase();
    if (search.isNotEmpty) {
      filtered = filtered.where((t) {
        final name = (t['name'] as String? ?? '').toLowerCase();
        return name.contains(search);
      }).toList();
    }

    // Filter by goal
    if (_selectedGoal != null) {
      filtered = filtered.where((t) {
        return t['goal'] == _selectedGoal;
      }).toList();
    }

    // Filter by difficulty
    if (_selectedDifficulty != null) {
      filtered = filtered.where((t) {
        return t['difficulty'] == _selectedDifficulty;
      }).toList();
    }

    // Filter by split
    if (_selectedSplit != null) {
      filtered = filtered.where((t) {
        return t['split_type'] == _selectedSplit;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.copy,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meus Planos',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Selecione um plano como base',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Search
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar planos...',
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    filled: true,
                    fillColor: isDark
                        ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                        : theme.colorScheme.surfaceContainerLow.withAlpha(200),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 12),

                // Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        theme,
                        isDark,
                        'Objetivo',
                        _selectedGoal != null ? _getGoalName(_selectedGoal!) : null,
                        () => _showGoalFilter(context, theme, isDark),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        theme,
                        isDark,
                        'Nível',
                        _selectedDifficulty != null
                            ? _getDifficultyName(_selectedDifficulty!)
                            : null,
                        () => _showDifficultyFilter(context, theme, isDark),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        theme,
                        isDark,
                        'Divisão',
                        _selectedSplit != null ? _getSplitName(_selectedSplit!) : null,
                        () => _showSplitFilter(context, theme, isDark),
                      ),
                      if (_selectedGoal != null ||
                          _selectedDifficulty != null ||
                          _selectedSplit != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            HapticUtils.lightImpact();
                            setState(() {
                              _selectedGoal = null;
                              _selectedDifficulty = null;
                              _selectedSplit = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.x,
                                  size: 14,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Limpar',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError(theme)
                    : _filteredTemplates.isEmpty
                        ? _buildEmpty(theme)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredTemplates.length,
                            itemBuilder: (context, index) {
                              return _TemplateCard(
                                template: _filteredTemplates[index],
                                isDark: isDark,
                                onTap: () async {
                                  HapticUtils.selectionClick();
                                  await _selectTemplate(_filteredTemplates[index]);
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    ThemeData theme,
    bool isDark,
    String label,
    String? value,
    VoidCallback onTap,
  ) {
    final hasValue = value != null;

    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasValue
              ? AppColors.primary.withAlpha(30)
              : (isDark
                  ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                  : theme.colorScheme.surfaceContainerLow.withAlpha(200)),
          borderRadius: BorderRadius.circular(20),
          border: hasValue
              ? Border.all(color: AppColors.primary.withAlpha(100))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasValue ? value : label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: hasValue ? AppColors.primary : null,
                fontWeight: hasValue ? FontWeight.w600 : null,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              LucideIcons.chevronDown,
              size: 14,
              color: hasValue
                  ? AppColors.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalFilter(BuildContext context, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterSheet(
        title: 'Objetivo',
        options: [
          ('hypertrophy', 'Hipertrofia'),
          ('strength', 'Força'),
          ('fat_loss', 'Emagrecimento'),
          ('endurance', 'Resistência'),
          ('functional', 'Funcional'),
          ('general_fitness', 'Condicionamento'),
        ],
        selectedValue: _selectedGoal,
        onSelected: (value) {
          setState(() => _selectedGoal = value);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDifficultyFilter(BuildContext context, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterSheet(
        title: 'Nível',
        options: [
          ('beginner', 'Iniciante'),
          ('intermediate', 'Intermediário'),
          ('advanced', 'Avançado'),
        ],
        selectedValue: _selectedDifficulty,
        onSelected: (value) {
          setState(() => _selectedDifficulty = value);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showSplitFilter(BuildContext context, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FilterSheet(
        title: 'Divisão de Treino',
        options: [
          ('abc', 'ABC'),
          ('abcd', 'ABCD'),
          ('abcde', 'ABCDE'),
          ('push_pull_legs', 'Push/Pull/Legs'),
          ('upper_lower', 'Upper/Lower'),
          ('full_body', 'Full Body'),
        ],
        selectedValue: _selectedSplit,
        onSelected: (value) {
          setState(() => _selectedSplit = value);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildError(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar planos',
              style: theme.textTheme.bodyLarge,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTemplates,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasActiveFilters =>
      _selectedGoal != null ||
      _selectedDifficulty != null ||
      _selectedSplit != null ||
      _searchController.text.isNotEmpty;

  Widget _buildEmpty(ThemeData theme) {
    // Check if there are no templates at all, or just filtered out
    final noTemplatesExist = _templates.isEmpty;
    final hasFilters = _hasActiveFilters;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              noTemplatesExist ? LucideIcons.clipboardList : LucideIcons.search,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              noTemplatesExist
                  ? 'Nenhum plano disponível'
                  : 'Nenhum plano encontrado',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              noTemplatesExist
                  ? 'Você ainda não criou nenhum plano'
                  : 'Tente ajustar os filtros de busca',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (noTemplatesExist) ...[
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(LucideIcons.arrowLeft, size: 18),
                label: const Text('Voltar e criar do zero'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withAlpha(100)),
                ),
              ),
            ] else if (hasFilters) ...[
              OutlinedButton.icon(
                onPressed: () {
                  HapticUtils.lightImpact();
                  setState(() {
                    _selectedGoal = null;
                    _selectedDifficulty = null;
                    _selectedSplit = null;
                    _searchController.clear();
                  });
                },
                icon: const Icon(LucideIcons.x, size: 18),
                label: const Text('Limpar filtros'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error.withAlpha(100)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getGoalName(String goal) {
    switch (goal.toLowerCase()) {
      case 'hypertrophy':
        return 'Hipertrofia';
      case 'strength':
        return 'Força';
      case 'fat_loss':
        return 'Emagrecimento';
      case 'endurance':
        return 'Resistência';
      case 'functional':
        return 'Funcional';
      case 'general_fitness':
        return 'Condicionamento';
      default:
        return goal;
    }
  }

  String _getDifficultyName(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Iniciante';
      case 'intermediate':
        return 'Intermediário';
      case 'advanced':
        return 'Avançado';
      default:
        return difficulty;
    }
  }

  String _getSplitName(String splitType) {
    switch (splitType.toLowerCase()) {
      case 'abc':
        return 'ABC';
      case 'abcd':
        return 'ABCD';
      case 'abcde':
        return 'ABCDE';
      case 'push_pull_legs':
        return 'Push/Pull/Legs';
      case 'upper_lower':
        return 'Upper/Lower';
      case 'full_body':
        return 'Full Body';
      default:
        return splitType;
    }
  }
}

class _FilterSheet extends StatelessWidget {
  final String title;
  final List<(String, String)> options;
  final String? selectedValue;
  final Function(String?) onSelected;

  const _FilterSheet({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...options.map((option) {
            final isSelected = selectedValue == option.$1;
            return ListTile(
              title: Text(option.$2),
              trailing: isSelected
                  ? Icon(LucideIcons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                HapticUtils.selectionClick();
                onSelected(isSelected ? null : option.$1);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final Map<String, dynamic> template;
  final bool isDark;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = template['name'] as String? ?? 'Template';
    final goal = template['goal'] as String? ?? '';
    final difficulty = template['difficulty'] as String? ?? '';
    final splitType = template['split_type'] as String? ?? '';
    final workouts = (template['program_workouts'] as List<dynamic>?) ?? [];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.withAlpha(isDark ? 30 : 20),
              Colors.deepOrange.withAlpha(isDark ? 20 : 10),
            ],
          ),
          border: Border.all(
            color: Colors.orange.withAlpha(isDark ? 50 : 30),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.clipboard,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${workouts.length} treinos - ${_getSplitName(splitType)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Badge(label: _getGoalName(goal), color: AppColors.primary),
                _Badge(label: _getDifficultyName(difficulty), color: AppColors.secondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getGoalName(String goal) {
    switch (goal.toLowerCase()) {
      case 'hypertrophy':
        return 'Hipertrofia';
      case 'strength':
        return 'Força';
      case 'fat_loss':
        return 'Emagrecimento';
      case 'endurance':
        return 'Resistência';
      case 'functional':
        return 'Funcional';
      case 'general_fitness':
        return 'Condicionamento';
      default:
        return goal;
    }
  }

  String _getDifficultyName(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Iniciante';
      case 'intermediate':
        return 'Intermediário';
      case 'advanced':
        return 'Avançado';
      default:
        return difficulty;
    }
  }

  String _getSplitName(String splitType) {
    switch (splitType.toLowerCase()) {
      case 'abc':
        return 'ABC';
      case 'abcd':
        return 'ABCD';
      case 'abcde':
        return 'ABCDE';
      case 'push_pull_legs':
        return 'Push/Pull/Legs';
      case 'upper_lower':
        return 'Upper/Lower';
      case 'full_body':
        return 'Full Body';
      default:
        return splitType;
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
