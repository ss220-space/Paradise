import { useBackend } from '../backend';
import {
  Button,
  Section,
  LabeledList,
  Slider,
  Box,
  ProgressBar,
  Flex,
} from '../components';
import { Window } from '../layouts';
import { PortableBaseData } from './PortablePump';

type PortableScrubberData = {
  rate: number;
  max_rate: number;
} & PortableBaseData;

export const PortableScrubber = (_props: unknown) => {
  const { data } = useBackend<PortableScrubberData>();
  const { has_holding_tank } = data;

  return (
    <Window width={433} height={346}>
      <Window.Content>
        <PumpSettings />
        <PressureSettings />
        {has_holding_tank ? (
          <HoldingTank />
        ) : (
          <Section title="Holding Tank">
            <Box color="average" bold>
              No Holding Tank Inserted.
            </Box>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

const PumpSettings = (_props: unknown) => {
  const { act, data } = useBackend<PortableScrubberData>();
  const { on, port_connected, hasHypernobCrystal, reactionSuppressionEnabled } =
    data;

  return (
    <Section title="Pump Settings">
      <LabeledList>
        {!!hasHypernobCrystal && (
          <LabeledList.Item label="Reaction Suppression">
            <Button
              icon={reactionSuppressionEnabled ? 'snowflake' : 'times'}
              selected={reactionSuppressionEnabled}
              onClick={() => act('reaction_suppression')}
            >
              {reactionSuppressionEnabled ? 'Enabled' : 'Disabled'}
            </Button>
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Power:">
          <Button
            icon={on ? 'power-off' : 'power-off'}
            color={on ? null : 'red'}
            selected={on}
            onClick={() => act('power')}
          >
            {on ? 'On' : 'Off'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item
          color={port_connected ? 'green' : 'average'}
          label="Port Status:"
        >
          {port_connected ? 'Connected' : 'Disconnected'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const PressureSettings = (_props: unknown) => {
  const { act, data } = useBackend<PortableScrubberData>();
  const { tank_pressure, rate, max_rate } = data;

  const average_pressure = max_rate * 0.7;
  const bad_pressure = max_rate * 0.25;

  return (
    <Section title="Pressure Settings">
      <LabeledList>
        <LabeledList.Item label="Stored pressure">
          <ProgressBar
            value={tank_pressure}
            minValue={0}
            maxValue={max_rate}
            ranges={{
              good: [average_pressure, Infinity],
              average: [bad_pressure, average_pressure],
              bad: [-Infinity, bad_pressure],
            }}
          >
            {tank_pressure} kPa
          </ProgressBar>
        </LabeledList.Item>
      </LabeledList>
      <Flex mt={2}>
        <Flex.Item mt={0.4} grow={1} color="label">
          Target pressure:
        </Flex.Item>
        <Flex.Item>
          <Button
            icon="undo"
            mr={0.5}
            width={2.2}
            textAlign="center"
            onClick={() =>
              act('set_rate', {
                rate: 101.325,
              })
            }
          />
          <Button
            icon="fast-backward"
            mr={0.5}
            width={2.2}
            textAlign="center"
            onClick={() =>
              act('set_rate', {
                rate: 0,
              })
            }
          />
        </Flex.Item>
        <Flex.Item>
          <Slider
            animated
            unit="kPa"
            width={17.3}
            stepPixelSize={0.22}
            minValue={0}
            maxValue={max_rate}
            value={rate}
            onChange={(e, value) =>
              act('set_rate', {
                rate: value,
              })
            }
          />
        </Flex.Item>
        <Flex.Item>
          <Button
            icon="fast-forward"
            ml={0.5}
            width={2.2}
            textAlign="center"
            onClick={() =>
              act('set_rate', {
                rate: max_rate,
              })
            }
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const HoldingTank = (_props: unknown) => {
  const { act, data } = useBackend<PortableScrubberData>();
  const { holding_tank, max_rate } = data;

  const average_pressure = max_rate * 0.7;
  const bad_pressure = max_rate * 0.25;

  return (
    <Section
      title="Holding Tank"
      buttons={
        <Button onClick={() => act('remove_tank')} icon="eject">
          Eject
        </Button>
      }
    >
      <Flex>
        <Flex.Item color="label" mr={7.2} mb={2.2}>
          Tank Label:
        </Flex.Item>
        <Flex.Item mb={1} color="silver">
          {holding_tank.name}
        </Flex.Item>
      </Flex>
      <Flex>
        <Flex.Item color="label" mt={0.5} mr={3.8}>
          Tank Pressure:
        </Flex.Item>
        <Flex.Item grow={1}>
          <ProgressBar
            value={holding_tank.tank_pressure}
            minValue={0}
            maxValue={max_rate}
            ranges={{
              good: [average_pressure, Infinity],
              average: [bad_pressure, average_pressure],
              bad: [-Infinity, bad_pressure],
            }}
          >
            {holding_tank.tank_pressure} kPa
          </ProgressBar>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
