import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/workout_service.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Provider for trainer's own templates
final trainerTemplatesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = WorkoutService();
  final templates = await service.getPlans(templatesOnly: true);
  return templates;
});

/// Provider for catalog templates
final catalogTemplatesProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = WorkoutService();
  final templates = await service.getCatalogTemplates();
  return templates;
});

/// Sheet for selecting a template to create a new plan
class TemplatePlanSheet extends ConsumerStatefulWidget {
  final String studentUserId;
  final String studentName;

  const TemplatePlanSheet({
    super.key,
    required this.studentUserId,
    required this.studentName,
  });

  @override
  ConsumerState<TemplatePlanSheet> createState() => _TemplatePlanSheetState();
}

class _TemplatePlanSheetState extends ConsumerState<TemplatePlanSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _useTemplate(Map<String, dynamic> template, {bool fromCatalog = false}) async {
    final templateId = template['id'] as String;
    final templateName = template['name'] as String? ?? 'Template';

    setState(() => _isLoading = true);

    try {
      String planIdToEdit;

      if (fromCatalog) {
        // Duplicate from catalog
        final service = WorkoutService();
        final newPlan = await service.duplicatePlan(
          templateId,
          newName: '$templateName (${widget.studentName})',
          fromCatalog: true,
        );
        planIdToEdit = newPlan['id'] as String;
      } else {
        // Duplicate trainer's own template
        final service = WorkoutService();
        final newPlan = await service.duplicatePlan(
          templateId,
          newName: '$templateName (${widget.studentName})',
        );
        planIdToEdit = newPlan['id'] as String;
      }

      if (mounted) {
        Navigator.pop(context);
        // Navigate to wizard with duplicated plan and pre-selected student
        context.push('/plans/wizard?edit=$planIdToEdit&studentId=${widget.studentUserId}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao usar template: $e'),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

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
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withAlpha(isDark ? 30 : 20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.layoutTemplate,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Templates de Plano',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Para ${widget.studentName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const LinearProgressIndicator(),
            ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar template...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                filled: true,
                fillColor: isDark ? AppColors.cardDark : AppColors.card,
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
          ),

          const SizedBox(height: 12),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppColors.primary.withAlpha(isDark ? 40 : 30),
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.user, size: 16),
                      SizedBox(width: 6),
                      Text('Meus Templates'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.store, size: 16),
                      SizedBox(width: 6),
                      Text('Catálogo'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // My Templates tab
                _buildTemplatesList(
                  ref.watch(trainerTemplatesProvider),
                  fromCatalog: false,
                  emptyMessage: 'Você ainda não tem templates',
                  emptySubMessage: 'Crie um plano e marque como template',
                ),
                // Catalog tab
                _buildTemplatesList(
                  ref.watch(catalogTemplatesProvider),
                  fromCatalog: true,
                  emptyMessage: 'Nenhum template no catálogo',
                  emptySubMessage: 'Em breve teremos mais opções',
                ),
              ],
            ),
          ),

          // Bottom padding
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }

  Widget _buildTemplatesList(
    AsyncValue<List<Map<String, dynamic>>> templatesAsync, {
    required bool fromCatalog,
    required String emptyMessage,
    required String emptySubMessage,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return templatesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: AppColors.destructive,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar templates',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                if (fromCatalog) {
                  ref.invalidate(catalogTemplatesProvider);
                } else {
                  ref.invalidate(trainerTemplatesProvider);
                }
              },
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
      data: (templates) {
        // Filter by search
        final search = _searchController.text.toLowerCase();
        final filteredTemplates = search.isEmpty
            ? templates
            : templates.where((t) {
                final name = (t['name'] as String? ?? '').toLowerCase();
                final goal = (t['goal'] as String? ?? '').toLowerCase();
                return name.contains(search) || goal.contains(search);
              }).toList();

        if (filteredTemplates.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.layoutTemplate,
                  size: 48,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                const SizedBox(height: 16),
                Text(
                  search.isEmpty ? emptyMessage : 'Nenhum template encontrado',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  search.isEmpty ? emptySubMessage : 'Tente uma busca diferente',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredTemplates.length,
          itemBuilder: (context, index) {
            final template = filteredTemplates[index];
            return _TemplateCard(
              template: template,
              isDark: isDark,
              fromCatalog: fromCatalog,
              isLoading: _isLoading,
              onTap: () => _useTemplate(template, fromCatalog: fromCatalog),
            );
          },
        );
      },
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final Map<String, dynamic> template;
  final bool isDark;
  final bool fromCatalog;
  final bool isLoading;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isDark,
    required this.fromCatalog,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = template['name'] as String? ?? 'Template';
    final goal = template['goal'] as String?;
    final difficulty = template['difficulty'] as String?;
    final splitType = template['split_type'] as String?;
    final workoutCount = template['workout_count'] as int? ??
        (template['workouts'] as List?)?.length ??
        (template['plan_workouts'] as List?)?.length ??
        0;
    final authorName = template['author_name'] as String?;
    final usageCount = template['usage_count'] as int?;

    return GestureDetector(
      onTap: isLoading ? null : () {
        HapticUtils.selectionClick();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (fromCatalog ? AppColors.secondary : AppColors.primary)
                        .withAlpha(isDark ? 30 : 20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    fromCatalog ? LucideIcons.store : LucideIcons.layoutTemplate,
                    color: fromCatalog ? AppColors.secondary : AppColors.primary,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (goal != null)
                        Text(
                          goal,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

            const SizedBox(height: 10),

            // Tags row
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (difficulty != null)
                  _Tag(label: difficulty, isDark: isDark),
                if (splitType != null)
                  _Tag(label: _formatSplitType(splitType), isDark: isDark),
                _Tag(
                  label: '$workoutCount treino${workoutCount == 1 ? '' : 's'}',
                  isDark: isDark,
                ),
                if (fromCatalog && authorName != null)
                  _Tag(
                    label: 'Por $authorName',
                    isDark: isDark,
                    icon: LucideIcons.user,
                  ),
                if (fromCatalog && usageCount != null && usageCount > 0)
                  _Tag(
                    label: '$usageCount uso${usageCount == 1 ? '' : 's'}',
                    isDark: isDark,
                    icon: LucideIcons.download,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatSplitType(String splitType) {
    switch (splitType.toLowerCase()) {
      case 'full_body':
        return 'Full Body';
      case 'upper_lower':
        return 'Upper/Lower';
      case 'push_pull_legs':
        return 'Push/Pull/Legs';
      case 'abc':
        return 'ABC';
      case 'abcd':
        return 'ABCD';
      case 'abcde':
        return 'ABCDE';
      default:
        return splitType;
    }
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final bool isDark;
  final IconData? icon;

  const _Tag({
    required this.label,
    required this.isDark,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.mutedDark : AppColors.muted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
