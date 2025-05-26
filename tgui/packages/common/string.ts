/**
 * Creates a search terms matcher. Returns true if given string matches the search text.
 *
 * @example
 * ```tsx
 * type Thing = { id: string; name: string };
 *
 * const objects = [
 *   { id: '123', name: 'Test' },
 *   { id: '456', name: 'Test' },
 * ];
 *
 * const search = createSearch('123', (obj: Thing) => obj.id);
 *
 * objects.filter(search); // returns [{ id: '123', name: 'Test' }]
 * ```
 */
export const createSearch = <TObj>(
  searchText: string,
  stringifier = (obj: TObj) => JSON.stringify(obj)
): ((obj: TObj) => boolean) => {
  const preparedSearchText = searchText.toLowerCase().trim();

  return (obj) => {
    if (!preparedSearchText) {
      return true;
    }
    const str = stringifier(obj);
    if (!str) {
      return false;
    }
    return str.toLowerCase().includes(preparedSearchText);
  };
};

export const VOWELS = ['a', 'e', 'i', 'o', 'u'];

/**
 * Pluralizes a word based on the number given.
 * Handles -es and -ies.
 *
 * @param override - A custom string to be appended instead for plurals. Useful for words that don't follow the standard rules.
 *
 * @example
 * ```tsx
 * pluralize('Dog', 1) // Dog
 * pluralize('Dog', 2) // Dogs
 * pluralize('Monarch', 2, "s") // Monarchs
 * ```
 */
export const pluralize = (str: string, n: number, override?: string) => {
  if (n === 1) {
    return str;
  }
  if (override) {
    return str + override;
  }
  if (
    str.endsWith('s') ||
    str.endsWith('x') ||
    str.endsWith('z') ||
    str.endsWith('ch') ||
    str.endsWith('sh')
  ) {
    return `${str}es`;
  }
  if (str.endsWith('y') && !VOWELS.includes(str.charAt(str.length - 2))) {
    return `${str.slice(0, -1)}ies`;
  }
  return `${str}s`;
};

/**
 * Capitalizes a word and lowercases the rest.
 *
 * @example
 * ```tsx
 * capitalize('heLLo') // Hello
 * ```
 */
export const capitalize = (str: string): string => {
  return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
};

/**
 * Similar to capitalize, this takes a string and replaces all first letters
 * of any words.
 *
 * @example
 * ```tsx
 * capitalizeAll('heLLo woRLd') // 'HeLLo WoRLd'
 * ```
 */
export const capitalizeAll = (str: string): string => {
  return str.replace(/(^\w{1})|(\s+\w{1})/g, (letter) => letter.toUpperCase());
};

/**
 * Capitalizes only the first letter of the str, leaving others untouched.
 *
 * @example
 * ```tsx
 * capitalizeFirst('heLLo woRLd') // 'HeLLo woRLd'
 * ```
 */
export const capitalizeFirst = (str: string): string => {
  return str.replace(/^\w/, (letter) => letter.toUpperCase());
};

const WORDS_UPPER = ['Id', 'Tv'] as const;

const WORDS_LOWER = [
  'A',
  'An',
  'And',
  'As',
  'At',
  'But',
  'By',
  'For',
  'For',
  'From',
  'In',
  'Into',
  'Near',
  'Nor',
  'Of',
  'On',
  'Onto',
  'Or',
  'The',
  'To',
  'With',
] as const;

/**
 * Converts a string to title case.
 *
 * @example
 * ```tsx
 * toTitleCase('a tale of two cities') // 'A Tale of Two Cities'
 * ```
 */
export const toTitleCase = (str: string): string => {
  if (!str) return str;

  let currentStr = str.replace(/([^\W_]+[^\s-]*) */g, (str) => {
    return capitalize(str);
  });

  for (const word of WORDS_LOWER) {
    const regex = new RegExp(`\\s${word}\\s`, 'g');
    currentStr = currentStr.replace(regex, (str) => str.toLowerCase());
  }

  for (const word of WORDS_UPPER) {
    const regex = new RegExp(`\\b${word}\\b`, 'g');
    currentStr = currentStr.replace(regex, (str) => str.toLowerCase());
  }

  return currentStr;
};

const TRANSLATE_REGEX = /&(nbsp|amp|quot|lt|gt|apos|trade|copy);/g;
const TRANSLATIONS = {
  amp: '&',
  apos: "'",
  gt: '>',
  lt: '<',
  nbsp: ' ',
  quot: '"',
  trade: '™',
  cops: '©',
} as const;

/**
 * Decodes HTML entities and removes unnecessary HTML tags.
 *
 * @example
 * ```tsx
 * decodeHtmlEntities('&amp;') // returns '&'
 * decodeHtmlEntities('&lt;') // returns '<'
 * ```
 */
export const decodeHtmlEntities = (str: string): string => {
  if (!str) return str;

  return (
    str
      // Newline tags
      .replace(/<br>/gi, '\n')
      .replace(/<\/?[a-z0-9-_]+[^>]*>/gi, '')
      // Basic entities
      .replace(TRANSLATE_REGEX, (_match, entity) => TRANSLATIONS[entity])
      // Decimal entities
      .replace(/&#?([0-9]+);/gi, (_match, numStr) => {
        const num = Number.parseInt(numStr, 10);
        return String.fromCharCode(num);
      })
      // Hex entities
      .replace(/&#x?([0-9a-f]+);/gi, (_match, numStr) => {
        const num = Number.parseInt(numStr, 16);
        return String.fromCharCode(num);
      })
  );
};
