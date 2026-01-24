import { Page, expect } from '@playwright/test';

/**
 * Login Page Object for MyFit Flutter Web app.
 *
 * Note: Flutter Web renders semantics as aria-label attributes on elements.
 * Use getByLabel() for semantic labels added via Semantics(label: '...')
 * or semanticsLabel property on form components.
 */
export class LoginPage {
  constructor(private page: Page) {}

  /**
   * Navigate to login page.
   */
  async goto() {
    await this.page.goto('/login');
    // Wait for Flutter to render
    await this.page.waitForSelector('flt-semantics-container', { timeout: 10000 });
  }

  /**
   * Login with credentials.
   *
   * Uses Flutter semantic labels:
   * - 'email-input' for email field
   * - 'password-input' for password field
   * - 'login-button' for submit button
   */
  async login(email: string, password: string) {
    // Wait for login form to be ready
    await this.page.waitForTimeout(1000); // Allow Flutter rendering

    // Find email input by semantic label
    const emailInput = this.page.getByLabel('email-input')
      .or(this.page.getByRole('textbox', { name: /email/i }))
      .or(this.page.locator('input[type="email"]'));

    // Find password input by semantic label
    const passwordInput = this.page.getByLabel('password-input')
      .or(this.page.getByRole('textbox', { name: /senha|password/i }))
      .or(this.page.locator('input[type="password"]'));

    // Fill credentials
    await emailInput.fill(email);
    await passwordInput.fill(password);

    // Click login button using semantic label
    const loginButton = this.page.getByLabel('login-button')
      .or(this.page.getByRole('button', { name: /entrar|login|sign in/i }));

    await loginButton.click();

    // Wait for navigation (either to org selector or dashboard)
    await this.page.waitForURL(/org-selector|dashboard|home/, { timeout: 15000 });
  }

  /**
   * Check if login page is displayed.
   */
  async isDisplayed(): Promise<boolean> {
    try {
      await this.page.waitForSelector('flt-semantics-container', { timeout: 5000 });
      const loginText = await this.page.getByText(/entrar|login/i).isVisible();
      return loginText;
    } catch {
      return false;
    }
  }

  /**
   * Get error message if login failed.
   */
  async getErrorMessage(): Promise<string | null> {
    try {
      const errorSnackbar = this.page.getByRole('alert')
        .or(this.page.locator('.snackbar'))
        .or(this.page.getByText(/erro|error|inválido|invalid/i));

      if (await errorSnackbar.isVisible()) {
        return await errorSnackbar.textContent();
      }
      return null;
    } catch {
      return null;
    }
  }
}
