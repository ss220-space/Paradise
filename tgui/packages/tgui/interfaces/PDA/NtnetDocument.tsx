import {
  type CSSProperties,
  createElement,
  type ReactNode,
  useMemo,
} from 'react';

const TAGS = new Set([
  'abbr',
  'address',
  'article',
  'aside',
  'b',
  'bdi',
  'bdo',
  'blockquote',
  'br',
  'button',
  'caption',
  'cite',
  'code',
  'col',
  'colgroup',
  'data',
  'dd',
  'del',
  'details',
  'dfn',
  'dialog',
  'div',
  'dl',
  'dt',
  'em',
  'figcaption',
  'figure',
  'footer',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'header',
  'hgroup',
  'hr',
  'i',
  'ins',
  'kbd',
  'li',
  'main',
  'mark',
  'menu',
  'meter',
  'nav',
  'ol',
  'output',
  'p',
  'picture',
  'pre',
  'progress',
  'q',
  'rp',
  'rt',
  'ruby',
  's',
  'samp',
  'section',
  'small',
  'span',
  'strong',
  'sub',
  'summary',
  'sup',
  'table',
  'tbody',
  'td',
  'tfoot',
  'th',
  'thead',
  'time',
  'tr',
  'u',
  'ul',
  'var',
  'wbr',
]);
const MAX_DEPTH = 16;
const MAX_NODES = 1024;
const STYLE_NAMES = new Set([
  'alignContent',
  'alignItems',
  'alignSelf',
  'aspectRatio',
  'backdropFilter',
  'background',
  'backgroundAttachment',
  'backgroundBlendMode',
  'backgroundClip',
  'backgroundColor',
  'backgroundImage',
  'backgroundOrigin',
  'backgroundPosition',
  'backgroundRepeat',
  'backgroundSize',
  'border',
  'borderBottom',
  'borderBottomColor',
  'borderBottomLeftRadius',
  'borderBottomRightRadius',
  'borderBottomStyle',
  'borderBottomWidth',
  'borderCollapse',
  'borderColor',
  'borderLeft',
  'borderLeftColor',
  'borderLeftStyle',
  'borderLeftWidth',
  'borderRadius',
  'borderRight',
  'borderRightColor',
  'borderRightStyle',
  'borderRightWidth',
  'borderSpacing',
  'borderStyle',
  'borderTop',
  'borderTopColor',
  'borderTopLeftRadius',
  'borderTopRightRadius',
  'borderTopStyle',
  'borderTopWidth',
  'borderWidth',
  'bottom',
  'boxShadow',
  'boxSizing',
  'captionSide',
  'clear',
  'clipPath',
  'color',
  'columnCount',
  'columnGap',
  'columnRule',
  'columnRuleColor',
  'columnRuleStyle',
  'columnRuleWidth',
  'cursor',
  'direction',
  'display',
  'filter',
  'flex',
  'flexBasis',
  'flexDirection',
  'flexGrow',
  'flexShrink',
  'flexWrap',
  'float',
  'fontFamily',
  'fontSize',
  'fontStretch',
  'fontStyle',
  'fontVariant',
  'fontWeight',
  'gap',
  'gridArea',
  'gridAutoColumns',
  'gridAutoFlow',
  'gridAutoRows',
  'gridColumn',
  'gridRow',
  'gridTemplateAreas',
  'gridTemplateColumns',
  'gridTemplateRows',
  'height',
  'hyphens',
  'inset',
  'isolation',
  'justifyContent',
  'justifyItems',
  'justifySelf',
  'left',
  'letterSpacing',
  'lineHeight',
  'listStyle',
  'listStylePosition',
  'listStyleType',
  'margin',
  'marginBottom',
  'marginLeft',
  'marginRight',
  'marginTop',
  'maxHeight',
  'maxWidth',
  'minHeight',
  'minWidth',
  'mixBlendMode',
  'objectFit',
  'objectPosition',
  'opacity',
  'order',
  'outline',
  'outlineColor',
  'outlineOffset',
  'outlineStyle',
  'outlineWidth',
  'overflow',
  'overflowWrap',
  'overflowX',
  'overflowY',
  'padding',
  'paddingBottom',
  'paddingLeft',
  'paddingRight',
  'paddingTop',
  'placeContent',
  'placeItems',
  'placeSelf',
  'pointerEvents',
  'position',
  'resize',
  'right',
  'rotate',
  'rowGap',
  'scale',
  'scrollBehavior',
  'scrollbarColor',
  'scrollbarWidth',
  'tabSize',
  'tableLayout',
  'textAlign',
  'textDecoration',
  'textDecorationColor',
  'textDecorationStyle',
  'textDecorationThickness',
  'textIndent',
  'textOrientation',
  'textOverflow',
  'textShadow',
  'textTransform',
  'textUnderlineOffset',
  'textWrap',
  'top',
  'transform',
  'transformOrigin',
  'transition',
  'transitionDelay',
  'transitionDuration',
  'transitionProperty',
  'transitionTimingFunction',
  'translate',
  'userSelect',
  'verticalAlign',
  'visibility',
  'whiteSpace',
  'width',
  'wordBreak',
  'wordSpacing',
  'writingMode',
  'zIndex',
]);
const VOID_TAGS = new Set(['br', 'hr', 'wbr', 'col']);
const DEFAULT_STYLES: Record<string, CSSProperties> = {
  dialog: { display: 'block', position: 'static' },
  pre: { whiteSpace: 'pre-wrap' },
  img: { maxWidth: '100%' },
  video: { maxWidth: '100%' },
};
const POSITIONS = new Set(['static', 'relative', 'absolute']);
const MAX_VALUE = 512;
const STYLE_NAME = /^(?:--[\w-]{1,40}|[a-zA-Z][a-zA-Z0-9]{1,39})$/;
const VALUE_FORBIDDEN =
  /(?:url|image-set|cross-fade|element|attr|paint|src)\s*\(|expression|binding|behavior|progid:|javascript:|<\/|[{};<]|@|\\/i;
const MEDIA_URL =
  /^https:\/\/media\.wiki-ss13\.space\/[a-z0-9]{32}\/[a-f0-9]{16}\.(?:png|jpg|gif|webp|mp4)$/;

const sanitizeStyle = (value: unknown): CSSProperties | undefined => {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return undefined;
  }
  const style: Record<string, string> = {};
  for (const [name, item] of Object.entries(value)) {
    if (
      (STYLE_NAMES.has(name) || STYLE_NAME.test(name)) &&
      typeof item === 'string' &&
      item.length <= MAX_VALUE &&
      (name !== 'position' || POSITIONS.has(item.toLowerCase())) &&
      !VALUE_FORBIDDEN.test(item)
    ) {
      style[name] = item;
    }
  }
  return Object.keys(style).length ? (style as CSSProperties) : undefined;
};

const SCOPE = 'ntnet-doc';
const MAX_CSS = 32768;
const NAME_VALUE = /^[\w\u0400-\u04ff -]{1,120}$/;
const CSS_FORBIDDEN =
  /(?:url|image-set|cross-fade|element|attr|paint|src)\s*\(|@import|@charset|@font-face|expression\s*\(|progid:|javascript:|behavior\s*:|binding\s*:|<\/|\\|position\s*:\s*(?:fixed|sticky)/i;

const ATTRIBUTES: Record<string, string> = {
  class: 'className',
  id: 'id',
  colspan: 'colSpan',
  high: 'high',
  low: 'low',
  max: 'max',
  min: 'min',
  open: 'open',
  optimum: 'optimum',
  reversed: 'reversed',
  rowspan: 'rowSpan',
  span: 'span',
  start: 'start',
  title: 'title',
  value: 'value',
};

const COUNT_ATTRIBUTES = new Set(['colspan', 'rowspan', 'span']);

const nodeProps = (node: Record<string, unknown>) => {
  const props: Record<string, unknown> = {};
  for (const [name, property] of Object.entries(ATTRIBUTES)) {
    const value = node[name];
    const limit = COUNT_ATTRIBUTES.has(name) ? 64 : 1000000;
    if (value === true) {
      props[property] = value;
    } else if (typeof value === 'number' && value >= 0 && value <= limit) {
      props[property] = value;
    } else if (typeof value === 'string') {
      if (name === 'title') {
        props[property] = value.slice(0, MAX_VALUE);
      } else if (NAME_VALUE.test(value)) {
        props[property] = value;
      }
    }
  }
  return props;
};

const sanitizeCss = (value: unknown): string => {
  if (typeof value !== 'string' || !value || value.length > MAX_CSS) {
    return '';
  }
  if (CSS_FORBIDDEN.test(value)) {
    return '';
  }
  let depth = 0;
  for (const character of value) {
    if (character === '{') {
      depth++;
    } else if (character === '}' && --depth < 0) {
      return '';
    }
  }
  return depth === 0 ? value : '';
};

type Props = {
  tree: unknown;
  onNavigate: (siteId: string, slug: string) => void;
};

const parseTree = (source: unknown): unknown => {
  if (typeof source !== 'string') {
    return source;
  }
  try {
    return JSON.parse(source);
  } catch {
    return null;
  }
};

export const NtnetDocument = ({ tree: source, onNavigate }: Props) => {
  const tree = useMemo(() => parseTree(source), [source]);
  const css = sanitizeCss(
    tree && typeof tree === 'object'
      ? (tree as Record<string, unknown>).css
      : null,
  );
  let remaining = MAX_NODES;
  const render = (value: unknown, depth: number, key: string): ReactNode => {
    if (
      --remaining < 0 ||
      depth > MAX_DEPTH ||
      !value ||
      typeof value !== 'object' ||
      Array.isArray(value)
    ) {
      return null;
    }
    const node = value as Record<string, unknown>;
    if (node.type === 'text') {
      return typeof node.text === 'string' ? node.text : null;
    }
    if (
      typeof node.type !== 'string' ||
      (!['link', 'image', 'video'].includes(node.type) && !TAGS.has(node.type))
    ) {
      return null;
    }
    if (VOID_TAGS.has(node.type)) {
      return createElement(node.type, {
        key,
        style: sanitizeStyle(node.style),
        ...nodeProps(node),
      });
    }
    if (node.type === 'image' || node.type === 'video') {
      if (typeof node.src !== 'string' || !MEDIA_URL.test(node.src)) {
        return null;
      }
      if (node.type === 'image') {
        return (
          <img
            key={key}
            src={node.src}
            alt={typeof node.alt === 'string' ? node.alt.slice(0, 160) : ''}
            style={{ ...DEFAULT_STYLES.img, ...sanitizeStyle(node.style) }}
            {...nodeProps(node)}
          />
        );
      }
      return (
        <video
          key={key}
          src={node.src}
          controls
          preload="metadata"
          style={{ ...DEFAULT_STYLES.video, ...sanitizeStyle(node.style) }}
          {...nodeProps(node)}
        />
      );
    }
    const children: ReactNode[] = [];
    if (Array.isArray(node.children)) {
      for (
        let index = 0;
        index < node.children.length && remaining > 0;
        index++
      ) {
        children.push(
          render(node.children[index], depth + 1, `${key}.${index}`),
        );
      }
    }
    if (node.type === 'link') {
      if (typeof node.site_id !== 'string' || typeof node.slug !== 'string') {
        return null;
      }
      const siteId = node.site_id;
      const slug = node.slug;
      return (
        <span
          key={key}
          style={{
            color: 'var(--nt-link, #1a5fb4)',
            textDecoration: 'underline',
            cursor: 'pointer',
            ...sanitizeStyle(node.style),
          }}
          onClick={() => onNavigate(siteId, slug)}
          {...nodeProps(node)}
        >
          {children}
        </span>
      );
    }
    return createElement(
      node.type,
      {
        key,
        style: { ...DEFAULT_STYLES[node.type], ...sanitizeStyle(node.style) },
        ...nodeProps(node),
      },
      children,
    );
  };
  return (
    <div
      className={SCOPE}
      style={{
        position: 'relative',
        isolation: 'isolate',
        overflow: 'hidden',
        overflowWrap: 'anywhere',
      }}
    >
      {css ? <style>{css}</style> : null}
      {render(tree, 0, 'root')}
    </div>
  );
};
