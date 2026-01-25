import { Page } from '@playwright/test';

/**
 * Flutter Web Helper.
 *
 * Provides utilities for interacting with Flutter Web apps via Playwright.
 * Flutter Web uses CanvasKit rendering which doesn't create traditional DOM elements,
 * but it does create an accessibility tree with flt-semantics elements.
 *
 * Key challenges:
 * - flutter-view intercepts pointer events, so direct clicks often don't work
 * - Must use keyboard navigation (Tab/Shift+Tab/Enter) for reliable interaction
 * - Accessibility must be enabled first by clicking the placeholder button
 */
export class FlutterHelper {
  constructor(private page: Page) {}

  /**
   * Wait for Flutter to be ready and enable accessibility.
   */
  async waitForFlutter() {
    // Wait for Flutter's glass pane to exist (not necessarily visible)
    await this.page.waitForSelector('flt-glass-pane', { timeout: 15000, state: 'attached' });

    // Give Flutter time to initialize
    await this.page.waitForTimeout(2000);

    // Flutter Web requires enabling accessibility to access the semantics tree
    await this.page.evaluate(() => {
      const btn = document.querySelector('flt-semantics-placeholder[aria-label="Enable accessibility"]') as HTMLElement;
      if (btn) btn.click();
    });

    // Wait for semantic nodes to be present
    await this.page.waitForSelector('flt-semantics', { timeout: 10000, state: 'attached' });
    await this.page.waitForTimeout(1500);
  }

  /**
   * Get Flutter semantic element by aria-label.
   */
  flutterElement(label: string) {
    return this.page.locator(`flt-semantics[aria-label="${label}"]`);
  }

  /**
   * Focus the semantics host to enable keyboard navigation.
   */
  async focusSemanticsHost() {
    await this.page.evaluate(() => {
      const host = document.querySelector('flt-semantics-host');
      if (host) (host as HTMLElement).focus();
    });
    await this.page.waitForTimeout(200);
  }

  /**
   * Navigate through Flutter elements using Tab key until finding a matching element.
   *
   * @param matcher Function that returns true when the target element is focused
   * @param maxTabs Maximum Tab presses before giving up
   * @returns True if element was found, false otherwise
   */
  async tabToElement(
    matcher: (element: { role: string | null; label: string | null; text: string | null }) => boolean,
    maxTabs = 20
  ): Promise<boolean> {
    await this.focusSemanticsHost();

    for (let i = 0; i < maxTabs; i++) {
      await this.page.keyboard.press('Tab');
      await this.page.waitForTimeout(150);

      const elementInfo = await this.page.evaluate(() => {
        const active = document.activeElement;
        if (active && active.tagName === 'FLT-SEMANTICS') {
          return {
            role: active.getAttribute('role'),
            label: active.getAttribute('aria-label'),
            text: active.textContent?.trim() || null,
          };
        }
        return null;
      });

      if (elementInfo && matcher(elementInfo)) {
        return true;
      }
    }

    return false;
  }

  /**
   * Navigate to element and press Enter to activate it.
   */
  async tabToAndActivate(
    matcher: (element: { role: string | null; label: string | null; text: string | null }) => boolean,
    maxTabs = 20
  ): Promise<boolean> {
    const found = await this.tabToElement(matcher, maxTabs);
    if (found) {
      await this.page.keyboard.press('Enter');
      await this.page.waitForTimeout(300);
    }
    return found;
  }

  /**
   * Navigate to a button with specific text and click it.
   */
  async clickButton(textPattern: RegExp): Promise<boolean> {
    return this.tabToAndActivate(
      (el) => el.role === 'button' && el.text !== null && textPattern.test(el.text)
    );
  }

  /**
   * Navigate to an element with specific role and activate it.
   */
  async activateRole(role: string): Promise<boolean> {
    return this.tabToAndActivate((el) => el.role === role);
  }

  /**
   * Navigate to a group (e.g., card) and activate it.
   */
  async clickFirstGroup(): Promise<boolean> {
    return this.tabToAndActivate((el) => el.role === 'group');
  }

  /**
   * Type text into the currently focused input.
   */
  async typeIntoFocused(text: string) {
    await this.page.keyboard.type(text);
    await this.page.waitForTimeout(100);
  }

  /**
   * Clear and type into an input field.
   * Flutter inputs are real <input> elements inside flt-semantics.
   */
  async fillInput(selector: string, value: string) {
    const input = this.page.locator(selector);
    await input.waitFor({ state: 'visible', timeout: 5000 });
    await input.click();
    await input.fill('');
    await input.fill(value);
    await this.page.waitForTimeout(200);
  }

  /**
   * Get info about the currently focused element.
   */
  async getFocusedElementInfo(): Promise<{ role: string | null; label: string | null; text: string | null } | null> {
    return this.page.evaluate(() => {
      const active = document.activeElement;
      if (active && active.tagName === 'FLT-SEMANTICS') {
        return {
          role: active.getAttribute('role'),
          label: active.getAttribute('aria-label'),
          text: active.textContent?.trim() || null,
        };
      }
      return null;
    });
  }

  /**
   * Debug: Log all flt-semantics elements and their properties.
   */
  async debugElements() {
    const elements = await this.page.evaluate(() => {
      const nodes = document.querySelectorAll('flt-semantics');
      return Array.from(nodes).slice(0, 30).map(el => ({
        id: el.id,
        role: el.getAttribute('role'),
        label: el.getAttribute('aria-label'),
        text: el.textContent?.trim()?.substring(0, 50) || null,
        visible: (el as HTMLElement).offsetWidth > 0,
      }));
    });
    console.log('Flutter semantic elements:', JSON.stringify(elements, null, 2));
    return elements;
  }
}
