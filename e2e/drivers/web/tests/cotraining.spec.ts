import { test, expect, Page, BrowserContext } from '@playwright/test';
import { LoginPage, DashboardPage, WorkoutSessionPage } from '../pages';

/**
 * Co-Training Multi-Actor Tests.
 *
 * These tests run two browser contexts simultaneously:
 * - Trainer: Monitors and sends adjustments
 * - Student: Performs workout and receives adjustments
 *
 * Prerequisites:
 * 1. E2E API server running: python -m tests.e2e.server (port 8001)
 * 2. Flutter Web app served: npx serve build/web -l 3000
 */

const API_URL = process.env.E2E_API_URL || 'http://localhost:8001';
const APP_URL = process.env.E2E_APP_URL || 'http://localhost:3000';

interface ScenarioData {
  trainer: {
    email: string;
    password: string;
    id: string;
    name: string;
    token: string;
  };
  student: {
    email: string;
    password: string;
    id: string;
    name: string;
    token: string;
  };
  organization_id: string;
  plan_id: string;
  assignment_id: string;
  workouts: Array<{
    id: string;
    name: string;
    label: string;
    exercises: Array<{
      id: string;
      name: string;
    }>;
  }>;
}

test.describe('Co-Training Multi-Actor Journey', () => {
  // Configure serial mode so tests share state and run in order
  test.describe.configure({ mode: 'serial' });

  let trainerContext: BrowserContext;
  let studentContext: BrowserContext;
  let trainerPage: Page;
  let studentPage: Page;
  let scenarioData: ScenarioData;

  test.beforeAll(async ({ browser }) => {
    // 1. Setup scenario in backend
    console.log('Setting up cotraining scenario...');
    const response = await fetch(`${API_URL}/test/setup/cotraining`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`Failed to setup scenario: ${error}`);
    }

    const result = await response.json();
    scenarioData = result.data;
    console.log('Scenario setup complete:', {
      trainer: scenarioData.trainer.email,
      student: scenarioData.student.email,
    });

    // 2. Create separate browser contexts for each actor
    trainerContext = await browser.newContext({
      viewport: { width: 1280, height: 720 },
    });
    studentContext = await browser.newContext({
      viewport: { width: 1280, height: 720 },
    });

    trainerPage = await trainerContext.newPage();
    studentPage = await studentContext.newPage();
  });

  test.afterAll(async () => {
    // Cleanup
    await trainerContext?.close();
    await studentContext?.close();

    // Reset database
    await fetch(`${API_URL}/test/reset`, { method: 'POST' });
    console.log('Test cleanup complete');
  });

  test('both actors can login with their credentials', async () => {
    // Login Trainer
    const trainerLogin = new LoginPage(trainerPage);
    await trainerLogin.goto();
    await trainerLogin.login(scenarioData.trainer.email, scenarioData.trainer.password);

    const trainerDashboard = new DashboardPage(trainerPage);
    await trainerDashboard.waitForLoad();
    expect(await trainerDashboard.isDisplayed()).toBe(true);

    // Login Student (in parallel context)
    const studentLogin = new LoginPage(studentPage);
    await studentLogin.goto();
    await studentLogin.login(scenarioData.student.email, scenarioData.student.password);

    const studentDashboard = new DashboardPage(studentPage);
    await studentDashboard.waitForLoad();
    expect(await studentDashboard.isDisplayed()).toBe(true);

    console.log('Both actors logged in successfully');
  });

  test('student can see assigned plan', async () => {
    const studentDashboard = new DashboardPage(studentPage);
    expect(await studentDashboard.hasAssignedPlan()).toBe(true);
  });

  test('student can start a workout', async () => {
    const studentDashboard = new DashboardPage(studentPage);

    // Student starts workout
    await studentDashboard.startWorkout(scenarioData.workouts[0].name);

    // Verify student is on the workout session page
    // The URL should contain 'active-workout' or similar, or we can check for exercise elements
    await studentPage.waitForTimeout(2000);

    // Check that we're on the workout page by looking for exercise-related elements
    const exerciseElement = studentPage.locator('flt-semantics').filter({
      hasText: /Supino|Crucifixo|Triceps|Completar|Série/i
    }).first();

    const isOnWorkoutPage = await exerciseElement.isVisible({ timeout: 5000 }).catch(() => false);
    expect(isOnWorkoutPage).toBe(true);

    console.log('Student successfully started workout');
  });

  // TODO: These tests require understanding the co-training flow better
  // The app may require selecting co-training mode BEFORE starting the workout
  // or there may be a specific UI flow for enabling co-training

  test.skip('trainer sees student activity (requires co-training mode)', async () => {
    const trainerDashboard = new DashboardPage(trainerPage);

    // This test requires the student to be in co-training mode
    // which needs further investigation of the app's UI flow
    await trainerPage.reload();
    const hasActiveStudent = await trainerDashboard.hasActiveStudent(scenarioData.student.name);
    expect(hasActiveStudent).toBe(true);

    console.log('Student started workout, visible to trainer');
  });

  test.skip('trainer joins session and sends adjustment (requires co-training mode)', async () => {
    const trainerDashboard = new DashboardPage(trainerPage);
    const trainerSession = new WorkoutSessionPage(trainerPage);
    const studentSession = new WorkoutSessionPage(studentPage);

    // Trainer joins the session
    await trainerDashboard.joinStudentSession(scenarioData.student.name);
    await trainerSession.waitForLoad();

    // Student should see trainer connected
    await studentPage.waitForTimeout(1000);
    expect(await studentSession.isTrainerConnected()).toBe(true);

    // Trainer sends weight adjustment
    await trainerSession.sendAdjustment(30, 'Boa execucao! Pode aumentar.');

    console.log('Trainer joined and sent adjustment');
  });

  test.skip('student receives and applies adjustment (requires co-training mode)', async () => {
    const studentSession = new WorkoutSessionPage(studentPage);

    // Wait for adjustment notification
    const received = await studentSession.waitForAdjustment(10000);
    expect(received).toBe(true);

    // Verify weight value
    const suggestedWeight = await studentSession.getAdjustmentWeight();
    expect(suggestedWeight).toBe(30);

    // Apply the adjustment
    await studentSession.applyAdjustment();

    console.log('Student received and applied adjustment');
  });
});

/**
 * Simpler smoke test that doesn't require full multi-actor coordination.
 * Useful for CI verification.
 */
test.describe('Co-Training Smoke Tests', () => {
  test('API health check', async ({ request }) => {
    const response = await request.get(`${API_URL}/test/health`);
    expect(response.ok()).toBe(true);

    const data = await response.json();
    expect(data.status).toBe('ok');
    expect(data.database).toBe('sqlite_in_memory');
  });

  test('can setup scenario', async ({ request }) => {
    const response = await request.post(`${API_URL}/test/setup/cotraining`);
    expect(response.ok()).toBe(true);

    const data = await response.json();
    expect(data.status).toBe('ok');
    expect(data.data.trainer.email).toBe('trainer@example.com');
    expect(data.data.student.email).toBe('student@example.com');
    expect(data.data.workouts.length).toBe(3);
  });

  test('can reset database', async ({ request }) => {
    // Setup first
    await request.post(`${API_URL}/test/setup/cotraining`);

    // Then reset
    const response = await request.post(`${API_URL}/test/reset`);
    expect(response.ok()).toBe(true);
  });
});
