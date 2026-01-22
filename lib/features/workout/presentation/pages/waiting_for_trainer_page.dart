import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/presentation/components/components.dart';
import '../../../home/presentation/providers/student_home_provider.dart';

/// Waiting screen while student waits for trainer to accept co-training request
class WaitingForTrainerPage extends ConsumerStatefulWidget {
  final String workoutId;
  final String workoutName;
  final String? assignmentId;

  const WaitingForTrainerPage({
    super.key,
    required this.workoutId,
    required this.workoutName,
    this.assignmentId,
  });

  @override
  ConsumerState<WaitingForTrainerPage> createState() =>
      _WaitingForTrainerPageState();
}

class _WaitingForTrainerPageState extends ConsumerState<WaitingForTrainerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String? _sessionId;
  bool _isCreatingSession = true;
  bool _isTrainerJoined = false;
  String? _error;

  Timer? _timeoutTimer;
  Timer? _pollTimer;
  int _waitingSeconds = 0;
  static const int _maxWaitSeconds = 120; // 2 minutes timeout

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _createCoTrainingSession();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timeoutTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _createCoTrainingSession() async {
    try {
      final client = ApiClient.instance;
      final response = await client.post(
        ApiEndpoints.workoutSessions,
        data: {
          'workout_id': widget.workoutId,
          'assignment_id': widget.assignmentId,
          'is_shared': true,
        },
      );

      if (response.statusCode == 201 && response.data != null) {
        final sessionData = response.data as Map<String, dynamic>;
        setState(() {
          _sessionId = sessionData['id'] as String?;
          _isCreatingSession = false;
        });

        // Start waiting timer
        _startWaitingTimer();

        // Start polling for trainer join
        _startPollingForTrainer();
      } else {
        setState(() {
          _error = 'Erro ao criar sessão de co-treino';
          _isCreatingSession = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro de conexão: $e';
        _isCreatingSession = false;
      });
    }
  }

  void _startWaitingTimer() {
    _timeoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _waitingSeconds++;
      });
      if (_waitingSeconds >= _maxWaitSeconds) {
        timer.cancel();
      }
    });
  }

  void _startPollingForTrainer() {
    // Poll every 3 seconds to check if trainer joined
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_sessionId == null) return;

      try {
        final client = ApiClient.instance;
        final response = await client.get(
          ApiEndpoints.workoutSession(_sessionId!),
        );

        if (response.statusCode == 200 && response.data != null) {
          final sessionData = response.data as Map<String, dynamic>;
          final status = sessionData['status'] as String?;
          final trainerId = sessionData['trainer_id'];

          if (status == 'active' && trainerId != null) {
            timer.cancel();
            _timeoutTimer?.cancel();
            HapticUtils.heavyImpact();

            setState(() {
              _isTrainerJoined = true;
            });

            // Small delay to show success animation
            await Future.delayed(const Duration(milliseconds: 800));

            if (mounted) {
              // Navigate to active workout with session ID
              context.go(
                '/workouts/active/${widget.workoutId}?sessionId=$_sessionId',
              );
            }
          }
        }
      } catch (e) {
        // Ignore polling errors, continue polling
      }
    });
  }

  Future<void> _cancelAndTrainAlone() async {
    HapticUtils.mediumImpact();
    _timeoutTimer?.cancel();
    _pollTimer?.cancel();

    // Cancel the co-training session if it was created
    if (_sessionId != null) {
      try {
        await ApiClient.instance.delete(
          ApiEndpoints.workoutSession(_sessionId!),
        );
      } catch (e) {
        // Ignore cancellation errors
      }
    }

    if (mounted) {
      // Navigate to active workout without session ID (solo training)
      context.go('/workouts/active/${widget.workoutId}');
    }
  }

  void _goBack() {
    HapticUtils.lightImpact();
    _timeoutTimer?.cancel();
    _pollTimer?.cancel();

    // Cancel the session
    if (_sessionId != null) {
      ApiClient.instance.delete(
        ApiEndpoints.workoutSession(_sessionId!),
      ).then((_) {}).catchError((_) {});
    }

    if (mounted) {
      context.pop();
    }
  }

  String _formatWaitTime() {
    final minutes = _waitingSeconds ~/ 60;
    final seconds = _waitingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dashboardState = ref.watch(studentDashboardProvider);
    final trainer = dashboardState.trainer;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withAlpha(isDark ? 30 : 20),
              AppColors.secondary.withAlpha(isDark ? 25 : 15),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _goBack,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDark.withAlpha(150)
                              : AppColors.card.withAlpha(200),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                        child: Icon(
                          LucideIcons.arrowLeft,
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

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated pulse icon
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isTrainerJoined ? 1.0 : _pulseAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: _isTrainerJoined
                                    ? AppColors.success.withAlpha(30)
                                    : AppColors.primary.withAlpha(25),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isTrainerJoined
                                            ? AppColors.success
                                            : AppColors.primary)
                                        .withAlpha(50),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isTrainerJoined
                                    ? LucideIcons.checkCircle
                                    : _isCreatingSession
                                        ? LucideIcons.loader2
                                        : LucideIcons.userCheck,
                                size: 48,
                                color: _isTrainerJoined
                                    ? AppColors.success
                                    : (isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primary),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Status text
                      if (_error != null) ...[
                        Text(
                          'Erro',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.destructive,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ] else if (_isCreatingSession) ...[
                        Text(
                          'Criando sessão...',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aguarde enquanto preparamos seu treino',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ] else if (_isTrainerJoined) ...[
                        Text(
                          'Personal conectado!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${trainer?.name ?? "Seu personal"} aceitou acompanhar seu treino',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        Text(
                          'Aguardando Personal',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          trainer != null
                              ? '${trainer.name} foi notificado e pode aceitar acompanhar seu treino'
                              : 'Seu personal foi notificado da sua solicitação',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Waiting timer
                      if (!_isCreatingSession && !_isTrainerJoined && _error == null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.cardDark.withAlpha(150)
                                : AppColors.card.withAlpha(200),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.clock,
                                size: 18,
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForeground,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Aguardando há ${_formatWaitTime()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Workout info
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDark.withAlpha(100)
                              : AppColors.card.withAlpha(150),
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                LucideIcons.dumbbell,
                                size: 20,
                                color: isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Treino',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.mutedForegroundDark
                                          : AppColors.mutedForeground,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.workoutName,
                                    style: TextStyle(
                                      fontSize: 15,
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
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom actions
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (!_isCreatingSession && !_isTrainerJoined && _error == null) ...[
                      // Hint text
                      if (_waitingSeconds >= 60)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Você pode iniciar o treino sozinho a qualquer momento',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Train alone button
                      SecondaryButton(
                        label: 'Treinar Sozinho',
                        icon: LucideIcons.play,
                        onPressed: _cancelAndTrainAlone,
                      ),
                    ] else if (_error != null) ...[
                      PrimaryButton(
                        label: 'Tentar Novamente',
                        icon: LucideIcons.refreshCw,
                        onPressed: () {
                          setState(() {
                            _error = null;
                            _isCreatingSession = true;
                          });
                          _createCoTrainingSession();
                        },
                      ),
                      const SizedBox(height: 12),
                      SecondaryButton(
                        label: 'Treinar Sozinho',
                        icon: LucideIcons.play,
                        onPressed: () {
                          if (mounted) {
                            context.go('/workouts/active/${widget.workoutId}');
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
