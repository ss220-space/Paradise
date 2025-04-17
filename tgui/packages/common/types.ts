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
