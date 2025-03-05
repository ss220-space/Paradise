import { useBackend, useLocalState } from '../backend';
import {
  Button,
  LabeledList,
  Box,
  AnimatedNumber,
  Section,
  NoticeBox,
  Tabs,
  Icon,
  Table,
} from '../components';
import { Window } from '../layouts';

export const TcommsRelay = (props) => {
  const { act, data } = useBackend();
  const { linked, active, network_id } = data;

  return (
    <Window width={600} height={400}>
      <Window.Content scrollable>
        <Section title="Конфигурация реле">
          <LabeledList>
            <LabeledList.Item label="Питание">
              <Button
                content={active ? 'Включено' : 'Выключено'}
                selected={active}
                icon="power-off"
                onClick={() => act('toggle_active')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Сетевой идентификатор">
              <Button
                content={network_id ? network_id : 'Не задано'}
                selected={network_id}
                icon="server"
                onClick={() => act('network_id')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Привязка">
              {linked === 1 ? (
                <Box color="green">Привязано</Box>
              ) : (
                <Box color="red">Не привязано</Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {linked === 1 ? <LinkedView /> : <UnlinkedView />}
      </Window.Content>
    </Window>
  );
};

const LinkedView = (_properties) => {
  const { act, data } = useBackend();
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
            content={hidden_link ? 'Да' : 'Нет'}
            icon={hidden_link ? 'eye-slash' : 'eye'}
            selected={hidden_link}
            onClick={() => act('toggle_hidden_link')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Отвязать">
          <Button
            content="Отвязать"
            icon="unlink"
            color="red"
            onClick={() => act('unlink')}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const UnlinkedView = (_properties) => {
  const { act, data } = useBackend();
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
                content="Привязка"
                icon="link"
                onClick={() =>
                  act('link', {
                    addr: c.addr,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
