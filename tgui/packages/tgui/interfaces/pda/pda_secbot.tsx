import { useBackend } from '../../backend';
import { Box, Button, LabeledList, Section } from '../../components';

type SecBotsData = {
  beepsky: SecBot;
};

type SecBot = { botstatus: SecBotStatusData } & Bot;

type SecBotStatusData = BotStatusData;

export const pda_secbot = (props: unknown) => {
  const { data } = useBackend<SecBotsData>();
  const { beepsky } = data;
  const { active } = beepsky;

  return <Box>{active ? <BotStatus /> : <BotList />}</Box>;
};

const BotList = (props: unknown) => {
  const { act, data } = useBackend<SecBotsData>();
  const { beepsky } = data;
  const { bots } = beepsky;

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
          Поиск ботов
        </Button>
      </Box>
    </Box>
  );
};

const BotStatus = (props: unknown) => {
  const { act, data } = useBackend<SecBotsData>();
  // Why are these things like 3 layers deep
  const { beepsky } = data;
  const { botstatus, active } = beepsky;

  const { mode, loca } = botstatus;

  let statusText: string;
  switch (mode) {
    case 0:
      statusText = 'Готов';
      break;
    case 1:
      statusText = 'Задержание цели';
      break;
    case 2:
    case 3:
      statusText = 'Арест цели';
      break;
    case 4:
      statusText = 'Начало патруля';
      break;
    case 5:
      statusText = 'Патрулирует';
      break;
    case 6:
      statusText = 'Отвечает на вызов';
      break;
  }

  return (
    <Section title={active}>
      {mode === -1 && (
        <Box color="red" bold>
          Ожидание ответа...
        </Box>
      )}
      <LabeledList>
        <LabeledList.Item label="Location">{loca}</LabeledList.Item>
        <LabeledList.Item label="Status">{statusText}</LabeledList.Item>
        <LabeledList.Item label="Controls">
          <Button icon="play" onClick={() => act('Go')}>
            Продолжить
          </Button>
          <Button icon="stop" onClick={() => act('Stop')}>
            Остановить
          </Button>
          <Button icon="arrow-down" onClick={() => act('Summon')}>
            Вызвать
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
