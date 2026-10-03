export const declensionRu = (
  num: number,
  single_name: string,
  double_name: string,
  multiple_name: string,
) => {
  const shorten = num % 100;

  if (shorten >= 10 && shorten <= 20) {
    return multiple_name;
  }

  const lastDigit = shorten % 10;

  if (lastDigit === 1) {
    return single_name;
  } else if (lastDigit >= 2 && lastDigit <= 4) {
    return double_name;
  } else {
    return multiple_name;
  }
};

/**
 * Accepts a number, returns one of the strings - for singular, dual, and plural numbers in Russian language.
 * *
 * @example
 * ```tsx
 * declension_ru(1, "single", "double", "multiple") // single
 * declension_ru(3, "single", "double", "multiple") // double
 * declension_ru(7, "single", "double", "multiple") // multiple
 * declension_ru(11, "single", "double", "multiple") // multiple
 * declension_ru(21, "single", "double", "multiple") // single
 * declension_ru(24, "single", "double", "multiple") // double
 * ```
 */
export const declension_ru = (
  num: number,
  single_name: string,
  double_name: string,
  multiple_name: string,
) => {
  if (typeof num !== 'number' || Math.round(num) !== num) {
    return double_name; // fractional numbers
  }
  if (num % 10 === 1 && num % 100 !== 11) {
    // 1, not 11
    return single_name;
  }
  if (num % 10 > 1 && num % 10 < 5 && (num % 100 < 11 || num % 100 > 15)) {
    // 2, 3, 4, not 12, 13, 14
    return double_name;
  }

  return multiple_name; // 5, 6, 7, 8, 9, 0
};
