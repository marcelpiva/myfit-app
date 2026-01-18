import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
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
class _InviteStudentSheetContent extends StatefulWidget {
  final bool isDark;
  final String orgId;
  final VoidCallback? onSuccess;

  const _InviteStudentSheetContent({
    required this.isDark,
    required this.orgId,
    this.onSuccess,
  });

  @override
  State<_InviteStudentSheetContent> createState() =>
      _InviteStudentSheetContentState();
}

class _InviteStudentSheetContentState extends State<_InviteStudentSheetContent> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
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
      await orgService.sendInvite(
        widget.orgId,
        email: email,
        role: 'student',
      );
      debugPrint('🟢 Invite sent successfully');

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

        // Extract a more user-friendly error message
        String errorMsg = 'Erro desconhecido';
        if (e.toString().contains('401')) {
          errorMsg = 'Sessão expirada. Faça login novamente.';
        } else if (e.toString().contains('403')) {
          errorMsg = 'Você não tem permissão para convidar alunos.';
        } else if (e.toString().contains('404')) {
          errorMsg = 'Organização não encontrada.';
        } else if (e.toString().contains('409')) {
          errorMsg = 'Este email já foi convidado.';
        } else {
          errorMsg = e.toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro: $errorMsg',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.destructive,
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
