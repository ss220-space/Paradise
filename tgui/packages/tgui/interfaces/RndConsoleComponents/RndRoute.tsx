import { ReactNode } from 'react';
import { useBackend } from '../../backend';

type RndRouteProps = {
  render: () => ReactNode;
} & RndRouteData;

export const RndRoute = (properties: RndRouteProps) => {
  const { render } = properties;
  const { data } = useBackend<RndRouteData>();
  const { menu, submenu } = data;

  const compare = (
    comparator: ((n: number) => boolean) | number,
    item: number
  ) => {
    if (comparator === null || comparator === undefined) {
      return true;
    } // unspecified, match all
    if (typeof comparator === 'function') {
      return comparator(item);
    }
    return comparator === item; // strings or ints?
  };

  let match =
    compare(properties.menu, menu as number) &&
    compare(properties.submenu, submenu as number);

  if (!match) {
    return null;
  }

  return render();
};
