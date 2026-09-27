import { describe, expect, test } from 'bun:test';

import {
  FRAME_POLICY,
  frameAddress,
  isInteractive,
  tokenRequest,
  navigationRequest,
} from '../interfaces/PDA/NtnetInteractive';

const SITE = '0123456789abcdef0123456789abcdef';
const GOOD = `https://sandbox.wiki-ss13.space/i/${SITE}/index`;

describe('NTnet interactive address', () => {
  test('accepts only the sandbox origin', () => {
    expect(isInteractive({ url: GOOD, version: 1 })).toEqual({
      url: GOOD,
      version: 1,
    });
    expect(isInteractive({ url: GOOD })).toEqual({ url: GOOD, version: 1 });
  });

  test('refuses anything else', () => {
    for (const url of [
      `http://sandbox.wiki-ss13.space/i/${SITE}/index`,
      `https://ntnet.wiki-ss13.space/i/${SITE}/index`,
      `https://media.wiki-ss13.space/i/${SITE}/index`,
      `https://sandbox.wiki-ss13.space.evil.example/i/${SITE}/index`,
      `https://evil.example/i/${SITE}/index`,
      `https://sandbox.wiki-ss13.space@evil.example/i/${SITE}/index`,
      `https://sandbox.wiki-ss13.space/i/${SITE}/index?x=1`,
      `https://sandbox.wiki-ss13.space/i/${SITE}/index#x`,
      `https://sandbox.wiki-ss13.space/../i/${SITE}/index`,
      `https://sandbox.wiki-ss13.space/i/${SITE}/ИНДЕКС`,
      'https://sandbox.wiki-ss13.space/i/short/index',
      'javascript:alert(1)',
      'byond://?src=admin',
      'data:text/html,<script>alert(1)</script>',
      '',
    ]) {
      expect(isInteractive({ url, version: 1 })).toBeNull();
    }
  });

  test('refuses junk instead of an object', () => {
    for (const value of [null, undefined, 'x', 42, [], { version: 1 }]) {
      expect(isInteractive(value)).toBeNull();
    }
  });
});

describe('NTnet navigation request from the frame', () => {
  test('accepts an internal address', () => {
    expect(
      navigationRequest({ ntnet: 'navigate', site: SITE, slug: 'news-2' }),
    ).toEqual({ siteId: SITE, slug: 'news-2' });
  });

  test('refuses anything else', () => {
    for (const value of [
      null,
      undefined,
      'navigate',
      { ntnet: 'stop', site: SITE, slug: 'index' },
      { site: SITE, slug: 'index' },
      { ntnet: 'navigate', site: SITE },
      { ntnet: 'navigate', site: 'short', slug: 'index' },
      { ntnet: 'navigate', site: SITE.toUpperCase(), slug: 'index' },
      { ntnet: 'navigate', site: SITE, slug: 'ИНДЕКС' },
      { ntnet: 'navigate', site: SITE, slug: '../index' },
      { ntnet: 'navigate', site: SITE, slug: '-news' },
      { ntnet: 'navigate', site: SITE, slug: '' },
    ]) {
      expect(navigationRequest(value)).toBeNull();
    }
  });
});

describe('NTnet site database handshake', () => {
  test('asks the sandbox for the connected policy', () => {
    expect(frameAddress(GOOD)).toBe(`${GOOD}?csp=3`);
  });

  test('lets the frame reach the mirrors without Cloudflare', () => {
    expect(FRAME_POLICY).toContain(
      'img-src https://media.wiki-ss13.space https://media-ru.wiki-ss13.space data:',
    );
    expect(FRAME_POLICY).toContain(
      'media-src https://media.wiki-ss13.space https://media-ru.wiki-ss13.space;',
    );
    expect(FRAME_POLICY).toContain(
      'connect-src https://sandbox.wiki-ss13.space https://sandbox-ru.wiki-ss13.space;',
    );
  });

  test('recognises only a token request', () => {
    expect(tokenRequest({ ntnet: 'token' })).toEqual({ renew: false });
    expect(tokenRequest({ ntnet: 'token', renew: true })).toEqual({
      renew: true,
    });
    expect(tokenRequest({ ntnet: 'token', renew: 'yes' })).toEqual({
      renew: false,
    });
    for (const value of [
      null,
      undefined,
      'token',
      { ntnet: 'navigate' },
      { token: 'x' },
      [],
    ]) {
      expect(tokenRequest(value)).toBeNull();
    }
  });
});
