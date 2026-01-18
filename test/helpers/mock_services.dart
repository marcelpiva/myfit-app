import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myfit_app/core/network/api_client.dart';
import 'package:myfit_app/core/services/organization_service.dart';
import 'package:myfit_app/core/services/trainer_service.dart';
import 'package:myfit_app/core/services/workout_service.dart';

/// Mock for ApiClient
class MockApiClient extends Mock implements ApiClient {}

/// Mock for TrainerService
class MockTrainerService extends Mock implements TrainerService {}

/// Mock for WorkoutService
class MockWorkoutService extends Mock implements WorkoutService {}

/// Mock for OrganizationService
class MockOrganizationService extends Mock implements OrganizationService {}

/// Register fallback values for common types used in mocks
void registerFallbackValues() {
  registerFallbackValue(DateTime.now());
  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(<Map<String, dynamic>>[]);
  registerFallbackValue(Options());
}

/// Creates a successful Dio Response
Response<T> createResponse<T>({
  required T data,
  int statusCode = 200,
  String? statusMessage,
  RequestOptions? requestOptions,
}) {
  return Response<T>(
    data: data,
    statusCode: statusCode,
    statusMessage: statusMessage ?? 'OK',
    requestOptions: requestOptions ?? RequestOptions(path: '/test'),
  );
}

/// Creates a DioException for testing error handling
DioException createDioException({
  DioExceptionType type = DioExceptionType.badResponse,
  int? statusCode,
  String? message,
  dynamic error,
  RequestOptions? requestOptions,
}) {
  return DioException(
    type: type,
    message: message,
    error: error,
    requestOptions: requestOptions ?? RequestOptions(path: '/test'),
    response: statusCode != null
        ? Response(
            statusCode: statusCode,
            requestOptions: requestOptions ?? RequestOptions(path: '/test'),
          )
        : null,
  );
}
