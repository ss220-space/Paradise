/**
 * Browser-agnostic abstraction of key-value web storage.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const IMPL_HUB_STORAGE = 1;
export const IMPL_IFRAME_INDEXED_DB = 2;

type StorageImplementation =
  | typeof IMPL_HUB_STORAGE
  | typeof IMPL_IFRAME_INDEXED_DB;

type StorageBackend = {
  impl: StorageImplementation;
  get(key: string): Promise<any>;
  set(key: string, value: any): Promise<void>;
  remove(key: string): Promise<void>;
  clear(): Promise<void>;
  processChatMessages(messages): Promise<void>;
  getChatMessages(): Promise<any>;
  iframe_check(): Promise<boolean>;
};

const testGeneric = (testFn: () => boolean) => (): boolean => {
  try {
    return Boolean(testFn());
  } catch {
    return false;
  }
};

const testHubStorage = testGeneric(
  () => window.hubStorage && !!window.hubStorage.getItem
);

const STORAGE_CDN_TIMEOUT = 5000;
// Сколько ждём, пока BYOND поднимет byondstorage после смены browser-options.
// Ждать без предела нельзя: событие может не прийти вовсе, а backendPromise тогда не
// разрешается никогда, и всё, что дёргает storage, висит вместе с ним.
const BYOND_STORAGE_TIMEOUT = 2000;
const persistedStorageKeys = ['panel-settings', 'chat-state', 'chat-messages'];
const legacyHubMigrationKeys = ['panel-settings'];

/**
 * Ждёт события о готовности byondstorage, но не дольше BYOND_STORAGE_TIMEOUT.
 */
const waitForByondStorage = (): Promise<void> =>
  new Promise((resolve) => {
    const done = () => {
      clearTimeout(timeout);
      document.removeEventListener('byondstorageupdated', listener);
      // Событие приходит *до* того, как byondstorage создан, поэтому ждём тик.
      setTimeout(resolve, 1);
    };
    const listener = () => done();
    const timeout = setTimeout(done, BYOND_STORAGE_TIMEOUT);

    document.addEventListener('byondstorageupdated', listener, { once: true });
  });

class HubStorageBackend implements StorageBackend {
  public impl: StorageImplementation;

  constructor() {
    this.impl = IMPL_HUB_STORAGE;
  }

  async get(key: string): Promise<any> {
    const value = await window.hubStorage.getItem('paradise-' + key);
    if (typeof value === 'string') {
      return JSON.parse(value);
    }
    return undefined;
  }

  async set(key: string, value: any): Promise<void> {
    window.hubStorage.setItem('paradise-' + key, JSON.stringify(value));
  }

  async remove(key: string): Promise<void> {
    window.hubStorage.removeItem('paradise-' + key);
  }

  async clear(): Promise<void> {
    window.hubStorage.clear();
  }

  async processChatMessages(messages): Promise<void> {
    window.hubStorage.setItem(
      'paradise-chat-messages',
      JSON.stringify(messages)
    );
  }

  async getChatMessages(): Promise<any> {
    const value = window.hubStorage.getItem('paradise-chat-messages');
    if (typeof value === 'string') {
      return JSON.parse(value);
    } else {
      return undefined;
    }
  }
  async iframe_check(): Promise<boolean> {
    return false;
  }
}

/**
 * Заглушка на случай, когда не поднялось ни хранилище в iframe, ни byondstorage.
 * Настройки в таком раунде не переживут перезапуск — но окна открываются, а это важнее.
 */
class NullStorageBackend implements StorageBackend {
  public impl: StorageImplementation;

  constructor() {
    this.impl = IMPL_HUB_STORAGE;
  }

  async get(): Promise<any> {
    return undefined;
  }

  async set(): Promise<void> {}

  async remove(): Promise<void> {}

  async clear(): Promise<void> {}

  async processChatMessages(): Promise<void> {}

  async getChatMessages(): Promise<any> {
    return undefined;
  }

  async iframe_check(): Promise<boolean> {
    return false;
  }
}

export class IFrameIndexedDbBackend implements StorageBackend {
  public impl: StorageImplementation;

  private documentElement: HTMLIFrameElement;
  private iframeWindow: Window;

  constructor() {
    this.impl = IMPL_IFRAME_INDEXED_DB;
  }

  async ready(): Promise<boolean | null> {
    const iframe = document.createElement('iframe');
    iframe.style.display = 'none';
    iframe.src = Byond.storageCdn;

    const completePromise: Promise<boolean> = new Promise((resolve) => {
      const listener = (message: MessageEvent) => {
        if (
          message.source === iframe.contentWindow &&
          message.data === 'ready'
        ) {
          resolveReady(true);
        }
      };
      const resolveReady = (ready: boolean) => {
        clearTimeout(timeout);
        window.removeEventListener('message', listener);
        resolve(ready);
      };
      const timeout = setTimeout(
        () => resolveReady(false),
        STORAGE_CDN_TIMEOUT
      );

      fetch(Byond.storageCdn, { method: 'HEAD' })
        .then((response) => {
          if (response.status !== 200) {
            resolveReady(false);
          }
        })
        .catch(() => {
          resolveReady(false);
        });

      window.addEventListener('message', listener);
    });

    this.documentElement = document.body.appendChild(iframe);
    if (!this.documentElement.contentWindow) {
      return new Promise((res) => res(false));
    }

    this.iframeWindow = this.documentElement.contentWindow;

    return completePromise;
  }

  async get(key: string): Promise<any> {
    const promise = new Promise((resolve) => {
      const listener = (message: MessageEvent) => {
        if (
          message.source === this.iframeWindow &&
          message.data.key &&
          message.data.key === key
        ) {
          clearTimeout(timeout);
          window.removeEventListener('message', listener);
          resolve(message.data.value);
        }
      };
      const timeout = setTimeout(() => {
        window.removeEventListener('message', listener);
        resolve(undefined);
      }, STORAGE_CDN_TIMEOUT);

      window.addEventListener('message', listener);
    });

    this.iframeWindow.postMessage({ type: 'get', key: key }, '*');
    return promise;
  }

  async set(key: string, value: any): Promise<void> {
    this.iframeWindow.postMessage({ type: 'set', key: key, value: value }, '*');
  }

  async remove(key: string): Promise<void> {
    this.iframeWindow.postMessage({ type: 'remove', key: key }, '*');
  }

  async clear(): Promise<void> {
    this.iframeWindow.postMessage({ type: 'clear' }, '*');
  }

  async destroy(): Promise<void> {
    document.body.removeChild(this.documentElement);
  }

  async processChatMessages(messages) {
    this.iframeWindow.postMessage(
      { type: 'processChatMessages', messages: messages },
      '*'
    );
  }

  async getChatMessages(): Promise<any> {
    const promise = new Promise((resolve) => {
      window.addEventListener('message', (message) => {
        if (message.data.messages) {
          resolve(message.data.messages);
        }
      });
    });

    this.iframeWindow.postMessage({ type: 'getChatMessages' }, '*');
    return promise;
  }
  async iframe_check(): Promise<boolean> {
    return true;
  }
}

/**
 * Web Storage Proxy object, which selects the best backend available
 * depending on the environment.
 */
class StorageProxy implements StorageBackend {
  private backendPromise: Promise<StorageBackend>;
  public impl: StorageImplementation = IMPL_IFRAME_INDEXED_DB;

  constructor() {
    this.backendPromise = (async () => {
      // Prefer the configured iframe storage when available. hubStorage may
      // already be enabled by another window/server, but the iframe origin is
      // the server-configured storage boundary.
      if (Byond.storageCdn) {
        const iframe = new IFrameIndexedDbBackend();

        if ((await iframe.ready()) === true) {
          if (await iframe.get('byondstorage-migrated')) return iframe;

          const iframeHasPersistedStorage = (
            await Promise.all(
              persistedStorageKeys.map((setting) => iframe.get(setting))
            )
          ).some((settings) => settings !== undefined);

          if (!iframeHasPersistedStorage) {
            const hubStorageWasEnabled = testHubStorage();
            if (!hubStorageWasEnabled) {
              Byond.winset(null, 'browser-options', '+byondstorage');
              await waitForByondStorage();
            }

            const hub = new HubStorageBackend();

            // Migrate safe legacy settings from byondstorage to the IFrame.
            // Chat history may contain server-specific HTML/components from
            // other codebases that shared the old byondstorage namespace.
            await Promise.all(
              legacyHubMigrationKeys.map(async (setting) => {
                try {
                  const settings = await hub.get(setting);
                  if (settings !== undefined) {
                    await iframe.set(setting, settings);
                  }
                } catch {
                  // Ignore unreadable legacy storage entries. A bad old cache
                  // key should not keep the client on byondstorage.
                }
              })
            );

            if (!hubStorageWasEnabled) {
              Byond.winset(null, 'browser-options', '-byondstorage');
            }
          }

          await iframe.set('byondstorage-migrated', true);

          return iframe;
        }

        iframe.destroy();
      }

      if (testHubStorage()) {
        return new HubStorageBackend();
      }

      // IFrame hasn't worked out for us, we'll need to enable byondstorage
      Byond.winset(null, 'browser-options', '+byondstorage');
      await waitForByondStorage();

      // Раньше здесь ждали события без таймаута и без проверки результата. Если
      // byondstorage так и не появлялся, промис не разрешался никогда и любой вызов
      // storage вис вместе с ним. Теперь ждём ограниченно и в худшем случае отдаём
      // заглушку — окно откроется без сохранённых настроек, а не не откроется вовсе.
      return testHubStorage()
        ? new HubStorageBackend()
        : new NullStorageBackend();
    })();
  }

  async get(key: string): Promise<any> {
    const backend = await this.backendPromise;
    return backend.get(key);
  }

  async set(key: string, value: any): Promise<void> {
    const backend = await this.backendPromise;
    return backend.set(key, value);
  }

  async remove(key: string): Promise<void> {
    const backend = await this.backendPromise;
    return backend.remove(key);
  }

  async clear(): Promise<void> {
    const backend = await this.backendPromise;
    return backend.clear();
  }
  async processChatMessages(messages) {
    const backend = await this.backendPromise;
    return backend.processChatMessages(messages);
  }

  async getChatMessages(): Promise<any> {
    const backend = await this.backendPromise;
    return backend.getChatMessages();
  }
  async iframe_check(): Promise<boolean> {
    const backend = await this.backendPromise;

    return backend.iframe_check();
  }
}

export const storage = new StorageProxy();
