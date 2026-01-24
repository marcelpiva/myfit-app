import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/cache/cache.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/error/api_exceptions.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../core/services/organization_service.dart';

/// Shows the invite student bottom sheet
/// This is a standalone function that can be called from anywhere
Future<void> showInviteStudentSheet(
  BuildContext context, {
  required WidgetRef ref,
  required bool isDark,
  VoidCallback? onSuccess,
}) {
  debugPrint('🔵 showInviteStudentSheet() called');

  // Get orgId before showing the sheet
  final orgId = ref.read(activeContextProvider)?.organization.id;
  debugPrint('🔵 orgId: $orgId');

  if (orgId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Erro: organização não encontrada'),
        backgroundColor: AppColors.destructive,
      ),
    );
    return Future.value();
  }

  return showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: true,
    builder: (ctx) {
      debugPrint('🔵 Bottom sheet builder called');
      return _InviteStudentSheetContent(
        isDark: isDark,
        orgId: orgId,
        onSuccess: onSuccess,
      );
    },
  );
}

/// Stateful content widget for the invite sheet
class _InviteStudentSheetContent extends ConsumerStatefulWidget {
  final bool isDark;
  final String orgId;
  final VoidCallback? onSuccess;

  const _InviteStudentSheetContent({
    required this.isDark,
    required this.orgId,
    this.onSuccess,
  });

  @override
  ConsumerState<_InviteStudentSheetContent> createState() =>
      _InviteStudentSheetContentState();
}

class _InviteStudentSheetContentState extends ConsumerState<_InviteStudentSheetContent> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showReactivateDialog(String membershipId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aluno Inativo'),
        content: const Text(
          'Este aluno já está em seus alunos, mas está inativo. Deseja reativá-lo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _reactivateMember(membershipId);
            },
            child: const Text('Reativar'),
          ),
        ],
      ),
    );
  }

  Future<void> _reactivateMember(String membershipId) async {
    setState(() => _isLoading = true);
    try {
      final orgService = OrganizationService();
      await orgService.reactivateMember(widget.orgId, membershipId);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(LucideIcons.checkCircle, color: Colors.white, size: 18),
                SizedBox(width: 12),
                Text('Aluno reativado com sucesso'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reativar aluno: $e'),
            backgroundColor: AppColors.destructive,
          ),
        );
      }
    }
  }

  Future<void> _sendInvite() async {
    // Validate email
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, informe o email do aluno'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Simple email validation
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, informe um email válido'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    HapticUtils.lightImpact();
    setState(() => _isLoading = true);

    // Send invite via API
    try {
      debugPrint('🔵 Sending invite to: $email for org: ${widget.orgId}');
      final orgService = OrganizationService();
      final result = await orgService.sendInvite(
        widget.orgId,
        email: email,
        role: 'student',
      );
      debugPrint('🟢 Invite sent successfully');

      // Emit cache event to refresh pending invites list
      final inviteId = result['id'] as String? ?? '';
      ref.read(cacheEventEmitterProvider).inviteCreated(
            inviteId,
            organizationId: widget.orgId,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.mail, color: Colors.white, size: 18),
                const SizedBox(width: 12),
                Text('Convite enviado para $email'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onSuccess?.call();
      }
    } catch (e, stackTrace) {
      debugPrint('🔴 Error sending invite: $e');
      debugPrint('🔴 Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);

        // Check for structured error response with code
        String? errorCode;
        String? membershipId;
        if (e is ValidationException) {
          // Try to extract code from detail
          final detail = e.fieldErrors;
          if (detail != null && detail.containsKey('code')) {
            errorCode = detail['code']?.firstOrNull;
          }
          if (detail != null && detail.containsKey('membership_id')) {
            membershipId = detail['membership_id']?.firstOrNull;
          }
        }

        // Handle specific error codes from backend
        if (errorCode == 'ALREADY_MEMBER') {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Você já tem esse aluno'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        } else if (errorCode == 'PENDING_INVITE') {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Este aluno já possui um convite pendente'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        } else if (errorCode == 'INACTIVE_MEMBER' && membershipId != null) {
          // Show dialog to reactivate
          _showReactivateDialog(membershipId);
          return;
        }

        // Extract a more user-friendly error message
        String errorMsg;
        final errorString = e.toString();
        if (e is ApiException) {
          errorMsg = e.userMessage;
        } else if (errorString.contains('401')) {
          errorMsg = 'Sessão expirada. Faça login novamente.';
        } else if (errorString.contains('403')) {
          errorMsg = 'Você não tem permissão para convidar alunos.';
        } else if (errorString.contains('404')) {
          errorMsg = 'Organização não encontrada.';
        } else if (errorString.contains('409') || errorString.contains('ALREADY_MEMBER')) {
          errorMsg = 'Você já tem esse aluno.';
        } else if (errorString.contains('PENDING_INVITE')) {
          errorMsg = 'Este aluno já possui um convite pendente.';
        } else if (errorString.contains('INACTIVE_MEMBER')) {
          errorMsg = 'Este aluno está inativo. Deseja reativá-lo?';
        } else {
          errorMsg = 'Erro ao enviar convite. Tente novamente.';
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMsg,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.destructive,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Padding(
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
            'Convidar Aluno',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Envie um convite para seu aluno se juntar ao MyFit',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.mutedForegroundDark
                  : AppColors.mutedForeground,
            ),
          ),

          const SizedBox(height: 24),

          // Nome
          Text(
            'Nome do aluno (opcional)',
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
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Ex: Maria Silva',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Email
          Text(
            'Email do aluno',
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
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'aluno@email.com',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.mutedForegroundDark
                      : AppColors.mutedForeground,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: TextStyle(
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () {
                          HapticUtils.lightImpact();
                          Navigator.pop(context);
                        },
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
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
                  onTap: _isLoading ? null : _sendInvite,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: _isLoading
                          ? AppColors.primary.withAlpha(150)
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          const Icon(LucideIcons.send,
                              size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
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
    );
  }
}
