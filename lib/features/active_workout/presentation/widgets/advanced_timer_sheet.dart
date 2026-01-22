import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/services/workout_timer_service.dart';

/// Advanced timer bottom sheet with multiple modes
class AdvancedTimerSheet extends ConsumerStatefulWidget {
  final int? initialRestSeconds;
  final VoidCallback? onComplete;

  const AdvancedTimerSheet({
    super.key,
    this.initialRestSeconds,
    this.onComplete,
  });

  @override
  ConsumerState<AdvancedTimerSheet> createState() => _AdvancedTimerSheetState();
}

class _AdvancedTimerSheetState extends ConsumerState<AdvancedTimerSheet> {
  TimerMode _selectedMode = TimerMode.rest;
  int _restSeconds = 60;
  int _amrapMinutes = 10;
  int _tabataRounds = 8;
  int _emomMinutes = 10;
  int _intervalWorkSeconds = 30;
  int _intervalRestSeconds = 15;
  int _intervalRounds = 5;

  // Technique-specific settings
  int _dropSetRestSeconds = 15;
  int _dropSetDrops = 3;
  int _restPauseSeconds = 12;
  int _restPausePauses = 2;
  int _clusterRestSeconds = 20;
  int _clusterCount = 4;
  int _supersetRestSeconds = 90;
  int _supersetSets = 3;

  @override
  void initState() {
    super.initState();
    if (widget.initialRestSeconds != null) {
      _restSeconds = widget.initialRestSeconds!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timerState = ref.watch(workoutTimerProvider);
    final timerNotifier = ref.read(workoutTimerProvider.notifier);

    // If timer is running, show the running view
    if (timerState.isRunning || timerState.isCompleted) {
      return _buildRunningTimer(context, isDark, timerState, timerNotifier);
    }

    // Otherwise show the setup view
    return _buildSetupView(context, isDark, timerNotifier);
  }

  Widget _buildSetupView(BuildContext context, bool isDark, WorkoutTimerNotifier timerNotifier) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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

            // Title
            Text(
              'Timer de Treino',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecione o modo e configure o timer',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),

            const SizedBox(height: 24),

            // Mode selector
            Text(
              'Modo',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Standard modes
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ModeChip(
                  icon: LucideIcons.pause,
                  label: 'Descanso',
                  isSelected: _selectedMode == TimerMode.rest,
                  onTap: () => setState(() => _selectedMode = TimerMode.rest),
                  isDark: isDark,
                ),
                _ModeChip(
                  icon: LucideIcons.repeat,
                  label: 'AMRAP',
                  isSelected: _selectedMode == TimerMode.amrap,
                  onTap: () => setState(() => _selectedMode = TimerMode.amrap),
                  isDark: isDark,
                ),
                _ModeChip(
                  icon: LucideIcons.zap,
                  label: 'Tabata',
                  isSelected: _selectedMode == TimerMode.tabata,
                  onTap: () => setState(() => _selectedMode = TimerMode.tabata),
                  isDark: isDark,
                ),
                _ModeChip(
                  icon: LucideIcons.clock,
                  label: 'EMOM',
                  isSelected: _selectedMode == TimerMode.emom,
                  onTap: () => setState(() => _selectedMode = TimerMode.emom),
                  isDark: isDark,
                ),
                _ModeChip(
                  icon: LucideIcons.timer,
                  label: 'Intervalo',
                  isSelected: _selectedMode == TimerMode.interval,
                  onTap: () => setState(() => _selectedMode = TimerMode.interval),
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Technique-specific modes
            Text(
              'Técnicas Avançadas',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ModeChip(
                  icon: LucideIcons.arrowDown,
                  label: 'Drop Set',
                  isSelected: _selectedMode == TimerMode.dropSet,
                  onTap: () => setState(() => _selectedMode = TimerMode.dropSet),
                  isDark: isDark,
                  color: const Color(0xFF2563EB),
                ),
                _ModeChip(
                  icon: LucideIcons.pauseCircle,
                  label: 'Rest-Pause',
                  isSelected: _selectedMode == TimerMode.restPause,
                  onTap: () => setState(() => _selectedMode = TimerMode.restPause),
                  isDark: isDark,
                  color: const Color(0xFF14B8A6),
                ),
                _ModeChip(
                  icon: LucideIcons.boxes,
                  label: 'Cluster',
                  isSelected: _selectedMode == TimerMode.cluster,
                  onTap: () => setState(() => _selectedMode = TimerMode.cluster),
                  isDark: isDark,
                  color: const Color(0xFF4F46E5),
                ),
                _ModeChip(
                  icon: LucideIcons.link,
                  label: 'Superset',
                  isSelected: _selectedMode == TimerMode.superset,
                  onTap: () => setState(() => _selectedMode = TimerMode.superset),
                  isDark: isDark,
                  color: const Color(0xFFEC4899),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Mode-specific settings
            _buildModeSettings(isDark),

            const SizedBox(height: 32),

            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticUtils.mediumImpact();
                  _startTimer(timerNotifier);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.play, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Iniciar Timer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSettings(bool isDark) {
    switch (_selectedMode) {
      case TimerMode.rest:
        return _RestSettings(
          seconds: _restSeconds,
          onChanged: (v) => setState(() => _restSeconds = v),
          isDark: isDark,
        );
      case TimerMode.amrap:
        return _AmrapSettings(
          minutes: _amrapMinutes,
          onChanged: (v) => setState(() => _amrapMinutes = v),
          isDark: isDark,
        );
      case TimerMode.tabata:
        return _TabataSettings(
          rounds: _tabataRounds,
          onChanged: (v) => setState(() => _tabataRounds = v),
          isDark: isDark,
        );
      case TimerMode.emom:
        return _EmomSettings(
          minutes: _emomMinutes,
          onChanged: (v) => setState(() => _emomMinutes = v),
          isDark: isDark,
        );
      case TimerMode.interval:
        return _IntervalSettings(
          workSeconds: _intervalWorkSeconds,
          restSeconds: _intervalRestSeconds,
          rounds: _intervalRounds,
          onWorkChanged: (v) => setState(() => _intervalWorkSeconds = v),
          onRestChanged: (v) => setState(() => _intervalRestSeconds = v),
          onRoundsChanged: (v) => setState(() => _intervalRounds = v),
          isDark: isDark,
        );
      case TimerMode.stopwatch:
        return const SizedBox.shrink();

      // Technique-specific modes
      case TimerMode.dropSet:
        return _TechniqueSettings(
          title: 'Drop Set',
          description: 'Descanso curto entre reduções de carga',
          restSeconds: _dropSetRestSeconds,
          count: _dropSetDrops,
          countLabel: 'Drops',
          restPresets: const [10, 15, 20, 30],
          countPresets: const [2, 3, 4, 5],
          onRestChanged: (v) => setState(() => _dropSetRestSeconds = v),
          onCountChanged: (v) => setState(() => _dropSetDrops = v),
          isDark: isDark,
          color: const Color(0xFF2563EB),
        );
      case TimerMode.restPause:
        return _TechniqueSettings(
          title: 'Rest-Pause',
          description: 'Micro descansos para continuar o set',
          restSeconds: _restPauseSeconds,
          count: _restPausePauses,
          countLabel: 'Pausas',
          restPresets: const [10, 12, 15, 20],
          countPresets: const [1, 2, 3, 4],
          onRestChanged: (v) => setState(() => _restPauseSeconds = v),
          onCountChanged: (v) => setState(() => _restPausePauses = v),
          isDark: isDark,
          color: const Color(0xFF14B8A6),
        );
      case TimerMode.cluster:
        return _TechniqueSettings(
          title: 'Cluster Set',
          description: 'Descanso entre mini-séries de alta intensidade',
          restSeconds: _clusterRestSeconds,
          count: _clusterCount,
          countLabel: 'Clusters',
          restPresets: const [15, 20, 25, 30],
          countPresets: const [3, 4, 5, 6],
          onRestChanged: (v) => setState(() => _clusterRestSeconds = v),
          onCountChanged: (v) => setState(() => _clusterCount = v),
          isDark: isDark,
          color: const Color(0xFF4F46E5),
        );
      case TimerMode.superset:
        return _TechniqueSettings(
          title: 'Superset / Bi-Set / Tri-Set',
          description: 'Descanso entre grupos de exercícios',
          restSeconds: _supersetRestSeconds,
          count: _supersetSets,
          countLabel: 'Séries',
          restPresets: const [60, 90, 120, 150],
          countPresets: const [2, 3, 4, 5],
          onRestChanged: (v) => setState(() => _supersetRestSeconds = v),
          onCountChanged: (v) => setState(() => _supersetSets = v),
          isDark: isDark,
          color: const Color(0xFFEC4899),
        );
    }
  }

  void _startTimer(WorkoutTimerNotifier timerNotifier) {
    switch (_selectedMode) {
      case TimerMode.rest:
        timerNotifier.startRestTimer(_restSeconds);
        break;
      case TimerMode.amrap:
        timerNotifier.startAmrapTimer(_amrapMinutes);
        break;
      case TimerMode.tabata:
        timerNotifier.startTabataTimer(rounds: _tabataRounds);
        break;
      case TimerMode.emom:
        timerNotifier.startEmomTimer(totalMinutes: _emomMinutes);
        break;
      case TimerMode.interval:
        timerNotifier.startIntervalTimer(
          workSeconds: _intervalWorkSeconds,
          restSeconds: _intervalRestSeconds,
          rounds: _intervalRounds,
        );
        break;
      case TimerMode.stopwatch:
        timerNotifier.startStopwatch();
        break;
      // Technique-specific modes
      case TimerMode.dropSet:
        timerNotifier.startDropSetTimer(
          seconds: _dropSetRestSeconds,
          drops: _dropSetDrops,
        );
        break;
      case TimerMode.restPause:
        timerNotifier.startRestPauseTimer(
          seconds: _restPauseSeconds,
          pauseCount: _restPausePauses,
        );
        break;
      case TimerMode.cluster:
        timerNotifier.startClusterTimer(
          seconds: _clusterRestSeconds,
          clusters: _clusterCount,
        );
        break;
      case TimerMode.superset:
        timerNotifier.startSupersetTimer(
          seconds: _supersetRestSeconds,
          sets: _supersetSets,
        );
        break;
    }
  }

  Widget _buildRunningTimer(
    BuildContext context,
    bool isDark,
    WorkoutTimerState timerState,
    WorkoutTimerNotifier timerNotifier,
  ) {
    final theme = Theme.of(context);
    final isWork = timerState.phase == TimerPhase.work;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 24),

              // Mode indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isWork
                      ? AppColors.success.withAlpha(20)
                      : AppColors.warning.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getModeIcon(timerState.mode),
                      size: 16,
                      color: isWork ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getPhaseLabel(timerState),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isWork ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Timer display
              SizedBox(
                width: 250,
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (isWork ? AppColors.success : AppColors.warning).withAlpha(40),
                          width: 12,
                        ),
                      ),
                    ),

                    // Progress indicator
                    if (timerState.mode != TimerMode.stopwatch &&
                        timerState.mode != TimerMode.amrap)
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CircularProgressIndicator(
                          value: timerState.progress,
                          strokeWidth: 12,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(
                            isWork ? AppColors.success : AppColors.warning,
                          ),
                          strokeCap: StrokeCap.round,
                        ),
                      ),

                    // Timer text
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          timerState.formattedTimeWithMinutes,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 64,
                            color: isWork ? AppColors.success : AppColors.warning,
                          ),
                        ),
                        if (timerState.totalRounds > 1)
                          Text(
                            'Round ${timerState.currentRound}/${timerState.totalRounds}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Controls
              if (timerState.isCompleted) ...[
                // Completed state
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.checkCircle, color: AppColors.success),
                      const SizedBox(width: 12),
                      Text(
                        'Timer Completo!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        timerNotifier.stop();
                        widget.onComplete?.call();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Fechar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Running controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Add time
                    if (timerState.mode == TimerMode.rest ||
                        timerState.mode == TimerMode.emom)
                      _ControlButton(
                        icon: LucideIcons.minus,
                        label: '-15s',
                        onTap: () {
                          HapticUtils.lightImpact();
                          timerNotifier.subtractTime(15);
                        },
                        isDark: isDark,
                      ),

                    const SizedBox(width: 16),

                    // Pause/Resume
                    _ControlButton(
                      icon: timerState.isRunning ? LucideIcons.pause : LucideIcons.play,
                      label: timerState.isRunning ? 'Pausar' : 'Continuar',
                      onTap: () {
                        HapticUtils.lightImpact();
                        if (timerState.isRunning) {
                          timerNotifier.pause();
                        } else {
                          timerNotifier.resume();
                        }
                      },
                      isDark: isDark,
                      isPrimary: true,
                    ),

                    const SizedBox(width: 16),

                    // Add time
                    if (timerState.mode == TimerMode.rest ||
                        timerState.mode == TimerMode.emom)
                      _ControlButton(
                        icon: LucideIcons.plus,
                        label: '+15s',
                        onTap: () {
                          HapticUtils.lightImpact();
                          timerNotifier.addTime(15);
                        },
                        isDark: isDark,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Skip button
                TextButton.icon(
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    timerNotifier.skip();
                  },
                  icon: const Icon(LucideIcons.skipForward, size: 18),
                  label: const Text('Pular'),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),

                const SizedBox(height: 16),

                // Stop button
                TextButton.icon(
                  onPressed: () {
                    HapticUtils.mediumImpact();
                    timerNotifier.stop();
                    Navigator.of(context).pop();
                  },
                  icon: Icon(LucideIcons.x, size: 18, color: AppColors.destructive),
                  label: Text('Cancelar', style: TextStyle(color: AppColors.destructive)),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getModeIcon(TimerMode mode) {
    switch (mode) {
      case TimerMode.rest:
        return LucideIcons.pause;
      case TimerMode.amrap:
        return LucideIcons.repeat;
      case TimerMode.tabata:
        return LucideIcons.zap;
      case TimerMode.emom:
        return LucideIcons.clock;
      case TimerMode.interval:
        return LucideIcons.timer;
      case TimerMode.stopwatch:
        return LucideIcons.watch;
      case TimerMode.dropSet:
        return LucideIcons.arrowDown;
      case TimerMode.restPause:
        return LucideIcons.pauseCircle;
      case TimerMode.cluster:
        return LucideIcons.boxes;
      case TimerMode.superset:
        return LucideIcons.link;
    }
  }

  String _getPhaseLabel(WorkoutTimerState state) {
    final modeLabels = {
      TimerMode.rest: 'DESCANSO',
      TimerMode.amrap: 'AMRAP',
      TimerMode.tabata: state.phase == TimerPhase.work ? 'TRABALHO' : 'DESCANSO',
      TimerMode.emom: 'EMOM',
      TimerMode.interval: state.phase == TimerPhase.work ? 'TRABALHO' : 'DESCANSO',
      TimerMode.stopwatch: 'STOPWATCH',
      TimerMode.dropSet: 'DROP SET',
      TimerMode.restPause: 'REST-PAUSE',
      TimerMode.cluster: 'CLUSTER',
      TimerMode.superset: 'SUPERSET',
    };
    return modeLabels[state.mode] ?? 'TIMER';
  }
}

// ==================== Mode Chips ====================

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color? color;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: () {
        HapticUtils.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor
              : (isDark ? AppColors.cardDark : AppColors.card),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (color ?? (isDark ? AppColors.foregroundDark : AppColors.foreground)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Control Buttons ====================

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool isPrimary;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : AppColors.card),
          borderRadius: BorderRadius.circular(14),
          border: isPrimary
              ? null
              : Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary
                  ? Colors.white
                  : (isDark ? AppColors.foregroundDark : AppColors.foreground),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Settings Widgets ====================

class _RestSettings extends StatelessWidget {
  final int seconds;
  final ValueChanged<int> onChanged;
  final bool isDark;

  const _RestSettings({
    required this.seconds,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Tempo de Descanso',
      isDark: isDark,
      child: _TimeSelector(
        value: seconds,
        onChanged: onChanged,
        presets: const [30, 45, 60, 90, 120, 180],
        unit: 's',
        isDark: isDark,
      ),
    );
  }
}

class _AmrapSettings extends StatelessWidget {
  final int minutes;
  final ValueChanged<int> onChanged;
  final bool isDark;

  const _AmrapSettings({
    required this.minutes,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Duração do AMRAP',
      isDark: isDark,
      child: _TimeSelector(
        value: minutes,
        onChanged: onChanged,
        presets: const [5, 8, 10, 12, 15, 20],
        unit: 'min',
        isDark: isDark,
      ),
    );
  }
}

class _TabataSettings extends StatelessWidget {
  final int rounds;
  final ValueChanged<int> onChanged;
  final bool isDark;

  const _TabataSettings({
    required this.rounds,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SettingsCard(
      title: 'Configuração Tabata',
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '20s trabalho / 10s descanso',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 12),
          _TimeSelector(
            value: rounds,
            onChanged: onChanged,
            presets: const [4, 6, 8, 10, 12],
            unit: 'rounds',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _EmomSettings extends StatelessWidget {
  final int minutes;
  final ValueChanged<int> onChanged;
  final bool isDark;

  const _EmomSettings({
    required this.minutes,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Minutos de EMOM',
      isDark: isDark,
      child: _TimeSelector(
        value: minutes,
        onChanged: onChanged,
        presets: const [5, 8, 10, 12, 15, 20],
        unit: 'min',
        isDark: isDark,
      ),
    );
  }
}

class _IntervalSettings extends StatelessWidget {
  final int workSeconds;
  final int restSeconds;
  final int rounds;
  final ValueChanged<int> onWorkChanged;
  final ValueChanged<int> onRestChanged;
  final ValueChanged<int> onRoundsChanged;
  final bool isDark;

  const _IntervalSettings({
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
    required this.onWorkChanged,
    required this.onRestChanged,
    required this.onRoundsChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingsCard(
          title: 'Trabalho',
          isDark: isDark,
          child: _TimeSelector(
            value: workSeconds,
            onChanged: onWorkChanged,
            presets: const [20, 30, 40, 45, 60],
            unit: 's',
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 12),
        _SettingsCard(
          title: 'Descanso',
          isDark: isDark,
          child: _TimeSelector(
            value: restSeconds,
            onChanged: onRestChanged,
            presets: const [10, 15, 20, 30],
            unit: 's',
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 12),
        _SettingsCard(
          title: 'Rounds',
          isDark: isDark,
          child: _TimeSelector(
            value: rounds,
            onChanged: onRoundsChanged,
            presets: const [3, 5, 8, 10, 12],
            unit: 'x',
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;

  const _SettingsCard({
    required this.title,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark.withAlpha(150) : AppColors.card.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final List<int> presets;
  final String unit;
  final bool isDark;

  const _TimeSelector({
    required this.value,
    required this.onChanged,
    required this.presets,
    required this.unit,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((preset) {
        final isSelected = preset == value;
        return GestureDetector(
          onTap: () {
            HapticUtils.selectionClick();
            onChanged(preset);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.backgroundDark : AppColors.background),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.borderDark : AppColors.border),
              ),
            ),
            child: Text(
              '$preset$unit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ==================== Technique Settings Widget ====================

class _TechniqueSettings extends StatelessWidget {
  final String title;
  final String description;
  final int restSeconds;
  final int count;
  final String countLabel;
  final List<int> restPresets;
  final List<int> countPresets;
  final ValueChanged<int> onRestChanged;
  final ValueChanged<int> onCountChanged;
  final bool isDark;
  final Color color;

  const _TechniqueSettings({
    required this.title,
    required this.description,
    required this.restSeconds,
    required this.count,
    required this.countLabel,
    required this.restPresets,
    required this.countPresets,
    required this.onRestChanged,
    required this.onCountChanged,
    required this.isDark,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 30 : 20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  LucideIcons.info,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rest time
          Text(
            'Tempo de descanso',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _TimeSelector(
            value: restSeconds,
            onChanged: onRestChanged,
            presets: restPresets,
            unit: 's',
            isDark: isDark,
          ),

          const SizedBox(height: 16),

          // Count
          Text(
            countLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _TimeSelector(
            value: count,
            onChanged: onCountChanged,
            presets: countPresets,
            unit: 'x',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

/// Helper function to show the timer sheet
Future<void> showAdvancedTimerSheet(
  BuildContext context, {
  int? initialRestSeconds,
  VoidCallback? onComplete,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AdvancedTimerSheet(
      initialRestSeconds: initialRestSeconds,
      onComplete: onComplete,
    ),
  );
}
