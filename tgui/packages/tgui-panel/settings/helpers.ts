/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { DEFAULT_FONT, FONTS_DISABLED } from './constants';
import { setClientTheme } from './themes';
import type { SettingsState } from './types';

let statFontTimer: NodeJS.Timeout;
let statTabsTimer: NodeJS.Timeout;
let statFamilyTimer: NodeJS.Timeout;
let overrideFontFamily: string | undefined;
let overrideFontSize: string;

/** Updates the global CSS rule to override the font family and size. */
function updateGlobalOverrideRule(): void {
  let fontFamily: string | null = null;

  if (overrideFontFamily !== undefined) {
    fontFamily = overrideFontFamily;
  }

  document.documentElement.style.setProperty('font-family', fontFamily);
  document.body.style.setProperty('font-family', fontFamily);
  document.body.style.setProperty('font-size', overrideFontSize);
}

function setGlobalFontSize(
  fontSize: string | number,
  statFontSize: string | number,
  statLinked: boolean,
): void {
  overrideFontSize = `${fontSize}px`;

  // Used solution from theme.ts
  clearInterval(statFontTimer);
  Byond.command(
    `.output statbrowser:set_font_size ${statLinked ? fontSize : statFontSize}px`,
  );
  statFontTimer = setTimeout(() => {
    Byond.command(
      `.output statbrowser:set_font_size ${statLinked ? fontSize : statFontSize}px`,
    );
  }, 1500);
}

function setGlobalFontFamily(
  fontFamily: string | undefined,
  statFontFamily: string | undefined,
  statLinked: boolean,
): void {
  if (fontFamily === FONTS_DISABLED) {
    fontFamily = DEFAULT_FONT;
  }

  if (statFontFamily === FONTS_DISABLED) {
    statFontFamily = DEFAULT_FONT;
  }

  overrideFontFamily = fontFamily;

  clearInterval(statFamilyTimer);
  Byond.command(
    `.output statbrowser:set_font_style ${statLinked ? fontFamily : statFontFamily}`,
  );
  statFamilyTimer = setTimeout(() => {
    Byond.command(
      `.output statbrowser:set_font_style ${statLinked ? fontFamily : statFontFamily}`,
    );
  }, 1500);
}

function setStatTabsStyle(style: string): void {
  clearInterval(statTabsTimer);
  Byond.command(`.output statbrowser:set_tabs_style ${style}`);
  statTabsTimer = setTimeout(() => {
    Byond.command(`.output statbrowser:set_tabs_style ${style}`);
  }, 1500);
}

export function generalSettingsHandler(update: SettingsState): void {
  // Set client theme
  const theme = update?.theme;
  if (theme) {
    setClientTheme(theme);
  }

  // Update stat panel settings
  setStatTabsStyle(update.statTabsStyle);

  // Update global UI font size
  setGlobalFontSize(update.fontSize, update.statFontSize, update.statLinked);
  setGlobalFontFamily(
    update.fontFamily,
    update.statFontFamily,
    update.statLinked,
  );
  updateGlobalOverrideRule();
}
