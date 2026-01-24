import { Page, expect } from '@playwright/test';

/**
 * Workout Session Page Object.
 *
 * Handles the active workout view for both Student and Trainer in co-training.
 *
 * Note: Flutter Web renders semantics as aria-label attributes on elements.
 * Use getByLabel() for semantic labels added via Semantics(label: '...').
 */
export class WorkoutSessionPage {
  constructor(private page: Page) {}

  /**
   * Wait for session to load.
   */
  async waitForLoad() {
    await this.page.waitForTimeout(1000);
    // Look for session-related elements
    const sessionElement = this.page.getByLabel('workout-session')
      .or(this.page.getByText(/treino ativo|exercício|série/i));
    await sessionElement.waitFor({ timeout: 10000 });
  }

  /**
   * Select co-training mode when starting workout.
   * Uses semantic label: 'cotraining-mode'.
   */
  async selectCoTrainingMode() {
    const coTrainingOption = this.page.getByLabel('cotraining-mode')
      .or(this.page.getByRole('button', { name: /treinar com personal|co-training/i }));

    await coTrainingOption.click();

    // Wait for "waiting for trainer" state
    await this.page.getByText(/aguardando|waiting/i).waitFor({ timeout: 5000 });
  }

  /**
   * Check if trainer is connected to the session.
   */
  async isTrainerConnected(): Promise<boolean> {
    try {
      const indicator = this.page.getByLabel('trainer-connected')
        .or(this.page.getByText(/personal conectado|trainer connected/i));
      return await indicator.isVisible();
    } catch {
      return false;
    }
  }

  /**
   * Get the current exercise name.
   */
  async getCurrentExercise(): Promise<string | null> {
    try {
      const exerciseElement = this.page.getByLabel('current-exercise')
        .or(this.page.getByRole('heading').filter({ hasText: /supino|rosca|agachamento/i }));
      return await exerciseElement.textContent();
    } catch {
      return null;
    }
  }

  /**
   * Complete a set.
   */
  async completeSet(reps: number, weight: number) {
    const repsInput = this.page.getByLabel('reps-input')
      .or(this.page.getByRole('spinbutton', { name: /reps|repetições/i }));

    const weightInput = this.page.getByLabel('weight-input')
      .or(this.page.getByRole('spinbutton', { name: /peso|weight/i }));

    await repsInput.fill(reps.toString());
    await weightInput.fill(weight.toString());

    const completeButton = this.page.getByRole('button', { name: /concluir|complete|próxima|completar série/i })
      .or(this.page.getByLabel('complete-set'));

    await completeButton.click();
  }

  // ==================
  // Co-training adjustment methods (for Trainer view)
  // ==================

  /**
   * Send a weight adjustment to the student.
   */
  async sendAdjustment(weight: number, note?: string) {
    // Open adjustment form
    const adjustButton = this.page.getByLabel('suggest-adjustment')
      .or(this.page.getByRole('button', { name: /sugerir ajuste|suggest/i }));
    await adjustButton.click();

    // Fill weight
    const weightInput = this.page.getByLabel('suggested-weight')
      .or(this.page.getByRole('spinbutton', { name: /peso sugerido/i }));
    await weightInput.fill(weight.toString());

    // Optional note
    if (note) {
      const noteInput = this.page.getByLabel('adjustment-note')
        .or(this.page.getByRole('textbox', { name: /nota|note/i }));
      await noteInput.fill(note);
    }

    // Send
    const sendButton = this.page.getByLabel('send-adjustment')
      .or(this.page.getByRole('button', { name: /enviar|send/i }));
    await sendButton.click();
  }

  // ==================
  // Adjustment notification methods (for Student view)
  // ==================

  /**
   * Wait for and check adjustment notification.
   * Uses Flutter semantic label: 'adjustment-notification'.
   */
  async waitForAdjustment(timeout = 10000): Promise<boolean> {
    try {
      const notification = this.page.getByLabel('adjustment-notification')
        .or(this.page.getByText(/sugestão do personal|ajuste do personal|personal sugere/i));
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
      const notification = this.page.getByLabel('adjustment-notification')
        .or(this.page.getByText(/sugestão do personal|ajuste do personal/i));
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
    const applyButton = this.page.getByRole('button', { name: /aplicar|apply/i })
      .or(this.page.getByLabel('apply-adjustment'));
    await applyButton.click();
  }

  /**
   * Dismiss the adjustment.
   */
  async dismissAdjustment() {
    const dismissButton = this.page.getByRole('button', { name: /ignorar|dismiss|cancel/i })
      .or(this.page.getByLabel('dismiss-adjustment'));
    await dismissButton.click();
  }
}
