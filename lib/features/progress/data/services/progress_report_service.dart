import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Service for generating progress report PDFs
class ProgressReportService {
  /// Generate a progress report PDF
  static Future<Uint8List> generateReport({
    required String userName,
    required List<WeightEntry> weightEntries,
    required List<MeasurementEntry> measurementEntries,
    required DateTime startDate,
    required DateTime endDate,
    String? trainerName,
    String? organizationName,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final primaryColor = PdfColor.fromHex('#6366F1');
    final accentColor = PdfColor.fromHex('#10B981');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(
          userName: userName,
          startDate: startDate,
          endDate: endDate,
          trainerName: trainerName,
          organizationName: organizationName,
          dateFormat: dateFormat,
          primaryColor: primaryColor,
        ),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          // Summary section
          _buildSummarySection(
            weightEntries: weightEntries,
            measurementEntries: measurementEntries,
            primaryColor: primaryColor,
            accentColor: accentColor,
          ),

          pw.SizedBox(height: 20),

          // Weight section
          if (weightEntries.isNotEmpty) ...[
            _buildSectionTitle('Evolução do Peso', primaryColor),
            pw.SizedBox(height: 10),
            _buildWeightTable(weightEntries, dateFormat),
            pw.SizedBox(height: 20),
          ],

          // Measurements section
          if (measurementEntries.isNotEmpty) ...[
            _buildSectionTitle('Evolução das Medidas', primaryColor),
            pw.SizedBox(height: 10),
            _buildMeasurementsTable(measurementEntries, dateFormat),
          ],
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader({
    required String userName,
    required DateTime startDate,
    required DateTime endDate,
    String? trainerName,
    String? organizationName,
    required DateFormat dateFormat,
    required PdfColor primaryColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Relatório de Progresso',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                userName,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
          if (organizationName != null || trainerName != null)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (organizationName != null)
                  pw.Text(
                    organizationName,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                if (trainerName != null) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Personal: $trainerName',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Gerado por MyFit',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey500,
            ),
          ),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummarySection({
    required List<WeightEntry> weightEntries,
    required List<MeasurementEntry> measurementEntries,
    required PdfColor primaryColor,
    required PdfColor accentColor,
  }) {
    // Calculate weight change
    double? weightChange;
    double? startWeight;
    double? currentWeight;
    if (weightEntries.length >= 2) {
      final sorted = List<WeightEntry>.from(weightEntries)
        ..sort((a, b) => a.date.compareTo(b.date));
      startWeight = sorted.first.weight;
      currentWeight = sorted.last.weight;
      weightChange = currentWeight - startWeight;
    }

    // Calculate measurement changes
    Map<String, double> measurementChanges = {};
    if (measurementEntries.length >= 2) {
      final sorted = List<MeasurementEntry>.from(measurementEntries)
        ..sort((a, b) => a.date.compareTo(b.date));
      final first = sorted.first;
      final last = sorted.last;

      if (first.waist != null && last.waist != null) {
        measurementChanges['Cintura'] = last.waist! - first.waist!;
      }
      if (first.chest != null && last.chest != null) {
        measurementChanges['Peito'] = last.chest! - first.chest!;
      }
      if (first.hips != null && last.hips != null) {
        measurementChanges['Quadril'] = last.hips! - first.hips!;
      }
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Resumo do Período',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: primaryColor,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildSummaryCard(
                  title: 'Peso Inicial',
                  value: startWeight != null ? '${startWeight.toStringAsFixed(1)} kg' : '-',
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: _buildSummaryCard(
                  title: 'Peso Atual',
                  value: currentWeight != null ? '${currentWeight.toStringAsFixed(1)} kg' : '-',
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: _buildSummaryCard(
                  title: 'Variação',
                  value: weightChange != null
                      ? '${weightChange > 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg'
                      : '-',
                  valueColor: weightChange != null
                      ? (weightChange < 0 ? accentColor : PdfColors.orange)
                      : null,
                ),
              ),
            ],
          ),
          if (measurementChanges.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text(
              'Variação nas Medidas:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Wrap(
              spacing: 16,
              runSpacing: 8,
              children: measurementChanges.entries.map((e) {
                final isNegative = e.value < 0;
                return pw.Text(
                  '${e.key}: ${e.value > 0 ? '+' : ''}${e.value.toStringAsFixed(1)} cm',
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: isNegative ? accentColor : PdfColors.orange,
                    fontWeight: pw.FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryCard({
    required String title,
    required String value,
    PdfColor? valueColor,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title, PdfColor color) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: color,
      ),
    );
  }

  static pw.Widget _buildWeightTable(
    List<WeightEntry> entries,
    DateFormat dateFormat,
  ) {
    final sorted = List<WeightEntry>.from(entries)
      ..sort((a, b) => b.date.compareTo(a.date));

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Data', isHeader: true),
            _buildTableCell('Peso (kg)', isHeader: true),
            _buildTableCell('Variação', isHeader: true),
          ],
        ),
        // Data rows
        ...sorted.asMap().entries.map((entry) {
          final current = entry.value;
          final nextIndex = entry.key + 1;
          String change = '-';

          if (nextIndex < sorted.length) {
            final diff = current.weight - sorted[nextIndex].weight;
            change = '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg';
          }

          return pw.TableRow(
            children: [
              _buildTableCell(dateFormat.format(current.date)),
              _buildTableCell(current.weight.toStringAsFixed(1)),
              _buildTableCell(change),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildMeasurementsTable(
    List<MeasurementEntry> entries,
    DateFormat dateFormat,
  ) {
    final sorted = List<MeasurementEntry>.from(entries)
      ..sort((a, b) => b.date.compareTo(a.date));

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Data', isHeader: true, flex: 2),
            _buildTableCell('Peito', isHeader: true),
            _buildTableCell('Cintura', isHeader: true),
            _buildTableCell('Quadril', isHeader: true),
            _buildTableCell('Braço E', isHeader: true),
            _buildTableCell('Braço D', isHeader: true),
            _buildTableCell('Coxa E', isHeader: true),
            _buildTableCell('Coxa D', isHeader: true),
          ],
        ),
        // Data rows
        ...sorted.map((entry) {
          return pw.TableRow(
            children: [
              _buildTableCell(dateFormat.format(entry.date), flex: 2),
              _buildTableCell(entry.chest?.toStringAsFixed(1) ?? '-'),
              _buildTableCell(entry.waist?.toStringAsFixed(1) ?? '-'),
              _buildTableCell(entry.hips?.toStringAsFixed(1) ?? '-'),
              _buildTableCell(entry.leftArm?.toStringAsFixed(1) ?? '-'),
              _buildTableCell(entry.rightArm?.toStringAsFixed(1) ?? '-'),
              _buildTableCell(entry.leftThigh?.toStringAsFixed(1) ?? '-'),
              _buildTableCell(entry.rightThigh?.toStringAsFixed(1) ?? '-'),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    int flex = 1,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: isHeader ? pw.FontWeight.bold : null,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }
}

/// Weight entry data for PDF report
class WeightEntry {
  final DateTime date;
  final double weight;
  final String? notes;

  const WeightEntry({
    required this.date,
    required this.weight,
    this.notes,
  });
}

/// Measurement entry data for PDF report
class MeasurementEntry {
  final DateTime date;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? leftArm;
  final double? rightArm;
  final double? leftThigh;
  final double? rightThigh;
  final double? leftCalf;
  final double? rightCalf;

  const MeasurementEntry({
    required this.date,
    this.chest,
    this.waist,
    this.hips,
    this.leftArm,
    this.rightArm,
    this.leftThigh,
    this.rightThigh,
    this.leftCalf,
    this.rightCalf,
  });
}
