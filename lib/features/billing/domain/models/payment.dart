import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

enum PaymentStatus {
  pending,
  paid,
  overdue,
  cancelled,
}

enum PaymentMethod {
  pix,
  creditCard,
  bankTransfer,
  cash,
}

@freezed
sealed class Payment with _$Payment {
  const Payment._();

  const factory Payment({
    required String id,
    required String studentId,
    required String studentName,
    String? studentAvatarUrl,
    required double amount,
    required DateTime dueDate,
    DateTime? paidAt,
    required PaymentStatus status,
    PaymentMethod? paymentMethod,
    String? description,
    String? receiptUrl,
    int? daysOverdue,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
}

@freezed
sealed class BillingSummary with _$BillingSummary {
  const BillingSummary._();

  const factory BillingSummary({
    required double totalExpected,
    required double totalReceived,
    required double totalPending,
    required int paidCount,
    required int pendingCount,
    required int overdueCount,
    required double receivedPercentage,
  }) = _BillingSummary;

  factory BillingSummary.fromJson(Map<String, dynamic> json) => _$BillingSummaryFromJson(json);
}

@freezed
sealed class PaymentReminder with _$PaymentReminder {
  const PaymentReminder._();

  const factory PaymentReminder({
    required String id,
    required String paymentId,
    required String studentId,
    required String message,
    required DateTime sentAt,
    required String channel, // whatsapp, email, push
    bool? delivered,
    bool? read,
  }) = _PaymentReminder;

  factory PaymentReminder.fromJson(Map<String, dynamic> json) => _$PaymentReminderFromJson(json);
}
