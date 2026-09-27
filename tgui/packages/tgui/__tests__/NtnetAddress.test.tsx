import { describe, expect, test } from 'bun:test';
import {
  formatAddress,
  formatTitle,
  type NtnetSite,
  parseAddress,
  siteIcon,
} from '../interfaces/PDA/NtnetAddress';

const sites: NtnetSite[] = [
  {
    id: 'welcome',
    domain: 'welcome.ss13',
    title: 'Добро пожаловать',
    pages: [
      { slug: 'index', title: 'Главная' },
      { slug: 'rules', title: 'Правила' },
    ],
  },
  {
    id: 'local',
    domain: 'bar.dp',
    title: 'Бар',
    pages: [{ slug: 'index', title: 'Меню' }],
  },
];

test('opens a site by its domain', () => {
  expect(parseAddress('welcome.ss13', sites)).toEqual({
    kind: 'site',
    siteId: 'welcome',
    slug: 'index',
  });
  expect(parseAddress('  NTNET://Welcome.SS13/rules ', sites)).toEqual({
    kind: 'site',
    siteId: 'welcome',
    slug: 'rules',
  });
});

test('reports unknown domains and pages instead of searching', () => {
  expect(parseAddress('nothing.ss13', sites)).toEqual({
    kind: 'missing',
    address: 'nothing.ss13',
  });
  expect(parseAddress('welcome.ss13/secret', sites)).toEqual({
    kind: 'missing',
    address: 'welcome.ss13/secret',
  });
});

test('opens a site in a server zone and searches for unknown zones', () => {
  expect(parseAddress('bar.dp', sites)).toEqual({
    kind: 'site',
    siteId: 'local',
    slug: 'index',
  });
  expect(parseAddress('nothing.dp', sites)).toEqual({
    kind: 'missing',
    address: 'nothing.dp',
  });
  expect(parseAddress('example.com', sites)).toEqual({
    kind: 'search',
    query: 'example.com',
  });
});

test('accepts a zone the service reported even without sites in it', () => {
  expect(parseAddress('outpost.mine', sites)).toEqual({
    kind: 'search',
    query: 'outpost.mine',
  });
  expect(parseAddress('outpost.mine', sites, ['ss13', 'mine'])).toEqual({
    kind: 'missing',
    address: 'outpost.mine',
  });
});

test('treats free text as a search query', () => {
  expect(parseAddress('бар на станции', sites)).toEqual({
    kind: 'search',
    query: 'бар на станции',
  });
  expect(parseAddress('ntnet://search?q=%D0%B1%D0%B0%D1%80', sites)).toEqual({
    kind: 'search',
    query: 'бар',
  });
  expect(parseAddress('x', sites)).toBeNull();
});

test('resolves the internal browser pages', () => {
  expect(parseAddress('', sites)).toEqual({ kind: 'home' });
  expect(parseAddress('ntnet://sites', sites)).toEqual({ kind: 'catalog' });
  expect(parseAddress('ntnet://create', sites)).toEqual({ kind: 'create' });
});

test('round trips every address back through the bar', () => {
  for (const address of [
    'ntnet://home',
    'ntnet://sites',
    'ntnet://create',
    'welcome.ss13',
    'welcome.ss13/rules',
  ]) {
    const location = parseAddress(address, sites);
    expect(location).not.toBeNull();
    expect(formatAddress(location!, sites)).toBe(address);
  }
  const search = parseAddress('станция', sites);
  expect(formatAddress(search!, sites)).toBe('ntnet://search?q=станция');
});

test('names tabs after the page being shown', () => {
  expect(formatTitle({ kind: 'home' }, sites)).toBe('Новая вкладка');
  expect(
    formatTitle({ kind: 'site', siteId: 'welcome', slug: 'rules' }, sites),
  ).toBe('Правила');
  expect(
    formatTitle({ kind: 'site', siteId: 'gone', slug: 'index' }, sites),
  ).toBe('Новая вкладка');
});

describe('site icon', () => {
  const base = 'https://media.wiki-ss13.space/0123456789abcdef0123456789abcdef';

  test('accepts an icon from the media bucket', () => {
    const url = `${base}/0123456789abcdef.png`;
    expect(siteIcon({ icon: url })).toBe(url);
  });

  test('refuses anything else', () => {
    for (const icon of [
      `${base}/0123456789abcdef.svg`,
      `${base}/0123456789abcdef.png?x=1`,
      'https://evil.example/0123456789abcdef0123456789abcdef/0123456789abcdef.png',
      'javascript:alert(1)',
      'byond://?src=admin',
      42,
      null,
      undefined,
    ]) {
      expect(siteIcon({ icon })).toBeNull();
    }
    expect(siteIcon(undefined)).toBeNull();
  });
});
