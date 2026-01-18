# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-01-18

### Added
- **Advanced Exercise Techniques**: Full support for training techniques
  - Bi-Set, Tri-Set, Giant Set (multi-exercise groups)
  - Drop Set, Rest-Pause, Cluster (single-exercise techniques)
  - Technique configuration modal with customizable parameters
  - Visual grouping with color-coded technique badges
- **Exercise Group Management**
  - Create groups from existing exercises
  - Add/remove exercises from groups
  - Reorder exercises within groups
  - Edit group instructions
  - Disband or delete entire groups
- **Centralized Exercise Theme** (`lib/config/theme/tokens/exercise_theme.dart`)
  - Unified color palette for all technique types
  - Consistent iconography across the app
- **Shared Exercise Components** (`lib/shared/presentation/components/exercise/`)
  - `ExerciseStatsRow`: Unified display for sets/reps/rest
  - `TechniqueBadge`: Technique indicator with icon and color
  - `PositionIndicator`: Position marker for grouped exercises
  - `TechniqueConfigDisplay`: Shows technique-specific config
- **Comprehensive Test Suite**
  - 52+ unit tests for program wizard provider
  - Integration tests for exercise group workflows
  - Test fixtures and helpers for consistent testing
- **iOS Fastlane Setup** for TestFlight deployment

### Fixed
- **Drag-and-drop reorder**: Now correctly handles UI indices vs data indices when exercise groups are present
- **Exercise group persistence**: Groups are now properly saved when editing existing programs
- **Group visual display**: Consistent rendering across wizard, detail, and active workout pages

### Changed
- Migrated technique colors/icons to centralized `ExerciseTheme`
- Updated `WorkoutService.updateProgram` to support workout structure updates
- Improved `step_workouts_config.dart` with better group visualization

## [1.1.0] - 2026-01-18

### Added
- **PWA Support**: App can now run as a Progressive Web App
  - Installable on desktop and mobile browsers
  - Offline-capable with service worker
  - Custom splash screen and app icons
- `lib/core/utils/platform_utils.dart`: Centralized platform detection utilities
- `lib/core/utils/haptic_utils.dart`: Web-safe haptic feedback wrapper
- Web manifest with MyFit branding and theme colors
- Loading splash screen for web version

### Changed
- Updated `web/manifest.json` with proper branding and PWA configuration
- Updated `web/index.html` with meta tags, Open Graph, and iOS support
- Modified `lib/main.dart` to guard SystemChrome calls for web compatibility
- Updated `lib/core/services/biometric_service.dart` to return false on web
- Replaced all `HapticFeedback` calls with `HapticUtils` across 92+ files
- QR Scanner and Barcode Scanner pages now show unavailability message on web

### Platform-Specific Behavior
- **Biometric Authentication**: Disabled on web (returns false)
- **QR/Barcode Scanner**: Shows "unavailable on web" message
- **Haptic Feedback**: No-op on web platform
- **System Chrome**: Orientation lock and UI overlays skipped on web

## [1.0.0] - 2026-01-15

### Added
- Initial release
- User authentication with email/password and biometrics
- Workout plan management
- Nutrition tracking and meal logging
- Progress tracking with photos and measurements
- Real-time chat functionality
- QR Code check-in system
- Gamification with achievements and leaderboards
- Multi-organization support
- Trainer/Coach dashboard
- Nutritionist features
