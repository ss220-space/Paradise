import {
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui/components';
import { toFixed } from 'common/math';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { GASES } from '../constants';
import { AtmosMachine, AtmosMachineView } from './common/AtmosMachine';

type AtmosTankControlData = {
  sensors: Sensor[];
  inlets?: AtmosMachine[];
  outlets?: AtmosMachine[];
};

type Sensor = {
  pressure: number;
  temperature: number;
};

export const AtmosTankControl = (props) => {
  const { data } = useBackend<AtmosTankControlData>();

  let sensors_list = data.sensors || {};

  const isValidNumber = (value: unknown): value is number => {
    return typeof value === 'number' && !isNaN(value);
  };

  return (
    <Window width={400} height={435}>
      <Window.Content scrollable>
        {Object.keys(sensors_list).map((s) => (
          <Section key={s} title={s}>
            <LabeledList>
              {isValidNumber(sensors_list[s].pressure) ? (
                <LabeledList.Item label="Pressure">
                  {sensors_list[s].pressure} kpa
                </LabeledList.Item>
              ) : (
                ''
              )}
              {isValidNumber(sensors_list[s].pressure) ? (
                <LabeledList.Item label="Temperature">
                  {sensors_list[s].temperature} K
                </LabeledList.Item>
              ) : (
                ''
              )}

              {GASES.map((g) =>
                isValidNumber(sensors_list[s][g.tlv]) ? (
                  <LabeledList.Item key={g.id} label={g.label}>
                    <ProgressBar
                      color={g.color}
                      value={sensors_list[s][g.tlv]}
                      minValue={0}
                      maxValue={100}
                    >
                      {toFixed(sensors_list[s][g.tlv], 2) + '%'}
                    </ProgressBar>
                  </LabeledList.Item>
                ) : (
                  ''
                )
              )}
            </LabeledList>
          </Section>
        ))}
        <Section title="Inlets">
          {data.inlets?.map((inlet) => (
            <AtmosMachineView key={inlet.uid} {...inlet} />
          ))}
        </Section>
        <Section title="Outlets">
          {data.outlets?.map((outlet) => (
            <AtmosMachineView key={outlet.uid} {...outlet} />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
