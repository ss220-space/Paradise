/**
 * Returns the arguments of a function F as an array.
 */
export type ArgumentsOf<F extends Fn> = F extends (...args: infer A) => unknown
  ? A
  : never;

/**
 * A function. Use this instead of `Function` to avoid issues with
 * type inference.
 */
export type Fn = (...args: any[]) => void;

type ByondStorage = {
  clear: () => void;
  fill: (data: object) => void;
  getItem: (item: string) => object;
  hasitem: (item: string) => boolean;
  removeItem: (item: string) => void;
  setItem: (item: string, value: any) => void;
  sync: () => void;
};

export type ByondWindow = Window &
  typeof globalThis & {
    hubStorage?: ByondStorage;
    serverStorage?: ByondStorage;
    domainStorage?: ByondStorage;
  };
