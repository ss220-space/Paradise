import { ReactNode } from 'react';
import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

type TankData = {
  has_mask: boolean;
  connected: boolean;
  tankPressure: number;
  releasePressure: number;
  minReleasePressure: number;
  maxReleasePressure: number;
  defaultReleasePressure: number;
};

export const Tank = (_props: unknown) => {
  const { act, data } = useBackend<TankData>();
  let maskStatus: ReactNode;
  if (!data.has_mask) {
    maskStatus = (
      <LabeledList.Item label="Mask" color="red">
        No Mask Equipped
      </LabeledList.Item>
    );
  } else {
    maskStatus = (
      <LabeledList.Item label="Mask">
        <Button
          icon={data.connected ? 'check' : 'times'}
          selected={data.connected}
          onClick={() => act('internals')}
        >
          {data.connected ? 'Internals On' : 'Internals Off'}
        </Button>
      </LabeledList.Item>
    );
  }
  return (
    <Window width={300} height={150}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Tank Pressure">
              <ProgressBar
                value={data.tankPressure / 1013}
                ranges={{
                  good: [0.35, Infinity],
                  average: [0.15, 0.35],
                  bad: [-Infinity, 0.15],
                }}
              >
                {data.tankPressure + ' kPa'}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Release Pressure">
              <Button
                icon="fast-backward"
                disabled={data.releasePressure === data.minReleasePressure}
                tooltip="Min"
                onClick={() =>
                  act('pressure', {
                    pressure: 'min',
                  })
                }
              />
              <NumberInput
                animated
                value={data.releasePressure}
                width="65px"
                unit="kPa"
                step={0.1}
                minValue={data.minReleasePressure}
                maxValue={data.maxReleasePressure}
                onChange={(value) =>
                  act('pressure', {
                    pressure: value,
                  })
                }
              />
              <Button
                icon="fast-forward"
                disabled={data.releasePressure === data.maxReleasePressure}
                tooltip="Max"
                onClick={() =>
                  act('pressure', {
                    pressure: 'max',
                  })
                }
              />
              <Button
                icon="undo"
                disabled={data.releasePressure === data.defaultReleasePressure}
                tooltip="Reset"
                onClick={() =>
                  act('pressure', {
                    pressure: 'reset',
                  })
                }
              />
            </LabeledList.Item>
            {maskStatus}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
