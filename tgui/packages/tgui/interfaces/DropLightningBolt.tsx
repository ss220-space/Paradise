import { BooleanLike } from 'common/react';
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
import React, { useMemo } from 'react';

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
  pointing: BooleanLike;
};

/**
 * Базовый класс режима
 */
abstract class LightningMode {
  readonly name: string;
  constructor(name: string) {
    this.name = name;
  }
  /**
   * Вызывается сразу после переключения на режим
   */
  onSelect?(): void;
  /**
   * Отрисовывает UI специфичный для режима
   */
  abstract render(): JSX.Element;
}

/**
 * Режим "По игроку"
 */
class PlayerMode extends LightningMode {
  constructor(
    private act: (act: string, args?: any) => void,
    private players: Record<string, string>,
    private ckey: string
  ) {
    super('По игроку');
  }

  render() {
    const { act, players, ckey } = this;
    return (
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
                act('pickPlayer', { ckey: selectedCkey });
              }}
            />
          }
        />
      </LabeledList>
    );
  }
}

/**
 * Режим "По координатам"
 */
class CoordinateMode extends LightningMode {
  constructor(
    private act: (act: string, args?: any) => void,
    private coords: { x: number; y: number; z: number },
    private autoupdate: boolean,
    private setAutoupdate: (val: boolean) => void
  ) {
    super('По координатам');
  }

  onSelect() {
    this.act('set_coords', {
      x_coord: this.coords.x,
      y_coord: this.coords.y,
      z_coord: this.coords.z,
    });
  }

  render() {
    const { act, coords, autoupdate, setAutoupdate } = this;
    return (
      <LabeledList>
        <LabeledList.Item label="Автообновление">
          <Button
            icon={autoupdate ? 'toggle-on' : 'toggle-off'}
            selected={autoupdate}
            onClick={() => {
              const newVal = !autoupdate;
              setAutoupdate(newVal);
              act('set_autoupdate', { val: newVal });
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label="X">
          <NumberInput
            maxValue={255}
            minValue={0}
            step={1}
            value={coords.x}
            onChange={(val) =>
              act('set_coords', {
                x_coord: val,
                y_coord: coords.y,
                z_coord: coords.z,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Y">
          <NumberInput
            maxValue={255}
            minValue={0}
            step={1}
            value={coords.y}
            onChange={(val) =>
              act('set_coords', {
                x_coord: coords.x,
                y_coord: val,
                z_coord: coords.z,
              })
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Z">
          <NumberInput
            maxValue={255}
            minValue={0}
            step={1}
            value={coords.z}
            onChange={(val) =>
              act('set_coords', {
                x_coord: coords.x,
                y_coord: coords.y,
                z_coord: val,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    );
  }
}

/**
 * Режим "По указателю"
 */
class PointerMode extends LightningMode {
  constructor(
    private act: (act: string, args?: any) => void,
    private pointing: boolean
  ) {
    super('По указателю');
  }

  render() {
    const { act, pointing } = this;
    return (
      <Button
        width="100%"
        tooltip="При статусе «Не готов» — нажмите на кнопку.
После нажатия и при последующих кликах не по кнопке — вы будете дропать молнии на тайл/моба,
на которого указывает курсор мыши."
        textAlign="center"
        selected={pointing}
        onClick={() =>
          act('set_pointing', {
            val: !pointing,
          })
        }
      >
        {pointing ? 'Готов' : 'Не готов'}
      </Button>
    );
  }
}

export const DropLightningBolt = (props: unknown) => {
  const { act, data } = useBackend<LightningBoltData>();
  const {
    x_coord,
    y_coord,
    z_coord,
    mode,
    damage,
    radius,
    delay,
    ckey,
    players,
    pointing,
  } = data;

  const [currentMode, setCurrentMode] = useSharedState('mode', mode);
  const [autoupdate, setAutoupdate] = useSharedState('autoupdate', true);

  // Собираем все режимы в объекты
  const modes = useMemo(() => {
    return [
      new PlayerMode(act, players, ckey),
      new CoordinateMode(
        act,
        { x: x_coord, y: y_coord, z: z_coord },
        autoupdate,
        setAutoupdate
      ),
      new PointerMode(act, !!pointing),
    ];
  }, [
    act,
    players,
    ckey,
    x_coord,
    y_coord,
    z_coord,
    autoupdate,
    setAutoupdate,
    pointing,
  ]);

  const modeNames = modes.map((m) => m.name);
  const ActiveMode = modes.find((m) => m.name === currentMode);

  return (
    <Window width={300} height={340} title="Вызов молнии">
      <Window.Content>
        <Section
          scrollable
          title="Настройка"
          buttons={
            <Dropdown
              width="150px"
              options={modeNames}
              selected={currentMode}
              onSelected={(val) => {
                setCurrentMode(val);
                act('set_mode', { mode: val });
                const inst = modes.find((m) => m.name === val);
                inst?.onSelect?.();
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

        <Section title={currentMode}>{ActiveMode?.render()}</Section>

        <Section>
          <Box textAlign="center">
            <Button
              icon="bolt"
              color="red"
              disabled={!currentMode || currentMode === 'По указателю'}
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
