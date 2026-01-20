# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2026-01-20

### Added
- **ExecutionMode Toggle** for exercise configuration
  - Three modes: Repetições (Reps), Isometria (Isometric), Combinado (Combined)
  - Automatic mode detection when editing existing exercises
  - Mode-specific fields: reps for strength, time for isometric, both for combined
  - Different time presets: 15-90s for pure isometric, 3-15s for combined pause

- **Exercise Group Notification** when changing workout muscle groups
  - Shows informational alert when workout has exercises from other muscle groups
  - Lists exercises that don't match the new muscle group selection
  - Exercises are kept (not deleted) - just informational notice

- **Auto-switch to "Personalizado"** split type
  - Automatically changes training type to "Personalizado" when user modifies workouts
  - Triggered by: adding/removing workouts, adding/removing exercises

### Fixed
- **White text/icons on selected chips** in light mode
  - SegmentedButton now shows white text and icons when selected (on blue background)
  - All ChoiceChips now have white checkmarks when selected
  - Fixed ExecutionMode toggle, ExerciseMode toggle, and all technique controls

## [1.4.1] - 2026-01-19

### Added
- **Structured Technique Parameter Editing**
  - Dropset: visual controls for drop count (2-5) and rest between drops (0, 5, 10, 15s)
  - Rest-Pause: visual controls for pause duration (10, 15, 20, 30s)
  - Cluster: visual controls for mini-set count (3-6) and pause duration
  - Parameters now persist correctly when saving and editing plans

- **Custom Duration Picker**
  - New slide-up bottom sheet replaces text input dialog
  - Grid of preset duration chips (15m to 3h)
  - Fine-tuning slider (15-180 min in 5-min increments)
  - Visual display of selected duration with icon

### Changed
- Label "Duração" renamed to "Semanas" for clarity
- Label "Duração Total" renamed to "Tempo Total"
- Custom duration chip label changed from "+" to "Outro"

### Fixed
- Technique parameters (dropCount, restBetweenDrops, pauseDuration, miniSetCount) now persist when editing plans

## [1.4.0] - 2026-01-19

### Added
- **Workout Duration Management**
  - New "Duração por Treino" selector in plan creation (30, 45, 60, 90, 120 min)
  - Time indicator in workout header showing current vs target time
  - Warning when workout exceeds 120% of target duration
  - Total time display in plan review summary

- **Exercise Time Estimation**
  - Automatic calculation based on sets, rest periods, and technique type
  - Time chip displayed on each exercise (e.g., "3:30")
  - Technique-aware timing (Drop Set, Rest-Pause, Cluster have different calculations)

- **AI Suggestion with Time Awareness**
  - Time info banner showing current workout time and remaining time
  - Dynamic exercise count suggestion based on available time
  - Slider for adjusting quantity (1-10 exercises)
  - Warning when selected count may exceed target workout duration

- **Calorie/Macro Validation**
  - Automatic validation: calories = (protein × 4) + (carbs × 4) + (fat × 9)
  - Tolerance margin: ±100 kcal or ±5%, whichever is greater
  - Visual feedback: error (red) when mismatch, success (green) when valid
  - Blocks advancing in diet step until calories match macros

### Changed
- AI suggestion modal now uses slider instead of fixed count chips
- Plan review shows "Por Treino" and "Tempo Total" stats

## [1.3.3] - 2026-01-19

### Added
- **AI Suggestion Technique Selection** - Configure which techniques the AI can use
  - Modal with technique selection (Normal, Drop Set, Rest-Pause, Cluster, Bi-Set, Superset, Tri-Set, Giant Set)
  - Pre-selection based on difficulty level (beginner gets fewer options)
  - Muscle group selection required when workout has no muscle groups defined
  - Cancel button to abort AI suggestion request
- **Autofocus on Group Instructions Modal** - Text field receives focus automatically when opening

### Fixed
- **AI Suggestion respects technique selection** - Backend now strictly enforces `allowed_techniques` parameter
  - If only Bi-Set/Superset selected, AI generates only paired exercises
  - No more "normal" exercises when user explicitly selects group techniques only
  - Both AI-powered and rule-based fallback respect the restriction

### Changed
- Improved spacing in plan creation wizard (reduced gap between sections)
- More compact headers for exercise technique types

## [1.3.2] - 2026-01-19

### Added
- **Settings access in Trainer view** - Added gear icon in trainer home header for quick access to settings
- **Delete profile functionality** - Visible trash icon on profile cards in org selector
  - Tap trash icon to delete profile with confirmation modal
  - 7-day recovery period before permanent deletion
  - Automatic refresh of memberships after deletion

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
