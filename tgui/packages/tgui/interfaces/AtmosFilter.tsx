import { useBackend } from '../backend';
import { Button, Section, NumberInput, LabeledList } from '../components';
import { Window } from '../layouts';

type AtmosData = {
  filter_type: string;
  filter_type_list: Filter[];
} & AtmosBase;

export interface AtmosBase {
  on: boolean;
  pressure: number;
  max_pressure: number;
}

type Filter = {
  label: string;
  gas_type: string;
};

export const AtmosFilter = (props: unknown) => {
  const { act, data } = useBackend<AtmosData>();
  const { on, pressure, max_pressure, filter_type, filter_type_list } = data;

  return (
    <Window width={380} height={140}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                icon={on ? 'power-off' : 'power-off'}
                color={on ? null : 'red'}
                selected={on}
                onClick={() => act('power')}
              >
                {on ? 'On' : 'Off'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Rate">
              <Button
                icon="fast-backward"
                textAlign="center"
                disabled={pressure === 0}
                width={2.2}
                onClick={() => act('min_pressure')}
              />
              <NumberInput
                animated
                unit="kPa"
                width={6.1}
                lineHeight={1.5}
                step={10}
                minValue={0}
                maxValue={max_pressure}
                value={pressure}
                onDrag={(value) =>
                  act('custom_pressure', {
                    pressure: value,
                  })
                }
              />
              <Button
                icon="fast-forward"
                textAlign="center"
                disabled={pressure === max_pressure}
                width={2.2}
                onClick={() => act('max_pressure')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Filter">
              {filter_type_list.map((filter) => (
                <Button
                  key={filter.label}
                  selected={filter.gas_type === filter_type}
                  onClick={() =>
                    act('set_filter', {
                      filter: filter.gas_type,
                    })
                  }
                >
                  {filter.label}
                </Button>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
