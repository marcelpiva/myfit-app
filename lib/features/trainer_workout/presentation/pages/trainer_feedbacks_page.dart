import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../providers/exercise_feedback_provider.dart';

/// Page for trainers to view and respond to exercise feedbacks
class TrainerFeedbacksPage extends ConsumerStatefulWidget {
  final String? studentId;

  const TrainerFeedbacksPage({
    super.key,
    this.studentId,
  });

  @override
  ConsumerState<TrainerFeedbacksPage> createState() => _TrainerFeedbacksPageState();
}

class _TrainerFeedbacksPageState extends ConsumerState<TrainerFeedbacksPage>
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use student-specific provider if studentId is provided
    final feedbackState = widget.studentId != null
        ? ref.watch(studentFeedbacksProvider(widget.studentId!))
        : ref.watch(trainerFeedbacksProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: const Text('Feedbacks dos Alunos'),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () {
              HapticUtils.lightImpact();
              if (widget.studentId != null) {
                ref.read(studentFeedbacksProvider(widget.studentId!).notifier).refresh();
              } else {
                ref.read(trainerFeedbacksProvider.notifier).refresh();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: isDark ? AppColors.foregroundDark : AppColors.foreground,
          unselectedLabelColor: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.repeat, size: 16),
                  const SizedBox(width: 8),
                  const Text('Trocas'),
                  if (feedbackState.pendingSwapCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.destructive,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${feedbackState.pendingSwapCount}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.messageSquare, size: 16),
                  const SizedBox(width: 8),
                  const Text('Todos'),
                  if (feedbackState.totalCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${feedbackState.totalCount}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: feedbackState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : feedbackState.error != null
              ? _buildErrorState(feedbackState.error!, isDark)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // Swap Requests Tab
                    _buildSwapRequestsList(feedbackState.swapRequests, isDark),
                    // All Feedbacks Tab
                    _buildAllFeedbacksList(feedbackState.feedbacks, isDark),
                  ],
                ),
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: AppColors.destructive.withAlpha(150),
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                if (widget.studentId != null) {
                  ref.read(studentFeedbacksProvider(widget.studentId!).notifier).refresh();
                } else {
                  ref.read(trainerFeedbacksProvider.notifier).refresh();
                }
              },
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapRequestsList(List<Map<String, dynamic>> swaps, bool isDark) {
    if (swaps.isEmpty) {
      return _buildEmptyState(
        'Nenhum pedido de troca',
        'Quando alunos solicitarem trocar exercicios, eles aparecerão aqui.',
        LucideIcons.repeat,
        isDark,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.studentId != null) {
          await ref.read(studentFeedbacksProvider(widget.studentId!).notifier).loadFeedbacks();
        } else {
          await ref.read(trainerFeedbacksProvider.notifier).loadFeedbacks();
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: swaps.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final swap = swaps[index];
          return _SwapRequestCard(
            swap: swap,
            isDark: isDark,
            onRespond: () => _showRespondDialog(swap),
          );
        },
      ),
    );
  }

  Widget _buildAllFeedbacksList(List<Map<String, dynamic>> feedbacks, bool isDark) {
    if (feedbacks.isEmpty) {
      return _buildEmptyState(
        'Nenhum feedback ainda',
        'Quando alunos avaliarem exercicios, os feedbacks aparecerão aqui.',
        LucideIcons.messageSquare,
        isDark,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.studentId != null) {
          await ref.read(studentFeedbacksProvider(widget.studentId!).notifier).loadFeedbacks();
        } else {
          await ref.read(trainerFeedbacksProvider.notifier).loadFeedbacks();
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: feedbacks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final feedback = feedbacks[index];
          return _FeedbackCard(
            feedback: feedback,
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.primary.withAlpha(150),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
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

  void _showRespondDialog(Map<String, dynamic> swap) {
    final responseController = TextEditingController();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24 + MediaQuery.of(ctx).viewInsets.bottom,
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

            // Title
            Text(
              'Responder Pedido de Troca',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Exercise info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withAlpha(40)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.dumbbell, size: 20, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          swap['exercise_name'] as String? ?? 'Exercício',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (swap['comment'] != null && (swap['comment'] as String).isNotEmpty)
                          Text(
                            '"${swap['comment']}"',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Response field
            TextField(
              controller: responseController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: 'Sua resposta',
                hintText: 'Ex: Substituí por Supino Inclinado com Halteres',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // TODO: Add exercise picker for replacement

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () async {
                      if (responseController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Digite uma resposta'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(ctx);
                      HapticUtils.mediumImpact();

                      final success = widget.studentId != null
                          ? await ref
                              .read(studentFeedbacksProvider(widget.studentId!).notifier)
                              .respondToSwap(
                                swap['id'] as String,
                                response: responseController.text.trim(),
                              )
                          : await ref.read(trainerFeedbacksProvider.notifier).respondToSwap(
                                swap['id'] as String,
                                response: responseController.text.trim(),
                              );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  success ? LucideIcons.checkCircle : LucideIcons.alertCircle,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(success ? 'Resposta enviada' : 'Erro ao enviar resposta'),
                              ],
                            ),
                            backgroundColor: success ? AppColors.success : AppColors.destructive,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(LucideIcons.send, size: 16),
                    label: const Text('Enviar Resposta'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card for swap request
class _SwapRequestCard extends StatelessWidget {
  final Map<String, dynamic> swap;
  final bool isDark;
  final VoidCallback onRespond;

  const _SwapRequestCard({
    required this.swap,
    required this.isDark,
    required this.onRespond,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = swap['responded_at'] == null;
    final studentName = swap['student_name'] as String? ?? 'Aluno';
    final exerciseName = swap['exercise_name'] as String? ?? 'Exercício';
    final comment = swap['comment'] as String?;
    final createdAt = _formatDate(swap['created_at'] as String?);
    final trainerResponse = swap['trainer_response'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending
              ? AppColors.warning.withAlpha(100)
              : (isDark ? AppColors.borderDark : AppColors.border),
          width: isPending ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isPending ? AppColors.warning : AppColors.success).withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isPending ? LucideIcons.repeat : LucideIcons.checkCircle,
                    size: 20,
                    color: isPending ? AppColors.warning : AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        createdAt,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPending ? AppColors.warning : AppColors.success,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPending ? 'Pendente' : 'Respondido',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Exercise info
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.backgroundDark : AppColors.background).withAlpha(150),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.dumbbell, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exerciseName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Comment (if any)
          if (comment != null && comment.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.messageCircle,
                    size: 14,
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '"$comment"',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Trainer response (if responded)
          if (!isPending && trainerResponse != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withAlpha(40)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.checkCircle, size: 14, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trainerResponse,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Respond button (if pending)
          if (isPending) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    onRespond();
                  },
                  icon: const Icon(LucideIcons.reply, size: 16),
                  label: const Text('Responder'),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return 'há ${diff.inMinutes} min';
      } else if (diff.inHours < 24) {
        return 'há ${diff.inHours}h';
      } else if (diff.inDays < 7) {
        return 'há ${diff.inDays} dias';
      } else {
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      return '';
    }
  }
}

/// Card for general feedback
class _FeedbackCard extends StatelessWidget {
  final Map<String, dynamic> feedback;
  final bool isDark;

  const _FeedbackCard({
    required this.feedback,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentName = feedback['student_name'] as String? ?? 'Aluno';
    final exerciseName = feedback['exercise_name'] as String? ?? 'Exercício';
    final feedbackType = feedback['feedback_type'] as String? ?? 'liked';
    final comment = feedback['comment'] as String?;
    final createdAt = _formatDate(feedback['created_at'] as String?);

    final (icon, color, label) = switch (feedbackType) {
      'liked' => (LucideIcons.thumbsUp, AppColors.success, 'Gostou'),
      'disliked' => (LucideIcons.thumbsDown, AppColors.warning, 'Não gostou'),
      'swap' => (LucideIcons.repeat, AppColors.info, 'Quer trocar'),
      _ => (LucideIcons.messageSquare, AppColors.primary, 'Feedback'),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
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
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      studentName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  exerciseName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
                if (comment != null && comment.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '"$comment"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            createdAt,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d';
      } else {
        return '${date.day}/${date.month}';
      }
    } catch (_) {
      return '';
    }
  }
}
