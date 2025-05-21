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

type StorageImplementation = typeof IMPL_MEMORY | typeof IMPL_HUB_STORAGE;

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

class MemoryBackend implements StorageBackend {
  private store: Record<string, any>;
  public impl: StorageImplementation;

  constructor() {
    this.impl = IMPL_MEMORY;
    this.store = {};
  }

  async get(key: string): Promise<any> {
    return this.store[key];
  }

  async set(key: string, value: any): Promise<void> {
    this.store[key] = value;
  }

  async remove(key: string): Promise<void> {
    this.store[key] = undefined;
  }

  async clear(): Promise<void> {
    this.store = {};
  }
}

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
}

/**
 * Web Storage Proxy object, which selects the best backend available
 * depending on the environment.
 */
class StorageProxy implements StorageBackend {
  private backendPromise: Promise<StorageBackend>;
  public impl: StorageImplementation = IMPL_MEMORY;

  constructor() {
    this.backendPromise = (async () => {
      try {
        const isHubAvailable = await this.retryWithDelay(
          () => testHubStorage(),
          5,
          10
        );

        if (isHubAvailable) {
          this.impl = IMPL_HUB_STORAGE;
          return new HubStorageBackend();
        }
      } catch (err) {}
      console.warn(
        'No supported storage backend found. Using in-memory storage.'
      );
      return new MemoryBackend();
    })();
  }

  async retryWithDelay<T>(
    action: () => Promise<T> | T,
    maxAttempts: number,
    delayMs: number
  ): Promise<T> {
    let attempt = 0;
    let lastError: unknown;

    while (attempt < maxAttempts) {
      attempt++;
      try {
        const result = await Promise.resolve(action());
        return result;
      } catch (error) {
        lastError = error;
        if (attempt < maxAttempts) {
          await new Promise((resolve) => setTimeout(resolve, delayMs));
        }
      }
    }
    throw lastError;
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
}

export const storage = new StorageProxy();
