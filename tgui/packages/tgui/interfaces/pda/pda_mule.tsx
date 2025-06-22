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
          Поиск ботов
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
      statusText = 'Готов';
      break;
    case 1:
      statusText = 'Погрузка/выгрузка';
      break;
    case 2:
    case 12:
      statusText = 'Перемещение к месту доставки';
      break;
    case 3:
      statusText = 'Перемещение домой';
      break;
    case 4:
      statusText = 'Ожидание освобождения пути';
      break;
    case 5:
    case 6:
      statusText = 'Производится расчёт пути';
      break;
    case 7:
      statusText = 'Невозможно найти пункт назначения';
      break;
    default:
      statusText = mode.toString();
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
        <LabeledList.Item label="Местоположение">{loca}</LabeledList.Item>
        <LabeledList.Item label="Статус">{statusText}</LabeledList.Item>
        <LabeledList.Item label="Заряд">{powr}%</LabeledList.Item>
        <LabeledList.Item label="Домашняя точка">{home}</LabeledList.Item>
        <LabeledList.Item label="Пункт назначения">
          <Button onClick={() => act('SetDest')}>
            {dest ? dest + ' (Указать)' : 'Нет (Указать)'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Загружено сейчас">
          <Button disabled={!load} onClick={() => act('Unload')}>
            {load ? load + ' (Разгрузить)' : 'Ничего'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Автоподбор">
          <Button
            selected={pick}
            onClick={() =>
              act('SetAutoPickup', {
                autoPickupType: pick ? 'pickoff' : 'pickon',
              })
            }
          >
            {pick ? 'Да' : 'Нет'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Автоматический возврат домой">
          <Button
            selected={retn}
            onClick={() =>
              act('SetAutoReturn', {
                autoReturnType: retn ? 'retoff' : 'reton',
              })
            }
          >
            {retn ? 'Да' : 'Нет'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Controls">
          <Button icon="stop" onClick={() => act('Stop')}>
            Остановить
          </Button>
          <Button icon="play" onClick={() => act('Start')}>
            Продолжить
          </Button>
          <Button icon="home" onClick={() => act('ReturnHome')}>
            Вернуться домой
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
