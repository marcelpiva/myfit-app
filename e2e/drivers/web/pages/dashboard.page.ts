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
   *
   * Flow to show StartWorkoutSheet (for co-training option):
   * Navigate to /workouts/{workoutId} -> WorkoutDetailPage -> "Iniciar Treino" -> StartWorkoutSheet
   *
   * @param workoutName - Optional name to identify the workout (used for logging)
   * @param workoutId - Optional workout UUID for direct navigation to WorkoutDetailPage
   */
  async startWorkout(workoutName?: string, workoutId?: string) {
    await this.waitForFlutter();

    console.log('Starting workout flow (navigating to WorkoutDetailPage)...');
    console.log('Looking for workout:', workoutName || 'any');

    // If workoutId is provided, navigate directly to WorkoutDetailPage
    if (workoutId) {
      console.log('Navigating directly to WorkoutDetailPage with ID:', workoutId);
      // Flutter uses hash-based routing (e.g., /#/workouts/{id})
      const baseUrl = this.page.url().split('#')[0];
      await this.page.goto(`${baseUrl}#/workouts/${workoutId}`);
      await this.page.waitForTimeout(2000);
      await this.waitForFlutter();
    } else {
      // Step 1: Navigate to Treinos tab (if not already there)
      const treinosTab = this.page.locator('flt-semantics[role="button"]').filter({ hasText: /^Treinos$/i }).first();
      if (await treinosTab.isVisible({ timeout: 2000 }).catch(() => false)) {
        console.log('Clicking Treinos tab...');
        await treinosTab.click({ force: true });
        await this.page.waitForTimeout(1500);
        await this.waitForFlutter();
      }

      // Step 2: Click on the plan card to see workouts list
      const planCard = this.page.locator('flt-semantics').filter({ hasText: /E2E Test Plan|ABC Split/i }).first();
      if (await planCard.isVisible({ timeout: 3000 }).catch(() => false)) {
        console.log('Clicking plan card...');
        await planCard.click({ force: true });
        await this.page.waitForTimeout(1500);
        await this.waitForFlutter();
      }

      // Step 3: Find and click the specific workout card to navigate to WorkoutDetailPage
      // Important: We need to click on the workout NAME, not the "Iniciar Treino" button
      if (workoutName) {
        console.log('Looking for workout card:', workoutName);

        // Look for the workout card with specific name
        // The workout card should be a group or button element with the workout name
        const workoutCard = this.page.locator('flt-semantics').filter({ hasText: new RegExp(workoutName, 'i') }).first();

        if (await workoutCard.isVisible({ timeout: 3000 }).catch(() => false)) {
          console.log('Found workout card, clicking to go to WorkoutDetailPage...');
          await workoutCard.click({ force: true });
          await this.page.waitForTimeout(2000);
          await this.waitForFlutter();
        } else {
          // Try keyboard navigation
          console.log('Trying keyboard navigation to find workout...');
          await this.flutter.tabToAndActivate(
            (el) => el.text !== null && el.text.toLowerCase().includes(workoutName.toLowerCase())
          );
          await this.page.waitForTimeout(1500);
        }
      } else {
        // Click the first workout card
        const anyWorkout = this.page.locator('flt-semantics').filter({ hasText: /treino.*[abc]|peito|costas|pernas/i }).first();
        if (await anyWorkout.isVisible({ timeout: 3000 }).catch(() => false)) {
          await anyWorkout.click({ force: true });
          await this.page.waitForTimeout(1500);
        }
      }
    }

    // Step 4: We should now be on WorkoutDetailPage
    // Wait for the page to load and verify we're there
    await this.waitForFlutter();

    // Debug: log current URL and page elements
    console.log('Current URL after navigation:', this.page.url());

    // Look for WorkoutDetailPage indicators (exercise list, "Iniciar Treino" button)
    const detailPageIndicators = await this.page.locator('flt-semantics').filter({
      hasText: /exercícios|série|séries|iniciar treino|dificuldade/i
    }).first().isVisible({ timeout: 3000 }).catch(() => false);

    console.log('On WorkoutDetailPage:', detailPageIndicators);

    // Step 5: Click "Iniciar Treino" button on WorkoutDetailPage
    // This should open the StartWorkoutSheet with co-training options
    const iniciarButton = this.page.locator('flt-semantics[role="button"]').filter({ hasText: /iniciar treino/i }).first();
    if (await iniciarButton.isVisible({ timeout: 5000 }).catch(() => false)) {
      console.log('Clicking "Iniciar Treino" button to show StartWorkoutSheet...');
      await iniciarButton.click({ force: true });
      await this.page.waitForTimeout(2000);
      await this.waitForFlutter();
    } else {
      console.log('Warning: "Iniciar Treino" button not found on WorkoutDetailPage');
    }

    // Debug: Check if StartWorkoutSheet appeared
    const hasCoTrainingOption = await this.page.locator('flt-semantics').filter({
      hasText: /treinar com personal|com personal/i
    }).first().isVisible({ timeout: 2000 }).catch(() => false);

    const hasSoloOption = await this.page.locator('flt-semantics').filter({
      hasText: /treinar sozinho|sozinho/i
    }).first().isVisible({ timeout: 2000 }).catch(() => false);

    console.log('StartWorkoutSheet visible - Co-training option:', hasCoTrainingOption, 'Solo option:', hasSoloOption);

    console.log('Workout flow completed - ready for training mode selection');
  }

  /**
   * Select training mode from the StartWorkoutSheet.
   * This sheet appears after selecting a workout and offers "Treinar Sozinho" or "Treinar com Personal".
   *
   * @param withPersonal - If true, selects "Treinar com Personal" (co-training mode)
   */
  async selectTrainingMode(withPersonal: boolean = false) {
    await this.waitForFlutter();

    console.log(`Selecting training mode: ${withPersonal ? 'with Personal' : 'Solo'}`);

    // Wait for the StartWorkoutSheet to appear
    await this.page.waitForTimeout(1000);

    if (withPersonal) {
      // Look for "Treinar com Personal" option using semantic label
      // The button has semanticsLabel 'cotraining-mode'
      console.log('Looking for "Treinar com Personal" button...');

      // First try keyboard navigation which is most reliable for Flutter Web
      await this.flutter.focusSemanticsHost();

      // Tab through to find the co-training button, logging each step
      let found = false;
      for (let i = 0; i < 25; i++) {
        await this.page.keyboard.press('Tab');
        await this.page.waitForTimeout(100);

        const elementInfo = await this.flutter.getFocusedElementInfo();
        const text = elementInfo?.text?.toLowerCase() || '';
        const role = elementInfo?.role || 'unknown';

        // Debug: log what we're tabbing through
        if (i < 10 || text.includes('treinar') || text.includes('personal') || text.includes('cotraining')) {
          console.log(`Tab ${i}: role=${role}, text="${text.substring(0, 60)}..."`);
        }

        if (text.includes('cotraining-mode') || (text.includes('treinar') && text.includes('personal'))) {
          console.log(`Found co-training button at Tab ${i}!`);
          await this.page.keyboard.press('Enter');
          found = true;
          await this.page.waitForTimeout(3000);
          break;
        }
      }

      if (!found) {
        console.log('Keyboard navigation failed after 25 tabs');

        // Try using Playwright's built-in click with multiple strategies
        const buttonLocator = this.page.locator('flt-semantics[role="button"]').filter({
          hasText: /cotraining-mode/i
        }).first();

        if (await buttonLocator.isVisible({ timeout: 2000 }).catch(() => false)) {
          console.log('Trying Playwright click on cotraining-mode button...');
          try {
            // Try dispatchEvent
            await buttonLocator.dispatchEvent('click');
            await this.page.waitForTimeout(2000);
          } catch (e) {
            console.log('dispatchEvent failed:', e);
          }
        }
      }

      // Should now be on WaitingForTrainerPage
      // Wait for navigation or "Aguardando Personal" text
      console.log('Checking for WaitingForTrainerPage...');
      const url = this.page.url();
      console.log('Current URL after clicking co-training:', url);

      const waitingIndicator = this.page.locator('flt-semantics').filter({
        hasText: /aguardando|waiting|conectando|criando sessão/i
      }).first();

      if (await waitingIndicator.isVisible({ timeout: 5000 }).catch(() => false)) {
        console.log('Successfully entered waiting for trainer mode');
      } else if (url.includes('waiting-trainer')) {
        console.log('Navigated to WaitingForTrainerPage via URL');
      } else {
        console.log('Warning: Not on WaitingForTrainerPage after clicking co-training');
      }
    } else {
      // Look for "Treinar Sozinho" option
      const soloOption = this.page.locator('flt-semantics[role="button"]').filter({
        hasText: /start-workout-solo|treinar sozinho/i
      }).first();

      if (await soloOption.isVisible({ timeout: 5000 }).catch(() => false)) {
        console.log('Found "Treinar Sozinho" button, using keyboard navigation...');
        const found = await this.flutter.tabToAndActivate(
          (el) => el.text !== null && /start-workout-solo|treinar sozinho/i.test(el.text)
        );

        if (!found) {
          await soloOption.click({ force: true });
        }

        await this.page.waitForTimeout(1500);
      } else {
        console.log('Trying keyboard navigation for solo option...');
        await this.flutter.tabToAndActivate(
          (el) => el.text !== null && /start-workout-solo|treinar sozinho/i.test(el.text)
        );
        await this.page.waitForTimeout(1500);
      }
    }

    await this.page.waitForTimeout(500);
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
