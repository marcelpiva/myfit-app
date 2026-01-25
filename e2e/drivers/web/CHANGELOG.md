# Changelog

All notable changes to the E2E tests will be documented in this file.

## [0.3.0] - 2026-01-24

### Added
- Direct navigation to WorkoutDetailPage using workout ID
- StartWorkoutSheet detection with co-training and solo options
- Multiple click strategies for Flutter Web buttons (Tab/Enter, JS click, dispatchEvent)
- `/test/waiting-sessions` and `/test/sessions/{id}/trainer-join` E2E helper endpoints

### Changed
- `startWorkout()` now accepts optional `workoutId` for direct navigation
- `selectTrainingMode()` uses more robust button detection
- Tests renamed to reflect actual functionality being tested

### Fixed
- Hash-based routing for direct navigation (`/#/workouts/{id}`)
- Better handling of StartWorkoutSheet modal interactions

### Documented
- Known limitations with Flutter Web button interactions
- Workarounds being explored for co-training tests

## [0.2.0] - 2025-01-24

### Added
- `FlutterHelper` class for reliable Flutter Web interaction using keyboard navigation
- Support for enabling Flutter accessibility programmatically
- Debug utilities for inspecting Flutter semantic elements
- Keyboard navigation (Tab/Enter) for modal interactions

### Changed
- Page objects now use `FlutterHelper` for consistent interaction patterns
- `startWorkout()` method improved to handle workout selection modal
- `hasAssignedPlan()` uses more specific selectors to avoid strict mode violations
- All locators now use `.first()` to avoid strict mode violations

### Fixed
- SQLite in-memory database now uses `StaticPool` to share data across connections
- Email validation fixed by using `@example.com` instead of `@e2e.test` domain
- Login flow handles org-selector redirect properly
- SPA routing with `serve -s` flag for hash-based URLs

### Skipped
- Co-training interaction tests (require understanding app's co-training UI flow)
- Feedback loop tests (require co-training mode enabled)

## [0.1.0] - 2025-01-24

### Added
- Initial E2E test setup with Playwright
- Page objects for Login, Dashboard, and WorkoutSession
- Test scenarios: cotraining, plan_assignment, feedback_loop
- E2E API server with SQLite in-memory database
- Multi-actor testing with separate browser contexts
- README documentation
