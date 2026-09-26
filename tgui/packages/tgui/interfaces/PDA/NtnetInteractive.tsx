import { useEffect, useRef, useState } from 'react';

import { useBackend } from '../../backend';

const SANDBOX_ORIGINS =
  'https://sandbox.wiki-ss13.space https://sandbox-ru.wiki-ss13.space';
const MEDIA_ORIGINS =
  'https://media.wiki-ss13.space https://media-ru.wiki-ss13.space';
const SANDBOX_URL =
  /^https:\/\/sandbox\.wiki-ss13\.space\/i\/[a-f0-9]{32}\/[a-z0-9][a-z0-9-]{0,62}$/;
const SITE_ID = /^[a-f0-9]{32}$/;
const PAGE_SLUG = /^[a-z0-9](?:[a-z0-9-]{0,62}[a-z0-9])?$/;
const FRAME_SANDBOX = 'allow-scripts';
export const FRAME_POLICY = [
  "default-src 'none'",
  "script-src 'unsafe-inline'",
  "style-src 'unsafe-inline'",
  `img-src ${MEDIA_ORIGINS} data:`,
  `media-src ${MEDIA_ORIGINS}`,
  'font-src data:',
  `connect-src ${SANDBOX_ORIGINS}`,
  "form-action 'none'",
  "frame-src 'none'",
  "child-src 'none'",
  "worker-src 'none'",
  "object-src 'none'",
  "base-uri 'none'",
  'sandbox allow-scripts',
].join('; ');
const FRAME_POLICY_VERSION = 3;
const PROBE_TIMEOUT = 700;
const LAG_TICK = 1000;
const LAG_LIMIT = 4000;
const CSP_PROBE =
  '<meta http-equiv="Content-Security-Policy" content="script-src \'none\'">' +
  '<script>parent.postMessage("ntnet-probe-csp","*")</script>';
const SANDBOX_PROBE =
  '<script>parent.postMessage("ntnet-probe-sandbox","*")</script>';

export type Interactive = { url: string; version: number };

type Viewer = { token: string | null; error: string | null };

type Data = { ntnet: { viewer?: Viewer } };

export const frameAddress = (url: string) =>
  `${url}?csp=${FRAME_POLICY_VERSION}`;

export const tokenRequest = (value: unknown): { renew: boolean } | null => {
  if (!value || typeof value !== 'object') {
    return null;
  }
  const { ntnet, renew } = value as Record<string, unknown>;
  return ntnet === 'token' ? { renew: renew === true } : null;
};

export const isInteractive = (value: unknown): Interactive | null => {
  if (!value || typeof value !== 'object') {
    return null;
  }
  const { url, version } = value as Record<string, unknown>;
  if (typeof url !== 'string' || !SANDBOX_URL.test(url)) {
    return null;
  }
  return { url, version: typeof version === 'number' ? version : 1 };
};

export const navigationRequest = (
  value: unknown,
): { siteId: string; slug: string } | null => {
  if (!value || typeof value !== 'object') {
    return null;
  }
  const { ntnet, site, slug } = value as Record<string, unknown>;
  if (
    ntnet !== 'navigate' ||
    typeof site !== 'string' ||
    typeof slug !== 'string' ||
    !SITE_ID.test(site) ||
    !PAGE_SLUG.test(slug)
  ) {
    return null;
  }
  return { siteId: site, slug };
};

let rendererCheck: Promise<boolean> | null = null;

const escapes = (): Promise<boolean> =>
  new Promise((resolve) => {
    let settled = false;
    const frames: HTMLIFrameElement[] = [];
    const finish = (leaked: boolean) => {
      if (settled) {
        return;
      }
      settled = true;
      window.removeEventListener('message', listener);
      window.clearTimeout(timer);
      for (const frame of frames) {
        frame.remove();
      }
      resolve(leaked);
    };
    const listener = (event: MessageEvent) => {
      if (
        event.data === 'ntnet-probe-csp' ||
        event.data === 'ntnet-probe-sandbox'
      ) {
        finish(true);
      }
    };
    const timer = window.setTimeout(() => finish(false), PROBE_TIMEOUT);
    window.addEventListener('message', listener);
    try {
      for (const [markup, sandbox] of [
        [CSP_PROBE, null],
        [SANDBOX_PROBE, ''],
      ] as [string, string | null][]) {
        const frame = document.createElement('iframe');
        frame.style.display = 'none';
        if (sandbox !== null) {
          frame.setAttribute('sandbox', sandbox);
        }
        frame.srcdoc = markup;
        document.body.appendChild(frame);
        frames.push(frame);
      }
    } catch {
      finish(true);
    }
  });

const rendererAllows = (): Promise<boolean> => {
  if (!rendererCheck) {
    rendererCheck = (async () => {
      const frame = document.createElement('iframe');
      if (!('sandbox' in frame) || !('srcdoc' in frame)) {
        return false;
      }
      return !(await escapes());
    })().catch(() => false);
  }
  return rendererCheck;
};

type Props = {
  interactive: Interactive;
  title: string;
  fallback: React.ReactNode;
  onNavigate: (siteId: string, slug: string) => void;
};

export const NtnetInteractive = (props: Props) => {
  const { interactive, title, fallback, onNavigate } = props;
  const { act, data } = useBackend<Data>();
  const [allowed, setAllowed] = useState<boolean | null>(null);
  const [stopped, setStopped] = useState(false);
  const [loadedUrl, setLoadedUrl] = useState<string | null>(null);
  const lastTick = useRef(0);
  const frame = useRef<HTMLIFrameElement | null>(null);
  const wantsToken = useRef(false);
  const staleToken = useRef<string | null>(null);
  const viewer = useRef<Viewer | undefined>(undefined);
  viewer.current = data.ntnet?.viewer;

  const deliverToken = () => {
    const target = frame.current?.contentWindow;
    const current = viewer.current;
    if (!wantsToken.current || !target || !current) {
      return;
    }
    if (current.token && current.token !== staleToken.current) {
      target.postMessage({ ntnet: 'token', token: current.token }, '*');
      staleToken.current = null;
    } else if (current.error) {
      target.postMessage({ ntnet: 'token', error: current.error }, '*');
    } else {
      return;
    }
    wantsToken.current = false;
  };

  useEffect(deliverToken, [
    data.ntnet?.viewer?.token,
    data.ntnet?.viewer?.error,
  ]);

  useEffect(() => {
    let alive = true;
    rendererAllows().then((result) => {
      if (alive) {
        setAllowed(result);
      }
    });
    return () => {
      alive = false;
    };
  }, []);

  useEffect(() => {
    setStopped(false);
    wantsToken.current = false;
    staleToken.current = null;
  }, [interactive.url]);

  useEffect(() => {
    const listener = (event: MessageEvent) => {
      if (!frame.current || event.source !== frame.current.contentWindow) {
        return;
      }
      const asked = tokenRequest(event.data);
      if (asked) {
        wantsToken.current = true;
        if (asked.renew) {
          staleToken.current = viewer.current?.token || null;
          act('ntnet_token', { renew: 1 });
        } else if (!viewer.current?.token) {
          act('ntnet_token');
        }
        deliverToken();
        return;
      }
      const request = navigationRequest(event.data);
      if (request) {
        onNavigate(request.siteId, request.slug);
      }
    };
    window.addEventListener('message', listener);
    return () => window.removeEventListener('message', listener);
  }, [onNavigate, act]);

  useEffect(() => {
    if (allowed !== true || stopped) {
      return;
    }
    lastTick.current = Date.now();
    const timer = window.setInterval(() => {
      const now = Date.now();
      const lag = now - lastTick.current - LAG_TICK;
      lastTick.current = now;
      if (lag > LAG_LIMIT) {
        setStopped(true);
      }
    }, LAG_TICK);
    return () => window.clearInterval(timer);
  }, [allowed, stopped, interactive.url]);

  if (allowed === null) {
    return (
      <div style={{ color: '#5c6b77' }}>Проверка интерактивного режима…</div>
    );
  }
  if (allowed === false || stopped) {
    return (
      <div>
        <div
          style={{
            marginBottom: '12px',
            padding: '8px 12px',
            border: '1px solid #d7cbb6',
            borderRadius: '6px',
            color: '#5c6b77',
          }}
        >
          {stopped
            ? 'Интерактивная страница остановлена. Показана обычная версия.'
            : 'Интерактивные страницы не поддерживаются этим клиентом. Показана обычная версия.'}
        </div>
        {fallback}
      </div>
    );
  }
  return (
    <div style={{ position: 'relative' }}>
      <div
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '12px',
          marginBottom: '8px',
          color: '#5c6b77',
        }}
      >
        <span>Интерактивная страница</span>
        <span
          onClick={() => setStopped(true)}
          style={{ cursor: 'pointer', textDecoration: 'underline' }}
        >
          Остановить
        </span>
      </div>
      <iframe
        key={interactive.url}
        title={title}
        ref={(node) => {
          frame.current = node;
          if (!node || node.dataset.ntnetLoaded === interactive.url) {
            return;
          }
          node.dataset.ntnetLoaded = interactive.url;
          node.setAttribute('csp', FRAME_POLICY);
          node.setAttribute('src', frameAddress(interactive.url));
        }}
        sandbox={FRAME_SANDBOX}
        allow=""
        referrerPolicy="no-referrer"
        onLoad={() => setLoadedUrl(interactive.url)}
        style={{
          width: '100%',
          height: 'calc(100vh - 260px)',
          minHeight: '620px',
          border: '1px solid #d7cbb6',
          borderRadius: '6px',
          background: '#ffffff',
        }}
      />
      {loadedUrl !== interactive.url && (
        <div
          style={{
            position: 'absolute',
            top: '32px',
            left: 0,
            right: 0,
            padding: '24px',
            textAlign: 'center',
            color: '#5c6b77',
          }}
        >
          Загрузка интерактивной страницы…
        </div>
      )}
    </div>
  );
};
