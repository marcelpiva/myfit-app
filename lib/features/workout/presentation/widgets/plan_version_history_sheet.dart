import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Shows the version history for a plan assignment
void showPlanVersionHistorySheet(
  BuildContext context,
  String assignmentId,
  int currentVersion,
  List<Map<String, dynamic>> versions,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => PlanVersionHistorySheet(
      assignmentId: assignmentId,
      currentVersion: currentVersion,
      versions: versions,
    ),
  );
}

class PlanVersionHistorySheet extends ConsumerStatefulWidget {
  final String assignmentId;
  final int currentVersion;
  final List<Map<String, dynamic>> versions;

  const PlanVersionHistorySheet({
    super.key,
    required this.assignmentId,
    required this.currentVersion,
    required this.versions,
  });

  @override
  ConsumerState<PlanVersionHistorySheet> createState() =>
      _PlanVersionHistorySheetState();
}

class _PlanVersionHistorySheetState
    extends ConsumerState<PlanVersionHistorySheet> {
  int? _selectedVersionA;
  int? _selectedVersionB;
  bool _showingDiff = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.history,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Histórico de Versões',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Versão atual: v${widget.currentVersion}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedVersionA != null && _selectedVersionB != null)
                  TextButton(
                    onPressed: () {
                      setState(() => _showingDiff = !_showingDiff);
                    },
                    child: Text(_showingDiff ? 'Lista' : 'Comparar'),
                  ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),

          // Content
          Expanded(
            child: _showingDiff && _selectedVersionA != null && _selectedVersionB != null
                ? _buildDiffView(context, isDark)
                : _buildVersionList(context, isDark),
          ),

          // Bottom padding
          SizedBox(height: bottomPadding + 16),
        ],
      ),
    );
  }

  Widget _buildVersionList(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    if (widget.versions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.fileCheck,
              size: 48,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              'Sem alterações registradas',
              style: theme.textTheme.titleSmall?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este é o plano original',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.versions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final version = widget.versions[index];
        final versionNum = version['version'] as int? ?? 0;
        final changedAt = version['changed_at'] as String?;
        final changedByName = version['changed_by_name'] as String?;
        final changeDescription = version['change_description'] as String?;

        final isSelected = _selectedVersionA == versionNum ||
                          _selectedVersionB == versionNum;

        DateTime? date;
        if (changedAt != null) {
          date = DateTime.tryParse(changedAt);
        }

        return GestureDetector(
          onTap: () {
            HapticUtils.selectionClick();
            _selectVersion(versionNum);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withAlpha(15)
                  : (isDark ? AppColors.cardDark : AppColors.card),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.borderDark : AppColors.border),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.mutedDark : AppColors.muted),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'v$versionNum',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        changeDescription ?? 'Atualização do plano',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (changedByName != null) ...[
                            Icon(
                              LucideIcons.user,
                              size: 12,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              changedByName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (date != null) ...[
                            Icon(
                              LucideIcons.calendar,
                              size: 12,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yy HH:mm').format(date.toLocal()),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
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
                    child: Center(
                      child: Text(
                        _selectedVersionA == versionNum ? 'A' : 'B',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectVersion(int version) {
    setState(() {
      if (_selectedVersionA == version) {
        _selectedVersionA = null;
      } else if (_selectedVersionB == version) {
        _selectedVersionB = null;
      } else if (_selectedVersionA == null) {
        _selectedVersionA = version;
      } else if (_selectedVersionB == null) {
        _selectedVersionB = version;
      } else {
        // Both selected, replace A
        _selectedVersionA = version;
      }
    });
  }

  Widget _buildDiffView(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    // Find the snapshots for selected versions
    final versionA = widget.versions.firstWhere(
      (v) => v['version'] == _selectedVersionA,
      orElse: () => {},
    );
    final versionB = widget.versions.firstWhere(
      (v) => v['version'] == _selectedVersionB,
      orElse: () => {},
    );

    final snapshotA = versionA['snapshot'] as Map<String, dynamic>?;
    final snapshotB = versionB['snapshot'] as Map<String, dynamic>?;

    if (snapshotA == null || snapshotB == null) {
      return Center(
        child: Text(
          'Erro ao carregar versões',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    // Compute differences
    final diff = _computeDiff(snapshotA, snapshotB);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header showing comparison
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildVersionBadge('v$_selectedVersionA', AppColors.info),
                const SizedBox(width: 16),
                Icon(
                  LucideIcons.arrowRight,
                  size: 20,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                const SizedBox(width: 16),
                _buildVersionBadge('v$_selectedVersionB', AppColors.success),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Changes list
          if (diff.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    LucideIcons.checkCircle,
                    size: 48,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sem diferenças encontradas',
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
            )
          else
            ...diff.map((change) => _buildChangeItem(context, change, isDark)),
        ],
      ),
    );
  }

  Widget _buildVersionBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildChangeItem(BuildContext context, Map<String, dynamic> change, bool isDark) {
    final theme = Theme.of(context);
    final type = change['type'] as String;
    final description = change['description'] as String;

    Color color;
    IconData icon;

    switch (type) {
      case 'added':
        color = AppColors.success;
        icon = LucideIcons.plus;
        break;
      case 'removed':
        color = AppColors.destructive;
        icon = LucideIcons.minus;
        break;
      case 'modified':
      default:
        color = AppColors.warning;
        icon = LucideIcons.pencil;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _computeDiff(
    Map<String, dynamic> snapshotA,
    Map<String, dynamic> snapshotB,
  ) {
    final diff = <Map<String, dynamic>>[];

    // Compare plan name
    final nameA = snapshotA['name'] as String?;
    final nameB = snapshotB['name'] as String?;
    if (nameA != nameB) {
      diff.add({
        'type': 'modified',
        'description': 'Nome alterado: "$nameA" → "$nameB"',
      });
    }

    // Compare goal
    final goalA = snapshotA['goal'] as String?;
    final goalB = snapshotB['goal'] as String?;
    if (goalA != goalB) {
      diff.add({
        'type': 'modified',
        'description': 'Objetivo alterado: $goalA → $goalB',
      });
    }

    // Compare workouts
    final workoutsA = (snapshotA['workouts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final workoutsB = (snapshotB['workouts'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final workoutIdsA = workoutsA.map((w) => w['id']).toSet();
    final workoutIdsB = workoutsB.map((w) => w['id']).toSet();

    // Added workouts
    for (final id in workoutIdsB.difference(workoutIdsA)) {
      final workout = workoutsB.firstWhere((w) => w['id'] == id);
      diff.add({
        'type': 'added',
        'description': 'Treino "${workout['label'] ?? workout['name']}" adicionado',
      });
    }

    // Removed workouts
    for (final id in workoutIdsA.difference(workoutIdsB)) {
      final workout = workoutsA.firstWhere((w) => w['id'] == id);
      diff.add({
        'type': 'removed',
        'description': 'Treino "${workout['label'] ?? workout['name']}" removido',
      });
    }

    // Modified workouts - compare exercises
    for (final id in workoutIdsA.intersection(workoutIdsB)) {
      final workoutA = workoutsA.firstWhere((w) => w['id'] == id);
      final workoutB = workoutsB.firstWhere((w) => w['id'] == id);

      final exercisesA = (workoutA['exercises'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final exercisesB = (workoutB['exercises'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      if (exercisesA.length != exercisesB.length) {
        diff.add({
          'type': 'modified',
          'description': 'Treino "${workoutA['label']}": ${exercisesA.length} → ${exercisesB.length} exercícios',
        });
      }
    }

    return diff;
  }
}
