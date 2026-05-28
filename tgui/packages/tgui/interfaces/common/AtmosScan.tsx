import { filter } from 'common/collections';
import { Box, LabeledList } from '../../components';

export const Danger2Colour = (danger: number) => {
  if (danger === 0) {
    return 'green';
  }
  if (danger === 1) {
    return 'orange';
  }
  return 'red';
};

type AirContent = {
  val: number;
  danger: number;
  units: string;
  entry: string;
};

export type AtmosScanData = {
  aircontents: AirContent[];
};

export const AtmosScan = (props: AtmosScanData) => {
  const { aircontents } = props;

  return (
    <Box>
      <LabeledList>
        {filter(
          aircontents,
          (i) =>
            i.val !== 0 || i.entry === 'Pressure' || i.entry === 'Temperature'
        ).map((item) => (
          <LabeledList.Item
            key={item.entry}
            label={item.entry}
            color={Danger2Colour(item.danger || 0)}
          >
            {item.val}
            {item.units}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Box>
  );
};
