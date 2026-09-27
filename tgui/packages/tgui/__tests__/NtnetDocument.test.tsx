import { expect, test } from 'bun:test';
import { createElement } from 'react';
import { renderToStaticMarkup } from 'react-dom/server.node';
import { NtnetDocument } from '../interfaces/PDA/NtnetDocument';

const render = (tree: unknown) =>
  renderToStaticMarkup(
    createElement(NtnetDocument, { tree, onNavigate: () => {} }),
  );

test('renders text as text, without interpreting HTML', () => {
  const html = render({
    type: 'text',
    text: '<img src="https://evil.example/track" onerror="alert(1)">',
  });
  expect(html).toContain('&lt;img');
  expect(html).not.toContain('<img');
});

test('discards executable, external and unknown elements', () => {
  for (const type of [
    'script',
    'iframe',
    'img',
    'video',
    'a',
    'style',
    'object',
    'future-block',
  ]) {
    const html = render({
      type,
      href: 'byond://?src=admin',
      src: 'https://evil.example/',
      children: [{ type: 'text', text: 'unsafe-child' }],
    });
    expect(html).not.toContain('unsafe-child');
    expect(html).not.toContain('byond:');
    expect(html).not.toContain('evil.example');
  }
});

test('does not spread untrusted attributes onto allowed tags', () => {
  const html = render({
    type: 'p',
    onClick: 'alert(1)',
    style: { backgroundImage: 'url(https://evil.example)' },
    dangerouslySetInnerHTML: { __html: '<script>bad</script>' },
    children: [{ type: 'strong', children: [{ type: 'text', text: 'safe' }] }],
  });
  expect(html).toContain('<p><strong>safe</strong></p>');
  expect(html).not.toContain('evil.example');
  expect(html).not.toContain('<script>');
});

test('bounds tree depth and total node count', () => {
  let tree: unknown = { type: 'text', text: 'too-deep' };
  for (let index = 0; index < 100; index++) {
    tree = { type: 'div', children: [tree] };
  }
  expect(render(tree)).not.toContain('too-deep');
  const wide = render({
    type: 'div',
    children: Array.from({ length: 5000 }, () => ({ type: 'text', text: 'x' })),
  });
  expect(wide.length).toBeLessThan(1200);
});

test('ignores malformed nodes', () => {
  for (const tree of [
    null,
    false,
    42,
    [],
    { type: 'text', text: {} },
    { type: 'p', children: 'not-an-array' },
  ]) {
    expect(() => render(tree)).not.toThrow();
  }
});

test('renders a tree delivered as JSON text', () => {
  let tree: unknown = { type: 'text', text: 'deep-text' };
  for (let index = 0; index < 12; index++) {
    tree = { type: 'div', children: [tree] };
  }
  expect(render(JSON.stringify(tree))).toContain('deep-text');
  expect(() => render('{"type":"div",')).not.toThrow();
  expect(render('<b>raw</b>')).not.toContain('raw');
});

test('internal links never become browser navigation', () => {
  const html = render({
    type: 'link',
    site_id: 'welcome',
    slug: 'index',
    href: 'byond://?src=admin',
    children: [{ type: 'text', text: 'Open site' }],
  });
  expect(html).toContain('Open site');
  expect(html).not.toContain('href');
  expect(html).not.toContain('byond:');
});

test('keeps ordinary styles and drops the dangerous ones', () => {
  const html = render({
    type: 'p',
    style: {
      color: '#74e3bc',
      textAlign: 'center',
      backgroundImage: 'url(https://evil.example)',
      background: 'image-set("evil.png")',
      behavior: 'binding(evil)',
      position: 'fixed',
      width: 'calc(100% - 2rem)',
      '--accent': '#74e3bc',
      WebkitTextStroke: '1px #000',
    },
    children: [{ type: 'text', text: 'styled' }],
  });
  expect(html).toContain('color:#74e3bc');
  expect(html).toContain('text-align:center');
  expect(html).toContain('width:calc(100% - 2rem)');
  expect(html).toContain('--accent:#74e3bc');
  expect(html).toContain('-webkit-text-stroke:1px #000');
  expect(html).not.toContain('evil.example');
  expect(html).not.toContain('image-set');
  expect(html).not.toContain('binding');
  expect(html).not.toContain('fixed');
});

test('renders media only from the NTnet bucket', () => {
  const good = render({
    type: 'image',
    src: 'https://media.wiki-ss13.space/0123456789abcdef0123456789abcdef/0123456789abcdef.png',
    alt: '<station>',
  });
  expect(good).toContain('<img');
  expect(good).toContain('&lt;station&gt;');
  const bad = render({ type: 'video', src: 'https://evil.example/track.mp4' });
  expect(bad).not.toContain('<video');
  expect(bad).not.toContain('evil.example');
});

test('renders the wider markup set with table spans', () => {
  const html = render({
    type: 'table',
    style: { borderCollapse: 'collapse', display: 'grid' },
    children: [
      {
        type: 'tr',
        children: [
          {
            type: 'th',
            colspan: 2,
            rowspan: 99,
            children: [{ type: 'text', text: 'Смена' }],
          },
        ],
      },
    ],
  });
  expect(html).toContain('<table');
  expect(html).toContain('border-collapse:collapse');
  expect(html.toLowerCase()).toContain('colspan="2"');
  expect(html.toLowerCase()).not.toContain('rowspan');
  const spoiler = render({
    type: 'details',
    children: [{ type: 'summary', children: [{ type: 'text', text: 'Ещё' }] }],
  });
  expect(spoiler).toContain('<details><summary>Ещё</summary></details>');
});

test('keeps the page from escaping its own area', () => {
  for (const position of ['fixed', 'STICKY', 'fixed ']) {
    const html = render({
      type: 'div',
      style: { position, top: '0px', zIndex: '99' },
      children: [{ type: 'text', text: 'overlay' }],
    });
    expect(html).not.toContain('fixed');
    expect(html).not.toContain('STICKY');
    expect(html).toContain('z-index:99');
  }
  const allowed = render({ type: 'div', style: { position: 'absolute' } });
  expect(allowed).toContain('position:absolute');
});

test('carries the whitelisted attributes and drops the rest', () => {
  const html = render({
    type: 'details',
    open: true,
    title: 'Подсказка',
    id: 'menu',
    class: 'card wide',
    onClick: 'alert(1)',
    children: [
      { type: 'summary', children: [{ type: 'text', text: 'Меню' }] },
      { type: 'progress', value: 70, max: 100 },
      { type: 'ol', start: 3, reversed: true, children: [] },
    ],
  });
  expect(html).toContain('open');
  expect(html).toContain('title="Подсказка"');
  expect(html).toContain('value="70"');
  expect(html).toContain('start="3"');
  expect(html).toContain('reversed');
  expect(html).toContain('id="menu"');
  expect(html).toContain('class="card wide"');
  expect(html).not.toContain('alert(1)');
});

test('carries a scoped stylesheet and refuses a dangerous one', () => {
  const html = render({
    type: 'div',
    css:
      '.ntnet-doc .card:hover{color:red}@keyframes fade{0%{opacity:0}}' +
      '.ntnet-doc .card{--accent:#74e3bc;color:var(--accent);width:calc(100% - 2rem)}' +
      '.ntnet-doc .card + .card{margin-top:8px}',
    children: [{ type: 'text', text: 'карточка' }],
  });
  expect(html).toContain('<style>');
  expect(html).toContain('.card:hover{color:red}');
  expect(html).toContain('@keyframes fade');
  expect(html).toContain('color:var(--accent)');
  expect(html).toContain('width:calc(100% - 2rem)');
  expect(html).toContain('.card + .card{margin-top:8px}');
  for (const css of [
    '.a{background:url(https://evil.example)}',
    '.a{background:url (https://evil.example)}',
    '.a{background:image-set("evil.png")}',
    '.a{background:element(#evil)}',
    '.a{content:attr(href)}',
    '.a{-moz-binding:binding(evil)}',
    '.a{background:\\75 rl(evil.png)}',
    '@import "https://evil.example";',
    '@font-face{font-family:evil}',
    '.a{position:fixed;top:0}',
    '.a{position:sticky;top:0}',
    '.a{color:red}</style><script>alert(1)</script>',
    '.a{color:red',
  ]) {
    const attempt = render({ type: 'div', css, children: [] });
    expect(attempt).not.toContain('<style>');
  }
});

test('renders the new effect properties', () => {
  const html = render({
    type: 'div',
    style: {
      transform: 'rotate(2deg) scale(1.1)',
      filter: 'blur(2px)',
      clipPath: 'inset(10% 0 0 0)',
      gridTemplateAreas: '"head head" "side main"',
      mixBlendMode: 'screen',
      visibility: 'visible',
      willChange: 'transform',
    },
  });
  expect(html).toContain('transform:rotate(2deg) scale(1.1)');
  expect(html).toContain('filter:blur(2px)');
  expect(html).toContain('clip-path:inset(10% 0 0 0)');
  expect(html).toContain('mix-blend-mode:screen');
  expect(html).toContain('will-change:transform');
});
