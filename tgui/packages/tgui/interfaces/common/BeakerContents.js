import { Stack } from '../../components';
const PropTypes = require('prop-types');

const formatUnits = (a) =>
  a +
  ' единиц' +
  (a % 10 === 1 && a % 100 !== 11 ? 'а' : '') +
  (a % 10 > 1 && a % 10 < 5 && !(a % 100 > 11) && !(a % 100 < 15) ? 'ы' : '');

/**
 * Displays a beaker's contents
 * @property {object} props
 */
export const BeakerContents = (props) => {
  const { beakerLoaded, beakerContents = [], buttons } = props;
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
          <Stack.Item key={chemical.name} color="label" grow>
            {formatUnits(chemical.volume)} {chemical.name}
          </Stack.Item>
          {!!buttons && <Stack.Item>{buttons(chemical, i)}</Stack.Item>}
        </Stack>
      ))}
    </Stack>
  );
};

BeakerContents.propTypes = {
  /**
   * Whether there is a loaded beaker or not
   */
  beakerLoaded: PropTypes.bool,
  /**
   * The reagents in the beaker
   */
  beakerContents: PropTypes.array,
  /**
   * The buttons to display next to each reagent line
   */
  buttons: PropTypes.arrayOf(PropTypes.element),
};
