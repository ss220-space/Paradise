import { useBackend } from '../backend';
import { Button, Section, NumberInput, LabeledList } from '../components';
import { GASES } from '../constants';
import { Window } from '../layouts';

type AtmosData = {
  filter_type: string;
} & AtmosBase;

export interface AtmosBase {
  on: boolean;
  pressure: number;
  max_pressure: number;
}

export const AtmosFilter = (props: unknown) => {
  const { act, data } = useBackend<AtmosData>();
  const { on, pressure, max_pressure, filter_type } = data;

  return (
    <Window width={380} height={220}>
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
              {GASES.map((filter) => (
                <Button
                  key={filter.label}
                  selected={filter.tlv === filter_type}
                  onClick={() =>
                    act('set_filter', {
                      filter: filter.tlv,
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
