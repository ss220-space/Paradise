import { classes } from 'common/react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Section,
  Stack,
  Table,
  AnimatedNumber,
  Icon,
  LabeledList,
  ProgressBar,
  NumberInput,
} from '../components';
import { Window } from '../layouts';

type AnomalyStabilizerData = {
  full_info;
  core1_name;
  core2_name;
  possible_stability;
  stability_delta;
  pull_range;
  choosen_pull_dist;
  block_move_time;
  block_move_impulses_time;
  weaken_val;
  weaken_time;
};

export const AnomalyStabilizer = (props) => {
  const { act, data } = useBackend<AnomalyStabilizerData>();
  const {
    full_info,
    core1_name,
    core2_name,
    possible_stability,
    stability_delta,
    pull_range,
    choosen_pull_dist,
    block_move_time,
    block_move_impulses_time,
    weaken_val,
    weaken_time,
  } = data;
  return (
    <Window width={710} height={500} title="Настройка стабилизатора аномалий">
      <Window.Content>
        <Section title="Вставленные ядра">
          {InsertedCores(core1_name, core2_name)}
        </Section>
        <Box mt="5px">
          Выбор уровня стабилизации:
          <NumberInput
            minValue={-possible_stability}
            maxValue={possible_stability}
            step={1}
            value={stability_delta}
            onChange={(e, value) => act('change_stability', { new_val: value })}
          />
        </Box>
        {full_info ? (
          <Box italic mt="5px">
            Чтобы расширить область допустимых значений изменения стабильности,
            вы можете вставить ядро энергетической аномалии. Затраты энергии при
            изменении стабильности на Х повышены в Х*Х раз при Х не равном 0.
          </Box>
        ) : null}

        <Box mt="5px">
          Выбор силы притяжения:
          <NumberInput
            minValue={-pull_range}
            maxValue={pull_range}
            step={1}
            value={choosen_pull_dist}
            onChange={(e, value) => act('change_pull_dist', { new_val: value })}
          />
        </Box>
        {full_info ? (
          <Box>
            <Box italic mt="5px">
              Чтобы добавить снарядам возможность притягивать аномалию,
              необходимо вставить ядро гравитационной аномалии. При
              отрицательной силе притяжения, аномалию будет отталкивать на
              выбранное количество шагов.
            </Box>
            <Box italic mt="5px">
              Снаряды будут блокировать естественное передвижение аномалии на
              время равное {block_move_time / 10} в секундах. Для увеличения
              этого значения добавьте ядро вихревой аномалии.
            </Box>
            <Box italic mt="5px">
              Снаряды будут блокировать импульсы перемещающие аномалию на время
              равное {block_move_impulses_time / 10} в секундах. Для увеличения
              этого значения добавьте ядро блюспейс аномалии.
            </Box>
            <Box italic mt="5px">
              Снаряды будут ослаблять эффекты аномалии на время равное
              {weaken_time / 10} в секундах. Ослабление будет понижать эффекты
              до уровня аномалии с силой на
              {weaken_val} меньше текущей, но не ниже 10. Для увеличения этих
              значений добавьте ядро атмосферной аномалии.
            </Box>
          </Box>
        ) : null}
        <Button
          mt="5px"
          content={!full_info ? 'Показать справку' : 'Скрыть'}
          onClick={() => act('toggle_full_info')}
        />
      </Window.Content>
    </Window>
  );
};

const InsertedCores = (core1_name: string, core2_name: string) => {
  const { act, data } = useBackend();
  if (core1_name === 'Пустой') {
    return null;
  } else if (core2_name === 'Пустой') {
    return <Button content={core1_name} onClick={() => act('eject1', {})} />;
  } else {
    return (
      <Box>
        <Button content={core1_name} onClick={() => act('eject1', {})} />
        <Button content={core2_name} onClick={() => act('eject2', {})} />
      </Box>
    );
  }
};
