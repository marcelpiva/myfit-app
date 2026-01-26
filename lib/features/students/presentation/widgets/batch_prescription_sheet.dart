import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/workout_service.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../trainer_workout/presentation/pages/trainer_plans_page.dart';
import '../../../trainer_workout/presentation/providers/trainer_students_provider.dart';

/// Sheet for batch prescribing a plan to multiple students
class BatchPrescriptionSheet extends ConsumerStatefulWidget {
  const BatchPrescriptionSheet({super.key});

  @override
  ConsumerState<BatchPrescriptionSheet> createState() => _BatchPrescriptionSheetState();
}

class _BatchPrescriptionSheetState extends ConsumerState<BatchPrescriptionSheet> {
  final Set<String> _selectedStudents = {};
  Map<String, dynamic>? _selectedPlan;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isPrescribing = false;
  int _prescribedCount = 0;
  int _failedCount = 0;
  List<String> _errors = [];
  bool _showResults = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final students = ref.watch(trainerStudentsProvider(null));
    final plansAsync = ref.watch(allPlansProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.users,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prescrição em Massa',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Prescreva para múltiplos alunos',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
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
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: _showResults
                ? _buildResults(theme, isDark)
                : _isPrescribing
                    ? _buildProgress(theme, isDark)
                    : _buildForm(
                        context,
                        theme,
                        isDark,
                        students,
                        plansAsync,
                      ),
          ),

          // Actions
          if (!_showResults && !_isPrescribing)
            _buildActions(context, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    List<TrainerStudent> students,
    AsyncValue<List<Map<String, dynamic>>> plansAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step 1: Select Plan
          _buildSectionHeader(theme, isDark, '1. Selecione o Modelo', LucideIcons.clipboard),
          const SizedBox(height: 12),
          plansAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erro ao carregar modelos: $e'),
            data: (plans) {
              if (plans.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.info,
                        size: 18,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nenhum modelo disponível. Crie um modelo primeiro.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedPlan,
                decoration: InputDecoration(
                  hintText: 'Escolha um modelo',
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                ),
                items: plans.map((plan) {
                  final name = plan['name'] as String? ?? 'Sem nome';
                  return DropdownMenuItem(
                    value: plan,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (plan) {
                  HapticUtils.selectionClick();
                  setState(() => _selectedPlan = plan);
                },
              );
            },
          ),

          const SizedBox(height: 24),

          // Step 2: Select Students
          _buildSectionHeader(
            theme,
            isDark,
            '2. Selecione os Alunos',
            LucideIcons.userCheck,
            trailing: _selectedStudents.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_selectedStudents.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          if (students.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 18,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nenhum aluno disponível.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                // Select all / deselect all
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        setState(() {
                          _selectedStudents.addAll(students.map((s) => s.id));
                        });
                      },
                      child: const Text('Selecionar todos'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        setState(() => _selectedStudents.clear());
                      },
                      child: const Text('Limpar'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Student list
                Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: students.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final isSelected = _selectedStudents.contains(student.id);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (checked) {
                          HapticUtils.selectionClick();
                          setState(() {
                            if (checked == true) {
                              _selectedStudents.add(student.id);
                            } else {
                              _selectedStudents.remove(student.id);
                            }
                          });
                        },
                        title: Text(
                          student.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: student.email != null
                            ? Text(
                                student.email!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                              )
                            : null,
                        secondary: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withAlpha(30),
                          child: Text(
                            student.initials,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                      );
                    },
                  ),
                ),
              ],
            ),

          const SizedBox(height: 24),

          // Step 3: Dates (optional)
          _buildSectionHeader(theme, isDark, '3. Datas (Opcional)', LucideIcons.calendar),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Início',
                  value: _startDate,
                  isDark: isDark,
                  onTap: () => _selectDate(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateField(
                  label: 'Término',
                  value: _endDate,
                  isDark: isDark,
                  onTap: () => _selectDate(false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProgress(ThemeData theme, bool isDark) {
    final total = _selectedStudents.length;
    final processed = _prescribedCount + _failedCount;
    final progress = total > 0 ? processed / total : 0.0;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: isDark ? AppColors.borderDark : AppColors.border,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Prescrevendo...',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$processed de $total alunos',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(ThemeData theme, bool isDark) {
    final success = _prescribedCount > 0 && _failedCount == 0;
    final partial = _prescribedCount > 0 && _failedCount > 0;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: success
                  ? AppColors.success.withAlpha(isDark ? 30 : 20)
                  : partial
                      ? AppColors.warning.withAlpha(isDark ? 30 : 20)
                      : AppColors.destructive.withAlpha(isDark ? 30 : 20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              success
                  ? LucideIcons.checkCircle
                  : partial
                      ? LucideIcons.alertCircle
                      : LucideIcons.xCircle,
              size: 48,
              color: success
                  ? AppColors.success
                  : partial
                      ? AppColors.warning
                      : AppColors.destructive,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            success
                ? 'Prescrição Concluída!'
                : partial
                    ? 'Prescrição Parcial'
                    : 'Falha na Prescrição',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ResultBadge(
                icon: LucideIcons.checkCircle,
                color: AppColors.success,
                label: '$_prescribedCount com sucesso',
                isDark: isDark,
              ),
              if (_failedCount > 0) ...[
                const SizedBox(width: 16),
                _ResultBadge(
                  icon: LucideIcons.xCircle,
                  color: AppColors.destructive,
                  label: '$_failedCount falhas',
                  isDark: isDark,
                ),
              ],
            ],
          ),
          if (_errors.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.destructive.withAlpha(isDark ? 15 : 10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Erros:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.destructive,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ..._errors.take(3).map((e) => Text(
                        '• $e',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.destructive,
                        ),
                      )),
                  if (_errors.length > 3)
                    Text(
                      '... e mais ${_errors.length - 3} erros',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.destructive,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Concluir'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme, bool isDark) {
    final canPrescribe = _selectedPlan != null && _selectedStudents.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: canPrescribe ? _startPrescription : null,
                icon: const Icon(LucideIcons.send, size: 18),
                label: Text(
                  'Prescrever (${_selectedStudents.length})',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    bool isDark,
    String title,
    IconData icon, {
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing,
        ],
      ],
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? now) : (_endDate ?? now.add(const Duration(days: 30))),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      HapticUtils.selectionClick();
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _startPrescription() async {
    if (_selectedPlan == null || _selectedStudents.isEmpty) return;

    HapticUtils.mediumImpact();
    setState(() {
      _isPrescribing = true;
      _prescribedCount = 0;
      _failedCount = 0;
      _errors = [];
    });

    final workoutService = WorkoutService();
    final planId = _selectedPlan!['id'] as String;

    for (final studentId in _selectedStudents) {
      try {
        await workoutService.createPlanAssignment(
          planId: planId,
          studentId: studentId,
          startDate: _startDate,
          endDate: _endDate,
        );
        setState(() => _prescribedCount++);
      } catch (e) {
        setState(() {
          _failedCount++;
          _errors.add(e.toString());
        });
      }
    }

    // Refresh providers
    ref.invalidate(trainerStudentsProvider);
    ref.invalidate(allPlansProvider);

    setState(() {
      _isPrescribing = false;
      _showResults = true;
    });
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final bool isDark;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
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
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                  Text(
                    value != null
                        ? '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}'
                        : 'Selecionar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: value != null
                          ? null
                          : (isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool isDark;

  const _ResultBadge({
    required this.icon,
    required this.color,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 20 : 15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the batch prescription sheet
void showBatchPrescriptionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const BatchPrescriptionSheet(),
  );
}
