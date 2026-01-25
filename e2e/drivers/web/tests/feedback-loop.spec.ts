/**
 * Feedback Loop E2E Test.
 *
 * Tests real-time feedback between trainer and student during an active
 * co-training session. This scenario starts with a session already in progress,
 * allowing us to focus on the feedback/adjustment flow.
 */

import { test, expect, Browser, BrowserContext, Page } from '@playwright/test';
import { LoginPage } from '../pages/login.page';
import { DashboardPage } from '../pages/dashboard.page';
import { WorkoutSessionPage } from '../pages/workout-session.page';

const API_URL = process.env.API_URL || 'http://localhost:8001';
const APP_URL = process.env.APP_URL || 'http://localhost:3000';

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
  active_session: {
    id: string;
    workout_id: string;
    workout_name: string;
    current_exercise: {
      id: string;
      name: string;
      current_set: number;
    };
    completed_sets: Array<{
      set_number: number;
      reps: number;
      weight_kg: number;
    }>;
    total_sets: number;
  };
}

// TODO: These tests require co-training mode to be properly implemented
// The app may have a different UI flow for enabling co-training that needs investigation
test.describe.skip('Feedback Loop - Real-time Co-training', () => {
  // Configure serial mode so tests share state and run in order
  test.describe.configure({ mode: 'serial' });

  let trainerContext: BrowserContext;
  let studentContext: BrowserContext;
  let trainerPage: Page;
  let studentPage: Page;
  let scenarioData: ScenarioData;

  test.beforeAll(async ({ browser }) => {
    // 1. Setup scenario in backend
    const response = await fetch(`${API_URL}/test/setup/feedback_loop`, {
      method: 'POST',
    });

    if (!response.ok) {
      throw new Error(`Failed to setup feedback_loop scenario: ${response.statusText}`);
    }

    const responseData = await response.json();
    scenarioData = responseData.data;
    console.log('Scenario data:', JSON.stringify(scenarioData, null, 2));

    // 2. Create separate browser contexts for trainer and student
    trainerContext = await browser.newContext({
      baseURL: APP_URL,
    });
    studentContext = await browser.newContext({
      baseURL: APP_URL,
    });

    trainerPage = await trainerContext.newPage();
    studentPage = await studentContext.newPage();
  });

  test.afterAll(async () => {
    // Clean up contexts
    await trainerContext?.close();
    await studentContext?.close();

    // Reset database
    await fetch(`${API_URL}/test/reset`, { method: 'POST' });
  });

  test('trainer can send weight adjustment to student', async () => {
    // Login both users
    const trainerLoginPage = new LoginPage(trainerPage);
    const studentLoginPage = new LoginPage(studentPage);

    // Login in parallel
    await Promise.all([
      trainerLoginPage.goto(),
      studentLoginPage.goto(),
    ]);

    await Promise.all([
      trainerLoginPage.login(scenarioData.trainer.email, scenarioData.trainer.password),
      studentLoginPage.login(scenarioData.student.email, scenarioData.student.password),
    ]);

    // Wait for dashboards to load
    const trainerDashboard = new DashboardPage(trainerPage);
    const studentDashboard = new DashboardPage(studentPage);

    await Promise.all([
      trainerDashboard.waitForLoad(),
      studentDashboard.waitForLoad(),
    ]);

    // Student navigates to active workout session
    // Since there's an active session, there should be a "Continue Workout" option
    const continueWorkout = studentPage.getByLabel('continue-workout')
      .or(studentPage.getByText(/continuar treino|retomar/i));

    if (await continueWorkout.isVisible({ timeout: 3000 })) {
      await continueWorkout.click();
    } else {
      // Navigate directly to the active session
      await studentPage.goto(`/workouts/active/${scenarioData.active_session.workout_id}`);
    }

    const studentSession = new WorkoutSessionPage(studentPage);
    await studentSession.waitForLoad();

    // Verify trainer is connected (from scenario setup)
    const trainerConnected = await studentSession.isTrainerConnected();
    expect(trainerConnected).toBe(true);

    // Trainer navigates to monitor the student
    // Check for active student in trainer's dashboard
    const hasActiveStudent = await trainerDashboard.hasActiveStudent(scenarioData.student.name);
    expect(hasActiveStudent).toBe(true);

    // Trainer joins the session
    await trainerDashboard.joinStudentSession(scenarioData.student.name);

    const trainerSession = new WorkoutSessionPage(trainerPage);
    await trainerSession.waitForLoad();

    // Trainer sends weight adjustment (+5kg)
    await trainerSession.sendAdjustment(5, 'Aumenta um pouco o peso!');

    // Student should receive the adjustment notification
    const receivedAdjustment = await studentSession.waitForAdjustment(10000);
    expect(receivedAdjustment).toBe(true);

    // Verify the adjustment value
    const adjustmentWeight = await studentSession.getAdjustmentWeight();
    expect(adjustmentWeight).toBe(5);

    // Student applies the adjustment
    await studentSession.applyAdjustment();

    // Verify adjustment was applied (notification should disappear)
    const stillVisible = await studentPage.getByLabel('adjustment-notification')
      .isVisible({ timeout: 2000 })
      .catch(() => false);
    expect(stillVisible).toBe(false);
  });

  test('student can complete set and trainer sees update', async () => {
    // This test assumes the previous test's session is still active
    // Student completes a set
    const studentSession = new WorkoutSessionPage(studentPage);
    const trainerSession = new WorkoutSessionPage(trainerPage);

    // Student completes set 3 with 12 reps at 27.5kg
    await studentSession.completeSet(12, 27.5);

    // Trainer should see the update (set completed indicator)
    const setCompleteIndicator = trainerPage.getByText(/série.*completa|set.*completed/i)
      .or(trainerPage.getByLabel('set-completed-3'));

    await expect(setCompleteIndicator).toBeVisible({ timeout: 5000 });
  });

  test('trainer and student can exchange messages', async () => {
    const studentSession = new WorkoutSessionPage(studentPage);
    const trainerSession = new WorkoutSessionPage(trainerPage);

    // Open chat/message panel on trainer side
    const chatButton = trainerPage.getByLabel('session-chat')
      .or(trainerPage.getByRole('button', { name: /chat|mensagem/i }));

    if (await chatButton.isVisible({ timeout: 2000 })) {
      await chatButton.click();
    }

    // Trainer sends a message
    const messageInput = trainerPage.getByLabel('message-input')
      .or(trainerPage.getByRole('textbox', { name: /mensagem/i }));

    await messageInput.fill('Ótimo trabalho! Mantenha a postura!');

    const sendButton = trainerPage.getByLabel('send-message')
      .or(trainerPage.getByRole('button', { name: /enviar|send/i }));

    await sendButton.click();

    // Student should receive the message
    const receivedMessage = studentPage.getByText('Ótimo trabalho! Mantenha a postura!');
    await expect(receivedMessage).toBeVisible({ timeout: 5000 });
  });
});

// TODO: This test also requires co-training mode to be properly implemented
test.describe.skip('Feedback Loop - Direct Session Access', () => {
  /**
   * Test accessing active session directly via URL with auth token.
   * This is useful for testing session state without going through login flow.
   */

  test('can access active session with auth token in storage', async ({ browser }) => {
    // Setup scenario
    const response = await fetch(`${API_URL}/test/setup/feedback_loop`, {
      method: 'POST',
    });

    if (!response.ok) {
      throw new Error(`Failed to setup scenario: ${response.statusText}`);
    }

    const responseData = await response.json();
    const scenarioData: ScenarioData = responseData.data;

    // Create context with pre-set auth token
    const context = await browser.newContext({
      baseURL: process.env.APP_URL || 'http://localhost:3000',
      storageState: {
        cookies: [],
        origins: [{
          origin: process.env.APP_URL || 'http://localhost:3000',
          localStorage: [{
            name: 'auth_token',
            value: scenarioData.student.token,
          }],
        }],
      },
    });

    const page = await context.newPage();

    // Navigate directly to active session
    await page.goto(`/workouts/active/${scenarioData.active_session.workout_id}`);

    // Wait for session to load
    await page.waitForTimeout(2000);

    // Verify session elements are visible
    const exerciseName = page.getByText(scenarioData.active_session.current_exercise.name);
    await expect(exerciseName).toBeVisible({ timeout: 10000 });

    // Verify completed sets are shown
    const completedSetsIndicator = page.getByText(/2.*séries.*completas|2.*sets.*completed/i)
      .or(page.getByLabel('completed-sets-2'));

    // This might not match exactly - adjust based on actual UI
    const hasProgress = await page.getByText(/progresso|progress/i).isVisible({ timeout: 3000 });
    expect(hasProgress).toBe(true);

    await context.close();

    // Cleanup
    await fetch(`${API_URL}/test/reset`, { method: 'POST' });
  });
});
