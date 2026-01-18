import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';

/// Payments and subscription management page
class PaymentsPage extends ConsumerWidget {
  const PaymentsPage({super.key});

  // ==========================================================================
  // MODAL: Help FAQ (Botao 1)
  // ==========================================================================
  void _showHelpModal(BuildContext context, ThemeData theme, bool isDark) {
    HapticUtils.lightImpact();

    final faqs = [
      {
        'question': 'Como funciona a cobranca?',
        'answer': 'A cobranca e feita automaticamente no cartao cadastrado na data de renovacao do seu plano. Voce recebera um email de confirmacao apos cada pagamento.',
      },
      {
        'question': 'Posso trocar de plano?',
        'answer': 'Sim! Voce pode fazer upgrade ou downgrade do seu plano a qualquer momento. A diferenca sera calculada proporcionalmente.',
      },
      {
        'question': 'Como cancelar minha assinatura?',
        'answer': 'Voce pode cancelar sua assinatura a qualquer momento clicando no botao "Cancelar" no card da assinatura ativa. O acesso continua ate o fim do periodo pago.',
      },
      {
        'question': 'Quais formas de pagamento sao aceitas?',
        'answer': 'Aceitamos cartoes de credito (Visa, Mastercard, Elo, American Express) e PIX. Em breve teremos boleto bancario.',
      },
      {
        'question': 'O pagamento e seguro?',
        'answer': 'Sim! Todos os pagamentos sao processados com criptografia SSL e nao armazenamos os dados do seu cartao. Utilizamos gateways de pagamento certificados.',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.helpCircle,
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Central de Ajuda',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Duvidas frequentes sobre pagamentos',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      LucideIcons.x,
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: isDark ? AppColors.borderDark : AppColors.border, height: 1),
            // FAQ List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.mutedDark : AppColors.muted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        faq['question']!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: [
                        Text(
                          faq['answer']!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Contact support button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Abrindo chat de suporte...'),
                        backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.messageCircle),
                  label: const Text('Falar com Suporte'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // MODAL: Subscription Details (Botao 2)
  // ==========================================================================
  void _showSubscriptionDetails(BuildContext context, ThemeData theme, bool isDark) {
    HapticUtils.selectionClick();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header with gradient
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.crown, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Joao',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Plano Mensal de Acompanhamento',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withAlpha(200),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Details
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildDetailItem(theme, isDark, LucideIcons.calendar, 'Data de Inicio', '15 de Outubro de 2024'),
                  _buildDetailItem(theme, isDark, LucideIcons.refreshCw, 'Proxima Renovacao', '15 de Fevereiro de 2025'),
                  _buildDetailItem(theme, isDark, LucideIcons.creditCard, 'Metodo de Pagamento', 'Visa **** 4242'),
                  _buildDetailItem(theme, isDark, LucideIcons.dollarSign, 'Valor Mensal', 'R\$ 250,00'),
                  _buildDetailItem(theme, isDark, LucideIcons.clock, 'Ciclo de Cobranca', 'Mensal'),
                  _buildDetailItem(theme, isDark, LucideIcons.receipt, 'Total Pago', 'R\$ 1.000,00 (4 meses)'),
                  const SizedBox(height: 16),
                  Text(
                    'Beneficios do Plano',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitItem(theme, isDark, 'Treinos personalizados semanais'),
                  _buildBenefitItem(theme, isDark, 'Acompanhamento via chat'),
                  _buildBenefitItem(theme, isDark, 'Ajustes ilimitados no treino'),
                  _buildBenefitItem(theme, isDark, 'Suporte prioritario'),
                ],
              ),
            ),
            // Close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Fechar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(ThemeData theme, bool isDark, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: isDark ? AppColors.primaryDark : AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(ThemeData theme, bool isDark, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(LucideIcons.check, size: 18, color: AppColors.success),
          const SizedBox(width: 10),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  // ==========================================================================
  // MODAL: Manage Subscription (Botao 3)
  // ==========================================================================
  void _showManageSubscription(BuildContext context, ThemeData theme, bool isDark) {
    HapticUtils.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gerenciar Assinatura',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha uma opcao para gerenciar seu plano',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: isDark ? AppColors.borderDark : AppColors.border, height: 1),
            _buildManageOption(
              context, theme, isDark,
              LucideIcons.arrowUpCircle,
              'Fazer Upgrade',
              'Mude para um plano superior',
              AppColors.success,
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Redirecionando para planos superiores...'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
            _buildManageOption(
              context, theme, isDark,
              LucideIcons.arrowDownCircle,
              'Fazer Downgrade',
              'Mude para um plano mais simples',
              Colors.orange,
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Redirecionando para planos inferiores...'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
            _buildManageOption(
              context, theme, isDark,
              LucideIcons.pauseCircle,
              'Pausar Assinatura',
              'Pause por ate 30 dias',
              isDark ? AppColors.primaryDark : AppColors.primary,
              () {
                Navigator.pop(context);
                _showPauseConfirmation(context, theme, isDark);
              },
            ),
            _buildManageOption(
              context, theme, isDark,
              LucideIcons.creditCard,
              'Alterar Pagamento',
              'Mude o metodo de pagamento',
              isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Abrindo metodos de pagamento...'),
                    backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showPauseConfirmation(BuildContext context, ThemeData theme, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(LucideIcons.pauseCircle, color: isDark ? AppColors.primaryDark : AppColors.primary),
            const SizedBox(width: 12),
            const Text('Pausar Assinatura'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voce pode pausar sua assinatura por ate 30 dias. Durante esse periodo:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _buildPauseInfoItem(theme, isDark, 'Nao havera cobranca'),
            _buildPauseInfoItem(theme, isDark, 'Seu acesso sera limitado'),
            _buildPauseInfoItem(theme, isDark, 'A assinatura reativa automaticamente'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Assinatura pausada com sucesso!'),
                  backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Pausar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseInfoItem(ThemeData theme, bool isDark, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(LucideIcons.check, size: 16, color: AppColors.success),
          const SizedBox(width: 8),
          Text(text, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildManageOption(BuildContext context, ThemeData theme, bool isDark, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // DIALOG: Cancel Subscription (Botao 4)
  // ==========================================================================
  void _showCancelConfirmation(BuildContext context, ThemeData theme, bool isDark) {
    HapticUtils.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.destructive.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.alertTriangle, color: AppColors.destructive),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Cancelar Assinatura'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja cancelar sua assinatura do plano Personal Joao?',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Voce ainda tera acesso ate 15 de Fevereiro de 2025',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ao cancelar voce perdera:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildLossItem(theme, 'Treinos personalizados'),
            _buildLossItem(theme, 'Acompanhamento do personal'),
            _buildLossItem(theme, 'Chat com suporte prioritario'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Manter Plano',
              style: TextStyle(
                color: isDark ? AppColors.primaryDark : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticUtils.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Assinatura cancelada. Acesso ate 15/02/2025.'),
                  backgroundColor: AppColors.destructive,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancelar Plano'),
          ),
        ],
      ),
    );
  }

  Widget _buildLossItem(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(LucideIcons.x, size: 16, color: AppColors.destructive),
          const SizedBox(width: 8),
          Text(text, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  // ==========================================================================
  // MODAL: Edit Payment Method (Botao 5)
  // ==========================================================================
  void _showEditPaymentMethod(BuildContext context, ThemeData theme, bool isDark, Map<String, dynamic> method) {
    HapticUtils.selectionClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.mutedDark : AppColors.muted,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                        ),
                        child: Center(
                          child: method['type'] == 'pix'
                              ? Text('PIX', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success))
                              : Icon(LucideIcons.creditCard, color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method['brand'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (method['last4'] != '')
                              Text(
                                'Terminado em ${method['last4']}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (method['type'] != 'pix') ...[
                    Text(
                      'Detalhes do Cartao',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentDetailRow(theme, isDark, 'Bandeira', method['brand'] as String),
                    _buildPaymentDetailRow(theme, isDark, 'Numero', '**** **** **** ${method['last4']}'),
                    _buildPaymentDetailRow(theme, isDark, 'Validade', method['expiry'] as String),
                    const SizedBox(height: 16),
                  ],
                  if (method['isDefault'] != true)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${method['brand']} definido como padrao!', style: const TextStyle(color: Colors.white)),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        icon: const Icon(LucideIcons.star, size: 18),
                        label: const Text('Definir como Padrao'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Fechar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailRow(ThemeData theme, bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MENU: Payment Method Options (Botao 6)
  // ==========================================================================
  void _showPaymentMethodOptions(BuildContext context, ThemeData theme, bool isDark, Map<String, dynamic> method, Offset tapPosition) {
    HapticUtils.lightImpact();

    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        tapPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      color: isDark ? AppColors.cardDark : AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(LucideIcons.edit, size: 18, color: isDark ? AppColors.foregroundDark : AppColors.foreground),
              const SizedBox(width: 12),
              const Text('Editar'),
            ],
          ),
        ),
        if (method['isDefault'] != true)
          PopupMenuItem<String>(
            value: 'default',
            child: Row(
              children: [
                Icon(LucideIcons.star, size: 18, color: isDark ? AppColors.primaryDark : AppColors.primary),
                const SizedBox(width: 12),
                const Text('Definir como padrao'),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'remove',
          child: Row(
            children: [
              Icon(LucideIcons.trash2, size: 18, color: AppColors.destructive),
              const SizedBox(width: 12),
              Text('Remover', style: TextStyle(color: AppColors.destructive)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == null) return;
      if (!context.mounted) return;

      switch (value) {
        case 'edit':
          _showEditPaymentMethod(context, theme, isDark, method);
          break;
        case 'default':
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${method['brand']} definido como padrao!', style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.success,
            ),
          );
          break;
        case 'remove':
          _showRemovePaymentConfirmation(context, theme, isDark, method);
          break;
      }
    });
  }

  void _showRemovePaymentConfirmation(BuildContext context, ThemeData theme, bool isDark, Map<String, dynamic> method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover Metodo'),
        content: Text(
          'Deseja remover ${method['brand']}${method['last4'] != '' ? ' **** ${method['last4']}' : ''} da sua conta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticUtils.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Metodo de pagamento removido!'),
                  backgroundColor: AppColors.destructive,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MODAL: Add Payment Method (Botao 7)
  // ==========================================================================
  void _showAddPaymentMethod(BuildContext context, ThemeData theme, bool isDark) {
    HapticUtils.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adicionar Forma de Pagamento',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha como deseja pagar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: isDark ? AppColors.borderDark : AppColors.border, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildPaymentOptionCard(
                    context, theme, isDark,
                    LucideIcons.creditCard,
                    'Cartao de Credito',
                    'Visa, Mastercard, Elo, Amex',
                    () {
                      Navigator.pop(context);
                      _showAddCardForm(context, theme, isDark);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentOptionCard(
                    context, theme, isDark,
                    LucideIcons.smartphone,
                    'PIX',
                    'Pagamento instantaneo',
                    () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('PIX cadastrado com sucesso!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentOptionCard(
                    context, theme, isDark,
                    LucideIcons.fileText,
                    'Boleto Bancario',
                    'Em breve',
                    null,
                    disabled: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionCard(BuildContext context, ThemeData theme, bool isDark, IconData icon, String title, String subtitle, VoidCallback? onTap, {bool disabled = false}) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: disabled
              ? (isDark ? AppColors.mutedDark : AppColors.muted).withAlpha(50)
              : (isDark ? AppColors.mutedDark : AppColors.muted),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: disabled
                    ? (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground).withAlpha(25)
                    : (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: disabled
                    ? (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground)
                    : (isDark ? AppColors.primaryDark : AppColors.primary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: disabled ? (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground) : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              disabled ? LucideIcons.lock : LucideIcons.chevronRight,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCardForm(BuildContext context, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.arrowLeft),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Adicionar Cartao',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: isDark ? AppColors.borderDark : AppColors.border, height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormField(theme, isDark, 'Numero do Cartao', '0000 0000 0000 0000', LucideIcons.creditCard),
                    const SizedBox(height: 16),
                    _buildFormField(theme, isDark, 'Nome no Cartao', 'Nome como no cartao', LucideIcons.user),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(theme, isDark, 'Validade', 'MM/AA', LucideIcons.calendar),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFormField(theme, isDark, 'CVV', '000', LucideIcons.lock),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(LucideIcons.shield, size: 16, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Seus dados estao protegidos com criptografia SSL',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    HapticUtils.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Cartao adicionado com sucesso!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Salvar Cartao'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(ThemeData theme, bool isDark, String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: isDark ? AppColors.mutedDark : AppColors.muted,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? AppColors.primaryDark : AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // MODAL: Transaction Details (Botao 8)
  // ==========================================================================
  void _showTransactionDetails(BuildContext context, ThemeData theme, bool isDark, Map<String, dynamic> transaction) {
    HapticUtils.selectionClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Status icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.checkCircle, color: AppColors.success, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pagamento Confirmado',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction['amount'] as String,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: isDark ? AppColors.borderDark : AppColors.border),
                  const SizedBox(height: 16),
                  _buildTransactionDetailRow(theme, isDark, 'Descricao', transaction['description'] as String),
                  _buildTransactionDetailRow(theme, isDark, 'Data', transaction['date'] as String),
                  _buildTransactionDetailRow(theme, isDark, 'ID da Transacao', '#TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}'),
                  _buildTransactionDetailRow(theme, isDark, 'Metodo', 'Visa **** 4242'),
                  _buildTransactionDetailRow(theme, isDark, 'Status', 'Aprovado'),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Recibo enviado para seu email!'),
                                backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.mail, size: 18),
                          label: const Text('Enviar Recibo'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Baixando recibo em PDF...'),
                                backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.download, size: 18),
                          label: const Text('Baixar PDF'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionDetailRow(ThemeData theme, bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MODAL: Plan Details (Botao 9)
  // ==========================================================================
  void _showPlanDetails(BuildContext context, ThemeData theme, bool isDark, Map<String, dynamic> plan) {
    HapticUtils.selectionClick();

    final isRecommended = plan['recommended'] as bool;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isRecommended
                    ? LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isRecommended ? null : (isDark ? AppColors.mutedDark : AppColors.muted),
                borderRadius: BorderRadius.circular(16),
                border: isRecommended ? null : Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isRecommended ? Colors.white.withAlpha(50) : (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isRecommended ? LucideIcons.crown : LucideIcons.package,
                      color: isRecommended ? Colors.white : (isDark ? AppColors.primaryDark : AppColors.primary),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isRecommended)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(50),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'MAIS POPULAR',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Text(
                          'Plano ${plan['name']}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: isRecommended ? Colors.white : null,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              plan['price'] as String,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: isRecommended ? Colors.white : (isDark ? AppColors.primaryDark : AppColors.primary),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              plan['period'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isRecommended ? Colors.white.withAlpha(200) : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Features
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text(
                    'O que esta incluso',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...(plan['features'] as List<String>).map((feature) => _buildFeatureItem(theme, isDark, feature)),
                  const SizedBox(height: 24),
                  Text(
                    'Informacoes do Plano',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPlanInfoRow(theme, isDark, 'Ciclo de Cobranca', 'Mensal'),
                  _buildPlanInfoRow(theme, isDark, 'Renovacao Automatica', 'Sim'),
                  _buildPlanInfoRow(theme, isDark, 'Cancelamento', 'A qualquer momento'),
                  _buildPlanInfoRow(theme, isDark, 'Garantia', '7 dias'),
                ],
              ),
            ),
            // Subscribe button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showSubscribeConfirmation(context, theme, isDark, plan);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isRecommended ? 'Assinar Agora' : 'Escolher Este Plano'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(ThemeData theme, bool isDark, String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.check, size: 14, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanInfoRow(ThemeData theme, bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // DIALOG: Subscribe Confirmation (Botao 10)
  // ==========================================================================
  void _showSubscribeConfirmation(BuildContext context, ThemeData theme, bool isDark, Map<String, dynamic> plan) {
    HapticUtils.mediumImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.sparkles, color: isDark ? AppColors.primaryDark : AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Confirmar Assinatura'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voce esta prestes a assinar o plano ${plan['name']}.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.mutedDark : AppColors.muted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Plano', style: theme.textTheme.bodySmall),
                      Text(plan['name'] as String, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Valor', style: theme.textTheme.bodySmall),
                      Text('${plan['price']}${plan['period']}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pagamento', style: theme.textTheme.bodySmall),
                      Text('Visa **** 4242', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(LucideIcons.shield, size: 16, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Garantia de 7 dias. Cancele quando quiser.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticUtils.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Assinatura do plano ${plan['name']} realizada com sucesso!', style: const TextStyle(color: Colors.white)),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BUILD METHOD
  // ==========================================================================
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(isDark ? 15 : 10),
              (isDark ? AppColors.secondaryDark : AppColors.secondary).withAlpha(isDark ? 12 : 8),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticUtils.lightImpact();
                        context.pop();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(LucideIcons.arrowLeft, size: 20, color: isDark ? AppColors.foregroundDark : AppColors.foreground),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pagamentos',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Botao 1: Help Icon
                    GestureDetector(
                      onTap: () => _showHelpModal(context, theme, isDark),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.cardDark : AppColors.card).withAlpha(isDark ? 150 : 200),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(LucideIcons.helpCircle, size: 20, color: isDark ? AppColors.foregroundDark : AppColors.foreground),
                      ),
                    ),
                  ],
                ),
              ),

              // Active Subscription Card
              FadeInUp(
                child: _buildActiveSubscription(context, theme, isDark),
              ),

              const SizedBox(height: 24),

              // Payment Methods
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: Text(
                  'Formas de Pagamento',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 150),
                child: _buildPaymentMethods(context, theme, isDark),
              ),

              const SizedBox(height: 24),

              // Billing History
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Historico de Pagamentos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 250),
                child: _buildBillingHistory(context, theme, isDark),
              ),

              const SizedBox(height: 24),

              // Available Plans
              FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'Planos Disponiveis',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInUp(
                delay: const Duration(milliseconds: 350),
                child: _buildAvailablePlans(context, theme, isDark),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // Botao 2: Subscription Card - mostrar detalhes
  // Botao 3: Manage Button - gerenciar assinatura
  // Botao 4: Cancel Button - cancelar assinatura
  Widget _buildActiveSubscription(BuildContext context, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () => _showSubscriptionDetails(context, theme, isDark),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -20,
              top: -20,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  LucideIcons.crown,
                  size: 150,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.crown, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'PLANO ATIVO',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Personal Joao',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Plano Mensal de Acompanhamento',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'R\$ 250,00',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '/mes',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Proxima cobranca',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            '15 de Fevereiro',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showManageSubscription(context, theme, isDark),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Gerenciar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showCancelConfirmation(context, theme, isDark),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Botao 5: Payment Method - editar metodo
  // Botao 6: Method Options - menu popup
  // Botao 7: Add Payment - adicionar metodo
  Widget _buildPaymentMethods(BuildContext context, ThemeData theme, bool isDark) {
    final methods = [
      {'type': 'card', 'brand': 'Visa', 'last4': '4242', 'expiry': '12/26', 'isDefault': true},
      {'type': 'card', 'brand': 'Mastercard', 'last4': '8888', 'expiry': '08/25', 'isDefault': false},
      {'type': 'pix', 'brand': 'PIX', 'last4': '', 'expiry': '', 'isDefault': false},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ...methods.map((method) {
            final isLast = methods.indexOf(method) == methods.length - 1;
            return GestureDetector(
              onTap: () => _showEditPaymentMethod(context, theme, isDark, method),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(
                          bottom: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                        ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.mutedDark : AppColors.muted,
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: method['type'] == 'pix'
                            ? Text(
                                'PIX',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              )
                            : Icon(
                                LucideIcons.creditCard,
                                size: 18,
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForeground,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                method['brand'] as String,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (method['last4'] != '') ...[
                                const SizedBox(width: 8),
                                Text(
                                  '•••• ${method['last4']}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? AppColors.mutedForegroundDark
                                        : AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (method['expiry'] != '')
                            Text(
                              'Expira em ${method['expiry']}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.mutedForegroundDark
                                    : AppColors.mutedForeground,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (method['isDefault'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.primaryDark : AppColors.primary).withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Padrao',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTapDown: (details) => _showPaymentMethodOptions(context, theme, isDark, method, details.globalPosition),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.mutedDark : AppColors.muted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.moreVertical,
                          size: 16,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          // Add new method
          GestureDetector(
            onTap: () => _showAddPaymentMethod(context, theme, isDark),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.plus,
                    size: 18,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Adicionar forma de pagamento',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Botao 8: History Item - detalhes da transacao
  Widget _buildBillingHistory(BuildContext context, ThemeData theme, bool isDark) {
    final history = [
      {'date': '15 Jan 2025', 'description': 'Plano Mensal - Personal Joao', 'amount': 'R\$ 250,00', 'status': 'paid'},
      {'date': '15 Dez 2024', 'description': 'Plano Mensal - Personal Joao', 'amount': 'R\$ 250,00', 'status': 'paid'},
      {'date': '15 Nov 2024', 'description': 'Plano Mensal - Personal Joao', 'amount': 'R\$ 250,00', 'status': 'paid'},
      {'date': '01 Nov 2024', 'description': 'Academia FitPro - Mensal', 'amount': 'R\$ 150,00', 'status': 'paid'},
      {'date': '15 Out 2024', 'description': 'Plano Mensal - Personal Joao', 'amount': 'R\$ 250,00', 'status': 'paid'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: history.map((item) {
          final isLast = history.indexOf(item) == history.length - 1;
          return GestureDetector(
            onTap: () => _showTransactionDetails(context, theme, isDark, item),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                      ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.receipt,
                      size: 18,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['description'] as String,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          item['date'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.mutedForegroundDark
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item['amount'] as String,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Pago',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Botao 9: Plan Card - detalhes do plano
  // Botao 10: Plan Subscribe - confirmar assinatura
  Widget _buildAvailablePlans(BuildContext context, ThemeData theme, bool isDark) {
    final plans = [
      {
        'name': 'Basico',
        'price': 'R\$ 99',
        'period': '/mes',
        'features': ['Acesso ao app', 'Treinos basicos', 'Suporte por email'],
        'recommended': false,
      },
      {
        'name': 'Pro',
        'price': 'R\$ 199',
        'period': '/mes',
        'features': ['Tudo do Basico', 'Treinos personalizados', 'Chat com personal', 'Acompanhamento semanal'],
        'recommended': true,
      },
      {
        'name': 'Premium',
        'price': 'R\$ 349',
        'period': '/mes',
        'features': ['Tudo do Pro', 'Plano nutricional', 'Acompanhamento diario', 'Sessoes online'],
        'recommended': false,
      },
    ];

    return Column(
      children: plans.map((plan) {
        final isRecommended = plan['recommended'] as bool;
        return GestureDetector(
          onTap: () => _showPlanDetails(context, theme, isDark, plan),
          child: Container(
            margin: EdgeInsets.only(bottom: plans.indexOf(plan) < plans.length - 1 ? 12 : 0),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardDark.withAlpha(150)
                  : AppColors.card.withAlpha(200),
              border: Border.all(
                color: isRecommended
                    ? (isDark ? AppColors.primaryDark : AppColors.primary)
                    : (isDark ? AppColors.borderDark : AppColors.border),
                width: isRecommended ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                if (isRecommended)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                    child: Text(
                      'MAIS POPULAR',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            plan['name'] as String,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                plan['price'] as String,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isRecommended
                                      ? (isDark ? AppColors.primaryDark : AppColors.primary)
                                      : null,
                                ),
                              ),
                              Text(
                                plan['period'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...(plan['features'] as List<String>).map((feature) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.check,
                                size: 16,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                feature,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _showSubscribeConfirmation(context, theme, isDark, plan),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isRecommended
                                ? (isDark ? AppColors.primaryDark : AppColors.primary)
                                : Colors.transparent,
                            border: isRecommended
                                ? null
                                : Border.all(
                                    color: isDark ? AppColors.borderDark : AppColors.border,
                                  ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              isRecommended ? 'Assinar Agora' : 'Escolher Plano',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isRecommended
                                    ? Colors.white
                                    : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
