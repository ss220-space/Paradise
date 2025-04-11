/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */
export const THEMES = ['light', 'dark', 'ntos', 'syndicate', 'paradise'];

const COLORS = {
  DARK: {
    BG_BASE: '#212020',
    BG_SECOND: '#131313',
    BUTTON: '#4C4C4D',
    TEXT: '#A4BAD6',
  },
  LIGHT: {
    BG_BASE: '#EFEEEE',
    BG_SECOND: '#FFFFFF',
    BUTTON: '#EEEEEE',
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

let setClientThemeTimer = null;

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
  }, 1500);

  const themeColor = COLORS[name.toUpperCase()];
  if (!themeColor) {
    return;
  }

  return Byond.winset({
    /* Buttons */
    'infobuttons.textb.background-color': themeColor.BUTTON,
    'infobuttons.textb.text-color': themeColor.TEXT,
    'infobuttons.infob.background-color': themeColor.BUTTON,
    'infobuttons.infob.text-color': themeColor.TEXT,
    'infobuttons.wikib.background-color': themeColor.BUTTON,
    'infobuttons.wikib.text-color': themeColor.TEXT,
    'infobuttons.forumb.background-color': themeColor.BUTTON,
    'infobuttons.forumb.text-color': themeColor.TEXT,
    'infobuttons.rulesb.background-color': themeColor.BUTTON,
    'infobuttons.rulesb.text-color': themeColor.TEXT,
    'infobuttons.githubb.background-color': themeColor.BUTTON,
    'infobuttons.githubb.text-color': themeColor.TEXT,
    'infobuttons.webmap.background-color': themeColor.BUTTON,
    'infobuttons.webmap.text-color': themeColor.TEXT,
    'infobuttons.changelog.background-color': themeColor.BUTTON,
    'infobuttons.changelog.text-color': themeColor.TEXT,
    'infobuttons.text-color': themeColor.TEXT,
    'info_and_buttons.background-color': themeColor.BG_BASE,
    'info.background-color': themeColor.BG_BASE,
    'info.text-color': themeColor.TEXT,
    'chat_panel.background-color': themeColor.BG_BASE,
    'chat_panel.text-color': themeColor.TEXT,
    'mainvsplit.background-color': themeColor.BG_BASE,
    /* Mainwindow */
    'mainwindow.background-color': themeColor.BG_BASE,
    'mainwindow.mainvsplit.background-color': themeColor.BG_BASE,
    'mainwindow.tooltip.background-color': themeColor.BG_BASE,
    'outputwindow.background-color': themeColor.BG_BASE,
    'outputwindow.text-color': themeColor.TEXT,
    'output.background-color': themeColor.BG_BASE,
    'output.text-color': themeColor.TEXT,
    /* Rpane */
    'infobuttons.background-color': themeColor.BG_BASE,
    'infobuttons.rpanewindow.background-color': themeColor.BG_BASE,
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
