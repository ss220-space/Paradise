import { useBackend } from '../backend';
import { Button, Dropdown, Input, Section, Stack } from '../components';
import { Window } from '../layouts';
import { CircuitModuleData } from './IntegratedCircuit/types';

export const CircuitModule = (props) => {
  const { act, data } = useBackend<CircuitModuleData>();
  const { input_ports, output_ports, global_port_types } = data;
  return (
    <Window width={600} height={300}>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Button
              textAlign="center"
              fluid
              onClick={() => act('open_internal_circuit')}
            >
              Обзор внутренней интегральной схемы
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Stack width="100%">
              <Stack.Item basis="50%">
                <Section title="Порты ввода">
                  <Stack vertical>
                    {input_ports.map((val, index) => (
                      <PortEntry
                        key={index}
                        name={val.name}
                        datatype={val.type}
                        datatypeOptions={global_port_types}
                        onRemove={() =>
                          act('remove_input_port', {
                            port_id: index + 1,
                          })
                        }
                        onSetType={(type) =>
                          act('set_port_type', {
                            port_id: index + 1,
                            is_input: true,
                            port_type: type,
                          })
                        }
                        onEnter={(e, value) =>
                          act('set_port_name', {
                            port_id: index + 1,
                            is_input: true,
                            port_name: value,
                          })
                        }
                      />
                    ))}
                    <Stack.Item>
                      <Button
                        fluid
                        color="good"
                        icon="plus"
                        onClick={() => act('add_input_port')}
                      >
                        Добавить порт ввода
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item basis="50%">
                <Section title="Порты вывода">
                  <Stack vertical>
                    {output_ports.map((val, index) => (
                      <PortEntry
                        key={index}
                        name={val.name}
                        datatype={val.type}
                        datatypeOptions={global_port_types}
                        onRemove={() =>
                          act('remove_output_port', {
                            port_id: index + 1,
                          })
                        }
                        onSetType={(type) =>
                          act('set_port_type', {
                            port_id: index + 1,
                            is_input: false,
                            port_type: type,
                          })
                        }
                        onEnter={(e, value) =>
                          act('set_port_name', {
                            port_id: index + 1,
                            is_input: false,
                            port_name: value,
                          })
                        }
                      />
                    ))}
                    <Stack.Item>
                      <Button
                        fluid
                        color="good"
                        icon="plus"
                        onClick={() => act('add_output_port')}
                      >
                        Добавить порт вывода
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PortEntry = (props) => {
  const {
    onRemove,
    onEnter,
    onSetType,
    name,
    datatype,
    datatypeOptions = [],
    ...rest
  } = props;

  return (
    <Stack.Item {...rest}>
      <Stack>
        <Stack.Item grow>
          <Input placeholder="Name" value={name} onChange={onEnter} />
        </Stack.Item>
        <Stack.Item>
          <Dropdown
            selected={datatype}
            options={datatypeOptions}
            onSelected={onSetType}
            width="100%"
          />
        </Stack.Item>
        <Stack.Item>
          <Button icon="times" color="red" onClick={onRemove} />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};
