import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/billing_service.dart';
import '../../domain/models/payment.dart';

/// Provider for BillingService
final billingServiceProvider = Provider<BillingService>((ref) {
  return BillingService();
});

// Current month filter
final billingMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

// Status filter
final billingStatusFilterProvider = StateProvider<PaymentStatus?>((ref) => null);

// Payments list (async from API)
final paymentsProvider = FutureProvider<List<Payment>>((ref) async {
  final service = ref.read(billingServiceProvider);
  final filter = ref.watch(billingStatusFilterProvider);
  return service.getPayments(status: filter);
});

// Billing summary (async from API)
final billingSummaryProvider = FutureProvider<BillingSummary>((ref) async {
  final service = ref.read(billingServiceProvider);
  return service.getSummary();
});

// Overdue payments (derived from payments)
final overduePaymentsProvider = Provider<List<Payment>>((ref) {
  final paymentsAsync = ref.watch(paymentsProvider);
  return paymentsAsync.when(
    data: (payments) => payments.where((p) => p.status == PaymentStatus.overdue).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Upcoming due payments (next 3 days)
final upcomingDuePaymentsProvider = Provider<List<Payment>>((ref) {
  final paymentsAsync = ref.watch(paymentsProvider);
  final now = DateTime.now();
  final threeDaysLater = now.add(const Duration(days: 3));

  return paymentsAsync.when(
    data: (payments) => payments.where((p) {
      return p.status == PaymentStatus.pending &&
          p.dueDate.isAfter(now) &&
          p.dueDate.isBefore(threeDaysLater);
    }).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Payment actions
final paymentActionsProvider = Provider((ref) => PaymentActions(ref));

class PaymentActions {
  final Ref _ref;

  PaymentActions(this._ref);

  Future<void> sendReminder(String paymentId, String channel) async {
    final service = _ref.read(billingServiceProvider);
    await service.sendReminder(paymentId, channel);
  }

  Future<void> sendBulkReminders(List<String> paymentIds, String channel) async {
    final service = _ref.read(billingServiceProvider);
    for (final id in paymentIds) {
      await service.sendReminder(id, channel);
    }
  }

  Future<Payment> markAsPaid(String paymentId, PaymentMethod method) async {
    final service = _ref.read(billingServiceProvider);
    final payment = await service.markAsPaid(paymentId, method);
    // Invalidate cache to reload payments
    _ref.invalidate(paymentsProvider);
    return payment;
  }

  Future<void> generateReceipt(String paymentId) async {
    // TODO: Implement receipt generation
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
