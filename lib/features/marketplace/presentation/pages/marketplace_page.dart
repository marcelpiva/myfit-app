import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/workout_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Provider for catalog templates (public programs from other users and system)
final catalogProgramsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = WorkoutService();
  return service.getCatalogTemplates();
});

// Provider for imported template IDs (source_template_id from user's programs)
final importedTemplateIdsProvider = FutureProvider.autoDispose<Set<String>>((ref) async {
  final service = WorkoutService();
  final programs = await service.getPrograms(templatesOnly: false);
  // Extract source_template_id from programs that were imported
  final importedIds = programs
      .where((p) => p['source_template_id'] != null)
      .map((p) => p['source_template_id'] as String)
      .toSet();
  return importedIds;
});

class MarketplacePage extends ConsumerStatefulWidget {
  const MarketplacePage({super.key});

  @override
  ConsumerState<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Filters
  String? _selectedGoal;
  String? _selectedDifficulty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterPrograms(List<Map<String, dynamic>> programs) {
    var filtered = programs;

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final name = (p['name'] as String? ?? '').toLowerCase();
        final description = (p['description'] as String? ?? '').toLowerCase();
        return name.contains(_searchQuery.toLowerCase()) ||
            description.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by goal
    if (_selectedGoal != null) {
      filtered = filtered.where((p) => p['goal'] == _selectedGoal).toList();
    }

    // Filter by difficulty
    if (_selectedDifficulty != null) {
      filtered = filtered.where((p) => p['difficulty'] == _selectedDifficulty).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final catalogAsync = ref.watch(catalogProgramsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withAlpha(isDark ? 15 : 10),
              AppColors.secondary.withAlpha(isDark ? 12 : 8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticUtils.lightImpact();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark.withAlpha(150)
                                  : AppColors.card.withAlpha(200),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Catalogo de Programas',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Programas prontos para importar',
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

                    const SizedBox(height: 20),

                    // Search Bar
                    _buildSearchBar(isDark),

                    const SizedBox(height: 12),

                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            'Objetivo',
                            _selectedGoal != null ? _getGoalDisplay(_selectedGoal!) : null,
                            () => _showGoalFilter(context, isDark),
                            isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            'Nivel',
                            _selectedDifficulty != null
                                ? _getDifficultyDisplay(_selectedDifficulty!)
                                : null,
                            () => _showDifficultyFilter(context, isDark),
                            isDark,
                          ),
                          if (_selectedGoal != null || _selectedDifficulty != null) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                HapticUtils.lightImpact();
                                setState(() {
                                  _selectedGoal = null;
                                  _selectedDifficulty = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.destructive.withAlpha(20),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.x, size: 14, color: AppColors.destructive),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Limpar',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.destructive,
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
                child: catalogAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => _buildErrorState(error.toString(), isDark),
                  data: (programs) {
                    final filtered = _filterPrograms(programs);

                    if (filtered.isEmpty) {
                      return _buildEmptyState(isDark, programs.isEmpty);
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(catalogProgramsProvider);
                        ref.invalidate(importedTemplateIdsProvider);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final program = filtered[index];
                          return _CompactProgramCard(
                            program: program,
                            isDark: isDark,
                            onTap: () => _showProgramDetail(context, program),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            LucideIcons.search,
            size: 18,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar programas...',
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  LucideIcons.x,
                  size: 18,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, VoidCallback onTap, bool isDark) {
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
                  ? AppColors.cardDark.withAlpha(150)
                  : AppColors.card.withAlpha(200)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasValue
                ? AppColors.primary.withAlpha(100)
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasValue ? value : label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: hasValue ? FontWeight.w600 : FontWeight.w500,
                color: hasValue
                    ? AppColors.primary
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              LucideIcons.chevronDown,
              size: 14,
              color: hasValue
                  ? AppColors.primary
                  : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalFilter(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FilterSheet(
        title: 'Objetivo',
        options: [
          ('hypertrophy', 'Hipertrofia'),
          ('strength', 'Forca'),
          ('fat_loss', 'Emagrecimento'),
          ('endurance', 'Resistencia'),
          ('functional', 'Funcional'),
        ],
        selectedValue: _selectedGoal,
        onSelected: (value) {
          setState(() => _selectedGoal = value);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showDifficultyFilter(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FilterSheet(
        title: 'Nivel',
        options: [
          ('beginner', 'Iniciante'),
          ('intermediate', 'Intermediario'),
          ('advanced', 'Avancado'),
        ],
        selectedValue: _selectedDifficulty,
        onSelected: (value) {
          setState(() => _selectedDifficulty = value);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool noPrograms) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              noPrograms ? LucideIcons.clipboardList : LucideIcons.search,
              size: 64,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              noPrograms ? 'Nenhum programa disponivel' : 'Nenhum programa encontrado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              noPrograms
                  ? 'Ainda nao ha programas no catalogo'
                  : 'Tente ajustar os filtros de busca',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: AppColors.destructive,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(catalogProgramsProvider),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProgramDetail(BuildContext context, Map<String, dynamic> program) {
    HapticUtils.lightImpact();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ProgramDetailSheet(
        program: program,
        onImport: () {
          Navigator.pop(ctx);
          _importProgram(context, program);
        },
      ),
    );
  }

  Future<void> _importProgram(BuildContext context, Map<String, dynamic> program) async {
    final programId = program['id'] as String?;
    final programName = program['name'] as String? ?? 'Programa';
    final hasDiet = program['has_diet'] as bool? ?? false;
    final createdById = program['created_by_id'] as String?;
    if (programId == null) return;

    // Prevent importing own programs
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null && createdById == currentUser.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voce nao pode importar seu proprio programa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final nameController = TextEditingController(text: programName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar aos Meus Templates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deseja adicionar "$programName" aos seus templates?'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nome do template',
                hintText: 'Digite o nome do template',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.dumbbell, size: 16, color: Theme.of(ctx).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text('Programa de treino completo'),
                    ],
                  ),
                  if (hasDiet) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(LucideIcons.utensils, size: 16, color: Theme.of(ctx).colorScheme.secondary),
                        const SizedBox(width: 8),
                        const Text('Inclui plano alimentar'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'O template ficara disponivel em "Meus Programas" para voce usar com seus alunos.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
            icon: const Icon(LucideIcons.download, size: 18),
            label: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && context.mounted) {
      try {
        final service = WorkoutService();
        // Duplicate the program from catalog (tracks source_template_id)
        final newProgram = await service.duplicateProgram(
          programId,
          newName: newName,
          fromCatalog: true,
        );
        final newProgramId = newProgram['id'] as String?;

        // Mark as template (not navigate to wizard)
        if (newProgramId != null) {
          await service.updateProgram(newProgramId, isTemplate: true);
        }

        // Invalidate the providers to refresh the lists
        ref.invalidate(catalogProgramsProvider);
        ref.invalidate(importedTemplateIdsProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Template "$newName" adicionado com sucesso!'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Ver Templates',
                textColor: Colors.white,
                onPressed: () {
                  context.push(RouteNames.trainerPrograms);
                },
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao adicionar template: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getGoalDisplay(String goal) {
    switch (goal.toLowerCase()) {
      case 'hypertrophy':
        return 'Hipertrofia';
      case 'strength':
        return 'Forca';
      case 'fat_loss':
        return 'Emagrecimento';
      case 'endurance':
        return 'Resistencia';
      case 'functional':
        return 'Funcional';
      default:
        return goal;
    }
  }

  String _getDifficultyDisplay(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Iniciante';
      case 'intermediate':
        return 'Intermediario';
      case 'advanced':
        return 'Avancado';
      default:
        return difficulty;
    }
  }
}

// ==================== Program Card ====================

class _ProgramCard extends ConsumerWidget {
  final Map<String, dynamic> program;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onImport;

  const _ProgramCard({
    required this.program,
    required this.isDark,
    required this.onTap,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final name = program['name'] as String? ?? 'Programa';
    final goal = program['goal'] as String? ?? '';
    final difficulty = program['difficulty'] as String? ?? '';
    final workoutCount = program['workout_count'] as int? ?? 0;
    final creatorName = program['creator_name'] as String?;
    final hasDiet = program['has_diet'] as bool? ?? false;
    final programId = program['id'] as String?;

    // Check if this program has been imported
    final importedIdsAsync = ref.watch(importedTemplateIdsProvider);
    final isImported = importedIdsAsync.maybeWhen(
      data: (ids) => programId != null && ids.contains(programId),
      orElse: () => false,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Stack(
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withAlpha(isDark ? 40 : 30),
                        AppColors.secondary.withAlpha(isDark ? 30 : 20),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.dumbbell,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                // Diet badge
                if (hasDiet)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(220),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.utensils, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          const Text(
                            'Dieta',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Imported badge
                if (isImported)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(220),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.check, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          const Text(
                            'Importado',
                            style: TextStyle(
                              fontSize: 10,
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

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (creatorName != null)
                      Text(
                        'por $creatorName',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                          fontSize: 11,
                        ),
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        _Badge(label: _getGoalDisplay(goal)),
                        const SizedBox(width: 4),
                        _Badge(label: _getDifficultyDisplay(difficulty)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.clipboardList,
                          size: 12,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$workoutCount treinos',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Import button (changes based on import status)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                width: double.infinity,
                child: isImported
                    ? OutlinedButton.icon(
                        onPressed: null,
                        icon: Icon(LucideIcons.check, size: 14, color: AppColors.success),
                        label: Text('Importado', style: TextStyle(fontSize: 12, color: AppColors.success)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(0, 32),
                          side: BorderSide(color: AppColors.success),
                        ),
                      )
                    : FilledButton.icon(
                        onPressed: () {
                          HapticUtils.lightImpact();
                          onImport();
                        },
                        icon: const Icon(LucideIcons.download, size: 14),
                        label: const Text('Importar', style: TextStyle(fontSize: 12)),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(0, 32),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGoalDisplay(String goal) {
    switch (goal.toLowerCase()) {
      case 'hypertrophy':
        return 'Hipertrofia';
      case 'strength':
        return 'Forca';
      case 'fat_loss':
        return 'Emagrecer';
      default:
        return goal.isNotEmpty ? goal.substring(0, 1).toUpperCase() + goal.substring(1) : '';
    }
  }

  String _getDifficultyDisplay(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Iniciante';
      case 'intermediate':
        return 'Interm.';
      case 'advanced':
        return 'Avancado';
      default:
        return difficulty;
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ==================== Compact Program Card (Spotify-style) ====================

class _CompactProgramCard extends ConsumerWidget {
  final Map<String, dynamic> program;
  final bool isDark;
  final VoidCallback onTap;

  const _CompactProgramCard({
    required this.program,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final name = program['name'] as String? ?? 'Programa';
    final goal = program['goal'] as String? ?? '';
    final difficulty = program['difficulty'] as String? ?? '';
    final workoutCount = program['workout_count'] as int? ?? 0;
    final creatorName = program['creator_name'] as String?;
    final programId = program['id'] as String?;
    final createdById = program['created_by_id'] as String?;

    // Check if this program belongs to the current user
    final currentUser = ref.watch(currentUserProvider);
    final isOwned = currentUser != null && createdById == currentUser.id;

    // Check if this program has been imported
    final importedIdsAsync = ref.watch(importedTemplateIdsProvider);
    final isImported = importedIdsAsync.maybeWhen(
      data: (ids) => programId != null && ids.contains(programId),
      orElse: () => false,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOwned
                    ? AppColors.primary.withAlpha(100)
                    : (isDark ? AppColors.borderDark : AppColors.border),
              ),
            ),
            child: Row(
              children: [
                // Icon/Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withAlpha(isDark ? 50 : 40),
                        AppColors.secondary.withAlpha(isDark ? 40 : 30),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.dumbbell,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title row with owned/imported badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isOwned)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(30),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.crown,
                                    size: 10,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Meu Programa',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (isImported)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withAlpha(30),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.check,
                                    size: 10,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Importado',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Subtitle with creator and stats
                      Row(
                        children: [
                          if (creatorName != null) ...[
                            Icon(
                              LucideIcons.user,
                              size: 11,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              creatorName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForeground,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForeground,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          Text(
                            '$workoutCount treinos',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Tags row
                      Row(
                        children: [
                          _CompactTag(
                            label: _getGoalDisplay(goal),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 6),
                          _CompactTag(
                            label: _getDifficultyDisplay(difficulty),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
                const SizedBox(width: 8),
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
        ),
      ),
    );
  }

  String _getGoalDisplay(String goal) {
    switch (goal.toLowerCase()) {
      case 'hypertrophy':
        return 'Hipertrofia';
      case 'strength':
        return 'Forca';
      case 'fat_loss':
        return 'Emagrecer';
      case 'endurance':
        return 'Resistencia';
      case 'functional':
        return 'Funcional';
      default:
        return goal.isNotEmpty
            ? goal.substring(0, 1).toUpperCase() + goal.substring(1)
            : '';
    }
  }

  String _getDifficultyDisplay(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Iniciante';
      case 'intermediate':
        return 'Intermediario';
      case 'advanced':
        return 'Avancado';
      default:
        return difficulty;
    }
  }
}

class _CompactTag extends StatelessWidget {
  final String label;
  final bool isDark;

  const _CompactTag({
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(isDark ? 25 : 15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ==================== Filter Sheet ====================

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
              trailing: isSelected ? Icon(LucideIcons.check, color: AppColors.primary) : null,
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

// ==================== Program Detail Sheet ====================

class _ProgramDetailSheet extends ConsumerWidget {
  final Map<String, dynamic> program;
  final VoidCallback onImport;

  const _ProgramDetailSheet({
    required this.program,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final name = program['name'] as String? ?? 'Programa';
    final description = program['description'] as String?;
    final goal = program['goal'] as String? ?? '';
    final difficulty = program['difficulty'] as String? ?? '';
    final splitType = program['split_type'] as String? ?? '';
    final durationWeeks = program['duration_weeks'] as int?;
    final workoutCount = program['workout_count'] as int? ?? 0;
    final creatorName = program['creator_name'] as String?;
    final programId = program['id'] as String?;
    final createdById = program['created_by_id'] as String?;

    // Check if this program belongs to the current user
    final currentUser = ref.watch(currentUserProvider);
    final isOwned = currentUser != null && createdById == currentUser.id;

    // Check if this program has been imported
    final importedIdsAsync = ref.watch(importedTemplateIdsProvider);
    final isImported = importedIdsAsync.maybeWhen(
      data: (ids) => programId != null && ids.contains(programId),
      orElse: () => false,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with owned badge
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withAlpha(40),
                              AppColors.secondary.withAlpha(30),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          LucideIcons.dumbbell,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    name,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isOwned) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(30),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          LucideIcons.crown,
                                          size: 12,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Meu',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (creatorName != null)
                              Text(
                                'por $creatorName',
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

                  const SizedBox(height: 20),

                  // Stats
                  Row(
                    children: [
                      _StatChip(
                        icon: LucideIcons.target,
                        label: _getGoalDisplay(goal),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        icon: LucideIcons.gauge,
                        label: _getDifficultyDisplay(difficulty),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _StatChip(
                        icon: LucideIcons.layoutGrid,
                        label: _getSplitDisplay(splitType),
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Info row
                  Row(
                    children: [
                      Icon(
                        LucideIcons.clipboardList,
                        size: 16,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$workoutCount treinos',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                      if (durationWeeks != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          LucideIcons.calendar,
                          size: 16,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$durationWeeks semanas',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Descricao',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom button
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              width: double.infinity,
              child: isOwned
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: Icon(LucideIcons.crown, color: AppColors.primary),
                      label: Text(
                        'Este e o seu programa',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary),
                      ),
                    )
                  : isImported
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: Icon(LucideIcons.check, color: AppColors.success),
                          label: Text(
                            'Ja importado para Meus Programas',
                            style: TextStyle(color: AppColors.success),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppColors.success),
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: onImport,
                          icon: const Icon(LucideIcons.download),
                          label: const Text('Importar para Meus Programas'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGoalDisplay(String goal) {
    switch (goal.toLowerCase()) {
      case 'hypertrophy':
        return 'Hipertrofia';
      case 'strength':
        return 'Forca';
      case 'fat_loss':
        return 'Emagrecimento';
      case 'endurance':
        return 'Resistencia';
      case 'functional':
        return 'Funcional';
      default:
        return goal;
    }
  }

  String _getDifficultyDisplay(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Iniciante';
      case 'intermediate':
        return 'Intermediario';
      case 'advanced':
        return 'Avancado';
      default:
        return difficulty;
    }
  }

  String _getSplitDisplay(String splitType) {
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
