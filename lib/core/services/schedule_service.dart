import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../error/api_exceptions.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

/// Service for managing trainer schedule and appointments
class ScheduleService {
  final ApiClient _client;

  ScheduleService({ApiClient? client}) : _client = client ?? ApiClient.instance;

  /// Get appointments for a specific day
  Future<List<Map<String, dynamic>>> getAppointmentsForDay(DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await _client.get(ApiEndpoints.scheduleDay(dateStr));
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar agenda', e);
    }
  }

  /// Get appointments for a week starting from date
  Future<Map<String, List<Map<String, dynamic>>>> getAppointmentsForWeek(DateTime startDate) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(startDate);
      final response = await _client.get(ApiEndpoints.scheduleWeek(dateStr));
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        return data.map((key, value) => MapEntry(
          key,
          (value as List).cast<Map<String, dynamic>>(),
        ));
      }
      return {};
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar agenda semanal', e);
    }
  }

  /// Create new appointment
  Future<Map<String, dynamic>> createAppointment({
    required String studentId,
    required DateTime dateTime,
    required int durationMinutes,
    String? workoutType,
    String? notes,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.scheduleAppointments,
        data: {
          'student_id': studentId,
          'date_time': dateTime.toIso8601String(),
          'duration_minutes': durationMinutes,
          if (workoutType != null) 'workout_type': workoutType,
          if (notes != null) 'notes': notes,
        },
      );
      if (response.statusCode == 201 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao criar agendamento');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao criar agendamento', e);
    }
  }

  /// Update appointment
  Future<Map<String, dynamic>> updateAppointment(
    String appointmentId, {
    DateTime? dateTime,
    int? durationMinutes,
    String? workoutType,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (dateTime != null) data['date_time'] = dateTime.toIso8601String();
      if (durationMinutes != null) data['duration_minutes'] = durationMinutes;
      if (workoutType != null) data['workout_type'] = workoutType;
      if (notes != null) data['notes'] = notes;

      final response = await _client.put(
        ApiEndpoints.scheduleAppointment(appointmentId),
        data: data,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      throw const ServerException('Erro ao atualizar agendamento');
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao atualizar agendamento', e);
    }
  }

  /// Cancel appointment
  Future<void> cancelAppointment(String appointmentId, {String? reason}) async {
    try {
      await _client.post(
        ApiEndpoints.scheduleAppointmentCancel(appointmentId),
        data: reason != null ? {'reason': reason} : null,
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao cancelar agendamento', e);
    }
  }

  /// Confirm appointment
  Future<void> confirmAppointment(String appointmentId) async {
    try {
      await _client.post(ApiEndpoints.scheduleAppointmentConfirm(appointmentId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao confirmar agendamento', e);
    }
  }

  /// Delete appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _client.delete(ApiEndpoints.scheduleAppointment(appointmentId));
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao excluir agendamento', e);
    }
  }

  /// Get student's own appointments (for students)
  Future<List<Map<String, dynamic>>> getMyAppointments({
    String? status,
    DateTime? fromDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (fromDate != null) {
        queryParams['from_date'] = DateFormat('yyyy-MM-dd').format(fromDate);
      }

      final response = await _client.get(
        ApiEndpoints.myAppointments,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response.statusCode == 200 && response.data != null) {
        return (response.data as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao carregar sessões', e);
    }
  }

  /// Request reschedule for an appointment (for students)
  Future<void> requestReschedule(
    String appointmentId, {
    DateTime? preferredDateTime,
    String? reason,
  }) async {
    try {
      await _client.post(
        ApiEndpoints.scheduleAppointmentReschedule(appointmentId),
        data: {
          if (preferredDateTime != null) 'preferred_date_time': preferredDateTime.toIso8601String(),
          if (reason != null) 'reason': reason,
        },
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : UnknownApiException(e.message ?? 'Erro ao solicitar reagendamento', e);
    }
  }
}
