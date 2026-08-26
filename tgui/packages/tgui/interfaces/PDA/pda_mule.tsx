import { useBackend } from '../../backend';
import { Box, Button, LabeledList, Section } from '../../components';

export const pda_mule = (props: unknown) => {
  const { data } = useBackend<MuleBotsData>();
  const { mulebot } = data;
  const { active } = mulebot;

  return <Box>{active ? <BotStatus /> : <BotList />}</Box>;
};

type MuleBotsData = {
  mulebot: MuleBot;
};

type MuleBot = { botstatus: MuleBotStatusData } & Bot;

type MuleBotStatusData = {
  load: string;
  powr: number;
  dest: string;
  home: string;
  retn: boolean;
  pick: boolean;
} & BotStatusData;

const BotList = (props: unknown) => {
  const { act, data } = useBackend<MuleBotsData>();
  const { mulebot } = data;
  const { bots } = mulebot;

  return (
    <Box>
      {bots.map((b) => (
        <Box key={b.Name}>
          <Button icon="cog" onClick={() => act('AccessBot', { uid: b.uid })}>
            {b.Name}
          </Button>
        </Box>
      ))}
      <Box mt={2}>
        <Button fluid icon="rss" onClick={() => act('Rescan')}>
          Re-scan for bots
        </Button>
      </Box>
    </Box>
  );
};

const BotStatus = (props: unknown) => {
  const { act, data } = useBackend<MuleBotsData>();
  // Why are these things like 3 layers deep
  const { mulebot } = data;
  const { botstatus, active } = mulebot;

  const { mode, loca, load, powr, dest, home, retn, pick } = botstatus;

  let statusText: string;
  switch (mode) {
    case 0:
      statusText = 'Ready';
      break;
    case 1:
      statusText = 'Loading/Unloading';
      break;
    case 2:
    case 12:
      statusText = 'Navigating to delivery location';
      break;
    case 3:
      statusText = 'Navigating to Home';
      break;
    case 4:
      statusText = 'Waiting for clear path';
      break;
    case 5:
    case 6:
      statusText = 'Calculating navigation path';
      break;
    case 7:
      statusText = 'Unable to locate destination';
      break;
    default:
      statusText = mode.toString();
      break;
  }

  return (
    <Section title={active}>
      {mode === -1 && (
        <Box color="red" bold>
          Waiting for response...
        </Box>
      )}
      <LabeledList>
        <LabeledList.Item label="Location">{loca}</LabeledList.Item>
        <LabeledList.Item label="Status">{statusText}</LabeledList.Item>
        <LabeledList.Item label="Power">{powr}%</LabeledList.Item>
        <LabeledList.Item label="Home">{home}</LabeledList.Item>
        <LabeledList.Item label="Destination">
          <Button onClick={() => act('SetDest')}>
            {dest ? dest + ' (Set)' : 'None (Set)'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Current Load">
          <Button disabled={!load} onClick={() => act('Unload')}>
            {load ? load + ' (Unload)' : 'None'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Auto Pickup">
          <Button
            selected={pick}
            onClick={() =>
              act('SetAutoPickup', {
                autoPickupType: pick ? 'pickoff' : 'pickon',
              })
            }
          >
            {pick ? 'Yes' : 'No'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Auto Return">
          <Button
            selected={retn}
            onClick={() =>
              act('SetAutoReturn', {
                autoReturnType: retn ? 'retoff' : 'reton',
              })
            }
          >
            {retn ? 'Yes' : 'No'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Controls">
          <Button icon="stop" onClick={() => act('Stop')}>
            Stop
          </Button>
          <Button icon="play" onClick={() => act('Start')}>
            Proceed
          </Button>
          <Button icon="home" onClick={() => act('ReturnHome')}>
            Return Home
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
