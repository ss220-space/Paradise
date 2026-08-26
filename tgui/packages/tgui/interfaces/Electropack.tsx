import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

type ElectropackData = {
  power: number;
  code: number;
} & Frequency;

export const Electropack = (props: unknown) => {
  const { act, data } = useBackend<ElectropackData>();
  const { power, code, frequency, minFrequency, maxFrequency } = data;
  return (
    <Window width={360} height={150}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                icon={power ? 'power-off' : 'times'}
                selected={power}
                onClick={() => act('power')}
              >
                {power ? 'On' : 'Off'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item
              label="Frequency"
              buttons={
                <Button
                  icon="sync"
                  onClick={() =>
                    act('reset', {
                      reset: 'freq',
                    })
                  }
                >
                  Reset
                </Button>
              }
            >
              <NumberInput
                animated
                unit="kHz"
                step={0.2}
                stepPixelSize={6}
                minValue={minFrequency / 10}
                maxValue={maxFrequency / 10}
                value={frequency / 10}
                format={(value) => toFixed(value, 1)}
                width="80px"
                onChange={(value) =>
                  act('freq', {
                    freq: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item
              label="Code"
              buttons={
                <Button
                  icon="sync"
                  onClick={() =>
                    act('reset', {
                      reset: 'code',
                    })
                  }
                >
                  Reset
                </Button>
              }
            >
              <NumberInput
                animated
                step={1}
                stepPixelSize={6}
                minValue={1}
                maxValue={100}
                value={code}
                width="80px"
                onChange={(value) =>
                  act('code', {
                    code: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
