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
   * Select co-training mode when starting workout.
   */
  async selectCoTrainingMode() {
    console.log('Selecting co-training mode...');

    // Try keyboard navigation first
    let found = await this.flutter.clickButton(/treinar com personal|co-training|com personal/i);

    if (!found) {
      // Fallback to direct locator
      const coTrainingOption = this.flutterElement('cotraining-mode')
        .or(this.page.locator('flt-semantics[role="button"]').filter({ hasText: /treinar com personal|co-training/i }));

      if (await coTrainingOption.isVisible({ timeout: 3000 })) {
        await coTrainingOption.click({ force: true });
      }
    }

    // Wait for "waiting for trainer" state
    try {
      await this.page.locator('flt-semantics').filter({ hasText: /aguardando|waiting|conectando/i }).waitFor({ timeout: 5000 });
    } catch {
      console.log('Waiting indicator not found, proceeding anyway...');
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
