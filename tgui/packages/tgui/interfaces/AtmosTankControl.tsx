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
  name: string;
  pressure: number;
  temperature: number;
};

export const AtmosTankControl = (props) => {
  const { data } = useBackend<AtmosTankControlData>();

  let sensors_list = data.sensors || [];

  const isValidNumber = (value: unknown): value is number => {
    return typeof value === 'number' && !isNaN(value);
  };

  return (
    <Window width={400} height={435}>
      <Window.Content scrollable>
        {sensors_list.map((s, index) => (
          <Section key={index} title={s.name}>
            <LabeledList>
              {isValidNumber(s.pressure) ? (
                <LabeledList.Item label="Pressure">
                  {s.pressure} kpa
                </LabeledList.Item>
              ) : (
                ''
              )}
              {isValidNumber(s.pressure) ? (
                <LabeledList.Item label="Temperature">
                  {s.temperature} K
                </LabeledList.Item>
              ) : (
                ''
              )}

              {GASES.map((g) =>
                s[g.tlv] ? (
                  <LabeledList.Item key={g.id} label={g.label}>
                    <ProgressBar
                      color={g.color}
                      value={s[g.tlv]}
                      minValue={0}
                      maxValue={100}
                    >
                      {toFixed(s[g.tlv], 2) + '%'}
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
