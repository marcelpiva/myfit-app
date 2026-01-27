# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.12.3] - 2026-01-27

### Fixed
- **Settings Page Wrong Options After Social Login** - Now uses organization membership role
  - Settings page correctly displays options based on user's role in the organization

- **API Error Messages Not Displayed** - Now shows specific messages from backend
  - Error interceptor properly extracts and displays backend error messages

- **validateStatus in ApiClient** - Fixed to properly trigger error interceptor for 4xx errors
  - 4xx status codes now correctly flow through error handling

- **Share Options Modal** - Now closes parent invite sheet when dismissed
  - Dismissing share options modal properly closes the invite sheet

## [1.12.2] - 2026-01-26

### Fixed
- **Onboarding Edit Mode Starting at Wrong Step** - Fixed race condition causing edit mode to open at Complete step
  - Added `_hasBeenReset` flag to prevent async state loading from overriding reset
  - "Dados Profissionais" and "Meus Objetivos" now correctly start from Welcome step

- **Trainer Onboarding Edit Mode Flow** - Flow now continues through all steps
  - Removed premature exit after Profile step in edit mode
  - Complete step now properly saves and exits

- **Keyboard Not Dismissing** - Fixed in "Treino Concluído" screen
  - Added `GestureDetector` with `FocusScope.unfocus()` to dismiss keyboard on tap outside

- **Bottom Sheet Content Cut Off** - Fixed in invite success dialog
  - Added `isScrollControlled: true` and `SingleChildScrollView`

- **"Outros" Share Button** - Now works correctly
  - Changed order to share content before closing dialogs

### Added
- **Weight/Height Input Masks** - Added validation and formatting
  - Weight: max 300 kg with decimal support
  - Height: max 250 cm

- **Invite Code Input Mask** - Format: MFP-XXXXX
  - Auto-uppercase and character filtering
  - Proper cursor positioning

- **Debug Logging** - Added for error diagnosis
  - Share profile functionality
  - Invite error handling with detailed type checking

## [1.12.1] - 2026-01-26

### Fixed
- **Invite Student Sheet Not Closing** - Sheet now closes after sharing invite
  - All share options (WhatsApp, Copy, QR Code, Others) now close both dialogs
  - onSuccess callback triggered to refresh invite list

- **Organization Selector Labels** - Activity-focused labeling for clarity
  - Students: "Treinos com [Org Name]" + "Aluno" badge (no member count)
  - Trainers: "Meus Alunos" + role badge + "[N] alunos" count

- **Train Alone Mode Improvements**
  - "Treinar por conta própria" hidden when user already has student profile or is in train alone mode
  - "Adicionar perfil Aluno" hidden in Settings when in train alone mode
  - "Meus Objetivos" now shows in Settings for train alone users (student context)
  - Train alone card appears in organization selector when active

- **Auth Session Persistence** - Session restored on app startup
  - Added `checkAuthStatus()` call in app.dart initState
  - Users no longer prompted repeatedly after Google login

### Changed
- `trainAloneModeProvider` moved to context_provider.dart for shared access
- Organization selector profile cards now show activity-focused titles

## [1.12.0] - 2026-01-26

### Added
- **Onboarding Data Persistence** - Save and load onboarding data from backend
  - Student data: fitness goal, experience level, weight, height, age, weekly frequency, injuries
  - Trainer data: CREF, specialties, years of experience, bio
  - Data persists across app sessions and devices
  - New `onboarding_completed` flag in user profile

- **Onboarding Incomplete Banner** - Subtle reminder when profile is incomplete
  - Shows on student/trainer home page if onboarding not completed
  - Tapping banner opens onboarding in edit mode
  - Different messages for student vs trainer

- **Auto-open Onboarding on First Access** - Guide users to complete profile
  - Opens automatically on first access to student/trainer view
  - Only opens once per profile (tracks via SharedPreferences)
  - If skipped, shows banner instead of re-opening

- **Edit Mode for Onboarding** - Access via Settings to update profile data
  - "Meus Objetivos" for students
  - "Dados Profissionais" for trainers
  - Pre-fills with existing data from backend
  - Returns to previous screen on completion

### Changed
- `UserResponse` now includes `onboardingCompleted` field
- `UserService.updateProfile()` accepts all onboarding fields

## [1.11.1] - 2026-01-26

### Fixed
- **Google/Apple Auth Network Error** - Fixed "Sem conexão com a internet" error on first click
  - Added retry logic with progressive backoff for social auth
  - Made `UnknownApiException` retryable for transient errors
  - Added 300ms initial delay to allow popup to fully close

- **Keyboard Not Dismissing on CREF Field** - Fixed keyboard staying open when tapping outside
  - Added `GestureDetector` to `_OnboardingStepScaffold` with `unfocus()` behavior

- **Organization Not Created for Trainers** - Fixed trainers not having org after onboarding
  - Auto-create organization with name "Personal {userName}" on onboarding completion
  - Set trainer as owner and activate context
  - Redirect to trainer home instead of org selector

- **Keyboard Collapsing Between Code Input Fields** - Fixed keyboard closing when moving between digits
  - Refactored to single hidden `TextField` with visual digit boxes
  - Prevents focus loss during code entry

- **Social Auth from Login Page** - Fixed new users going to register instead of onboarding
  - New users from Google/Apple sign-in on login page now go to user type selection → onboarding
  - Added `isAlreadyAuthenticated` flag to skip registration for already-authenticated users

### Added
- **CREF Mask Formatter** - Auto-format CREF field as `000000-X`
  - Supports all formation letters: G (Graduado), B (Bacharel), L (Licenciado), F (Formação antiga)
  - Numbers only for first 6 characters, letter for suffix

## [1.11.0] - 2026-01-25

### Added
- **Onboarding Wizard** - Guided onboarding flow after registration
  - Trainer flow: Welcome → Invite Student → Create Plan → Explore Templates → Complete
  - Student flow: Welcome → Fitness Goal → Experience Level → Physical Data → Weekly Frequency → Injuries → Complete
  - Skip option to complete later
  - Data saved to user profile
  - New files: `onboarding_provider.dart`, `onboarding_page.dart`

- **Plan Version History UI** - View and compare plan versions
  - `plan_version_history_sheet.dart` - Bottom sheet with version list
  - Version comparison view with diff visualization
  - Shows changes between versions (added, removed, modified)
  - Select two versions to compare (A/B comparison)

- **Do Not Disturb (DND) Settings** - Silence notifications during specific hours
  - Toggle in Settings → Notifications section
  - Time pickers for start and end times
  - Default: 22:00 - 07:00

- **Batch Prescription** - Prescribe plans to multiple students at once
  - Multi-select student list
  - Plan dropdown selection
  - Optional start/end date pickers
  - Progress indicator during prescription
  - Success/failure summary

- **Plan Draft System** - Save and restore plan wizard state
  - Auto-save with 30-second debounce
  - `plan_draft_service.dart` for SharedPreferences storage
  - `plan_drafts_provider.dart` for draft management
  - `drafts_list_sheet.dart` for draft selection UI
  - Maximum 10 drafts with automatic cleanup

- **QR Code for Invites** - Show QR code modal for student invites
  - Uses `qr_flutter` package
  - Copy link button
  - Integrated in students page

- **WhatsApp Sharing** - Share invite links via WhatsApp
  - Uses `share_plus` package
  - Pre-formatted message with invite link

- **Social Login** - Google and Apple Sign-In support
  - `social_auth_service.dart` for OAuth handling
  - Apple Sign In for iOS
  - Google Sign In for all platforms
  - Integrated in login and welcome pages

- **Email Verification** - OTP verification flow
  - `verify_email_page.dart` with 6-digit code input
  - Auto-submit on complete code
  - Resend with cooldown timer
  - Skip option for later verification

- **User Type Selection** - Personal Trainer vs Student registration
  - `user_type_selection_page.dart` with visual cards
  - CREF field for trainers (with verification badge)
  - Routes to appropriate onboarding flow

### Changed
- Updated `app_router.dart` with onboarding route and userType parameter
- Enhanced `register_page.dart` to redirect to onboarding
- Updated `verify_email_page.dart` to pass userType on redirect

## [1.10.0] - 2026-01-25

### Added
- **Plan Accept/Decline UI** - Students can now accept or decline prescribed training plans
  - New card on home page showing pending plans (orange) with "Responder" button
  - Bottom sheet with plan details, accept button, and decline with optional reason
  - Visual distinction between pending plans (needs response) and new plans (auto-accepted)
  - Trainer receives notification when student accepts or declines

- **Plan Assignment Response Endpoint** - Added `planAssignmentRespond` API endpoint
  - Supports accept/decline with optional decline reason
  - Automatic dashboard refresh after response

### Changed
- **Student Plans Provider** - Enhanced to handle both pending and new plans
  - `pendingPlans` - Plans awaiting acceptance (status == 'pending')
  - `newPlans` - Auto-accepted plans not yet acknowledged
  - New `respondToPlan()` method for accept/decline
  - `hasPlansNeedingAttention` getter for UI visibility

- **Home Page Plans Card** - Updated to show different states
  - Pending plans show orange accent with clipboard icon
  - New/unacknowledged plans show blue accent with sparkles icon
  - Priority: pending plans shown before new plans

## [1.9.2] - 2026-01-25

### Fixed
- **Exercise Library Filters** - Removed "Cardio" from muscle group filters
  - Cardio exercises are now only accessible via the "Aeróbico" option
  - Consistent behavior with other pickers in the app

- **Push Notifications** - Complete overhaul of push notification system
  - Fixed FCM token registration endpoint path (`/notifications/notifications/devices`)
  - Added APNs token verification before FCM token retrieval on iOS
  - Added `setForegroundNotificationPresentationOptions` for iOS foreground notifications
  - Push notifications now work in foreground, background, and terminated states

- **In-App Notifications Screen** - Fixed "Erro ao carregar" on notifications page
  - Fixed response parsing (API returns `{notifications: [...]}` not plain list)
  - Fixed `unread_count` response field parsing

### Added
- **Fastlane External Testing** - New `testflight_external` lane
  - Distributes builds to external testing groups automatically

## [1.9.1] - 2026-01-24

### Added
- **TestFlight Automation** - Streamlined iOS deployment process
  - `ITSAppUsesNonExemptEncryption` flag to auto-skip encryption compliance review
  - Builds no longer require manual compliance approval in App Store Connect

### Changed
- Updated fastlane configuration for simplified TestFlight uploads

## [1.9.0] - 2026-01-24

### Added
- **Global Cache Strategy** - Comprehensive caching infrastructure for Riverpod providers
  - `CachedStateNotifier` base class with built-in TTL and stale-while-revalidate support
  - `CacheConfig` with predefined TTL configs: frequent (1 min), standard (5 min), longlived (30 min), static (24 hours)
  - `CacheMetadata` for tracking fetch timestamps and refresh state
  - Event-driven cache invalidation via `CacheEventType` (workoutCompleted, planAssigned, etc.)
  - `CachedRefreshIndicator` widget for pull-to-refresh with automatic haptic feedback
  - Background refresh shows cached data immediately while fetching updates

### Changed
- **Provider Migrations to Cache System**:
  - `StudentDashboardNotifier` - Uses dashboard cache (1 min TTL), auto-refreshes on workout/checkin events
  - `TrainerDashboardNotifier` - Uses dashboard cache, listens to student/workout/session events
  - `PlansNotifier` - Uses plans cache (5 min TTL), auto-refreshes on plan create/update/delete events
  - `NotificationsNotifier` - Uses notifications cache (1 min TTL), refreshes on message/achievement events
  - `GamificationStatsNotifier` - Uses gamification cache, refreshes on workout/checkin/achievement events
  - `TrainerStudentsNotifier` - Uses students cache, refreshes on student add/remove/invite events
  - All providers now support stale-while-revalidate pattern for better UX

## [1.8.9] - 2026-01-24

### Fixed
- **iOS Push Notifications** - Fixed push notifications not working on iPhone
  - Created `RunnerRelease.entitlements` with `aps-environment: production`
  - Release and Profile builds now use production APNs environment
  - Debug builds continue to use development environment

## [1.8.8] - 2026-01-24

### Fixed
- **Organization Context for Multi-Trainer Students** - Students with multiple trainers now see correct data
  - Workouts screen loads only workouts from the selected trainer's organization
  - Works with backend's new X-Organization-ID header filtering
  - OrganizationInterceptor automatically adds organization context to all requests

### Changed
- Minor UI improvements and code cleanup

## [1.8.7] - 2026-01-24

### Added
- **Google Play Store Deployment** - Full Android release pipeline
  - Configured release signing with upload keystore
  - Enabled core library desugaring for Java 8+ API support
  - Added multiDex support for large app builds
  - Updated Kotlin to 2.1.0 for Flutter compatibility
  - Added Google Services plugin 4.4.2 for Firebase

- **Android Fastlane Setup** - Automated Play Store deployment
  - `fastlane build` - Generate release App Bundle
  - `fastlane internal` - Deploy to internal testing track
  - `fastlane beta` - Deploy to open testing track
  - `fastlane production` - Deploy to production
  - `fastlane promote_to_production` - Promote internal to production
  - Service Account authentication with Play Store API

### Changed
- Updated `.gitignore` to exclude Android keystore and Play Store credentials

## [1.8.6] - 2026-01-24

### Added
- **Visual Regression Testing** - Alchemist-based golden tests for UI components
  - Device profiles for iPhone 14 Pro, Pixel 7, iPad Pro 11
  - Auth components tests (login form, buttons, headers, screen mockups)
  - Student dashboard tests (stats cards, workout cards, activity lists)
  - Button components tests (elevated, outlined, text, FAB variants)
  - 34 visual tests with multi-device support

- **CI/CD for Visual Tests** - GitHub Actions workflow for visual regression
  - Runs on PRs and pushes affecting lib/ or test/visual/
  - Uploads failure artifacts for debugging
  - Auto-update goldens with `update-goldens` label

- **Observability Infrastructure** - GlitchTip/Sentry-compatible error tracking
  - `ObservabilityService` for error capture and user context
  - `ObservabilityProviderObserver` for Riverpod state tracking
  - `ObservabilityNavigationObserver` for route tracking
  - Environment-based DSN configuration (production, staging, development)
  - Performance tracing with configurable sample rates
  - Integrated in `main.dart` and GoRouter for full coverage
  - DSN configured: app.glitchtip.com/19780

- **Provider Unit Tests** - Comprehensive tests for critical providers
  - `auth_provider_test.dart` - 24 tests (login, logout, register, state management)
  - `context_provider_test.dart` - 30 tests (active context, memberships, role checks)

### Fixed
- **Exercise Feedback Swap Dialog** - Keyboard no longer covers submit button
  - Added `isScrollControlled: true` to modal bottom sheet
  - Wrapped content in `SingleChildScrollView` for proper keyboard handling

### Dependencies
- Added `alchemist: ^0.13.0` for visual testing
- Added `sentry_flutter: ^8.0.0` for observability

## [1.8.5] - 2026-01-24

### Fixed
- **Plan Wizard Reordering** - Complete fix for drag-and-drop reordering of exercises
  - Fixed items landing in wrong positions after drag-and-drop
  - Root cause: mismatch between UI list building and provider's index calculation
  - UI was grouping all single exercises together instead of preserving original order
  - Now correctly preserves relative positions of singles and groups (bi-set, tri-set, giant-set)
  - Groups can now be positioned anywhere, not just at start/end
  - Moved collapse/expand state to `PlanWizardState` provider to survive reordering
  - Added `collapsedExerciseIds` and `collapsedGroupIds` fields
  - Removed unused legacy reorder functions (`_buildUiToDataMapping`, `_reorderSingleExercise`, `_reorderGroup`)

## [1.8.4] - 2026-01-24

### Fixed
- **Xcode Warnings** - Resolved 109+ Xcode warnings and build issues
  - Added `inhibit_all_warnings!` to Podfile to suppress CocoaPods plugin warnings
  - Disabled `CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER` in project settings
  - Updated `IPHONEOS_DEPLOYMENT_TARGET` from 13.0 to 15.0 for consistency with Podfile
  - Fixes iOS version mismatch linker warnings

## [1.8.3] - 2026-01-24

### Fixed
- **Blank Screen on Workout Detail** - Fixed blank screen when student clicks workout from assigned plan
  - Added standalone `/workout/:workoutId` route outside StatefulShellRoute
  - Navigation from `PlanDetailPage` now uses standalone route instead of shell-nested route
  - Fixed same issue in `ActiveCheckinCard` widget
  - Added validation and debug logging to `WorkoutDetailNotifier`

## [1.8.2] - 2026-01-23

### Added
- **Organization Context Interceptor** - Automatic `X-Organization-ID` header on all API requests
  - `OrganizationInterceptor` syncs with active context
  - Ensures API filters data by current organization
  - Prevents cross-organization data leaks

- **Auto-Refresh on App Resume** - Data refreshes when returning from background
  - Triggers after 30+ seconds in background
  - Refreshes dashboard, plans, students, and invites
  - Uses `WidgetsBindingObserver` lifecycle management

### Fixed
- **Plan Workouts Display** - Assigned plans now show correct workout count
  - Maps `plan_workouts` to `workouts` for UI compatibility
  - Badge correctly shows number of workouts in plan

- **Keyboard Dismissal** - Numeric keyboard now dismisses properly in active workout
  - Added `textInputAction: TextInputAction.done` for Done button
  - Added `onTapOutside` handler to dismiss on outside tap
  - Properly unfocuses input after submission

- **Workout Detail Loading States** - Page now shows loading spinner and error messages
  - Displays loading indicator while fetching workout data
  - Shows error message with retry button when fetch fails
  - Improves user feedback for API issues

## [1.8.1] - 2026-01-23

### Fixed
- **Trainer Plan Wizard Redirect** - Fixed trainers being incorrectly redirected to workouts page
  - `_trainerGuardRedirect` now checks user role before applying student guard
  - Trainers can now access plan wizard without being redirected

- **Duplicate Bottom Navigation** - Fixed trainers seeing student bottom nav when viewing workouts
  - Added `/trainer/workouts/:workoutId` route outside shell
  - Plan detail page now routes trainers to trainer-specific workout route
  - Prevents duplicate navigation bars when trainer clicks Home

## [1.8.0] - 2026-01-23

### Added
- **Workout Picker Sheet** - New bottom sheet for choosing which workout to start
  - Shows all workouts from active plan
  - Highlights suggested workout with badge
  - Allows selecting any workout regardless of schedule
  - Integrates with Start Workout options (alone vs with personal)

- **Feature Flags System** - New `FeatureFlags` class for controlling features
  - `showDevScreenLabels` - Controls visibility of dev screen labels
  - Works in release builds (not tied to kDebugMode)

- **DevScreenLabel on All Routes** - Automatic wrapper via GoRouter
  - All 70+ routes now have DevScreenLabel automatically
  - Centralized implementation via `_devLabel()` helper
  - Removed manual DevScreenLabel from individual pages

- **Grouped Exercise Indicators** - Visual badges for advanced techniques in active workout
  - BI-SET, TRI-SET, SUPERSET, GIANT SET, DROP SET, CLUSTER badges
  - Color-coded with icons for each technique type
  - Shows exercise order within group
  - Displays group instructions when available
  - **Consistent colors** - Now uses centralized `ExerciseTheme` for matching colors between builder and active workout
  - **Visual enhancements** - Colored borders and subtle gradients for grouped exercises
  - **Global technique theming** - Background gradient, progress bar, and "Completar Série" button all adapt to current exercise's technique color
  - **Smooth transitions** - Animated color changes when navigating between exercises with different techniques

### Fixed
- **Active Workout Exit Bug** - Fixed dialog context issue preventing exit
  - Separated dialog context from page context
  - Exit now works reliably from confirmation dialog

- **Workout Complete Exit Bug** - Fixed "Finalizar" button not working on completion sheet
  - Used callback pattern to pass page context to bottom sheet
  - Exit now works correctly after completing workout

- **Exercise Name Display** - Improved name detection in active workout
  - Checks multiple paths: `name`, `exercise_name`, `exercise.name`
  - Fallback to "Exercício" if no name found

- **Plan Detail 422 Error** - Fixed navigation to `/plans/null`
  - Added redirect guard for invalid planId (null, empty, "null")
  - Added validation in PlanDetailNotifier before API call
  - Added null check in WorkoutsPage before navigation

- **Plan Cache Invalidation** - Fixed exercises not appearing after plan edit
  - Now invalidates `planDetailNotifierProvider` after saving in wizard

- **Exercise Order** - Fixed missing order field when saving plan
  - Added `order` field to exercise mapping in plan wizard provider

- **Plan Wizard Blank Screen on Edit** - Fixed blank screen when editing student workout
  - Added loading indicator while fetching plan data
  - Added error state with retry option
  - Applies to both edit mode and periodization mode

- **Duplicate Exercise Count** - Fixed "1/12" showing twice on active workout screen
  - ExercisePageIndicator no longer shows compact text when > 10 exercises
  - ExerciseNavigationArrows already displays the count

- **Muscle Group Translation** - Applied `translateMuscleGroup` to ExerciseCardCompact
  - "glutes" now correctly shows as "Glúteos"

### Changed
- **Start Workout Flow** - Now shows WorkoutPickerSheet instead of direct navigation
  - Students can choose any workout from their plan
  - Suggested workout is highlighted but not required

## [1.7.1] - 2026-01-22

### Added
- **Dev Screen Labels** - Subtle debug labels for screen identification
  - Shows screen name in top-right corner (debug mode only)
  - Non-intrusive design with `IgnorePointer` for touch-through
  - Added to key screens: `WorkoutDetailPage`

### Fixed
- **Exercise Grouping Display** - Fixed technique visualization for bi-sets, tri-sets, etc.
  - Changed field lookup from `group_id` to `exercise_group_id` (with legacy fallback)
  - Exercises now correctly display with technique grouping badges

- **Trainer Plans Tab** - Fixed UI showing accept buttons incorrectly
  - Removed accept/decline buttons from trainer's student view
  - Added read-only pending section "Aguardando Resposta do Aluno"
  - Added cancel option for pending prescriptions via PopupMenuButton
  - Added visibility for declined plans with "Recusado" badge

## [1.7.0] - 2026-01-22

### Added

#### Phase 2.6 - Advanced Training Features
- **Workout Timer System** - Advanced timer sheet for active workouts
  - Configurable timer with rest intervals
  - Visual countdown with progress indicator

- **Exercise Technique Visualization** - Grouped display for advanced techniques
  - Visual grouping for supersets, bisets, trisets, giantsets
  - Technique badges and colors for dropsets, rest-pause, cluster sets
  - Improved workout detail page with technique cards

- **Plan Assignment Accept/Decline** - Student response to prescribed plans
  - Pending plans notification card on Home
  - Bottom sheet to view plan details and respond
  - Accept plan directly or decline with optional reason
  - `studentPendingPlansProvider` for student's own pending plans
  - `respondToPlanAssignment()` service method

- **Social Features Foundation**
  - Shareable workout completion cards
  - Shareable achievement cards
  - Activity feed page structure

- **Progress Reports**
  - PDF report generation page structure

### Fixed
- **Workout Detail Null Handling** - Fixed "type Null is not a subtype of String" errors
  - Added null safety for exercise name, sets, reps, rest fields
  - Nested Map access with fallbacks

### Changed
- **Student Plans Tab** - Added "Aguardando Resposta" section for pending plans
  - Direct accept button on pending plan cards
  - "Ver Detalhes" opens full response sheet

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
