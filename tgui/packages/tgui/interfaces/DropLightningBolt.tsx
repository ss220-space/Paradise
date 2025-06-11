import { BooleanLike } from 'common/react';
import { useState } from 'react';
import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  NumberInput,
  Section,
  Dropdown,
  Box,
} from '../components';
import { Window } from '../layouts';

type LightningBoltMode = 'По игроку' | 'По указателю';

type LightningBoltData = {
  mode: LightningBoltMode;
  damage: number;
  radius: number;
  delay: number;
  ckey: string;
  players: Record<string, string>;
  pointing: BooleanLike;
};

export const DropLightningBolt = (props: unknown) => {
  const { act, data } = useBackend<LightningBoltData>();
  const {
    damage,
    radius,
    delay,
    ckey,
    players,
    pointing,
    mode: backendMode,
  } = data;

  const availableModes: LightningBoltMode[] = ['По игроку', 'По указателю'];

  const [mode, setMode] = useState<LightningBoltMode>(backendMode);
  const [autoupdate, setAutoupdate] = useState(true);

  return (
    <Window width={300} height={340} title="Вызов молнии">
      <Window.Content>
        <Section
          scrollable
          title="Настройка"
          buttons={
            <Dropdown
              width="150px"
              options={availableModes}
              selected={mode}
              onSelected={(val) => {
                const m = val as LightningBoltMode;
                setMode(m);
                act('set_mode', { mode: m });
              }}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Урон молнии">
              <NumberInput
                maxValue={600}
                minValue={0}
                step={1}
                value={damage}
                onChange={(val) => act('set_damage', { damage: val })}
              />
            </LabeledList.Item>
            <LabeledList.Item
              label="Радиус поражения"
              tooltip="Включая центр, без снижения урона с отдалением от центра"
            >
              <NumberInput
                maxValue={30}
                minValue={0}
                step={1}
                value={radius}
                onChange={(val) => act('set_radius', { radius: val })}
              />
            </LabeledList.Item>
            <LabeledList.Item
              label="Задержка перед ударом"
              tooltip="В секундах"
            >
              <NumberInput
                maxValue={60}
                minValue={0}
                step={1}
                value={delay}
                onChange={(val) => act('set_delay', { delay: val })}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={mode ?? 'Не выбран режим'}>
          {mode === 'По игроку' && (
            <LabeledList>
              <LabeledList.Item
                label="Игрок"
                buttons={
                  <Dropdown
                    width="150px"
                    options={Object.values(players)}
                    selected={players[ckey] || ckey}
                    onSelected={(val) => {
                      const selectedCkey = Object.keys(players).find(
                        (key) => players[key] === val
                      );
                      act('pick_player', { ckey: selectedCkey });
                    }}
                  />
                }
              />
            </LabeledList>
          )}
          {mode === 'По указателю' && (
            <Button
              width="100%"
              tooltip="При статусе «Не готов» — нажмите на кнопку.
                  После нажатия и при последующих кликах не по кнопке — вы будете дропать молнии на тайл/моба,
                  на которого указывает курсор мыши."
              textAlign="center"
              selected={pointing}
              onClick={() => act('set_pointing', { val: !pointing })}
            >
              {pointing ? 'Готов' : 'Не готов'}
            </Button>
          )}
        </Section>
        <Section>
          <Box textAlign="center">
            <Button
              icon="bolt"
              color="red"
              disabled={!mode || mode === 'По указателю'}
              onClick={() => act('drop')}
            >
              Вызвать молнию
            </Button>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
