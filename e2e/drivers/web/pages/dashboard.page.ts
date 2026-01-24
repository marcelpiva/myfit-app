import { Page, expect } from '@playwright/test';

/**
 * Dashboard Page Object.
 *
 * Handles both Trainer and Student dashboard views.
 *
 * Note: Flutter Web renders semantics as aria-label attributes on elements.
 * Use getByLabel() for semantic labels added via Semantics(label: '...').
 */
export class DashboardPage {
  constructor(private page: Page) {}

  /**
   * Wait for dashboard to load.
   */
  async waitForLoad() {
    await this.page.waitForURL(/dashboard|home|org-selector/);
    await this.page.waitForTimeout(1500); // Allow Flutter to render
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
      // Look for user name in app bar or profile area
      const nameElement = this.page.getByLabel('user-name')
        .or(this.page.getByRole('heading').first());
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
   * Uses Flutter semantic labels set via Semantics(label: 'active-students').
   */
  async hasActiveStudent(studentName: string): Promise<boolean> {
    try {
      // Flutter semantic label: 'active-students'
      const activeStudents = this.page.getByLabel('active-students')
        .or(this.page.getByText(/alunos? recentes/i));

      await activeStudents.waitFor({ timeout: 5000 });

      // Check for student card with semantic label
      const studentCard = this.page.getByLabel(`student-card-${studentName}`)
        .or(this.page.getByText(studentName));

      return await studentCard.isVisible();
    } catch {
      return false;
    }
  }

  /**
   * Click to join a student's co-training session.
   */
  async joinStudentSession(studentName: string) {
    const studentCard = this.page.getByLabel(`student-card-${studentName}`)
      .or(this.page.getByText(studentName));

    await studentCard.click();

    // Look for join session button in the session details
    const joinButton = this.page.getByLabel('join-session')
      .or(this.page.getByRole('button', { name: /acompanhar|join/i }));

    await joinButton.click();
  }

  // ==================
  // Student-specific methods
  // ==================

  /**
   * Check if student has an assigned plan.
   */
  async hasAssignedPlan(): Promise<boolean> {
    try {
      const planSection = this.page.getByLabel('assigned-plan')
        .or(this.page.getByText(/seu plano|your plan|treino de hoje/i));
      return await planSection.isVisible();
    } catch {
      return false;
    }
  }

  /**
   * Start a workout from the dashboard.
   * Uses semantic labels: 'quick-action-iniciar-treino' for the start workout button.
   */
  async startWorkout(workoutName?: string) {
    // Click on "Iniciar Treino" quick action
    const startButton = this.page.getByLabel('quick-action-iniciar-treino')
      .or(this.page.getByRole('button', { name: /iniciar.*treino|start.*workout/i }))
      .or(this.page.getByText(/iniciar.*treino/i).first());

    await startButton.click();

    // Wait for workout picker sheet to appear
    await this.page.waitForTimeout(500);

    if (workoutName) {
      // Click specific workout card
      const workoutCard = this.page.getByText(workoutName);
      await workoutCard.click();
    } else {
      // Click the first/suggested workout
      const suggestedWorkout = this.page.getByLabel(/workout-card-treino-a/i)
        .or(this.page.getByText(/sugerido/i).locator('..'));
      await suggestedWorkout.click();
    }
  }

  /**
   * Enable co-training mode when starting a workout.
   * Uses semantic label: 'cotraining-mode'.
   */
  async enableCotrainingMode() {
    const cotrainingButton = this.page.getByLabel('cotraining-mode')
      .or(this.page.getByRole('button', { name: /treinar com personal/i }));

    await cotrainingButton.click();
  }

  /**
   * Start workout in solo mode.
   * Uses semantic label: 'start-workout-solo'.
   */
  async startWorkoutSolo() {
    const soloButton = this.page.getByLabel('start-workout-solo')
      .or(this.page.getByRole('button', { name: /treinar sozinho/i }));

    await soloButton.click();
  }
}
