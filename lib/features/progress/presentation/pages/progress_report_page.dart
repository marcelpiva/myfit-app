import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/student_home_provider.dart';
import '../../data/services/progress_report_service.dart';
import '../providers/progress_provider.dart';

/// Page for generating and sharing progress reports
class ProgressReportPage extends ConsumerStatefulWidget {
  const ProgressReportPage({super.key});

  @override
  ConsumerState<ProgressReportPage> createState() => _ProgressReportPageState();
}

class _ProgressReportPageState extends ConsumerState<ProgressReportPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isGenerating = false;
  bool _isSharing = false;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).scaffoldBackgroundColor,
              onSurface: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _setQuickPeriod(int days) {
    HapticUtils.selectionClick();
    setState(() {
      _endDate = DateTime.now();
      _startDate = _endDate.subtract(Duration(days: days));
    });
  }

  List<WeightEntry> _buildWeightEntries(List<Map<String, dynamic>> logs) {
    return logs
        .where((log) {
          final date = DateTime.tryParse(log['logged_at'] ?? '');
          if (date == null) return false;
          return date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
              date.isBefore(_endDate.add(const Duration(days: 1)));
        })
        .map((log) => WeightEntry(
              date: DateTime.parse(log['logged_at']),
              weight: (log['weight_kg'] as num).toDouble(),
              notes: log['notes'] as String?,
            ))
        .toList();
  }

  List<MeasurementEntry> _buildMeasurementEntries(List<Map<String, dynamic>> logs) {
    return logs
        .where((log) {
          final date = DateTime.tryParse(log['logged_at'] ?? '');
          if (date == null) return false;
          return date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
              date.isBefore(_endDate.add(const Duration(days: 1)));
        })
        .map((log) => MeasurementEntry(
              date: DateTime.parse(log['logged_at']),
              chest: (log['chest_cm'] as num?)?.toDouble(),
              waist: (log['waist_cm'] as num?)?.toDouble(),
              hips: (log['hips_cm'] as num?)?.toDouble(),
              leftArm: (log['biceps_cm'] as num?)?.toDouble(),
              rightArm: (log['biceps_cm'] as num?)?.toDouble(),
              leftThigh: (log['thigh_cm'] as num?)?.toDouble(),
              rightThigh: (log['thigh_cm'] as num?)?.toDouble(),
              leftCalf: (log['calf_cm'] as num?)?.toDouble(),
              rightCalf: (log['calf_cm'] as num?)?.toDouble(),
            ))
        .toList();
  }

  Future<void> _previewReport() async {
    HapticUtils.lightImpact();
    setState(() => _isGenerating = true);

    try {
      final user = ref.read(currentUserProvider);
      final progressState = ref.read(progressProvider);
      final dashboardState = ref.read(studentDashboardProvider);

      final weightEntries = _buildWeightEntries(progressState.weightLogs);
      final measurementEntries = _buildMeasurementEntries(progressState.measurementLogs);

      if (weightEntries.isEmpty && measurementEntries.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhum dado de progresso no período selecionado'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      final pdfBytes = await ProgressReportService.generateReport(
        userName: user?.name ?? 'Aluno',
        weightEntries: weightEntries,
        measurementEntries: measurementEntries,
        startDate: _startDate,
        endDate: _endDate,
        trainerName: dashboardState.trainer?.name,
        organizationName: null,
      );

      if (mounted) {
        await Printing.layoutPdf(
          onLayout: (_) async => pdfBytes,
          name: 'Relatório de Progresso - ${user?.name ?? "Aluno"}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao gerar relatório: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _shareReport() async {
    HapticUtils.lightImpact();
    setState(() => _isSharing = true);

    try {
      final user = ref.read(currentUserProvider);
      final progressState = ref.read(progressProvider);
      final dashboardState = ref.read(studentDashboardProvider);

      final weightEntries = _buildWeightEntries(progressState.weightLogs);
      final measurementEntries = _buildMeasurementEntries(progressState.measurementLogs);

      if (weightEntries.isEmpty && measurementEntries.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhum dado de progresso no período selecionado'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      final pdfBytes = await ProgressReportService.generateReport(
        userName: user?.name ?? 'Aluno',
        weightEntries: weightEntries,
        measurementEntries: measurementEntries,
        startDate: _startDate,
        endDate: _endDate,
        trainerName: dashboardState.trainer?.name,
        organizationName: null,
      );

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final dateFormat = DateFormat('yyyy-MM-dd');
      final fileName = 'relatorio_progresso_${dateFormat.format(_startDate)}_${dateFormat.format(_endDate)}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Meu relatório de progresso - ${user?.name ?? ""}',
        subject: 'Relatório de Progresso MyFit',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final progressState = ref.watch(progressProvider);

    // Count data in selected period
    final weightCount = progressState.weightLogs.where((log) {
      final date = DateTime.tryParse(log['logged_at'] ?? '');
      if (date == null) return false;
      return date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(_endDate.add(const Duration(days: 1)));
    }).length;

    final measurementCount = progressState.measurementLogs.where((log) {
      final date = DateTime.tryParse(log['logged_at'] ?? '');
      if (date == null) return false;
      return date.isAfter(_startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(_endDate.add(const Duration(days: 1)));
    }).length;

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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          context.pop();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
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
                        child: Text(
                          'Relatório de Progresso',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Period selector
                        Text(
                          'Período do Relatório',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Date range card
                        GestureDetector(
                          onTap: _selectDateRange,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark.withAlpha(150)
                                  : AppColors.card.withAlpha(200),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    LucideIcons.calendar,
                                    size: 22,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.foregroundDark
                                              : AppColors.foreground,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Toque para alterar',
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
                                Icon(
                                  LucideIcons.chevronRight,
                                  size: 20,
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Quick period buttons
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _QuickPeriodChip(
                              label: '7 dias',
                              isSelected: _endDate.difference(_startDate).inDays == 7,
                              onTap: () => _setQuickPeriod(7),
                              isDark: isDark,
                            ),
                            _QuickPeriodChip(
                              label: '30 dias',
                              isSelected: _endDate.difference(_startDate).inDays == 30,
                              onTap: () => _setQuickPeriod(30),
                              isDark: isDark,
                            ),
                            _QuickPeriodChip(
                              label: '90 dias',
                              isSelected: _endDate.difference(_startDate).inDays == 90,
                              onTap: () => _setQuickPeriod(90),
                              isDark: isDark,
                            ),
                            _QuickPeriodChip(
                              label: '6 meses',
                              isSelected: _endDate.difference(_startDate).inDays == 180,
                              onTap: () => _setQuickPeriod(180),
                              isDark: isDark,
                            ),
                            _QuickPeriodChip(
                              label: '1 ano',
                              isSelected: _endDate.difference(_startDate).inDays == 365,
                              onTap: () => _setQuickPeriod(365),
                              isDark: isDark,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Data summary
                        Text(
                          'Dados no Período',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _DataCountCard(
                                icon: LucideIcons.scale,
                                label: 'Registros de Peso',
                                count: weightCount,
                                color: AppColors.primary,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DataCountCard(
                                icon: LucideIcons.ruler,
                                label: 'Registros de Medidas',
                                count: measurementCount,
                                color: AppColors.secondary,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),

                        if (weightCount == 0 && measurementCount == 0) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.warning.withAlpha(50),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.alertTriangle,
                                  size: 20,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Nenhum dado encontrado no período selecionado. Registre seu peso ou medidas para gerar o relatório.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Report preview info
                        Text(
                          'O Relatório Inclui',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _FeatureItem(
                          icon: LucideIcons.lineChart,
                          title: 'Resumo do Período',
                          description: 'Peso inicial, atual e variação total',
                          isDark: isDark,
                        ),
                        _FeatureItem(
                          icon: LucideIcons.table,
                          title: 'Tabela de Evolução',
                          description: 'Histórico detalhado de peso e medidas',
                          isDark: isDark,
                        ),
                        _FeatureItem(
                          icon: LucideIcons.trendingUp,
                          title: 'Variações',
                          description: 'Mudanças entre cada registro',
                          isDark: isDark,
                        ),
                        if (ref.watch(studentDashboardProvider).hasTrainer)
                          _FeatureItem(
                            icon: LucideIcons.userCheck,
                            title: 'Dados do Personal',
                            description: 'Nome do trainer e academia',
                            isDark: isDark,
                          ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 16,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.background,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _isGenerating || _isSharing ? null : _previewReport,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardDark.withAlpha(150)
                        : AppColors.card.withAlpha(200),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary,
                    ),
                  ),
                  child: Center(
                    child: _isGenerating
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.eye,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Visualizar',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _isGenerating || _isSharing ? null : _shareReport,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isSharing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.share2,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Compartilhar',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickPeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickPeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark
                  ? AppColors.cardDark.withAlpha(150)
                  : AppColors.card.withAlpha(200)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.foregroundDark : AppColors.foreground),
          ),
        ),
      ),
    );
  }
}

class _DataCountCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final bool isDark;

  const _DataCountCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
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
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDark;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Text(
                  description,
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
          Icon(
            LucideIcons.check,
            size: 18,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}
