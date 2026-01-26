import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/providers/context_provider.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/animated_progress_bar.dart';
import '../../widgets/invite_action_card.dart';

/// Redesigned Invite Student step with action cards
class TrainerInviteStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final double progress;

  const TrainerInviteStep({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    this.progress = 0.4,
  });

  @override
  ConsumerState<TrainerInviteStep> createState() => _TrainerInviteStepState();
}

class _TrainerInviteStepState extends ConsumerState<TrainerInviteStep> {
  String? _inviteLink;
  bool _isLoading = false;
  bool _isSharing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateInviteToken();
  }

  Future<void> _generateInviteToken() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get active context for organization ID
      final context = ref.read(activeContextProvider);
      if (context == null) {
        // No org yet - will be created on completion
        // Generate a preview token for display
        setState(() {
          _inviteLink = 'https://myfit.app/join/preview';
          _isLoading = false;
        });
        return;
      }

      final response = await ApiClient.instance.post(
        ApiEndpoints.organizationInvite(context.organization.id),
        data: {'role': 'student'},
      );

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'] as String?;
        if (token != null) {
          setState(() {
            _inviteLink = 'https://myfit.app/join/$token';
            _isLoading = false;
          });
        } else {
          // No token returned - use preview link
          setState(() {
            _inviteLink = 'https://myfit.app/join/preview';
            _isLoading = false;
          });
        }
      } else {
        // Non-200 response - use preview link
        setState(() {
          _inviteLink = 'https://myfit.app/join/preview';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error generating invite token: $e');
      setState(() {
        _error = 'Erro ao gerar convite';
        _isLoading = false;
      });
    }
  }

  String get _shareMessage {
    final user = ref.read(currentUserProvider);
    final trainerName = user?.name ?? 'seu Personal';
    return 'Olá! Sou $trainerName, seu Personal Trainer no MyFit.\n\n'
        'Use o link abaixo para se conectar comigo e começar seus treinos personalizados:\n\n'
        '${_inviteLink ?? ''}';
  }

  Future<void> _shareViaWhatsApp() async {
    if (_inviteLink == null) return;

    setState(() => _isSharing = true);
    HapticUtils.mediumImpact();

    try {
      final encodedMessage = Uri.encodeComponent(_shareMessage);
      final whatsappUrl = Uri.parse('whatsapp://send?text=$encodedMessage');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
        // Mark as invited
        ref.read(trainerOnboardingProvider.notifier).markStudentInvited();
      } else {
        // Fallback to web WhatsApp
        final webWhatsapp = Uri.parse(
          'https://wa.me/?text=$encodedMessage',
        );
        await launchUrl(webWhatsapp, mode: LaunchMode.externalApplication);
        ref.read(trainerOnboardingProvider.notifier).markStudentInvited();
      }
    } catch (e) {
      debugPrint('Error sharing via WhatsApp: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _showQRCode() {
    if (_inviteLink == null) return;

    HapticUtils.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QRCodeSheet(
        inviteLink: _inviteLink!,
        trainerName: ref.read(currentUserProvider)?.name ?? 'Personal',
      ),
    );
  }

  Future<void> _shareOther() async {
    if (_inviteLink == null) return;

    HapticUtils.mediumImpact();

    await Share.share(
      _shareMessage,
      subject: 'Convite MyFit',
    );
    ref.read(trainerOnboardingProvider.notifier).markStudentInvited();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              // Header with progress
              _buildHeader(context, isDark),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Illustration
                      const InviteIllustration(),
                      const SizedBox(height: 24),
                      // Title
                      Text(
                        'Convide seu primeiro aluno',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Compartilhe o link de convite e comece a treinar seus alunos no MyFit',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.mutedForegroundDark
                              : AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Action cards
                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_error != null)
                        _buildErrorState(isDark)
                      else ...[
                        WhatsAppInviteCard(
                          onTap: _shareViaWhatsApp,
                          isLoading: _isSharing,
                        ),
                        const SizedBox(height: 12),
                        CopyLinkInviteCard(
                          link: _inviteLink,
                          onCopied: () {},
                        ),
                        const SizedBox(height: 12),
                        QRCodeInviteCard(
                          onTap: _showQRCode,
                        ),
                        const SizedBox(height: 12),
                        OtherShareCard(
                          onTap: _shareOther,
                        ),
                        const SizedBox(height: 24),
                        // Message preview
                        InvitePreviewMessage(
                          trainerName: user?.name ?? 'Personal',
                          inviteLink: _inviteLink,
                        ),
                      ],
                      const SizedBox(height: 100), // Space for bottom actions
                    ],
                  ),
                ),
              ),
              // Bottom actions
              _buildBottomActions(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              widget.onBack();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.card,
                borderRadius: BorderRadius.circular(10),
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
          Expanded(
            child: SimpleProgressIndicator(progress: widget.progress),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              widget.onSkip();
            },
            child: Text(
              'Pular',
              style: TextStyle(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.destructive.withAlpha(isDark ? 20 : 15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.destructive.withAlpha(50),
        ),
      ),
      child: Column(
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 48,
            color: AppColors.destructive,
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Erro desconhecido',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _generateInviteToken,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                HapticUtils.mediumImpact();
                widget.onNext();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              HapticUtils.lightImpact();
              // Skip this step - mark for later reminder
              ref.read(trainerOnboardingProvider.notifier).skipCurrentStep();
              widget.onNext();
            },
            child: Text(
              'Fazer depois',
              style: TextStyle(
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for displaying QR code
class _QRCodeSheet extends StatelessWidget {
  final String inviteLink;
  final String trainerName;

  const _QRCodeSheet({
    required this.inviteLink,
    required this.trainerName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Escaneie para conectar',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Peça para seu aluno escanear este QR Code',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // QR Code
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: inviteLink,
                  version: QrVersions.auto,
                  size: 220,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Trainer name badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(isDark ? 30 : 20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.userCog,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      trainerName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Close button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
