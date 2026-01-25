import { Page, expect } from '@playwright/test';
import { FlutterHelper } from './flutter.helper';

/**
 * Dashboard Page Object.
 *
 * Handles both Trainer and Student dashboard views.
 * Uses Flutter Web semantic selectors and keyboard navigation.
 */
export class DashboardPage {
  private flutter: FlutterHelper;

  constructor(private page: Page) {
    this.flutter = new FlutterHelper(page);
  }

  /**
   * Wait for Flutter to be ready and enable accessibility.
   */
  async waitForFlutter() {
    await this.flutter.waitForFlutter();
  }

  /**
   * Get Flutter semantic element by label.
   */
  private flutterElement(label: string) {
    return this.flutter.flutterElement(label);
  }

  /**
   * Wait for dashboard to load, handling org-selector if needed.
   */
  async waitForLoad() {
    await this.page.waitForURL(/dashboard|home|org-selector/);
    await this.waitForFlutter();

    // If we're on org-selector, select the first organization
    if (this.page.url().includes('org-selector')) {
      await this.selectOrganization();
    }
  }

  /**
   * Check if we're on the dashboard.
   */
  async isDisplayed(): Promise<boolean> {
    const url = this.page.url();
    return url.includes('dashboard') || url.includes('home');
  }

  /**
   * Get the current user's name from the dashboard.
   */
  async getUserName(): Promise<string | null> {
    try {
      const nameElement = this.flutterElement('user-name')
        .or(this.page.locator('flt-semantics[role="heading"]').first());
      return await nameElement.textContent();
    } catch {
      return null;
    }
  }

  // ==================
  // Trainer-specific methods
  // ==================

  /**
   * Check if active students section shows a specific student.
   */
  async hasActiveStudent(studentName: string): Promise<boolean> {
    try {
      await this.waitForFlutter();

      // Refresh to get latest data
      await this.page.reload();
      await this.waitForFlutter();

      // Look for the active-students container or student card
      const studentCard = this.page.locator('flt-semantics').filter({ hasText: studentName });

      return await studentCard.isVisible({ timeout: 5000 });
    } catch {
      return false;
    }
  }

  /**
   * Click to join a student's co-training session.
   */
  async joinStudentSession(studentName: string) {
    await this.waitForFlutter();

    // Find and click the student card using keyboard navigation
    const found = await this.flutter.tabToAndActivate(
      (el) => el.text !== null && el.text.includes(studentName)
    );

    if (!found) {
      // Fallback: try direct click
      const studentCard = this.page.locator('flt-semantics').filter({ hasText: studentName });
      await studentCard.click();
    }

    await this.page.waitForTimeout(500);

    // Look for join session button
    const joinFound = await this.flutter.clickButton(/acompanhar|join|entrar/i);

    if (!joinFound) {
      // Fallback: direct locator
      const joinButton = this.flutterElement('join-session')
        .or(this.page.locator('flt-semantics[role="button"]').filter({ hasText: /acompanhar|join/i }));
      await joinButton.click();
    }
  }

  // ==================
  // Student-specific methods
  // ==================

  /**
   * Check if student has an assigned plan.
   */
  async hasAssignedPlan(): Promise<boolean> {
    try {
      await this.waitForFlutter();

      // Look for plan-related elements - the UI shows:
      // - A button with "NOVO E2E Test Plan - ABC Split Ver"
      // - "Treino de Hoje" section heading
      // Use a specific selector for the plan card (button role with NOVO text)
      const planButton = this.page.locator('flt-semantics[role="button"]').filter({ hasText: 'NOVO' }).first();
      const treinoHoje = this.page.locator('flt-semantics').filter({ hasText: 'Treino de Hoje' }).first();

      const hasPlanButton = await planButton.isVisible({ timeout: 3000 }).catch(() => false);
      const hasTreinoHoje = await treinoHoje.isVisible({ timeout: 3000 }).catch(() => false);

      console.log('hasAssignedPlan - Plan button visible:', hasPlanButton, 'Treino de Hoje visible:', hasTreinoHoje);
      return hasPlanButton || hasTreinoHoje;
    } catch (e) {
      console.log('hasAssignedPlan - Error:', e);
      return false;
    }
  }

  /**
   * Start a workout from the dashboard.
   * Flow: Home -> Plan Card -> Workout List -> Start Workout
   */
  async startWorkout(workoutName?: string) {
    await this.waitForFlutter();

    console.log('Starting workout flow...');
    console.log('Looking for workout:', workoutName || 'any');

    // Step 1: Navigate to Treinos tab (if not already there)
    const treinosTab = this.page.locator('flt-semantics[role="button"]').filter({ hasText: /^Treinos$/i }).first();
    if (await treinosTab.isVisible({ timeout: 2000 }).catch(() => false)) {
      console.log('Clicking Treinos tab...');
      await treinosTab.click({ force: true });
      await this.page.waitForTimeout(1500);
      await this.waitForFlutter();
    }

    // Step 2: Click on the plan card to see workouts
    // Look for the plan that contains our workout
    const planCard = this.page.locator('flt-semantics').filter({ hasText: /E2E Test Plan|ABC Split/i }).first();
    if (await planCard.isVisible({ timeout: 3000 }).catch(() => false)) {
      console.log('Clicking plan card...');
      await planCard.click({ force: true });
      await this.page.waitForTimeout(1500);
      await this.waitForFlutter();
    }

    // Step 3: Find and click the specific workout
    if (workoutName) {
      console.log('Looking for workout:', workoutName);
      // Try to find the workout by name
      const workoutCard = this.page.locator('flt-semantics').filter({ hasText: workoutName }).first();
      if (await workoutCard.isVisible({ timeout: 3000 }).catch(() => false)) {
        console.log('Found workout card, clicking...');
        await workoutCard.click({ force: true });
        await this.page.waitForTimeout(1500);
        await this.waitForFlutter();
      } else {
        // Try keyboard navigation
        console.log('Trying keyboard navigation to find workout...');
        await this.flutter.tabToAndActivate(
          (el) => el.text !== null && el.text.toLowerCase().includes(workoutName.toLowerCase())
        );
      }
    } else {
      // Click the first workout card
      const anyWorkout = this.page.locator('flt-semantics').filter({ hasText: /treino.*[abc]|peito|costas|pernas/i }).first();
      if (await anyWorkout.isVisible({ timeout: 3000 }).catch(() => false)) {
        await anyWorkout.click({ force: true });
        await this.page.waitForTimeout(1000);
      }
    }

    // Step 4: Click "Iniciar Treino" button (opens modal to select workout)
    const iniciarButton = this.page.locator('flt-semantics[role="button"]').filter({ hasText: /iniciar treino/i }).first();
    if (await iniciarButton.isVisible({ timeout: 3000 }).catch(() => false)) {
      console.log('Clicking Iniciar Treino button...');
      await iniciarButton.click({ force: true });
      await this.page.waitForTimeout(1500);
      await this.waitForFlutter();
    }

    // Step 5: A modal appears "Escolha qual treino deseja iniciar" - select the workout using keyboard
    // Use Tab navigation to find workout items in the modal
    console.log('Navigating modal to select workout...');
    await this.flutter.focusSemanticsHost();

    // Tab through to find the workout we want
    let workoutFound = false;
    for (let i = 0; i < 15; i++) {
      await this.page.keyboard.press('Tab');
      await this.page.waitForTimeout(200);

      const elementInfo = await this.flutter.getFocusedElementInfo();
      if (elementInfo?.text) {
        console.log(`Tab ${i}: focused on "${elementInfo.text.substring(0, 50)}..."`);

        // Look for the workout we want (Treino A, or matching workoutName)
        if (workoutName && elementInfo.text.toLowerCase().includes(workoutName.toLowerCase())) {
          console.log('Found target workout, pressing Enter...');
          await this.page.keyboard.press('Enter');
          await this.page.waitForTimeout(1000);
          workoutFound = true;
          break;
        } else if (!workoutName && /treino a|peito/i.test(elementInfo.text)) {
          console.log('Found first workout (Treino A), pressing Enter...');
          await this.page.keyboard.press('Enter');
          await this.page.waitForTimeout(1000);
          workoutFound = true;
          break;
        }
      }
    }

    if (!workoutFound) {
      console.log('Workout not found via Tab, trying direct click...');
      // Fallback: try clicking the workout option directly
      const workoutOption = this.page.locator('flt-semantics').filter({ hasText: /Treino A.*Peito/i }).first();
      if (await workoutOption.isVisible({ timeout: 2000 }).catch(() => false)) {
        await workoutOption.click({ force: true });
        await this.page.waitForTimeout(1000);
      }
    }

    // Step 6: After selecting workout, there might be another screen or the session starts directly
    // Check if there's an "Iniciar Treino" confirmation button
    await this.page.waitForTimeout(500);
    const confirmButton = this.page.locator('flt-semantics[role="button"]').filter({ hasText: /^iniciar treino$/i }).first();
    if (await confirmButton.isVisible({ timeout: 3000 }).catch(() => false)) {
      console.log('Clicking confirm Iniciar Treino button...');
      await confirmButton.click({ force: true });
      await this.page.waitForTimeout(1500);
    }

    await this.page.waitForTimeout(500);
    console.log('Workout start flow completed');
  }

  /**
   * Enable co-training mode when starting a workout.
   */
  async enableCotrainingMode() {
    await this.page.waitForTimeout(500);

    const found = await this.flutter.clickButton(/treinar com personal|co-training|com personal/i);

    if (!found) {
      const cotrainingButton = this.flutterElement('cotraining-mode')
        .or(this.page.locator('flt-semantics[role="button"]').filter({ hasText: /treinar com personal/i }));
      await cotrainingButton.click({ force: true });
    }
  }

  /**
   * Start workout in solo mode.
   */
  async startWorkoutSolo() {
    await this.page.waitForTimeout(500);

    const found = await this.flutter.clickButton(/treinar sozinho|solo|sem personal/i);

    if (!found) {
      const soloButton = this.flutterElement('start-workout-solo')
        .or(this.page.locator('flt-semantics[role="button"]').filter({ hasText: /treinar sozinho/i }));
      await soloButton.click({ force: true });
    }
  }

  /**
   * Select organization (for org selector page).
   */
  async selectOrganization(orgName?: string) {
    await this.waitForFlutter();

    // Flutter Web: use keyboard navigation through the accessibility tree
    await this.page.waitForTimeout(500);

    // Focus the semantics host
    await this.flutter.focusSemanticsHost();

    // Tab through elements until we find a group element (org card)
    for (let i = 0; i < 15; i++) {
      await this.page.keyboard.press('Tab');
      await this.page.waitForTimeout(200);

      const elementInfo = await this.flutter.getFocusedElementInfo();

      // Check if we've focused an org card (group)
      if (elementInfo?.role === 'group') {
        // If a specific org was requested, check if this is it
        if (orgName) {
          if (elementInfo.text?.toLowerCase().includes(orgName.toLowerCase())) {
            await this.page.keyboard.press('Enter');
            break;
          }
          // Not the right org, continue tabbing
          continue;
        }

        // No specific org requested, select first one
        await this.page.keyboard.press('Enter');
        break;
      }
    }

    // Wait for navigation
    await this.page.waitForTimeout(1000);
    await this.page.waitForURL(/home|dashboard/, { timeout: 10000 });
  }
}
