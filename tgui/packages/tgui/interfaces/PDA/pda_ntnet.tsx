import { type ReactNode, useRef, useState } from 'react';
import { Box, Icon, Input, Tooltip } from 'tgui-core/components';
import { useBackend } from '../../backend';
import {
  findSite,
  formatAddress,
  formatTitle,
  NTNET_HOME,
  type NtnetLocation,
  type NtnetSite,
  parseAddress,
  siteIcon,
} from './NtnetAddress';
import { NtnetDocument } from './NtnetDocument';
import { isInteractive, NtnetInteractive } from './NtnetInteractive';

const LETTER_COLORS = [
  '#e0584e',
  '#e8833a',
  '#d4a72c',
  '#4caf6a',
  '#26a69a',
  '#3d8fe0',
  '#6c6ce0',
  '#a45ad6',
  '#d6548f',
  '#78909c',
];

const letterColor = (domain: string) => {
  let hash = 0;
  for (const char of domain) {
    hash = (hash * 31 + char.charCodeAt(0)) >>> 0;
  }
  return LETTER_COLORS[hash % LETTER_COLORS.length];
};

const SiteIcon = (props: {
  site?: { domain: string; icon?: unknown };
  size: number;
}) => {
  const { site, size } = props;
  const icon = siteIcon(site);
  const [broken, setBroken] = useState<string | null>(null);
  if (!site) {
    return (
      <Icon name="globe" style={{ fontSize: `${size}px`, color: ACCENT }} />
    );
  }
  const plate = {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    flexShrink: 0,
    width: `${size}px`,
    height: `${size}px`,
    borderRadius: `${Math.round(size * 0.22)}px`,
    overflow: 'hidden',
  };
  if (icon && broken !== icon) {
    return (
      <Box style={{ ...plate, background: '#ffffff' }}>
        <img
          src={icon}
          alt=""
          onError={() => setBroken(icon)}
          style={{ width: '100%', height: '100%', objectFit: 'cover' }}
        />
      </Box>
    );
  }
  return (
    <Box
      style={{
        ...plate,
        background: letterColor(site.domain),
        color: '#ffffff',
        fontSize: `${Math.round(size * 0.55)}px`,
        fontWeight: 'bold',
        lineHeight: 1,
      }}
    >
      {site.domain.slice(0, 1).toUpperCase()}
    </Box>
  );
};

const tabSite = (location: NtnetLocation, sites: NtnetSite[]) =>
  location.kind === 'site' ? findSite(sites, location.siteId) : undefined;

type NtnetResult = {
  site_id: string;
  slug: string;
  title: string;
  snippet: string;
};

type Tab = {
  id: number;
  history: NtnetLocation[];
  index: number;
};

type Data = {
  ntnet: {
    available: boolean;
    loading: boolean;
    failed?: boolean;
    catalog: NtnetSite[];
    zones: string[];
    theme: string;
    site: NtnetSite | null;
    page: {
      site_id: string;
      slug: string;
      tree: unknown;
      interactive?: unknown;
    } | null;
    slug: string | null;
    search: {
      query: string | null;
      results: NtnetResult[];
      pending: boolean;
      error: string | null;
    };
    login: {
      code: string | null;
      pending: boolean;
      retry_seconds: number;
      error: string | null;
    };
  };
};

const ACCENT = 'var(--nt-accent)';
const CHROME = 'var(--nt-chrome)';
const CHROME_DARK = 'var(--nt-deep)';
const CHROME_LINE = 'var(--nt-line)';
const MUTED = 'var(--nt-muted)';
const SURFACE = 'var(--nt-surface)';
const TEXT = 'var(--nt-text)';
const PAPER = 'var(--nt-paper)';
const SHEET = 'var(--nt-sheet)';
const SHEET_LINE = 'var(--nt-sheet-line)';
const INK = 'var(--nt-ink)';
const VOID = 'var(--nt-canvas)';
const PALETTES: Record<string, Record<string, string>> = {
  dark: {
    '--nt-accent': '#4a9eff',
    '--nt-chrome': '#1b1e24',
    '--nt-deep': '#101217',
    '--nt-line': '#33394a',
    '--nt-text': '#e6e9ef',
    '--nt-muted': '#8b93a3',
    '--nt-disabled': '#4d5361',
    '--nt-surface': 'rgba(255, 255, 255, 0.05)',
    '--nt-canvas': '#15171c',
    '--nt-paper': '#101217',
    '--nt-sheet': '#1c1f26',
    '--nt-sheet-line': '#2c313b',
    '--nt-ink': '#e6e9ef',
    '--nt-link': '#6aa9ff',
    '--nt-secure': '#57c785',
    '--nt-danger': '#ff8080',
  },
  light: {
    '--nt-accent': '#1a73e8',
    '--nt-chrome': '#dfe3ea',
    '--nt-deep': '#c3cad4',
    '--nt-line': '#aab3c0',
    '--nt-text': '#1f2328',
    '--nt-muted': '#5f6672',
    '--nt-disabled': '#a7aebb',
    '--nt-surface': 'rgba(0, 0, 0, 0.06)',
    '--nt-canvas': '#f2f3f5',
    '--nt-paper': '#e8eaed',
    '--nt-sheet': '#ffffff',
    '--nt-sheet-line': '#dfe3e8',
    '--nt-ink': '#16181d',
    '--nt-link': '#1a5fb4',
    '--nt-secure': '#1e8e3e',
    '--nt-danger': '#c5221f',
  },
};

export const pda_ntnet = () => {
  const { act, data } = useBackend<Data>();
  const {
    available,
    loading,
    catalog,
    zones,
    theme,
    site,
    page,
    slug,
    search,
  } = data.ntnet;
  const palette = PALETTES[theme] || PALETTES.dark;

  const [tabs, setTabs] = useState<Tab[]>(() => [
    {
      id: 1,
      history: [
        site && slug ? { kind: 'site', siteId: site.id, slug } : NTNET_HOME,
      ],
      index: 0,
    },
  ]);
  const [activeTab, setActiveTab] = useState(1);
  const [nextTab, setNextTab] = useState(2);
  const [addressKey, setAddressKey] = useState(0);
  const addressRef = useRef<HTMLInputElement>(null);

  const tab = tabs.find((entry) => entry.id === activeTab) || tabs[0];
  const current = tab.history[tab.index];
  const address = formatAddress(current, catalog);

  const sync = (location: NtnetLocation) => {
    if (location.kind === 'site') {
      act('ntnet_open', { site_id: location.siteId, slug: location.slug });
      return;
    }
    if (site) {
      act('Back');
    }
    if (location.kind === 'search') {
      act('ntnet_search', { query: location.query });
    }
  };

  const go = (location: NtnetLocation | null) => {
    if (!location) {
      return;
    }
    setTabs((entries) =>
      entries.map((entry) => {
        if (entry.id !== tab.id) {
          return entry;
        }
        const history = [...entry.history.slice(0, entry.index + 1), location];
        return { ...entry, history, index: history.length - 1 };
      }),
    );
    setAddressKey(addressKey + 1);
    sync(location);
  };

  const step = (offset: number) => {
    const index = tab.index + offset;
    if (index < 0 || index >= tab.history.length) {
      return;
    }
    setTabs((entries) =>
      entries.map((entry) =>
        entry.id === tab.id ? { ...entry, index } : entry,
      ),
    );
    sync(tab.history[index]);
  };

  const selectTab = (id: number) => {
    const target = tabs.find((entry) => entry.id === id);
    if (!target) {
      return;
    }
    setActiveTab(id);
    sync(target.history[target.index]);
  };

  const openTab = () => {
    setTabs((entries) => [
      ...entries,
      { id: nextTab, history: [NTNET_HOME], index: 0 },
    ]);
    setActiveTab(nextTab);
    setNextTab(nextTab + 1);
    sync(NTNET_HOME);
  };

  const closeTab = (id: number) => {
    if (tabs.length === 1) {
      act('Home');
      return;
    }
    const rest = tabs.filter((entry) => entry.id !== id);
    setTabs(rest);
    if (id === activeTab) {
      const neighbour =
        rest[
          Math.min(
            tabs.findIndex((entry) => entry.id === id),
            rest.length - 1,
          )
        ];
      setActiveTab(neighbour.id);
      sync(neighbour.history[neighbour.index]);
    }
  };

  const reload = () => {
    act('ntnet_refresh');
    if (current.kind === 'search') {
      act('ntnet_search', { query: current.query });
    }
  };

  const openSite = (siteId: string, pageSlug: string) =>
    go({ kind: 'site', siteId, slug: pageSlug });

  const openSearch = (query: string) => {
    const value = query.trim();
    if (value.length < 2) {
      return;
    }
    go({ kind: 'search', query: value });
  };

  const onPaper = current.kind === 'site';

  return (
    <Box
      style={{
        display: 'flex',
        flexDirection: 'column',
        height: '100%',
        background: CHROME_DARK,
        color: TEXT,
        ...palette,
      }}
    >
      <Box
        style={{
          display: 'flex',
          alignItems: 'flex-end',
          gap: '2px',
          padding: '5px 6px 0',
        }}
      >
        {tabs.map((entry) => (
          <BrowserTab
            key={entry.id}
            active={entry.id === tab.id}
            title={formatTitle(entry.history[entry.index], catalog)}
            site={tabSite(entry.history[entry.index], catalog)}
            onSelect={() => selectTab(entry.id)}
            onClose={() => closeTab(entry.id)}
          />
        ))}
        <Box
          onClick={openTab}
          style={{
            padding: '4px 10px 6px',
            cursor: 'pointer',
            color: MUTED,
            fontSize: '1.1rem',
          }}
        >
          <Icon name="plus" />
        </Box>
      </Box>

      <Box
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '5px',
          padding: '6px 8px',
          background: CHROME,
        }}
      >
        <ToolButton
          icon="arrow-left"
          tooltip="Назад"
          disabled={tab.index === 0}
          onClick={() => step(-1)}
        />
        <ToolButton
          icon="arrow-right"
          tooltip="Вперёд"
          disabled={tab.index >= tab.history.length - 1}
          onClick={() => step(1)}
        />
        <ToolButton icon="sync" tooltip="Обновить" onClick={reload} />
        <ToolButton
          icon="home"
          tooltip="Домашняя страница"
          onClick={() => go(NTNET_HOME)}
        />
        <Box
          onClick={() => addressRef.current?.focus()}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            flex: 1,
            minWidth: 0,
            height: '28px',
            padding: '0 12px',
            background: CHROME_DARK,
            border: `1px solid ${CHROME_LINE}`,
            borderRadius: '14px',
          }}
        >
          <Icon
            name={onPaper ? 'lock' : 'globe'}
            style={{
              color: onPaper ? 'var(--nt-secure)' : MUTED,
              fontSize: '0.8rem',
            }}
          />
          <Input
            key={`${address}|${addressKey}`}
            ref={addressRef}
            value={address}
            maxLength={120}
            placeholder="Введите адрес .ss13 или поисковый запрос"
            style={{
              flex: 1,
              minWidth: 0,
              width: 'auto',
              background: 'transparent',
              border: 0,
              borderRadius: 0,
              padding: 0,
              height: '26px',
              color: TEXT,
            }}
            onMouseDown={() => {
              if (document.activeElement !== addressRef.current) {
                setTimeout(() => addressRef.current?.select(), 0);
              }
            }}
            onEnter={(value) => go(parseAddress(value, catalog, zones))}
            onEscape={() => setAddressKey(addressKey + 1)}
          />
        </Box>
        <ToolButton
          icon="list"
          tooltip="Список сайтов"
          onClick={() => go({ kind: 'catalog' })}
        />
        <ToolButton
          icon="plus-square"
          tooltip="Создать сайт"
          onClick={() => go({ kind: 'create' })}
        />
        <ToolButton
          icon={theme === 'light' ? 'moon' : 'sun'}
          tooltip={theme === 'light' ? 'Тёмная тема' : 'Светлая тема'}
          onClick={() => act('ntnet_theme')}
        />
        <ToolButton
          icon="times"
          tooltip="Закрыть NTnet"
          onClick={() => act('Home')}
        />
      </Box>

      <Box
        style={{
          height: '2px',
          background: CHROME_DARK,
          overflow: 'hidden',
        }}
      >
        <Box
          style={{
            height: '100%',
            width: loading ? '75%' : '100%',
            opacity: loading ? 1 : 0,
            background: ACCENT,
            transition: 'width 1.2s ease-out, opacity 0.4s ease',
          }}
        />
      </Box>

      <Box
        style={{
          flex: 1,
          minHeight: 0,
          overflowY: 'auto',
          background: onPaper ? PAPER : VOID,
          color: onPaper ? INK : TEXT,
        }}
      >
        {current.kind === 'home' ? (
          <HomePage
            catalog={catalog}
            onSearch={openSearch}
            onOpen={openSite}
            onGo={go}
          />
        ) : current.kind === 'catalog' ? (
          <ListPage
            title="Сайты NTnet"
            subtitle={`В сети ${catalog.length} ${plural(catalog.length)}`}
            sites={catalog}
            empty="В NTnet пока нет ни одного сайта."
            onOpen={openSite}
          />
        ) : current.kind === 'search' ? (
          <SearchPage
            query={current.query}
            search={search}
            catalog={catalog}
            onOpen={openSite}
            onGo={go}
          />
        ) : current.kind === 'create' ? (
          <CreatePage />
        ) : current.kind === 'missing' ? (
          <MissingPage address={current.address} onSearch={openSearch} />
        ) : (
          <SitePage
            site={findSite(catalog, current.siteId)}
            slug={current.slug}
            page={page}
            failed={
              !!data.ntnet.failed &&
              site?.id === current.siteId &&
              slug === current.slug
            }
            onOpen={openSite}
            onRetry={reload}
          />
        )}
      </Box>

      <Box
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '12px',
          padding: '3px 10px',
          background: CHROME,
          borderTop: `1px solid ${CHROME_DARK}`,
          color: MUTED,
          fontSize: '0.75rem',
        }}
      >
        <Box style={{ flex: 1, minWidth: 0 }}>
          {loading
            ? `Загрузка ${address}…`
            : available
              ? 'Готово'
              : 'Нет связи с NTnet — показаны сохранённые данные'}
        </Box>
        <Box>
          <Icon name={available ? 'wifi' : 'exclamation-triangle'} mr={0.5} />
          {available ? 'NTnet' : 'Не в сети'}
        </Box>
      </Box>
    </Box>
  );
};

const plural = (
  count: number,
  one = 'сайт',
  few = 'сайта',
  many = 'сайтов',
) => {
  const tail = count % 100;
  if (tail > 10 && tail < 20) {
    return many;
  }
  switch (count % 10) {
    case 1:
      return one;
    case 2:
    case 3:
    case 4:
      return few;
    default:
      return many;
  }
};

const ToolButton = (props: {
  icon: string;
  tooltip: string;
  disabled?: boolean;
  onClick: () => void;
}) => (
  <Tooltip content={props.tooltip} position="bottom">
    <Box
      onClick={() => !props.disabled && props.onClick()}
      style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        width: '26px',
        height: '26px',
        borderRadius: '13px',
        cursor: props.disabled ? 'default' : 'pointer',
        color: props.disabled ? 'var(--nt-disabled)' : TEXT,
        background: SURFACE,
      }}
    >
      <Icon name={props.icon} />
    </Box>
  </Tooltip>
);

const BrowserTab = (props: {
  active: boolean;
  title: string;
  site?: NtnetSite;
  onSelect: () => void;
  onClose: () => void;
}) => (
  <Box
    onClick={props.onSelect}
    style={{
      display: 'flex',
      alignItems: 'center',
      gap: '6px',
      width: '190px',
      padding: '6px 8px',
      borderRadius: '8px 8px 0 0',
      cursor: 'pointer',
      background: props.active ? CHROME : SURFACE,
      color: props.active ? TEXT : MUTED,
    }}
  >
    <SiteIcon site={props.site} size={16} />
    <Box
      style={{
        flex: 1,
        minWidth: 0,
        overflow: 'hidden',
        textOverflow: 'ellipsis',
        whiteSpace: 'nowrap',
        fontSize: '0.85rem',
      }}
    >
      {props.title}
    </Box>
    <Box
      onClick={(event) => {
        event.stopPropagation();
        props.onClose();
      }}
      style={{ padding: '0 2px' }}
    >
      <Icon name="times" style={{ fontSize: '0.8rem' }} />
    </Box>
  </Box>
);

const HomePage = (props: {
  catalog: NtnetSite[];
  onSearch: (query: string) => void;
  onOpen: (siteId: string, slug: string) => void;
  onGo: (location: NtnetLocation) => void;
}) => {
  const [query, setQuery] = useState('');

  return (
    <Box
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        padding: '60px 24px 32px',
      }}
    >
      <Box style={{ fontSize: '3.4rem', fontWeight: 'bold', lineHeight: 1 }}>
        NT
        <Box as="span" style={{ color: ACCENT }}>
          net
        </Box>
      </Box>
      <Box mt={0.5} style={{ color: MUTED, letterSpacing: '2px' }}>
        СЕТЬ СТАНЦИОННЫХ САЙТОВ
      </Box>
      <Box
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '10px',
          width: '100%',
          maxWidth: '520px',
          height: '42px',
          margin: '28px 0 0',
          padding: '0 18px',
          background: SURFACE,
          border: `1px solid ${CHROME_LINE}`,
          borderRadius: '21px',
        }}
      >
        <Icon name="search" style={{ color: MUTED }} />
        <Input
          value={query}
          maxLength={80}
          placeholder="Поиск в NTnet"
          style={{
            flex: 1,
            minWidth: 0,
            width: 'auto',
            background: 'transparent',
            border: 0,
            borderRadius: 0,
            padding: 0,
            height: '40px',
            fontSize: '1.1rem',
            color: TEXT,
          }}
          onChange={setQuery}
          onEnter={(value) => props.onSearch(value)}
        />
        <Box
          onClick={() => props.onSearch(query)}
          style={{ cursor: 'pointer', color: ACCENT }}
        >
          <Icon name="arrow-right" />
        </Box>
      </Box>
      <Box mt={2} style={{ display: 'flex', gap: '10px' }}>
        <QuickAction
          icon="list"
          text="Список сайтов"
          onClick={() => props.onGo({ kind: 'catalog' })}
        />
        <QuickAction
          icon="plus"
          text="Создать сайт"
          onClick={() => props.onGo({ kind: 'create' })}
        />
      </Box>
      {props.catalog.length ? (
        <Box
          style={{
            display: 'flex',
            flexWrap: 'wrap',
            justifyContent: 'center',
            gap: '12px',
            maxWidth: '640px',
            marginTop: '32px',
          }}
        >
          {props.catalog.slice(0, 8).map((entry) => (
            <Box
              key={entry.id}
              onClick={() => props.onOpen(entry.id, entry.pages[0].slug)}
              style={{
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                gap: '8px',
                width: '96px',
                padding: '10px 4px',
                borderRadius: '10px',
                cursor: 'pointer',
                background: SURFACE,
              }}
            >
              <SiteIcon site={entry} size={44} />
              <Box
                style={{
                  width: '100%',
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  whiteSpace: 'nowrap',
                  textAlign: 'center',
                  fontSize: '0.75rem',
                  color: MUTED,
                }}
              >
                {entry.domain}
              </Box>
            </Box>
          ))}
        </Box>
      ) : null}
    </Box>
  );
};

const QuickAction = (props: {
  icon: string;
  text: string;
  onClick: () => void;
}) => (
  <Box
    onClick={props.onClick}
    style={{
      display: 'flex',
      alignItems: 'center',
      gap: '8px',
      padding: '8px 16px',
      borderRadius: '16px',
      cursor: 'pointer',
      background: SURFACE,
    }}
  >
    <Icon name={props.icon} style={{ color: ACCENT }} />
    {props.text}
  </Box>
);

const ListPage = (props: {
  title: string;
  subtitle: string;
  sites: NtnetSite[];
  empty: string;
  onOpen: (siteId: string, slug: string) => void;
}) => (
  <Box style={{ maxWidth: '760px', margin: '0 auto', padding: '28px 24px' }}>
    <Box style={{ fontSize: '1.6rem', fontWeight: 'bold' }}>{props.title}</Box>
    <Box mt={0.5} style={{ color: MUTED }}>
      {props.subtitle}
    </Box>
    <Box mt={2}>
      {props.sites.map((entry) => (
        <Box
          key={entry.id}
          onClick={() => props.onOpen(entry.id, entry.pages[0].slug)}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '14px',
            padding: '12px 14px',
            marginBottom: '8px',
            borderRadius: '10px',
            cursor: 'pointer',
            background: SURFACE,
          }}
        >
          <SiteIcon site={entry} size={32} />
          <Box style={{ flex: 1, minWidth: 0 }}>
            <Box bold>{entry.title}</Box>
            <Box style={{ color: MUTED, fontSize: '0.85rem' }}>
              {entry.domain}
            </Box>
          </Box>
          <Box style={{ color: MUTED, fontSize: '0.8rem' }}>
            {entry.pages.length} стр.
          </Box>
        </Box>
      ))}
      {!props.sites.length ? (
        <Box style={{ color: MUTED }}>{props.empty}</Box>
      ) : null}
    </Box>
  </Box>
);

const SearchPage = (props: {
  query: string;
  search: Data['ntnet']['search'];
  catalog: NtnetSite[];
  onOpen: (siteId: string, slug: string) => void;
  onGo: (location: NtnetLocation) => void;
}) => {
  const { query, search } = props;
  if (search.error) {
    return (
      <Box
        style={{ maxWidth: '760px', margin: '0 auto', padding: '28px 24px' }}
      >
        <Box style={{ fontSize: '1.6rem', fontWeight: 'bold' }}>
          Поиск не удался
        </Box>
        <Box mt={1} style={{ color: MUTED }}>
          {search.error}
        </Box>
      </Box>
    );
  }
  if (search.pending || search.query !== query) {
    return (
      <Box style={{ padding: '40px', textAlign: 'center', color: MUTED }}>
        <Icon name="spinner" spin mr={1} />
        Ищем «{query}» в NTnet…
      </Box>
    );
  }
  return (
    <Box style={{ maxWidth: '720px', padding: '18px 28px 40px' }}>
      <Box style={{ color: MUTED, fontSize: '0.8rem' }}>
        {search.results.length
          ? `Найдено ${search.results.length} ${plural(search.results.length, 'страница', 'страницы', 'страниц')} по запросу «${query}»`
          : `По запросу «${query}» ничего не найдено`}
      </Box>
      {search.results.map((entry) => {
        const site = findSite(props.catalog, entry.site_id);
        if (!site) {
          return null;
        }
        const first = site.pages[0].slug === entry.slug;
        return (
          <Box key={`${entry.site_id}.${entry.slug}`} mt={2.5}>
            <Box
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
                color: MUTED,
                fontSize: '0.8rem',
              }}
            >
              <SiteIcon site={site} size={18} />
              {site.domain}
              {first ? null : ` › ${entry.title}`}
            </Box>
            <Box
              onClick={() => props.onOpen(entry.site_id, entry.slug)}
              style={{
                marginTop: '2px',
                color: 'var(--nt-link)',
                fontSize: '1.25rem',
                cursor: 'pointer',
                textDecoration: 'underline',
              }}
            >
              {first ? site.title : entry.title}
            </Box>
            <Box mt={0.5} style={{ lineHeight: 1.5 }}>
              {highlight(entry.snippet, query)}
            </Box>
          </Box>
        );
      })}
      {search.results.length ? null : (
        <Box mt={2} style={{ color: MUTED, lineHeight: 1.6 }}>
          Попробуйте другие слова или откройте{' '}
          <Box
            as="span"
            onClick={() => props.onGo({ kind: 'catalog' })}
            style={{ color: 'var(--nt-link)', cursor: 'pointer' }}
          >
            список сайтов
          </Box>
          .
        </Box>
      )}
    </Box>
  );
};

const highlight = (snippet: string, query: string): ReactNode[] => {
  const words = query
    .toLowerCase()
    .split(/\s+/)
    .filter((word) => word.length > 1)
    .map((word) =>
      word.length > 6
        ? word.slice(0, -2)
        : word.length > 4
          ? word.slice(0, -1)
          : word,
    );
  const lowered = snippet.toLowerCase();
  const marks = new Array(snippet.length).fill(false);
  for (const word of words) {
    let at = lowered.indexOf(word);
    while (at >= 0) {
      marks.fill(true, at, at + word.length);
      at = lowered.indexOf(word, at + word.length);
    }
  }
  const parts: ReactNode[] = [];
  let start = 0;
  for (let index = 1; index <= snippet.length; index++) {
    if (index === snippet.length || marks[index] !== marks[start]) {
      const text = snippet.slice(start, index);
      parts.push(
        marks[start] ? (
          <b key={start}>{text}</b>
        ) : (
          <Box as="span" key={start} style={{ color: MUTED }}>
            {text}
          </Box>
        ),
      );
      start = index;
    }
  }
  return parts;
};

const CreatePage = () => {
  const { act, data } = useBackend<Data>();
  const { login } = data.ntnet;

  return (
    <Box style={{ maxWidth: '640px', margin: '0 auto', padding: '32px 24px' }}>
      <Box style={{ fontSize: '1.6rem', fontWeight: 'bold' }}>
        Свой сайт в NTnet
      </Box>
      <Box mt={1} style={{ color: MUTED, lineHeight: 1.5 }}>
        Страницы пишутся во внешнем редакторе. Получите одноразовый код, ссылка
        на редактор придёт Вам в чат. Код действует 15 минут, передавать его
        другим нельзя.
      </Box>
      <Box
        mt={2}
        onClick={() =>
          !login.pending && !login.retry_seconds && act('ntnet_login')
        }
        style={{
          display: 'inline-flex',
          alignItems: 'center',
          gap: '10px',
          padding: '10px 20px',
          borderRadius: '18px',
          cursor: login.pending || login.retry_seconds ? 'default' : 'pointer',
          background: login.pending || login.retry_seconds ? SURFACE : ACCENT,
          color: login.pending || login.retry_seconds ? MUTED : CHROME_DARK,
          fontWeight: 'bold',
        }}
      >
        <Icon name="key" />
        {login.pending ? 'Получение кода…' : 'Получить код редактора'}
      </Box>
      {login.retry_seconds > 0 && !login.pending ? (
        <Box mt={1} style={{ color: MUTED }}>
          Новый код можно запросить через {login.retry_seconds} с.
        </Box>
      ) : null}
      {login.code ? (
        <Box
          mt={2}
          style={{
            padding: '16px 20px',
            borderRadius: '10px',
            background: SURFACE,
            border: `1px solid ${ACCENT}`,
          }}
        >
          <Box style={{ color: MUTED }}>Ваш код для входа в редактор</Box>
          <Box
            mt={0.5}
            style={{
              fontSize: '1.8rem',
              fontWeight: 'bold',
              letterSpacing: '4px',
            }}
          >
            {login.code}
          </Box>
        </Box>
      ) : null}
      {login.error ? (
        <Box mt={2} style={{ color: 'var(--nt-danger)' }}>
          {login.error}
        </Box>
      ) : null}
    </Box>
  );
};

const MissingPage = (props: {
  address: string;
  onSearch: (query: string) => void;
}) => (
  <Box style={{ maxWidth: '560px', margin: '0 auto', padding: '70px 24px' }}>
    <Icon name="unlink" style={{ fontSize: '3rem', color: MUTED }} />
    <Box mt={2} style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>
      Не удаётся найти этот сайт
    </Box>
    <Box mt={1} style={{ color: MUTED, lineHeight: 1.5 }}>
      Адрес <b>{props.address}</b> не зарегистрирован в NTnet или указанной
      страницы больше нет. Проверьте написание адреса.
    </Box>
    <Box
      mt={2}
      onClick={() => props.onSearch(props.address)}
      style={{ color: ACCENT, cursor: 'pointer' }}
    >
      <Icon name="search" mr={1} />
      Искать «{props.address}» в NTnet
    </Box>
  </Box>
);

const renderPage = (
  page: NonNullable<Data['ntnet']['page']>,
  title: string,
  onOpen: (siteId: string, slug: string) => void,
) => {
  const document = <NtnetDocument tree={page.tree} onNavigate={onOpen} />;
  const interactive = isInteractive(page.interactive);
  if (!interactive) {
    return document;
  }
  return (
    <NtnetInteractive
      interactive={interactive}
      title={title}
      fallback={document}
      onNavigate={onOpen}
    />
  );
};

const SitePage = (props: {
  site: NtnetSite | undefined;
  slug: string;
  page: Data['ntnet']['page'];
  failed: boolean;
  onOpen: (siteId: string, slug: string) => void;
  onRetry: () => void;
}) => {
  const { site, slug, page } = props;
  if (!site) {
    return (
      <Box style={{ padding: '40px', textAlign: 'center', color: MUTED }}>
        Сайт больше не доступен в NTnet.
      </Box>
    );
  }
  const ready = page && page.site_id === site.id && page.slug === slug;
  return (
    <Box style={{ maxWidth: '820px', margin: '0 auto', background: SHEET }}>
      <Box
        style={{
          display: 'flex',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: '14px',
          padding: '12px 24px',
          borderBottom: `1px solid ${SHEET_LINE}`,
        }}
      >
        <Box bold>{site.title}</Box>
        <Box style={{ flex: 1 }} />
        {site.pages.map((entry) => (
          <Box
            key={entry.slug}
            onClick={() => props.onOpen(site.id, entry.slug)}
            style={{
              cursor: 'pointer',
              fontWeight: entry.slug === slug ? 'bold' : 'normal',
              color: entry.slug === slug ? INK : 'var(--nt-link)',
            }}
          >
            {entry.title}
          </Box>
        ))}
      </Box>
      <Box style={{ padding: '20px 24px 48px' }}>
        {ready ? (
          renderPage(page, site.title, props.onOpen)
        ) : (
          <Box style={{ color: MUTED }}>
            {props.failed ? (
              <>
                Страница не загрузилась.{' '}
                <Box
                  as="span"
                  onClick={props.onRetry}
                  style={{
                    color: 'var(--nt-link)',
                    cursor: 'pointer',
                    textDecoration: 'underline',
                  }}
                >
                  Повторить
                </Box>
              </>
            ) : (
              <>
                <Icon name="spinner" spin mr={1} />
                Загрузка страницы…
              </>
            )}
          </Box>
        )}
      </Box>
    </Box>
  );
};
