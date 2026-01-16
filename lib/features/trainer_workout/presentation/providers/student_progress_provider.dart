import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/trainer_service.dart';

// ==================== Models ====================

/// Weight entry for student progress
class WeightEntry {
  final String id;
  final double weight;
  final String date;
  final double change;

  const WeightEntry({
    required this.id,
    required this.weight,
    required this.date,
    required this.change,
  });

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: json['id']?.toString() ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      date: json['formatted_date'] ?? json['date'] ?? '',
      change: (json['change'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'weight': weight,
        'date': date,
        'change': change,
      };
}

/// Body measurement
class Measurement {
  final String label;
  final double value;
  final String unit;
  final double change;

  const Measurement({
    required this.label,
    required this.value,
    required this.unit,
    required this.change,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      label: json['label'] ?? json['name'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] ?? 'cm',
      change: (json['change'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Progress photo
class ProgressPhoto {
  final String id;
  final String date;
  final String weight;
  final String? note;
  final String? imageUrl;

  const ProgressPhoto({
    required this.id,
    required this.date,
    required this.weight,
    this.note,
    this.imageUrl,
  });

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) {
    return ProgressPhoto(
      id: json['id']?.toString() ?? '',
      date: json['formatted_date'] ?? json['date'] ?? '',
      weight: json['weight_at_photo'] ?? json['weight'] ?? '',
      note: json['note'],
      imageUrl: json['image_url'] ?? json['url'],
    );
  }

  Map<String, dynamic> toMap() => {
        'date': date,
        'weight': weight,
        'note': note,
      };
}

/// Trainer note about student
class TrainerNote {
  final String id;
  final String date;
  final String content;

  const TrainerNote({
    required this.id,
    required this.date,
    required this.content,
  });

  factory TrainerNote.fromJson(Map<String, dynamic> json) {
    return TrainerNote(
      id: json['id']?.toString() ?? '',
      date: json['formatted_date'] ?? json['date'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

/// Student progress summary
class StudentProgressSummary {
  final DateTime? startDate;
  final int durationDays;
  final double currentWeight;
  final double goalWeight;
  final double totalChange;
  final double initialWeight;

  const StudentProgressSummary({
    this.startDate,
    this.durationDays = 0,
    this.currentWeight = 0,
    this.goalWeight = 0,
    this.totalChange = 0,
    this.initialWeight = 0,
  });

  factory StudentProgressSummary.fromJson(Map<String, dynamic> json) {
    return StudentProgressSummary(
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'])
          : null,
      durationDays: (json['duration_days'] ?? json['duration'] ?? 0) as int,
      currentWeight: (json['current_weight'] as num?)?.toDouble() ?? 0,
      goalWeight: (json['goal_weight'] as num?)?.toDouble() ?? 0,
      totalChange: (json['total_change'] as num?)?.toDouble() ?? 0,
      initialWeight: (json['initial_weight'] as num?)?.toDouble() ?? 0,
    );
  }

  String get formattedStartDate {
    if (startDate == null) return '-';
    final months = [
      '',
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return '${startDate!.day.toString().padLeft(2, '0')} ${months[startDate!.month]}';
  }

  String get formattedDuration => '$durationDays dias';

  double get remainingToGoal => currentWeight - goalWeight;
}

// ==================== State ====================

class StudentProgressState {
  final StudentProgressSummary summary;
  final List<WeightEntry> weightEntries;
  final List<Measurement> measurements;
  final List<ProgressPhoto> photos;
  final List<TrainerNote> notes;
  final List<double> chartValues;
  final List<String> chartLabels;
  final String? lastMeasurementDate;
  final bool isLoading;
  final String? error;

  const StudentProgressState({
    this.summary = const StudentProgressSummary(),
    this.weightEntries = const [],
    this.measurements = const [],
    this.photos = const [],
    this.notes = const [],
    this.chartValues = const [],
    this.chartLabels = const [],
    this.lastMeasurementDate,
    this.isLoading = false,
    this.error,
  });

  StudentProgressState copyWith({
    StudentProgressSummary? summary,
    List<WeightEntry>? weightEntries,
    List<Measurement>? measurements,
    List<ProgressPhoto>? photos,
    List<TrainerNote>? notes,
    List<double>? chartValues,
    List<String>? chartLabels,
    String? lastMeasurementDate,
    bool? isLoading,
    String? error,
  }) {
    return StudentProgressState(
      summary: summary ?? this.summary,
      weightEntries: weightEntries ?? this.weightEntries,
      measurements: measurements ?? this.measurements,
      photos: photos ?? this.photos,
      notes: notes ?? this.notes,
      chartValues: chartValues ?? this.chartValues,
      chartLabels: chartLabels ?? this.chartLabels,
      lastMeasurementDate: lastMeasurementDate ?? this.lastMeasurementDate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get photoCount => photos.length;
}

// ==================== Notifier ====================

class StudentProgressNotifier extends StateNotifier<StudentProgressState> {
  final TrainerService _service;
  final String studentId;

  StudentProgressNotifier(this._service, this.studentId)
      : super(const StudentProgressState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getStudentProgress(studentId);

      // Parse summary
      final summary = StudentProgressSummary.fromJson(data);

      // Parse weight entries
      final weightData = data['weight_entries'] as List<dynamic>? ?? [];
      final weightEntries =
          weightData.map((e) => WeightEntry.fromJson(e as Map<String, dynamic>)).toList();

      // Parse measurements
      final measurementData = data['measurements'] as List<dynamic>? ?? [];
      final measurements = measurementData
          .map((e) => Measurement.fromJson(e as Map<String, dynamic>))
          .toList();

      // Parse photos
      final photoData = data['photos'] as List<dynamic>? ?? [];
      final photos =
          photoData.map((e) => ProgressPhoto.fromJson(e as Map<String, dynamic>)).toList();

      // Parse notes
      final noteData = data['notes'] as List<dynamic>? ?? [];
      final notes =
          noteData.map((e) => TrainerNote.fromJson(e as Map<String, dynamic>)).toList();

      // Parse chart data
      final chartValues = (data['chart_values'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [];
      final chartLabels = (data['chart_labels'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      state = state.copyWith(
        summary: summary,
        weightEntries: weightEntries,
        measurements: measurements,
        photos: photos,
        notes: notes,
        chartValues: chartValues,
        chartLabels: chartLabels,
        lastMeasurementDate: data['last_measurement_date'] as String?,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar progresso do aluno',
      );
    }
  }

  Future<void> refresh() async => loadAll();

  Future<bool> addNote(String content) async {
    try {
      await _service.addStudentNote(studentId, content);
      await loadAll();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// ==================== Providers ====================

final trainerServiceProvider = Provider<TrainerService>((ref) {
  return TrainerService();
});

final studentProgressNotifierProvider = StateNotifierProvider.family<
    StudentProgressNotifier, StudentProgressState, String>((ref, studentId) {
  final service = ref.watch(trainerServiceProvider);
  return StudentProgressNotifier(service, studentId);
});

// Convenience providers
final studentWeightEntriesProvider =
    Provider.family<List<WeightEntry>, String>((ref, studentId) {
  return ref.watch(studentProgressNotifierProvider(studentId)).weightEntries;
});

final studentMeasurementsProvider =
    Provider.family<List<Measurement>, String>((ref, studentId) {
  return ref.watch(studentProgressNotifierProvider(studentId)).measurements;
});

final studentPhotosProvider =
    Provider.family<List<ProgressPhoto>, String>((ref, studentId) {
  return ref.watch(studentProgressNotifierProvider(studentId)).photos;
});

final studentNotesProvider =
    Provider.family<List<TrainerNote>, String>((ref, studentId) {
  return ref.watch(studentProgressNotifierProvider(studentId)).notes;
});

final isStudentProgressLoadingProvider =
    Provider.family<bool, String>((ref, studentId) {
  return ref.watch(studentProgressNotifierProvider(studentId)).isLoading;
});
