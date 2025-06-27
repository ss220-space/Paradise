/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const THEMES = ['light', 'dark', 'ntos', 'syndicate', 'paradise'];

const COLORS = {
  DARK: {
    BG_BASE: '#202020',
    BG_SECOND: '#151515',
    BUTTON: '#404040',
    TEXT: '#A6A6A6',
  },
  LIGHT: {
    BG_BASE: '#EEEEEE',
    BG_SECOND: '#FFFFFF',
    BUTTON: '#FFFFFF',
    TEXT: '#000000',
  },
  NTOS: {
    BG_BASE: '#1b2633',
    BG_SECOND: '#121922',
    BUTTON: '#384e68',
    TEXT: '#b8cbe6',
  },
  SYNDICATE: {
    BG_BASE: '#4d0202',
    BG_SECOND: '#2b0101',
    BUTTON: '#397439',
    TEXT: '#ffffff',
  },
  PARADISE: {
    BG_BASE: '#800448',
    BG_SECOND: '#400125',
    BUTTON: '#208080',
    TEXT: '#ffffff',
  },
};

let setClientThemeTimer: NodeJS.Timeout;

/**
 * Darkmode preference, originally by Kmc2000.
 *
 * This lets you switch client themes by using winset.
 *
 * If you change ANYTHING in interface/skin.dmf you need to change it here.
 *
 * There's no way round it. We're essentially changing the skin by hand.
 * It's painful but it works, and is the way Lummox suggested.
 */
export const setClientTheme = (name) => {
  // Transmit once for fast updates and again in a little while in case we won
  // the race against statbrowser init.
  clearInterval(setClientThemeTimer);
  Byond.command(`.output statbrowser:set_theme ${name}`);
  Byond.command(`.output title_browser:set_theme ${name}`);
  setClientThemeTimer = setTimeout(() => {
    Byond.command(`.output statbrowser:set_theme ${name}`);
    Byond.command(`.output title_browser:set_theme ${name}`);
  }, 1500);

  const themeColor = COLORS[name.toUpperCase()];
  if (!themeColor) {
    return;
  }

  Byond.sendMessage('theme', { 'theme': name });

  return Byond.winset({
    /* Mainwindow */
    'mainwindow.background-color': themeColor.BG_BASE,
    'mainwindow.mainvsplit.background-color': themeColor.BG_BASE,
    'mainwindow.tooltip.background-color': themeColor.BG_BASE,
    'info_and_buttons.background-color': themeColor.BG_BASE,
    'info.background-color': themeColor.BG_BASE,
    'info.text-color': themeColor.TEXT,
    'chat_panel.background-color': themeColor.BG_BASE,
    'chat_panel.text-color': themeColor.TEXT,
    'outputwindow.background-color': themeColor.BG_BASE,
    'outputwindow.text-color': themeColor.TEXT,
    'mainvsplit.background-color': themeColor.BG_BASE,
    /* Buttons */
    'infobuttons.textb.background-color': themeColor.BUTTON,
    'infobuttons.textb.text-color': themeColor.TEXT,
    'infobuttons.infob.background-color': themeColor.BUTTON,
    'infobuttons.infob.text-color': themeColor.TEXT,
    'infobuttons.wikib.background-color': themeColor.BUTTON,
    'infobuttons.wikib.text-color': themeColor.TEXT,
    'infobuttons.discordb.background-color': themeColor.BUTTON,
    'infobuttons.discordb.text-color': themeColor.TEXT,
    'infobuttons.webmap.background-color': themeColor.BUTTON,
    'infobuttons.webmap.text-color': themeColor.TEXT,
    'infobuttons.fullscreenb.background-color': themeColor.BUTTON,
    'infobuttons.fullscreenb.text-color': themeColor.TEXT,
    'output.background-color': themeColor.BG_BASE,
    'output.text-color': themeColor.TEXT,
    /* Rpane */
    'infobuttons.background-color': themeColor.BG_BASE,
    'infobuttons.text-color': themeColor.TEXT,
    /* Infowindow */
    'infowindow.background-color': themeColor.BG_BASE,
    'infowindow.text-color': themeColor.TEXT,
    // Say, OOC, me Buttons etc.
    'saybutton.background-color': themeColor.BG_BASE,
    'saybutton.text-color': themeColor.TEXT,
    'oocbutton.background-color': themeColor.BG_BASE,
    'oocbutton.text-color': themeColor.TEXT,
    'mebutton.background-color': themeColor.BG_BASE,
    'mebutton.text-color': themeColor.TEXT,
    'asset_cache_browser.background-color': themeColor.BG_BASE,
    'asset_cache_browser.text-color': themeColor.TEXT,
    'tooltip.background-color': themeColor.BG_BASE,
    'tooltip.text-color': themeColor.TEXT,
    'input.background-color': themeColor.BG_SECOND,
    'input.text-color': themeColor.TEXT,
  });
};
