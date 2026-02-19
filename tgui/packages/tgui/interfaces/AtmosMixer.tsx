import { useBackend } from '../backend';
import { Button, Section, NumberInput, LabeledList, Flex } from '../components';
import { Window } from '../layouts';
import { AtmosBase } from './AtmosFilter';

type AtmosMixerData = {
  node1_concentration: number;
  node2_concentration: number;
} & AtmosBase;

export const AtmosMixer = (props: unknown) => {
  const { act, data } = useBackend<AtmosMixerData>();
  const {
    on,
    pressure,
    max_pressure,
    node1_concentration,
    node2_concentration,
  } = data;

  return (
    <Window width={330} height={165}>
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
            <NodeControls node_name="Node 1" node_ref={node1_concentration} />
            <NodeControls node_name="Node 2" node_ref={node2_concentration} />
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};

type NodeControleProps = {
  node_name: string;
  node_ref: number;
};

const NodeControls = (props: NodeControleProps) => {
  const { act } = useBackend();
  const { node_name, node_ref } = props;

  return (
    <LabeledList.Item label={node_name}>
      <Button
        icon="fast-backward"
        textAlign="center"
        width={2.2}
        disabled={node_ref === 0}
        onClick={() =>
          act('set_node', {
            node_name: node_name,
            concentration: (node_ref - 10) / 100,
          })
        }
      />
      <NumberInput
        animated
        step={0.1}
        unit="%"
        width={6.1}
        lineHeight={1.5}
        stepPixelSize={10}
        minValue={0}
        maxValue={100}
        value={node_ref}
        onChange={(value) =>
          act('set_node', {
            node_name: node_name,
            concentration: value / 100,
          })
        }
      />
      <Button
        icon="fast-forward"
        textAlign="center"
        width={2.2}
        disabled={node_ref === 100}
        onClick={() =>
          act('set_node', {
            node_name: node_name,
            concentration: (node_ref + 10) / 100,
          })
        }
      />
    </LabeledList.Item>
  );
};
