import { Page, expect } from '@playwright/test';

/**
 * Login Page Object for MyFit Flutter Web app.
 *
 * Flutter Web with CanvasKit renders semantic labels as aria-label attributes
 * on flt-semantics elements inside flt-semantics-container.
 */
export class LoginPage {
  constructor(private page: Page) {}

  /**
   * Navigate to login page.
   */
  async goto() {
    await this.page.goto('/login');
    // Wait for Flutter to fully render
    await this.waitForFlutter();

    // If we're on landing page, click "Já tenho uma conta" to go to login
    const loginLink = this.page.locator('flt-semantics[role="button"]').filter({ hasText: /já tenho uma conta/i });
    if (await loginLink.isVisible({ timeout: 2000 }).catch(() => false)) {
      await loginLink.click();
      await this.page.waitForTimeout(1000);
    }
  }

  /**
   * Wait for Flutter to be ready and enable accessibility.
   */
  async waitForFlutter() {
    // Wait for Flutter's glass pane to exist (not necessarily visible)
    await this.page.waitForSelector('flt-glass-pane', { timeout: 15000, state: 'attached' });

    // Give Flutter time to initialize
    await this.page.waitForTimeout(2000);

    // Flutter Web requires enabling accessibility to access the semantics tree
    // Click via JavaScript since the button is outside viewport
    await this.page.evaluate(() => {
      const btn = document.querySelector('flt-semantics-placeholder[aria-label="Enable accessibility"]') as HTMLElement;
      if (btn) btn.click();
    });

    // Wait for semantic nodes to be present (they appear after accessibility is enabled)
    await this.page.waitForSelector('flt-semantics', { timeout: 10000, state: 'attached' });
    // Give Flutter a moment to finish rendering
    await this.page.waitForTimeout(1500);
  }

  /**
   * Get Flutter semantic element by label.
   */
  private flutterElement(label: string) {
    return this.page.locator(`flt-semantics[aria-label="${label}"]`);
  }

  /**
   * Login with credentials.
   */
  async login(email: string, password: string) {
    await this.waitForFlutter();

    // Flutter Web uses real <input> elements inside flt-semantics
    // There are two textboxes per field: one disabled (decorator) and one enabled (actual input)
    // Find the enabled email input (the one with autocomplete="email" and not disabled)
    const emailInput = this.page.locator('flt-semantics input[autocomplete="email"]:not([disabled])');

    // Find the enabled password input (not disabled, not the email one)
    const passwordInput = this.page.locator('flt-semantics input[data-semantics-role="text-field"]:not([disabled])').nth(1);

    // Wait for email input to be visible
    await emailInput.waitFor({ state: 'visible', timeout: 10000 });

    // Clear and fill email
    await emailInput.click();
    await emailInput.fill('');
    await emailInput.fill(email);

    // Wait a bit before moving to password
    await this.page.waitForTimeout(300);

    // Clear and fill password
    await passwordInput.click();
    await passwordInput.fill('');
    await passwordInput.fill(password);

    // Wait a bit before clicking login
    await this.page.waitForTimeout(300);

    // Find and click login button ("login-button Entrar" or just text containing "Entrar")
    const loginButton = this.page.locator('flt-semantics[role="button"]').filter({ hasText: 'Entrar' }).first();

    await loginButton.click();

    // Wait for navigation
    await this.page.waitForURL(/org-selector|dashboard|home/, { timeout: 20000 });
  }

  /**
   * Check if login page is displayed.
   */
  async isDisplayed(): Promise<boolean> {
    try {
      await this.page.waitForSelector('flt-glass-pane', { timeout: 5000 });
      // Check for login-related text
      const hasLoginText = await this.page.locator('flt-semantics').filter({ hasText: /entrar|login/i }).count() > 0;
      return hasLoginText;
    } catch {
      return false;
    }
  }

  /**
   * Get error message if login failed.
   */
  async getErrorMessage(): Promise<string | null> {
    try {
      // Snackbars in Flutter appear as alert or live region
      const errorElement = this.page.locator('flt-semantics[role="alert"]')
        .or(this.page.locator('flt-semantics').filter({ hasText: /erro|error|inválido|invalid/i }));

      if (await errorElement.isVisible({ timeout: 2000 })) {
        return await errorElement.textContent();
      }
      return null;
    } catch {
      return null;
    }
  }
}
