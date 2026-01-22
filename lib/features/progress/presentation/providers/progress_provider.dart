import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/api_exceptions.dart';
import '../../../../core/services/progress_service.dart';

// Service provider
final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});

// ==================== Weight Logs ====================

class WeightLogsState {
  final List<Map<String, dynamic>> logs;
  final Map<String, dynamic>? latest;
  final bool isLoading;
  final String? error;

  const WeightLogsState({
    this.logs = const [],
    this.latest,
    this.isLoading = false,
    this.error,
  });

  WeightLogsState copyWith({
    List<Map<String, dynamic>>? logs,
    Map<String, dynamic>? latest,
    bool? isLoading,
    String? error,
    bool clearLatest = false,
  }) {
    return WeightLogsState(
      logs: logs ?? this.logs,
      latest: clearLatest ? null : (latest ?? this.latest),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WeightLogsNotifier extends StateNotifier<WeightLogsState> {
  final ProgressService _service;

  WeightLogsNotifier(this._service) : super(const WeightLogsState()) {
    loadWeightLogs();
  }

  Future<void> loadWeightLogs({DateTime? fromDate, DateTime? toDate}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _service.getWeightLogs(fromDate: fromDate, toDate: toDate),
        _service.getLatestWeight(),
      ]);

      state = state.copyWith(
        logs: results[0] as List<Map<String, dynamic>>,
        latest: results[1] as Map<String, dynamic>?,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar pesos');
    }
  }

  Future<void> addWeightLog({
    required double weightKg,
    DateTime? loggedAt,
    String? notes,
  }) async {
    try {
      final data = await _service.createWeightLog(
        weightKg: weightKg,
        loggedAt: loggedAt,
        notes: notes,
      );
      state = state.copyWith(
        logs: [data, ...state.logs],
        latest: data,
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> updateWeightLog(String logId, {
    double? weightKg,
    DateTime? loggedAt,
    String? notes,
  }) async {
    try {
      final data = await _service.updateWeightLog(
        logId,
        weightKg: weightKg,
        loggedAt: loggedAt,
        notes: notes,
      );
      state = state.copyWith(
        logs: state.logs.map((l) => l['id'] == logId ? data : l).toList(),
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> deleteWeightLog(String logId) async {
    try {
      await _service.deleteWeightLog(logId);
      state = state.copyWith(
        logs: state.logs.where((l) => l['id'] != logId).toList(),
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  void refresh() => loadWeightLogs();
}

final weightLogsNotifierProvider = StateNotifierProvider<WeightLogsNotifier, WeightLogsState>((ref) {
  final service = ref.watch(progressServiceProvider);
  return WeightLogsNotifier(service);
});

// ==================== Measurement Logs ====================

class MeasurementLogsState {
  final List<Map<String, dynamic>> logs;
  final Map<String, dynamic>? latest;
  final bool isLoading;
  final String? error;

  const MeasurementLogsState({
    this.logs = const [],
    this.latest,
    this.isLoading = false,
    this.error,
  });

  MeasurementLogsState copyWith({
    List<Map<String, dynamic>>? logs,
    Map<String, dynamic>? latest,
    bool? isLoading,
    String? error,
    bool clearLatest = false,
  }) {
    return MeasurementLogsState(
      logs: logs ?? this.logs,
      latest: clearLatest ? null : (latest ?? this.latest),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MeasurementLogsNotifier extends StateNotifier<MeasurementLogsState> {
  final ProgressService _service;

  MeasurementLogsNotifier(this._service) : super(const MeasurementLogsState()) {
    loadMeasurementLogs();
  }

  Future<void> loadMeasurementLogs({DateTime? fromDate, DateTime? toDate}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _service.getMeasurementLogs(fromDate: fromDate, toDate: toDate),
        _service.getLatestMeasurements(),
      ]);

      state = state.copyWith(
        logs: results[0] as List<Map<String, dynamic>>,
        latest: results[1] as Map<String, dynamic>?,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar medidas');
    }
  }

  Future<void> addMeasurementLog({
    DateTime? loggedAt,
    double? chestCm,
    double? waistCm,
    double? hipsCm,
    double? bicepsCm,
    double? thighCm,
    double? calfCm,
    double? neckCm,
    double? forearmCm,
    String? notes,
  }) async {
    try {
      final data = await _service.createMeasurementLog(
        loggedAt: loggedAt,
        chestCm: chestCm,
        waistCm: waistCm,
        hipsCm: hipsCm,
        bicepsCm: bicepsCm,
        thighCm: thighCm,
        calfCm: calfCm,
        neckCm: neckCm,
        forearmCm: forearmCm,
        notes: notes,
      );
      state = state.copyWith(
        logs: [data, ...state.logs],
        latest: data,
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> updateMeasurementLog(String logId, {
    double? chestCm,
    double? waistCm,
    double? hipsCm,
    double? bicepsCm,
    double? thighCm,
    double? calfCm,
    double? neckCm,
    double? forearmCm,
    String? notes,
  }) async {
    try {
      final data = await _service.updateMeasurementLog(
        logId,
        chestCm: chestCm,
        waistCm: waistCm,
        hipsCm: hipsCm,
        bicepsCm: bicepsCm,
        thighCm: thighCm,
        calfCm: calfCm,
        neckCm: neckCm,
        forearmCm: forearmCm,
        notes: notes,
      );
      state = state.copyWith(
        logs: state.logs.map((l) => l['id'] == logId ? data : l).toList(),
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> deleteMeasurementLog(String logId) async {
    try {
      await _service.deleteMeasurementLog(logId);
      state = state.copyWith(
        logs: state.logs.where((l) => l['id'] != logId).toList(),
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  void refresh() => loadMeasurementLogs();
}

final measurementLogsNotifierProvider = StateNotifierProvider<MeasurementLogsNotifier, MeasurementLogsState>((ref) {
  final service = ref.watch(progressServiceProvider);
  return MeasurementLogsNotifier(service);
});

// ==================== Progress Photos ====================

class ProgressPhotosState {
  final List<Map<String, dynamic>> photos;
  final bool isLoading;
  final String? error;

  const ProgressPhotosState({
    this.photos = const [],
    this.isLoading = false,
    this.error,
  });

  ProgressPhotosState copyWith({
    List<Map<String, dynamic>>? photos,
    bool? isLoading,
    String? error,
  }) {
    return ProgressPhotosState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProgressPhotosNotifier extends StateNotifier<ProgressPhotosState> {
  final ProgressService _service;

  ProgressPhotosNotifier(this._service) : super(const ProgressPhotosState()) {
    loadProgressPhotos();
  }

  Future<void> loadProgressPhotos({String? angle, DateTime? fromDate, DateTime? toDate}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final photos = await _service.getProgressPhotos(
        angle: angle,
        fromDate: fromDate,
        toDate: toDate,
      );
      state = state.copyWith(photos: photos, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar fotos');
    }
  }

  Future<void> uploadPhoto({
    required String photoUrl,
    required String angle,
    DateTime? loggedAt,
    String? notes,
    String? weightLogId,
    String? measurementLogId,
  }) async {
    try {
      final data = await _service.uploadProgressPhoto(
        photoUrl: photoUrl,
        angle: angle,
        loggedAt: loggedAt,
        notes: notes,
        weightLogId: weightLogId,
        measurementLogId: measurementLogId,
      );
      state = state.copyWith(photos: [data, ...state.photos]);
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> deletePhoto(String photoId) async {
    try {
      await _service.deleteProgressPhoto(photoId);
      state = state.copyWith(
        photos: state.photos.where((p) => p['id'] != photoId).toList(),
      );
    } on ApiException catch (e) {
      throw e;
    }
  }

  void refresh() => loadProgressPhotos();
}

final progressPhotosNotifierProvider = StateNotifierProvider<ProgressPhotosNotifier, ProgressPhotosState>((ref) {
  final service = ref.watch(progressServiceProvider);
  return ProgressPhotosNotifier(service);
});

// ==================== Weight Goal ====================

class WeightGoalState {
  final Map<String, dynamic>? goal;
  final bool isLoading;
  final String? error;

  const WeightGoalState({
    this.goal,
    this.isLoading = false,
    this.error,
  });

  WeightGoalState copyWith({
    Map<String, dynamic>? goal,
    bool? isLoading,
    String? error,
    bool clearGoal = false,
  }) {
    return WeightGoalState(
      goal: clearGoal ? null : (goal ?? this.goal),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WeightGoalNotifier extends StateNotifier<WeightGoalState> {
  final ProgressService _service;

  WeightGoalNotifier(this._service) : super(const WeightGoalState()) {
    loadWeightGoal();
  }

  Future<void> loadWeightGoal() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final goal = await _service.getWeightGoal();
      state = state.copyWith(goal: goal, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar meta');
    }
  }

  Future<void> setWeightGoal({
    required double targetWeightKg,
    required double startWeightKg,
    DateTime? targetDate,
    String? notes,
  }) async {
    try {
      final goal = await _service.setWeightGoal(
        targetWeightKg: targetWeightKg,
        startWeightKg: startWeightKg,
        targetDate: targetDate,
        notes: notes,
      );
      state = state.copyWith(goal: goal);
    } on ApiException catch (e) {
      throw e;
    }
  }

  Future<void> deleteWeightGoal() async {
    try {
      await _service.deleteWeightGoal();
      state = state.copyWith(clearGoal: true);
    } on ApiException catch (e) {
      throw e;
    }
  }

  void refresh() => loadWeightGoal();
}

final weightGoalNotifierProvider = StateNotifierProvider<WeightGoalNotifier, WeightGoalState>((ref) {
  final service = ref.watch(progressServiceProvider);
  return WeightGoalNotifier(service);
});

// ==================== Progress Stats ====================

class ProgressStatsState {
  final Map<String, dynamic> stats;
  final bool isLoading;
  final String? error;

  const ProgressStatsState({
    this.stats = const {},
    this.isLoading = false,
    this.error,
  });

  ProgressStatsState copyWith({
    Map<String, dynamic>? stats,
    bool? isLoading,
    String? error,
  }) {
    return ProgressStatsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProgressStatsNotifier extends StateNotifier<ProgressStatsState> {
  final ProgressService _service;

  ProgressStatsNotifier(this._service) : super(const ProgressStatsState()) {
    loadProgressStats();
  }

  Future<void> loadProgressStats({int days = 30}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stats = await _service.getProgressStats(days: days);
      state = state.copyWith(stats: stats, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro ao carregar estatísticas');
    }
  }

  void refresh() => loadProgressStats();
}

final progressStatsNotifierProvider = StateNotifierProvider<ProgressStatsNotifier, ProgressStatsState>((ref) {
  final service = ref.watch(progressServiceProvider);
  return ProgressStatsNotifier(service);
});

// ==================== Convenience Providers ====================

// Simple providers for backward compatibility
final weightLogsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(weightLogsNotifierProvider).logs;
});

final latestWeightProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(weightLogsNotifierProvider).latest;
});

final measurementLogsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(measurementLogsNotifierProvider).logs;
});

final latestMeasurementsProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(measurementLogsNotifierProvider).latest;
});

final progressPhotosProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(progressPhotosNotifierProvider).photos;
});

final weightGoalProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(weightGoalNotifierProvider).goal;
});

final progressStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(progressStatsNotifierProvider).stats;
});

// Loading state providers
final isWeightLogsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(weightLogsNotifierProvider).isLoading;
});

final isMeasurementLogsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(measurementLogsNotifierProvider).isLoading;
});

final isProgressPhotosLoadingProvider = Provider<bool>((ref) {
  return ref.watch(progressPhotosNotifierProvider).isLoading;
});

// ==================== Combined Progress Provider ====================

/// Combined progress state for comparison page
class CombinedProgressState {
  final List<Map<String, dynamic>> weightLogs;
  final List<Map<String, dynamic>> measurementLogs;
  final bool isLoading;
  final String? error;

  const CombinedProgressState({
    this.weightLogs = const [],
    this.measurementLogs = const [],
    this.isLoading = false,
    this.error,
  });
}

/// Combined provider for progress comparison
final progressProvider = Provider<CombinedProgressState>((ref) {
  final weightState = ref.watch(weightLogsNotifierProvider);
  final measurementState = ref.watch(measurementLogsNotifierProvider);

  return CombinedProgressState(
    weightLogs: weightState.logs,
    measurementLogs: measurementState.logs,
    isLoading: weightState.isLoading || measurementState.isLoading,
    error: weightState.error ?? measurementState.error,
  );
});
