import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/workout_service.dart';
import '../../../trainer_workout/presentation/providers/trainer_students_provider.dart';

/// Sheet for assigning a plan to a student
class AssignPlanSheet extends ConsumerStatefulWidget {
  final String planId;
  final String planName;

  const AssignPlanSheet({
    super.key,
    required this.planId,
    required this.planName,
  });

  @override
  ConsumerState<AssignPlanSheet> createState() => _AssignPlanSheetState();
}

class _AssignPlanSheetState extends ConsumerState<AssignPlanSheet> {
  final _workoutService = WorkoutService();
  final _searchController = TextEditingController();

  String? _selectedStudentId;
  String? _selectedStudentName;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _assignPlan() async {
    if (_selectedStudentId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _workoutService.createPlanAssignment(
        planId: widget.planId,
        studentId: _selectedStudentId!,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Plano atribuído a $_selectedStudentName'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
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
    final studentsState = ref.watch(trainerStudentsNotifierProvider(null));
    final students = studentsState.students;
    final isStudentsLoading = studentsState.isLoading;

    // Filter students by search
    final search = _searchController.text.toLowerCase();
    final filteredStudents = search.isEmpty
        ? students
        : students.where((s) {
            final name = s.name.toLowerCase();
            final email = (s.email ?? '').toLowerCase();
            return name.contains(search) || email.contains(search);
          }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.userPlus,
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
                        'Atribuir Plano',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.planName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
                color: theme.colorScheme.error.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.alertCircle,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
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
                hintText: 'Buscar aluno...',
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
          ),

          // Students list
          Expanded(
            child: isStudentsLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredStudents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.users,
                              size: 48,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum aluno encontrado',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          final studentId = student.id;
                          final studentName = student.name;
                          final studentEmail = student.email ?? '';
                          final isSelected = _selectedStudentId == studentId;

                          return GestureDetector(
                            onTap: () {
                              HapticUtils.selectionClick();
                              setState(() {
                                _selectedStudentId = studentId;
                                _selectedStudentName = studentName;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withAlpha(20)
                                    : (isDark
                                        ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
                                        : theme.colorScheme.surfaceContainerLow.withAlpha(200)),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary.withAlpha(30),
                                    child: Text(
                                      studentName.isNotEmpty ? studentName[0].toUpperCase() : '?',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          studentName,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (studentEmail.isNotEmpty)
                                          Text(
                                            studentEmail,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                            ),
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
                      ),
          ),

          // Date selection (optional)
          if (_selectedStudentId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Início',
                      date: _startDate,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => _startDate = date);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Fim (opcional)',
                      date: _endDate,
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
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedStudentId != null && !_isLoading
                    ? _assignPlan
                    : null,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(LucideIcons.userPlus, size: 20),
                label: Text(_isLoading ? 'Atribuindo...' : 'Atribuir Plano'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
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

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerLow.withAlpha(150)
              : theme.colorScheme.surfaceContainerLow.withAlpha(200),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
