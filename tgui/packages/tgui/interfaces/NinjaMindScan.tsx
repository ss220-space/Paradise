import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  LabeledList,
  Section,
  Table,
  NoticeBox,
  Image,
} from '../components';
import { Window } from '../layouts';

export const NinjaMindScan = (_props: unknown) => {
  return (
    <Window width={500} height={400} theme="spider_clan">
      <Window.Content className="Layout__content--flexColumn">
        <MindScanMenu />
      </Window.Content>
    </Window>
  );
};

type MindScanData = {
  occupantIcon: string;
  occupant_name: string;
  occupant_health: number;
  scanned_occupants: Occupant[];
};

type Occupant = {
  scanned_occupant: string;
};

const MindScanMenu = (_props: unknown) => {
  const { act, data } = useBackend<MindScanData>();
  const { occupantIcon, occupant_name, occupant_health, scanned_occupants } =
    data;
  let block_buttons = occupant_name === 'none' ? 1 : 0;

  return (
    <Flex direction="column" shrink={1} alignContent="left">
      <Section
        title={'Пациент'}
        backgroundColor="rgba(0, 0, 0, 0.4)"
        buttons={
          <Button
            tooltip={
              'Отображение внешнего вида и состояния пациента в устройстве.'
            }
            tooltipPosition="left"
          >
            ?
          </Button>
        }
      >
        <Flex direction="row" shrink={1} alignContent="left">
          <Flex.Item shrink={1} alignContent="left">
            <NoticeBox className="NoticeBox_blue" width="90px" align="left">
              <Section
                style={{ background: 'rgba(4, 74, 27, 0.75)' }}
                align="left"
                mb={-1}
              >
                <Image
                  height="128px"
                  width="128px"
                  src={`data:image/jpeg;base64,${occupantIcon}`}
                  ml="-28px"
                />
              </Section>
            </NoticeBox>
          </Flex.Item>
          <Flex.Item grow={1} alignContent="right">
            <NoticeBox className="NoticeBox_green" align="left" ml={1}>
              <LabeledList>
                <LabeledList.Item label="Имя">{occupant_name}</LabeledList.Item>
                <LabeledList.Item label="Здоровье">
                  {occupant_health}
                </LabeledList.Item>
              </LabeledList>
            </NoticeBox>
            <NoticeBox className="NoticeBox_red" mt={2.5} align="center" ml={1}>
              <Button
                className={block_buttons === 0 ? '' : 'Button_disabled'}
                width="250px"
                textAlign="center"
                disabled={block_buttons}
                tooltip={
                  'Сканирует пациента и пытается добыть из его разума необходимую клану информацию.'
                }
                tooltipPosition="bottom-start"
                onClick={() => act('scan_occupant')}
              >
                Начать сканирование
              </Button>

              <Button
                className={block_buttons === 0 ? '' : 'Button_disabled'}
                width="250px"
                textAlign="center"
                disabled={block_buttons}
                tooltip={'Открывает устройство, выпуская пациента из капсулы'}
                tooltipPosition="bottom-start"
                onClick={() => act('go_out')}
              >
                Открыть устройство
              </Button>

              <Button
                className={block_buttons === 0 ? '' : 'Button_disabled'}
                width="250px"
                textAlign="center"
                disabled={block_buttons}
                tooltip={
                  'Телепортирует пациента обратно на обьект с которого он был похищен. Рекомендуем как следует его запугать перед этим, чтобы он не разболтал о вас.'
                }
                tooltipPosition="bottom-start"
                onClick={() => act('teleport_out')}
              >
                Телепортация пациента
              </Button>
            </NoticeBox>
          </Flex.Item>
        </Flex>
      </Section>
      <Section
        title={'Список уже просканированных вами людей'}
        align="center"
        backgroundColor="rgba(0, 0, 0, 0.4)"
      >
        <Box maxHeight={15} overflowY="auto" overflowX="hidden">
          <Table m="0.5rem">
            {scanned_occupants.map((r) => (
              <Table.Row key={r.scanned_occupant}>
                <Table.Cell>
                  <Box>{r.scanned_occupant}</Box>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Box>
      </Section>
    </Flex>
  );
};
