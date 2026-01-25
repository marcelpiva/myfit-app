/**
 * Debug script to understand Flutter Web DOM structure.
 */

import { test, expect } from '@playwright/test';

const APP_URL = process.env.APP_URL || 'http://localhost:3000';

test('inspect Flutter Web DOM structure', async ({ page }) => {
  // Navigate to login page
  await page.goto(`${APP_URL}/login`);

  // Wait some time for Flutter to load
  await page.waitForTimeout(3000);

  // Enable accessibility via JavaScript (button is outside viewport)
  console.log('Clicking accessibility button via JS...');
  await page.evaluate(() => {
    const btn = document.querySelector('flt-semantics-placeholder[aria-label="Enable accessibility"]') as HTMLElement;
    if (btn) btn.click();
  });
  await page.waitForTimeout(2000);

  // Click "Já tenho uma conta" to go to login page
  const loginLink = page.locator('flt-semantics[role="button"]').filter({ hasText: /já tenho uma conta/i });
  if (await loginLink.isVisible({ timeout: 2000 }).catch(() => false)) {
    console.log('Clicking "Já tenho uma conta" button...');
    await loginLink.click();
    await page.waitForTimeout(2000);
  }

  // Log all flt-* elements
  const fltElements = await page.evaluate(() => {
    const elements = document.querySelectorAll('[class^="flt-"], flt-glass-pane, flt-scene-host, flt-semantics-container, flt-semantics');
    return Array.from(elements).map(el => ({
      tagName: el.tagName.toLowerCase(),
      className: el.className,
      id: el.id,
      visible: window.getComputedStyle(el).display !== 'none' && window.getComputedStyle(el).visibility !== 'hidden',
      dimensions: {
        width: el.getBoundingClientRect().width,
        height: el.getBoundingClientRect().height,
      },
    }));
  });

  console.log('Flutter elements found:', JSON.stringify(fltElements, null, 2));

  // Get details of all flt-semantics elements
  const semanticsDetails = await page.evaluate(() => {
    const elements = document.querySelectorAll('flt-semantics');
    return Array.from(elements).slice(0, 30).map(el => ({
      id: el.id,
      role: el.getAttribute('role'),
      ariaLabel: el.getAttribute('aria-label'),
      ariaValueNow: el.getAttribute('aria-valuenow'),
      textContent: el.textContent?.substring(0, 50),
      innerHTML: el.innerHTML.substring(0, 100),
    }));
  });

  console.log('Semantics details:', JSON.stringify(semanticsDetails, null, 2));

  // Check for canvas elements
  const canvasElements = await page.evaluate(() => {
    const elements = document.querySelectorAll('canvas');
    return Array.from(elements).map(el => ({
      className: el.className,
      width: el.width,
      height: el.height,
    }));
  });

  console.log('Canvas elements:', JSON.stringify(canvasElements, null, 2));

  // Take a screenshot
  await page.screenshot({ path: 'test-results/debug-flutter.png', fullPage: true });
  console.log('Screenshot saved to test-results/debug-flutter.png');
});
