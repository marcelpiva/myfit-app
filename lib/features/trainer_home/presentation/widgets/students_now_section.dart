/// Students Now section for trainer home - shows active workout sessions.
library;

import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../shared_session/domain/models/shared_session.dart';
import '../../../shared_session/presentation/providers/shared_session_provider.dart';

/// Section showing students currently working out (real-time).
class StudentsNowSection extends ConsumerWidget {
  final bool isDark;
  final String? organizationId;

  const StudentsNowSection({
    super.key,
    required this.isDark,
    this.organizationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSessionsAsync = ref.watch(activeSessionsProvider(organizationId));

    return activeSessionsAsync.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
      data: (sessions) {
        if (sessions.isEmpty) {
          return _buildEmptyState();
        }
        return _buildSessionsList(context, ref, sessions);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card)
            .withAlpha(isDark ? 150 : 200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card)
            .withAlpha(isDark ? 150 : 200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 20,
            color: AppColors.destructive.withAlpha(150),
          ),
          const SizedBox(width: 12),
          Text(
            'Erro ao carregar alunos',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card)
            .withAlpha(isDark ? 150 : 200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.users,
            size: 20,
            color: AppColors.mutedForeground.withAlpha(150),
          ),
          const SizedBox(width: 12),
          Text(
            'Nenhum aluno treinando no momento',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(
    BuildContext context,
    WidgetRef ref,
    List<ActiveSession> sessions,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sessions.map((session) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _ActiveStudentCard(
              session: session,
              isDark: isDark,
              onTap: () {
                HapticUtils.lightImpact();
                // Navigate to shared session page
                context.push('/sessions/${session.id}?mode=trainer');
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ActiveStudentCard extends StatelessWidget {
  final ActiveSession session;
  final bool isDark;
  final VoidCallback onTap;

  const _ActiveStudentCard({
    required this.session,
    required this.isDark,
    required this.onTap,
  });

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Color _getStatusColor() {
    switch (session.status) {
      case SessionStatus.active:
        return AppColors.success;
      case SessionStatus.paused:
        return AppColors.warning;
      case SessionStatus.waiting:
        return AppColors.info;
      default:
        return AppColors.mutedForeground;
    }
  }

  String _getStatusText() {
    switch (session.status) {
      case SessionStatus.active:
        return 'Treinando';
      case SessionStatus.paused:
        return 'Pausado';
      case SessionStatus.waiting:
        return 'Aguardando';
      default:
        return 'Offline';
    }
  }

  String _formatDuration(DateTime startedAt) {
    final duration = DateTime.now().difference(startedAt);
    if (duration.inMinutes < 1) {
      return 'agora';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}min';
    } else {
      final hours = duration.inHours;
      final mins = duration.inMinutes % 60;
      return '${hours}h ${mins}min';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card)
              .withAlpha(isDark ? 150 : 200),
          border: Border.all(
            color: statusColor.withAlpha(100),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isDark ? AppColors.primaryDark : AppColors.primary,
                        isDark ? AppColors.secondaryDark : AppColors.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(session.studentName),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Live indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Student name
            Text(
              session.studentName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Workout name
            Text(
              session.workoutName ?? 'Treino',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Duration
            Row(
              children: [
                Icon(
                  LucideIcons.timer,
                  size: 12,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(session.startedAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action button
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      session.isShared ? LucideIcons.eye : LucideIcons.userPlus,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      session.isShared ? 'Acompanhar' : 'Entrar',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
