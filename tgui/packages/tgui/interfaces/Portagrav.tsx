import {
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type PortagravData = {
  on: BooleanLike;
  open: BooleanLike;
  anchored: BooleanLike;
  wireMode: BooleanLike;
  hasPowercell: BooleanLike;
  powerLevel: number;
  level: number;
  maxLevel: number;
  range: number;
  gravity: number;
  maxGravity: number;
  draw: string;
};

export const Portagrav = () => {
  const { act, data } = useBackend<PortagravData>();
  const {
    on,
    open,
    anchored,
    wireMode,
    hasPowercell,
    powerLevel,
    level,
    maxLevel,
    range,
    gravity,
    maxGravity,
    draw,
  } = data;

  return (
    <Window width={400} height={340}>
      <Window.Content>
        {!anchored && (
          <NoticeBox>Закрепите генератор гаечным ключом.</NoticeBox>
        )}
        <Section
          title="Питание"
          buttons={
            <>
              <Button
                icon="eject"
                disabled={!hasPowercell || !open}
                onClick={() => act('eject')}
              >
                Извлечь батарею
              </Button>
              <Button
                icon={on ? 'power-off' : 'times'}
                selected={on}
                disabled={!anchored}
                onClick={() => act('power')}
              >
                {on ? 'Включён' : 'Выключен'}
              </Button>
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Источник">
              <Button
                icon="plug"
                selected={wireMode}
                onClick={() => act('wire_mode')}
              >
                {wireMode ? 'Силовой кабель' : 'Батарея'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item
              label="Батарея"
              color={!hasPowercell ? 'bad' : ''}
            >
              {(!!hasPowercell && (
                <ProgressBar
                  value={powerLevel / 100}
                  ranges={{
                    good: [0.6, Infinity],
                    average: [0.3, 0.6],
                    bad: [-Infinity, 0.3],
                  }}
                />
              )) ||
                'Отсутствует'}
            </LabeledList.Item>
            <LabeledList.Item label="Потребление">{draw}</LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Поле">
          <LabeledList>
            <LabeledList.Item
              label="Мощность"
              buttons={
                <>
                  <Button
                    icon="minus"
                    disabled={level <= 1}
                    onClick={() => act('adjust_level', { adjustment: -1 })}
                  />
                  <Button
                    icon="plus"
                    disabled={level >= maxLevel}
                    onClick={() => act('adjust_level', { adjustment: 1 })}
                  />
                </>
              }
            >
              {level} / {maxLevel} ({range} тайлов)
            </LabeledList.Item>
            <LabeledList.Item
              label="Гравитация"
              buttons={
                <>
                  <Button
                    icon="minus"
                    disabled={gravity <= 0}
                    onClick={() => act('adjust_gravity', { adjustment: -1 })}
                  />
                  <Button
                    icon="plus"
                    disabled={gravity >= maxGravity}
                    onClick={() => act('adjust_gravity', { adjustment: 1 })}
                  />
                </>
              }
            >
              {gravity} G
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
