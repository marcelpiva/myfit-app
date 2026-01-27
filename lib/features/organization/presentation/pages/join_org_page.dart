import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/haptic_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/tokens/animations.dart';
import '../../../../core/error/api_exceptions.dart';
import '../../../../core/providers/context_provider.dart';
import '../../../../core/services/organization_service.dart';

class JoinOrgPage extends ConsumerStatefulWidget {
  const JoinOrgPage({super.key});

  @override
  ConsumerState<JoinOrgPage> createState() => _JoinOrgPageState();
}

class _JoinOrgPageState extends ConsumerState<JoinOrgPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final _codeController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;

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
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Format: MFP-XXXXX (e.g., MFP-A1B2C)
  bool get _canJoin {
    final code = _codeController.text.trim().toUpperCase();
    // Accept format MFP-XXXXX where X is hex (0-9, A-F)
    return RegExp(r'^MFP-[A-F0-9]{5}$').hasMatch(code);
  }

  Future<void> _joinOrganization() async {
    if (!_canJoin) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final code = _codeController.text.trim().toUpperCase();
    final orgService = OrganizationService();

    try {
      // First, preview the invite to get organization details
      final preview = await orgService.getInvitePreviewByCode(code);

      if (!mounted) return;

      // Show confirmation dialog with organization details
      final confirmed = await _showConfirmationDialog(
        organizationName: preview['organization_name'] ?? 'Organização',
        inviterName: preview['invited_by_name'] ?? 'Desconhecido',
        role: preview['role'] ?? 'student',
      );

      if (!confirmed || !mounted) {
        setState(() => _isLoading = false);
        return;
      }

      // Accept the invite
      await orgService.acceptInviteByCode(code);

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Convite aceito com sucesso!', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.success,
        ),
      );

      // Invalidate providers to refresh memberships
      ref.invalidate(trainAloneModeProvider);

      context.go(RouteNames.orgSelector);
    } on NotFoundException {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Código de convite não encontrado. Verifique e tente novamente.';
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.userMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erro ao processar convite. Tente novamente.';
        });
      }
    }
  }

  Future<bool> _showConfirmationDialog({
    required String organizationName,
    required String inviterName,
    required String role,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roleLabel = _getRoleLabel(role);

    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                LucideIcons.userPlus,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Confirmar Entrada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Você foi convidado por $inviterName para entrar em:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              organizationName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                roleLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticUtils.mediumImpact();
                  Navigator.pop(sheetContext, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Aceitar Convite',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(sheetContext, false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(sheetContext).padding.bottom),
          ],
        ),
      ),
    );

    return result ?? false;
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'student':
        return 'Aluno';
      case 'trainer':
        return 'Personal Trainer';
      case 'coach':
        return 'Coach';
      case 'nutritionist':
        return 'Nutricionista';
      case 'gym_admin':
        return 'Administrador';
      case 'gym_owner':
        return 'Proprietário';
      default:
        return 'Membro';
    }
  }

  Future<void> _pasteCode() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _codeController.text = data!.text!.trim().toUpperCase();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasStudentProfile = ref.watch(hasStudentRoleProvider);
    final isTrainAlone = ref.watch(trainAloneModeProvider).valueOrNull ?? false;
    // Hide train alone option if user already has a student profile OR is already in train alone mode
    final showTrainAloneOption = !hasStudentProfile && !isTrainAlone;

    return Scaffold(
      body: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.background,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                _buildHeader(isDark),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Illustration/Icon
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          child: Icon(
                            LucideIcons.userPlus,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title and description
                      Center(
                        child: Text(
                          'Como você quer treinar?',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Escolha como deseja começar sua jornada fitness',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Train alone option - Only show if user has no student profile AND is not already in train alone mode
                      if (showTrainAloneOption) ...[
                        _buildTrainAloneOption(isDark),
                        const SizedBox(height: 16),

                        // Divider with "ou"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: isDark ? AppColors.borderDark : AppColors.border,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'ou',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: isDark ? AppColors.borderDark : AppColors.border,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                      ],

                      // Code input section
                      Text(
                        'Código de Convite',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Digite o código fornecido pelo seu personal ou academia',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _codeController,
                              focusNode: _focusNode,
                              textCapitalization: TextCapitalization.characters,
                              onChanged: (_) => setState(() => _errorMessage = null),
                              decoration: InputDecoration(
                                hintText: 'MFP-A1B2C',
                                filled: true,
                                fillColor: isDark ? AppColors.cardDark : AppColors.card,
                                prefixIcon: Icon(
                                  LucideIcons.hash,
                                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: _errorMessage != null
                                        ? AppColors.destructive
                                        : (isDark ? AppColors.borderDark : AppColors.border),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: _errorMessage != null
                                        ? AppColors.destructive
                                        : (isDark ? AppColors.borderDark : AppColors.border),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: _errorMessage != null
                                        ? AppColors.destructive
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              HapticUtils.lightImpact();
                              _pasteCode();
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.cardDark.withAlpha(150)
                                    : AppColors.card.withAlpha(200),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? AppColors.borderDark : AppColors.border,
                                ),
                              ),
                              child: Icon(
                                LucideIcons.clipboard,
                                size: 20,
                                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.destructive.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.destructive.withAlpha(50)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.alertCircle,
                                size: 18,
                                color: AppColors.destructive,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.destructive,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // QR Code option
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            HapticUtils.lightImpact();
                            context.push('/qr-scanner');
                          },
                          icon: Icon(LucideIcons.scanLine, size: 18),
                          label: const Text('Escanear QR Code'),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Info box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDark.withAlpha(150)
                              : AppColors.card.withAlpha(200),
                          borderRadius: BorderRadius.circular(8),
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
                                  LucideIcons.info,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Como funciona?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildInfoItem(isDark, '1', 'Digite o código de convite recebido'),
                            _buildInfoItem(isDark, '2', 'Sua solicitação será enviada ao administrador'),
                            _buildInfoItem(isDark, '3', 'Aguarde a aprovação para acessar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

                // Footer
                _buildFooter(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticUtils.lightImpact();
              context.pop();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark.withAlpha(150)
                    : AppColors.card.withAlpha(200),
                borderRadius: BorderRadius.circular(8),
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
          const Spacer(),
          Text(
            'Entrar na Organização',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildInfoItem(bool isDark, String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainAloneOption(bool isDark) {
    return GestureDetector(
      onTap: () {
        HapticUtils.lightImpact();
        _showTrainAloneConfirmation(isDark);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark.withAlpha(100)
              : AppColors.card.withAlpha(150),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.dumbbell,
                size: 24,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Treinar por conta própria',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Crie seus próprios treinos sem personal',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  void _showTrainAloneConfirmation(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                LucideIcons.dumbbell,
                size: 36,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Treinar sozinho',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.foregroundDark : AppColors.foreground,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Você poderá criar seus próprios treinos e acompanhar seu progresso. A qualquer momento você pode adicionar um personal digitando o código de convite.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  HapticUtils.mediumImpact();
                  Navigator.pop(sheetContext);

                  // Save train alone preference
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('train_alone_mode', true);

                  // Clear any active organization context
                  ref.read(activeContextProvider.notifier).clearContext();

                  // Invalidate train alone provider so org selector picks up the change
                  ref.invalidate(trainAloneModeProvider);

                  // Navigate to student home
                  if (mounted) {
                    context.go(RouteNames.home);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Começar a treinar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(sheetContext),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(sheetContext).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.background.withAlpha(200),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _canJoin && !_isLoading ? () {
            HapticUtils.lightImpact();
            _joinOrganization();
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Enviar Solicitação'),
        ),
      ),
    );
  }
}
