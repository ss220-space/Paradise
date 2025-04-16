type Func = (...args: any[]) => any;

/**
 * Creates a function that returns the result of invoking the given
 * functions, where each successive invocation is supplied the return
 * value of the previous.
 *
 * @example
 * ```tsx
 * const add2 = (x) => x + 2;
 * const multiplyBy3 = (x) => x * 3;
 * const subtract5 = (x) => x - 5;
 *
 * const composedFunction = flow(add2, multiplyBy3, subtract5); // ((4 + 2) * 3) - 5 = 13
 * const composedFunction2 = flow([add2, multiplyBy3], subtract5); // ((4 + 2) * 3) - 5 = 13
 *
 */
export const flow =
  (...funcs: Array<Func | Func[]>) =>
  (input: any, ...rest: any[]): any => {
    let output = input;

    for (const func of funcs) {
      // Recurse into the array of functions
      if (Array.isArray(func)) {
        output = flow(...func)(output, ...rest);
      } else if (func) {
        output = func(output, ...rest);
      }
    }
    return output;
  };

/**
 * Composes single-argument functions from right to left.
 *
 * All functions might accept a context in form of additional arguments.
 * If the resulting function is called with more than 1 argument, rest of
 * the arguments are passed to all functions unchanged.
 *
 * @param {...Function} funcs The functions to compose
 * @returns {Function} A function obtained by composing the argument functions
 * from right to left. For example, compose(f, g, h) is identical to doing
 * (input, ...rest) => f(g(h(input, ...rest), ...rest), ...rest)
 */
export const compose = (...funcs: Array<Func>) => {
  if (funcs.length === 0) {
    return (arg) => arg;
  }
  if (funcs.length === 1) {
    return funcs[0];
  }
  return funcs.reduce(
    (a, b) =>
      (value, ...rest) =>
        a(b(value, ...rest), ...rest)
  );
};
