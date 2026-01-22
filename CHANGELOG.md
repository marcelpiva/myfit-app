# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.6.0] - 2026-01-22

### Added

#### Phase 2.3 - Progress Milestones & AI Insights
- **Milestones System** - Goal tracking with visual progress
  - Multiple milestone types: Weight, Measurements, Personal Records, Consistency, Workout Count
  - Progress bar with percentage and days remaining
  - Auto-detection of almost complete goals (≥80%)
  - Create, update, and delete milestones

- **AI Insights** - AI-generated progress analysis
  - Sentiment-based styling (positive, neutral, warning)
  - Recommendations list with actionable tips
  - Dismissible insights with expiration

- **Progress Comparison Page** - Compare metrics over time
  - Date range selector with quick presets (30d, 90d, 6m, 1y)
  - Weight and measurements side-by-side comparison
  - Motivational summary with trend indicators

- **Personal Records Tab** - New "PRs" tab in Progress page
  - PR cards with exercise history
  - Exercise history bottom sheet with timeline
  - PR indicator during active workout

#### Phase 2.2 - Student Schedule Management
- **Student Schedule Page** - View and manage sessions with trainer
  - Pending confirmations banner
  - Next session highlight
  - Upcoming and past sessions lists

- **Session Actions** - Confirm presence, request reschedule
  - Reschedule request sheet with date/time picker
  - Optional reason field for reschedule requests

- **Schedule Quick Action** - Added "Agenda" to home for students with trainers

### Fixed
- **Database Migrations** - Added missing columns for co-training
  - `trainer_id`, `is_shared`, `status` columns in workout_sessions
  - `training_mode` column in plan_assignments
- **Workout Response Schema** - Fixed `created_by_id` to be nullable
- **Workout Exercises Attribute** - Fixed `workout.exercises` reference

## [1.5.4] - 2026-01-22

### Changed
- **Profile Display for Students** - Now shows organization type instead of user role
  - Students see "Personal Trainer", "Academia", etc. instead of "Aluno"
  - Professionals still see their role (Personal, Coach, etc.)
- **Leave Profile vs Delete Profile** - Different UX for students vs owners
  - Students: "Sair do Perfil" with logout icon
  - Owners: "Excluir Perfil" with trash icon
  - Context-appropriate confirmation messages

### Removed
- **Auto-login with Biometrics** - Removed automatic biometric login from welcome page
  - Users now always see the welcome page and choose to login manually

## [1.5.3] - 2026-01-21

### Added
- **Pending Invites Support** - Students can now see and accept organization invites
  - `getMyPendingInvites()` method in OrganizationService
  - Pending invites section in OrgSelectorPage with accept button
  - Invalidate providers after login/register to fetch fresh invite data

### Changed
- **Student Registration Success Message** - Updated to "Convite enviado com sucesso!"
  - Reflects new invite-based flow instead of direct membership

### Fixed
- **Pending Invites Not Showing** - Fixed issue where invites weren't visible after login
  - Now invalidates `membershipsProvider` and `pendingInvitesForUserProvider` after auth

## [1.5.2] - 2026-01-21

### Added
- **Plan Conflict Dialog** - Smart handling when assigning plans to students with active plans
  - "Substituir plano atual" - Deactivates current and assigns new
  - "Adicionar como complementar" - Both plans stay active
  - "Agendar para depois" - Schedules new plan after current ends
- **Multi-Plan Support** - Students can now have multiple active/scheduled plans
  - `StudentPlansState` refactored with `activePlans`, `scheduledPlans`, `historyAssignments`
  - Scheduled plans section with warning-colored styling
  - `deactivateAssignment(assignmentId)` method for specific plan deactivation
- **Duplicate Plan Prevention** - Shows error dialog when trying to assign same plan twice
- **Muscle Group Translation** - Added `translateMuscleGroup()` to centralized translations

### Fixed
- **Navigation Routes** - Fixed "Page not found" errors
  - "Ver" button: `/plan/$id` → `/plans/$id`
  - "Editar" button: `/plan/edit/$id` → `/plans/wizard?edit=$id`
- **"Descartar" Button** - Fixed text color from black to white
- **Review Step Translations** - Now uses centralized translate functions for goal, difficulty, splitType
- **_StatCard Overflow** - Fixed "Personalizado" text overflow in review step
- **Continuous Plan Duration** - Fixed saving when changing from weeks to "Contínuo"
  - Now sends `clear_duration_weeks: true` to API

## [1.5.1] - 2026-01-20

### Added
- **User Profile Fields** - Extended user model with additional fields
  - `birthDate` - User's date of birth
  - `gender` - User's gender
  - `heightCm` - User's height in centimeters
  - `bio` - User's biography/description

### Fixed
- **Backend Integration** - All trainer features now fully functional
  - Schedule session with students (backend endpoint active)
  - Student progress notes (backend endpoint active)
  - Student plan assignments filtering by student_id

## [1.5.0] - 2026-01-20

### Added

#### Student Detail Page - Trainer Features
- **Student Diet Tab** - View student's current diet plan with macros and meals
  - Current plan card with adherence progress
  - Macros section (calories, protein, carbs, fat)
  - Meals section with meal type icons
  - Diet history and quick actions

- **Progress Photo Gallery** - Full-screen photo viewer for student progress
  - Interactive zoom with InteractiveViewer
  - Thumbnail strip navigation
  - Photo info overlay (angle, date, notes)
  - **Before/After Comparison** - Side-by-side photo comparison with swipeable selection

- **Session Filtering** - Enhanced workout sessions tab
  - Filter by period (7 days, 30 days, 90 days, all)
  - Filter by status (completed, in progress, cancelled)
  - Combined filter support with "no results" state

- **Periodization Flow** - Complete training plan evolution system
  - `PeriodizationPhase` enum: progress, deload, newCycle
  - `loadPlanForPeriodization()` method in PlanWizardProvider
  - Phase-specific adjustments:
    - Progress: +1 set per exercise
    - Deload: ~50% sets, 1 week duration, longer rest periods
    - New Cycle: Copy structure with fresh start notes
  - Navigate from "Evoluir Plano" sheet with basePlanId and phaseType

- **Schedule Session Sheet** - Book training sessions with students
  - Date and time picker
  - Duration selection (30, 45, 60, 90, 120 min)
  - Workout type selection (strength, cardio, functional, HIIT, assessment)
  - Optional notes field

- **Student Notes Sheet** - Add and view trainer notes about students
  - Notes list with author and timestamp
  - Add new notes with real-time refresh
  - Uses TrainerService.addStudentNote() API

- **PDF Report Generation** - Generate and share student progress reports
  - Added packages: `pdf`, `printing`, `share_plus`
  - Professional PDF layout with header, summary, and data tables
  - Period selection: week, month, quarter, semester, year, custom
  - Weight progress table with variation calculation
  - Measurements table with latest values
  - Sessions/workouts table (last 20)
  - Preview/Print via printing package
  - Share via share_plus

### Changed
- StudentDetailPage popup menu now has functional actions instead of "Em breve!"
- Added report generation option to student detail menu

### Technical
- New files:
  - `lib/features/students/presentation/widgets/student_diet_tab.dart`
  - `lib/features/students/presentation/widgets/progress_photo_gallery.dart`
  - `lib/features/students/presentation/widgets/schedule_session_sheet.dart`
  - `lib/features/students/presentation/widgets/student_notes_sheet.dart`
  - `lib/features/students/presentation/widgets/student_report_sheet.dart`
  - `lib/core/utils/pdf_report_generator.dart`
- Modified PlanWizardState to include `basePlanId` and `phaseType` fields
- Updated app_router.dart to parse periodization query parameters
- Updated pubspec.yaml with pdf, printing, and share_plus dependencies

---

## [Unreleased]

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
  - Triggered by: adding/removing workouts, changing workout name/label

- **Lock split type when editing** existing plans
  - Split selection disabled with info banner explaining restriction
  - Selected split shown first, other options visually disabled (50% opacity)
  - Prevents accidental restructuring of existing training plans

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

- **AI Suggestion Technique Selection** - Configure which techniques the AI can use
  - Modal with technique selection (Normal, Drop Set, Rest-Pause, Cluster, Bi-Set, Superset, Tri-Set, Giant Set)
  - Pre-selection based on difficulty level (beginner gets fewer options)
  - Muscle group selection required when workout has no muscle groups defined
  - Cancel button to abort AI suggestion request

- **Autofocus on Group Instructions Modal** - Text field receives focus automatically when opening

- **Settings access in Trainer view** - Added gear icon in trainer home header for quick access to settings

- **Delete profile functionality** - Visible trash icon on profile cards in org selector
  - Tap trash icon to delete profile with confirmation modal
  - 7-day recovery period before permanent deletion
  - Automatic refresh of memberships after deletion

- **LEGS Muscle Group Support**
  - Extended `MuscleGroupParsing` to map API leg subgroups (quadriceps, hamstrings, calves) to generic `legs`
  - Flutter app now correctly displays all leg exercises under "Pernas" category

- **Muscle Group Validation for Techniques**
  - Super-Set now requires antagonist muscle groups (blocks same group)
  - Bi-Set/Tri-Set/Giant Set block antagonist muscles (only allow same area)
  - Visual indicators for blocked exercises (orange border, ban icon, 50% opacity)
  - Info banner shows required muscle group for Super-Set
  - Info banner shows blocked antagonist groups for Bi-Set/Tri-Set/Giant Set
  - Validation snackbars when tapping blocked exercises

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

- **PWA Support**: App can now run as a Progressive Web App
  - Installable on desktop and mobile browsers
  - Offline-capable with service worker
  - Custom splash screen and app icons

- `lib/core/utils/platform_utils.dart`: Centralized platform detection utilities
- `lib/core/utils/haptic_utils.dart`: Web-safe haptic feedback wrapper
- Web manifest with MyFit branding and theme colors
- Loading splash screen for web version

### Changed
- Label "Duração" renamed to "Semanas" for clarity
- Label "Duração Total" renamed to "Tempo Total"
- Custom duration chip label changed from "+" to "Outro"
- AI suggestion modal now uses slider instead of fixed count chips
- Plan review shows "Por Treino" and "Tempo Total" stats
- Improved spacing in plan creation wizard (reduced gap between sections)
- More compact headers for exercise technique types
- Trainer home header now shows: Avatar, Greeting, Switch Profile, Notifications, Settings
- **Completed "Programa" → "Plano de Treino" refactor** - Full terminology refactor across the app
  - Renamed `workout_program` feature module to `training_plan`
  - Updated all class names: `WorkoutProgram` → `TrainingPlan`, `ProgramWizard` → `PlanWizard`
  - Updated API endpoints: `/programs` → `/plans`
  - Updated route names: `programWizard` → `planWizard`, `programDetail` → `planDetail`
  - Updated service methods: `getPrograms` → `getPlans`, `createProgram` → `createPlan`
  - Updated navigation labels: "Programas" → "Planos"
  - Updated all Portuguese UI texts from "Programa" to "Plano de Treino"
  - Updated tests to match new naming convention
- **Updated Quick Action Labels** in trainer home page
  - "Convidar" → "Convidar Aluno"
  - "Plano" → "Criar Plano"
  - "Catálogo" → "Ver Catálogo"
  - "Agendar" → "Agendar Sessão"
- Updated i18n ARB files (app_pt.arb, app_es.arb, app_en.arb) with correct accents
- Regenerated localization files
- Reordered technique selection menu: Superset → Biset → Triset → Giantset
- Super-Set option only appears when workout has antagonist muscle pairs
- Migrated technique colors/icons to centralized `ExerciseTheme`
- Updated `WorkoutService.updateProgram` to support workout structure updates
- Improved `step_workouts_config.dart` with better group visualization
- Updated `web/manifest.json` with proper branding and PWA configuration
- Updated `web/index.html` with meta tags, Open Graph, and iOS support
- Modified `lib/main.dart` to guard SystemChrome calls for web compatibility
- Updated `lib/core/services/biometric_service.dart` to return false on web
- Replaced all `HapticFeedback` calls with `HapticUtils` across 92+ files
- QR Scanner and Barcode Scanner pages now show unavailability message on web

### Fixed
- **ABC split default workouts** now generate automatically
  - Previously required clicking on ABC option even when already selected
  - Default split (ABC) now creates workouts A, B, C immediately on wizard load
- **White text/icons on selected chips** in light mode
  - SegmentedButton now shows white text and icons when selected (on blue background)
  - All ChoiceChips now have white checkmarks when selected
  - Fixed ExecutionMode toggle, ExerciseMode toggle, and all technique controls
- Technique parameters (dropCount, restBetweenDrops, pauseDuration, miniSetCount) now persist when editing plans
- **AI Suggestion respects technique selection** - Backend now strictly enforces `allowed_techniques` parameter
  - If only Bi-Set/Superset selected, AI generates only paired exercises
  - No more "normal" exercises when user explicitly selects group techniques only
  - Both AI-powered and rule-based fallback respect the restriction
- **Portuguese Accent Corrections** - Comprehensive review and fix of pt-BR text across 97 files
- **Drag-and-drop reorder**: Now correctly handles UI indices vs data indices when exercise groups are present
- **Exercise group persistence**: Groups are now properly saved when editing existing programs
- **Group visual display**: Consistent rendering across wizard, detail, and active workout pages

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
