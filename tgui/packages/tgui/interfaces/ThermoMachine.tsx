import {
  AnimatedNumber,
  Button,
  LabeledList,
  NumberInput,
  Section,
} from '../components';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type ThermoMachineData = {
  temperature: number;
  pressure: number;
  on: boolean;
  cooling: boolean;
  target: number;
  min: number;
  max: number;
  initial: number;
};

export const ThermoMachine = (props: unknown) => {
  const { act, data } = useBackend<ThermoMachineData>();

  return (
    <Window width={300} height={225}>
      <Window.Content>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="Temperature">
              <AnimatedNumber
                value={data.temperature}
                format={(value: number) => toFixed(value, 2)}
              />
              {' K'}
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">
              <AnimatedNumber
                value={data.pressure}
                format={(value: number) => toFixed(value, 2)}
              />
              {' kPa'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Controls"
          buttons={
            <Button
              icon={data.on ? 'power-off' : 'times'}
              selected={data.on}
              onClick={() => act('power')}
            >
              {data.on ? 'On' : 'Off'}
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Setting" textAlign="center">
              <Button
                fluid
                icon={data.cooling ? 'temperature-low' : 'temperature-high'}
                selected={data.cooling}
                onClick={() => act('cooling')}
              >
                {data.cooling ? 'Cooling' : 'Heating'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Target Temperature">
              <Button
                icon="fast-backward"
                disabled={data.target === data.min}
                onClick={() =>
                  act('target', {
                    target: data.min,
                  })
                }
              >
                Minimum temperature
              </Button>
              <NumberInput
                animated
                value={Math.round(data.target)}
                unit="K"
                width={5.4}
                lineHeight={1.4}
                minValue={Math.round(data.min)}
                maxValue={Math.round(data.max)}
                step={5}
                stepPixelSize={3}
                onChange={(value: number) =>
                  act('target', {
                    target: value,
                  })
                }
              />
              <Button
                icon="fast-forward"
                disabled={data.target === data.max}
                onClick={() =>
                  act('target', {
                    target: data.max,
                  })
                }
              >
                Maximum Temperature
              </Button>
              <Button
                icon="sync"
                disabled={data.target === data.initial}
                onClick={() =>
                  act('target', {
                    target: data.initial,
                  })
                }
              >
                Room Temperature
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
