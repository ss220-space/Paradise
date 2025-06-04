import { useBackend, useSharedState } from '../backend';
import {
  Button,
  LabeledList,
  NumberInput,
  Section,
  Dropdown,
  Box,
} from '../components';
import { Window } from '../layouts';
type LightningBoltData = {
  x_coord: number;
  y_coord: number;
  z_coord: number;
  mode: string;
  damage: number;
  radius: number;
  delay: number;
  ckey: string;
  players: Record<string, string>;
};

export const DropLightningBolt = (props: unknown) => {
  const { act, data } = useBackend<LightningBoltData>();
  const { x_coord, y_coord, z_coord, damage, radius, delay, ckey, players } =
    data;

  const avaivableModes = ['По игроку', 'По координатам'];
  let [mode, setMode] = useSharedState('mode', '');
  let [autoupdate, setAutoupdate] = useSharedState('autoupdate', true);

  return (
    <Window width={280} height={420} title="Вызов молнии">
      <Window.Content>
        <Section
          scrollable
          title={'Настройка'}
          buttons={
            <Dropdown
              width="150px"
              options={avaivableModes}
              selected={mode}
              onSelected={(val) => {
                setMode(val);
                act('set_mode', { 'mode': val });
              }}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Урон молнии">
              <NumberInput
                maxValue={255}
                minValue={0}
                step={1}
                value={damage}
                onChange={(val) => act('set_damage', { 'damage': val })}
              />
            </LabeledList.Item>

            <LabeledList.Item
              label="Радиус поражения"
              tooltip="Включая центр, без снижения урона с отдалением от центра"
            >
              <NumberInput
                maxValue={255}
                minValue={0}
                step={1}
                value={radius}
                onChange={(val) => act('set_radius', { 'radius': val })}
              />
            </LabeledList.Item>
            <LabeledList.Item
              label="Задержка перед ударом"
              tooltip="В секундах"
            >
              <NumberInput
                maxValue={255}
                minValue={0}
                step={1}
                value={delay}
                onChange={(val) => act('set_delay', { 'delay': val })}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title={mode}>
          {mode === 'По игроку' && (
            <LabeledList>
              <LabeledList.Item
                label="Игрок"
                buttons={
                  <Dropdown
                    width="150px"
                    options={Object.values(players)} // Изменено с players на Object.values(players)
                    selected={players[ckey] || ckey}
                    onSelected={(val) => {
                      // Найти ckey по значению
                      const selectedCkey = Object.keys(players).find(
                        (key) => players[key] === val
                      );
                      act('pickPlayer', { 'ckey': selectedCkey });
                    }}
                  />
                }
              />
            </LabeledList>
          )}

          {mode === 'По координатам' && (
            <LabeledList>
              <LabeledList.Item label="Автообновление">
                <Button
                  icon={autoupdate ? 'toggle-on' : 'toggle-off'}
                  selected={autoupdate}
                  onClick={() => {
                    const newValue = !autoupdate;
                    setAutoupdate(newValue);
                    act('set_autoupdate', { 'val': newValue });
                  }}
                />
              </LabeledList.Item>
              <LabeledList.Item label="X">
                <NumberInput
                  maxValue={255}
                  minValue={0}
                  step={1}
                  value={x_coord}
                  onChange={(val) =>
                    act('set_coords', {
                      'x_coord': val,
                      'y_coord': y_coord,
                      'z_coord': z_coord,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Y">
                <NumberInput
                  maxValue={255}
                  minValue={0}
                  step={1}
                  value={y_coord}
                  onChange={(val) => {
                    act('set_coords', {
                      'x_coord': x_coord,
                      'y_coord': val,
                      'z_coord': z_coord,
                    });
                  }}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Z">
                <NumberInput
                  maxValue={255}
                  minValue={0}
                  step={1}
                  value={z_coord}
                  onChange={(val) =>
                    act('set_coords', {
                      'x_coord': x_coord,
                      'y_coord': y_coord,
                      'z_coord': val,
                    })
                  }
                />
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
        <Section>
          <Box textAlign="center">
            <Button
              icon="bolt"
              color="red"
              disabled={mode ? false : true}
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
