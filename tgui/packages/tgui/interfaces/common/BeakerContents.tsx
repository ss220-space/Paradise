import { ReactNode } from 'react';
import { declension_ru } from 'common/string';
import { Stack } from '../../components';

type BeakerContentsProps = {
  /**
   * Whether there is a loaded beaker or not
   */
  beakerLoaded?: boolean;

  /**
   * The reagents in the beaker
   */
  beakerContents?: Chemical[];

  /**
   * A function that returns ReactNode (buttons) for a given chemical
   */
  buttons?: (chemical: Chemical, index: number) => ReactNode;
};

const formatUnits = (a: number): string =>
  a + ' единиц' + declension_ru(a, 'а', 'ы', '');

export const BeakerContents = ({
  beakerLoaded,
  beakerContents = [],
  buttons,
}: BeakerContentsProps) => {
  return (
    <Stack vertical>
      {(!beakerLoaded && (
        <Stack.Item color="label">Ёмкость отсутствует.</Stack.Item>
      )) ||
        (beakerContents.length === 0 && (
          <Stack.Item color="label">Ёмкость пуста.</Stack.Item>
        ))}

      {beakerContents.map((chemical, i) => (
        <Stack key={chemical.name}>
          <Stack.Item color="label" grow>
            {formatUnits(chemical.volume)} {chemical.name}
          </Stack.Item>
          {!!buttons && <Stack.Item>{buttons(chemical, i)}</Stack.Item>}
        </Stack>
      ))}
    </Stack>
  );
};
