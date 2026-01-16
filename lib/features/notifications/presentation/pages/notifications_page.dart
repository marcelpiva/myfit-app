import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../providers/notifications_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
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

    // Load notifications
    Future.microtask(() {
      ref.read(notificationsProvider.notifier).loadNotifications();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(notificationsProvider.notifier).loadNotifications();
  }

  void _markAsRead(String id) {
    ref.read(notificationsProvider.notifier).markAsRead(id);
  }

  void _markAllAsRead() {
    HapticFeedback.mediumImpact();
    ref.read(notificationsProvider.notifier).markAllAsRead();
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.workout:
        return LucideIcons.dumbbell;
      case NotificationType.checkin:
        return LucideIcons.checkCircle;
      case NotificationType.message:
        return LucideIcons.messageCircle;
      case NotificationType.achievement:
        return LucideIcons.trophy;
      case NotificationType.system:
        return LucideIcons.bell;
    }
  }

  Color _getColorForType(NotificationType type, bool isDark) {
    switch (type) {
      case NotificationType.workout:
        return isDark ? AppColors.primaryDark : AppColors.primary;
      case NotificationType.checkin:
        return const Color(0xFF10B981); // Green
      case NotificationType.message:
        return const Color(0xFF8B5CF6); // Purple
      case NotificationType.achievement:
        return const Color(0xFFF59E0B); // Amber
      case NotificationType.system:
        return isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'Ha ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Ha ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return 'Ha ${difference.inDays} dias';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  Widget _buildErrorState(BuildContext context, bool isDark, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? AppColors.cardDark : AppColors.card,
              ),
              child: Icon(
                LucideIcons.alertCircle,
                size: 36,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erro ao carregar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tente novamente mais tarde.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onRefresh,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notificationsState = ref.watch(notificationsProvider);
    final notifications = notificationsState.notifications;
    final unreadCount = notificationsState.unreadCount;

    return Scaffold(
      body: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isDark ? AppColors.cardDark : AppColors.card,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.arrowLeft,
                            size: 18,
                            color: isDark
                                ? AppColors.foregroundDark
                                : AppColors.foreground,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Notificacoes',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (unreadCount > 0)
                        GestureDetector(
                          onTap: _markAllAsRead,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isDark ? AppColors.cardDark : AppColors.card,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.border,
                              ),
                            ),
                            child: Icon(
                              LucideIcons.checkCheck,
                              size: 18,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 40),
                    ],
                  ),
                ),

                // Unread badge
                if (unreadCount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: (isDark ? AppColors.primaryDark : AppColors.primary)
                            .withAlpha(25),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.bellRing,
                            size: 18,
                            color: isDark
                                ? AppColors.primaryDark
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$unreadCount ${unreadCount == 1 ? 'nova notificacao' : 'novas notificacoes'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (unreadCount > 0) const SizedBox(height: 16),

                // Notifications list
                Expanded(
                  child: notificationsState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : notificationsState.error != null
                          ? _buildErrorState(context, isDark, notificationsState.error!)
                          : notifications.isEmpty
                              ? _buildEmptyState(context, isDark)
                              : RefreshIndicator(
                                  onRefresh: _onRefresh,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    itemCount: notifications.length,
                                    itemBuilder: (context, index) {
                                      final notification = notifications[index];
                                      return _buildNotificationCard(
                                        context,
                                        isDark,
                                        notification,
                                        index,
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

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? AppColors.cardDark : AppColors.card,
              ),
              child: Icon(
                LucideIcons.bellOff,
                size: 36,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma notificacao',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Voce vera aqui atualizacoes sobre\nseus treinos, mensagens e mais.',
              textAlign: TextAlign.center,
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
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    bool isDark,
    NotificationItem notification,
    int index,
  ) {
    final color = _getColorForType(notification.type, isDark);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isDark
                ? AppColors.cardDark.withAlpha(notification.isRead ? 100 : 200)
                : AppColors.card.withAlpha(notification.isRead ? 150 : 255),
            border: Border.all(
              color: notification.isRead
                  ? (isDark ? AppColors.borderDark : AppColors.border)
                  : color.withAlpha(100),
              width: notification.isRead ? 1 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: color.withAlpha(25),
                ),
                child: Icon(
                  _getIconForType(notification.type),
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: isDark
                                  ? AppColors.foregroundDark
                                  : AppColors.foreground,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimeAgo(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: (isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground)
                            .withAlpha(180),
                      ),
                    ),
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
