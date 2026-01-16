import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../services/biometric_service.dart';

/// Provider for BiometricService instance
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// Provider to check if biometrics are available on device
final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(biometricServiceProvider);
  return service.isBiometricAvailable();
});

/// Provider to check if biometric login is enabled in app
final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(biometricServiceProvider);
  return service.isBiometricEnabled();
});

/// Provider for available biometric types
final biometricTypesProvider = FutureProvider<List<BiometricType>>((ref) async {
  final service = ref.read(biometricServiceProvider);
  return service.getAvailableBiometrics();
});

/// Provider for biometric label (Face ID, Touch ID, etc.)
final biometricLabelProvider = FutureProvider<String>((ref) async {
  final service = ref.read(biometricServiceProvider);
  final types = await service.getAvailableBiometrics();
  return service.getBiometricLabel(types);
});
