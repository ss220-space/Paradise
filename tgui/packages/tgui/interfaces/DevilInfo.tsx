import { useBackend } from '../backend';
import { Section, Stack } from '../components';
import { Window } from '../layouts';

type DevilInfoData = {
  true_name: string;
  ban: string;
  obligation: string;
  bane: string;
  banish: string;
  souls_count: number;
  sacrifice_count: number;
  rank: string;
  next_rank: string;
  required_souls: number;
  sacrifice_required: boolean;
  ritual_required: boolean;
};

export const DevilInfo = (_props: unknown) => {
  const { data } = useBackend<DevilInfoData>();
  const {
    true_name,
    ban,
    banish,
    obligation,
    bane,
    souls_count,
    sacrifice_count,
    rank,
    next_rank,
    required_souls,
    sacrifice_required,
    ritual_required,
  } = data;
  return (
    <Window theme="infernal">
      <Window.Content>
        <Section title="Информация о дьяволе">
          <Stack vertical zebra>
            <Stack.Item p={1}>
              Истинное имя: <b>{true_name}</b>
            </Stack.Item>
            <Stack.Item p={1}>
              Запрет: <b>{ban}</b>
            </Stack.Item>
            <Stack.Item p={1}>
              Обязательство: <b>{obligation}</b>
            </Stack.Item>
            <Stack.Item p={1}>
              Слабость: <b>{bane}</b>
            </Stack.Item>
            <Stack.Item p={1}>
              Изгнание: <b>{banish}</b>
            </Stack.Item>
            <Stack.Item p={1}>
              Собрано душ/Принесено жертв:{' '}
              <b>
                {souls_count}/{sacrifice_count}
              </b>
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Ранг">
          {' '}
          <Stack vertical zebra>
            <Stack.Item p={1}>
              Текущий ранг: <b>{rank}</b>
            </Stack.Item>
            <Stack.Item p={1}>
              Следующий ранг: <b>{next_rank}</b>
            </Stack.Item>
            <Stack.Item p={1}>
              Необхдимо душ: <b>{required_souls}</b>
            </Stack.Item>
            <Stack.Item p={1}>
              Необходимо жертв:<b>{sacrifice_required}</b>
            </Stack.Item>
            <Stack.Item p={1}>
              Нужен ритуал возвышения:{' '}
              <span style={{ color: ritual_required ? 'green' : 'red' }}>
                <b>{ritual_required ? 'Да' : 'Нет'}</b>
              </span>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
