import { useBackend } from '../backend';
import { Button, LabeledList, Box, Section, Table } from '../components';
import { Window } from '../layouts';

type TcommsRelayData = {
  linked: boolean;
  active: boolean;
  network_id: string;
  linked_core_id: string;
  linked_core_addr: string;
  hidden_link: boolean;
  cores: Core[];
};

type Core = {
  addr: string;
  net_id: string;
  sector: string;
};

export const TcommsRelay = (_props: unknown) => {
  const { act, data } = useBackend<TcommsRelayData>();
  const { linked, active, network_id } = data;

  return (
    <Window width={600} height={400}>
      <Window.Content scrollable>
        <Section title="Конфигурация реле">
          <LabeledList>
            <LabeledList.Item label="Питание">
              <Button
                selected={active}
                icon="power-off"
                onClick={() => act('toggle_active')}
              >
                {active ? 'Включено' : 'Выключено'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Сетевой идентификатор">
              <Button
                selected={!!network_id}
                icon="server"
                onClick={() => act('network_id')}
              >
                {network_id ? network_id : 'Не задано'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Привзка">
              {linked ? (
                <Box color="green">Привязано</Box>
              ) : (
                <Box color="red">Не привязано</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {linked ? <LinkedView /> : <UnlinkedView />}
      </Window.Content>
    </Window>
  );
};

const LinkedView = (_properties) => {
  const { act, data } = useBackend<TcommsRelayData>();
  const { linked_core_id, linked_core_addr, hidden_link } = data;
  return (
    <Section title="Состояние привязки">
      <LabeledList>
        <LabeledList.Item label="Идентификатор привязанного ядра">
          {linked_core_id}
        </LabeledList.Item>
        <LabeledList.Item label="Сетевой адрес привязано ядра">
          {linked_core_addr}
        </LabeledList.Item>
        <LabeledList.Item label="Скрытая привязка">
          <Button
            icon={hidden_link ? 'eye-slash' : 'eye'}
            selected={hidden_link}
            onClick={() => act('toggle_hidden_link')}
          >
            {hidden_link ? 'Да' : 'Нет'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Отвязать">
          <Button icon="unlink" color="red" onClick={() => act('unlink')}>
            Отвязать
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const UnlinkedView = (_properties) => {
  const { act, data } = useBackend<TcommsRelayData>();
  const { cores } = data;
  return (
    <Section title="Обнаруженные ядра">
      <Table m="0.5rem">
        <Table.Row header>
          <Table.Cell>Сетевой адрес</Table.Cell>
          <Table.Cell>Сетевой идентификатор</Table.Cell>
          <Table.Cell>Сектор</Table.Cell>
          <Table.Cell>Привязка</Table.Cell>
        </Table.Row>
        {cores.map((c) => (
          <Table.Row key={c.addr}>
            <Table.Cell>{c.addr}</Table.Cell>
            <Table.Cell>{c.net_id}</Table.Cell>
            <Table.Cell>{c.sector}</Table.Cell>
            <Table.Cell>
              <Button
                icon="link"
                onClick={() =>
                  act('link', {
                    addr: c.addr,
                  })
                }
              >
                Привязать
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
