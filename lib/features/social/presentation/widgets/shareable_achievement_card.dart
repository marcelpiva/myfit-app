import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../gamification/domain/models/achievement.dart';

/// A shareable achievement card that can be converted to an image and shared
class ShareableAchievementCard extends StatefulWidget {
  final Achievement achievement;
  final String userName;
  final String? userAvatarUrl;
  final VoidCallback? onClose;

  const ShareableAchievementCard({
    super.key,
    required this.achievement,
    required this.userName,
    this.userAvatarUrl,
    this.onClose,
  });

  @override
  State<ShareableAchievementCard> createState() => _ShareableAchievementCardState();
}

class _ShareableAchievementCardState extends State<ShareableAchievementCard> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The card to capture
          RepaintBoundary(
            key: _cardKey,
            child: _buildShareCard(isDark, theme),
          ),

          const SizedBox(height: 24),

          // Share actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ShareButton(
                icon: LucideIcons.share2,
                label: 'Compartilhar',
                onTap: _shareAsImage,
                isLoading: _isSharing,
                isDark: isDark,
                isPrimary: true,
              ),
              const SizedBox(width: 16),
              _ShareButton(
                icon: LucideIcons.copy,
                label: 'Copiar Texto',
                onTap: _copyAsText,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 16),

          TextButton(
            onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildShareCard(bool isDark, ThemeData theme) {
    final rarityColor = _getRarityColor(widget.achievement.rarity);

    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            rarityColor.withAlpha(40),
            rarityColor.withAlpha(20),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: rarityColor.withAlpha(100),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App branding
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.dumbbell,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'MyFit',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Achievement icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  rarityColor,
                  rarityColor.withAlpha(180),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: rarityColor.withAlpha(80),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getAchievementEmoji(widget.achievement),
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Rarity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: rarityColor.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: rarityColor.withAlpha(60)),
            ),
            child: Text(
              _getRarityLabel(widget.achievement.rarity),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: rarityColor,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Achievement name
          Text(
            widget.achievement.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Achievement description
          Text(
            widget.achievement.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),

          const SizedBox(height: 20),

          // User info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.userAvatarUrl != null)
                CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(widget.userAvatarUrl!),
                )
              else
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary.withAlpha(30),
                  child: Text(
                    widget.userName.isNotEmpty
                        ? widget.userName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                widget.userName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Points earned
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.star, size: 16, color: AppColors.warning),
                const SizedBox(width: 6),
                Text(
                  '+${widget.achievement.pointsReward} pontos',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),

          if (widget.achievement.unlockedAt != null) ...[
            const SizedBox(height: 12),
            Text(
              _formatDate(widget.achievement.unlockedAt!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _shareAsImage() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);
    HapticUtils.mediumImpact();

    try {
      // Capture the widget as an image
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _isSharing = false);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/achievement_${widget.achievement.id}.png');
      await file.writeAsBytes(pngBytes);

      // Share
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Conquistei "${widget.achievement.name}" no MyFit! ${widget.achievement.description}',
      );
    } catch (e) {
      debugPrint('Error sharing achievement: $e');
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _copyAsText() async {
    HapticUtils.lightImpact();

    final text = '''
Conquistei "${widget.achievement.name}" no MyFit!

${widget.achievement.description}

+${widget.achievement.pointsReward} pontos

#MyFit #Fitness #Conquista
''';

    await Share.share(text);
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return AppColors.success;
      case AchievementRarity.rare:
        return AppColors.info;
      case AchievementRarity.epic:
        return const Color(0xFF9333EA);
      case AchievementRarity.legendary:
        return AppColors.warning;
    }
  }

  String _getRarityLabel(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 'COMUM';
      case AchievementRarity.rare:
        return 'RARA';
      case AchievementRarity.epic:
        return 'EPICA';
      case AchievementRarity.legendary:
        return 'LENDARIA';
    }
  }

  String _getAchievementEmoji(Achievement achievement) {
    switch (achievement.category) {
      case AchievementCategory.consistency:
        return '🔥';
      case AchievementCategory.progress:
        return '📈';
      case AchievementCategory.social:
        return '👥';
      case AchievementCategory.milestone:
        return '🏆';
      case AchievementCategory.special:
        return '⭐';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool isPrimary;
  final bool isLoading;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.isPrimary = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : AppColors.card),
          borderRadius: BorderRadius.circular(14),
          border: isPrimary
              ? null
              : Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    isPrimary ? Colors.white : AppColors.primary,
                  ),
                ),
              )
            else
              Icon(
                icon,
                size: 18,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPrimary
                    ? Colors.white
                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the shareable achievement dialog
Future<void> showShareableAchievement(
  BuildContext context, {
  required Achievement achievement,
  required String userName,
  String? userAvatarUrl,
}) {
  return showDialog(
    context: context,
    builder: (context) => ShareableAchievementCard(
      achievement: achievement,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
    ),
  );
}
