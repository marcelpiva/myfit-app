import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'duplicate_plan_sheet.dart';
import 'template_plan_sheet.dart';

/// Bottom sheet for prescribing a new plan to a student
class PrescribePlanSheet extends StatelessWidget {
  final String studentUserId;
  final String studentName;

  const PrescribePlanSheet({
    super.key,
    required this.studentUserId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
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
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.filePlus,
                      size: 28,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Prescrever',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Para $studentName',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),

            // Options
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _OptionTile(
                    icon: LucideIcons.sparkles,
                    iconColor: AppColors.primary,
                    title: 'Criar do Zero',
                    description: 'Crie uma prescrição personalizada passo a passo',
                    isDark: isDark,
                    onTap: () => _createFromScratch(context),
                  ),
                  const SizedBox(height: 12),
                  _OptionTile(
                    icon: LucideIcons.layoutTemplate,
                    iconColor: AppColors.secondary,
                    title: 'A Partir de Modelo',
                    description: 'Use um modelo da sua biblioteca',
                    isDark: isDark,
                    onTap: () => _createFromTemplate(context),
                  ),
                  const SizedBox(height: 12),
                  _OptionTile(
                    icon: LucideIcons.copy,
                    iconColor: AppColors.info,
                    title: 'Duplicar Modelo Existente',
                    description: 'Copie e adapte um modelo já criado',
                    isDark: isDark,
                    onTap: () => _duplicateExisting(context),
                  ),
                ],
              ),
            ),

            // Cancel button
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomPadding),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createFromScratch(BuildContext context) {
    HapticUtils.lightImpact();
    Navigator.pop(context);
    // Navigate to Plan Wizard with pre-selected student
    context.push('/plans/wizard?studentId=$studentUserId');
  }

  void _createFromTemplate(BuildContext context) {
    HapticUtils.lightImpact();
    Navigator.pop(context);
    // Show template selection sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TemplatePlanSheet(
        studentUserId: studentUserId,
        studentName: studentName,
      ),
    );
  }

  void _duplicateExisting(BuildContext context) {
    HapticUtils.lightImpact();
    Navigator.pop(context);
    // Show plan selection sheet for duplication
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DuplicatePlanSheet(
        studentUserId: studentUserId,
        studentName: studentName,
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool isDark;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(isDark ? 30 : 20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
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
