import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// PDF Report Generator for student progress reports
class PdfReportGenerator {
  /// Generate a student progress report PDF
  static Future<Uint8List> generateStudentProgressReport({
    required String studentName,
    required String trainerName,
    required DateTime fromDate,
    required DateTime toDate,
    required Map<String, dynamic> progressData,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Extract data
    final weightLogs = (progressData['weight_logs'] as List<dynamic>?) ?? [];
    final measurements = (progressData['measurements'] as List<dynamic>?) ?? [];
    final stats = (progressData['stats'] as Map<String, dynamic>?) ?? {};
    final sessions = (progressData['sessions'] as List<dynamic>?) ?? [];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(
          studentName: studentName,
          trainerName: trainerName,
          fromDate: fromDate,
          toDate: toDate,
          dateFormat: dateFormat,
        ),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Summary Section
          _buildSummarySection(stats, weightLogs, sessions),

          pw.SizedBox(height: 20),

          // Weight Progress Section
          if (weightLogs.isNotEmpty) ...[
            _buildSectionTitle('Evolução do Peso'),
            _buildWeightTable(weightLogs, dateFormat),
            pw.SizedBox(height: 20),
          ],

          // Measurements Section
          if (measurements.isNotEmpty) ...[
            _buildSectionTitle('Medidas Corporais'),
            _buildMeasurementsTable(measurements, dateFormat),
            pw.SizedBox(height: 20),
          ],

          // Sessions Section
          if (sessions.isNotEmpty) ...[
            _buildSectionTitle('Treinos Realizados'),
            _buildSessionsTable(sessions, dateFormat),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader({
    required String studentName,
    required String trainerName,
    required DateTime fromDate,
    required DateTime toDate,
    required DateFormat dateFormat,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#4F46E5'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Relatório de Progresso',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(
                'MyFit',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Aluno: $studentName',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    'Personal: $trainerName',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Período: ${dateFormat.format(fromDate)} - ${dateFormat.format(toDate)}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    'Gerado em: ${dateFormat.format(DateTime.now())}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Página ${context.pageNumber} de ${context.pagesCount}',
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey600,
        ),
      ),
    );
  }

  static pw.Widget _buildSummarySection(
    Map<String, dynamic> stats,
    List<dynamic> weightLogs,
    List<dynamic> sessions,
  ) {
    final totalSessions = stats['total_sessions'] ?? sessions.length;
    final currentWeight = stats['current_weight'] ?? _getLatestWeight(weightLogs);
    final weightChange = stats['weight_change'];
    final startWeight = stats['start_weight'] ?? _getFirstWeight(weightLogs);

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F3F4F6'),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Treinos', '$totalSessions'),
          _buildStatCard('Peso Atual', '${currentWeight?.toStringAsFixed(1) ?? '-'} kg'),
          _buildStatCard('Peso Inicial', '${startWeight?.toStringAsFixed(1) ?? '-'} kg'),
          _buildStatCard(
            'Variação',
            weightChange != null
                ? '${weightChange > 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg'
                : '-',
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStatCard(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#1F2937'),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.only(bottom: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey300,
            width: 1,
          ),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#374151'),
        ),
      ),
    );
  }

  static pw.Widget _buildWeightTable(List<dynamic> weightLogs, DateFormat dateFormat) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#F9FAFB'),
          ),
          children: [
            _buildTableHeader('Data'),
            _buildTableHeader('Peso (kg)'),
            _buildTableHeader('Variação'),
          ],
        ),
        // Data rows
        ...weightLogs.asMap().entries.map((entry) {
          final index = entry.key;
          final log = entry.value as Map<String, dynamic>;
          final weight = (log['weight'] as num?)?.toDouble();
          final dateStr = log['date'] as String?;
          DateTime? date;
          try {
            date = dateStr != null ? DateTime.parse(dateStr) : null;
          } catch (_) {}

          double? change;
          if (index < weightLogs.length - 1) {
            final prevLog = weightLogs[index + 1] as Map<String, dynamic>;
            final prevWeight = (prevLog['weight'] as num?)?.toDouble();
            if (weight != null && prevWeight != null) {
              change = weight - prevWeight;
            }
          }

          return pw.TableRow(
            children: [
              _buildTableCell(date != null ? dateFormat.format(date) : '-'),
              _buildTableCell(weight?.toStringAsFixed(1) ?? '-'),
              _buildTableCell(
                change != null
                    ? '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}'
                    : '-',
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildMeasurementsTable(
    List<dynamic> measurements,
    DateFormat dateFormat,
  ) {
    if (measurements.isEmpty) {
      return pw.Text('Sem medidas registradas');
    }

    final latest = measurements.first as Map<String, dynamic>;
    final dateStr = latest['date'] as String?;
    DateTime? date;
    try {
      date = dateStr != null ? DateTime.parse(dateStr) : null;
    } catch (_) {}

    final measurementFields = [
      ('Peitoral', 'chest'),
      ('Cintura', 'waist'),
      ('Quadril', 'hips'),
      ('Braço D.', 'right_arm'),
      ('Braço E.', 'left_arm'),
      ('Coxa D.', 'right_thigh'),
      ('Coxa E.', 'left_thigh'),
      ('Panturrilha', 'calf'),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Última medição: ${date != null ? dateFormat.format(date) : '-'}',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F9FAFB'),
              ),
              children: [
                _buildTableHeader('Medida'),
                _buildTableHeader('Valor (cm)'),
              ],
            ),
            ...measurementFields.map((field) {
              final value = latest[field.$2];
              return pw.TableRow(
                children: [
                  _buildTableCell(field.$1),
                  _buildTableCell(value != null ? value.toString() : '-'),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSessionsTable(List<dynamic> sessions, DateFormat dateFormat) {
    final displaySessions = sessions.take(20).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (sessions.length > 20)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Text(
              'Exibindo últimos 20 treinos de ${sessions.length} total',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1.5),
          },
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F9FAFB'),
              ),
              children: [
                _buildTableHeader('Data'),
                _buildTableHeader('Treino'),
                _buildTableHeader('Duração'),
                _buildTableHeader('Status'),
              ],
            ),
            ...displaySessions.map((session) {
              final sessionMap = session as Map<String, dynamic>;
              final dateStr = sessionMap['completed_at'] ?? sessionMap['created_at'];
              DateTime? date;
              try {
                date = dateStr != null ? DateTime.parse(dateStr as String) : null;
              } catch (_) {}

              final workoutName = sessionMap['workout_name'] ?? sessionMap['name'] ?? 'Treino';
              final durationMinutes = sessionMap['duration_minutes'] ?? sessionMap['duration'];
              final status = sessionMap['status'] as String?;

              return pw.TableRow(
                children: [
                  _buildTableCell(date != null ? dateFormat.format(date) : '-'),
                  _buildTableCell(workoutName.toString()),
                  _buildTableCell(durationMinutes != null ? '${durationMinutes}min' : '-'),
                  _buildTableCell(_getStatusLabel(status)),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#374151'),
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 10,
        ),
      ),
    );
  }

  static double? _getLatestWeight(List<dynamic> weightLogs) {
    if (weightLogs.isEmpty) return null;
    final latest = weightLogs.first as Map<String, dynamic>;
    return (latest['weight'] as num?)?.toDouble();
  }

  static double? _getFirstWeight(List<dynamic> weightLogs) {
    if (weightLogs.isEmpty) return null;
    final first = weightLogs.last as Map<String, dynamic>;
    return (first['weight'] as num?)?.toDouble();
  }

  static String _getStatusLabel(String? status) {
    switch (status) {
      case 'completed':
        return 'Completo';
      case 'in_progress':
        return 'Em andamento';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status ?? '-';
    }
  }
}
