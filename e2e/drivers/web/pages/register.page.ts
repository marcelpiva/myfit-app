import { Page, expect } from '@playwright/test';
import { FlutterHelper } from './flutter.helper';

/**
 * Registration Page Object for MyFit Flutter Web app.
 *
 * Handles:
 * - Welcome page navigation
 * - User type selection (Personal Trainer / Student)
 * - Registration form
 * - Social login buttons (Google/Apple)
 */
export class RegisterPage {
  private flutter: FlutterHelper;

  constructor(private page: Page) {
    this.flutter = new FlutterHelper(page);
  }

  /**
   * Navigate to welcome page.
   */
  async goto() {
    await this.page.goto('/');
    await this.flutter.waitForFlutter();
  }

  /**
   * Click "Começar Gratuitamente" on welcome page.
   */
  async clickStartFree() {
    const button = this.page.locator('flt-semantics[role="button"]').filter({ hasText: /começar gratuitamente/i });
    await button.waitFor({ state: 'visible', timeout: 10000 });
    await button.click();
    await this.page.waitForTimeout(1000);
  }

  /**
   * Click "Já tenho uma conta" on welcome page to go to login.
   */
  async clickAlreadyHaveAccount() {
    const button = this.page.locator('flt-semantics[role="button"]').filter({ hasText: /já tenho uma conta/i });
    await button.waitFor({ state: 'visible', timeout: 10000 });
    await button.click();
    await this.page.waitForTimeout(1000);
  }

  /**
   * Select user type on user type selection page.
   */
  async selectUserType(type: 'personal' | 'student') {
    await this.page.waitForTimeout(500);

    const cardText = type === 'personal' ? /personal trainer/i : /aluno/i;
    const card = this.page.locator('flt-semantics[role="button"]').filter({ hasText: cardText });

    await card.waitFor({ state: 'visible', timeout: 10000 });
    await card.click();
    await this.page.waitForTimeout(500);
  }

  /**
   * Click continue button on user type selection page.
   */
  async clickContinue() {
    const button = this.page.locator('flt-semantics[role="button"]').filter({ hasText: /continuar/i });
    await button.waitFor({ state: 'visible', timeout: 10000 });
    await button.click();
    await this.page.waitForTimeout(1000);
  }

  /**
   * Check if user type selection page is displayed.
   */
  async isUserTypeSelectionDisplayed(): Promise<boolean> {
    try {
      const hasText = await this.page.locator('flt-semantics').filter({ hasText: /você é/i }).count() > 0;
      return hasText;
    } catch {
      return false;
    }
  }

  /**
   * Check if "Continue with Google" button is visible.
   */
  async isGoogleButtonVisible(): Promise<boolean> {
    try {
      const button = this.page.locator('flt-semantics[role="button"]').filter({ hasText: /google/i });
      return await button.isVisible({ timeout: 3000 });
    } catch {
      return false;
    }
  }

  /**
   * Check if "Continue with Apple" button is visible.
   */
  async isAppleButtonVisible(): Promise<boolean> {
    try {
      const button = this.page.locator('flt-semantics[role="button"]').filter({ hasText: /apple/i });
      return await button.isVisible({ timeout: 3000 });
    } catch {
      return false;
    }
  }

  /**
   * Fill registration form.
   */
  async fillRegistrationForm(name: string, email: string, password: string) {
    // Find the name input (first text field)
    const nameInput = this.page.locator('flt-semantics input[data-semantics-role="text-field"]:not([disabled])').first();
    await nameInput.waitFor({ state: 'visible', timeout: 10000 });
    await nameInput.click();
    await nameInput.fill(name);
    await this.page.waitForTimeout(200);

    // Find email input
    const emailInput = this.page.locator('flt-semantics input[autocomplete="email"]:not([disabled])');
    await emailInput.click();
    await emailInput.fill(email);
    await this.page.waitForTimeout(200);

    // Find password input (second text field that's not email)
    const passwordInput = this.page.locator('flt-semantics input[data-semantics-role="text-field"]:not([disabled])').nth(2);
    await passwordInput.click();
    await passwordInput.fill(password);
    await this.page.waitForTimeout(200);
  }

  /**
   * Click "Criar conta" button.
   */
  async clickCreateAccount() {
    const button = this.page.locator('flt-semantics[role="button"]').filter({ hasText: /criar conta/i });
    await button.waitFor({ state: 'visible', timeout: 10000 });
    await button.click();
    await this.page.waitForTimeout(1000);
  }

  /**
   * Check if registration page is displayed.
   */
  async isRegistrationPageDisplayed(): Promise<boolean> {
    try {
      const hasText = await this.page.locator('flt-semantics').filter({ hasText: /criar conta|cadastro/i }).count() > 0;
      return hasText;
    } catch {
      return false;
    }
  }

  /**
   * Get error message if displayed.
   */
  async getErrorMessage(): Promise<string | null> {
    try {
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
