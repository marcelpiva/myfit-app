import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/haptic_utils.dart';

/// Timer mode types
enum TimerMode {
  /// Rest timer - counts down from a set time
  rest,

  /// AMRAP - As Many Reps As Possible (counts up)
  amrap,

  /// Tabata - 20s work / 10s rest intervals
  tabata,

  /// EMOM - Every Minute On the Minute (resets every minute)
  emom,

  /// Custom interval
  interval,

  /// Stopwatch - counts up indefinitely
  stopwatch,

  // ==================== Technique-specific modes ====================

  /// Drop Set - very short rest (10-20s) between weight drops
  dropSet,

  /// Rest-Pause - short rest (10-15s) between mini-sets
  restPause,

  /// Cluster - short rest (15-20s) between clusters
  cluster,

  /// Superset/Biset/Triset/Giantset - rest between exercise groups
  superset,
}

/// Timer phase for interval timers
enum TimerPhase {
  work,
  rest,
}

/// Timer state
class WorkoutTimerState {
  final TimerMode mode;
  final int currentSeconds;
  final int totalSeconds;
  final TimerPhase phase;
  final int currentRound;
  final int totalRounds;
  final bool isRunning;
  final bool isCompleted;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const WorkoutTimerState({
    this.mode = TimerMode.rest,
    this.currentSeconds = 0,
    this.totalSeconds = 60,
    this.phase = TimerPhase.work,
    this.currentRound = 1,
    this.totalRounds = 1,
    this.isRunning = false,
    this.isCompleted = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  WorkoutTimerState copyWith({
    TimerMode? mode,
    int? currentSeconds,
    int? totalSeconds,
    TimerPhase? phase,
    int? currentRound,
    int? totalRounds,
    bool? isRunning,
    bool? isCompleted,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return WorkoutTimerState(
      mode: mode ?? this.mode,
      currentSeconds: currentSeconds ?? this.currentSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      phase: phase ?? this.phase,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  /// Progress as a value between 0 and 1
  double get progress {
    if (mode == TimerMode.stopwatch || mode == TimerMode.amrap) {
      return 0; // No progress for count-up timers
    }
    if (totalSeconds == 0) return 0;
    return currentSeconds / totalSeconds;
  }

  /// Formatted time string (MM:SS or just SS)
  String get formattedTime {
    if (currentSeconds < 60) {
      return '$currentSeconds';
    }
    final minutes = currentSeconds ~/ 60;
    final seconds = currentSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formatted time string always showing minutes
  String get formattedTimeWithMinutes {
    final minutes = currentSeconds ~/ 60;
    final seconds = currentSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Workout timer notifier
class WorkoutTimerNotifier extends StateNotifier<WorkoutTimerState> {
  Timer? _timer;
  final void Function()? onComplete;
  final void Function(TimerPhase phase)? onPhaseChange;

  // Tabata defaults
  static const tabataWorkSeconds = 20;
  static const tabataRestSeconds = 10;
  static const tabataDefaultRounds = 8;

  // EMOM default
  static const emomDefaultMinutes = 1;

  // Technique-specific defaults
  static const dropSetRestSeconds = 15;      // Short rest between drops
  static const restPauseRestSeconds = 12;    // Very short rest in rest-pause
  static const clusterRestSeconds = 20;      // Inter-cluster rest
  static const supersetRestSeconds = 90;     // Rest between supersets

  WorkoutTimerNotifier({
    this.onComplete,
    this.onPhaseChange,
  }) : super(const WorkoutTimerState());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Start a rest timer
  void startRestTimer(int seconds) {
    _timer?.cancel();
    state = state.copyWith(
      mode: TimerMode.rest,
      currentSeconds: seconds,
      totalSeconds: seconds,
      phase: TimerPhase.rest,
      currentRound: 1,
      totalRounds: 1,
      isRunning: true,
      isCompleted: false,
    );
    _startCountdown();
  }

  /// Start an AMRAP timer (counts up)
  void startAmrapTimer(int durationMinutes) {
    _timer?.cancel();
    final totalSec = durationMinutes * 60;
    state = state.copyWith(
      mode: TimerMode.amrap,
      currentSeconds: 0,
      totalSeconds: totalSec,
      phase: TimerPhase.work,
      currentRound: 1,
      totalRounds: 1,
      isRunning: true,
      isCompleted: false,
    );
    _startCountUp(maxSeconds: totalSec);
  }

  /// Start a Tabata timer (20s work / 10s rest)
  void startTabataTimer({int rounds = tabataDefaultRounds}) {
    _timer?.cancel();
    state = state.copyWith(
      mode: TimerMode.tabata,
      currentSeconds: tabataWorkSeconds,
      totalSeconds: tabataWorkSeconds,
      phase: TimerPhase.work,
      currentRound: 1,
      totalRounds: rounds,
      isRunning: true,
      isCompleted: false,
    );
    _startTabata();
  }

  /// Start an EMOM timer
  void startEmomTimer({int totalMinutes = 10}) {
    _timer?.cancel();
    state = state.copyWith(
      mode: TimerMode.emom,
      currentSeconds: 60,
      totalSeconds: 60,
      phase: TimerPhase.work,
      currentRound: 1,
      totalRounds: totalMinutes,
      isRunning: true,
      isCompleted: false,
    );
    _startEmom();
  }

  /// Start a custom interval timer
  void startIntervalTimer({
    required int workSeconds,
    required int restSeconds,
    required int rounds,
  }) {
    _timer?.cancel();
    state = state.copyWith(
      mode: TimerMode.interval,
      currentSeconds: workSeconds,
      totalSeconds: workSeconds,
      phase: TimerPhase.work,
      currentRound: 1,
      totalRounds: rounds,
      isRunning: true,
      isCompleted: false,
    );
    _startInterval(workSeconds, restSeconds);
  }

  /// Start a stopwatch (counts up indefinitely)
  void startStopwatch() {
    _timer?.cancel();
    state = state.copyWith(
      mode: TimerMode.stopwatch,
      currentSeconds: 0,
      totalSeconds: 0,
      phase: TimerPhase.work,
      currentRound: 1,
      totalRounds: 1,
      isRunning: true,
      isCompleted: false,
    );
    _startCountUp();
  }

  // ==================== Technique-Specific Timers ====================

  /// Start a Drop Set timer - short rest between weight drops
  void startDropSetTimer({int seconds = dropSetRestSeconds, int drops = 3}) {
    _timer?.cancel();
    state = state.copyWith(
      mode: TimerMode.dropSet,
      currentSeconds: seconds,
      totalSeconds: seconds,
      phase: TimerPhase.rest,
      currentRound: 1,
      totalRounds: drops - 1, // Rests between drops
      isRunning: true,
      isCompleted: false,
    );
    _startCountdown();
  }

  /// Start a Rest-Pause timer - very short rest between mini-sets
  void startRestPauseTimer({int seconds = restPauseRestSeconds, int pauseCount = 2}) {
    _timer?.cancel();
    state = state.copyWith(
      mode: TimerMode.restPause,
      currentSeconds: seconds,
      totalSeconds: seconds,
      phase: TimerPhase.rest,
      currentRound: 1,
      totalRounds: pauseCount,
      isRunning: true,
      isCompleted: false,
    );
    _startCountdown();
  }

  /// Start a Cluster timer - inter-cluster rest
  void startClusterTimer({int seconds = clusterRestSeconds, int clusters = 4}) {
    _timer?.cancel();
    state = state.copyWith(
      mode: TimerMode.cluster,
      currentSeconds: seconds,
      totalSeconds: seconds,
      phase: TimerPhase.rest,
      currentRound: 1,
      totalRounds: clusters - 1, // Rests between clusters
      isRunning: true,
      isCompleted: false,
    );
    _startCountdown();
  }

  /// Start a Superset/Biset/Triset/Giantset timer - rest between exercise groups
  void startSupersetTimer({int seconds = supersetRestSeconds, int sets = 3}) {
    _timer?.cancel();
    state = state.copyWith(
      mode: TimerMode.superset,
      currentSeconds: seconds,
      totalSeconds: seconds,
      phase: TimerPhase.rest,
      currentRound: 1,
      totalRounds: sets,
      isRunning: true,
      isCompleted: false,
    );
    _startCountdown();
  }

  /// Pause the timer
  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  /// Resume the timer
  void resume() {
    if (!state.isRunning && !state.isCompleted) {
      state = state.copyWith(isRunning: true);

      switch (state.mode) {
        case TimerMode.rest:
        case TimerMode.dropSet:
        case TimerMode.restPause:
        case TimerMode.cluster:
        case TimerMode.superset:
          _startCountdown();
          break;
        case TimerMode.amrap:
          _startCountUp(maxSeconds: state.totalSeconds);
          break;
        case TimerMode.tabata:
          _startTabata();
          break;
        case TimerMode.emom:
          _startEmom();
          break;
        case TimerMode.interval:
          // Would need to track work/rest seconds
          _startCountdown();
          break;
        case TimerMode.stopwatch:
          _startCountUp();
          break;
      }
    }
  }

  /// Add time to the current timer
  void addTime(int seconds) {
    if (state.mode == TimerMode.rest || state.mode == TimerMode.emom) {
      state = state.copyWith(
        currentSeconds: state.currentSeconds + seconds,
        totalSeconds: state.totalSeconds + seconds,
      );
    }
  }

  /// Subtract time from the current timer
  void subtractTime(int seconds) {
    if (state.mode == TimerMode.rest || state.mode == TimerMode.emom) {
      final newCurrent = (state.currentSeconds - seconds).clamp(1, state.currentSeconds);
      state = state.copyWith(
        currentSeconds: newCurrent,
      );
    }
  }

  /// Skip to the next phase/round
  void skip() {
    _timer?.cancel();
    _notifyVibration();

    switch (state.mode) {
      case TimerMode.rest:
      case TimerMode.stopwatch:
      case TimerMode.dropSet:
      case TimerMode.restPause:
      case TimerMode.cluster:
      case TimerMode.superset:
        _complete();
        break;
      case TimerMode.tabata:
        _advanceTabata();
        break;
      case TimerMode.emom:
        _advanceEmom();
        break;
      case TimerMode.amrap:
        _complete();
        break;
      case TimerMode.interval:
        _advanceInterval();
        break;
    }
  }

  /// Stop and reset the timer
  void stop() {
    _timer?.cancel();
    state = const WorkoutTimerState();
  }

  /// Toggle sound
  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
  }

  /// Toggle vibration
  void toggleVibration() {
    state = state.copyWith(vibrationEnabled: !state.vibrationEnabled);
  }

  // ==================== Private Methods ====================

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.currentSeconds > 1) {
        state = state.copyWith(currentSeconds: state.currentSeconds - 1);

        // Warning haptic at 3 seconds
        if (state.currentSeconds == 3) {
          _notifyVibration(light: true);
        }
      } else {
        _timer?.cancel();
        _notifyVibration();
        _complete();
      }
    });
  }

  void _startCountUp({int? maxSeconds}) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final newSeconds = state.currentSeconds + 1;

      if (maxSeconds != null && newSeconds >= maxSeconds) {
        _timer?.cancel();
        state = state.copyWith(currentSeconds: maxSeconds);
        _notifyVibration();
        _complete();
      } else {
        state = state.copyWith(currentSeconds: newSeconds);
      }
    });
  }

  void _startTabata() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.currentSeconds > 1) {
        state = state.copyWith(currentSeconds: state.currentSeconds - 1);

        if (state.currentSeconds == 3) {
          _notifyVibration(light: true);
        }
      } else {
        _advanceTabata();
      }
    });
  }

  void _advanceTabata() {
    _timer?.cancel();
    _notifyVibration();

    if (state.phase == TimerPhase.work) {
      // Switch to rest
      state = state.copyWith(
        phase: TimerPhase.rest,
        currentSeconds: tabataRestSeconds,
        totalSeconds: tabataRestSeconds,
      );
      onPhaseChange?.call(TimerPhase.rest);
      _startTabata();
    } else {
      // Switch to work or complete
      if (state.currentRound >= state.totalRounds) {
        _complete();
      } else {
        state = state.copyWith(
          phase: TimerPhase.work,
          currentSeconds: tabataWorkSeconds,
          totalSeconds: tabataWorkSeconds,
          currentRound: state.currentRound + 1,
        );
        onPhaseChange?.call(TimerPhase.work);
        _startTabata();
      }
    }
  }

  void _startEmom() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.currentSeconds > 1) {
        state = state.copyWith(currentSeconds: state.currentSeconds - 1);

        if (state.currentSeconds == 3) {
          _notifyVibration(light: true);
        }
      } else {
        _advanceEmom();
      }
    });
  }

  void _advanceEmom() {
    _timer?.cancel();
    _notifyVibration();

    if (state.currentRound >= state.totalRounds) {
      _complete();
    } else {
      state = state.copyWith(
        currentSeconds: 60,
        currentRound: state.currentRound + 1,
      );
      onPhaseChange?.call(TimerPhase.work);
      _startEmom();
    }
  }

  void _startInterval(int workSeconds, int restSeconds) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.currentSeconds > 1) {
        state = state.copyWith(currentSeconds: state.currentSeconds - 1);

        if (state.currentSeconds == 3) {
          _notifyVibration(light: true);
        }
      } else {
        _advanceInterval(workSeconds: workSeconds, restSeconds: restSeconds);
      }
    });
  }

  void _advanceInterval({int workSeconds = 30, int restSeconds = 15}) {
    _timer?.cancel();
    _notifyVibration();

    if (state.phase == TimerPhase.work) {
      state = state.copyWith(
        phase: TimerPhase.rest,
        currentSeconds: restSeconds,
        totalSeconds: restSeconds,
      );
      onPhaseChange?.call(TimerPhase.rest);
      _startCountdown();
    } else {
      if (state.currentRound >= state.totalRounds) {
        _complete();
      } else {
        state = state.copyWith(
          phase: TimerPhase.work,
          currentSeconds: workSeconds,
          totalSeconds: workSeconds,
          currentRound: state.currentRound + 1,
        );
        onPhaseChange?.call(TimerPhase.work);
        _startCountdown();
      }
    }
  }

  void _complete() {
    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      isCompleted: true,
      currentSeconds: 0,
    );
    onComplete?.call();
  }

  void _notifyVibration({bool light = false}) {
    if (state.vibrationEnabled) {
      if (light) {
        HapticUtils.lightImpact();
      } else {
        HapticUtils.mediumImpact();
      }
    }
  }
}

/// Provider for the workout timer
final workoutTimerProvider =
    StateNotifierProvider.autoDispose<WorkoutTimerNotifier, WorkoutTimerState>((ref) {
  return WorkoutTimerNotifier();
});

/// Provider with callbacks
final workoutTimerWithCallbacksProvider = StateNotifierProvider.autoDispose
    .family<WorkoutTimerNotifier, WorkoutTimerState, ({void Function()? onComplete, void Function(TimerPhase)? onPhaseChange})>(
  (ref, callbacks) {
    return WorkoutTimerNotifier(
      onComplete: callbacks.onComplete,
      onPhaseChange: callbacks.onPhaseChange,
    );
  },
);
