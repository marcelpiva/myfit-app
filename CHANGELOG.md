# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.2] - 2026-01-19

### Added
- **Settings access in Trainer view** - Added gear icon in trainer home header for quick access to settings
- **Leave profile functionality** - Long press on profile card in org selector to leave an organization
  - Confirmation modal with clear warning message
  - Automatic refresh of memberships after leaving

### Changed
- Trainer home header now shows: Avatar, Greeting, Switch Profile, Notifications, Settings

## [1.3.1] - 2026-01-19

### Changed
- **Completed "Programa" → "Plano de Treino" refactor** - Final wave of terminology updates
  - Renamed provider classes: `ProgramsNotifier` → `PlansNotifier`, `ProgramDetailNotifier` → `PlanDetailNotifier`
  - Renamed provider classes: `StudentProgramsNotifier` → `StudentPlansNotifier`
  - Updated `workouts_page.dart`: Renamed `_ProgramCard` → `_PlanCard`, `_ProgramBadge` → `_PlanBadge`
  - Updated `student_workouts_page.dart`: Renamed `_StudentProgramCard` → `_StudentPlanCard`
  - Updated `marketplace_page.dart`: Renamed `_CompactProgramCard` → `_CompactPlanCard`, `_ProgramDetailSheet` → `_PlanDetailSheet`
  - Updated `trainer_plans_page.dart`: Renamed `_ProgramsList` → `_PlansList`, `_UnifiedProgramCard` → `_UnifiedPlanCard`
  - Updated callback in `trainer_home_page.dart`: `onNovoProgramy` → `onNovoPlano`
  - Renamed files: `program_detail_page.dart` → `plan_detail_page.dart`, `assign_program_sheet.dart` → `assign_plan_sheet.dart`
  - Renamed test fixtures: `program_fixtures.dart` → `plan_fixtures.dart`, `ProgramFixtures` → `PlanFixtures`
  - Renamed test file: `program_creation_journey_test.dart` → `plan_creation_journey_test.dart`
  - Deleted obsolete files: `program_detail_page.dart`, `assign_program_sheet.dart`

- **Updated Quick Action Labels** in trainer home page
  - "Convidar" → "Convidar Aluno"
  - "Plano" → "Criar Plano"
  - "Catálogo" → "Ver Catálogo"
  - "Agendar" → "Agendar Sessão"

## [1.3.0] - 2026-01-19

### Changed
- **Renamed "Programa" to "Plano de Treino"** - Full terminology refactor across the app
  - Renamed `workout_program` feature module to `training_plan`
  - Updated all class names: `WorkoutProgram` → `TrainingPlan`, `ProgramWizard` → `PlanWizard`
  - Updated API endpoints: `/programs` → `/plans`
  - Updated route names: `programWizard` → `planWizard`, `programDetail` → `planDetail`
  - Updated service methods: `getPrograms` → `getPlans`, `createProgram` → `createPlan`
  - Updated navigation labels: "Programas" → "Planos"
  - Updated all Portuguese UI texts from "Programa" to "Plano de Treino"
  - Updated tests to match new naming convention

## [1.2.2] - 2026-01-19

### Fixed
- **Portuguese Accent Corrections** - Comprehensive review and fix of pt-BR text across 97 files
  - Fixed missing accents: 'Amanhã', 'mês', 'Câmera', 'Avanço', 'Média', 'Diferença'
  - Corrected 'Retenção', 'Permissões', 'Integrações', 'Matrícula', 'Observações'
  - Fixed 'Proteína', 'Distribuição', 'Déficit', 'Superávit', 'Proprietário'
  - Corrected 'Consistência', 'distância', 'prioritário', 'Bancário', 'Funcionário'
  - Fixed 'Nível', 'Disponíveis', 'Confirmações', 'Solicitações', 'Técnicas'
  - And many other accent corrections throughout the app

### Changed
- Updated i18n ARB files (app_pt.arb, app_es.arb, app_en.arb) with correct accents
- Regenerated localization files

## [1.2.1] - 2026-01-19

### Added
- **Muscle Group Validation for Techniques**
  - Super-Set now requires antagonist muscle groups (blocks same group)
  - Bi-Set/Tri-Set/Giant Set block antagonist muscles (only allow same area)
  - Visual indicators for blocked exercises (orange border, ban icon, 50% opacity)
  - Info banner shows required muscle group for Super-Set
  - Info banner shows blocked antagonist groups for Bi-Set/Tri-Set/Giant Set
  - Validation snackbars when tapping blocked exercises

### Changed
- Reordered technique selection menu: Superset → Biset → Triset → Giantset
- Super-Set option only appears when workout has antagonist muscle pairs

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
