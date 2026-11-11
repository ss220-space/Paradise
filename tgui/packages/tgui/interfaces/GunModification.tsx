import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Icon,
  Image,
  LabeledList,
  Modal,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

/** Must match the size of the gun image element below. */
const IMAGE_SCALE = 6;

type Module = {
  ref: string;
  name: string;
  desc?: string;
  icon?: string | null;
  icon_state?: string | null;
  can_detach?: boolean;
  slot?: string;
};

type Slot = {
  slot: string;
  name: string;
  class_name: string;
  x: number;
  y: number;
  installed: Module | null;
};

type GunStats = {
  min_spread: number;
  max_spread: number;
  base_min_spread: number;
  base_max_spread: number;
  head: number;
  base_head: number;
  chest: number;
  base_chest: number;
  arms: number;
  base_arms: number;
  legs: number;
  base_legs: number;
  hands: number;
  base_hands: number;
  feet: number;
  base_feet: number;
  other: number;
  base_other: number;
  caliber: string | null;
  firemodes: string[];
  damage_mod: number;
  stamina_mod: number;
  recoil: number | null;
  base_recoil: number | null;
  rpm: number | null;
};

type Data = {
  hasGun: boolean;
  gunIcon: string | null;
  imageWidth: number;
  imageHeight: number;
  gunOriginX: number;
  gunOriginY: number;
  gunName: string;
  slots: Slot[];
  availableModules: Module[];
  stats: GunStats | null;
};

export const GunModification = (_props: unknown) => {
  const { act, data } = useBackend<Data>();
  const {
    hasGun,
    gunIcon,
    imageWidth = 96,
    imageHeight = 96,
    gunOriginX = 32,
    gunOriginY = 32,
    gunName,
    slots = [],
    availableModules = [],
    stats,
  } = data;

  const [selectedSlot, setSelectedSlot] = useState<string | null>(null);
  const [detachSlot, setDetachSlot] = useState<string | null>(null);
  const [hoveredSlot, setHoveredSlot] = useState<string | null>(null);

  const selected = slots.find((slot) => slot.slot === selectedSlot);
  const detaching = slots.find((slot) => slot.slot === detachSlot);
  const modulesForSelected = selected
    ? availableModules.filter((module) => module.slot === selected.slot)
    : [];

  const handleSlotClick = (slot: Slot) => {
    if (slot.installed) {
      setDetachSlot(slot.slot);
    } else {
      setSelectedSlot(slot.slot);
    }
  };

  return (
    <Window width={900} height={600} title="Модификация оружия">
      <Window.Content scrollable>
        {!hasGun ? (
          <NoticeBox danger textAlign="center">
            Не удалось получить данные об оружии.
          </NoticeBox>
        ) : (
          <Stack fill>
            <Stack.Item>
              <Section title={gunName} fill textAlign="center">
                <Stack fill vertical align="center" justify="center">
                  <Stack.Item>
                    <Box
                      style={{
                        position: 'relative',
                        width: `${imageWidth * IMAGE_SCALE}px`,
                        height: `${imageHeight * IMAGE_SCALE}px`,
                        backgroundColor: 'rgba(255, 255, 255, 0.12)',
                        border: '1px solid rgba(255, 255, 255, 0.25)',
                        borderRadius: '4px',
                      }}
                    >
                  {!!gunIcon && (
                    <Image
                      src={gunIcon}
                      width={`${imageWidth * IMAGE_SCALE}px`}
                      height={`${imageHeight * IMAGE_SCALE}px`}
                      style={{
                        display: 'block',
                        imageRendering: 'pixelated',
                      }}
                    />
                  )}
                  {slots.map((slot) => {
                    const dotX = Math.max(
                      12,
                      Math.min(
                        (gunOriginX + slot.x) * IMAGE_SCALE,
                        imageWidth * IMAGE_SCALE - 12,
                      ),
                    );
                    const dotY = Math.max(
                      12,
                      Math.min(
                        (imageHeight - gunOriginY - slot.y) * IMAGE_SCALE,
                        imageHeight * IMAGE_SCALE - 12,
                      ),
                    );

                    return (
                      <Box
                        key={slot.slot}
                        onMouseEnter={() => setHoveredSlot(slot.slot)}
                        onMouseLeave={() => setHoveredSlot(null)}
                        style={{
                          position: 'absolute',
                          left: `${dotX}px`,
                          top: `${dotY}px`,
                          transform: 'translate(-50%, -50%)',
                          zIndex: 1,
                        }}
                      >
                        <Button
                          color={slot.installed ? 'blue' : 'green'}
                          tooltip={
                            slot.installed
                              ? `${slot.name}: ${slot.installed.name}`
                              : `${slot.name}: ${slot.class_name}`
                          }
                          tooltipPosition="top"
                          onClick={() => handleSlotClick(slot)}
                          style={{
                            width: '18px',
                            height: '18px',
                            minWidth: '18px',
                            minHeight: '18px',
                            padding: '0',
                            lineHeight: '0',
                            borderRadius: '50%',
                            border: '2px solid rgba(255, 255, 255, 0.85)',
                            boxShadow: '0 0 4px rgba(0, 0, 0, 0.8)',
                            opacity: hoveredSlot === slot.slot ? 1 : 0.25,
                            transition: 'opacity 0.15s',
                          }}
                        />
                      </Box>
                    );
                  })}
                    </Box>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
            <Stack.Item grow>
              <Stack vertical fill>
                <Stack.Item grow>
                  <Section title="Слоты" fill>
                    {slots.length > 0 ? (
                      <LabeledList>
                        {slots.map((slot) => (
                          <LabeledList.Item
                            key={slot.slot}
                            label={slot.name}
                            color={slot.installed ? 'blue' : 'green'}
                          >
                            <Button
                              fluid
                              color={slot.installed ? 'blue' : 'green'}
                              onClick={() => handleSlotClick(slot)}
                            >
                              <Stack align="center">
                                <Stack.Item>
                                  <SlotIcon module={slot.installed} />
                                </Stack.Item>
                                <Stack.Item grow>
                                  {slot.installed
                                    ? slot.installed.name
                                    : slot.class_name}
                                </Stack.Item>
                              </Stack>
                            </Button>
                          </LabeledList.Item>
                        ))}
                      </LabeledList>
                    ) : (
                      <NoticeBox info>
                        У этого оружия нет слотов для модулей.
                      </NoticeBox>
                    )}
                  </Section>
                </Stack.Item>
                {!!stats && (
                  <Stack.Item>
                    <Section title="Характеристики">
                      <Stack vertical>
                        <StatBar
                          label="Разброс"
                          value={`${stats.min_spread}–${stats.max_spread}`}
                          fill={spreadFill(stats.max_spread)}
                          baseFill={spreadFill(stats.base_max_spread)}
                          delta={makeDelta(
                            stats.max_spread - stats.base_max_spread,
                            false,
                          )}
                        />
                        <StatBar
                          label="Отдача"
                          value={formatRecoil(stats.recoil)}
                          fill={recoilFill(stats.recoil)}
                          baseFill={recoilFill(stats.base_recoil)}
                          delta={makeDelta(
                            (stats.recoil ?? 0) - (stats.base_recoil ?? 0),
                            false,
                            2,
                          )}
                        />
                        <StatBar
                          label="Скорострельность"
                          value={stats.rpm ? `${stats.rpm} выстр/мин` : '—'}
                          fill={clamp01((stats.rpm ?? 0) / 800)}
                        />
                        <StatBar
                          label="Физический урон"
                          value={formatModifier(stats.damage_mod)}
                          fill={clamp01(stats.damage_mod / DAMAGE_MAX)}
                        />
                        <StatBar
                          label="Стамина урон"
                          value={formatModifier(stats.stamina_mod)}
                          fill={clamp01(stats.stamina_mod / DAMAGE_MAX)}
                        />
                        <StatBar
                          label="Точность"
                          value={`${stats.chest}%`}
                          fill={clamp01(stats.chest / ACCURACY_MAX)}
                          baseFill={clamp01(stats.base_chest / ACCURACY_MAX)}
                          delta={makeDelta(
                            stats.chest - stats.base_chest,
                            true,
                            0,
                            '%',
                          )}
                        />
                        <Box mt={0.5}>
                          <Table>
                            <Table.Row>
                              <Table.Cell>Голова</Table.Cell>
                              <Table.Cell>
                                <AccuracyValue
                                  current={stats.head}
                                  base={stats.base_head}
                                />
                              </Table.Cell>
                              <Table.Cell>Торс</Table.Cell>
                              <Table.Cell>
                                <AccuracyValue
                                  current={stats.chest}
                                  base={stats.base_chest}
                                />
                              </Table.Cell>
                            </Table.Row>
                            <Table.Row>
                              <Table.Cell>Руки</Table.Cell>
                              <Table.Cell>
                                <AccuracyValue
                                  current={stats.arms}
                                  base={stats.base_arms}
                                />
                              </Table.Cell>
                              <Table.Cell>Ноги</Table.Cell>
                              <Table.Cell>
                                <AccuracyValue
                                  current={stats.legs}
                                  base={stats.base_legs}
                                />
                              </Table.Cell>
                            </Table.Row>
                            <Table.Row>
                              <Table.Cell>Кисти</Table.Cell>
                              <Table.Cell>
                                <AccuracyValue
                                  current={stats.hands}
                                  base={stats.base_hands}
                                />
                              </Table.Cell>
                              <Table.Cell>Стопы</Table.Cell>
                              <Table.Cell>
                                <AccuracyValue
                                  current={stats.feet}
                                  base={stats.base_feet}
                                />
                              </Table.Cell>
                            </Table.Row>
                            <Table.Row>
                              <Table.Cell>Прочее</Table.Cell>
                              <Table.Cell>
                                <AccuracyValue
                                  current={stats.other}
                                  base={stats.base_other}
                                />
                              </Table.Cell>
                            </Table.Row>
                          </Table>
                        </Box>
                        <Box mt={1}>
                          <LabeledList>
                            <LabeledList.Item label="Калибр">
                              {stats.caliber || '—'}
                            </LabeledList.Item>
                            <LabeledList.Item label="Режимы стрельбы">
                              {stats.firemodes?.length
                                ? stats.firemodes.join(', ')
                                : '—'}
                            </LabeledList.Item>
                          </LabeledList>
                        </Box>
                      </Stack>
                    </Section>
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
          </Stack>
        )}

        {!!selected && (
          <Modal maxWidth="440px" maxHeight="75%">
            <Section
              title={`Установка модуля: ${selected.name}`}
              buttons={
                <Button
                  icon="times"
                  onClick={() => setSelectedSlot(null)}
                />
              }
            >
              {modulesForSelected.length > 0 ? (
                <Box maxHeight="50vh" overflowY="auto">
                  <Stack vertical>
                    {modulesForSelected.map((module) => (
                      <Stack.Item key={module.ref}>
                        <Button
                          fluid
                          color="green"
                          tooltip={module.desc}
                          tooltipPosition="right"
                          onClick={() => {
                            act('install_module', {
                              slot: selected.slot,
                              module: module.ref,
                            });
                            setSelectedSlot(null);
                          }}
                        >
                          <Stack align="center">
                            <Stack.Item>
                              <SlotIcon module={module} />
                            </Stack.Item>
                            <Stack.Item grow>{module.name}</Stack.Item>
                          </Stack>
                        </Button>
                      </Stack.Item>
                    ))}
                  </Stack>
                </Box>
              ) : (
                <NoticeBox color="orange">
                  В вашем инвентаре нет подходящих модулей для этого слота.
                </NoticeBox>
              )}
            </Section>
          </Modal>
        )}

        {!!detaching?.installed && (
          <Modal maxWidth="400px">
            <Section
              title="Снятие модуля"
              buttons={
                <Button icon="times" onClick={() => setDetachSlot(null)} />
              }
            >
              <Stack vertical>
                <Stack.Item>
                  <Box>
                    Снять модуль «{detaching.installed.name}» с оружия?
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  {detaching.installed.can_detach ? (
                    <Stack>
                      <Stack.Item>
                        <Button
                          color="bad"
                          icon="check"
                          onClick={() => {
                            act('detach_module', {
                              slot: detaching.slot,
                            });
                            setDetachSlot(null);
                          }}
                        >
                          Снять
                        </Button>
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="times"
                          onClick={() => setDetachSlot(null)}
                        >
                          Отмена
                        </Button>
                      </Stack.Item>
                    </Stack>
                  ) : (
                    <NoticeBox danger>
                      Этот модуль нельзя снять обычным способом.
                    </NoticeBox>
                  )}
                </Stack.Item>
              </Stack>
            </Section>
          </Modal>
        )}
      </Window.Content>
    </Window>
  );
};

const SPREAD_MAX = 40;
const RECOIL_MAX = 2;
const ACCURACY_MAX = 150;
const DAMAGE_MAX = 2;

const clamp01 = (value: number) => Math.min(1, Math.max(0, value));

const spreadFill = (value: number) => clamp01(1 - value / SPREAD_MAX);

const recoilFill = (value: number | null) =>
  value === null ? 1 : clamp01(1 - value / RECOIL_MAX);

type StatDelta = {
  text: string;
  positive: boolean;
} | null;

const makeDelta = (
  value: number,
  higherIsBetter: boolean,
  digits = 0,
  suffix = '',
): StatDelta => {
  if (Math.abs(value) < 0.001) {
    return null;
  }
  const sign = value > 0 ? '+' : '';
  const text =
    digits > 0 ? value.toFixed(digits) : `${Math.round(value)}`;
  return {
    text: `${sign}${text}${suffix}`,
    positive: higherIsBetter ? value > 0 : value < 0,
  };
};

const AccuracyValue = (props: { current: number; base: number }) => {
  const color =
    props.current > props.base
      ? 'good'
      : props.current < props.base
        ? 'bad'
        : undefined;
  return (
    <Box as="span" color={color}>
      {props.current}%
    </Box>
  );
};

const StatBar = (props: {
  label: string;
  value: string;
  fill: number;
  baseFill?: number;
  delta?: StatDelta;
}) => {
  const fill = clamp01(props.fill);
  const baseFill = clamp01(props.baseFill ?? fill);
  const deltaStart = Math.min(fill, baseFill);
  const deltaWidth = Math.abs(fill - baseFill);
  const deltaPositive = fill >= baseFill;

  return (
    <Box
      position="relative"
      height="20px"
      mb={0.5}
      backgroundColor="rgba(255, 255, 255, 0.08)"
      style={{ borderRadius: '2px', overflow: 'hidden' }}
    >
      <Box
        position="absolute"
        left="0"
        top="0"
        bottom="0"
        width={`${fill * 100}%`}
        backgroundColor="#3f7fbf"
      />
      {deltaWidth > 0.001 && (
        <Box
          position="absolute"
          left={`${deltaStart * 100}%`}
          top="0"
          bottom="0"
          width={`${deltaWidth * 100}%`}
          backgroundColor={deltaPositive ? '#4caf50' : '#d9534f'}
        />
      )}
      <Box position="absolute" left="0" right="0" top="0" bottom="0">
        <Stack
          align="center"
          justify="space-between"
          height="100%"
          px={1}
          style={{ textShadow: '0 0 2px rgba(0, 0, 0, 0.9)' }}
        >
          <Stack.Item bold color="white">
            {props.label}
          </Stack.Item>
          <Stack.Item>
            <Box as="span" color="white">
              {props.value}
            </Box>
            {!!props.delta && (
              <Box
                as="span"
                ml={1}
                bold
                color={props.delta.positive ? 'good' : 'bad'}
              >
                {props.delta.text}
              </Box>
            )}
          </Stack.Item>
        </Stack>
      </Box>
    </Box>
  );
};

const formatModifier = (value: number | null | undefined) => {
  if (value === null || value === undefined) {
    return '—';
  }
  return `${Math.round(value * 100)}%`;
};

const formatRecoil = (value: number | null) => {
  if (value === null || value === undefined) {
    return '—';
  }
  const label =
    value <= 0.1
      ? 'минимальная'
      : value <= 0.25
        ? 'низкая'
        : value <= 0.45
          ? 'средняя'
          : value <= 1
            ? 'высокая'
            : 'очень высокая';
  return `${label} (${value.toFixed(2)})`;
};

const SlotIcon = (props: { module: Module | null }) => {
  const { module } = props;

  if (!module?.icon || !module.icon_state) {
    return <Icon name={module ? 'box' : 'plus'} color="gray" />;
  }

  return (
    <DmIcon
      icon={module.icon}
      icon_state={module.icon_state}
      width="32px"
      height="32px"
      fallback={<Icon name="box" color="gray" />}
    />
  );
};
