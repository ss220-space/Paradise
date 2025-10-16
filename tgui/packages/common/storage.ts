/**
 * Browser-agnostic abstraction of key-value web storage.
 *
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 *
 */

export const IMPL_MEMORY = 0;
export const IMPL_HUB_STORAGE = 1;
export const IMPL_IFRAME_INDEXED_DB = 2;

type StorageImplementation =
  | typeof IMPL_MEMORY
  | typeof IMPL_HUB_STORAGE
  | typeof IMPL_IFRAME_INDEXED_DB;

const READ_ONLY = 'readonly';
const READ_WRITE = 'readwrite';

type StorageBackend = {
  impl: StorageImplementation;
  get(key: string): Promise<any>;
  set(key: string, value: any): Promise<void>;
  remove(key: string): Promise<void>;
  clear(): Promise<void>;
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

class HubStorageBackend implements StorageBackend {
  public impl: StorageImplementation;

  constructor() {
    this.impl = IMPL_HUB_STORAGE;
  }

  async get(key: string): Promise<any> {
    return new Promise((resolve) => {
      queueMicrotask(() => {
        const value = window.hubStorage.getItem('paradise-' + key);
        if (typeof value === 'string') {
          resolve(JSON.parse(value));
        } else {
          resolve(undefined);
        }
      });
    });
  }

  async set(key: string, value: any): Promise<void> {
    return new Promise((resolve) => {
      queueMicrotask(() => {
        window.hubStorage.setItem('paradise-' + key, JSON.stringify(value));
        resolve();
      });
    });
  }

  async remove(key: string): Promise<void> {
    return new Promise((resolve) => {
      queueMicrotask(() => {
        window.hubStorage.removeItem('paradise-' + key);
        resolve();
      });
    });
  }

  async clear(): Promise<void> {
    return new Promise((resolve) => {
      queueMicrotask(() => {
        window.hubStorage.clear();
        resolve();
      });
    });
  }
  async processChatMessages(messages) {
    return storage.set('chat-messages', messages);
  }

  async getChatMessages(): Promise<any> {
    return await storage.get('chat-messages');
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
    iframe.sandbox = 'allow-scripts allow-same-origin allow-forms';
    iframe.src = Byond.storageCdn;

    const completePromise: Promise<boolean> = new Promise((resolve) => {
      iframe.onload = () => resolve(!!this);
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
      window.addEventListener('message', (message) => {
        if (message.data.key && message.data.key === key) {
          resolve(message.data.value);
        }
      });
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

  async ping(): Promise<boolean> {
    const promise: Promise<boolean> = new Promise((resolve) => {
      window.addEventListener('message', (message) => {
        if (message.data === true) {
          resolve(true);
        }
      });

      setTimeout(() => resolve(false), 100);
    });

    this.iframeWindow.postMessage({ type: 'ping' }, '*');
    return promise;
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
  async destroy(): Promise<void> {
    document.body.removeChild(this.documentElement);
    this.documentElement = null;
    this.iframeWindow = null;
  }
}

/**
 * Web Storage Proxy object, which selects the best backend available
 * depending on the environment.
 */
export class StorageProxy implements StorageBackend {
  private backendPromise: Promise<StorageBackend>;
  public impl: StorageImplementation = IMPL_MEMORY;

  constructor() {
    this.backendPromise = (async () => {
      if (Byond.storageCdn) {
        const iframe = new IFrameIndexedDbBackend();
        await iframe.ready();

        if ((await iframe.ping()) === true) {
          // Remove with 516... eventually
          if (await iframe.get('byondstorage-migrated')) return iframe;

          Byond.winset(null, 'browser-options', '+byondstorage');

          await new Promise<void>((resolve) => {
            document.addEventListener('byondstorageupdated', async () => {
              setTimeout(() => {
                const hub = new HubStorageBackend();
                hub
                  .get('panel-settings')
                  .then((settings) => iframe.set('panel-settings', settings));
                iframe.set('byondstorage-migrated', true);

                resolve();
              }, 1);
            });
          });
          return iframe;
        }

        iframe.destroy();
      }
      if (!testHubStorage()) {
        Byond.winset(null, 'browser-options', '+byondstorage');

        return new Promise((resolve) => {
          const listener = () => {
            document.removeEventListener('byondstorageupdated', listener);
            resolve(new HubStorageBackend());
          };

          document.addEventListener('byondstorageupdated', listener);
        });
      }
      return new HubStorageBackend();
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

  getBackendPromise() {
    return this.backendPromise;
  }
}

export const storage = new StorageProxy();
