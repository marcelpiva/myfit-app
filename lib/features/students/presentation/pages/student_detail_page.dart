import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../core/services/trainer_service.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/widgets/dev_screen_label.dart';
import '../../../trainer_workout/presentation/providers/trainer_students_provider.dart';
import '../widgets/schedule_session_sheet.dart';
import '../widgets/student_diet_tab.dart';
import '../widgets/student_notes_sheet.dart';
import '../widgets/student_plans_tab.dart';
import '../widgets/student_progress_tab.dart';
import '../widgets/student_report_sheet.dart';
import '../widgets/student_sessions_tab.dart';

/// Detailed view of a student for trainers
class StudentDetailPage extends ConsumerStatefulWidget {
  final String studentId; // Membership ID
  final String studentUserId; // User ID for API calls
  final String studentName;
  final String? studentEmail;
  final String? avatarUrl;
  final bool isActive;

  const StudentDetailPage({
    super.key,
    required this.studentId,
    required this.studentUserId,
    required this.studentName,
    this.studentEmail,
    this.avatarUrl,
    this.isActive = true,
  });

  @override
  ConsumerState<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends ConsumerState<StudentDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late bool _isStudentActive;
  bool _isTogglingStatus = false;

  final _trainerService = TrainerService();

  final _tabs = [
    (icon: LucideIcons.clipboardList, label: 'Planos'),
    (icon: LucideIcons.dumbbell, label: 'Treinos'),
    (icon: LucideIcons.trendingUp, label: 'Progresso'),
    (icon: LucideIcons.utensils, label: 'Dieta'),
  ];

  @override
  void initState() {
    super.initState();
    _isStudentActive = widget.isActive;
    _tabController = TabController(length: _tabs.length, vsync: this);
    _animController = AnimationController(
      duration: AppAnimations.entrance,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: AppAnimations.easeOut),
    );
    _animController.forward();
  }

  Future<void> _toggleStudentStatus() async {
    final newStatus = !_isStudentActive;
    final action = newStatus ? 'ativar' : 'desativar';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${newStatus ? 'Ativar' : 'Desativar'} aluno?'),
        content: Text(
          newStatus
              ? 'O aluno poderá voltar a acessar seus treinos e funcionalidades.'
              : 'O aluno será marcado como inativo e não aparecerá na lista de alunos ativos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: newStatus ? AppColors.success : AppColors.warning,
            ),
            child: Text(newStatus ? 'Ativar' : 'Desativar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isTogglingStatus = true);

    try {
      await _trainerService.updateStudentStatus(widget.studentUserId, newStatus);

      // Invalidate the students provider to refresh the list when returning
      final activeContext = ref.read(activeContextProvider);
      if (activeContext != null) {
        ref.invalidate(trainerStudentsNotifierProvider(activeContext.organization.id));
      }

      setState(() {
        _isStudentActive = newStatus;
        _isTogglingStatus = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  newStatus ? LucideIcons.checkCircle : LucideIcons.userX,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Aluno ${newStatus ? 'ativado' : 'desativado'} com sucesso',
                ),
              ],
            ),
            backgroundColor: newStatus ? AppColors.success : AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isTogglingStatus = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao $action aluno: ${e.toString()}'),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DevScreenLabel(
      screenName: 'StudentDetailPage',
      child: Scaffold(
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
              child: Column(
                children: [
                  // Header
                  _buildHeader(context, theme, isDark),

                  // Tabs
                  _buildTabBar(theme, isDark),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Plans tab
                      StudentPlansTab(
                        studentUserId: widget.studentUserId,
                        studentName: widget.studentName,
                      ),
                      // Sessions/Workouts tab
                      StudentSessionsTab(
                        studentUserId: widget.studentUserId,
                        studentName: widget.studentName,
                      ),
                      // Progress tab
                      StudentProgressTab(
                        studentUserId: widget.studentUserId,
                        studentName: widget.studentName,
                      ),
                      // Diet tab
                      StudentDietTab(
                        studentUserId: widget.studentUserId,
                        studentName: widget.studentName,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () {
              HapticUtils.lightImpact();
              context.pop();
            },
            icon: Icon(
              LucideIcons.arrowLeft,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),

          const SizedBox(width: 8),

          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(isDark ? 40 : 30),
              borderRadius: BorderRadius.circular(24),
              image: widget.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(widget.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.avatarUrl == null
                ? Center(
                    child: Text(
                      widget.studentName.isNotEmpty
                          ? widget.studentName[0].toUpperCase()
                          : 'A',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),

          const SizedBox(width: 12),

          // Name and email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.studentName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.studentEmail != null)
                  Text(
                    widget.studentEmail!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Options menu
          PopupMenuButton<String>(
            icon: Icon(
              LucideIcons.moreVertical,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
            onSelected: (value) {
              HapticUtils.selectionClick();
              switch (value) {
                case 'message':
                  _openChat(context);
                case 'schedule':
                  _showScheduleSheet(context, isDark);
                case 'notes':
                  _showNotesSheet(context, isDark);
                case 'report':
                  _showReportSheet(context, isDark);
                case 'toggle_status':
                  _toggleStudentStatus();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'message',
                child: Row(
                  children: [
                    Icon(LucideIcons.messageCircle, size: 18),
                    SizedBox(width: 12),
                    Text('Enviar mensagem'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'schedule',
                child: Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 18),
                    SizedBox(width: 12),
                    Text('Agendar sessão'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'notes',
                child: Row(
                  children: [
                    Icon(LucideIcons.stickyNote, size: 18),
                    SizedBox(width: 12),
                    Text('Notas do aluno'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(LucideIcons.fileText, size: 18),
                    SizedBox(width: 12),
                    Text('Gerar relatório'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon(
                      _isStudentActive ? LucideIcons.userX : LucideIcons.userCheck,
                      size: 18,
                      color: _isStudentActive ? AppColors.warning : AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isStudentActive ? 'Desativar aluno' : 'Ativar aluno',
                      style: TextStyle(
                        color: _isStudentActive ? AppColors.warning : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppColors.primary.withAlpha(isDark ? 40 : 30),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: isDark
            ? AppColors.mutedForegroundDark
            : AppColors.mutedForeground,
        labelStyle: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelSmall,
        tabs: _tabs.map((tab) {
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tab.icon, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    tab.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onTap: (_) => HapticUtils.selectionClick(),
      ),
    );
  }

  void _openChat(BuildContext context) {
    // Navigate to the chat page - in the future this could navigate directly
    // to a conversation with this specific student
    context.push('/chat');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inicie ou continue uma conversa com ${widget.studentName}'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showScheduleSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleSessionSheet(
        studentUserId: widget.studentUserId,
        studentName: widget.studentName,
      ),
    );
  }

  void _showNotesSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StudentNotesSheet(
        studentUserId: widget.studentUserId,
        studentName: widget.studentName,
      ),
    );
  }

  void _showReportSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StudentReportSheet(
        studentUserId: widget.studentUserId,
        studentName: widget.studentName,
        trainerName: 'Personal Trainer', // TODO: Get from auth state
      ),
    );
  }
}
