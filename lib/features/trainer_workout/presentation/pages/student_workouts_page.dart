import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../../domain/models/trainer_workout.dart';
import '../providers/trainer_workout_provider.dart';
import '../widgets/ai_suggestion_card.dart';
import '../widgets/workout_card.dart';

/// Página que mostra os treinos de um aluno específico
/// para o trainer gerenciar
class StudentWorkoutsPage extends ConsumerStatefulWidget {
  final String studentId;
  final String? studentName;

  const StudentWorkoutsPage({
    super.key,
    required this.studentId,
    this.studentName,
  });

  @override
  ConsumerState<StudentWorkoutsPage> createState() => _StudentWorkoutsPageState();
}

class _StudentWorkoutsPageState extends ConsumerState<StudentWorkoutsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workouts = ref.watch(studentWorkoutsProvider(widget.studentId));
    final progress = ref.watch(studentProgressProvider(widget.studentId));
    final suggestions = ref.watch(aiSuggestionsProvider(widget.studentId));
    final programs = ref.watch(studentProgramsProvider(widget.studentId));

    final activeWorkouts =
        workouts.where((w) => w.status == WorkoutAssignmentStatus.active).toList();
    final draftWorkouts =
        workouts.where((w) => w.status == WorkoutAssignmentStatus.draft).toList();
    final archivedWorkouts =
        workouts.where((w) => w.status == WorkoutAssignmentStatus.archived ||
            w.status == WorkoutAssignmentStatus.completed).toList();

    return Scaffold(
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
              _buildHeader(context, isDark, progress),

              // Tabs
              _buildTabs(isDark, activeWorkouts.length, draftWorkouts.length),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Treinos Ativos + Sugestões IA + Programas
                    _buildActiveTab(context, isDark, activeWorkouts, suggestions, progress, programs),

                    // Rascunhos
                    _buildDraftsTab(context, isDark, draftWorkouts),

                    // Histórico
                    _buildHistoryTab(context, isDark, archivedWorkouts),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticUtils.lightImpact();
          _createNewWorkout(context, isDark);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus, size: 20),
        label: const Text('Novo Treino'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, StudentProgress progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    borderRadius: BorderRadius.circular(8),
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
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    progress.studentName.isNotEmpty ? progress.studentName[0].toUpperCase() : '?',
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
                      progress.studentName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.flame,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${progress.currentStreak} dias',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${progress.sessionsThisWeek}/sem',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // More options
              GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  _showStudentOptions(context, isDark);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardDark.withAlpha(150)
                        : AppColors.card.withAlpha(200),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: Icon(
                    LucideIcons.moreVertical,
                    size: 20,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quick stats
          Row(
            children: [
              _buildQuickStat(isDark, 'Total', '${progress.totalWorkouts}', LucideIcons.dumbbell),
              const SizedBox(width: 12),
              _buildQuickStat(isDark, 'Minutos', '${progress.totalMinutes}', LucideIcons.clock),
              const SizedBox(width: 12),
              _buildQuickStat(isDark, 'Melhor', '${progress.longestStreak}d', LucideIcons.trophy),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(bool isDark, String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(150)
              : AppColors.card.withAlpha(200),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(bool isDark, int activeCount, int draftCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelColor: AppColors.primary,
        unselectedLabelColor: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        onTap: (_) {
          HapticUtils.selectionClick();
        },
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Ativos'),
                if (activeCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$activeCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Rascunhos'),
                if (draftCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$draftCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: 'Histórico'),
        ],
      ),
    );
  }

  Widget _buildActiveTab(
    BuildContext context,
    bool isDark,
    List<TrainerWorkout> workouts,
    List<AISuggestion> suggestions,
    StudentProgress progress,
    List<Map<String, dynamic>> programs,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sugestões da IA
          if (suggestions.isNotEmpty) ...[
            FadeInUp(
              child: _buildAISuggestionsSection(context, isDark, suggestions),
            ),
            const SizedBox(height: 24),
          ],

          // Programas de treino
          if (programs.isNotEmpty) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 50),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.clipboard,
                    size: 18,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Programas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ...programs.asMap().entries.map((entry) {
              return FadeInUp(
                delay: Duration(milliseconds: 100 + (entry.key * 50)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StudentProgramCard(
                    program: entry.value,
                    isDark: isDark,
                    onTap: () {
                      HapticUtils.lightImpact();
                      context.push('/programs/${entry.value['id']}');
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],

          // Treinos ativos
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Row(
              children: [
                Icon(
                  LucideIcons.dumbbell,
                  size: 18,
                  color: isDark ? AppColors.secondaryDark : AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Treinos Individuais',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (workouts.isEmpty)
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: _buildEmptyState(
                isDark,
                'Nenhum treino ativo',
                'Crie um novo treino para este aluno',
                LucideIcons.dumbbell,
              ),
            )
          else
            ...workouts.asMap().entries.map((entry) {
              return FadeInUp(
                delay: Duration(milliseconds: 150 + (entry.key * 50)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: WorkoutCard(
                    workout: entry.value,
                    onTap: () => _openWorkout(context, entry.value),
                    onEdit: () => _editWorkout(context, entry.value),
                    onEvolve: () => _evolveWorkout(context, isDark, entry.value),
                    onPause: () => _pauseWorkout(entry.value.id),
                  ),
                ),
              );
            }),

          // Progress milestones
          if (progress.milestones.isNotEmpty) ...[
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildMilestonesSection(context, isDark, progress.milestones),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAISuggestionsSection(
    BuildContext context,
    bool isDark,
    List<AISuggestion> suggestions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(LucideIcons.sparkles, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sugestões da IA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  Text(
                    'Baseadas no progresso do aluno',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...suggestions.take(2).map((suggestion) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AISuggestionCard(
              suggestion: suggestion,
              onApply: () => _applySuggestion(suggestion),
              onDismiss: () => _dismissSuggestion(context, isDark, suggestion),
            ),
          );
        }),
        if (suggestions.length > 2)
          TextButton.icon(
            onPressed: () {
              HapticUtils.lightImpact();
              _showAllSuggestions(context, isDark, suggestions);
            },
            icon: const Icon(LucideIcons.chevronDown, size: 16),
            label: Text('Ver todas (${suggestions.length})'),
          ),
      ],
    );
  }

  Widget _buildMilestonesSection(
    BuildContext context,
    bool isDark,
    List<ProgressMilestone> milestones,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conquistas Recentes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: milestones.length,
            itemBuilder: (context, index) {
              final milestone = milestones[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning.withAlpha(25),
                      AppColors.warning.withAlpha(10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withAlpha(50)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      milestone.icon == 'trophy' ? LucideIcons.trophy : LucideIcons.flame,
                      size: 24,
                      color: AppColors.warning,
                    ),
                    const Spacer(),
                    Text(
                      milestone.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatDate(milestone.achievedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDraftsTab(BuildContext context, bool isDark, List<TrainerWorkout> workouts) {
    if (workouts.isEmpty) {
      return Center(
        child: _buildEmptyState(
          isDark,
          'Nenhum rascunho',
          'Treinos em edição aparecerão aqui',
          LucideIcons.fileEdit,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 50),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WorkoutCard(
              workout: workout,
              onTap: () => _editWorkout(context, workout),
              onActivate: () => _activateWorkout(workout.id),
              onDelete: () => _deleteWorkout(context, isDark, workout),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(BuildContext context, bool isDark, List<TrainerWorkout> workouts) {
    if (workouts.isEmpty) {
      return Center(
        child: _buildEmptyState(
          isDark,
          'Sem histórico',
          'Treinos arquivados aparecerão aqui',
          LucideIcons.archive,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return FadeInUp(
          delay: Duration(milliseconds: index * 50),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WorkoutCard(
              workout: workout,
              showProgress: true,
              onTap: () => _openWorkout(context, workout),
              onDuplicate: () => _duplicateWorkout(workout),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark, String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(height: 16),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _showStudentOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle visual
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Título
              Text(
                'Opções do Aluno',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 16),
              // Opções
              _buildStudentOptionTile(
                ctx,
                isDark,
                LucideIcons.lineChart,
                'Ver Progresso Detalhado',
                'Acompanhe a evolução do aluno',
                AppColors.primary,
                () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  context.push('/students/${widget.studentId}/progress?name=${Uri.encodeComponent(widget.studentName ?? '')}');
                },
              ),
              const SizedBox(height: 8),
              _buildStudentOptionTile(
                ctx,
                isDark,
                LucideIcons.messageSquare,
                'Enviar Mensagem',
                'Comunique-se com o aluno',
                AppColors.info,
                () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  _showSendMessageModal(context, isDark);
                },
              ),
              const SizedBox(height: 8),
              _buildStudentOptionTile(
                ctx,
                isDark,
                LucideIcons.calendar,
                'Agendar Sessão',
                'Marque uma sessão de treino',
                AppColors.success,
                () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  _showScheduleSessionModal(context, isDark);
                },
              ),
              const SizedBox(height: 8),
              _buildStudentOptionTile(
                ctx,
                isDark,
                LucideIcons.fileText,
                'Notas do Aluno',
                'Adicione observações importantes',
                AppColors.warning,
                () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  _showStudentNotesModal(context, isDark);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentOptionTile(
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
          color: isDark ? AppColors.mutedDark : AppColors.muted,
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
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  void _showSendMessageModal(BuildContext context, bool isDark) {
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.info.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(LucideIcons.messageSquare, size: 22, color: AppColors.info),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enviar Mensagem',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      Text(
                        'Para ${widget.studentName ?? 'Aluno'}',
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
            const SizedBox(height: 20),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Digite sua mensagem...',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
                filled: true,
                fillColor: isDark ? AppColors.mutedDark : AppColors.muted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  if (messageController.text.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                            Text('Mensagem enviada para ${widget.studentName ?? 'aluno'}'),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                icon: const Icon(LucideIcons.send, size: 18),
                label: const Text('Enviar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleSessionModal(BuildContext context, bool isDark) {
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
        maxWidth: MediaQuery.of(context).size.width,
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(LucideIcons.calendar, size: 22, color: AppColors.success),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agendar Sessão',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        Text(
                          'Com ${widget.studentName ?? 'Aluno'}',
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
              const SizedBox(height: 24),
              // Data
              Text(
                'Data',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.mutedDark : AppColors.muted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.calendar, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        LucideIcons.chevronDown,
                        size: 18,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Horário
              Text(
                'Horário',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.mutedDark : AppColors.muted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.clock, size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        LucideIcons.chevronDown,
                        size: 18,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                            Text('Sessão agendada para ${selectedDate.day}/${selectedDate.month} as ${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.calendarCheck, size: 18),
                  label: const Text('Confirmar Agendamento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentNotesModal(BuildContext context, bool isDark) {
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(LucideIcons.fileText, size: 22, color: AppColors.warning),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notas do Aluno',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      Text(
                        widget.studentName ?? 'Aluno',
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
            const SizedBox(height: 20),
            TextField(
              controller: notesController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Adicione observacoes sobre o aluno...\n\nEx: Lesão no ombro direito, evitar exercícios de pressão overhead.',
                hintStyle: TextStyle(
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
                filled: true,
                fillColor: isDark ? AppColors.mutedDark : AppColors.muted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  if (notesController.text.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
                            SizedBox(width: 12),
                            Text('Notas salvas com sucesso'),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                icon: const Icon(LucideIcons.save, size: 18),
                label: const Text('Salvar Notas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createNewWorkout(BuildContext context, bool isDark) {
    // Navigate directly to program wizard with studentId
    HapticUtils.lightImpact();
    context.push('${RouteNames.programWizard}?studentId=${widget.studentId}');
  }

  void _openWorkout(BuildContext context, TrainerWorkout workout) {
    HapticUtils.lightImpact();
    // Navigate to workout detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo ${workout.name}', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _editWorkout(BuildContext context, TrainerWorkout workout) {
    HapticUtils.lightImpact();
    // Navigate to workout builder
  }

  void _evolveWorkout(BuildContext context, bool isDark, TrainerWorkout workout) {
    HapticUtils.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
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
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.trendingUp, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evoluir Treino',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        Text(
                          'Semana ${workout.weekNumber ?? 1} → ${(workout.weekNumber ?? 1) + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Como deseja evoluir?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 16),
              _buildEvolveOption(
                ctx,
                isDark,
                LucideIcons.sparkles,
                'Sugestão Automática',
                'IA sugere progressão baseada no histórico',
                () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  _applyAIEvolution(workout);
                },
              ),
              const SizedBox(height: 12),
              _buildEvolveOption(
                ctx,
                isDark,
                LucideIcons.plus,
                'Aumentar Carga',
                '+2.5kg em todos os exercícios',
                () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  _applyWeightIncrease(workout);
                },
              ),
              const SizedBox(height: 12),
              _buildEvolveOption(
                ctx,
                isDark,
                LucideIcons.layers,
                'Aumentar Volume',
                '+1 série em exercícios compostos',
                () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  _applyVolumeIncrease(workout);
                },
              ),
              const SizedBox(height: 12),
              _buildEvolveOption(
                ctx,
                isDark,
                LucideIcons.edit,
                'Editar Manualmente',
                'Fazer ajustes personalizados',
                () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  _editWorkout(context, workout);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvolveOption(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.mutedDark : AppColors.muted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      fontSize: 13,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  void _applyAIEvolution(TrainerWorkout workout) {
    // Apply AI-suggested evolution
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(LucideIcons.sparkles, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Gerando evolução com IA...'),
          ],
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _applyWeightIncrease(TrainerWorkout workout) {
    final evolvedExercises = workout.exercises.map((e) {
      if (e.weightKg != null) {
        return e.copyWith(weightKg: e.weightKg! + 2.5);
      }
      return e;
    }).toList();

    ref.read(trainerWorkoutsNotifierProvider.notifier).evolveWorkout(workout.id, evolvedExercises);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Treino evoluído! +2.5kg nas cargas'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _applyVolumeIncrease(TrainerWorkout workout) {
    final evolvedExercises = workout.exercises.map((e) {
      // Add 1 set to compound exercises (first 2-3 exercises typically)
      if (e.order < 3) {
        return e.copyWith(sets: e.sets + 1);
      }
      return e;
    }).toList();

    ref.read(trainerWorkoutsNotifierProvider.notifier).evolveWorkout(workout.id, evolvedExercises);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Treino evoluído! +1 série nos compostos'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _pauseWorkout(String workoutId) {
    HapticUtils.lightImpact();
    ref.read(trainerWorkoutsNotifierProvider.notifier).pauseWorkout(workoutId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Treino pausado'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _activateWorkout(String workoutId) {
    HapticUtils.lightImpact();
    ref.read(trainerWorkoutsNotifierProvider.notifier).activateWorkout(workoutId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Treino ativado!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _duplicateWorkout(TrainerWorkout workout) {
    HapticUtils.lightImpact();
    ref.read(trainerWorkoutsNotifierProvider.notifier).duplicateWorkout(workout.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Treino duplicado'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _deleteWorkout(BuildContext context, bool isDark, TrainerWorkout workout) {
    HapticUtils.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          'Excluir Treino?',
          style: TextStyle(
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        content: Text(
          'Esta ação não pode ser desfeita.',
          style: TextStyle(
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticUtils.lightImpact();
              Navigator.pop(ctx);
              ref.read(trainerWorkoutsNotifierProvider.notifier).deleteWorkout(workout.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Treino excluído'),
                  backgroundColor: AppColors.destructive,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _applySuggestion(AISuggestion suggestion) {
    HapticUtils.lightImpact();
    ref.read(studentProgressNotifierProvider(widget.studentId).notifier).applySuggestion(suggestion.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text('Aplicado: ${suggestion.title}')),
          ],
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _dismissSuggestion(BuildContext context, bool isDark, AISuggestion suggestion) {
    HapticUtils.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          'Ignorar Sugestão?',
          style: TextStyle(
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Por que está ignorando esta sugestão?',
              style: TextStyle(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            _buildDismissOption(ctx, 'Não é relevante', () {
              _doDismiss(suggestion, 'Não é relevante');
            }),
            _buildDismissOption(ctx, 'Já apliquei manualmente', () {
              _doDismiss(suggestion, 'Já apliquei manualmente');
            }),
            _buildDismissOption(ctx, 'Aluno tem restrições', () {
              _doDismiss(suggestion, 'Aluno tem restrições');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissOption(BuildContext context, String text, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticUtils.lightImpact();
        Navigator.pop(context);
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const Icon(LucideIcons.circle, size: 16),
            const SizedBox(width: 12),
            Text(text),
          ],
        ),
      ),
    );
  }

  void _doDismiss(AISuggestion suggestion, String reason) {
    ref.read(studentProgressNotifierProvider(widget.studentId).notifier).dismissSuggestion(suggestion.id, reason);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sugestão ignorada'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _showAllSuggestions(BuildContext context, bool isDark, List<AISuggestion> suggestions) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Todas as Sugestões',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 20),
            ...suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AISuggestionCard(
                suggestion: s,
                onApply: () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  _applySuggestion(s);
                },
                onDismiss: () {
                  HapticUtils.lightImpact();
                  Navigator.pop(ctx);
                  _dismissSuggestion(context, isDark, s);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Hoje';
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return 'há ${diff.inDays} dias';
    return '${date.day}/${date.month}';
  }
}

// ============================================================
// STUDENT PROGRAM CARD
// ============================================================

class _StudentProgramCard extends StatelessWidget {
  final Map<String, dynamic> program;
  final bool isDark;
  final VoidCallback onTap;

  const _StudentProgramCard({
    required this.program,
    required this.isDark,
    required this.onTap,
  });

  String _getDifficultyLabel(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'beginner':
        return 'Iniciante';
      case 'intermediate':
        return 'Intermediário';
      case 'advanced':
        return 'Avançado';
      default:
        return 'Intermediário';
    }
  }

  String _getGoalLabel(String? goal) {
    switch (goal?.toLowerCase()) {
      case 'hypertrophy':
        return 'Hipertrofia';
      case 'strength':
        return 'Força';
      case 'weight_loss':
        return 'Emagrecimento';
      case 'endurance':
        return 'Resistência';
      case 'functional':
        return 'Funcional';
      default:
        return goal ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = program['name'] as String? ?? 'Programa';
    final goal = program['goal'] as String?;
    final difficulty = program['difficulty'] as String?;
    final splitType = program['split_type'] as String?;
    final workoutsCount = (program['workouts'] as List?)?.length ?? 0;
    final durationWeeks = program['duration_weeks'] as int?;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withAlpha(isDark ? 30 : 20),
              AppColors.secondary.withAlpha(isDark ? 20 : 15),
            ],
          ),
          border: Border.all(
            color: AppColors.primary.withAlpha(50),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.clipboard,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
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
                      if (goal != null)
                        Text(
                          _getGoalLabel(goal),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ProgramBadge(
                  label: '$workoutsCount treinos',
                  icon: LucideIcons.dumbbell,
                  isDark: isDark,
                ),
                if (splitType != null)
                  _ProgramBadge(
                    label: splitType.toUpperCase(),
                    icon: LucideIcons.layoutGrid,
                    isDark: isDark,
                  ),
                if (difficulty != null)
                  _ProgramBadge(
                    label: _getDifficultyLabel(difficulty),
                    icon: LucideIcons.gauge,
                    isDark: isDark,
                  ),
                if (durationWeeks != null)
                  _ProgramBadge(
                    label: '$durationWeeks semanas',
                    icon: LucideIcons.calendar,
                    isDark: isDark,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;

  const _ProgramBadge({
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark.withAlpha(150) : Colors.white.withAlpha(180),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

