// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Payment _$PaymentFromJson(Map<String, dynamic> json) => _Payment(
  id: json['id'] as String,
  studentId: json['studentId'] as String,
  studentName: json['studentName'] as String,
  studentAvatarUrl: json['studentAvatarUrl'] as String?,
  amount: (json['amount'] as num).toDouble(),
  dueDate: DateTime.parse(json['dueDate'] as String),
  paidAt: json['paidAt'] == null
      ? null
      : DateTime.parse(json['paidAt'] as String),
  status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
  paymentMethod: $enumDecodeNullable(
    _$PaymentMethodEnumMap,
    json['paymentMethod'],
  ),
  description: json['description'] as String?,
  receiptUrl: json['receiptUrl'] as String?,
  daysOverdue: (json['daysOverdue'] as num?)?.toInt(),
);

Map<String, dynamic> _$PaymentToJson(_Payment instance) => <String, dynamic>{
  'id': instance.id,
  'studentId': instance.studentId,
  'studentName': instance.studentName,
  'studentAvatarUrl': instance.studentAvatarUrl,
  'amount': instance.amount,
  'dueDate': instance.dueDate.toIso8601String(),
  'paidAt': instance.paidAt?.toIso8601String(),
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod],
  'description': instance.description,
  'receiptUrl': instance.receiptUrl,
  'daysOverdue': instance.daysOverdue,
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.paid: 'paid',
  PaymentStatus.overdue: 'overdue',
  PaymentStatus.cancelled: 'cancelled',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.pix: 'pix',
  PaymentMethod.creditCard: 'creditCard',
  PaymentMethod.bankTransfer: 'bankTransfer',
  PaymentMethod.cash: 'cash',
};

_BillingSummary _$BillingSummaryFromJson(Map<String, dynamic> json) =>
    _BillingSummary(
      totalExpected: (json['totalExpected'] as num).toDouble(),
      totalReceived: (json['totalReceived'] as num).toDouble(),
      totalPending: (json['totalPending'] as num).toDouble(),
      paidCount: (json['paidCount'] as num).toInt(),
      pendingCount: (json['pendingCount'] as num).toInt(),
      overdueCount: (json['overdueCount'] as num).toInt(),
      receivedPercentage: (json['receivedPercentage'] as num).toDouble(),
    );

Map<String, dynamic> _$BillingSummaryToJson(_BillingSummary instance) =>
    <String, dynamic>{
      'totalExpected': instance.totalExpected,
      'totalReceived': instance.totalReceived,
      'totalPending': instance.totalPending,
      'paidCount': instance.paidCount,
      'pendingCount': instance.pendingCount,
      'overdueCount': instance.overdueCount,
      'receivedPercentage': instance.receivedPercentage,
    };

_PaymentReminder _$PaymentReminderFromJson(Map<String, dynamic> json) =>
    _PaymentReminder(
      id: json['id'] as String,
      paymentId: json['paymentId'] as String,
      studentId: json['studentId'] as String,
      message: json['message'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      channel: json['channel'] as String,
      delivered: json['delivered'] as bool?,
      read: json['read'] as bool?,
    );

Map<String, dynamic> _$PaymentReminderToJson(_PaymentReminder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'paymentId': instance.paymentId,
      'studentId': instance.studentId,
      'message': instance.message,
      'sentAt': instance.sentAt.toIso8601String(),
      'channel': instance.channel,
      'delivered': instance.delivered,
      'read': instance.read,
    };
