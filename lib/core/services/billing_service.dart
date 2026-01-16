import 'package:dio/dio.dart';

import '../../features/billing/domain/models/payment.dart';
import '../error/api_exceptions.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Service for billing and payment management
class BillingService {
  final ApiClient _client;

  BillingService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  /// Get all payments for the organization
  Future<List<Payment>> getPayments({PaymentStatus? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status.name;
      }

      final response = await _client.get(
        ApiEndpoints.billingPayments,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as List;
        return data.map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar pagamentos', e);
    }
  }

  /// Get billing summary
  Future<BillingSummary> getSummary() async {
    try {
      final response = await _client.get(ApiEndpoints.billingSummary);
      if (response.statusCode == 200 && response.data != null) {
        return BillingSummary.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerException('Erro ao carregar resumo de cobranças');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar resumo', e);
    }
  }

  /// Send payment reminder
  Future<void> sendReminder(String paymentId, String channel) async {
    try {
      final response = await _client.post(
        '${ApiEndpoints.billingPayment(paymentId)}/reminder',
        data: {'channel': channel},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw const ServerException('Erro ao enviar lembrete');
      }
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao enviar lembrete', e);
    }
  }

  /// Mark payment as paid
  Future<Payment> markAsPaid(String paymentId, PaymentMethod method) async {
    try {
      final response = await _client.post(
        '${ApiEndpoints.billingPayment(paymentId)}/mark-paid',
        data: {'payment_method': method.name},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Payment.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerException('Erro ao marcar como pago');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao marcar como pago', e);
    }
  }
}
