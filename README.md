# MyFit App

[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](./CHANGELOG.md)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B.svg?logo=flutter)](https://flutter.dev)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20Android%20%7C%20Web-lightgrey.svg)](https://flutter.dev/multi-platform)

Aplicativo Flutter multiplataforma para a plataforma MyFit.

## Features

- User authentication with biometrics (iOS/Android)
- Workout plan management
- Nutrition tracking
- Progress photos and measurements
- Real-time chat
- Check-in via QR Code (iOS/Android)
- Gamification system
- **PWA Support** - Installable web app

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
├── core/           # Core utilities, constants, theme
├── features/       # Feature modules
│   ├── auth/
│   ├── workout/
│   ├── nutrition/
│   ├── progress/
│   └── chat/
├── shared/         # Shared widgets and components
└── main.dart
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
flutter test
```

## License

Proprietary - All rights reserved.
