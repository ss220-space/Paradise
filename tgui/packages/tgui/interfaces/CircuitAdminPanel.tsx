import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Button, Stack, Table } from '../components';
import { Window } from '../layouts';

type CircuitAdminPanelData = {
  circuits: {
    ref: string;
    name: string;
    creator: string;
    has_inserter: BooleanLike;
  }[];
};

export const CircuitAdminPanel = (props) => {
  const { act, data } = useBackend<CircuitAdminPanelData>();

  return (
    <Window title="Админ-панель интегральных схем" width={1200} height={500}>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Table>
              <Table.Row header>
                <Table.Cell>Название схемы</Table.Cell>

                <Table.Cell>Создатель</Table.Cell>

                <Table.Cell>Опции</Table.Cell>
              </Table.Row>

              {data.circuits.map((circuit) => {
                const createAct = (action: string) => () => {
                  act(action, { circuit: circuit.ref });
                };

                return (
                  <Table.Row key={circuit.ref}>
                    <Table.Cell>{circuit.name}</Table.Cell>

                    <Table.Cell>{circuit.creator}</Table.Cell>

                    <Table.Cell>
                      <Button onClick={createAct('follow_circuit')}>
                        Следовать
                      </Button>

                      <Button onClick={createAct('open_circuit')}>
                        Открыть
                      </Button>

                      <Button onClick={createAct('vv_circuit')}>VV</Button>

                      <Button onClick={createAct('save_circuit')}>
                        Сохранить
                      </Button>

                      <Button onClick={createAct('duplicate_circuit')}>
                        Создать копию
                      </Button>

                      {!!circuit.has_inserter && (
                        <Button onClick={createAct('open_player_panel')}>
                          Панель игрока
                        </Button>
                      )}
                    </Table.Cell>
                  </Table.Row>
                );
              })}
            </Table>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
