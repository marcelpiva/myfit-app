# MyFit App

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](../CHANGELOG.md)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B.svg?logo=flutter)](https://flutter.dev)

Flutter mobile application for the MyFit platform.

## Features

- User authentication with biometrics
- Workout plan management
- Nutrition tracking
- Progress photos and measurements
- Real-time chat
- Check-in via QR Code
- Gamification system

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
- iOS 12+ / Android 5.0+

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
```

## Testing

```bash
flutter test
```

## License

Proprietary - All rights reserved.
