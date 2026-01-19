import 'package:flutter/material.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/domain/entities/user_role.dart';
import '../../../../shared/presentation/components/animations/fade_in_up.dart';
import '../../../../shared/presentation/components/role_bottom_navigation.dart';
import '../../domain/models/payment.dart';
import '../providers/billing_provider.dart';
import '../widgets/billing_summary_card.dart';
import '../widgets/payment_tile.dart';

class BillingDashboardPage extends ConsumerWidget {
  const BillingDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final summaryAsync = ref.watch(billingSummaryProvider);
    final paymentsAsync = ref.watch(paymentsProvider);
    final overduePayments = ref.watch(overduePaymentsProvider);
    final upcomingPayments = ref.watch(upcomingDuePaymentsProvider);
    final statusFilter = ref.watch(billingStatusFilterProvider);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      bottomNavigationBar: const RoleBottomNavigation(
        role: UserRole.gymOwner,
        currentIndex: 3, // Financeiro tab
      ),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
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
        ),
        title: const Text('Cobrancas'),
        actions: [
          IconButton(
            onPressed: () {
              HapticUtils.lightImpact();
              _showMonthPicker(context, ref);
            },
            icon: const Icon(LucideIcons.calendar),
            tooltip: 'Selecionar mes',
          ),
        ],
      ),
      body: Container(
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
        child: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.alertCircle, size: 48, color: AppColors.destructive),
                const SizedBox(height: 16),
                Text('Erro ao carregar dados', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(billingSummaryProvider),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
          data: (summary) => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary card
                FadeInUp(
                  child: BillingSummaryCard(summary: summary),
                ),

                const SizedBox(height: 24),

                // Alerts section
                if (overduePayments.isNotEmpty || upcomingPayments.isNotEmpty) ...[
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _AlertsSection(
                      overduePayments: overduePayments,
                      upcomingPayments: upcomingPayments,
                      isDark: isDark,
                      currencyFormat: currencyFormat,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Filter tabs
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDark.withAlpha(150)
                          : AppColors.card.withAlpha(200),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _FilterTab(
                          label: 'Todos',
                          count: null,
                          isSelected: statusFilter == null,
                          onTap: () {
                            HapticUtils.selectionClick();
                            ref.read(billingStatusFilterProvider.notifier).state = null;
                          },
                          isDark: isDark,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        _FilterTab(
                          label: 'Pagos',
                          count: summary.paidCount,
                          isSelected: statusFilter == PaymentStatus.paid,
                          onTap: () {
                            HapticUtils.selectionClick();
                            ref.read(billingStatusFilterProvider.notifier).state = PaymentStatus.paid;
                          },
                          isDark: isDark,
                          color: AppColors.success,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        _FilterTab(
                          label: 'Pendentes',
                          count: summary.pendingCount,
                          isSelected: statusFilter == PaymentStatus.pending,
                          onTap: () {
                            HapticUtils.selectionClick();
                            ref.read(billingStatusFilterProvider.notifier).state = PaymentStatus.pending;
                          },
                          isDark: isDark,
                          color: AppColors.warning,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        _FilterTab(
                          label: 'Atrasados',
                          count: summary.overdueCount,
                          isSelected: statusFilter == PaymentStatus.overdue,
                          onTap: () {
                            HapticUtils.selectionClick();
                            ref.read(billingStatusFilterProvider.notifier).state = PaymentStatus.overdue;
                          },
                          isDark: isDark,
                          color: AppColors.destructive,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Payments list
                paymentsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Erro ao carregar pagamentos'),
                  data: (payments) => Column(
                    children: [
                      ...payments.asMap().entries.map((entry) {
                        return FadeInUp(
                          delay: Duration(milliseconds: 250 + (entry.key * 50)),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: PaymentTile(payment: entry.value),
                          ),
                        );
                      }),

                      if (payments.isEmpty)
                        FadeInUp(
                          delay: const Duration(milliseconds: 250),
                          child: Container(
                            padding: const EdgeInsets.all(32),
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
                                Icon(
                                  LucideIcons.receipt,
                                  size: 48,
                                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhuma cobrança encontrada',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Não há cobranças com este filtro',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMonthPicker(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMonth = ref.read(billingMonthProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecionar mes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(6, (index) {
                final month = DateTime(DateTime.now().year, DateTime.now().month - index, 1);
                final isSelected = month.year == currentMonth.year && month.month == currentMonth.month;

                return GestureDetector(
                  onTap: () {
                    HapticUtils.selectionClick();
                    ref.read(billingMonthProvider.notifier).state = month;
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat('MMMM yyyy', 'pt_BR').format(month),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? (isDark ? AppColors.primaryDark : AppColors.primary)
                                  : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            LucideIcons.check,
                            size: 20,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertsSection extends StatelessWidget {
  final List<Payment> overduePayments;
  final List<Payment> upcomingPayments;
  final bool isDark;
  final NumberFormat currencyFormat;

  const _AlertsSection({
    required this.overduePayments,
    required this.upcomingPayments,
    required this.isDark,
    required this.currencyFormat,
  });

  void _showOverduePaymentsModal(BuildContext context) {
    HapticUtils.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Row(
                children: [
                  Icon(
                    LucideIcons.alertTriangle,
                    color: AppColors.destructive,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Pagamentos Atrasados',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${currencyFormat.format(overduePayments.fold<double>(0, (sum, p) => sum + p.amount))}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 20),
              // Payments list
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: overduePayments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final payment = overduePayments[index];
                    return _OverduePaymentItem(
                      payment: payment,
                      isDark: isDark,
                      currencyFormat: currencyFormat,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.mediumImpact();
                        Navigator.pop(context);
                        final names = overduePayments.map((p) => p.studentName.split(' ').first).take(3).join(', ');
                        final suffix = overduePayments.length > 3 ? ' e mais ${overduePayments.length - 3}' : '';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lembrete enviado para $names$suffix!', style: const TextStyle(color: Colors.white)),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.destructive,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.bell, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Enviar Lembrete a Todos',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }

  void _showUpcomingPaymentsModal(BuildContext context) {
    HapticUtils.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Row(
                children: [
                  Icon(
                    LucideIcons.calendarClock,
                    color: AppColors.warning,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Pagamentos Próximos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${currencyFormat.format(upcomingPayments.fold<double>(0, (sum, p) => sum + p.amount))}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 20),
              // Payments list
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: upcomingPayments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final payment = upcomingPayments[index];
                    return _UpcomingPaymentItem(
                      payment: payment,
                      isDark: isDark,
                      currencyFormat: currencyFormat,
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtils.mediumImpact();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Lembretes agendados para todos!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.clock, size: 18, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Agendar Lembrete a Todos',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }

  void _sendOverdueReminder(BuildContext context) {
    HapticUtils.lightImpact();
    final names = overduePayments.map((p) => p.studentName.split(' ').first).take(3).join(', ');
    final suffix = overduePayments.length > 3 ? ' e mais ${overduePayments.length - 3}' : '';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lembrete enviado para $names$suffix!', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scheduleUpcomingReminder(BuildContext context) {
    HapticUtils.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lembrete agendado!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações sugeridas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        if (overduePayments.isNotEmpty)
          GestureDetector(
            onTap: () => _showOverduePaymentsModal(context),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.destructive.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.destructive.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.alertTriangle,
                    color: AppColors.destructive,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${overduePayments.length} aluno${overduePayments.length > 1 ? 's' : ''} com pagamento atrasado',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: ${currencyFormat.format(overduePayments.fold<double>(0, (sum, p) => sum + p.amount))}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _sendOverdueReminder(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.destructive,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Lembrar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (upcomingPayments.isNotEmpty)
          GestureDetector(
            onTap: () => _showUpcomingPaymentsModal(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.calendarClock,
                    color: AppColors.warning,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${upcomingPayments.length} cobrança${upcomingPayments.length > 1 ? 's' : ''} vence${upcomingPayments.length > 1 ? 'm' : ''} em 3 dias',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: ${currencyFormat.format(upcomingPayments.fold<double>(0, (sum, p) => sum + p.amount))}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: GestureDetector(
                      onTap: () => _scheduleUpcomingReminder(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Lembrar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _OverduePaymentItem extends StatelessWidget {
  final Payment payment;
  final bool isDark;
  final NumberFormat currencyFormat;

  const _OverduePaymentItem({
    required this.payment,
    required this.isDark,
    required this.currencyFormat,
  });

  String _getPaymentMethodLabel(PaymentMethod? method) {
    switch (method) {
      case PaymentMethod.pix:
        return 'PIX';
      case PaymentMethod.creditCard:
        return 'Cartão';
      case PaymentMethod.bankTransfer:
        return 'Transferência';
      case PaymentMethod.cash:
        return 'Dinheiro';
      default:
        return 'Não definido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final daysOverdue = payment.daysOverdue ?? DateTime.now().difference(payment.dueDate).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: AppColors.destructive.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  payment.studentName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ),
              Text(
                currencyFormat.format(payment.amount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.destructive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Due date and days overdue
          Row(
            children: [
              Icon(
                LucideIcons.calendar,
                size: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              const SizedBox(width: 6),
              Text(
                'Venceu em ${dateFormat.format(payment.dueDate)}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.destructive.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$daysOverdue dias atrasado',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.destructive,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticUtils.lightImpact();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lembrete enviado para ${payment.studentName}!', style: const TextStyle(color: Colors.white)),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDark
                          : AppColors.card,
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.bell,
                          size: 16,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Enviar Lembrete',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticUtils.mediumImpact();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pagamento de ${payment.studentName} marcado como pago!', style: const TextStyle(color: Colors.white)),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Marcar Pago',
                          style: TextStyle(
                            fontSize: 12,
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
          const SizedBox(height: 8),
          // Payment options
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticUtils.lightImpact();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Link PIX copiado!'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF32BCAD).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.qrCode,
                          size: 16,
                          color: Color(0xFF32BCAD),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'PIX',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF32BCAD),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticUtils.lightImpact();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Link de pagamento por cartão enviado!'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.creditCard,
                          size: 16,
                          color: isDark ? AppColors.primaryDark : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Cartão',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
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

class _UpcomingPaymentItem extends StatelessWidget {
  final Payment payment;
  final bool isDark;
  final NumberFormat currencyFormat;

  const _UpcomingPaymentItem({
    required this.payment,
    required this.isDark,
    required this.currencyFormat,
  });

  String _getPaymentMethodLabel(PaymentMethod? method) {
    switch (method) {
      case PaymentMethod.pix:
        return 'PIX';
      case PaymentMethod.creditCard:
        return 'Cartão';
      case PaymentMethod.bankTransfer:
        return 'Transferência';
      case PaymentMethod.cash:
        return 'Dinheiro';
      default:
        return 'Não definido';
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod? method) {
    switch (method) {
      case PaymentMethod.pix:
        return LucideIcons.qrCode;
      case PaymentMethod.creditCard:
        return LucideIcons.creditCard;
      case PaymentMethod.bankTransfer:
        return LucideIcons.building;
      case PaymentMethod.cash:
        return LucideIcons.banknote;
      default:
        return LucideIcons.helpCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final daysUntilDue = payment.dueDate.difference(DateTime.now()).inDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withAlpha(150)
            : AppColors.card.withAlpha(200),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  payment.studentName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                  ),
                ),
              ),
              Text(
                currencyFormat.format(payment.amount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Due date and payment method
          Row(
            children: [
              Icon(
                LucideIcons.calendar,
                size: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              const SizedBox(width: 6),
              Text(
                'Vence em ${dateFormat.format(payment.dueDate)}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  daysUntilDue == 0 ? 'Hoje' : '$daysUntilDue dias',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Payment method
          Row(
            children: [
              Icon(
                _getPaymentMethodIcon(payment.paymentMethod),
                size: 14,
                color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
              ),
              const SizedBox(width: 6),
              Text(
                'Método: ${_getPaymentMethodLabel(payment.paymentMethod)}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticUtils.lightImpact();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lembrete agendado para ${payment.studentName}!', style: const TextStyle(color: Colors.white)),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Agendar Lembrete',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticUtils.lightImpact();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Abrindo conversa com ${payment.studentName}...', style: const TextStyle(color: Colors.white)),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDark
                          : AppColors.card,
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.messageCircle,
                          size: 16,
                          color: isDark ? AppColors.foregroundDark : AppColors.foreground,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Contatar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.foregroundDark : AppColors.foreground,
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

class _FilterTab extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color? color;

  const _FilterTab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: isSelected
            ? (color ?? (isDark ? AppColors.primaryDark : AppColors.primary)).withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? (color ?? (isDark ? AppColors.primaryDark : AppColors.primary))
                        : (isDark ? AppColors.foregroundDark : AppColors.foreground),
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? (color ?? (isDark ? AppColors.primaryDark : AppColors.primary))
                          : (isDark ? AppColors.mutedForegroundDark : AppColors.mutedForeground),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
