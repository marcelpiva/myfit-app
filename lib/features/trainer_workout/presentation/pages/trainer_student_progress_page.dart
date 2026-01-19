import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../providers/student_progress_provider.dart';

/// Página para trainer visualizar o progresso de um aluno específico
class TrainerStudentProgressPage extends ConsumerStatefulWidget {
  final String studentId;
  final String? studentName;

  const TrainerStudentProgressPage({
    super.key,
    required this.studentId,
    this.studentName,
  });

  @override
  ConsumerState<TrainerStudentProgressPage> createState() =>
      _TrainerStudentProgressPageState();
}

class _TrainerStudentProgressPageState
    extends ConsumerState<TrainerStudentProgressPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _selectedTab = 0;

  final _tabs = ['Peso', 'Medidas', 'Fotos'];

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

    // Load student progress data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(studentProgressNotifierProvider(widget.studentId).notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final studentName = widget.studentName ?? 'Aluno';
    final progressState = ref.watch(studentProgressNotifierProvider(widget.studentId));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? AppColors.primaryDark : AppColors.primary)
                  .withAlpha(isDark ? 15 : 10),
              (isDark ? AppColors.secondaryDark : AppColors.secondary)
                  .withAlpha(isDark ? 12 : 8),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back button
                  _buildHeader(context, isDark, studentName),

                  // Student summary card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _StudentSummaryCard(
                      isDark: isDark,
                      studentName: studentName,
                      summary: progressState.summary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildTabs(isDark),
                  ),

                  const SizedBox(height: 24),

                  // Content based on selected tab
                  if (_selectedTab == 0) ...[
                    _WeightProgressTab(
                      isDark: isDark,
                      summary: progressState.summary,
                      entries: progressState.weightEntries,
                      chartValues: progressState.chartValues,
                      chartLabels: progressState.chartLabels,
                      isLoading: progressState.isLoading,
                    ),
                  ] else if (_selectedTab == 1) ...[
                    _MeasurementsProgressTab(
                      isDark: isDark,
                      measurements: progressState.measurements,
                      lastMeasurementDate: progressState.lastMeasurementDate,
                    ),
                  ] else ...[
                    _PhotosProgressTab(
                      isDark: isDark,
                      photos: progressState.photos,
                    ),
                  ],

                  // Trainer notes section
                  const SizedBox(height: 24),
                  _TrainerNotesSection(
                    isDark: isDark,
                    studentId: widget.studentId,
                    notes: progressState.notes,
                    onAddNote: (content) async {
                      return ref
                          .read(studentProgressNotifierProvider(widget.studentId).notifier)
                          .addNote(content);
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, String studentName) {
    return Padding(
      padding: const EdgeInsets.all(24),
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
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progresso',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Text(
                  studentName,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              _showStudentOptions(context, isDark);
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Icon(
                LucideIcons.moreVertical,
                size: 20,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final isSelected = entry.key == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticUtils.selectionClick();
                setState(() => _selectedTab = entry.key);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? (isDark
                              ? AppColors.backgroundDark
                              : AppColors.background)
                          : (isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showStudentOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.target),
              title: const Text('Definir Metas'),
              subtitle: const Text('Peso, medidas e objetivos'),
              onTap: () {
                HapticUtils.lightImpact();
                Navigator.pop(ctx);
                _showSetGoalsDialog(context, isDark);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.fileText),
              title: const Text('Adicionar Nota'),
              subtitle: const Text('Observações sobre o progresso'),
              onTap: () {
                HapticUtils.lightImpact();
                Navigator.pop(ctx);
                _showAddNoteDialog(context, isDark);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.messageSquare),
              title: const Text('Enviar Feedback'),
              subtitle: const Text('Mensagem sobre o progresso'),
              onTap: () {
                HapticUtils.lightImpact();
                Navigator.pop(ctx);
                _showSendFeedbackDialog(context, isDark);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.download),
              title: const Text('Exportar Relatório'),
              subtitle: const Text('PDF com histórico completo'),
              onTap: () {
                HapticUtils.lightImpact();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Gerando relatório...'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSetGoalsDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(LucideIcons.target, size: 24, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              'Definir Metas',
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Meta de Peso (kg)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixText: 'kg',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Meta de Cintura (cm)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixText: 'cm',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Prazo',
                  hintText: 'Ex: 3 meses',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticUtils.mediumImpact();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Metas definidas!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(LucideIcons.fileText, size: 24, color: AppColors.secondary),
            const SizedBox(width: 12),
            Text(
              'Adicionar Nota',
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
        content: TextField(
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Observação',
            hintText: 'Adicione uma nota sobre o progresso do aluno...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticUtils.mediumImpact();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Nota adicionada!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showSendFeedbackDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(LucideIcons.messageSquare, size: 24, color: AppColors.accent),
            const SizedBox(width: 12),
            Text(
              'Enviar Feedback',
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Envie uma mensagem de feedback sobre o progresso do aluno.',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Mensagem',
                hintText: 'Ótimo progresso! Continue assim...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticUtils.mediumImpact();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Feedback enviado!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// STUDENT SUMMARY CARD
// =============================================================================

class _StudentSummaryCard extends StatelessWidget {
  final bool isDark;
  final String studentName;
  final StudentProgressSummary summary;

  const _StudentSummaryCard({
    required this.isDark,
    required this.studentName,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                studentName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildMiniStat(isDark, 'Início', summary.formattedStartDate),
                    const SizedBox(width: 16),
                    _buildMiniStat(isDark, 'Duração', summary.formattedDuration),
                  ],
                ),
              ],
            ),
          ),
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getChangeColor(summary.totalChange).withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  '${summary.totalChange >= 0 ? '+' : ''}${summary.totalChange.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _getChangeColor(summary.totalChange),
                  ),
                ),
                Text(
                  'kg',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getChangeColor(summary.totalChange),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(bool isDark, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
      ],
    );
  }

  Color _getChangeColor(double change) {
    // Negative weight change is typically good (weight loss)
    if (change < 0) return AppColors.success;
    if (change == 0) return AppColors.primary;
    return AppColors.warning;
  }
}

// =============================================================================
// WEIGHT PROGRESS TAB
// =============================================================================

class _WeightProgressTab extends StatelessWidget {
  final bool isDark;
  final StudentProgressSummary summary;
  final List<WeightEntry> entries;
  final List<double> chartValues;
  final List<String> chartLabels;
  final bool isLoading;

  const _WeightProgressTab({
    required this.isDark,
    required this.summary,
    required this.entries,
    this.chartValues = const [],
    this.chartLabels = const [],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current vs Goal
          _buildWeightComparison(isDark),
          const SizedBox(height: 20),
          // Chart
          _buildWeightChart(isDark),
          const SizedBox(height: 20),
          // Recent entries
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Registros Recentes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticUtils.selectionClick();
                  _showFullWeightHistory(context, isDark);
                },
                child: Text(
                  'Ver todos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (entries.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Nenhum registro de peso',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            ...entries.map((e) => _buildWeightEntry(isDark, e)),
        ],
      ),
    );
  }

  Widget _buildWeightComparison(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Current
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peso Atual',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      summary.currentWeight.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        ' kg',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Arrow
          Column(
            children: [
              Icon(
                LucideIcons.arrowRight,
                size: 24,
                color: AppColors.primary,
              ),
              const SizedBox(height: 4),
              Text(
                '${summary.remainingToGoal >= 0 ? '+' : ''}${summary.remainingToGoal.toStringAsFixed(1)} kg',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: summary.remainingToGoal <= 0 ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
          // Goal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Meta',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      summary.goalWeight > 0 ? summary.goalWeight.toStringAsFixed(1) : '-',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        ' kg',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(bool isDark) {
    final values = chartValues.isNotEmpty ? chartValues : [summary.currentWeight];
    final months = chartLabels.isNotEmpty ? chartLabels : ['Atual'];
    final maxVal = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 0.0;
    final minVal = values.isNotEmpty ? values.reduce((a, b) => a < b ? a : b) : 0.0;
    final range = maxVal - minVal;

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Evolução',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (summary.totalChange <= 0 ? AppColors.success : AppColors.warning).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      summary.totalChange <= 0 ? LucideIcons.trendingDown : LucideIcons.trendingUp,
                      size: 14,
                      color: summary.totalChange <= 0 ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${summary.totalChange >= 0 ? '+' : ''}${summary.totalChange.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: summary.totalChange <= 0 ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: values.asMap().entries.map((entry) {
                final normalizedHeight = range > 0
                    ? ((entry.value - minVal) / range) * 80 + 30
                    : 80.0;
                final isLast = entry.key == values.length - 1;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isLast
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: normalizedHeight,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: isLast
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        months[entry.key],
                        style: TextStyle(
                          fontSize: 11,
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
        ],
      ),
    );
  }

  Widget _buildWeightEntry(bool isDark, WeightEntry entry) {
    final isNegative = entry.change < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isNegative ? AppColors.success : AppColors.warning)
                  .withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isNegative ? LucideIcons.trendingDown : LucideIcons.trendingUp,
              size: 18,
              color: isNegative ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.weight.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Text(
                  entry.date,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isNegative ? AppColors.success : AppColors.warning)
                  .withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${entry.change > 0 ? '+' : ''}${entry.change.toStringAsFixed(1)} kg',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isNegative ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullWeightHistory(BuildContext context, bool isDark) {
    // Full weight history data
    final allEntries = [
      {'weight': 75.2, 'date': 'Hoje, 08:30', 'change': -0.3},
      {'weight': 75.5, 'date': 'Ontem, 07:45', 'change': -0.5},
      {'weight': 76.0, 'date': '12 Jan, 08:00', 'change': 0.2},
      {'weight': 75.8, 'date': '10 Jan, 07:30', 'change': -0.4},
      {'weight': 76.2, 'date': '08 Jan, 08:15', 'change': -0.3},
      {'weight': 76.5, 'date': '06 Jan, 07:50', 'change': -0.5},
      {'weight': 77.0, 'date': '04 Jan, 08:00', 'change': -0.2},
      {'weight': 77.2, 'date': '02 Jan, 07:45', 'change': -0.6},
      {'weight': 77.8, 'date': '01 Jan, 08:30', 'change': -0.4},
      {'weight': 78.2, 'date': '30 Dez, 08:00', 'change': -0.3},
      {'weight': 78.5, 'date': '28 Dez, 07:30', 'change': -0.5},
      {'weight': 79.0, 'date': '26 Dez, 08:15', 'change': 0.5},
      {'weight': 78.5, 'date': '24 Dez, 07:45', 'change': -0.3},
      {'weight': 78.8, 'date': '22 Dez, 08:00', 'change': -0.2},
      {'weight': 79.0, 'date': '20 Dez, 07:50', 'change': -0.5},
      {'weight': 79.5, 'date': '18 Dez, 08:30', 'change': 0.0},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Histórico de Peso',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${allEntries.length} registros',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Exportando dados...'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            LucideIcons.download,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text('Abrindo gráfico detalhado...'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            LucideIcons.lineChart,
                            size: 20,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Summary stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark.withAlpha(150)
                      : AppColors.card.withAlpha(200),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(isDark, 'Inicial', '79.5 kg'),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    _buildSummaryItem(isDark, 'Atual', '75.2 kg'),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    _buildSummaryItem(
                        isDark, 'Total', '-4.3 kg', AppColors.success),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Divider
            Divider(
              color: isDark ? AppColors.borderDark : AppColors.border,
              height: 1,
            ),
            // Scrollable list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: allEntries.length,
                itemBuilder: (context, index) {
                  final entry = allEntries[index];
                  final change = entry['change'] as double;
                  final isNegative = change < 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.backgroundDark.withAlpha(100)
                          : AppColors.card.withAlpha(150),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (isNegative
                                    ? AppColors.success
                                    : AppColors.warning)
                                .withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isNegative
                                ? LucideIcons.trendingDown
                                : LucideIcons.trendingUp,
                            size: 18,
                            color: isNegative
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry['weight']} kg',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foreground,
                                ),
                              ),
                              Text(
                                entry['date'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isNegative
                                    ? AppColors.success
                                    : AppColors.warning)
                                .withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${change > 0 ? '+' : ''}$change kg',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isNegative
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(bool isDark, String label, String value,
      [Color? valueColor]) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color:
                valueColor ?? (isDark ? AppColors.foregroundDark : AppColors.foreground),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// MEASUREMENTS PROGRESS TAB
// =============================================================================

class _MeasurementsProgressTab extends StatelessWidget {
  final bool isDark;
  final List<Measurement> measurements;
  final String? lastMeasurementDate;

  const _MeasurementsProgressTab({
    required this.isDark,
    required this.measurements,
    this.lastMeasurementDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Últimas Medidas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastMeasurementDate ?? 'Sem registros',
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
          const SizedBox(height: 16),
          // Grid
          Row(
            children: [
              Expanded(
                  child: _buildMeasurement(isDark, 'Peito', '98', 'cm', -2.0)),
              const SizedBox(width: 12),
              Expanded(
                  child:
                      _buildMeasurement(isDark, 'Cintura', '82', 'cm', -4.5)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child:
                      _buildMeasurement(isDark, 'Quadril', '95', 'cm', -1.5)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildMeasurement(isDark, 'Braço', '36', 'cm', 2.0)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildMeasurement(isDark, 'Coxa', '58', 'cm', 1.0)),
              const SizedBox(width: 12),
              Expanded(
                  child:
                      _buildMeasurement(isDark, 'Panturrilha', '38', 'cm', 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurement(
      bool isDark, String label, String value, String unit, double change) {
    final isPositive = change > 0;
    // For waist and hip, negative is good. For arms/legs, positive is good.
    final changeColor = label == 'Cintura' || label == 'Quadril'
        ? (isPositive ? AppColors.warning : AppColors.success)
        : (isPositive ? AppColors.success : AppColors.warning);

    return Container(
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  ' $unit',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: changeColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${isPositive ? '+' : ''}${change.toStringAsFixed(1)} $unit',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: changeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PHOTOS PROGRESS TAB
// =============================================================================

class _PhotosProgressTab extends StatelessWidget {
  final bool isDark;
  final List<ProgressPhoto> photos;

  const _PhotosProgressTab({
    required this.isDark,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardDark.withAlpha(150)
                  : AppColors.card.withAlpha(200),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.camera, size: 24, color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registro Visual',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      Text(
                        '${photos.length} fotos registradas',
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
          const SizedBox(height: 20),
          // Before/After comparison
          Text(
            'Comparação',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildPhotoPlaceholder(isDark, 'Antes', '01 Jan')),
              const SizedBox(width: 12),
              Expanded(child: _buildPhotoPlaceholder(isDark, 'Atual', '13 Jun')),
            ],
          ),
          const SizedBox(height: 20),
          // Timeline
          Text(
            'Linha do Tempo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          if (photos.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Nenhuma foto registrada',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            ...photos.map((p) => _buildPhotoEntry(context, isDark, p)),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder(bool isDark, String label, String date) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.image, size: 40, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoEntry(BuildContext context, bool isDark, ProgressPhoto photo) {
    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        _showPhotoViewer(context, isDark, photo);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(LucideIcons.image, size: 24, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photo.date,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    photo.weight,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                  if (photo.note != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      photo.note!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
    );
  }

  void _showPhotoViewer(
      BuildContext context, bool isDark, ProgressPhoto photo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Foto de Progresso',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        photo.date,
                        style: TextStyle(
                          fontSize: 14,
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
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.backgroundDark.withAlpha(150)
                            : AppColors.card.withAlpha(200),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
                      child: Icon(
                        LucideIcons.x,
                        size: 20,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Photo placeholder
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.image,
                        size: 80,
                        color: AppColors.primary.withAlpha(150),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Foto de Progresso',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Imagem em tamanho completo',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Info section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark.withAlpha(150)
                      : AppColors.card.withAlpha(200),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 18,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                              ),
                              Text(
                                photo.date,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          LucideIcons.scale,
                          size: 18,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Peso',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                              ),
                              Text(
                                photo.weight,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (photo.note != null) ...[
                      const SizedBox(height: 16),
                      Divider(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                        height: 1,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            LucideIcons.stickyNote,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nota',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.mutedForegroundDark
                                        : AppColors.mutedForeground,
                                  ),
                                ),
                                Text(
                                  photo.note!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Compartilhando foto...'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(50),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.share2,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Compartilhar',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(ctx);
                        _showDeleteConfirmation(context, isDark, photo);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.destructive.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.destructive.withAlpha(50),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.trash2,
                              size: 18,
                              color: AppColors.destructive,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Excluir',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.destructive,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, bool isDark, ProgressPhoto photo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(LucideIcons.alertTriangle, size: 24, color: AppColors.destructive),
            const SizedBox(width: 12),
            Text(
              'Excluir Foto',
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
        content: Text(
          'Tem certeza que deseja excluir esta foto de ${photo.date}? Esta ação não pode ser desfeita.',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticUtils.mediumImpact();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Foto excluída!'),
                  backgroundColor: AppColors.destructive,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TRAINER NOTES SECTION
// =============================================================================

class _TrainerNotesSection extends StatelessWidget {
  final bool isDark;
  final String studentId;
  final List<TrainerNote> notes;
  final Future<bool> Function(String content)? onAddNote;

  const _TrainerNotesSection({
    required this.isDark,
    required this.studentId,
    required this.notes,
    this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minhas Notas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  // Add new note
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.plus, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Adicionar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Notes list
          if (notes.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Nenhuma nota adicionada',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
            )
          else
            ...notes.map((note) => _buildNoteCard(isDark, note)),
        ],
      ),
    );
  }

  Widget _buildNoteCard(bool isDark, TrainerNote note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.stickyNote,
                size: 16,
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                note.date,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
