import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  NumberInput,
  RestrictedInput,
  Section,
} from '../components';
import { Window } from '../layouts';
import { GASES } from '../constants';

type Data = {
  pressure?: number;
  temperature?: number;
  gas_ratios?: Record<string, number>;
};

export const AtmosBuildMode = (_props: unknown) => {
  const { act, data } = useBackend<Data>();
  const { pressure = 101.3, temperature = 293.15, gas_ratios = {} } = data;

  return (
    <Window width={500} height={600}>
      <Window.Content scrollable>
        <Section title="Базовые параметры">
          <LabeledList>
            <LabeledList.Item label="Давление (кПа)">
              <RestrictedInput
                value={pressure}
                width="80px"
                minValue={0}
                maxValue={100000}
                onChange={(value) => act('set_pressure', { pressure: value })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Температура (K)">
              <RestrictedInput
                value={temperature}
                width="80px"
                minValue={0}
                maxValue={100000}
                onChange={(value) =>
                  act('set_temperature', { temperature: value })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>

        <Section title="Состав газовой смеси" mt={1} scrollable>
          <LabeledList>
            {GASES.map((gas) => (
              <LabeledList.Item key={gas.id} label={gas.name + '(%)'}>
                <RestrictedInput
                  value={gas_ratios[gas.tlv] || 0}
                  width="80px"
                  minValue={0}
                  maxValue={1}
                  onChange={(value) =>
                    act('set_gas_ratio', {
                      gas_id: gas.tlv,
                      ratio: value,
                    })
                  }
                />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
