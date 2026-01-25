# MyFit E2E Tests (Playwright)

Multi-actor E2E tests for MyFit Flutter Web app using Playwright.

## Prerequisites

1. Node.js 18+
2. Python 3.11+ (for E2E API server)
3. Flutter SDK (for building web app)

## Quick Start

```bash
# 1. Start E2E API Server (from myfit-api)
cd myfit-api
python -m tests.e2e.server

# 2. Build and serve Flutter Web (from myfit-app)
cd myfit-app
flutter build web --dart-define=API_URL=http://localhost:8001
npx serve build/web -l 3000

# 3. Run tests (from e2e/drivers/web)
cd e2e/drivers/web
npm install
npm run install:browsers
npm test
```

## Setup

```bash
# Install Playwright dependencies
cd myfit-app/e2e/drivers/web
npm install
npx playwright install chromium
```

## Running Tests

### 1. Start the E2E API Server

From the `myfit-api` directory:

```bash
cd myfit-api
python -m tests.e2e.server
```

This starts the API with SQLite in-memory database on port 8001.

### 2. Build and Serve Flutter Web

From the `myfit-app` directory:

```bash
cd myfit-app
flutter build web --dart-define=API_URL=http://localhost:8001/api/v1
npx serve build/web -l 3000 -s  # -s flag enables SPA mode for hash routing
```

> **Note:** The `-s` flag is required for SPA (Single Page Application) mode to handle Flutter's hash-based routing properly.

### 3. Run Tests

```bash
cd myfit-app/e2e/drivers/web

# Run all tests
npm test

# Run specific scenarios
npm run test:cotraining   # Co-training flow
npm run test:feedback     # Feedback loop flow

# Run with UI (interactive)
npm run test:ui

# Run with visible browser
npm run test:headed

# Run in debug mode
npm run test:debug

# View HTML report
npm run report
```

## Test Structure

```
e2e/drivers/web/
├── tests/
│   ├── cotraining.spec.ts    # Multi-actor co-training tests
│   ├── feedback-loop.spec.ts # Real-time feedback tests
│   └── debug-flutter.spec.ts # Flutter Web debugging utilities
├── pages/
│   ├── flutter.helper.ts     # Flutter Web interaction helper (keyboard nav)
│   ├── login.page.ts         # Login page object
│   ├── dashboard.page.ts     # Dashboard page object
│   └── workout-session.page.ts # Workout session page object
├── playwright.config.ts      # Playwright configuration
└── package.json
```

## Current Test Status

| Test | Status | Description |
|------|--------|-------------|
| Login flow | ✅ Pass | Both trainer and student can login with credentials |
| Student sees plan | ✅ Pass | Student dashboard shows assigned workout plan |
| Workout navigation | ✅ Pass | Student can navigate to workout detail and see StartWorkoutSheet |
| Training mode options | ✅ Pass | StartWorkoutSheet shows both "Treinar Sozinho" and "Treinar com Personal" |
| Trainer dashboard | ✅ Pass | Trainer can view their dashboard |
| API health check | ✅ Pass | E2E server responds correctly |
| Scenario setup | ✅ Pass | Test scenarios load with correct data |
| Database reset | ✅ Pass | Database clears between test runs |
| Co-training interaction | ⏸️ Skip | Flutter Web button clicks don't trigger handlers (see Known Limitations) |
| Feedback loop | ⏸️ Skip | Requires working co-training mode |

### Known Limitations

Flutter Web renders to a canvas using CanvasKit, which creates semantic elements for accessibility but doesn't respond to programmatic DOM clicks. This means:

1. **Button clicks via JavaScript don't work** - The semantic elements are read-only accessibility hints
2. **Keyboard navigation is inconsistent** - Tab focus doesn't always reach all elements
3. **Modal interactions are challenging** - Bottom sheets and dialogs trap focus differently

**Workarounds being explored:**
- Using Patrol (Flutter's mobile testing framework) for native interactions
- Adding JavaScript hooks in the Flutter app for E2E testing
- Direct API calls to simulate user actions where UI interaction fails

## Available Scenarios

The E2E API server provides test scenarios:

| Scenario | Description |
|----------|-------------|
| `cotraining` | Trainer + Student + Plan + Assignment (accepted) |
| `plan_assignment` | Trainer + 3 Students + Plan (not assigned) |
| `feedback_loop` | Active session with trainer joined, sets in progress |

Use via API:
```bash
# Setup a scenario
curl -X POST http://localhost:8001/test/setup/cotraining
curl -X POST http://localhost:8001/test/setup/feedback_loop

# Reset database
curl -X POST http://localhost:8001/test/reset

# Health check
curl http://localhost:8001/test/health
```

## Multi-Actor Testing

The tests create separate browser contexts for different actors:

1. **Trainer Context**: Monitors students, joins sessions, sends adjustments
2. **Student Context**: Starts workout, receives adjustments

Both run simultaneously with coordinated assertions.

## Flutter Web Interaction Patterns

Flutter Web renders using CanvasKit which doesn't create traditional DOM elements. However, it does create an accessibility tree with `flt-semantics` elements.

### Key Challenges

1. **flutter-view intercepts pointer events** - Direct clicks often don't work
2. **Must enable accessibility first** - Click the `flt-semantics-placeholder` button
3. **Use keyboard navigation** - Tab/Shift+Tab/Enter for reliable interaction

### FlutterHelper Class

The `flutter.helper.ts` provides utilities for Flutter Web interaction:

```typescript
import { FlutterHelper } from './pages/flutter.helper';

const flutter = new FlutterHelper(page);

// Wait for Flutter and enable accessibility
await flutter.waitForFlutter();

// Navigate using keyboard
await flutter.tabToAndActivate((el) => el.text?.includes('Login'));

// Click a button by text pattern
await flutter.clickButton(/iniciar|start/i);

// Debug: log all semantic elements
await flutter.debugElements();
```

### Selectors

- `flt-semantics[role="button"]` - Button elements
- `flt-semantics[aria-label="..."]` - Elements with semantic labels
- `flt-semantics input` - Real input elements inside Flutter semantic containers

### Semantic Labels Added

| Component | Semantic Label |
|-----------|----------------|
| Email input | `email-input` |
| Password input | `password-input` |
| Login button | `login-button` |
| Start workout | `quick-action-iniciar-treino` |
| Co-training mode | `cotraining-mode` |
| Active students | `active-students` |
| Student cards | `student-card-{name}` |
| Adjustment notification | `adjustment-notification` |

## CI/CD

E2E tests run automatically on push to `main` and `develop` branches.

See `.github/workflows/e2e.yml` for the workflow configuration.

### Running in CI

```bash
# The CI workflow does this automatically:
npm run test:ci
```

## Troubleshooting

### API server not starting

Check if port 8001 is in use:
```bash
lsof -i :8001
```

### Flutter Web not loading

Ensure the web build has the correct API URL:
```bash
flutter build web --dart-define=API_URL=http://localhost:8001
```

### Tests timing out

Increase timeouts in `playwright.config.ts` or individual tests.

### Selectors not finding elements

Ensure Flutter widgets have `Semantics` widgets or `semanticsLabel` properties.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `API_URL` | `http://localhost:8001` | E2E API server URL |
| `APP_URL` | `http://localhost:3000` | Flutter Web app URL |
| `CI` | - | Set in CI environment |
