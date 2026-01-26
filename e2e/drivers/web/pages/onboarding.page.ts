import { Page, expect } from '@playwright/test';
import { FlutterHelper } from './flutter.helper';

/**
 * Onboarding Page Object for MyFit Flutter Web app.
 *
 * Handles:
 * - Trainer onboarding flow (welcome, invite, plan, templates, complete)
 * - Student onboarding flow (welcome, goal, experience, body, frequency, injuries, complete)
 * - CREF input with mask validation
 */
export class OnboardingPage {
  private flutter: FlutterHelper;

  constructor(private page: Page) {
    this.flutter = new FlutterHelper(page);
  }

  /**
   * Wait for onboarding page to load.
   */
  async waitForLoad() {
    await this.flutter.waitForFlutter();
    // Wait for onboarding content
    await this.page.waitForTimeout(1000);
  }

  /**
   * Check if on welcome step (first step of onboarding).
   */
  async isOnWelcomeStep(): Promise<boolean> {
    try {
      const hasWelcome = await this.page.locator('flt-semantics').filter({ hasText: /bem-vindo|welcome/i }).count() > 0;
      return hasWelcome;
    } catch {
      return false;
    }
  }

  /**
   * Check if onboarding page is displayed.
   */
  async isDisplayed(): Promise<boolean> {
    try {
      // Check for onboarding indicators
      const hasSteps = await this.page.locator('flt-semantics').filter({ hasText: /passo|step|próximo|continuar/i }).count() > 0;
      return hasSteps;
    } catch {
      return false;
    }
  }

  /**
   * Click "Próximo" or "Continuar" to go to next step.
   */
  async clickNext() {
    const button = this.page.locator('flt-semantics[role="button"]').filter({ hasText: /próximo|continuar/i }).first();
    await button.waitFor({ state: 'visible', timeout: 10000 });
    await button.click();
    await this.page.waitForTimeout(800);
  }

  /**
   * Click "Pular" to skip current step.
   */
  async clickSkip() {
    const button = this.page.locator('flt-semantics[role="button"]').filter({ hasText: /pular|skip/i });
    if (await button.isVisible({ timeout: 2000 })) {
      await button.click();
      await this.page.waitForTimeout(500);
    }
  }

  /**
   * Click "Concluir" or "Finalizar" to complete onboarding.
   */
  async clickComplete() {
    const button = this.page.locator('flt-semantics[role="button"]').filter({ hasText: /concluir|finalizar|complete/i });
    await button.waitFor({ state: 'visible', timeout: 10000 });
    await button.click();
    await this.page.waitForTimeout(1000);
  }

  /**
   * Fill CREF field (trainer onboarding).
   * Expected format: 000000-X where X is G, B, L, or F
   */
  async fillCref(cref: string) {
    // Find CREF input
    const crefInput = this.page.locator('flt-semantics input[data-semantics-role="text-field"]:not([disabled])').first();
    await crefInput.waitFor({ state: 'visible', timeout: 10000 });
    await crefInput.click();
    await crefInput.fill(cref);
    await this.page.waitForTimeout(300);
  }

  /**
   * Select state/UF dropdown (trainer onboarding).
   */
  async selectState(state: string) {
    // Find the dropdown
    const dropdown = this.page.locator('flt-semantics[role="combobox"]').first();
    if (await dropdown.isVisible({ timeout: 2000 })) {
      await dropdown.click();
      await this.page.waitForTimeout(300);

      // Select state option
      const option = this.page.locator('flt-semantics[role="option"]').filter({ hasText: new RegExp(state, 'i') });
      if (await option.isVisible({ timeout: 2000 })) {
        await option.click();
        await this.page.waitForTimeout(300);
      }
    }
  }

  /**
   * Select fitness goal (student onboarding).
   */
  async selectFitnessGoal(goal: 'perder peso' | 'ganhar massa' | 'saúde' | 'condicionamento') {
    const goalMap: Record<string, RegExp> = {
      'perder peso': /perder peso|emagrecer/i,
      'ganhar massa': /ganhar massa|hipertrofia/i,
      'saúde': /saúde|bem-estar/i,
      'condicionamento': /condicionamento|resistência/i,
    };

    const card = this.page.locator('flt-semantics[role="button"]').filter({ hasText: goalMap[goal] });
    if (await card.isVisible({ timeout: 3000 })) {
      await card.click();
      await this.page.waitForTimeout(300);
    }
  }

  /**
   * Select experience level (student onboarding).
   */
  async selectExperience(level: 'iniciante' | 'intermediário' | 'avançado') {
    const card = this.page.locator('flt-semantics[role="button"]').filter({ hasText: new RegExp(level, 'i') });
    if (await card.isVisible({ timeout: 3000 })) {
      await card.click();
      await this.page.waitForTimeout(300);
    }
  }

  /**
   * Fill physical data (student onboarding).
   */
  async fillPhysicalData(weight: string, height: string) {
    const inputs = this.page.locator('flt-semantics input[data-semantics-role="text-field"]:not([disabled])');

    // Weight input (first)
    const weightInput = inputs.nth(0);
    if (await weightInput.isVisible({ timeout: 3000 })) {
      await weightInput.click();
      await weightInput.fill(weight);
      await this.page.waitForTimeout(200);
    }

    // Height input (second)
    const heightInput = inputs.nth(1);
    if (await heightInput.isVisible({ timeout: 3000 })) {
      await heightInput.click();
      await heightInput.fill(height);
      await this.page.waitForTimeout(200);
    }
  }

  /**
   * Select weekly training frequency (student onboarding).
   */
  async selectFrequency(days: number) {
    const frequency = this.page.locator('flt-semantics[role="button"]').filter({ hasText: new RegExp(`${days}.*vez|${days}x`, 'i') });
    if (await frequency.isVisible({ timeout: 3000 })) {
      await frequency.click();
      await this.page.waitForTimeout(300);
    }
  }

  /**
   * Complete trainer onboarding flow quickly.
   */
  async completeTrainerOnboarding() {
    await this.waitForLoad();

    // Step 1: Welcome - click next
    await this.clickNext();

    // Step 2: CREF (optional, can skip or fill)
    await this.clickSkip().catch(() => this.clickNext());

    // Step 3: Invite student (skip)
    await this.clickSkip().catch(() => this.clickNext());

    // Step 4: Create plan (skip)
    await this.clickSkip().catch(() => this.clickNext());

    // Step 5: Templates (skip)
    await this.clickSkip().catch(() => this.clickNext());

    // Final: Complete
    await this.clickComplete().catch(() => this.clickNext());
  }

  /**
   * Complete student onboarding flow quickly.
   */
  async completeStudentOnboarding() {
    await this.waitForLoad();

    // Step 1: Welcome
    await this.clickNext();

    // Step 2: Fitness goal - select first available
    await this.page.locator('flt-semantics[role="button"]').first().click().catch(() => {});
    await this.page.waitForTimeout(300);
    await this.clickNext().catch(() => {});

    // Continue clicking next/skip through remaining steps
    for (let i = 0; i < 5; i++) {
      await this.clickSkip().catch(async () => {
        await this.clickNext().catch(() => {});
      });
    }

    // Complete
    await this.clickComplete().catch(() => {});
  }

  /**
   * Check if redirected to home/dashboard after onboarding.
   */
  async isOnDashboard(): Promise<boolean> {
    try {
      await this.page.waitForURL(/home|dashboard|trainer/, { timeout: 10000 });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Get current step indicator text.
   */
  async getCurrentStepText(): Promise<string | null> {
    try {
      const stepIndicator = this.page.locator('flt-semantics').filter({ hasText: /passo \d|step \d/i });
      if (await stepIndicator.isVisible({ timeout: 2000 })) {
        return await stepIndicator.textContent();
      }
      return null;
    } catch {
      return null;
    }
  }
}
