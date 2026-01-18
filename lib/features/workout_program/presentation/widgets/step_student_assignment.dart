import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/trainer_service.dart';
import '../providers/program_wizard_provider.dart';

/// Provider for active students
final activeStudentsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final service = TrainerService();
  // Request only active students from the API
  final students = await service.getStudents(status: 'active');
  return students;
});

/// Step 6: Optional student assignment
class StepStudentAssignment extends ConsumerWidget {
  const StepStudentAssignment({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(programWizardProvider);
    final notifier = ref.read(programWizardProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final studentsAsync = ref.watch(activeStudentsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atribuir a um Aluno',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Opcional: selecione um aluno para atribuir este programa automaticamente',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),

          // Skip option
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              notifier.setStudentId(null);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: state.studentId == null
                    ? AppColors.primary.withAlpha(isDark ? 30 : 20)
                    : (isDark ? AppColors.cardDark : AppColors.card),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.studentId == null
                      ? AppColors.primary
                      : (isDark ? AppColors.borderDark : AppColors.border),
                  width: state.studentId == null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.muted.withAlpha(isDark ? 50 : 100),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      LucideIcons.skipForward,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pular esta etapa',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nao atribuir a nenhum aluno agora',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.studentId == null)
                    Icon(
                      LucideIcons.checkCircle,
                      color: AppColors.primary,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Divider with "or"
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ou selecione um aluno',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Students list
          studentsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.alertCircle,
                      size: 48,
                      color: AppColors.destructive,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar alunos',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(activeStudentsProvider),
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
            data: (students) {
              if (students.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.users,
                          size: 48,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum aluno ativo',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Adicione alunos para poder atribuir programas',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: students.map((student) {
                  final studentId = student['id'] as String?;
                  final studentName = student['name'] as String? ?? 'Aluno';
                  final studentEmail = student['email'] as String?;
                  final avatarUrl = student['avatar_url'] as String?;
                  final isSelected = state.studentId == studentId;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        notifier.setStudentId(isSelected ? null : studentId);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withAlpha(isDark ? 30 : 20)
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
                            // Avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(isDark ? 40 : 30),
                                borderRadius: BorderRadius.circular(24),
                                image: avatarUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(avatarUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: avatarUrl == null
                                  ? Center(
                                      child: Text(
                                        studentName.isNotEmpty
                                            ? studentName[0].toUpperCase()
                                            : 'A',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    studentName,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (studentEmail != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      studentEmail,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: isDark
                                            ? AppColors.mutedForegroundDark
                                            : AppColors.mutedForeground,
                                      ),
                                    ),
                                  ],
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
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
