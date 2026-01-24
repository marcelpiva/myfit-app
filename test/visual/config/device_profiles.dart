/// Device profiles for multi-device visual testing.
///
/// These profiles simulate common devices for golden tests
/// to ensure UI works correctly across different screen sizes.
library;

import 'package:flutter/material.dart';

/// Device configuration for visual testing.
class DeviceConfig {
  const DeviceConfig({
    required this.name,
    required this.size,
    this.devicePixelRatio = 2.0,
  });

  final String name;
  final Size size;
  final double devicePixelRatio;

  /// Create a safe filename from the device name
  String get safeFileName => name.toLowerCase().replaceAll(' ', '_');
}

/// Common device profiles for visual testing.
class DeviceProfiles {
  DeviceProfiles._();

  // ==========================================================================
  // iOS Devices
  // ==========================================================================

  /// iPhone 14 Pro - Modern iPhone with notch
  static const iPhone14Pro = DeviceConfig(
    name: 'iPhone 14 Pro',
    size: Size(393, 852),
    devicePixelRatio: 3.0,
  );

  /// iPhone SE (3rd gen) - Compact iPhone
  static const iPhoneSE = DeviceConfig(
    name: 'iPhone SE',
    size: Size(375, 667),
    devicePixelRatio: 2.0,
  );

  /// iPhone 15 Pro Max - Large iPhone
  static const iPhone15ProMax = DeviceConfig(
    name: 'iPhone 15 Pro Max',
    size: Size(430, 932),
    devicePixelRatio: 3.0,
  );

  /// iPad Pro 11" - Tablet
  static const iPadPro11 = DeviceConfig(
    name: 'iPad Pro 11',
    size: Size(834, 1194),
    devicePixelRatio: 2.0,
  );

  // ==========================================================================
  // Android Devices
  // ==========================================================================

  /// Pixel 7 - Modern Android phone
  static const pixel7 = DeviceConfig(
    name: 'Pixel 7',
    size: Size(412, 915),
    devicePixelRatio: 2.625,
  );

  /// Pixel 7a - Mid-range Android phone
  static const pixel7a = DeviceConfig(
    name: 'Pixel 7a',
    size: Size(412, 892),
    devicePixelRatio: 2.625,
  );

  /// Samsung Galaxy S23 - Popular Android flagship
  static const galaxyS23 = DeviceConfig(
    name: 'Galaxy S23',
    size: Size(360, 780),
    devicePixelRatio: 3.0,
  );

  /// Small Android phone (budget device)
  static const smallAndroid = DeviceConfig(
    name: 'Small Android',
    size: Size(320, 568),
    devicePixelRatio: 2.0,
  );

  // ==========================================================================
  // Device Groups
  // ==========================================================================

  /// Standard device set for most tests (phones only)
  static const List<DeviceConfig> phones = [
    iPhone14Pro,
    iPhoneSE,
    pixel7,
    galaxyS23,
  ];

  /// Comprehensive device set including tablets
  static const List<DeviceConfig> all = [
    iPhone14Pro,
    iPhoneSE,
    iPhone15ProMax,
    iPadPro11,
    pixel7,
    pixel7a,
    galaxyS23,
    smallAndroid,
  ];

  /// Critical devices for quick testing
  static const List<DeviceConfig> critical = [
    iPhone14Pro,
    pixel7,
  ];

  /// Tablet devices only
  static const List<DeviceConfig> tablets = [
    iPadPro11,
  ];

  /// Compact devices for testing small screens
  static const List<DeviceConfig> compact = [
    iPhoneSE,
    smallAndroid,
  ];
}
