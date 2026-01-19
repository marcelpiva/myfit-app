import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../../domain/models/check_in.dart';
import '../../domain/models/checkin_target.dart';
import '../providers/checkin_context_provider.dart';
import '../providers/checkin_provider.dart';
import '../widgets/checkin_stats_card.dart';

/// Smart Check-in Page que se adapta ao contexto do usuario
class SmartCheckinPage extends ConsumerStatefulWidget {
  const SmartCheckinPage({super.key});

  @override
  ConsumerState<SmartCheckinPage> createState() => _SmartCheckinPageState();
}

class _SmartCheckinPageState extends ConsumerState<SmartCheckinPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final checkInContext = ref.watch(checkInContextProvider);
    final stats = ref.watch(checkInStatsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withAlpha(isDark ? 15 : 10),
              AppColors.secondary.withAlpha(isDark ? 12 : 8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, isDark, checkInContext),

              // Role tabs (Student / Trainer)
              _buildRoleTabs(isDark),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Student View
                    _StudentCheckinView(context: checkInContext, stats: stats),

                    // Trainer View
                    const _TrainerCheckinView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, CheckInContext checkInContext) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              context.pop();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check-in',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                if (checkInContext.hasNearbyGym)
                  Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${checkInContext.nearbyGymName} - ${checkInContext.distanceToGym?.toInt()}m',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Pending confirmations badge
          if (checkInContext.hasPendingConfirmations)
            GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
                _showPendingConfirmations(context, isDark, checkInContext);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(25),
                  border: Border.all(color: AppColors.warning),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        LucideIcons.bell,
                        size: 20,
                        color: AppColors.warning,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${checkInContext.pendingConfirmations.length}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoleTabs(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelColor: AppColors.primary,
        unselectedLabelColor: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        onTap: (index) {
          HapticUtils.selectionClick();
        },
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.user, size: 18),
                SizedBox(width: 8),
                Text('Aluno'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.userCog, size: 18),
                SizedBox(width: 8),
                Text('Personal'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPendingConfirmations(BuildContext context, bool isDark, CheckInContext checkInContext) {
    HapticUtils.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.bell, size: 24, color: AppColors.warning),
                  const SizedBox(width: 12),
                  Text(
                    'Confirmações Pendentes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...checkInContext.pendingConfirmations.map((confirmation) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.mutedDark.withAlpha(150)
                        : AppColors.muted.withAlpha(200),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                confirmation.requesterName[0].toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  confirmation.requesterName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                  ),
                                ),
                                Text(
                                  'ha ${confirmation.waitingTime.inMinutes} minutos',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (confirmation.message != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          confirmation.message!,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticUtils.lightImpact();
                                Navigator.pop(context);
                                // Rejeitar
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.destructive),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'Recusar',
                                    style: TextStyle(
                                      color: AppColors.destructive,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticUtils.mediumImpact();
                                Navigator.pop(context);
                                // Confirmar
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Confirmar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STUDENT VIEW
// ============================================================

class _StudentCheckinView extends ConsumerWidget {
  final CheckInContext context;
  final CheckInStats stats;

  const _StudentCheckinView({
    required this.context,
    required this.stats,
  });

  @override
  Widget build(BuildContext buildContext, WidgetRef ref) {
    final isDark = Theme.of(buildContext).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sessão próxima (se houver)
          if (context.hasUpcomingSession) ...[
            FadeInUp(
              child: _buildUpcomingSession(buildContext, isDark, context.nextSession!),
            ),
            const SizedBox(height: 24),
          ],

          // Opções de check-in
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Como deseja fazer check-in?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Check-in cards
          FadeInUp(
            delay: const Duration(milliseconds: 150),
            child: _buildCheckinOptions(buildContext, isDark),
          ),

          const SizedBox(height: 24),

          // Aulas disponíveis
          if (context.availableClasses.isNotEmpty) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildAvailableClasses(buildContext, isDark),
            ),
            const SizedBox(height: 24),
          ],

          // Stats
          FadeInUp(
            delay: const Duration(milliseconds: 250),
            child: CheckinStatsCard(stats: stats),
          ),

          const SizedBox(height: 24),

          // Métodos alternativos
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildAlternativeMethods(buildContext, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSession(BuildContext context, bool isDark, ScheduledSession session) {
    final timeUntil = session.timeUntilStart;
    final isStartingSoon = timeUntil.inMinutes <= 30 && timeUntil.inMinutes > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withAlpha(200),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isStartingSoon ? LucideIcons.clock : LucideIcons.calendar,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isStartingSoon
                          ? 'Comeca em ${timeUntil.inMinutes} min'
                          : 'Agendado',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (session.trainerName != null)
                Row(
                  children: [
                    const Icon(LucideIcons.user, size: 14, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      session.trainerName!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            session.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(LucideIcons.building2, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                session.gymName ?? 'Academia',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                HapticUtils.mediumImpact();
                _startSessionCheckin(context, session);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.play, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Fazer Check-in para Sessão',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startSessionCheckin(BuildContext context, ScheduledSession session) {
    HapticUtils.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      isScrollControlled: true,
      builder: (ctx) => _SessionCheckinSheet(session: session),
    );
  }

  Widget _buildCheckinOptions(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Treino livre (so academia)
        _buildCheckinCard(
          context,
          isDark,
          icon: LucideIcons.dumbbell,
          title: 'Treino Livre',
          subtitle: 'Check-in apenas na academia',
          color: AppColors.accent,
          targets: [CheckInTargetType.gym],
          onTap: () => _doQuickCheckin(context, CheckInType.freeTraining),
        ),
        const SizedBox(height: 12),
        // Sessão com Personal
        _buildCheckinCard(
          context,
          isDark,
          icon: LucideIcons.users,
          title: 'Sessão com Personal',
          subtitle: 'Academia + Personal Trainer',
          color: AppColors.primary,
          targets: [CheckInTargetType.gym, CheckInTargetType.trainer],
          onTap: () => _selectTrainerForSession(context, isDark),
        ),
      ],
    );
  }

  Widget _buildCheckinCard(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required List<CheckInTargetType> targets,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Target badges
                  Row(
                    children: targets.map((t) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getTargetLabel(t),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 24,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  String _getTargetLabel(CheckInTargetType type) {
    switch (type) {
      case CheckInTargetType.gym:
        return 'Academia';
      case CheckInTargetType.trainer:
        return 'Personal';
      case CheckInTargetType.student:
        return 'Aluno';
      case CheckInTargetType.groupClass:
        return 'Aula';
      case CheckInTargetType.session:
        return 'Sessão';
      case CheckInTargetType.equipment:
        return 'Equipamento';
    }
  }

  void _doQuickCheckin(BuildContext context, CheckInType type) {
    HapticUtils.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Text('Check-in realizado com sucesso!'),
          ],
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _selectTrainerForSession(BuildContext context, bool isDark) {
    HapticUtils.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecione o Personal',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 20),
              _buildTrainerOption(ctx, isDark, 'Joao Silva', 'Personal Trainer', true),
              const SizedBox(height: 12),
              _buildTrainerOption(ctx, isDark, 'Ana Costa', 'Personal Trainer', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainerOption(BuildContext context, bool isDark, String name, String role, bool isAvailable) {
    return GestureDetector(
      onTap: isAvailable ? () {
        HapticUtils.lightImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solicitação enviada para $name', style: const TextStyle(color: Colors.white)),
            backgroundColor: AppColors.success,
          ),
        );
      } : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.mutedDark.withAlpha(150)
              : AppColors.muted.withAlpha(200),
          border: Border.all(
            color: isAvailable ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.border),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name[0],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isAvailable ? AppColors.success.withAlpha(25) : AppColors.warning.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isAvailable ? 'Disponível' : 'Ocupado',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isAvailable ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableClasses(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aulas Disponíveis',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        ...this.context.availableClasses.map((cls) {
          final spotsLeft = (cls.classCapacity ?? 0) - (cls.classEnrolled ?? 0);
          return GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.users, size: 24, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cls.className ?? cls.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(LucideIcons.clock, size: 12, color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                            const SizedBox(width: 4),
                            Text(
                              '${cls.scheduledAt.hour}:${cls.scheduledAt.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(LucideIcons.users, size: 12, color: spotsLeft <= 3 ? AppColors.warning : AppColors.success),
                            const SizedBox(width: 4),
                            Text(
                              '$spotsLeft vagas',
                              style: TextStyle(
                                fontSize: 13,
                                color: spotsLeft <= 3 ? AppColors.warning : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticUtils.lightImpact();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAlternativeMethods(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Outros Métodos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMethodButton(
                context,
                isDark,
                LucideIcons.scanLine,
                'QR Code',
                () {
                  HapticUtils.lightImpact();
                  context.push(RouteNames.qrScanner);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMethodButton(
                context,
                isDark,
                LucideIcons.hash,
                'Código',
                () {
                  HapticUtils.lightImpact();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMethodButton(
                context,
                isDark,
                LucideIcons.history,
                'Histórico',
                () {
                  HapticUtils.lightImpact();
                  context.push(RouteNames.checkinHistory);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodButton(BuildContext context, bool isDark, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: isDark ? AppColors.foregroundDark : AppColors.foreground),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TRAINER VIEW
// ============================================================

class _TrainerCheckinView extends ConsumerWidget {
  const _TrainerCheckinView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trainerContext = ref.watch(trainerContextProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Confirmacoes pendentes
          if (trainerContext.pendingConfirmations.isNotEmpty) ...[
            FadeInUp(
              child: _buildPendingSection(context, isDark, trainerContext),
            ),
            const SizedBox(height: 24),
          ],

          // Sessoes de hoje
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: _buildTodaySessions(context, isDark, trainerContext),
          ),

          const SizedBox(height: 24),

          // Acoes rapidas
          FadeInUp(
            delay: const Duration(milliseconds: 150),
            child: _buildQuickActions(context, isDark),
          ),

          const SizedBox(height: 24),

          // Lista de alunos
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildStudentsList(context, isDark, trainerContext),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSection(BuildContext context, bool isDark, TrainerContext trainerContext) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(25),
        border: Border.all(color: AppColors.warning),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.bell, size: 20, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                '${trainerContext.pendingConfirmations.length} Solicitações Pendentes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...trainerContext.pendingConfirmations.take(2).map((c) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${c.requesterName} solicitou check-in',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticUtils.lightImpact();
                    },
                    child: Text('Ver', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTodaySessions(BuildContext context, bool isDark, TrainerContext trainerContext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sessões de Hoje',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
              },
              child: Row(
                children: [
                  Icon(LucideIcons.plus, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('Agendar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (trainerContext.todaySessions.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardDark.withAlpha(150)
                  : AppColors.card.withAlpha(200),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    LucideIcons.calendarOff,
                    size: 40,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhuma sessão agendada',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...trainerContext.todaySessions.map((session) {
            final timeUntil = session.timeUntilStart;
            final isNext = timeUntil.inMinutes > 0 && timeUntil.inMinutes <= 60;

            return GestureDetector(
              onTap: () {
                HapticUtils.lightImpact();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardDark.withAlpha(150)
                      : AppColors.card.withAlpha(200),
                  border: Border.all(
                    color: isNext ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.border),
                    width: isNext ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${session.scheduledAt.hour}:${session.scheduledAt.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.studentName ?? 'Aluno',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                          Text(
                            session.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticUtils.mediumImpact();
                        // Iniciar sessão
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Iniciar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                isDark,
                LucideIcons.qrCode,
                'Gerar QR',
                'Para alunos escanearem',
                AppColors.primary,
                () {
                  HapticUtils.lightImpact();
                  context.push(RouteNames.qrGenerator);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                isDark,
                LucideIcons.userPlus,
                'Check-in Avulso',
                'Registrar manualmente',
                AppColors.secondary,
                () {
                  HapticUtils.lightImpact();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList(BuildContext context, bool isDark, TrainerContext trainerContext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Meus Alunos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            Text(
              '${trainerContext.activeStudents}/${trainerContext.totalStudents} ativos',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...trainerContext.students.map((student) {
          return GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        student.name[0],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              student.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                              ),
                            ),
                            if (student.hasSessionToday) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Hoje',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          student.currentPlan ?? 'Sem treino ativo',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.flame, size: 14, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text(
                            '${student.weeklyCheckIns}/sem',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ============================================================
// SESSION CHECKIN SHEET
// ============================================================

class _SessionCheckinSheet extends StatelessWidget {
  final ScheduledSession session;

  const _SessionCheckinSheet({required this.session});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Session info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                border: Border.all(color: AppColors.primary.withAlpha(30)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            session.trainerName?[0] ?? 'T',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                              ),
                            ),
                            Text(
                              'com ${session.trainerName}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Targets
            Text(
              'Este check-in será registrado para:',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTargetChip(isDark, LucideIcons.building2, session.gymName ?? 'Academia', true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTargetChip(isDark, LucideIcons.user, session.trainerName ?? 'Personal', true),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(15),
                border: Border.all(color: AppColors.success.withAlpha(30)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info, size: 18, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'O Personal receberá uma notificação para confirmar sua presença',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticUtils.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticUtils.heavyImpact();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
                              const SizedBox(width: 12),
                              const Text('Check-in realizado! Aguardando confirmação.'),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.checkCircle, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text(
                            'Confirmar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetChip(bool isDark, IconData icon, String label, bool included) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: included
            ? AppColors.success.withAlpha(25)
            : (isDark
                ? AppColors.cardDark.withAlpha(150)
                : AppColors.card.withAlpha(200)),
        border: Border.all(
          color: included
              ? AppColors.success
              : (isDark ? AppColors.borderDark : AppColors.border),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            included ? LucideIcons.checkCircle : icon,
            size: 18,
            color: included ? AppColors.success : (isDark ? AppColors.foregroundDark : AppColors.foreground),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: included ? AppColors.success : (isDark ? AppColors.foregroundDark : AppColors.foreground),
            ),
          ),
        ],
      ),
    );
  }
}
