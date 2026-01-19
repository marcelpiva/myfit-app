import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../../../../core/services/organization_service.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';

/// Page for accepting organization invites via deep link
/// Route: /invite/:token
class InviteAcceptPage extends ConsumerStatefulWidget {
  final String token;

  const InviteAcceptPage({
    super.key,
    required this.token,
  });

  @override
  ConsumerState<InviteAcceptPage> createState() => _InviteAcceptPageState();
}

class _InviteAcceptPageState extends ConsumerState<InviteAcceptPage> {
  bool _isLoading = true;
  bool _isAccepting = false;
  String? _error;
  Map<String, dynamic>? _inviteData;

  @override
  void initState() {
    super.initState();
    _loadInvitePreview();
  }

  Future<void> _loadInvitePreview() async {
    try {
      final orgService = OrganizationService();
      final preview = await orgService.getInvitePreview(widget.token);

      if (mounted) {
        setState(() {
          _inviteData = preview;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Convite não encontrado ou expirado';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _acceptInvite() async {
    final authState = ref.read(authProvider);

    if (!authState.isAuthenticated) {
      // User is not logged in - go to login with token
      context.go('${RouteNames.login}?invite_token=${widget.token}');
      return;
    }

    setState(() => _isAccepting = true);

    try {
      final orgService = OrganizationService();
      await orgService.acceptInvite(widget.token);

      if (mounted) {
        HapticUtils.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.checkCircle, color: Colors.white, size: 18),
                const SizedBox(width: 12),
                Text('Bem-vindo a ${_inviteData?['organization_name'] ?? 'equipe'}!'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
        // Navigate to org selector to select the new organization
        context.go(RouteNames.orgSelector);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAccepting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao aceitar convite: ${e.toString()}'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
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
          child: _isLoading
              ? _buildLoadingState(isDark)
              : _error != null
                  ? _buildErrorState(isDark)
                  : _buildInviteContent(isDark, authState.isAuthenticated),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? AppColors.primaryDark : AppColors.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Carregando convite...',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: FadeInUp(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.destructive.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.alertTriangle,
                  size: 40,
                  color: AppColors.destructive,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Convite Inválido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _error ?? 'Este convite não existe ou já expirou.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    HapticUtils.lightImpact();
                    context.go(RouteNames.welcome);
                  },
                  child: const Text('Voltar ao Início'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInviteContent(bool isDark, bool isAuthenticated) {
    final organizationName = _inviteData?['organization_name'] ?? 'Organização';
    final invitedByName = _inviteData?['invited_by_name'] ?? 'Um profissional';
    final role = _inviteData?['role'] ?? 'student';
    final email = _inviteData?['email'] ?? '';

    String roleLabel;
    switch (role) {
      case 'student':
        roleLabel = 'Aluno';
        break;
      case 'trainer':
        roleLabel = 'Treinador';
        break;
      case 'nutritionist':
        roleLabel = 'Nutricionista';
        break;
      case 'coach':
        roleLabel = 'Coach';
        break;
      default:
        roleLabel = 'Membro';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Logo or Icon
          FadeInUp(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark ? AppColors.primaryDark : AppColors.primary,
                    isDark ? AppColors.secondaryDark : AppColors.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(isDark ? 40 : 60),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.userCheck,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Title
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Você foi convidado!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          FadeInUp(
            delay: const Duration(milliseconds: 150),
            child: Text(
              '$invitedByName convidou você para se juntar à equipe.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForeground,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Invite details card
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: LucideIcons.building2,
                    label: 'Organização',
                    value: organizationName,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: LucideIcons.user,
                    label: 'Função',
                    value: roleLabel,
                    isDark: isDark,
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      icon: LucideIcons.mail,
                      label: 'Email',
                      value: email,
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Action buttons
          if (isAuthenticated)
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _isAccepting ? null : _acceptInvite,
                      child: _isAccepting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Aceitar Convite'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      HapticUtils.lightImpact();
                      context.go(RouteNames.orgSelector);
                    },
                    child: Text(
                      'Voltar',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.mutedForegroundDark
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        context.go('${RouteNames.login}?invite_token=${widget.token}');
                      },
                      child: const Text('Já tenho conta'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticUtils.lightImpact();
                        context.go('${RouteNames.register}?invite_token=${widget.token}&email=$email');
                      },
                      child: const Text('Criar nova conta'),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: (isDark ? AppColors.primaryDark : AppColors.primary)
                .withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.primaryDark : AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
