import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/domain/entities/user_role.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../../../../shared/presentation/components/role_bottom_navigation.dart';
import '../providers/schedule_provider.dart';

/// Schedule Page for Personal Trainers
/// Displays a week view with daily sessions for managing appointments
class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late DateTime _selectedDate;
  late DateTime _weekStart;
  late ScrollController _weekScrollController;

  static const String _orgId = 'default';

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
    _controller.forward();

    _selectedDate = DateTime.now();
    _weekStart = _getWeekStart(DateTime.now());
    _weekScrollController = ScrollController();

    // Load sessions from provider
    Future.microtask(() {
      ref.read(scheduleSessionsNotifierProvider.notifier).loadSessions();
      ref.read(scheduleStudentsNotifierProvider(_orgId).notifier).loadStudents();
    });
  }

  DateTime _getWeekStart(DateTime date) {
    // Get Monday of the week
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    _weekScrollController.dispose();
    super.dispose();
  }

  List<DateTime> _getWeekDays() {
    return List.generate(7, (index) => _weekStart.add(Duration(days: index)));
  }

  List<Map<String, dynamic>> _getSessionsForDay(DateTime day, List<ScheduleSession> allSessions) {
    // Filter sessions for the selected day
    return allSessions
        .where((session) =>
            session.date.year == day.year &&
            session.date.month == day.month &&
            session.date.day == day.day)
        .map((session) => {
              'id': session.id,
              'studentName': session.studentName,
              'studentAvatarUrl': session.studentAvatarUrl,
              'time': session.time,
              'duration': session.durationMinutes,
              'workoutType': session.workoutType,
              'status': session.status,
            })
        .toList();
  }

  Future<void> _onRefresh() async {
    await ref.read(scheduleSessionsNotifierProvider.notifier).loadSessions();
  }

  List<Map<String, dynamic>> _getStudents(List<Map<String, dynamic>> allStudents) {
    return allStudents;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSelected(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  String _formatSessionTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? '${hours}h${mins}min' : '${hours}h';
    }
    return '${minutes}min';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.destructive;
      default:
        return AppColors.mutedForeground;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmado';
      case 'pending':
        return 'Pendente';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return LucideIcons.checkCircle;
      case 'pending':
        return LucideIcons.clock;
      case 'cancelled':
        return LucideIcons.xCircle;
      default:
        return LucideIcons.circle;
    }
  }

  void _goToPreviousWeek() {
    HapticFeedback.selectionClick();
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
      _selectedDate = _weekStart;
    });
  }

  void _goToNextWeek() {
    HapticFeedback.selectionClick();
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
      _selectedDate = _weekStart;
    });
  }

  void _goToToday() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedDate = DateTime.now();
      _weekStart = _getWeekStart(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final weekDays = _getWeekDays();

    // Watch provider state
    final sessionsState = ref.watch(scheduleSessionsNotifierProvider);
    final allSessions = sessionsState.sessions;
    final sessionsForDay = _getSessionsForDay(_selectedDate, allSessions);

    final studentsState = ref.watch(scheduleStudentsNotifierProvider(_orgId));
    final students = studentsState.students;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      bottomNavigationBar: const RoleBottomNavigation(
        role: UserRole.trainer,
        currentIndex: 3, // Agenda tab
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? AppColors.primaryDark : AppColors.primary)
                  .withAlpha(isDark ? 15 : 10),
              (isDark ? AppColors.secondaryDark : AppColors.secondary)
                  .withAlpha(isDark ? 12 : 8),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: FadeInUp(
                      child: _HeaderSection(
                        isDark: isDark,
                        weekStart: _weekStart,
                        onPreviousWeek: _goToPreviousWeek,
                        onNextWeek: _goToNextWeek,
                        onGoToToday: _goToToday,
                        onBack: () {
                          HapticFeedback.lightImpact();
                          context.pop();
                        },
                      ),
                    ),
                  ),

                  // Week days selector
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      height: 90,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.builder(
                        controller: _weekScrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: weekDays.length,
                        itemBuilder: (context, index) {
                          final day = weekDays[index];
                          return _DayCard(
                            date: day,
                            isToday: _isToday(day),
                            isSelected: _isSelected(day),
                            isDark: isDark,
                            sessionsCount: _getSessionsForDay(day, allSessions).length,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedDate = day);
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats summary for selected day
                  FadeInUp(
                    delay: const Duration(milliseconds: 150),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _DayStatsSummary(
                        isDark: isDark,
                        sessions: sessionsForDay,
                        selectedDate: _selectedDate,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sessions list
                  Expanded(
                    child: sessionsForDay.isEmpty
                        ? FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: _EmptyState(
                              isDark: isDark,
                              selectedDate: _selectedDate,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: sessionsForDay.length,
                            itemBuilder: (context, index) {
                              final session = sessionsForDay[index];
                              return FadeInUp(
                                delay: Duration(milliseconds: 200 + (index * 50)),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _SessionCard(
                                    session: session,
                                    isDark: isDark,
                                    formatTime: _formatSessionTime,
                                    formatDuration: _formatDuration,
                                    getStatusColor: _getStatusColor,
                                    getStatusLabel: _getStatusLabel,
                                    getStatusIcon: _getStatusIcon,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      _showSessionDetail(context, isDark, session);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FadeInUp(
        delay: const Duration(milliseconds: 400),
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.lightImpact();
            _showCreateSessionSheet(context, isDark, students);
          },
          backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
          icon: const Icon(LucideIcons.plus, color: Colors.white),
          label: const Text(
            'Nova Sessao',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showSessionDetail(
      BuildContext context, bool isDark, Map<String, dynamic> session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Session header
                Row(
                  children: [
                    // Avatar
                    _buildAvatar(session, isDark, size: 56),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session['studentName'] as String,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(session['status'] as String)
                                      .withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getStatusIcon(session['status'] as String),
                                      size: 14,
                                      color: _getStatusColor(
                                          session['status'] as String),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getStatusLabel(session['status'] as String),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: _getStatusColor(
                                            session['status'] as String),
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
                  ],
                ),

                const SizedBox(height: 24),

                // Session details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.mutedDark.withAlpha(100)
                        : AppColors.muted.withAlpha(100),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        isDark,
                        LucideIcons.clock,
                        'Horario',
                        '${_formatSessionTime(session['time'] as TimeOfDay)} - ${_formatDuration(session['duration'] as int)}',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        isDark,
                        LucideIcons.dumbbell,
                        'Tipo de Treino',
                        session['workoutType'] as String,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        isDark,
                        LucideIcons.calendar,
                        'Data',
                        DateFormat('EEEE, d MMMM', 'pt_BR').format(_selectedDate),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          _showMessageModal(context, isDark, session);
                        },
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.messageCircle,
                                  size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Enviar Mensagem',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        _showEditSessionSheet(context, isDark, session);
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.edit,
                          size: 18,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        _showCancelConfirmModal(context, isDark, session);
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.destructive.withAlpha(100),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.x,
                          size: 18,
                          color: AppColors.destructive,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      bool isDark, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.primaryDark : AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(Map<String, dynamic> session, bool isDark,
      {double size = 48}) {
    final name = session['studentName'] as String;
    final initials = name.split(' ').map((w) => w[0]).take(2).join();
    final avatarUrl = session['studentAvatarUrl'] as String?;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AppColors.mutedDark : AppColors.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: avatarUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(avatarUrl, fit: BoxFit.cover),
            )
          : Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: size * 0.32,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),
    );
  }

  void _showCreateSessionSheet(BuildContext context, bool isDark, List<Map<String, dynamic>> studentList) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.primaryDark : AppColors.primary)
                            .withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.calendarPlus,
                        size: 24,
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Nova Sessao',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color:
                            isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Quick actions
                _buildCreateOption(
                  ctx,
                  isDark,
                  LucideIcons.userPlus,
                  'Selecionar Aluno',
                  'Escolha um aluno para agendar',
                  AppColors.primary,
                  () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(ctx);
                    _showSelectStudentModal(context, isDark, studentList);
                  },
                ),

                const SizedBox(height: 12),

                _buildCreateOption(
                  ctx,
                  isDark,
                  LucideIcons.repeat,
                  'Sessao Recorrente',
                  'Criar sessoes que se repetem',
                  AppColors.secondary,
                  () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(ctx);
                    _showRecurringSessionModal(context, isDark, studentList);
                  },
                ),

                const SizedBox(height: 12),

                _buildCreateOption(
                  ctx,
                  isDark,
                  LucideIcons.users,
                  'Sessao em Grupo',
                  'Agendar para multiplos alunos',
                  AppColors.accent,
                  () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(ctx);
                    _showGroupSessionModal(context, isDark, studentList);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSelectStudentModal(BuildContext context, bool isDark, List<Map<String, dynamic>> studentList) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.primaryDark : AppColors.primary)
                          .withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.userPlus,
                      size: 24,
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Selecionar Aluno',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color:
                          isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: studentList.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum aluno encontrado',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: studentList.length,
                        itemBuilder: (context, index) {
                          final student = studentList[index];
                    final name = student['name'] as String;
                    final initials =
                        name.split(' ').map((w) => w[0]).take(2).join();
                    final avatarUrl = student['avatarUrl'] as String?;
                    final lastWorkout = student['lastWorkout'] as String;
                    final lastWorkoutDate = student['lastWorkoutDate'] as String;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(ctx);
                        _showTimePickerForStudent(context, isDark, student);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.mutedDark.withAlpha(100)
                              : AppColors.muted.withAlpha(100),
                          border: Border.all(
                            color:
                                isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color:
                                    isDark ? AppColors.mutedDark : AppColors.muted,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: avatarUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(avatarUrl,
                                          fit: BoxFit.cover),
                                    )
                                  : Center(
                                      child: Text(
                                        initials,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.foregroundDark
                                              : AppColors.foreground,
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
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foreground,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        LucideIcons.dumbbell,
                                        size: 12,
                                        color: isDark
                                            ? AppColors.mutedForegroundDark
                                            : AppColors.mutedForeground,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '$lastWorkout - $lastWorkoutDate',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark
                                                ? AppColors.mutedForegroundDark
                                                : AppColors.mutedForeground,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 20,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimePickerForStudent(
      BuildContext context, bool isDark, Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          TimeOfDay selectedTime = TimeOfDay.now();

          return SafeArea(
            child: Padding(
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Agendar sessao com ${student['name']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setModalState(() => selectedTime = time);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.mutedDark.withAlpha(100)
                            : AppColors.muted.withAlpha(100),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 20,
                            color:
                                isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Horario: ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Alterar',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Sessao criada para ${student['name']} as ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.primaryDark : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Criar Sessao',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRecurringSessionModal(BuildContext context, bool isDark, List<Map<String, dynamic>> studentList) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          String selectedFrequency = 'weekly';
          Set<int> selectedWeekdays = {1, 3, 5}; // Mon, Wed, Fri
          TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
          int selectedDuration = 60;
          Map<String, dynamic>? selectedStudent;

          final frequencies = {
            'daily': 'Diario',
            'weekly': 'Semanal',
            'biweekly': 'Quinzenal',
            'monthly': 'Mensal',
          };

          final weekdays = {
            1: 'Seg',
            2: 'Ter',
            3: 'Qua',
            4: 'Qui',
            5: 'Sex',
            6: 'Sab',
            7: 'Dom',
          };

          final durations = [30, 45, 60, 90, 120];

          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? AppColors.secondaryDark
                                    : AppColors.secondary)
                                .withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            LucideIcons.repeat,
                            size: 24,
                            color: isDark
                                ? AppColors.secondaryDark
                                : AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Sessao Recorrente',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Frequency selector
                    Text(
                      'Frequencia',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: frequencies.entries.map((entry) {
                        final isSelected = selectedFrequency == entry.key;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setModalState(() => selectedFrequency = entry.key);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.primaryDark
                                      : AppColors.primary)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? (isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primary)
                                    : (isDark
                                        ? AppColors.borderDark
                                        : AppColors.border),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.foregroundDark
                                        : AppColors.foreground),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    if (selectedFrequency == 'weekly') ...[
                      const SizedBox(height: 24),
                      Text(
                        'Dias da Semana',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: weekdays.entries.map((entry) {
                          final isSelected = selectedWeekdays.contains(entry.key);
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setModalState(() {
                                if (isSelected) {
                                  selectedWeekdays.remove(entry.key);
                                } else {
                                  selectedWeekdays.add(entry.key);
                                }
                              });
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primary)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark
                                          ? AppColors.primaryDark
                                          : AppColors.primary)
                                      : (isDark
                                          ? AppColors.borderDark
                                          : AppColors.border),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                            ? AppColors.foregroundDark
                                            : AppColors.foreground),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Time picker
                    Text(
                      'Horario',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          setModalState(() => selectedTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.mutedDark.withAlpha(100)
                              : AppColors.muted.withAlpha(100),
                          border: Border.all(
                            color:
                                isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.clock,
                              size: 20,
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Alterar',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Duration selector
                    Text(
                      'Duracao',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: durations.map((duration) {
                        final isSelected = selectedDuration == duration;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setModalState(() => selectedDuration = duration);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.primaryDark
                                      : AppColors.primary)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? (isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primary)
                                    : (isDark
                                        ? AppColors.borderDark
                                        : AppColors.border),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${duration}min',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.foregroundDark
                                        : AppColors.foreground),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Student selector
                    Text(
                      'Aluno',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        showModalBottomSheet(
                          context: context,
                          backgroundColor:
                              isDark ? AppColors.cardDark : AppColors.background,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (innerCtx) => SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Selecionar Aluno',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foreground,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 300,
                                    child: ListView.builder(
                                      itemCount: studentList.length,
                                      itemBuilder: (context, index) {
                                        final student = studentList[index];
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: isDark
                                                ? AppColors.mutedDark
                                                : AppColors.muted,
                                            child: Text(
                                              (student['name'] as String)
                                                  .split(' ')
                                                  .map((w) => w[0])
                                                  .take(2)
                                                  .join(),
                                              style: TextStyle(
                                                color: isDark
                                                    ? AppColors.foregroundDark
                                                    : AppColors.foreground,
                                              ),
                                            ),
                                          ),
                                          title: Text(student['name'] as String),
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            Navigator.pop(innerCtx);
                                            setModalState(
                                                () => selectedStudent = student);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.mutedDark.withAlpha(100)
                              : AppColors.muted.withAlpha(100),
                          border: Border.all(
                            color:
                                isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.user,
                              size: 20,
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              selectedStudent != null
                                  ? selectedStudent!['name'] as String
                                  : 'Selecionar aluno',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: selectedStudent != null
                                    ? (isDark
                                        ? AppColors.foregroundDark
                                        : AppColors.foreground)
                                    : (isDark
                                        ? AppColors.mutedForegroundDark
                                        : AppColors.mutedForeground),
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 20,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Preview
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (isDark
                                ? AppColors.primaryDark
                                : AppColors.primary)
                            .withAlpha(15),
                        border: Border.all(
                          color: (isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary)
                              .withAlpha(50),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Previa das Sessoes',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedFrequency == 'weekly'
                                ? '${selectedWeekdays.length} sessoes por semana as ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
                                : '${frequencies[selectedFrequency]} as ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: selectedStudent != null
                            ? () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Sessoes recorrentes criadas para ${selectedStudent!['name']}',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? AppColors.primaryDark : AppColors.primary,
                          disabledBackgroundColor: isDark
                              ? AppColors.mutedDark
                              : AppColors.muted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Criar Sessoes Recorrentes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showGroupSessionModal(BuildContext context, bool isDark, List<Map<String, dynamic>> studentList) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          Set<String> selectedStudentIds = {};
          TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
          int selectedDuration = 60;
          final sessionNameController = TextEditingController();
          int maxCapacity = 10;

          final durations = [30, 45, 60, 90, 120];

          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                (isDark ? AppColors.accentDark : AppColors.accent)
                                    .withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            LucideIcons.users,
                            size: 24,
                            color: isDark ? AppColors.accentDark : AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Sessao em Grupo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Session name
                    Text(
                      'Nome da Sessao',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: sessionNameController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Treino Funcional em Grupo',
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.mutedDark.withAlpha(100)
                            : AppColors.muted.withAlpha(100),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                isDark ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                isDark ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Students multi-select
                    Text(
                      'Alunos (${selectedStudentIds.length} selecionados)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.mutedDark.withAlpha(100)
                            : AppColors.muted.withAlpha(100),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: studentList.map((student) {
                          final isSelected =
                              selectedStudentIds.contains(student['id']);
                          final name = student['name'] as String;
                          final initials =
                              name.split(' ').map((w) => w[0]).take(2).join();

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setModalState(() {
                                if (isSelected) {
                                  selectedStudentIds.remove(student['id']);
                                } else {
                                  selectedStudentIds.add(student['id'] as String);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.border,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDark
                                              ? AppColors.primaryDark
                                              : AppColors.primary)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? (isDark
                                                ? AppColors.primaryDark
                                                : AppColors.primary)
                                            : (isDark
                                                ? AppColors.borderDark
                                                : AppColors.border),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            LucideIcons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.mutedDark
                                          : AppColors.muted,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        initials,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.foregroundDark
                                              : AppColors.foreground,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Time picker
                    Text(
                      'Horario',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          setModalState(() => selectedTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.mutedDark.withAlpha(100)
                              : AppColors.muted.withAlpha(100),
                          border: Border.all(
                            color:
                                isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.clock,
                              size: 20,
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Alterar',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Duration selector
                    Text(
                      'Duracao',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: durations.map((duration) {
                        final isSelected = selectedDuration == duration;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setModalState(() => selectedDuration = duration);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.primaryDark
                                      : AppColors.primary)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? (isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primary)
                                    : (isDark
                                        ? AppColors.borderDark
                                        : AppColors.border),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${duration}min',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.foregroundDark
                                        : AppColors.foreground),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Max capacity
                    Text(
                      'Capacidade Maxima',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            if (maxCapacity > 2) {
                              setModalState(() => maxCapacity--);
                            }
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.border,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              LucideIcons.minus,
                              size: 20,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '$maxCapacity pessoas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            if (maxCapacity < 50) {
                              setModalState(() => maxCapacity++);
                            }
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.border,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              LucideIcons.plus,
                              size: 20,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: selectedStudentIds.isNotEmpty
                            ? () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Sessao em grupo criada com ${selectedStudentIds.length} alunos',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? AppColors.primaryDark : AppColors.primary,
                          disabledBackgroundColor: isDark
                              ? AppColors.mutedDark
                              : AppColors.muted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Criar Sessao em Grupo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMessageModal(
      BuildContext context, bool isDark, Map<String, dynamic> session) {
    final messageController = TextEditingController();
    final studentName = session['studentName'] as String;

    final quickMessages = [
      'Lembrete de sessao',
      'Alteracao de horario',
      'Confirmacao de presenca',
      'Parabens pelo progresso!',
      'Treino disponivel',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? AppColors.primaryDark : AppColors.primary)
                                .withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.messageCircle,
                        size: 24,
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enviar Mensagem',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                        Text(
                          'Para: $studentName',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick messages
                Text(
                  'Mensagens Rapidas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickMessages.map((message) {
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setModalState(() {
                          messageController.text = message;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.mutedDark.withAlpha(100)
                              : AppColors.muted.withAlpha(100),
                          border: Border.all(
                            color:
                                isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Message input
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Digite sua mensagem...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.mutedDark.withAlpha(100)
                        : AppColors.muted.withAlpha(100),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 24),

                // Send button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Mensagem enviada para $studentName', style: const TextStyle(color: Colors.white)),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? AppColors.primaryDark : AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.send, size: 18, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Enviar Mensagem',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showChangeTimeModal(
      BuildContext context, bool isDark, Map<String, dynamic> session) {
    final currentTime = session['time'] as TimeOfDay;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          TimeOfDay selectedTime = currentTime;

          return SafeArea(
            child: Padding(
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              (isDark ? AppColors.primaryDark : AppColors.primary)
                                  .withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.clock,
                          size: 24,
                          color: isDark ? AppColors.primaryDark : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Alterar Horario',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Current time
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.mutedDark.withAlpha(100)
                          : AppColors.muted.withAlpha(100),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Horario atual:',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // New time selector
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setModalState(() => selectedTime = time);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? AppColors.primaryDark : AppColors.primary)
                                .withAlpha(15),
                        border: Border.all(
                          color:
                              (isDark ? AppColors.primaryDark : AppColors.primary)
                                  .withAlpha(50),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 20,
                            color:
                                isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Novo horario: ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Alterar',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Horario alterado', style: const TextStyle(color: Colors.white)),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? AppColors.primaryDark : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Salvar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRescheduleModal(
      BuildContext context, bool isDark, Map<String, dynamic> session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          DateTime selectedDate = _selectedDate;
          TimeOfDay selectedTime = session['time'] as TimeOfDay;

          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primary)
                                .withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            LucideIcons.calendar,
                            size: 24,
                            color:
                                isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Reagendar Sessao',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Date picker
                    Text(
                      'Nova Data',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setModalState(() => selectedDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.mutedDark.withAlpha(100)
                              : AppColors.muted.withAlpha(100),
                          border: Border.all(
                            color:
                                isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 20,
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('EEEE, d MMMM yyyy', 'pt_BR')
                                  .format(selectedDate),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Alterar',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Time picker
                    Text(
                      'Novo Horario',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          setModalState(() => selectedTime = time);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.mutedDark.withAlpha(100)
                              : AppColors.muted.withAlpha(100),
                          border: Border.all(
                            color:
                                isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.clock,
                              size: 20,
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Alterar',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(ctx);
                          final dateStr =
                              DateFormat('d/MM', 'pt_BR').format(selectedDate);
                          final timeStr =
                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Sessao reagendada para $dateStr as $timeStr'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? AppColors.primaryDark : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Salvar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCancelConfirmModal(
      BuildContext context, bool isDark, Map<String, dynamic> session) {
    final reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.destructive.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.xCircle,
                    size: 24,
                    color: AppColors.destructive,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Cancelar Sessao',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Confirmation message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.destructive.withAlpha(15),
                border: Border.all(
                  color: AppColors.destructive.withAlpha(50),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.alertTriangle,
                    size: 20,
                    color: AppColors.destructive,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tem certeza que deseja cancelar a sessao com ${session['studentName']}?',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Reason input
            Text(
              'Motivo do cancelamento (opcional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ex: Aluno solicitou cancelamento...',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.mutedDark.withAlpha(100)
                    : AppColors.muted.withAlpha(100),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
              ),
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Voltar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sessao cancelada', style: const TextStyle(color: Colors.white)),
                            backgroundColor: AppColors.destructive,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.destructive,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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

  Widget _buildCreateOption(
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
              ? AppColors.mutedDark.withAlpha(100)
              : AppColors.muted.withAlpha(100),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
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
                      color:
                          isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSessionSheet(
      BuildContext context, bool isDark, Map<String, dynamic> session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Editar Sessao',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(LucideIcons.clock),
                title: const Text('Alterar Horario'),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                  _showChangeTimeModal(context, isDark, session);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.calendar),
                title: const Text('Reagendar'),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                  _showRescheduleModal(context, isDark, session);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.checkCircle),
                title: const Text('Marcar como Confirmado'),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sessao confirmada', style: const TextStyle(color: Colors.white)),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(LucideIcons.xCircle, color: AppColors.destructive),
                title: Text(
                  'Cancelar Sessao',
                  style: TextStyle(color: AppColors.destructive),
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                  _showCancelConfirmModal(context, isDark, session);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Header Section Widget
class _HeaderSection extends StatelessWidget {
  final bool isDark;
  final DateTime weekStart;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onGoToToday;
  final VoidCallback onBack;

  const _HeaderSection({
    required this.isDark,
    required this.weekStart,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onGoToToday,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final monthFormat = DateFormat('MMM', 'pt_BR');
    final isCurrentWeek = _isCurrentWeek();

    String weekLabel;
    if (weekStart.month == weekEnd.month) {
      weekLabel =
          '${weekStart.day} - ${weekEnd.day} ${monthFormat.format(weekStart)}';
    } else {
      weekLabel =
          '${weekStart.day} ${monthFormat.format(weekStart)} - ${weekEnd.day} ${monthFormat.format(weekEnd)}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.cardDark : AppColors.card)
                          .withAlpha(isDark ? 150 : 200),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
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
                const SizedBox(width: 12),
                Text(
                  'Agenda',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
            if (!isCurrentWeek)
              GestureDetector(
                onTap: onGoToToday,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.primaryDark : AppColors.primary)
                        .withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.calendarCheck,
                        size: 16,
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Hoje',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color:
                              isDark ? AppColors.primaryDark : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            GestureDetector(
              onTap: onPreviousWeek,
              child: Container(
                width: 40,
                height: 40,
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
                  LucideIcons.chevronLeft,
                  size: 18,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                weekLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onNextWeek,
              child: Container(
                width: 40,
                height: 40,
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
                  LucideIcons.chevronRight,
                  size: 18,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _isCurrentWeek() {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    return weekStart.year == currentWeekStart.year &&
        weekStart.month == currentWeekStart.month &&
        weekStart.day == currentWeekStart.day;
  }
}

// Day Card Widget
class _DayCard extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool isDark;
  final int sessionsCount;
  final VoidCallback onTap;

  const _DayCard({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isDark,
    required this.sessionsCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('E', 'pt_BR');
    final dayName = dayFormat.format(date).substring(0, 3).toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        width: 52,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
              : (isDark
                  ? AppColors.cardDark.withAlpha(150)
                  : AppColors.card.withAlpha(200)),
          border: Border.all(
            color: isToday && !isSelected
                ? (isDark ? AppColors.primaryDark : AppColors.primary)
                : isSelected
                    ? (isDark ? AppColors.foregroundDark : AppColors.foreground)
                    : (isDark ? AppColors.borderDark : AppColors.border),
            width: isToday && !isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.backgroundDark : AppColors.background)
                    : (isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? (isDark ? AppColors.backgroundDark : AppColors.background)
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
            const SizedBox(height: 4),
            if (sessionsCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.backgroundDark : AppColors.background)
                          .withAlpha(50)
                      : (isDark ? AppColors.primaryDark : AppColors.primary)
                          .withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$sessionsCount',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? (isDark
                            ? AppColors.backgroundDark
                            : AppColors.background)
                        : (isDark ? AppColors.primaryDark : AppColors.primary),
                  ),
                ),
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Day Stats Summary Widget
class _DayStatsSummary extends StatelessWidget {
  final bool isDark;
  final List<Map<String, dynamic>> sessions;
  final DateTime selectedDate;

  const _DayStatsSummary({
    required this.isDark,
    required this.sessions,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final confirmed =
        sessions.where((s) => s['status'] == 'confirmed').length;
    final pending = sessions.where((s) => s['status'] == 'pending').length;
    final totalMinutes = sessions.fold<int>(
        0, (sum, s) => sum + (s['duration'] as int));

    final dateFormat = DateFormat('EEEE', 'pt_BR');
    final dayName = dateFormat.format(selectedDate);
    final capitalizedDay =
        dayName[0].toUpperCase() + dayName.substring(1);

    return Container(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalizedDay,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Text(
                  '${sessions.length} sessoes programadas',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildMiniStat(
                  '$confirmed', 'Confirmadas', AppColors.success, isDark),
              const SizedBox(width: 16),
              _buildMiniStat('$pending', 'Pendentes', AppColors.warning, isDark),
              const SizedBox(width: 16),
              _buildMiniStat(
                '${totalMinutes ~/ 60}h',
                'Total',
                isDark ? AppColors.primaryDark : AppColors.primary,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

// Session Card Widget
class _SessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  final bool isDark;
  final String Function(TimeOfDay) formatTime;
  final String Function(int) formatDuration;
  final Color Function(String) getStatusColor;
  final String Function(String) getStatusLabel;
  final IconData Function(String) getStatusIcon;
  final VoidCallback onTap;

  const _SessionCard({
    required this.session,
    required this.isDark,
    required this.formatTime,
    required this.formatDuration,
    required this.getStatusColor,
    required this.getStatusLabel,
    required this.getStatusIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = session['studentName'] as String;
    final initials = name.split(' ').map((w) => w[0]).take(2).join();
    final avatarUrl = session['studentAvatarUrl'] as String?;
    final time = session['time'] as TimeOfDay;
    final duration = session['duration'] as int;
    final workoutType = session['workoutType'] as String;
    final status = session['status'] as String;
    final statusColor = getStatusColor(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          border: Border.all(
            color: status == 'cancelled'
                ? AppColors.destructive.withAlpha(50)
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Time badge
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(15),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  bottomLeft: Radius.circular(7),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatTime(time),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    formatDuration(duration),
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.mutedDark : AppColors.muted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: avatarUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(avatarUrl, fit: BoxFit.cover),
                    )
                  : Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                    ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: status == 'cancelled'
                            ? (isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground)
                            : (isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground),
                        decoration: status == 'cancelled'
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.dumbbell,
                          size: 12,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            workoutType,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Status badge
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      getStatusIcon(status),
                      size: 12,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      getStatusLabel(status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
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

// Empty State Widget
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final DateTime selectedDate;

  const _EmptyState({
    required this.isDark,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final isWeekend = selectedDate.weekday == DateTime.saturday ||
        selectedDate.weekday == DateTime.sunday;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryDark : AppColors.primary)
                    .withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isWeekend ? LucideIcons.coffee : LucideIcons.calendarOff,
                size: 36,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isWeekend ? 'Dia de descanso' : 'Nenhuma sessao agendada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isWeekend
                  ? 'Aproveite para recarregar as energias!'
                  : 'Toque no botao abaixo para agendar uma nova sessao',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isWeekend) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Navigate to create session
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.calendarPlus,
                          size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Agendar Sessao',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
