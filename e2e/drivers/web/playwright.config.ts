import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright configuration for MyFit E2E tests.
 *
 * Run against:
 * - E2E API server: http://localhost:8001 (myfit-api in E2E mode)
 * - Flutter Web app: http://localhost:3000 (flutter build web + serve)
 */

const API_URL = process.env.E2E_API_URL || 'http://localhost:8001';
const APP_URL = process.env.E2E_APP_URL || 'http://localhost:3000';

export default defineConfig({
  testDir: './tests',
  fullyParallel: false, // Multi-actor tests need sequential execution
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: 1, // Single worker for multi-actor coordination
  reporter: [
    ['html', { open: 'never' }],
    ['list'],
  ],

  use: {
    baseURL: APP_URL,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'on-first-retry',
  },

  // Global setup/teardown
  globalSetup: undefined, // Can add if needed
  globalTeardown: undefined,

  // Test timeout
  timeout: 60000, // 60 seconds per test
  expect: {
    timeout: 10000, // 10 seconds for assertions
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    // Can add more browsers if needed
    // {
    //   name: 'firefox',
    //   use: { ...devices['Desktop Firefox'] },
    // },
  ],

  // Web server configuration (optional - start servers automatically)
  // webServer: [
  //   {
  //     command: 'cd ../../../.. && python -m tests.e2e.server',
  //     cwd: '../../../myfit-api',
  //     url: API_URL,
  //     reuseExistingServer: !process.env.CI,
  //   },
  //   {
  //     command: 'npx serve ../../build/web -l 3000',
  //     url: APP_URL,
  //     reuseExistingServer: !process.env.CI,
  //   },
  // ],
});

// Export URLs for test files
export { API_URL, APP_URL };
