import { Page, expect } from '@playwright/test';
import { FlutterHelper } from './flutter.helper';

/**
 * Workout Session Page Object.
 *
 * Handles the active workout view for both Student and Trainer in co-training.
 * Uses Flutter Web semantic selectors and keyboard navigation.
 */
export class WorkoutSessionPage {
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
   * Wait for session to load.
   */
  async waitForLoad() {
    await this.waitForFlutter();

    // Debug: log elements to understand the page structure
    console.log('Waiting for workout session...');
    await this.flutter.debugElements();

    // Look for session-related elements
    const sessionElement = this.flutterElement('workout-session')
      .or(this.page.locator('flt-semantics').filter({ hasText: /treino ativo|exercício|série|supino|rosca|agachamento/i }));

    await sessionElement.waitFor({ timeout: 15000 });
  }

  /**
   * Check if we're on the WaitingForTrainerPage.
   */
  async isOnWaitingForTrainerPage(): Promise<boolean> {
    try {
      const waitingIndicator = this.page.locator('flt-semantics').filter({
        hasText: /aguardando personal|waiting for trainer/i
      }).first();
      return await waitingIndicator.isVisible({ timeout: 3000 });
    } catch {
      return false;
    }
  }

  /**
   * Wait for trainer to connect (on WaitingForTrainerPage).
   * Returns true if trainer connected, false if timeout.
   */
  async waitForTrainerToConnect(timeoutMs: number = 30000): Promise<boolean> {
    console.log('Waiting for trainer to connect...');

    const startTime = Date.now();

    while (Date.now() - startTime < timeoutMs) {
      // Check for "Personal conectado" success message
      const connectedIndicator = this.page.locator('flt-semantics').filter({
        hasText: /personal conectado|trainer connected|conectado/i
      }).first();

      if (await connectedIndicator.isVisible({ timeout: 1000 }).catch(() => false)) {
        console.log('Trainer connected!');
        return true;
      }

      // Check if we've navigated to active workout (URL contains active or sessionId)
      const url = this.page.url();
      if (url.includes('active') && url.includes('sessionId')) {
        console.log('Navigated to active workout page with sessionId');
        return true;
      }

      await this.page.waitForTimeout(2000);
    }

    console.log('Timeout waiting for trainer to connect');
    return false;
  }

  /**
   * Click "Treinar Sozinho" fallback button on WaitingForTrainerPage.
   */
  async fallbackToSoloTraining() {
    console.log('Falling back to solo training...');

    const soloButton = this.page.locator('flt-semantics[role="button"]').filter({
      hasText: /treinar sozinho|solo|continuar sozinho/i
    }).first();

    if (await soloButton.isVisible({ timeout: 3000 }).catch(() => false)) {
      await soloButton.click({ force: true });
      await this.page.waitForTimeout(1000);
    }
  }

  /**
   * Select co-training mode from StartWorkoutSheet and enter waiting state.
   */
  async selectCoTrainingMode() {
    console.log('Selecting co-training mode from StartWorkoutSheet...');

    // Look for "Treinar com Personal" option in the StartWorkoutSheet
    const coTrainingOption = this.page.locator('flt-semantics').filter({
      hasText: /treinar com personal|com personal/i
    }).first();

    if (await coTrainingOption.isVisible({ timeout: 5000 }).catch(() => false)) {
      console.log('Found "Treinar com Personal" option, clicking...');
      await coTrainingOption.click({ force: true });
      await this.page.waitForTimeout(1500);

      // Should now be on WaitingForTrainerPage
      const isWaiting = await this.isOnWaitingForTrainerPage();
      if (isWaiting) {
        console.log('Successfully entered WaitingForTrainerPage');
      } else {
        console.log('Not on WaitingForTrainerPage, checking URL...');
        console.log('Current URL:', this.page.url());
      }
    } else {
      // Try keyboard navigation
      console.log('Trying keyboard navigation for co-training option...');
      const found = await this.flutter.tabToAndActivate(
        (el) => el.text !== null && /treinar com personal|com personal/i.test(el.text)
      );

      if (found) {
        await this.page.waitForTimeout(1500);
      } else {
        console.log('Co-training option not found');
      }
    }
  }

  /**
   * Check if trainer is connected to the session.
   */
  async isTrainerConnected(): Promise<boolean> {
    try {
      await this.waitForFlutter();

      const indicator = this.flutterElement('trainer-connected')
        .or(this.page.locator('flt-semantics').filter({ hasText: /personal conectado|trainer connected|personal online/i }));

      return await indicator.isVisible({ timeout: 5000 });
    } catch {
      return false;
    }
  }

  /**
   * Get the current exercise name.
   */
  async getCurrentExercise(): Promise<string | null> {
    try {
      const exerciseElement = this.flutterElement('current-exercise')
        .or(this.page.locator('flt-semantics[role="heading"]').filter({ hasText: /supino|rosca|agachamento|puxada|remada|triceps|leg|desenvolvimento/i }));
      return await exerciseElement.textContent();
    } catch {
      return null;
    }
  }

  /**
   * Complete a set.
   */
  async completeSet(reps: number, weight: number) {
    console.log(`Completing set: ${reps} reps @ ${weight}kg`);

    // Find and fill reps input
    const repsInput = this.page.locator('flt-semantics input[type="number"]').first()
      .or(this.page.locator('flt-semantics input').first());

    if (await repsInput.isVisible({ timeout: 2000 })) {
      await repsInput.click();
      await repsInput.fill('');
      await repsInput.fill(reps.toString());
      await this.page.waitForTimeout(200);
    } else {
      // Try keyboard navigation
      const found = await this.flutter.tabToElement((el) => el.role === 'spinbutton' || el.role === 'textbox');
      if (found) {
        await this.page.keyboard.type(reps.toString());
      }
    }

    // Find and fill weight input
    const weightInput = this.page.locator('flt-semantics input[type="number"]').nth(1)
      .or(this.page.locator('flt-semantics input').nth(1));

    if (await weightInput.isVisible({ timeout: 2000 })) {
      await weightInput.click();
      await weightInput.fill('');
      await weightInput.fill(weight.toString());
      await this.page.waitForTimeout(200);
    }

    // Click complete button
    let found = await this.flutter.clickButton(/concluir|complete|próxima|completar|registrar/i);

    if (!found) {
      const completeButton = this.flutterElement('complete-set')
        .or(this.page.locator('flt-semantics[role="button"]').filter({ hasText: /concluir|complete|registrar/i }));

      if (await completeButton.isVisible({ timeout: 3000 })) {
        await completeButton.click({ force: true });
      }
    }
  }

  // ==================
  // Co-training adjustment methods (for Trainer view)
  // ==================

  /**
   * Send a weight adjustment to the student.
   */
  async sendAdjustment(weight: number, note?: string) {
    console.log(`Sending adjustment: ${weight}kg`);

    // Open adjustment form
    let found = await this.flutter.clickButton(/sugerir|ajuste|suggest|adjustment/i);

    if (!found) {
      const adjustButton = this.flutterElement('suggest-adjustment')
        .or(this.page.locator('flt-semantics[role="button"]').filter({ hasText: /sugerir|ajuste/i }));

      if (await adjustButton.isVisible({ timeout: 3000 })) {
        await adjustButton.click({ force: true });
      }
    }

    await this.page.waitForTimeout(500);

    // Fill weight input
    const weightInput = this.page.locator('flt-semantics input').first();

    if (await weightInput.isVisible({ timeout: 2000 })) {
      await weightInput.click();
      await weightInput.fill('');
      await weightInput.fill(weight.toString());
    } else {
      // Try keyboard navigation
      await this.flutter.tabToElement((el) => el.role === 'textbox' || el.role === 'spinbutton');
      await this.page.keyboard.type(weight.toString());
    }

    // Optional note
    if (note) {
      await this.page.waitForTimeout(300);
      // Tab to next input or find note field
      const noteInput = this.page.locator('flt-semantics input').nth(1)
        .or(this.page.locator('flt-semantics textarea'));

      if (await noteInput.isVisible({ timeout: 2000 })) {
        await noteInput.click();
        await noteInput.fill(note);
      }
    }

    // Send
    found = await this.flutter.clickButton(/enviar|send|confirmar/i);

    if (!found) {
      const sendButton = this.flutterElement('send-adjustment')
        .or(this.page.locator('flt-semantics[role="button"]').filter({ hasText: /enviar|send/i }));

      if (await sendButton.isVisible({ timeout: 3000 })) {
        await sendButton.click({ force: true });
      }
    }
  }

  // ==================
  // Adjustment notification methods (for Student view)
  // ==================

  /**
   * Wait for and check adjustment notification.
   */
  async waitForAdjustment(timeout = 10000): Promise<boolean> {
    try {
      const notification = this.flutterElement('adjustment-notification')
        .or(this.page.locator('flt-semantics').filter({ hasText: /sugestão|ajuste|personal sugere|nova sugestão/i }));

      await notification.waitFor({ timeout });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Get the suggested weight from adjustment notification.
   */
  async getAdjustmentWeight(): Promise<number | null> {
    try {
      const notification = this.flutterElement('adjustment-notification')
        .or(this.page.locator('flt-semantics').filter({ hasText: /sugestão|ajuste|personal/i }));

      const text = await notification.textContent();

      // Extract number from text like "+5kg" or "30kg"
      const match = text?.match(/([+-]?\d+(?:\.\d+)?)\s*kg/i);
      return match ? parseFloat(match[1]) : null;
    } catch {
      return null;
    }
  }

  /**
   * Apply the suggested adjustment.
   */
  async applyAdjustment() {
    let found = await this.flutter.clickButton(/aplicar|apply|aceitar|accept/i);

    if (!found) {
      const applyButton = this.flutterElement('apply-adjustment')
        .or(this.page.locator('flt-semantics[role="button"]').filter({ hasText: /aplicar|apply/i }));

      if (await applyButton.isVisible({ timeout: 3000 })) {
        await applyButton.click({ force: true });
      }
    }
  }

  /**
   * Dismiss the adjustment.
   */
  async dismissAdjustment() {
    let found = await this.flutter.clickButton(/ignorar|dismiss|cancel|fechar/i);

    if (!found) {
      const dismissButton = this.flutterElement('dismiss-adjustment')
        .or(this.page.locator('flt-semantics[role="button"]').filter({ hasText: /ignorar|dismiss/i }));

      if (await dismissButton.isVisible({ timeout: 3000 })) {
        await dismissButton.click({ force: true });
      }
    }
  }
}
