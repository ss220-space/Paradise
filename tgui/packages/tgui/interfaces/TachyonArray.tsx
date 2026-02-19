import { useBackend } from '../backend';
import {
  Button,
  Flex,
  Table,
  NoticeBox,
  Section,
  LabeledList,
} from '../components';
import { Window } from '../layouts';

type TachyonArrayData = {
  records?: ExplosionRecord[];
  explosion_target: string;
  toxins_tech: string;
  printing: boolean;
};

type ExplosionRecord = {
  index: string;
  logged_time: string;
  epicenter: string;
  actual_size_message: string;
  theoretical_size_message: string;
};

export const TachyonArray = (_props: unknown) => {
  const { act, data } = useBackend<TachyonArrayData>();
  const { records = [], explosion_target, toxins_tech, printing } = data;
  return (
    <Window width={500} height={600}>
      <Window.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Shift's Target">
              {explosion_target}
            </LabeledList.Item>
            <LabeledList.Item label="Current Toxins Level">
              {toxins_tech}
            </LabeledList.Item>
            <LabeledList.Item label="Administration">
              <Button
                icon="print"
                disabled={!records.length || printing}
                align="center"
                onClick={() => act('print_logs')}
              >
                Print All Logs
              </Button>
              <Button.Confirm
                icon="trash"
                disabled={!records.length}
                color="bad"
                align="center"
                onClick={() => act('delete_logs')}
              >
                Delete All Logs
              </Button.Confirm>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!records.length ? (
          <NoticeBox>No Records</NoticeBox>
        ) : (
          <TachyonArrayContent />
        )}
      </Window.Content>
    </Window>
  );
};

export const TachyonArrayContent = (_props: unknown) => {
  const { act, data } = useBackend<TachyonArrayData>();
  const { records = [] } = data;

  return (
    <Section title="Logged Explosions">
      <Flex>
        <Flex.Item>
          <Table m="0.5rem">
            <Table.Row header>
              <Table.Cell>Time</Table.Cell>
              <Table.Cell>Epicenter</Table.Cell>
              <Table.Cell>Actual Size</Table.Cell>
              <Table.Cell>Theoretical Size</Table.Cell>
            </Table.Row>
            {records.map((a) => (
              <Table.Row key={a.index}>
                <Table.Cell>{a.logged_time}</Table.Cell>
                <Table.Cell>{a.epicenter}</Table.Cell>
                <Table.Cell>{a.actual_size_message}</Table.Cell>
                <Table.Cell>{a.theoretical_size_message}</Table.Cell>
                <Table.Cell>
                  <Button.Confirm
                    icon="trash"
                    color="bad"
                    onClick={() =>
                      act('delete_record', {
                        'index': a.index,
                      })
                    }
                  >
                    Delete
                  </Button.Confirm>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
