import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  NumberInput,
  Section,
  Dropdown,
  Box,
  Tooltip,
  Stack,
} from '../components';
import { Window } from '../layouts';

type LightningBoltData = {
  mode: string;
  damage: number;
  radius: number;
  delay: number;
  ckey: string;
  players: Record<string, string>;
  pointing: BooleanLike;
};

type PlayerDropdownOption = {
  displayText: string;
  value: string;
};

const getPlayerOptions = (
  players: Record<string, string>
): PlayerDropdownOption[] => {
  return Object.entries(players).map(([ckey, display]) => ({
    displayText: display,
    value: ckey,
  }));
};

const findCkeyByDisplayText = (
  players: Record<string, string>,
  displayText: string
): string | undefined => {
  return Object.keys(players).find((key) => players[key] === displayText);
};

export const DropLightningBolt = (props: unknown) => {
  const { act, data } = useBackend<LightningBoltData>();
  const { damage, radius, delay, ckey, players, pointing, mode } = data;

  const playerOptions = getPlayerOptions(players);
  const currentPlayerDisplay = players[ckey] || ckey;

  const isPlayerMode = mode === 'По игроку';
  const isPointerMode = mode === 'По указателю';
  const isDropButtonDisabled = !mode || isPointerMode;

  return (
    <Window width={300} height={280} title="Вызов молнии" theme="admin">
      <Window.Content>
        <Section title={mode ?? 'Не выбран режим'}>
          {isPlayerMode && (
            <LabeledList>
              <LabeledList.Item
                label="Игрок"
                buttons={
                  <Dropdown
                    width="150px"
                    options={playerOptions.map((opt) => opt.displayText)}
                    selected={currentPlayerDisplay}
                    onSelected={(displayText) => {
                      const selectedCkey = findCkeyByDisplayText(
                        players,
                        displayText
                      );
                      if (selectedCkey) {
                        act('pick_player', { ckey: selectedCkey });
                      }
                    }}
                  />
                }
              />
            </LabeledList>
          )}

          {isPointerMode && (
            <Tooltip
              content={`При статусе «Не готов» — нажмите на кнопку.
                После нажатия и при последующих кликах не по кнопке —
                вы будете дропать молнии на тайл/моба,
                на которого указывает курсор мыши.`}
              position="bottom"
            >
              <Button
                width="100%"
                textAlign="center"
                selected={pointing}
                onClick={() => act('set_pointing', { val: !pointing })}
              >
                {pointing ? 'Готов' : 'Не готов'}
              </Button>
            </Tooltip>
          )}
        </Section>

        <Section
          scrollable
          title="Настройка"
          buttons={
            <Dropdown
              width="150px"
              options={['По игроку', 'По указателю']}
              selected={mode}
              onSelected={(value) => act('set_mode', { mode: value })}
            />
          }
        >
          <Stack vertical fill>
            <Stack.Item>
              <Stack align="center">
                <Stack.Item grow>
                  <Box>Урон молнии:</Box>
                </Stack.Item>
                <Stack.Item>
                  <NumberInput
                    maxValue={600}
                    minValue={0}
                    step={1}
                    value={damage}
                    onChange={(value) => act('set_damage', { damage: value })}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack align="center">
                <Stack.Item grow>
                  <Box>
                    <Tooltip
                      content="Включая центр, без снижения урона
                      с отдалением от центра"
                    >
                      Радиус поражения:
                    </Tooltip>
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Tooltip
                    content="Включая центр, без снижения урона
                    с отдалением от центра"
                  >
                    <NumberInput
                      maxValue={30}
                      minValue={0}
                      step={1}
                      value={radius}
                      onChange={(value) => act('set_radius', { radius: value })}
                    />
                  </Tooltip>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack align="center">
                <Stack.Item grow>
                  <Box>
                    <Tooltip content="В секундах">
                      Задержка перед ударом:
                    </Tooltip>
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Tooltip content="В секундах">
                    <NumberInput
                      maxValue={60}
                      minValue={0}
                      step={1}
                      value={delay}
                      onChange={(value) => act('set_delay', { delay: value })}
                    />
                  </Tooltip>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>

        <Section>
          <Box textAlign="center">
            <Button
              icon="bolt"
              color="red"
              disabled={isDropButtonDisabled}
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
