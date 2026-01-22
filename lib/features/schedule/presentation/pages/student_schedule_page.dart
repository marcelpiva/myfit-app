import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../providers/student_schedule_provider.dart';
import '../widgets/reschedule_request_sheet.dart';
import '../widgets/session_card_student.dart';

/// Schedule page for students - shows their sessions with trainers
class StudentSchedulePage extends ConsumerStatefulWidget {
  const StudentSchedulePage({super.key});

  @override
  ConsumerState<StudentSchedulePage> createState() => _StudentSchedulePageState();
}

class _StudentSchedulePageState extends ConsumerState<StudentSchedulePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

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

  Future<void> _onRefresh() async {
    await ref.read(studentScheduleProvider.notifier).loadSessions();
  }

  void _showRescheduleSheet(StudentSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RescheduleRequestSheet(
        session: session,
        onSubmit: (preferredDateTime, reason) async {
          final success = await ref.read(studentScheduleProvider.notifier).requestReschedule(
                session.id,
                preferredDateTime: preferredDateTime,
                reason: reason,
              );
          if (success && mounted) {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Solicitação de reagendamento enviada'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _confirmSession(StudentSession session) async {
    final success = await ref.read(studentScheduleProvider.notifier).confirmSession(session.id);
    if (success && mounted) {
      HapticUtils.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sessão confirmada com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(studentScheduleProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(isDark ? 15 : 10),
              (isDark ? AppColors.secondaryDark : AppColors.secondary).withAlpha(isDark ? 12 : 8),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
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
                                color: isDark ? AppColors.cardDark : AppColors.card,
                                borderRadius: BorderRadius.circular(10),
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
                              'Minha Agenda',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content
                  if (state.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.error != null)
                    SliverFillRemaining(
                      child: _ErrorView(
                        error: state.error!,
                        onRetry: _onRefresh,
                        isDark: isDark,
                      ),
                    )
                  else if (state.sessions.isEmpty)
                    SliverFillRemaining(
                      child: _EmptyView(isDark: isDark),
                    )
                  else ...[
                    // Pending confirmations section
                    if (state.pendingSessions.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                          child: FadeInUp(
                            child: _PendingConfirmationsBanner(
                              count: state.pendingSessions.length,
                              isDark: isDark,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Next session highlight
                    if (state.nextSession != null) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                          child: FadeInUp(
                            child: Text(
                              'Próxima Sessão',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: FadeInUp(
                            delay: const Duration(milliseconds: 50),
                            child: SessionCardStudent(
                              session: state.nextSession!,
                              isDark: isDark,
                              onConfirm: state.nextSession!.needsConfirmation
                                  ? () => _confirmSession(state.nextSession!)
                                  : null,
                              onReschedule: () => _showRescheduleSheet(state.nextSession!),
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Upcoming sessions
                    if (state.upcomingSessions.length > 1) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                          child: FadeInUp(
                            delay: const Duration(milliseconds: 100),
                            child: Text(
                              'Próximas Sessões',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              // Skip the first one (already shown as "next")
                              final session = state.upcomingSessions[index + 1];
                              return FadeInUp(
                                delay: Duration(milliseconds: 150 + (index * 50)),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: SessionCardStudent(
                                    session: session,
                                    isDark: isDark,
                                    onConfirm: session.needsConfirmation
                                        ? () => _confirmSession(session)
                                        : null,
                                    onReschedule: () => _showRescheduleSheet(session),
                                  ),
                                ),
                              );
                            },
                            childCount: state.upcomingSessions.length - 1,
                          ),
                        ),
                      ),
                    ],

                    // Past sessions (show last 5)
                    if (_getPastSessions(state).isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                          child: Text(
                            'Sessões Anteriores',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final session = _getPastSessions(state)[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Opacity(
                                  opacity: 0.7,
                                  child: SessionCardStudent(
                                    session: session,
                                    isDark: isDark,
                                  ),
                                ),
                              );
                            },
                            childCount: _getPastSessions(state).take(5).length,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<StudentSession> _getPastSessions(StudentScheduleState state) {
    return state.sessions
        .where((s) => !s.isUpcoming && s.status != 'cancelled')
        .toList()
      ..sort((a, b) {
        final aDate = DateTime(a.date.year, a.date.month, a.date.day, a.time.hour, a.time.minute);
        final bDate = DateTime(b.date.year, b.date.month, b.date.day, b.time.hour, b.time.minute);
        return bDate.compareTo(aDate);
      });
  }
}

class _PendingConfirmationsBanner extends StatelessWidget {
  final int count;
  final bool isDark;

  const _PendingConfirmationsBanner({
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(isDark ? 30 : 20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.warning.withAlpha(50),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.alertCircle,
              size: 18,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count ${count == 1 ? 'sessão aguarda' : 'sessões aguardam'} confirmação',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Confirme sua presença para os treinos agendados',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final bool isDark;

  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: AppColors.destructive,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool isDark;

  const _EmptyView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                LucideIcons.calendar,
                size: 40,
                color: AppColors.primary.withAlpha(100),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma sessão agendada',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seus treinos com o Personal aparecerão aqui quando forem agendados.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
