import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/cache/cache.dart';
import '../../../../core/services/workout_service.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../providers/student_plans_provider.dart';

/// Provider for trainer's plans list
final trainerPlansListProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = WorkoutService();
  final plans = await service.getPlans();
  return plans;
});

/// Translate difficulty enum value to Portuguese
String _translateDifficulty(String difficulty) {
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

/// Translate split type enum value to Portuguese
String _translateSplitType(String splitType) {
  switch (splitType.toLowerCase()) {
    case 'abc':
      return 'ABC';
    case 'abcd':
      return 'ABCD';
    case 'abcde':
      return 'ABCDE';
    case 'fullbody':
    case 'full_body':
      return 'Full Body';
    case 'upper_lower':
      return 'Upper/Lower';
    case 'push_pull_legs':
    case 'ppl':
      return 'Push/Pull/Legs';
    case 'custom':
      return 'Personalizado';
    default:
      return splitType.toUpperCase();
  }
}

/// Translate goal/objective enum value to Portuguese
String _translateGoal(String goal) {
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

/// Sheet for assigning an existing plan to a student
class AssignExistingPlanSheet extends ConsumerStatefulWidget {
  final String studentUserId;
  final String studentName;

  const AssignExistingPlanSheet({
    super.key,
    required this.studentUserId,
    required this.studentName,
  });

  @override
  ConsumerState<AssignExistingPlanSheet> createState() => _AssignExistingPlanSheetState();
}

class _AssignExistingPlanSheetState extends ConsumerState<AssignExistingPlanSheet> {
  final _workoutService = WorkoutService();
  final _searchController = TextEditingController();

  String? _selectedPlanId;
  String? _selectedPlanName;
  int? _selectedPlanDurationWeeks;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isLoading = false;
  String? _error;

  /// Calculate end date based on start date and plan duration
  void _updateEndDateFromDuration() {
    setState(() {
      if (_selectedPlanDurationWeeks != null && _selectedPlanDurationWeeks! > 0) {
        _endDate = _startDate.add(Duration(days: _selectedPlanDurationWeeks! * 7));
      } else {
        // Clear end date if plan has no defined duration
        _endDate = null;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _assignPlan() async {
    if (_selectedPlanId == null) return;

    // Check if student already has an active plan
    final plansState = ref.read(studentPlansProvider(widget.studentUserId));

    // Check if selected plan is already assigned (active or scheduled)
    final isAlreadyAssigned = _isPlanAlreadyAssigned(plansState, _selectedPlanId!);
    if (isAlreadyAssigned) {
      _showDuplicatePlanError();
      return;
    }

    if (plansState.hasCurrentPlan) {
      // Show conflict dialog
      final action = await _showConflictDialog(plansState);
      if (action == null) return; // User cancelled

      await _executeAssignmentWithAction(action, plansState);
    } else {
      // No conflict, assign directly
      await _executeAssignment();
    }
  }

  /// Check if a plan is already assigned to the student (active or scheduled)
  bool _isPlanAlreadyAssigned(StudentPlansState state, String planId) {
    // Check in active plans
    for (final assignment in state.activePlans) {
      if (assignment['plan_id'] == planId) {
        return true;
      }
    }
    // Check in scheduled plans
    for (final assignment in state.scheduledPlans) {
      if (assignment['plan_id'] == planId) {
        return true;
      }
    }
    return false;
  }

  /// Show error when trying to assign a plan that's already assigned
  void _showDuplicatePlanError() {
    HapticUtils.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              LucideIcons.alertCircle,
              color: AppColors.destructive,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Plano já atribuído'),
            ),
          ],
        ),
        content: Text(
          'O plano "$_selectedPlanName" já está atribuído a este aluno.\n\n'
          'Se deseja substituí-lo, primeiro encerre a atribuição atual na aba de planos.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  /// Show dialog when student already has an active plan
  Future<_ConflictAction?> _showConflictDialog(StudentPlansState plansState) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentPlanName = plansState.currentPlanName ?? 'Plano atual';
    final currentEndDateStr = plansState.currentAssignment?['end_date'] as String?;
    String endDateDisplay = '';
    if (currentEndDateStr != null) {
      try {
        final date = DateTime.parse(currentEndDateStr);
        endDateDisplay = ' (até ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')})';
      } catch (_) {}
    }

    return showDialog<_ConflictAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              LucideIcons.alertTriangle,
              color: AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Plano ativo existente'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Este aluno já possui um plano ativo:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.muted.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.clipboardList,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$currentPlanName$endDateDisplay',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'O que deseja fazer?',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ConflictOptionButton(
                icon: LucideIcons.replace,
                label: 'Substituir plano atual',
                description: 'Encerra o plano atual e ativa o novo',
                isDark: isDark,
                onTap: () => Navigator.pop(ctx, _ConflictAction.replace),
              ),
              const SizedBox(height: 8),
              _ConflictOptionButton(
                icon: LucideIcons.layers,
                label: 'Adicionar como complementar',
                description: 'Ambos os planos ficam ativos',
                isDark: isDark,
                onTap: () => Navigator.pop(ctx, _ConflictAction.addComplementary),
              ),
              if (currentEndDateStr != null) ...[
                const SizedBox(height: 8),
                _ConflictOptionButton(
                  icon: LucideIcons.calendarPlus,
                  label: 'Agendar para depois',
                  description: 'Inicia quando o plano atual terminar',
                  isDark: isDark,
                  onTap: () => Navigator.pop(ctx, _ConflictAction.scheduleAfter),
                ),
              ],
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Execute assignment based on conflict resolution action
  Future<void> _executeAssignmentWithAction(
    _ConflictAction action,
    StudentPlansState plansState,
  ) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      switch (action) {
        case _ConflictAction.replace:
          // First deactivate the current plan
          if (plansState.currentAssignmentId != null) {
            await _workoutService.updatePlanAssignment(
              plansState.currentAssignmentId!,
              isActive: false,
              endDate: DateTime.now(),
            );
          }
          // Then assign the new plan
          await _workoutService.createPlanAssignment(
            planId: _selectedPlanId!,
            studentId: widget.studentUserId,
            startDate: _startDate,
            endDate: _endDate,
          );

        case _ConflictAction.addComplementary:
          // Just add the new plan without deactivating the current one
          await _workoutService.createPlanAssignment(
            planId: _selectedPlanId!,
            studentId: widget.studentUserId,
            startDate: _startDate,
            endDate: _endDate,
          );

        case _ConflictAction.scheduleAfter:
          // Schedule the new plan to start after current plan ends
          final currentEndDateStr = plansState.currentAssignment?['end_date'] as String?;
          DateTime newStartDate = _startDate;
          DateTime? newEndDate = _endDate;

          if (currentEndDateStr != null) {
            try {
              final currentEndDate = DateTime.parse(currentEndDateStr);
              newStartDate = currentEndDate.add(const Duration(days: 1));

              // Recalculate end date if plan has duration
              if (_selectedPlanDurationWeeks != null && _selectedPlanDurationWeeks! > 0) {
                newEndDate = newStartDate.add(Duration(days: _selectedPlanDurationWeeks! * 7));
              }
            } catch (_) {}
          }

          await _workoutService.createPlanAssignment(
            planId: _selectedPlanId!,
            studentId: widget.studentUserId,
            startDate: newStartDate,
            endDate: newEndDate,
          );
      }

      // Emit cache event to refresh student's dashboard and plan lists
      ref.read(cacheEventEmitterProvider).planAssigned(
            _selectedPlanId!,
            studentId: widget.studentUserId,
          );

      // Also invalidate specific student plans provider for immediate update
      ref.invalidate(studentPlansProvider(widget.studentUserId));

      if (mounted) {
        Navigator.pop(context, true);

        String message;
        switch (action) {
          case _ConflictAction.replace:
            message = 'Plano substituído com sucesso';
          case _ConflictAction.addComplementary:
            message = '$_selectedPlanName adicionado como complementar';
          case _ConflictAction.scheduleAfter:
            message = '$_selectedPlanName agendado para após o plano atual';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Execute direct assignment (no conflict)
  Future<void> _executeAssignment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _workoutService.createPlanAssignment(
        planId: _selectedPlanId!,
        studentId: widget.studentUserId,
        startDate: _startDate,
        endDate: _endDate,
      );

      // Emit cache event to refresh student's dashboard and plan lists
      ref.read(cacheEventEmitterProvider).planAssigned(
            _selectedPlanId!,
            studentId: widget.studentUserId,
          );

      // Also invalidate specific student plans provider for immediate update
      ref.invalidate(studentPlansProvider(widget.studentUserId));

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('$_selectedPlanName atribuído a ${widget.studentName}'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final plansAsync = ref.watch(trainerPlansListProvider);
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                    color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.fileSymlink,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atribuir Plano Existente',
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

          // Error message
          if (_error != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.destructive.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    color: AppColors.destructive,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: AppColors.destructive),
                    ),
                  ),
                ],
              ),
            ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar plano...',
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

          // Plans list
          Expanded(
            child: plansAsync.when(
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
                      'Erro ao carregar planos',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(trainerPlansListProvider),
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
              data: (plans) {
                // Filter plans by search
                final search = _searchController.text.toLowerCase();
                final filteredPlans = search.isEmpty
                    ? plans
                    : plans.where((p) {
                        final name = (p['name'] as String? ?? '').toLowerCase();
                        final objective = (p['objective'] as String? ?? '').toLowerCase();
                        return name.contains(search) || objective.contains(search);
                      }).toList();

                if (filteredPlans.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.clipboardList,
                          size: 48,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          search.isEmpty
                              ? 'Nenhum plano criado'
                              : 'Nenhum plano encontrado',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          search.isEmpty
                              ? 'Crie um plano primeiro para atribuir'
                              : 'Tente uma busca diferente',
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

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredPlans.length,
                  itemBuilder: (context, index) {
                    final plan = filteredPlans[index];
                    final planId = plan['id'] as String;
                    final planName = plan['name'] as String? ?? 'Plano sem nome';
                    final objective = plan['objective'] as String? ?? plan['goal'] as String?;
                    final difficulty = plan['difficulty'] as String?;
                    final splitType = plan['split_type'] as String?;
                    final workoutsCount = plan['workout_count'] as int? ?? 0;
                    final durationWeeks = plan['duration_weeks'] as int?;
                    final isSelected = _selectedPlanId == planId;

                    return GestureDetector(
                      onTap: () {
                        HapticUtils.selectionClick();
                        setState(() {
                          _selectedPlanId = planId;
                          _selectedPlanName = planName;
                          _selectedPlanDurationWeeks = durationWeeks;
                          // Clear end date first, then recalculate if plan has duration
                          if (durationWeeks != null && durationWeeks > 0) {
                            _endDate = _startDate.add(Duration(days: durationWeeks * 7));
                          } else {
                            _endDate = null;
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withAlpha(isDark ? 30 : 20)
                              : (isDark ? AppColors.cardDark : AppColors.card),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? AppColors.borderDark : AppColors.border),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                LucideIcons.clipboardList,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    planName,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (objective != null)
                                    Text(
                                      _translateGoal(objective),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: isDark
                                            ? AppColors.mutedForegroundDark
                                            : AppColors.mutedForeground,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (difficulty != null)
                                        _PlanChip(
                                          label: _translateDifficulty(difficulty),
                                          isDark: isDark,
                                        ),
                                      if (splitType != null)
                                        _PlanChip(
                                          label: _translateSplitType(splitType),
                                          isDark: isDark,
                                        ),
                                      _PlanChip(
                                        label: '$workoutsCount treino${workoutsCount == 1 ? '' : 's'}',
                                        isDark: isDark,
                                      ),
                                      if (durationWeeks != null && durationWeeks > 0)
                                        _PlanChip(
                                          label: '$durationWeeks semana${durationWeeks == 1 ? '' : 's'}',
                                          isDark: isDark,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                LucideIcons.checkCircle,
                                color: AppColors.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Date selection
          if (_selectedPlanId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Início',
                      date: _startDate,
                      isDark: isDark,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _startDate = date);
                          // Recalculate end date based on new start date
                          _updateEndDateFromDuration();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Fim (opcional)',
                      date: _endDate,
                      isDark: isDark,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
                          firstDate: _startDate,
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        setState(() => _endDate = date);
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Action button
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomPadding),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _selectedPlanId != null && !_isLoading
                    ? _assignPlan
                    : null,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(LucideIcons.checkCircle, size: 20),
                label: Text(_isLoading ? 'Atribuindo...' : 'Atribuir Plano'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  final String label;
  final bool isDark;

  const _PlanChip({
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.mutedDark : AppColors.muted,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isDark;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 16,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}'
                      : '-',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Enum for conflict resolution actions
enum _ConflictAction {
  replace,
  addComplementary,
  scheduleAfter,
}

/// Button widget for conflict resolution options
class _ConflictOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool isDark;
  final VoidCallback onTap;

  const _ConflictOptionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticUtils.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
