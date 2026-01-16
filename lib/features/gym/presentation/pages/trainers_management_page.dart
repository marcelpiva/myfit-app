import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../providers/organization_provider.dart';

/// Trainers Management page for Gym owners and admins
class TrainersManagementPage extends ConsumerStatefulWidget {
  const TrainersManagementPage({super.key});

  @override
  ConsumerState<TrainersManagementPage> createState() =>
      _TrainersManagementPageState();
}

class _TrainersManagementPageState
    extends ConsumerState<TrainersManagementPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _selectedFilter = 0;
  final _searchController = TextEditingController();

  final _filters = ['Todos', 'Ativos', 'Pendentes', 'Inativos'];

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
    _searchController.dispose();
    super.dispose();
  }

  // Temporary orgId - in a real app this would come from the auth provider
  static const String _orgId = 'default';

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await ref.read(membersNotifierProvider(_orgId).notifier).loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final membersState = ref.watch(membersNotifierProvider(_orgId));
    final trainers = membersState.members.where((m) => m['role'] == 'trainer').toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Professores',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _showInviteTrainerSheet(context, isDark);
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
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
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Search bar
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.border,
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
                                  hintText: 'Buscar professores...',
                                  hintStyle: TextStyle(
                                    fontSize: 15,
                                    color: isDark
                                        ? AppColors.mutedForegroundDark
                                        : AppColors.mutedForeground,
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foreground,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filters.asMap().entries.map((entry) {
                            final isSelected = entry.key == _selectedFilter;
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() => _selectedFilter = entry.key);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark
                                          ? AppColors.foregroundDark
                                          : AppColors.foreground)
                                      : (isDark
                                          ? AppColors.cardDark
                                          : AppColors.card).withAlpha(isDark ? 150 : 200),
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
                    ],
                  ),
                ),

                // Stats summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMiniStat(isDark, '8', 'Total'),
                        Container(
                          width: 1,
                          height: 30,
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        _buildMiniStat(isDark, '7', 'Ativos',
                            color: AppColors.success),
                        Container(
                          width: 1,
                          height: 30,
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        _buildMiniStat(isDark, '147', 'Alunos',
                            color: AppColors.secondary),
                        Container(
                          width: 1,
                          height: 30,
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        _buildMiniStat(isDark, '4.8', 'Media',
                            color: AppColors.warning),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Trainers list
                Expanded(
                  child: membersState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : membersState.error != null
                          ? _buildErrorState(isDark, membersState.error!)
                          : trainers.isEmpty
                              ? _buildEmptyState(isDark)
                              : RefreshIndicator(
                                  onRefresh: _onRefresh,
                                  color: AppColors.primary,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    itemCount: trainers.length,
                                    itemBuilder: (context, index) {
                                      final trainer = trainers[index];
                                      return _TrainerCard(
                                        trainer: trainer,
                                        isDark: isDark,
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          _showTrainerDetail(context, isDark, trainer);
                                        },
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              LucideIcons.users,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum professor encontrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Convide professores para a sua academia',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(bool isDark, String value, String label,
      {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color ??
                (isDark ? AppColors.foregroundDark : AppColors.foreground),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  void _showInviteTrainerSheet(BuildContext context, bool isDark) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                'Convidar Professor',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Envie um convite por email ou compartilhe o codigo',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),

              const SizedBox(height: 24),

              // Email input
              Text(
                'Email do Professor',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'email@exemplo.com',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Role selector
              Text(
                'Funcao',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _RoleOption(
                      label: 'Professor',
                      icon: LucideIcons.dumbbell,
                      isSelected: true,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RoleOption(
                      label: 'Administrador',
                      icon: LucideIcons.shield,
                      isSelected: false,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Divider with "or"
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'ou',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Invite Code
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.mutedDark : AppColors.muted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'FITPRO-PROF-2024',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        LucideIcons.copy,
                        size: 18,
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
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
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.x,
                              size: 18,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Cancelar',
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Convite enviado com sucesso!'),
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
                            Icon(
                              LucideIcons.send,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Enviar Convite',
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

  void _showTrainerDetail(
      BuildContext context, bool isDark, Map<String, dynamic> trainer) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
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
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          trainer['initials'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
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
                            trainer['name'],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trainer['specialty'],
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: trainer['status'] == 'active'
                                      ? AppColors.success
                                      : AppColors.warning,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                trainer['status'] == 'active'
                                    ? 'Ativo'
                                    : 'Pendente',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: trainer['status'] == 'active'
                                      ? AppColors.success
                                      : AppColors.warning,
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
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.mutedDark : AppColors.muted,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              LucideIcons.messageCircle,
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
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.mutedDark : AppColors.muted,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              LucideIcons.moreVertical,
                              size: 18,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
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
                          '${trainer['students']}', 'Alunos', isDark),
                      _buildDetailStat('${trainer['rating']}', 'Avaliacao', isDark),
                      _buildDetailStat(trainer['since'], 'Desde', isDark),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Contact info
                Text(
                  'Informacoes de Contato',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),

                const SizedBox(height: 12),

                _buildContactRow(
                    isDark, LucideIcons.mail, trainer['email'] ?? 'email@exemplo.com'),
                const SizedBox(height: 8),
                _buildContactRow(isDark, LucideIcons.phone,
                    trainer['phone'] ?? '(11) 99999-9999'),
                const SizedBox(height: 8),
                _buildContactRow(isDark, LucideIcons.mapPin,
                    trainer['location'] ?? 'Sao Paulo, SP'),

                const SizedBox(height: 24),

                // Schedule
                Text(
                  'Horarios',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildScheduleChip(isDark, 'Seg', '06:00 - 12:00'),
                    _buildScheduleChip(isDark, 'Ter', '06:00 - 12:00'),
                    _buildScheduleChip(isDark, 'Qua', '06:00 - 12:00'),
                    _buildScheduleChip(isDark, 'Qui', '06:00 - 12:00'),
                    _buildScheduleChip(isDark, 'Sex', '06:00 - 12:00'),
                    _buildScheduleChip(isDark, 'Sab', '08:00 - 14:00'),
                  ],
                ),

                const SizedBox(height: 24),

                // Recent students
                Text(
                  'Alunos Recentes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),

                const SizedBox(height: 12),

                // Students data not yet available from API
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.users,
                        size: 20,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Lista de alunos sera exibida aqui',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
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
                        },
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.destructive.withAlpha(20),
                            border: Border.all(
                              color: AppColors.destructive.withAlpha(50),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.userX,
                                  size: 18, color: AppColors.destructive),
                              const SizedBox(width: 8),
                              Text(
                                'Desativar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.destructive,
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
                          HapticFeedback.lightImpact();
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
                              Icon(LucideIcons.pencil,
                                  size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Editar Perfil',
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
      ),
    );
  }

  Widget _buildDetailStat(String value, String label, bool isDark) {
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
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(bool isDark, IconData icon, String value) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleChip(bool isDark, String day, String hours) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainerCard extends StatelessWidget {
  final Map<String, dynamic> trainer;
  final bool isDark;
  final VoidCallback onTap;

  const _TrainerCard({
    required this.trainer,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
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
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      trainer['initials'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: trainer['status'] == 'active'
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
            ),

            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trainer['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trainer['specialty'],
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.users,
                        size: 12,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trainer['students']} alunos',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        LucideIcons.star,
                        size: 12,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trainer['rating']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ],
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
}

class _RoleOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _RoleOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(20)
              : (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.foregroundDark
                      : AppColors.foreground),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.foregroundDark
                        : AppColors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

