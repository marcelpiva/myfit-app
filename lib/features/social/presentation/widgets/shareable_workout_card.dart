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

/// Data for a completed workout to share
class ShareableWorkoutData {
  final String workoutName;
  final int durationMinutes;
  final int exerciseCount;
  final int setCount;
  final double? totalVolume;
  final int? caloriesBurned;
  final String? personalRecord;

  const ShareableWorkoutData({
    required this.workoutName,
    required this.durationMinutes,
    required this.exerciseCount,
    required this.setCount,
    this.totalVolume,
    this.caloriesBurned,
    this.personalRecord,
  });
}

/// A shareable workout card that can be converted to an image and shared
class ShareableWorkoutCard extends StatefulWidget {
  final ShareableWorkoutData workoutData;
  final String userName;
  final String? userAvatarUrl;
  final VoidCallback? onClose;

  const ShareableWorkoutCard({
    super.key,
    required this.workoutData,
    required this.userName,
    this.userAvatarUrl,
    this.onClose,
  });

  @override
  State<ShareableWorkoutCard> createState() => _ShareableWorkoutCardState();
}

class _ShareableWorkoutCardState extends State<ShareableWorkoutCard> {
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
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success.withAlpha(30),
            AppColors.primary.withAlpha(20),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success.withAlpha(80),
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
              const Icon(
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

          // Workout complete badge
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.success,
                  Color(0xFF059669),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withAlpha(80),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                LucideIcons.checkCircle,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Workout name
          Text(
            widget.workoutData.workoutName,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'TREINO COMPLETO!',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // Stats grid
          Row(
            children: [
              _StatItem(
                icon: LucideIcons.clock,
                value: '${widget.workoutData.durationMinutes}',
                label: 'min',
                isDark: isDark,
              ),
              _StatItem(
                icon: LucideIcons.dumbbell,
                value: '${widget.workoutData.exerciseCount}',
                label: 'exercícios',
                isDark: isDark,
              ),
              _StatItem(
                icon: LucideIcons.repeat,
                value: '${widget.workoutData.setCount}',
                label: 'séries',
                isDark: isDark,
              ),
            ],
          ),

          if (widget.workoutData.totalVolume != null ||
              widget.workoutData.caloriesBurned != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.workoutData.totalVolume != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.scale, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.workoutData.totalVolume!.toStringAsFixed(0)}kg',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (widget.workoutData.totalVolume != null &&
                    widget.workoutData.caloriesBurned != null)
                  const SizedBox(width: 8),
                if (widget.workoutData.caloriesBurned != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.flame, size: 14, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.workoutData.caloriesBurned}cal',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],

          // Personal record badge
          if (widget.workoutData.personalRecord != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.trophy, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'PR: ${widget.workoutData.personalRecord}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],

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
                    style: const TextStyle(
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

          const SizedBox(height: 8),

          Text(
            _formatDate(DateTime.now()),
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareAsImage() async {
    if (_isSharing) return;

    setState(() => _isSharing = true);
    HapticUtils.mediumImpact();

    try {
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _isSharing = false);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/workout_$timestamp.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Completei "${widget.workoutData.workoutName}" no MyFit! '
            '${widget.workoutData.durationMinutes}min | '
            '${widget.workoutData.exerciseCount} exercícios | '
            '${widget.workoutData.setCount} séries',
      );
    } catch (e) {
      debugPrint('Error sharing workout: $e');
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _copyAsText() async {
    HapticUtils.lightImpact();

    var text = '''
Treino Completo no MyFit!

${widget.workoutData.workoutName}
${widget.workoutData.durationMinutes} min | ${widget.workoutData.exerciseCount} exercícios | ${widget.workoutData.setCount} séries
''';

    if (widget.workoutData.totalVolume != null) {
      text += 'Volume total: ${widget.workoutData.totalVolume!.toStringAsFixed(0)}kg\n';
    }

    if (widget.workoutData.personalRecord != null) {
      text += '\nNovo Recorde: ${widget.workoutData.personalRecord}\n';
    }

    text += '\n#MyFit #Fitness #Treino';

    await Share.share(text);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
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

/// Shows the shareable workout dialog
Future<void> showShareableWorkout(
  BuildContext context, {
  required ShareableWorkoutData workoutData,
  required String userName,
  String? userAvatarUrl,
}) {
  return showDialog(
    context: context,
    builder: (context) => ShareableWorkoutCard(
      workoutData: workoutData,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
    ),
  );
}
