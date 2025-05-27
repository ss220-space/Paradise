import { useBackend } from '../backend';
import { useState } from 'react';
import {
  Button,
  Tabs,
  Box,
  Stack,
  Section,
  Tooltip,
  Icon,
  LabeledList,
  Table,
  Image,
} from '../components';
import { classes } from 'common/react';
import { Window } from '../layouts';
import { decodeHtmlEntities } from 'common/string';

const getRewardColor = (reward: number, isCorp: boolean) => {
  if (isCorp) {
    reward /= 10;
  }

  if (reward > 1100) {
    return 'purple';
  }
  if (reward > 500) {
    return 'orange';
  }
  if (reward > 250) {
    return 'yellow';
  }
  return 'green';
};

const mapTwoByTwo = <T1, T2>(a: T1[], c: (b: T1, c: T1, i: number) => T2) => {
  let result = [];
  for (let i = 0; i < a.length; i += 2) {
    result.push(c(a[i], a[i + 1], i));
  }
  return result;
};

type QuestConsoleData = {
  points: number;
  timeleft: number;
  moving: boolean;
  at_station: boolean;
  techs: Tech[];
  cargo_money: number;
  purchased_techs: Tech[];
  quests: Quest[];
};

type Tech = {
  tech_name: string;
  tech_id: string;
  tech_level: number;
  cost: number;
};

type Quest = {
  customer: string;
  ref: string;
  reward: number;
  target_departament: string;
  fast_bonus: boolean;
  active: boolean;
  timer: string;
  quests_items: Task[];
};

export const QuestConsole = (_properties) => {
  const [tabName, setTab] = useState('centcomm');
  return (
    <Window width={1000} height={820}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Tabs fluid>
            <Tabs.Tab
              key="NT Requests"
              icon="mail-bulk"
              selected={tabName === 'centcomm'}
              onClick={() => setTab('centcomm')}
            >
              NT Requests
            </Tabs.Tab>
            <Tabs.Tab
              key="Commercial"
              icon="dollar-sign"
              selected={tabName === 'corporation'}
              onClick={() => setTab('corporation')}
            >
              Commercial
            </Tabs.Tab>
            <Tabs.Tab
              key="Plasma Supply"
              icon="fire"
              selected={tabName === 'plasma'}
              onClick={() => setTab('plasma')}
            >
              Plasma Supply
            </Tabs.Tab>
            <Tabs.Tab
              key="Management"
              icon="info"
              selected={tabName === 'management'}
              onClick={() => setTab('management')}
            >
              Management
            </Tabs.Tab>
          </Tabs>
          {tabName === 'management' ? (
            <StatusPane />
          ) : (
            <QuestPane source_customer={tabName} />
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const StatusPane = (_properties) => {
  const { act, data } = useBackend<QuestConsoleData>();
  const {
    points,
    timeleft,
    moving,
    at_station,
    techs,
    cargo_money,
    purchased_techs,
  } = data;

  // Shuttle status text
  let statusText: string;
  if (moving) {
    statusText = `Shuttle is en route (ETA: ${timeleft} minute${timeleft !== 1 ? 's' : ''})`;
  } else if (at_station) {
    statusText = 'Docked at the station';
  } else {
    statusText = 'Docked off-station';
  }

  return (
    <Box>
      <Section title="Status">
        <LabeledList>
          <LabeledList.Item label="Points Available">{points}</LabeledList.Item>
          <LabeledList.Item label="Shuttle Status">
            {statusText}
          </LabeledList.Item>
          <LabeledList.Item label="Current Cargo Budget">
            {cargo_money} credits
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Sent Technologies">
        {techs.map((tech, index) => (
          <Box key={index}>
            {' '}
            {tech.tech_name}: {tech.tech_level || '0'}
          </Box>
        ))}
        {!techs.length ? <Box>No tecnologies sent yet</Box> : <Box />}
      </Section>
      <Section title="Buy High-Tech Technologies">
        {purchased_techs ? (
          <LabeledList>
            {purchased_techs.map((tech, index) => (
              <Stack mb={0.5} key={tech.tech_id}>
                <Stack.Item width={'25%'}>{tech.tech_name}:</Stack.Item>
                <Stack.Item width={'10%'} ml={3}>
                  {tech.cost}
                </Stack.Item>
                <Stack.Item ml={3}>
                  <Button
                    onClick={() =>
                      act('buy_tech', {
                        cost: tech.cost,
                        tech_name: tech.tech_name,
                      })
                    }
                  >
                    Buy
                  </Button>
                </Stack.Item>
              </Stack>
            ))}
          </LabeledList>
        ) : (
          <Box>Nine seventh-level technologies have not been sent yet</Box>
        )}
      </Section>
    </Box>
  );
};

type QuestPaneProps = {
  source_customer: string;
};

const QuestPane = (properties: QuestPaneProps) => {
  const { data } = useBackend<QuestConsoleData>();
  const { source_customer } = properties;
  const { quests } = data;
  return (
    <Table>
      {mapTwoByTwo(
        quests.filter((quest) => quest.customer === source_customer),
        (quest1, quest2, index) => (
          <Table.Row key={index}>
            <Table.Cell px={2} py={1.25} width="50%" height="1px">
              <QuestItem quest={quest1} />
            </Table.Cell>
            <Table.Cell px={2} py={1.25} width="50%" height="1px">
              {quest2 ? <QuestItem quest={quest2} /> : <Box />}
            </Table.Cell>
          </Table.Row>
        )
      )}
    </Table>
  );
};

type QuestFastTimeBonusProps = {
  color: string;
};

const QuestFastTimeBonus = (properties: QuestFastTimeBonusProps) => (
  <Box position="absolute" right={0.7} top={0.6}>
    <Tooltip content="Fast time bonus active" position="left" />
    <Icon name="fire" size={1.3} color={properties.color || 'average'} />
  </Box>
);

type QuestItemProps = {
  quest: Quest;
};

const QuestItem = (properties: QuestItemProps) => {
  const [cardWithShownMenu, setCardWithShownMenu] = useState('');
  const { act } = useBackend();
  const { quest } = properties;
  const isCorp = quest.customer === 'corporation';
  const rewardColor = getRewardColor(quest.reward, isCorp);
  return (
    <Section
      title={`Order from ${quest.target_departament}`}
      className={`QuestConsoleSection QuestConsoleSection--${rewardColor} ${cardWithShownMenu === quest.ref && 'QuestConsoleSection--dimmed'} ${quest.active && 'QuestConsoleSection--active'}`}
      height="100%"
      stretchContents
      position="relative"
      overflow="clip"
      onClick={() =>
        setCardWithShownMenu(cardWithShownMenu !== quest.ref ? quest.ref : '')
      }
    >
      {!quest.fast_bonus || <QuestFastTimeBonus color={rewardColor} />}
      <Stack
        className="QuestConsoleSection__content"
        direction="column"
        height="calc(100% - 33px)"
      >
        <Stack.Item>
          <Table>
            {mapTwoByTwo(quest.quests_items, (task1, task2, index) => (
              <Table.Row key={index}>
                <Table.Cell width="50%">
                  <QuestItemTask task={task1} />
                </Table.Cell>
                <Table.Cell width="50%">
                  {task2 ? <QuestItemTask task={task2} /> : <Box />}
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Stack.Item>
        <Stack.Item grow={1} basis={1} />
        <Stack.Item>
          <Table>
            <Table.Row>
              <Table.Cell>
                <Box fontSize={1.15}>
                  <b>PROFIT:</b> +{quest.reward} {isCorp ? 'credits' : 'points'}
                </Box>
              </Table.Cell>
              <Table.Cell>
                <Box>
                  <b>Time left:</b> {quest.timer}
                </Box>
              </Table.Cell>
            </Table.Row>
          </Table>
        </Stack.Item>
      </Stack>
      {cardWithShownMenu !== quest.ref || (
        <>
          <Box
            fillPositionedParent
            backgroundColor="black"
            opacity="0.5"
            style={{ zIndex: '1' }}
          />
          {!quest.active ? (
            <Box
              position="absolute"
              top="50%"
              left="50%"
              textAlign="center"
              style={{ zIndex: '2', transform: 'translate(-50%, -50%)' }}
            >
              <Box bold fontSize={1.3} mb={2}>
                Choose an option:
              </Box>
              <Button
                icon="check"
                color="green"
                fontSize={1.2}
                py={1}
                px={2}
                onClick={() => act('activate', { uid: quest.ref })}
              >
                Take
              </Button>
              <Button
                ml={2}
                icon="undo"
                color="blue"
                fontSize={1.2}
                py={1}
                px={2}
                onClick={() => act('denied', { uid: quest.ref })}
              >
                Reroll
              </Button>
            </Box>
          ) : (
            <Box
              position="absolute"
              top="50%"
              left="50%"
              textAlign="center"
              style={{ zIndex: '2', transform: 'translate(-50%, -50%)' }}
            >
              <Box bold fontSize={1.2}>
                The order is already being processed
              </Box>
              <Button
                icon="print"
                color="blue"
                fontSize={1.2}
                py={1}
                px={2}
                onClick={() => act('print_order', { uid: quest.ref })}
              >
                Print
              </Button>
              <Button
                ml={2}
                icon="hourglass-half"
                color="orange"
                fontSize={1.2}
                py={1}
                px={2}
                onClick={() => act('add_time', { uid: quest.ref })}
              >
                Delay
              </Button>
            </Box>
          )}
        </>
      )}
    </Section>
  );
};

type QuestItemTaskProps = {
  task: Task;
};

type Task = {
  image: string;
  quest_type_name: string;
  desc: string;
};

const QuestItemTask = (properties: QuestItemTaskProps) => {
  const { task } = properties;
  return (
    <Stack align="center" position="relative">
      <Stack.Item width={'42px'} mr={1}>
        <Box position="relative">
          <Tooltip position="right" content={'Send ' + task?.quest_type_name} />
          <Image
            className={classes(['cargo_quest42x42', task?.image])}
            style={{
              verticalAlign: 'middle',
              width: '42px',
              margin: '0px',
            }}
          />
        </Box>
      </Stack.Item>
      <Stack.Item style={{ maxWidth: '180px', whiteSpace: 'pre' }}>
        {decodeHtmlEntities(task.desc)}
      </Stack.Item>
    </Stack>
  );
};
