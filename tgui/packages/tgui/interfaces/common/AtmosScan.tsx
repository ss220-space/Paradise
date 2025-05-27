import { filter } from 'common/collections';
import { Box, LabeledList } from '../../components';

const getItemColor = (
  value: number,
  min2: number,
  min1: number,
  max1: number,
  max2: number
) => {
  if (value < min2) {
    return 'bad';
  } else if (value < min1) {
    return 'average';
  } else if (value > max1) {
    return 'average';
  } else if (value > max2) {
    return 'bad';
  }
  return 'good';
};

type AirContent = {
  val: number;
  bad_low: number;
  poor_low: number;
  poor_high: number;
  bad_high: number;
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
            color={getItemColor(
              item.val,
              item.bad_low,
              item.poor_low,
              item.poor_high,
              item.bad_high
            )}
          >
            {item.val}
            {item.units}
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Box>
  );
};
