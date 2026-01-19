import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/haptic_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/domain/entities/user_role.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../../../../shared/presentation/components/role_bottom_navigation.dart';
import '../providers/trainer_students_provider.dart';
import '../widgets/invite_student_sheet.dart' show showInviteStudentSheet;

/// Students List Page for Personal Trainers
/// Displays a searchable, filterable list of students with stats and actions
class StudentsListPage extends ConsumerStatefulWidget {
  const StudentsListPage({super.key});

  @override
  ConsumerState<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends ConsumerState<StudentsListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedFilter = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isRefreshing = false;

  final _filters = ['Todos', 'Ativos', 'Inativos', 'Convites'];

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

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  List<TrainerStudent> _getFilteredStudents(List<TrainerStudent> students) {
    return students.where((student) {
      // Filter by search query
      final matchesSearch = _searchQuery.isEmpty ||
          student.name.toLowerCase().contains(_searchQuery);

      // Filter by tab selection
      final matchesFilter = _selectedFilter == 0 ||
          (_selectedFilter == 1 && student.isActive) ||
          (_selectedFilter == 2 && !student.isActive);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    HapticUtils.mediumImpact();

    // Get current org ID
    final orgId = ref.read(activeContextProvider)?.organization.id;

    // Refresh data from API
    await ref.read(trainerStudentsNotifierProvider(orgId).notifier).loadStudents();
    await ref.read(pendingInvitesNotifierProvider(orgId).notifier).loadInvites();

    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  Future<void> _cancelInvite(BuildContext context, String inviteId, bool isDark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
        title: Text(
          'Cancelar Convite',
          style: TextStyle(
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        content: Text(
          'Tem certeza que deseja cancelar este convite?',
          style: TextStyle(
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final orgId = ref.read(activeContextProvider)?.organization.id;
        await ref.read(pendingInvitesNotifierProvider(orgId).notifier).cancelInvite(inviteId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Convite cancelado',
                style: TextStyle(color: isDark ? Colors.black : Colors.white),
              ),
              backgroundColor: isDark ? AppColors.success : AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erro ao cancelar convite',
                style: TextStyle(color: isDark ? Colors.black : Colors.white),
              ),
              backgroundColor: isDark ? AppColors.destructive : AppColors.destructive,
            ),
          );
        }
      }
    }
  }

  Future<void> _resendInvite(BuildContext context, String inviteId, bool isDark) async {
    try {
      final orgId = ref.read(activeContextProvider)?.organization.id;
      await ref.read(pendingInvitesNotifierProvider(orgId).notifier).resendInvite(inviteId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Convite reenviado com sucesso',
              style: TextStyle(color: isDark ? Colors.black : Colors.white),
            ),
            backgroundColor: isDark ? AppColors.success : AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao reenviar convite',
              style: TextStyle(color: isDark ? Colors.black : Colors.white),
            ),
            backgroundColor: isDark ? AppColors.destructive : AppColors.destructive,
          ),
        );
      }
    }
  }

  void _copyInviteLink(BuildContext context, String? token, bool isDark) {
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Token de convite não disponível',
            style: TextStyle(color: isDark ? Colors.black : Colors.white),
          ),
          backgroundColor: isDark ? AppColors.warning : AppColors.warning,
        ),
      );
      return;
    }
    final link = 'myfit://invite/$token';
    Clipboard.setData(ClipboardData(text: link));
    HapticUtils.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Link copiado!',
          style: TextStyle(color: isDark ? Colors.black : Colors.white),
        ),
        backgroundColor: isDark ? AppColors.success : AppColors.success,
      ),
    );
  }

  String _formatLastWorkout(DateTime? lastWorkout) {
    if (lastWorkout == null) return 'Nunca';

    final now = DateTime.now();
    final difference = now.difference(lastWorkout);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays} dias';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Há $weeks semana${weeks > 1 ? 's' : ''}';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'Há $months mês${months > 1 ? 'es' : ''}';
    }
  }

  String _getFrequencyLabel(double frequency) {
    if (frequency >= 0.8) return 'Excelente';
    if (frequency >= 0.6) return 'Bom';
    if (frequency >= 0.4) return 'Regular';
    return 'Baixo';
  }

  Color _getFrequencyColor(double frequency) {
    if (frequency >= 0.8) return AppColors.success;
    if (frequency >= 0.6) return AppColors.primary;
    if (frequency >= 0.4) return AppColors.warning;
    return AppColors.destructive;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeContext = ref.watch(activeContextProvider);
    final orgId = activeContext?.organization.id;
    final studentsState = ref.watch(trainerStudentsNotifierProvider(orgId));
    final filteredStudents = _getFilteredStudents(studentsState.students);
    final pendingInvitesState = ref.watch(pendingInvitesNotifierProvider(orgId));
    final pendingInvites = pendingInvitesState.invites;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      bottomNavigationBar: const RoleBottomNavigation(
        role: UserRole.trainer,
        currentIndex: 1, // Alunos tab
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and add button
                        FadeInUp(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
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
                                    'Meus Alunos',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  HapticUtils.lightImpact();
                                  showInviteStudentSheet(
                                    context,
                                    ref: ref,
                                    isDark: isDark,
                                    onSuccess: () {
                                      ref.read(pendingInvitesNotifierProvider(orgId).notifier).loadInvites();
                                    },
                                  );
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withAlpha(isDark ? 40 : 60),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    LucideIcons.userPlus,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Search bar
                        FadeInUp(
                          delay: const Duration(milliseconds: 100),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark.withAlpha(150)
                                  : AppColors.card.withAlpha(200),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.border,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 14),
                                Icon(
                                  LucideIcons.search,
                                  size: 18,
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Buscar alunos...',
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: isDark
                                            ? AppColors.mutedForegroundDark
                                            : AppColors.mutedForeground,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foreground,
                                    ),
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _searchController.clear();
                                      HapticUtils.selectionClick();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Icon(
                                        LucideIcons.x,
                                        size: 16,
                                        color: isDark
                                            ? AppColors.mutedForegroundDark
                                            : AppColors.mutedForeground,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Filter tabs
                        FadeInUp(
                          delay: const Duration(milliseconds: 150),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _filters.asMap().entries.map((entry) {
                                final isSelected = entry.key == _selectedFilter;
                                return GestureDetector(
                                  onTap: () {
                                    HapticUtils.selectionClick();
                                    setState(
                                        () => _selectedFilter = entry.key);
                                  },
                                  child: AnimatedContainer(
                                    duration: AppAnimations.fast,
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDark
                                              ? AppColors.foregroundDark
                                              : AppColors.foreground)
                                          : (isDark
                                              ? AppColors.cardDark
                                                  .withAlpha(150)
                                              : AppColors.card.withAlpha(200)),
                                      border: Border.all(
                                        color: isSelected
                                            ? (isDark
                                                ? AppColors.foregroundDark
                                                : AppColors.foreground)
                                            : (isDark
                                                ? AppColors.borderDark
                                                : AppColors.border),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      entry.value,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? (isDark
                                                ? AppColors.backgroundDark
                                                : AppColors.background)
                                            : (isDark
                                                ? AppColors.foregroundDark
                                                : AppColors.foreground),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats summary
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _StatsSummary(
                        isDark: isDark,
                        totalStudents: studentsState.students.length,
                        activeStudents: studentsState.activeCount,
                        inactiveStudents: studentsState.inactiveCount,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Main content - Students list OR Invites list based on selected tab
                  Expanded(
                    child: _selectedFilter == 3
                        // Tab "Convites" selected - show invites
                        ? _buildInvitesTab(context, isDark, pendingInvites, pendingInvitesState.isLoading)
                        // Other tabs - show students
                        : studentsState.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : studentsState.error != null
                                ? _buildErrorState(isDark, studentsState.error!)
                                : filteredStudents.isEmpty
                                    ? _EmptyState(
                                        isDark: isDark,
                                        searchQuery: _searchQuery,
                                        onAddStudent: () => showInviteStudentSheet(
                                          context,
                                          ref: ref,
                                          isDark: isDark,
                                          onSuccess: () {
                                            ref.read(pendingInvitesNotifierProvider(orgId).notifier).loadInvites();
                                          },
                                        ),
                                      )
                                    : RefreshIndicator(
                                        onRefresh: _onRefresh,
                                        color: isDark
                                            ? AppColors.primaryDark
                                            : AppColors.primary,
                                        backgroundColor:
                                            isDark ? AppColors.cardDark : AppColors.card,
                                        child: ListView.builder(
                                          padding:
                                              const EdgeInsets.symmetric(horizontal: 20),
                                          itemCount: filteredStudents.length,
                                          itemBuilder: (context, index) {
                                            final student = filteredStudents[index];
                                            return FadeInUp(
                                              delay:
                                                  Duration(milliseconds: 250 + (index * 50)),
                                              child: Padding(
                                                padding: const EdgeInsets.only(bottom: 12),
                                                child: _StudentCardWidget(
                                                  student: student,
                                                  isDark: isDark,
                                                  lastWorkoutFormatted: _formatLastWorkout(
                                                      student.lastWorkoutAt),
                                                  frequencyLabel: _getFrequencyLabel(
                                                      student.adherencePercent / 100),
                                                  frequencyColor: _getFrequencyColor(
                                                      student.adherencePercent / 100),
                                                  onTap: () {
                                                    HapticUtils.selectionClick();
                                                    _showStudentDetailSheet(
                                                        context, isDark, student);
                                                  },
                                                ),
                                              ),
                                            );
                                      },
                                    ),
                                  ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FadeInUp(
        delay: const Duration(milliseconds: 500),
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticUtils.lightImpact();
            showInviteStudentSheet(
              context,
              ref: ref,
              isDark: isDark,
              onSuccess: () {
                ref.read(pendingInvitesNotifierProvider(orgId).notifier).loadInvites();
              },
            );
          },
          backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
          icon: const Icon(LucideIcons.userPlus, color: Colors.white),
          label: const Text(
            'Novo Aluno',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _onRefresh,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tentar novamente',
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
  }

  Widget _buildInvitesTab(BuildContext context, bool isDark, List<PendingInvite> invites, bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (invites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.mailCheck,
                size: 48,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum convite pendente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Convide novos alunos clicando no botao + acima',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: isDark ? AppColors.primaryDark : AppColors.primary,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: invites.length,
        itemBuilder: (context, index) {
          final invite = invites[index];
          return FadeInUp(
            delay: Duration(milliseconds: 100 + (index * 50)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PendingInviteCard(
                invite: invite,
                isDark: isDark,
                onCancel: () => _cancelInvite(context, invite.id, isDark),
                onResend: () => _resendInvite(context, invite.id, isDark),
                onCopyLink: () => _copyInviteLink(context, invite.token, isDark),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showStudentDetailSheet(
      BuildContext context, bool isDark, TrainerStudent student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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
                // Profile header
                Row(
                  children: [
                    _buildAvatarForStudent(student, isDark, size: 64),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.name,
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
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: student.isActive
                                      ? AppColors.success
                                      : AppColors.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                student.isActive ? 'Ativo' : 'Inativo',
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
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.mutedDark : AppColors.muted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Treinos',
                        '${student.totalWorkouts}',
                        isDark,
                      ),
                      _buildStatItem(
                        'Completos',
                        '${student.completedWorkouts}',
                        isDark,
                      ),
                      _buildStatItem(
                        'Aderência',
                        '${student.adherencePercent.toInt()}%',
                        isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          Navigator.pop(context);
                          // Navigate to student workouts
                          context.push('/students/${student.id}/workouts?name=${Uri.encodeComponent(student.name)}');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.dumbbell, size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Treinos',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          Navigator.pop(context);
                          // Navigate to student progress
                          context.push('/students/${student.id}/progress?name=${Uri.encodeComponent(student.name)}');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.trendingUp,
                                size: 18,
                                color: isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Progresso',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foreground,
                                  fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarForStudent(TrainerStudent student, bool isDark, {double size = 48}) {
    final initials = student.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join().toUpperCase();

    if (student.avatarUrl != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 4),
          image: DecorationImage(
            image: NetworkImage(student.avatarUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? AppColors.mutedDark : AppColors.muted,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size / 3,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
      ),
    );
  }

  void _showStudentDetail(
      BuildContext context, bool isDark, Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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

                // Profile header
                Row(
                  children: [
                    _buildAvatar(student, isDark, size: 64),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['name'] as String,
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
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: (student['isActive'] as bool)
                                      ? AppColors.success
                                      : AppColors.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                (student['isActive'] as bool)
                                    ? 'Ativo'
                                    : 'Inativo',
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
                    ),
                    // Actions
                    Row(
                      children: [
                        _buildIconButton(
                          isDark: isDark,
                          icon: LucideIcons.messageCircle,
                          onTap: () {
                            HapticUtils.lightImpact();
                            Navigator.pop(context);
                            _showMessageComposeSheet(
                              this.context,
                              isDark,
                              student,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildIconButton(
                          isDark: isDark,
                          icon: LucideIcons.moreVertical,
                          onTap: () {
                            HapticUtils.lightImpact();
                            Navigator.pop(context);
                            _showStudentOptionsSheet(
                              this.context,
                              isDark,
                              student,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Stats
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailStat(
                        '${student['workoutsCompleted']}',
                        'Treinos',
                        isDark,
                      ),
                      _buildDetailStat(
                        '${((student['frequency'] as double) * 100).toInt()}%',
                        'Frequência',
                        isDark,
                      ),
                      _buildDetailStat(
                        _formatLastWorkout(student['lastWorkout'] as DateTime?),
                        'Último Treino',
                        isDark,
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
                          HapticUtils.lightImpact();
                          Navigator.pop(context);
                          final studentId = student['id'] as String;
                          final studentName = student['name'] as String;
                          this.context.push('/students/$studentId/workouts?name=${Uri.encodeComponent(studentName)}');
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
                              Icon(LucideIcons.dumbbell,
                                  size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Ver Treinos',
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
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticUtils.lightImpact();
                          Navigator.pop(context);
                          final studentId = student['id'] as String;
                          final studentName = student['name'] as String;
                          this.context.push('/students/$studentId/progress?name=${Uri.encodeComponent(studentName)}');
                        },
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.lineChart,
                                size: 18,
                                color: isDark
                                    ? AppColors.foregroundDark
                                    : AppColors.foreground,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Progresso',
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

  Widget _buildAvatar(Map<String, dynamic> student, bool isDark,
      {double size = 52}) {
    final name = student['name'] as String;
    final initials = name.split(' ').map((w) => w[0]).take(2).join();
    final avatarUrl = student['avatarUrl'] as String?;

    return Stack(
      children: [
        Container(
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
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: size * 0.26,
            height: size * 0.26,
            decoration: BoxDecoration(
              color: (student['isActive'] as bool)
                  ? AppColors.success
                  : AppColors.warning,
              border: Border.all(
                color: isDark ? AppColors.cardDark : AppColors.card,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.mutedDark : AppColors.muted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
        ),
      ),
    );
  }

  Widget _buildDetailStat(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  void _showMessageComposeSheet(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> student,
  ) {
    final messageController = TextEditingController();
    final studentName = student['name'] as String;

    final quickMessages = [
      'Bom treino!',
      'Como foi o treino?',
      'Lembre-se de descansar hoje',
      'Parabéns pelo progresso!',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
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

            // Header with student name
            Row(
              children: [
                Icon(
                  LucideIcons.messageCircle,
                  size: 24,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
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
                      const SizedBox(height: 2),
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
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick messages
            Text(
              'Mensagens rapidas',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quickMessages.map((message) {
                return GestureDetector(
                  onTap: () {
                    HapticUtils.selectionClick();
                    messageController.text = message;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.mutedDark.withAlpha(100)
                          : AppColors.muted.withAlpha(100),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
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

            const SizedBox(height: 20),

            // Message input
            Text(
              'Sua mensagem',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
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
              child: TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Digite sua mensagem...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: TextStyle(
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticUtils.lightImpact();
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
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
                      HapticUtils.lightImpact();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(LucideIcons.check,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 12),
                              Text('Mensagem enviada para $studentName'),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
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
                          Icon(LucideIcons.send, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Enviar',
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentOptionsSheet(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> student,
  ) {
    final studentId = student['id'] as String;
    final studentName = student['name'] as String;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      builder: (ctx) => Padding(
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

            // Header
            Text(
              'Opções para $studentName',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),

            const SizedBox(height: 20),

            // Options list
            _buildOptionItem(
              isDark: isDark,
              icon: LucideIcons.dumbbell,
              label: 'Ver treinos do aluno',
              onTap: () {
                HapticUtils.lightImpact();
                Navigator.pop(ctx);
                context.push(
                    '/students/$studentId/workouts?name=${Uri.encodeComponent(studentName)}');
              },
            ),

            _buildOptionItem(
              isDark: isDark,
              icon: LucideIcons.lineChart,
              label: 'Ver progresso',
              onTap: () {
                HapticUtils.lightImpact();
                Navigator.pop(ctx);
                context.push(
                    '/students/$studentId/progress?name=${Uri.encodeComponent(studentName)}');
              },
            ),

            _buildOptionItem(
              isDark: isDark,
              icon: LucideIcons.calendarPlus,
              label: 'Agendar sessão',
              onTap: () {
                HapticUtils.lightImpact();
                Navigator.pop(ctx);
                _showScheduleSessionSheet(context, isDark, student);
              },
            ),

            _buildOptionItem(
              isDark: isDark,
              icon: LucideIcons.stickyNote,
              label: 'Adicionar nota',
              onTap: () {
                HapticUtils.lightImpact();
                Navigator.pop(ctx);
                _showAddNoteSheet(context, isDark, student);
              },
            ),

            const Divider(height: 24),

            _buildOptionItem(
              isDark: isDark,
              icon: LucideIcons.userMinus,
              label: 'Remover aluno',
              isDestructive: true,
              onTap: () {
                HapticUtils.lightImpact();
                Navigator.pop(ctx);
                _showRemoveStudentDialog(context, isDark, student);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? AppColors.destructive
        : (isDark ? AppColors.foregroundDark : AppColors.foreground);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.destructive.withAlpha(20)
                    : (isDark
                        ? AppColors.mutedDark.withAlpha(100)
                        : AppColors.muted.withAlpha(100)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleSessionSheet(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> student,
  ) {
    final studentName = student['name'] as String;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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

              Text(
                'Agendar Sessão',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Com $studentName',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),

              const SizedBox(height: 24),

              // Date picker
              Text(
                'Data',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        LucideIcons.calendar,
                        size: 18,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Time picker
              Text(
                'Horário',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setModalState(() => selectedTime = time);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        size: 18,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
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
                        HapticUtils.lightImpact();
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(LucideIcons.calendarCheck,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Sessão agendada com $studentName',
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
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
                            Icon(LucideIcons.calendarPlus,
                                size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Agendar',
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNoteSheet(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> student,
  ) {
    final noteController = TextEditingController();
    final studentName = student['name'] as String;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
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
                Icon(
                  LucideIcons.stickyNote,
                  size: 24,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adicionar Nota',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sobre: $studentName',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Note input
            Text(
              'Sua nota',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
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
              child: TextField(
                controller: noteController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      'Ex: Aluno apresentou desconforto no ombro direito...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForeground,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: TextStyle(
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticUtils.lightImpact();
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
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
                      HapticUtils.lightImpact();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(LucideIcons.check,
                                  color: Colors.white, size: 18),
                              const SizedBox(width: 12),
                              Text('Nota adicionada para $studentName'),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
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
                          Icon(LucideIcons.save, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Salvar',
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveStudentDialog(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> student,
  ) {
    final studentName = student['name'] as String;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.destructive.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.alertTriangle,
                size: 20,
                color: AppColors.destructive,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Remover Aluno',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ],
        ),
        content: Text(
          'Tem certeza que deseja remover $studentName da sua lista de alunos? Esta ação não pode ser desfeita.',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(ctx);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(LucideIcons.userMinus,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 12),
                      Text('$studentName foi removido'),
                    ],
                  ),
                  backgroundColor: AppColors.destructive,
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}

// Pending Invites Section Widget
class _PendingInvitesSection extends StatelessWidget {
  final List<PendingInvite> invites;
  final bool isDark;
  final Function(String) onCancel;
  final Function(String) onResend;
  final Function(String?) onCopyLink;

  const _PendingInvitesSection({
    required this.invites,
    required this.isDark,
    required this.onCancel,
    required this.onResend,
    required this.onCopyLink,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(
                LucideIcons.mail,
                size: 18,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Convites Pendentes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.warning : AppColors.warning).withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${invites.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.warning : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Invite cards
          ...invites.map((invite) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PendingInviteCard(
              invite: invite,
              isDark: isDark,
              onCancel: () => onCancel(invite.id),
              onResend: () => onResend(invite.id),
              onCopyLink: () => onCopyLink(invite.token),
            ),
          )),
        ],
      ),
    );
  }
}

// Pending Invite Card Widget
class _PendingInviteCard extends StatelessWidget {
  final PendingInvite invite;
  final bool isDark;
  final VoidCallback onCancel;
  final VoidCallback onResend;
  final VoidCallback onCopyLink;

  const _PendingInviteCard({
    required this.invite,
    required this.isDark,
    required this.onCancel,
    required this.onResend,
    required this.onCopyLink,
  });

  @override
  Widget build(BuildContext context) {
    final expiressSoon = invite.expiresWithinDays(2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
        border: Border.all(
          color: expiressSoon
              ? (isDark ? AppColors.warning : AppColors.warning).withAlpha(100)
              : (isDark ? AppColors.borderDark : AppColors.border),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email and time
          Row(
            children: [
              Icon(
                LucideIcons.mailCheck,
                size: 16,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  invite.email,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ),
              Text(
                invite.timeSinceCreated,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Role and expiration warning
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.secondaryDark : AppColors.secondary).withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  invite.role == 'student' ? 'Aluno' : invite.role,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.secondaryDark : AppColors.secondary,
                  ),
                ),
              ),
              const Spacer(),
              if (expiressSoon)
                Row(
                  children: [
                    Icon(
                      LucideIcons.alertTriangle,
                      size: 14,
                      color: isDark ? AppColors.warning : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      invite.timeUntilExpiration,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.warning : AppColors.warning,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _InviteActionButton(
                  icon: LucideIcons.copy,
                  label: 'Copiar Link',
                  isDark: isDark,
                  onTap: onCopyLink,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InviteActionButton(
                  icon: LucideIcons.refreshCcw,
                  label: 'Reenviar',
                  isDark: isDark,
                  onTap: onResend,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InviteActionButton(
                  icon: LucideIcons.x,
                  label: 'Cancelar',
                  isDark: isDark,
                  isDestructive: true,
                  onTap: onCancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Invite Action Button Widget
class _InviteActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final bool isDestructive;
  final VoidCallback onTap;

  const _InviteActionButton({
    required this.icon,
    required this.label,
    required this.isDark,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? (isDark ? AppColors.destructive : AppColors.destructive)
        : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground);

    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stats Summary Widget
class _StatsSummary extends StatelessWidget {
  final bool isDark;
  final int totalStudents;
  final int activeStudents;
  final int inactiveStudents;

  const _StatsSummary({
    required this.isDark,
    required this.totalStudents,
    required this.activeStudents,
    required this.inactiveStudents,
  });

  @override
  Widget build(BuildContext context) {
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniStat('$totalStudents', 'Total', null),
          Container(
            width: 1,
            height: 30,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          _buildMiniStat('$activeStudents', 'Ativos', AppColors.success),
          Container(
            width: 1,
            height: 30,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          _buildMiniStat('$inactiveStudents', 'Inativos', AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color? color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color:
                color ?? (isDark ? AppColors.foregroundDark : AppColors.foreground),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color:
                isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

// Student Card Widget for TrainerStudent
class _StudentCardWidget extends StatelessWidget {
  final TrainerStudent student;
  final bool isDark;
  final String lastWorkoutFormatted;
  final String frequencyLabel;
  final Color frequencyColor;
  final VoidCallback onTap;

  const _StudentCardWidget({
    required this.student,
    required this.isDark,
    required this.lastWorkoutFormatted,
    required this.frequencyLabel,
    required this.frequencyColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = student.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join();

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
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.mutedDark : AppColors.muted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: student.avatarUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(student.avatarUrl!, fit: BoxFit.cover),
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
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: student.isActive ? AppColors.success : AppColors.warning,
                      border: Border.all(
                        color: isDark ? AppColors.cardDark : AppColors.card,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
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
                        LucideIcons.calendar,
                        size: 12,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lastWorkoutFormatted,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        LucideIcons.dumbbell,
                        size: 12,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${student.totalWorkouts} treinos',
                        style: TextStyle(
                          fontSize: 13,
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

            // Frequency badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: frequencyColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '${student.adherencePercent.toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: frequencyColor,
                    ),
                  ),
                  Text(
                    frequencyLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: frequencyColor.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

// Legacy Student Card Widget (keeping for backwards compatibility)
class _StudentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final bool isDark;
  final String lastWorkoutFormatted;
  final String frequencyLabel;
  final Color frequencyColor;
  final VoidCallback onTap;

  const _StudentCard({
    required this.student,
    required this.isDark,
    required this.lastWorkoutFormatted,
    required this.frequencyLabel,
    required this.frequencyColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = student['name'] as String;
    final initials = name.split(' ').map((w) => w[0]).take(2).join();
    final avatarUrl = student['avatarUrl'] as String?;
    final isActive = student['isActive'] as bool;
    final workoutsCompleted = student['workoutsCompleted'] as int;
    final frequency = student['frequency'] as double;

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
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.success : AppColors.warning,
                      border: Border.all(
                        color: isDark ? AppColors.cardDark : AppColors.card,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // Info
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
                        LucideIcons.calendar,
                        size: 12,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        lastWorkoutFormatted,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        LucideIcons.dumbbell,
                        size: 12,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$workoutsCompleted treinos',
                        style: TextStyle(
                          fontSize: 13,
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

            // Frequency badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: frequencyColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '${(frequency * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: frequencyColor,
                    ),
                  ),
                  Text(
                    frequencyLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: frequencyColor.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
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
  final String searchQuery;
  final VoidCallback? onAddStudent;

  const _EmptyState({
    required this.isDark,
    required this.searchQuery,
    this.onAddStudent,
  });

  @override
  Widget build(BuildContext context) {
    final isSearching = searchQuery.isNotEmpty;

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
                isSearching ? LucideIcons.searchX : LucideIcons.users,
                size: 36,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching ? 'Nenhum aluno encontrado' : 'Nenhum aluno ainda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Tente buscar por outro nome'
                  : 'Adicione seu primeiro aluno para começar',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isSearching) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  onAddStudent?.call();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.userPlus, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Adicionar Aluno',
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

