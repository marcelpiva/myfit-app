# MyFit App

[![Version](https://img.shields.io/badge/version-1.4.0-blue.svg)](./CHANGELOG.md)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B.svg?logo=flutter)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20Android%20%7C%20Web-lightgrey.svg)](https://flutter.dev/multi-platform)
[![Tests](https://img.shields.io/badge/tests-150+-green.svg)]()

Aplicativo Flutter multiplataforma para a plataforma MyFit.

## Features

- User authentication with biometrics (iOS/Android)
- Workout plan management
- **Advanced Training Techniques** - Bi-Set, Tri-Set, Giant Set, Drop Set, Rest-Pause, Cluster
- **Exercise Group Management** - Create, edit, reorder, and manage exercise groups
- Nutrition tracking
- Progress photos and measurements
- Real-time chat
- Check-in via QR Code (iOS/Android)
- Gamification system
- **PWA Support** - Installable web app
- **Multi-language Support** - Portuguese (pt-BR), Spanish (es), English (en)

## Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| iOS | ✅ | Full features |
| Android | ✅ | Full features |
| Web (PWA) | ✅ | Some features unavailable* |

*Web limitations: biometric auth, QR/barcode scanner, haptic feedback

## Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Navigation**: go_router
- **Forms**: reactive_forms
- **Network**: Dio
- **Storage**: shared_preferences

## Getting Started

### Prerequisites

- Flutter SDK 3.10+
- Dart 3.x
- iOS 12+ / Android 5.0+ / Modern browsers (Chrome, Safari, Edge)

### Installation

```bash
# Install dependencies
flutter pub get

# Generate code (Riverpod, Freezed, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Environment

Create a `.env` file in the root:

```env
API_BASE_URL=https://api.myfitplatform.com
```

## Project Structure

```
lib/
├── config/
│   ├── l10n/           # Localization (ARB files, generated)
│   ├── routes/         # App routing configuration
│   └── theme/          # Theme tokens and exercise theme
├── core/               # Core utilities, services, network
│   ├── services/       # API services (workout, auth, etc.)
│   ├── utils/          # Platform utils, haptic utils
│   └── network/        # Dio client, interceptors
├── features/           # Feature modules
│   ├── auth/
│   ├── workout/
│   ├── training_plan/   # Training plan wizard, techniques
│   ├── trainer_workout/
│   ├── nutrition/
│   ├── progress/
│   └── chat/
├── shared/             # Shared widgets and components
│   └── presentation/
│       └── components/
│           └── exercise/  # Exercise-related components
└── main.dart

test/
├── unit/               # Unit tests
│   ├── models/
│   ├── providers/
│   └── services/
├── integration/        # Integration tests
│   └── journeys/
└── helpers/            # Test fixtures and utilities
```

## Building

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web (PWA)
flutter build web --release
# Output: build/web/
```

## Testing

```bash
# Run all tests
flutter test

# Run unit tests only
flutter test test/unit/

# Run integration tests
flutter test test/integration/

# Run specific test file
flutter test test/unit/providers/plan_wizard_provider_test.dart

# Run with coverage
flutter test --coverage
```

### Test Coverage

| Category | Tests |
|----------|-------|
| Unit Tests - Providers | 80+ |
| Unit Tests - Models | 30+ |
| Unit Tests - Services | 40+ |
| Integration Tests | 70+ |
| **Total** | **150+** |

## License

Proprietary - All rights reserved.
