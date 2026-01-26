import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';

/// Large action card for invite options
class InviteActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;

  const InviteActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              HapticUtils.mediumImpact();
              onTap?.call();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withAlpha(isDark ? 30 : 20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withAlpha(60),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withAlpha(isDark ? 50 : 30),
                borderRadius: BorderRadius.circular(16),
              ),
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: color,
                        ),
                      ),
                    )
                  : Icon(
                      icon,
                      size: 28,
                      color: color,
                    ),
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
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
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
              size: 24,
              color: color.withAlpha(180),
            ),
          ],
        ),
      ),
    );
  }
}

/// WhatsApp invite action card
class WhatsAppInviteCard extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const WhatsAppInviteCard({
    super.key,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InviteActionCard(
      title: 'Enviar via WhatsApp',
      subtitle: 'Compartilhe com um toque',
      icon: LucideIcons.messageCircle,
      color: const Color(0xFF25D366), // WhatsApp green
      onTap: onTap,
      isLoading: isLoading,
    );
  }
}

/// Copy link invite action card
class CopyLinkInviteCard extends StatefulWidget {
  final String? link;
  final VoidCallback? onCopied;

  const CopyLinkInviteCard({
    super.key,
    this.link,
    this.onCopied,
  });

  @override
  State<CopyLinkInviteCard> createState() => _CopyLinkInviteCardState();
}

class _CopyLinkInviteCardState extends State<CopyLinkInviteCard> {
  bool _copied = false;

  void _copyLink() async {
    if (widget.link == null) return;

    await Clipboard.setData(ClipboardData(text: widget.link!));
    HapticUtils.mediumImpact();

    setState(() => _copied = true);
    widget.onCopied?.call();

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _copied = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InviteActionCard(
      title: _copied ? 'Link copiado!' : 'Copiar link',
      subtitle: _copied ? 'Cole onde quiser' : 'Compartilhe em qualquer lugar',
      icon: _copied ? LucideIcons.check : LucideIcons.link,
      color: _copied ? AppColors.success : AppColors.info,
      onTap: widget.link != null ? _copyLink : null,
    );
  }
}

/// QR Code invite action card
class QRCodeInviteCard extends StatelessWidget {
  final VoidCallback? onTap;

  const QRCodeInviteCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InviteActionCard(
      title: 'Mostrar QR Code',
      subtitle: 'Escaneie para conectar',
      icon: LucideIcons.qrCode,
      color: AppColors.primary,
      onTap: onTap,
    );
  }
}

/// Other sharing options card
class OtherShareCard extends StatelessWidget {
  final VoidCallback? onTap;

  const OtherShareCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InviteActionCard(
      title: 'Outras opções',
      subtitle: 'Email, SMS, redes sociais...',
      icon: LucideIcons.share2,
      color: AppColors.warning,
      onTap: onTap,
    );
  }
}

/// Invite preview message widget
class InvitePreviewMessage extends StatelessWidget {
  final String trainerName;
  final String? inviteLink;

  const InvitePreviewMessage({
    super.key,
    required this.trainerName,
    this.inviteLink,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.mutedDark : AppColors.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.messageSquare,
                size: 16,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
              const SizedBox(width: 8),
              Text(
                'Prévia da mensagem',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Olá! Sou $trainerName, seu Personal Trainer no MyFit.\n\n'
            'Use o link abaixo para se conectar comigo e começar seus treinos personalizados:\n\n'
            '${inviteLink ?? '[Link de convite]'}',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated illustration for invite step
class InviteIllustration extends StatelessWidget {
  const InviteIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha(isDark ? 30 : 20),
            AppColors.success.withAlpha(isDark ? 30 : 20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Trainer icon
          Positioned(
            left: 40,
            top: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.userCog,
                size: 30,
                color: AppColors.primary,
              ),
            ),
          ),
          // Connection line
          Positioned(
            left: 100,
            top: 45,
            child: Container(
              width: 60,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withAlpha(100),
                    AppColors.success.withAlpha(100),
                  ],
                ),
              ),
            ),
          ),
          // Arrow icon
          Positioned(
            left: 125,
            top: 35,
            child: Icon(
              LucideIcons.arrowRight,
              size: 20,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
          // Student icon
          Positioned(
            right: 40,
            top: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.user,
                size: 30,
                color: AppColors.success,
              ),
            ),
          ),
          // Label
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Conecte-se com seus alunos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
