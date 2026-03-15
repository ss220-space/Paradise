import { useState } from 'react';
import { Box, Button, Stack, Table, Tabs } from '../components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

interface BotData {
  name: string;
  model: string;
  status: number;
  location: string;
  on: boolean;
  UID: string;
}

type BotMap = Record<number, BotData[]>;

interface BotCallData {
  bots: BotMap;
}

const BOT_NAMES: Record<number, string> = {
  0: 'Security',
  1: 'Medibot',
  2: 'Cleanbot',
  3: 'Floorbot',
  4: 'Mule',
  5: 'Honkbot',
};

interface StatusMapping {
  modes: number[];
  label: string;
  color: string;
}

const BotStatus: React.FC<{ mode: number }> = ({ mode }) => {
  const statusMap: StatusMapping[] = [
    { modes: [0, 20], label: 'Idle', color: 'green' },
    { modes: [1, 2, 3], label: 'Arresting', color: 'yellow' },
    { modes: [4, 5], label: 'Patrolling', color: 'average' },
    { modes: [9], label: 'Moving', color: 'average' },
    { modes: [6, 11], label: 'Responding', color: 'green' },
    { modes: [12], label: 'Delivering Cargo', color: 'blue' },
    { modes: [13], label: 'Returning Home', color: 'blue' },
    {
      modes: [7, 8, 10, 14, 15, 16, 17, 18, 19],
      label: 'Working',
      color: 'blue',
    },
  ];

  const failsafeStatus = (mode: number): StatusMapping => ({
    modes: [-1],
    label: `ERROR!!CALL_CODER!!${mode}`,
    color: 'red',
  });

  const matchedStatus =
    statusMap.find((mapping) => mapping.modes.includes(mode)) ||
    failsafeStatus(mode);

  return <Box color={matchedStatus.color}> {matchedStatus.label} </Box>;
};

export const BotCall: React.FC = () => {
  const { act, data } = useBackend<BotCallData>();
  const [tabIndex, setTabIndex] = useState<number>(0);

  const decideTab = (index: number) => {
    const modelName = BOT_NAMES[index];
    return modelName ? (
      <BotExists model={modelName} />
    ) : (
      <Box>This should not happen. Please report this in the bug report.</Box>
    );
  };

  return (
    <Window width={700} height={400}>
      <Window.Content scrollable={tabIndex === 0}>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs fluid textAlign="center">
              {Array.from({ length: 6 }).map((_, index) => (
                <Tabs.Tab
                  key={index}
                  selected={tabIndex === index}
                  onClick={() => setTabIndex(index)}
                >
                  {BOT_NAMES[index]}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          {decideTab(tabIndex)}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const BotExists: React.FC<{ model: string }> = ({ model }) => {
  const { data } = useBackend<BotCallData>();
  const { bots } = data;

  const botType = Object.keys(BOT_NAMES).find(
    (key) => BOT_NAMES[Number(key)] === model
  );

  if (botType !== undefined && bots[Number(botType)] !== undefined) {
    return <MapBot model={model} />;
  } else {
    return <NoBot model={model} />;
  }
};

const NoBot: React.FC<{ model: string }> = ({ model }) => {
  return (
    <Stack justify="center" align="center" fill vertical>
      <Box bold color="bad">
        No {model} detected
      </Box>
    </Stack>
  );
};

const MapBot: React.FC<{ model: string }> = ({ model }) => {
  const { act, data } = useBackend<BotCallData>();
  const { bots } = data;

  const botType = Object.keys(BOT_NAMES).find(
    (key) => BOT_NAMES[Number(key)] === model
  );
  if (!botType) return null;

  const botList = bots[Number(botType)] || [];

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Table m="0.5rem">
          <Table.Row header>
            <Table.Cell>Name</Table.Cell>
            <Table.Cell>Model</Table.Cell>
            <Table.Cell>Status</Table.Cell>
            <Table.Cell>Location</Table.Cell>
            <Table.Cell>Interface</Table.Cell>
            <Table.Cell>Call</Table.Cell>
          </Table.Row>
          {botList.map((bot) => (
            <Table.Row key={bot.UID}>
              <Table.Cell>{bot.name}</Table.Cell>
              <Table.Cell>{bot.model}</Table.Cell>
              <Table.Cell>
                {bot.on ? (
                  <BotStatus mode={bot.status} />
                ) : (
                  <Box color="red">Off</Box>
                )}
              </Table.Cell>
              <Table.Cell>{bot.location}</Table.Cell>
              <Table.Cell>
                <Button onClick={() => act('interface', { botref: bot.UID })} />
                Interface
              </Table.Cell>
              <Table.Cell>
                <Button onClick={() => act('call', { botref: bot.UID })} />
                Call
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Stack.Item>
    </Stack>
  );
};
