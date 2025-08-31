/**
 * Limits a number to the range between 'min' and 'max'.
 */
export const clamp = (value: number, min: number, max: number): number => {
  return value < min ? min : value > max ? max : value;
};

/**
 * Limits a number between 0 and 1.
 */
export const clamp01 = (value: number): number => {
  return value < 0 ? 0 : value > 1 ? 1 : value;
};

/**
 * Scales a number to fit into the range between min and max.
 */
export const scale = (value: number, min = 0, max = 100): number => {
  return (value - min) / (max - min);
};

/**
 * Robust number rounding, similar to PHP's round() function.
 *
 * @url https://stackoverflow.com/questions/53450248/how-to-round-in-javascript-like-php-do/54721202#54721202
 */
export const round = (num: number, dec: number): number => {
  const num_sign = num >= 0 ? 1 : -1;
  return Number.parseFloat(
    (Math.round(num * 10 ** dec + num_sign * 0.0001) / 10 ** dec).toFixed(dec)
  );
};

/**
 * Returns a string representing a number in fixed point notation.
 */
export const toFixed = (value: number, fractionDigits = 0): string => {
  return Number(value).toFixed(Math.max(fractionDigits, 0));
};

/**
 * Checks whether a value is within the provided range.
 *
 * Range is an array of two numbers, for example: [0, 15].
 */
export const inRange = (value: number, range: number[]): boolean => {
  return range && value >= range[0] && value <= range[1];
};

/**
 * Walks over the object with ranges, comparing value against every range,
 * and returns the key of the first matching range.
 *
 * Range is an array of two numbers, for example: [0, 15].
 */
export const keyOfMatchingRange = (
  value: number,
  ranges: Record<string, any>
): string | undefined => {
  for (const rangeName of Object.keys(ranges)) {
    const range = ranges[rangeName];
    if (inRange(value, range)) {
      return rangeName;
    }
  }
};

/**
 * Get number of digits following the decimal point in a number
 */
export const numberOfDecimalDigits = (value: number): number => {
  if (Math.floor(value) !== value) {
    return value.toString().split('.')[1].length || 0;
  }
  return 0;
};

export const rad2deg = (rad) => {
  return rad * (180 / Math.PI);
};

/**
 * Ensures the number is valid and not infinite/NaN.
 */
export const isSafeNumber = (value: number): boolean => {
  return (
    typeof value === 'number' && Number.isFinite(value) && !Number.isNaN(value)
  );
};
