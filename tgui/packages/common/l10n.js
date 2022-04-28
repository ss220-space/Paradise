export const declensionRu = (num, single_name, double_name, multiple_name) => {
  const shorten = num % 100;

  if (shorten >= 10 && shorten <= 20) {
    return multiple_name;
  }

  const lastDigit = shorten % 10;

  if (lastDigit === 1) {
    return single_name;
  } else if (lastDigit >= 2 && shorten <= 4) {
    return double_name;
  } else {
    return multiple_name;
  }
};
