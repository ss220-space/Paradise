import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from '../components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type GravityGeneratorData = {
  breaker: boolean;
  charge_count: number;
  charging_state: number;
  on: boolean;
  operational: boolean;
};

export const GravityGenerator = () => {
  const { data } = useBackend<GravityGeneratorData>();
  const { operational } = data;
  return (
    <Window width={400} height={155}>
      <Window.Content>
        {!operational && <NoticeBox>No data available</NoticeBox>}
        {!!operational && <GravityGeneratorContent />}
      </Window.Content>
    </Window>
  );
};

const GravityGeneratorContent = () => {
  const { act, data } = useBackend<GravityGeneratorData>();
  const { breaker, charge_count, charging_state, on, operational } = data;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Power">
          <Button
            icon={breaker ? 'power-off' : 'times'}
            selected={breaker}
            disabled={!operational}
            onClick={() => act('gentoggle')}
          >
            {breaker ? 'On' : 'Off'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Gravity Charge">
          <ProgressBar
            value={charge_count / 100}
            ranges={{
              good: [0.7, Infinity],
              average: [0.3, 0.7],
              bad: [-Infinity, 0.3],
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Charge Mode">
          {charging_state === 0 &&
            ((on && <Box color="good">Fully Charged</Box>) || (
              <Box color="bad">Not Charging</Box>
            ))}
          {charging_state === 1 && <Box color="average">Charging</Box>}
          {charging_state === 2 && <Box color="average">Discharging</Box>}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
