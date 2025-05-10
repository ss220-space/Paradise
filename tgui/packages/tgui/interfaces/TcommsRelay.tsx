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
        <Section title="Relay Configuration">
          <LabeledList>
            <LabeledList.Item label="Machine Power">
              <Button
                selected={active}
                icon="power-off"
                onClick={() => act('toggle_active')}
              >
                {active ? 'On' : 'Off'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Network ID">
              <Button
                selected={!!network_id}
                icon="server"
                onClick={() => act('network_id')}
              >
                {network_id ? network_id : 'Unset'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Link Status">
              {linked ? (
                <Box color="green">Linked</Box>
              ) : (
                <Box color="red">Unlinked</Box>
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
    <Section title="Link Status">
      <LabeledList>
        <LabeledList.Item label="Linked Core ID">
          {linked_core_id}
        </LabeledList.Item>
        <LabeledList.Item label="Linked Core Address">
          {linked_core_addr}
        </LabeledList.Item>
        <LabeledList.Item label="Hidden Link">
          <Button
            icon={hidden_link ? 'eye-slash' : 'eye'}
            selected={hidden_link}
            onClick={() => act('toggle_hidden_link')}
          >
            {hidden_link ? 'Yes' : 'No'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Unlink">
          <Button icon="unlink" color="red" onClick={() => act('unlink')}>
            Unlink
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
    <Section title="Detected Cores">
      <Table m="0.5rem">
        <Table.Row header>
          <Table.Cell>Network Address</Table.Cell>
          <Table.Cell>Network ID</Table.Cell>
          <Table.Cell>Sector</Table.Cell>
          <Table.Cell>Link</Table.Cell>
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
                Link
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
