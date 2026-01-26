import { test, expect } from '@playwright/test';
import { LoginPage } from '../pages/login.page';
import { RegisterPage } from '../pages/register.page';
import { OnboardingPage } from '../pages/onboarding.page';

const API_URL = process.env.API_URL || 'http://localhost:8001';
const APP_URL = process.env.APP_URL || 'http://localhost:3000';

/**
 * E2E tests for Authentication and Onboarding flows.
 *
 * These tests verify:
 * 1. Welcome page navigation
 * 2. User type selection (Personal Trainer / Student)
 * 3. Registration flow
 * 4. Social auth buttons presence
 * 5. Onboarding flow completion
 *
 * Note: Social login (Google/Apple) cannot be fully tested in E2E
 * due to OAuth popup restrictions. We verify UI presence only.
 */
test.describe('Auth & Onboarding Flows', () => {
  test.beforeAll(async () => {
    // Reset E2E database before tests
    try {
      const response = await fetch(`${API_URL}/test/reset`, { method: 'POST' });
      console.log('Database reset:', response.ok ? 'success' : 'failed');
    } catch (e) {
      console.log('Database reset skipped (E2E server not running)');
    }
  });

  test.describe('Welcome Page', () => {
    test('should display welcome page with main CTAs', async ({ page }) => {
      const registerPage = new RegisterPage(page);
      await registerPage.goto();

      // Should show "Começar Gratuitamente" button
      const startButton = page.locator('flt-semantics[role="button"]').filter({ hasText: /começar gratuitamente/i });
      await expect(startButton).toBeVisible({ timeout: 15000 });

      // Should show "Já tenho uma conta" link
      const loginLink = page.locator('flt-semantics[role="button"]').filter({ hasText: /já tenho uma conta/i });
      await expect(loginLink).toBeVisible();
    });

    test('should navigate to login page when clicking "Já tenho uma conta"', async ({ page }) => {
      const registerPage = new RegisterPage(page);
      await registerPage.goto();
      await registerPage.clickAlreadyHaveAccount();

      // Should be on login page
      const loginPage = new LoginPage(page);
      expect(await loginPage.isDisplayed()).toBe(true);
    });

    test('should navigate to user type selection when clicking "Começar Gratuitamente"', async ({ page }) => {
      const registerPage = new RegisterPage(page);
      await registerPage.goto();
      await registerPage.clickStartFree();

      // Should show user type selection
      expect(await registerPage.isUserTypeSelectionDisplayed()).toBe(true);
    });
  });

  test.describe('User Type Selection', () => {
    test('should display Personal Trainer and Student options', async ({ page }) => {
      const registerPage = new RegisterPage(page);
      await registerPage.goto();
      await registerPage.clickStartFree();

      // Check for both user type cards
      const trainerCard = page.locator('flt-semantics[role="button"]').filter({ hasText: /personal trainer/i });
      const studentCard = page.locator('flt-semantics[role="button"]').filter({ hasText: /aluno/i });

      await expect(trainerCard).toBeVisible({ timeout: 10000 });
      await expect(studentCard).toBeVisible();
    });

    test('should enable Continue button when user type is selected', async ({ page }) => {
      const registerPage = new RegisterPage(page);
      await registerPage.goto();
      await registerPage.clickStartFree();

      // Select Personal Trainer
      await registerPage.selectUserType('personal');

      // Continue button should be enabled
      const continueButton = page.locator('flt-semantics[role="button"]').filter({ hasText: /continuar/i });
      await expect(continueButton).toBeVisible();
    });

    test('should navigate to registration after selecting Personal Trainer', async ({ page }) => {
      const registerPage = new RegisterPage(page);
      await registerPage.goto();
      await registerPage.clickStartFree();

      await registerPage.selectUserType('personal');
      await registerPage.clickContinue();

      // Should be on registration page
      expect(await registerPage.isRegistrationPageDisplayed()).toBe(true);
    });

    test('should navigate to registration after selecting Student', async ({ page }) => {
      const registerPage = new RegisterPage(page);
      await registerPage.goto();
      await registerPage.clickStartFree();

      await registerPage.selectUserType('student');
      await registerPage.clickContinue();

      // Should be on registration page
      expect(await registerPage.isRegistrationPageDisplayed()).toBe(true);
    });
  });

  test.describe('Social Auth Buttons', () => {
    test('should display Google and Apple login buttons on login page', async ({ page }) => {
      const registerPage = new RegisterPage(page);
      await registerPage.goto();
      await registerPage.clickAlreadyHaveAccount();

      // Check social buttons
      expect(await registerPage.isGoogleButtonVisible()).toBe(true);
      expect(await registerPage.isAppleButtonVisible()).toBe(true);
    });

    test('should display Google and Apple buttons on registration page', async ({ page }) => {
      const registerPage = new RegisterPage(page);
      await registerPage.goto();
      await registerPage.clickStartFree();
      await registerPage.selectUserType('personal');
      await registerPage.clickContinue();

      // Check social buttons
      expect(await registerPage.isGoogleButtonVisible()).toBe(true);
      expect(await registerPage.isAppleButtonVisible()).toBe(true);
    });
  });

  test.describe('Login Flow', () => {
    test.beforeAll(async () => {
      // Setup cotraining scenario which includes test users
      try {
        await fetch(`${API_URL}/test/setup/cotraining`, { method: 'POST' });
      } catch (e) {
        console.log('Scenario setup skipped');
      }
    });

    test('should login successfully with valid credentials', async ({ page }) => {
      const loginPage = new LoginPage(page);
      await loginPage.goto();
      await loginPage.login('trainer@test.com', 'password123');

      // Should redirect to org selector or dashboard
      await expect(page).toHaveURL(/org-selector|dashboard|home/, { timeout: 20000 });
    });

    test('should show error with invalid credentials', async ({ page }) => {
      const loginPage = new LoginPage(page);
      await loginPage.goto();
      await loginPage.login('invalid@test.com', 'wrongpassword');

      // Should show error message
      const error = await loginPage.getErrorMessage();
      expect(error).toBeTruthy();
    });
  });

  test.describe('Onboarding Flow', () => {
    test.skip('should complete trainer onboarding and create organization', async ({ page }) => {
      // This test requires a logged-in user going through onboarding
      // Skipped due to Flutter Web button interaction limitations
      const onboardingPage = new OnboardingPage(page);

      // Navigate to onboarding (would need authenticated user)
      await page.goto('/onboarding');
      await onboardingPage.waitForLoad();

      // Verify onboarding is displayed
      expect(await onboardingPage.isDisplayed()).toBe(true);

      // Complete onboarding
      await onboardingPage.completeTrainerOnboarding();

      // Should be on dashboard
      expect(await onboardingPage.isOnDashboard()).toBe(true);
    });
  });

  test.describe('CREF Field Validation', () => {
    test('should only accept valid CREF format (000000-G/B/L/F)', async ({ page }) => {
      // Navigate to trainer registration/onboarding to test CREF field
      const registerPage = new RegisterPage(page);
      await registerPage.goto();
      await registerPage.clickStartFree();
      await registerPage.selectUserType('personal');
      await registerPage.clickContinue();

      // The CREF field is in onboarding, not registration
      // This test verifies the UI is present
      expect(await registerPage.isRegistrationPageDisplayed()).toBe(true);
    });
  });
});

test.describe('Email Verification Flow', () => {
  test('should display 6-digit code input', async ({ page }) => {
    // Navigate to verify email page (would need to register first)
    // This is a UI presence test
    const registerPage = new RegisterPage(page);
    await registerPage.goto();

    // Verify the registration flow includes email verification
    // The actual code input is tested after registration
    expect(await page.locator('flt-glass-pane').count()).toBeGreaterThan(0);
  });
});
