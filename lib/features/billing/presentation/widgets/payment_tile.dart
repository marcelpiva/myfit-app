import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../domain/models/payment.dart';
import '../providers/billing_provider.dart';

class PaymentTile extends ConsumerWidget {
  final Payment payment;

  const PaymentTile({
    super.key,
    required this.payment,
  });

  Color _getStatusColor() {
    switch (payment.status) {
      case PaymentStatus.paid:
        return AppColors.success;
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.overdue:
        return AppColors.destructive;
      case PaymentStatus.cancelled:
        return AppColors.mutedForeground;
    }
  }

  IconData _getStatusIcon() {
    switch (payment.status) {
      case PaymentStatus.paid:
        return LucideIcons.checkCircle;
      case PaymentStatus.pending:
        return LucideIcons.clock;
      case PaymentStatus.overdue:
        return LucideIcons.alertCircle;
      case PaymentStatus.cancelled:
        return LucideIcons.xCircle;
    }
  }

  String _getStatusLabel() {
    switch (payment.status) {
      case PaymentStatus.paid:
        return 'Pago';
      case PaymentStatus.pending:
        return 'Pendente';
      case PaymentStatus.overdue:
        return 'Atrasado';
      case PaymentStatus.cancelled:
        return 'Cancelado';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM');
    final statusColor = _getStatusColor();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPaymentDetails(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.mutedDark : AppColors.muted,
                    shape: BoxShape.circle,
                  ),
                  child: payment.studentAvatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            payment.studentAvatarUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            payment.studentName.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                            ),
                          ),
                        ),
                ),

                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.studentName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getStatusIcon(),
                            size: 12,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getStatusLabel(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            payment.status == PaymentStatus.paid && payment.paidAt != null
                                ? 'Pago em ${dateFormat.format(payment.paidAt!)}'
                                : 'Venc. ${dateFormat.format(payment.dueDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                            ),
                          ),
                          if (payment.daysOverdue != null && payment.daysOverdue! > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.destructive.withValues(alpha: 0.1),
                              ),
                              child: Text(
                                '${payment.daysOverdue}d atraso',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.destructive,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Amount
                Text(
                  currencyFormat.format(payment.amount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentDetails(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final statusColor = _getStatusColor();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.mutedDark : AppColors.muted,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        payment.studentName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.studentName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                          ),
                          child: Text(
                            _getStatusLabel().toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currencyFormat.format(payment.amount),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Details
              _DetailRow(
                icon: LucideIcons.calendarDays,
                label: 'Vencimento',
                value: dateFormat.format(payment.dueDate),
                isDark: isDark,
              ),
              if (payment.paidAt != null)
                _DetailRow(
                  icon: LucideIcons.checkCircle,
                  label: 'Pago em',
                  value: dateFormat.format(payment.paidAt!),
                  isDark: isDark,
                  valueColor: AppColors.success,
                ),
              if (payment.paymentMethod != null)
                _DetailRow(
                  icon: LucideIcons.creditCard,
                  label: 'Método',
                  value: _getPaymentMethodLabel(payment.paymentMethod!),
                  isDark: isDark,
                ),
              if (payment.description != null)
                _DetailRow(
                  icon: LucideIcons.fileText,
                  label: 'Descrição',
                  value: payment.description!,
                  isDark: isDark,
                ),

              const SizedBox(height: 24),

              // Actions
              if (payment.status != PaymentStatus.paid) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _sendReminder(context, ref);
                        },
                        icon: const Icon(LucideIcons.send, size: 18),
                        label: const Text('Enviar lembrete'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _markAsPaid(context, ref);
                        },
                        icon: const Icon(LucideIcons.check, size: 18),
                        label: const Text('Marcar pago'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _generateReceipt(context, ref);
                    },
                    icon: const Icon(LucideIcons.receipt, size: 18),
                    label: const Text('Gerar comprovante'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getPaymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.pix:
        return 'PIX';
      case PaymentMethod.creditCard:
        return 'Cartão de Crédito';
      case PaymentMethod.bankTransfer:
        return 'Transferência';
      case PaymentMethod.cash:
        return 'Dinheiro';
    }
  }

  void _sendReminder(BuildContext context, WidgetRef ref) async {
    await ref.read(paymentActionsProvider).sendReminder(payment.id, 'whatsapp');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lembrete enviado para ${payment.studentName}', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _markAsPaid(BuildContext context, WidgetRef ref) async {
    await ref.read(paymentActionsProvider).markAsPaid(payment.id, PaymentMethod.pix);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pagamento de ${payment.studentName} marcado como pago', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _generateReceipt(BuildContext context, WidgetRef ref) async {
    await ref.read(paymentActionsProvider).generateReceipt(payment.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comprovante gerado', style: const TextStyle(color: Colors.white)),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? (isDark ? AppColors.foregroundDark : AppColors.foreground),
            ),
          ),
        ],
      ),
    );
  }
}
