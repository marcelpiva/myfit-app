import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/services/trainer_service.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/pdf_report_generator.dart';

/// Report period options
enum ReportPeriod {
  week('Última Semana', 7),
  month('Último Mês', 30),
  quarter('Último Trimestre', 90),
  semester('Último Semestre', 180),
  year('Último Ano', 365),
  custom('Personalizado', 0);

  final String label;
  final int days;

  const ReportPeriod(this.label, this.days);
}

/// Sheet for generating and exporting student progress reports
class StudentReportSheet extends ConsumerStatefulWidget {
  final String studentUserId;
  final String studentName;
  final String trainerName;

  const StudentReportSheet({
    super.key,
    required this.studentUserId,
    required this.studentName,
    required this.trainerName,
  });

  @override
  ConsumerState<StudentReportSheet> createState() => _StudentReportSheetState();
}

class _StudentReportSheetState extends ConsumerState<StudentReportSheet> {
  ReportPeriod _selectedPeriod = ReportPeriod.month;
  DateTime? _customFromDate;
  DateTime? _customToDate;
  bool _isLoading = false;
  String? _errorMessage;

  DateTime get _fromDate {
    if (_selectedPeriod == ReportPeriod.custom && _customFromDate != null) {
      return _customFromDate!;
    }
    return DateTime.now().subtract(Duration(days: _selectedPeriod.days));
  }

  DateTime get _toDate {
    if (_selectedPeriod == ReportPeriod.custom && _customToDate != null) {
      return _customToDate!;
    }
    return DateTime.now();
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final initialRange = DateTimeRange(
      start: _customFromDate ?? now.subtract(const Duration(days: 30)),
      end: _customToDate ?? now,
    );

    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: initialRange,
      locale: const Locale('pt', 'BR'),
    );

    if (result != null) {
      setState(() {
        _customFromDate = result.start;
        _customToDate = result.end;
        _selectedPeriod = ReportPeriod.custom;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchProgressData() async {
    final service = TrainerService();
    final progress = await service.getStudentProgress(widget.studentUserId);
    final stats = await service.getStudentStats(widget.studentUserId, days: _selectedPeriod.days);
    final workouts = await service.getStudentWorkouts(widget.studentUserId);

    return {
      'weight_logs': progress['weight_logs'] ?? [],
      'measurements': progress['measurements'] ?? [],
      'stats': stats,
      'sessions': workouts,
    };
  }

  Future<void> _generateAndPreviewPdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final progressData = await _fetchProgressData();

      final pdfBytes = await PdfReportGenerator.generateStudentProgressReport(
        studentName: widget.studentName,
        trainerName: widget.trainerName,
        fromDate: _fromDate,
        toDate: _toDate,
        progressData: progressData,
      );

      if (mounted) {
        await Printing.layoutPdf(
          onLayout: (format) async => pdfBytes,
          name: 'Relatório de ${widget.studentName}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Erro ao gerar relatório: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generateAndSharePdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final progressData = await _fetchProgressData();

      final pdfBytes = await PdfReportGenerator.generateStudentProgressReport(
        studentName: widget.studentName,
        trainerName: widget.trainerName,
        fromDate: _fromDate,
        toDate: _toDate,
        progressData: progressData,
      );

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final fileName = 'relatorio_${widget.studentName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Relatório de Progresso - ${widget.studentName}',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Erro ao compartilhar: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

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
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      LucideIcons.fileText,
                      size: 24,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gerar Relatório',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.studentName,
                          style: theme.textTheme.bodyMedium?.copyWith(
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

              const SizedBox(height: 24),

              // Period selection
              Text(
                'Período do Relatório',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ReportPeriod.values.where((p) => p != ReportPeriod.custom).map((period) {
                  final isSelected = _selectedPeriod == period;
                  return GestureDetector(
                    onTap: () {
                      HapticUtils.selectionClick();
                      setState(() => _selectedPeriod = period);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.cardDark : AppColors.card),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? AppColors.borderDark : AppColors.border),
                        ),
                      ),
                      child: Text(
                        period.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Custom date range button
              GestureDetector(
                onTap: _selectCustomDateRange,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _selectedPeriod == ReportPeriod.custom
                        ? AppColors.secondary.withAlpha(isDark ? 30 : 20)
                        : (isDark ? AppColors.cardDark : AppColors.card),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedPeriod == ReportPeriod.custom
                          ? AppColors.secondary
                          : (isDark ? AppColors.borderDark : AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.calendarRange,
                        size: 18,
                        color: _selectedPeriod == ReportPeriod.custom
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Período Personalizado',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: _selectedPeriod == ReportPeriod.custom
                                    ? AppColors.secondary
                                    : null,
                              ),
                            ),
                            if (_selectedPeriod == ReportPeriod.custom && _customFromDate != null)
                              Text(
                                '${_formatDate(_customFromDate!)} - ${_formatDate(_customToDate ?? DateTime.now())}',
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
                        size: 18,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ),

              // Selected period info
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.mutedDark.withAlpha(50)
                      : AppColors.muted.withAlpha(80),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: 16,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Período: ${_formatDate(_fromDate)} até ${_formatDate(_toDate)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.destructive.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.alertCircle,
                        size: 16,
                        color: AppColors.destructive,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.destructive,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action buttons
              if (_isLoading)
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        'Gerando relatório...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: [
                    // Preview/Print button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _generateAndPreviewPdf,
                        icon: const Icon(LucideIcons.printer, size: 18),
                        label: const Text('Visualizar / Imprimir'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Share button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _generateAndSharePdf,
                        icon: const Icon(LucideIcons.share2, size: 18),
                        label: const Text('Compartilhar PDF'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
