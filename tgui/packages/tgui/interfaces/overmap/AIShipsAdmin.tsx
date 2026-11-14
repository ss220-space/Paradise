import { useRef, useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../../backend';
import {
  AIDiplomacy,
  type AIDiplomacyValue,
  type AIRelationOption,
} from './AIDiplomacy';
import { AIFleetOrders } from './AIFleetOrders';

type Ship = {
  id: string;
  name: string;
  role: string;
  tactic: string;
  faction: string;
  group: string;
  sector: string;
  x: number;
  y: number;
  enabled: BooleanLike;
  ready: BooleanLike;
  destroyed: BooleanLike;
  hull_loss: number;
  state: string;
  target?: string;
};
type Sector = { id: string; name: string; size: number };
type Template = {
  id: string;
  kind: string;
  name: string;
  width: number;
  height: number;
  ai_role?: string;
  faction?: string;
};
type Draft = {
  ship_class: string;
  key: number;
  role: string;
  name: string;
  template: string;
  unarmed: boolean;
};
type Data = {
  ai: {
    name_template: string;
    ship_classes: Record<string, string>;
    faction_options: Record<string, string>;
    relation_options: AIRelationOption[];
    default_enemies: Record<string, string[]>;
    ships: Ship[];
    uploads: Template[];
    feedback?: string;
    failed?: BooleanLike;
  };
  sectors: Sector[] | Record<string, Sector>;
  templates: Template[] | Record<string, Template>;
  suggest_sector?: string;
  suggest_x?: number;
  suggest_y?: number;
};
const asList = <T,>(value: T[] | Record<string, T> | undefined): T[] =>
  Array.isArray(value) ? value : Object.values(value || {});
const roles: Record<string, string> = {
  light: 'Лёгкий',
  medium: 'Средний',
  heavy: 'Тяжёлый',
  support: 'Поддержка',
  flagship: 'Флагман',
};
const factions: Record<string, string> = {
  erw: 'Eisenwehr Raumfahrtwerke',
  neutral: 'Нейтральная',
  syndicate: 'Синдикат',
  nt: 'Нанотрейзен',
};
const states: Record<string, string> = {
  patrol: 'Патруль',
  orbit: 'Кружение',
  flank: 'Заход с борта',
  standoff: 'Дальний бой',
  search: 'Поиск',
  disabled: 'Нет тяги',
  stopped: 'Остановлен',
  flee: 'Отступление',
  destroyed: 'Уничтожен',
  move: 'Выполняет переход',
  patrol_order: 'Патруль по точкам',
  suppress: 'Огонь на подавление',
  order_complete: 'Приказ выполнен',
};
const roleOptions = Object.entries(roles).map(([value, displayText]) => ({
  value,
  displayText,
}));

export const AIShipsAdmin = () => {
  const { act, data } = useBackend<Data>();
  const sectors = asList(data.sectors);
  const [sectorId, setSectorId] = useState(
    data.suggest_sector || sectors[0]?.id || '',
  );
  const [faction, setFaction] = useState('syndicate');
  const [diplomacyDrafts, setDiplomacyDrafts] = useState<
    Record<string, AIDiplomacyValue>
  >({});
  const diplomacy = diplomacyDrafts[faction] ?? {
    enemies: data.ai?.default_enemies?.[faction] ?? [],
    friends: [...new Set([faction, 'neutral'])],
    relations: [],
  };
  const [group, setGroup] = useState('');
  const [radioSilence, setRadioSilence] = useState(false);
  const [nameTemplate, setNameTemplate] = useState(
    data.ai?.name_template || '$faction$-$class$-$id$ $shipname$',
  );
  const [x, setX] = useState(data.suggest_x || 10);
  const [y, setY] = useState(data.suggest_y || 10);
  const [search, setSearch] = useState('');
  const [draft, setDraft] = useState<Draft[]>([
    {
      key: 0,
      role: 'medium',
      ship_class: '',
      name: '',
      template: '',
      unarmed: false,
    },
  ]);
  const nextKey = useRef(1);
  const update = (key: number, change: Partial<Draft>) =>
    setDraft((rows) =>
      rows.map((row) => (row.key === key ? { ...row, ...change } : row)),
    );
  const templates = [
    ...(data.ai?.uploads || []),
    ...asList(data.templates),
  ].filter(
    (item) =>
      item.width > 0 &&
      item.height > 0 &&
      item.width <= 256 &&
      item.height <= 256,
  );
  const templateOptions = templates
    .filter((item) =>
      `${item.name} ${item.id}`.toLowerCase().includes(search.toLowerCase()),
    )
    .map((item) => ({
      value: `${item.kind}:${item.id}`,
      displayText: `${item.name} (${item.width}×${item.height})`,
    }));
  const ships = data.ai?.ships || [];
  const groups = [...new Set(ships.map((ship) => ship.group))];
  const sector = sectors.find((entry) => entry.id === sectorId) || sectors[0];
  const valid =
    draft.length > 0 &&
    draft.every(
      (row) =>
        !row.template ||
        templates.some((item) => `${item.kind}:${item.id}` === row.template),
    );
  return (
    <>
      {!!data.ai?.feedback && (
        <NoticeBox danger={!!data.ai.failed}>{data.ai.feedback}</NoticeBox>
      )}
      <AIFleetOrders />
      <Section title="Создать соединение">
        <LabeledList>
          <LabeledList.Item label="Название соединения">
            <Input
              fluid
              value={group}
              placeholder="Новое соединение автоматически"
              onChange={setGroup}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Радиообмен">
            <Button.Checkbox
              checked={radioSilence}
              onClick={() => setRadioSilence(!radioSilence)}
            >
              Радиомолчание
            </Button.Checkbox>
          </LabeledList.Item>
          <LabeledList.Item label="Шаблон имени">
            <Input fluid value={nameTemplate} onChange={setNameTemplate} />
            <Box color="label">{'$faction$ · $class$ · $id$ · $shipname$'}</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Фракция">
            <Dropdown
              fluid
              selected={faction}
              displayText={factions[faction]}
              options={Object.entries(factions).map(([value, displayText]) => ({
                value,
                displayText,
              }))}
              onSelected={setFaction}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Дипломатия">
            <AIDiplomacy
              value={diplomacy}
              factions={data.ai?.faction_options || {}}
              contacts={data.ai?.relation_options || []}
              onChange={(value) =>
                setDiplomacyDrafts({ ...diplomacyDrafts, [faction]: value })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item label="Сектор">
            <Dropdown
              fluid
              selected={sector?.id}
              displayText={sector?.name}
              options={sectors.map((entry) => ({
                value: entry.id,
                displayText: entry.name,
              }))}
              onSelected={setSectorId}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Положение">
            <Stack>
              <Stack.Item>
                X{' '}
                <NumberInput
                  width="90px"
                  value={x}
                  minValue={1}
                  maxValue={sector?.size || 20}
                  step={1}
                  onChange={setX}
                />
              </Stack.Item>
              <Stack.Item>
                Y{' '}
                <NumberInput
                  width="90px"
                  value={y}
                  minValue={1}
                  maxValue={sector?.size || 20}
                  step={1}
                  onChange={setY}
                />
              </Stack.Item>
            </Stack>
          </LabeledList.Item>
        </LabeledList>
        <Box mt={1}>
          <Input
            value={search}
            placeholder="Поиск карт для состава"
            onChange={setSearch}
          />
          <Button icon="upload" onClick={() => act('ai_upload')}>
            Добавить свою DMM
          </Button>
        </Box>
        {draft.map((row, index) => (
          <Section
            key={row.key}
            mt={1}
            title={`Корабль ${index + 1}`}
            buttons={
              <Button
                icon="trash"
                color="bad"
                onClick={() =>
                  setDraft((rows) =>
                    rows.filter((item) => item.key !== row.key),
                  )
                }
              >
                Убрать
              </Button>
            }
          >
            <LabeledList>
              <LabeledList.Item label="Имя корабля">
                <Input
                  fluid
                  value={row.name}
                  placeholder="Из зоны карты или шаблона"
                  onChange={(name) => update(row.key, { name })}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Класс в позывном">
                <Dropdown
                  fluid
                  selected={row.ship_class}
                  options={[
                    { value: '', displayText: 'Из карты или тактической роли' },
                    ...Object.entries(data.ai?.ship_classes || {}).map(
                      ([value, label]) => ({
                        value,
                        displayText: `${value} — ${label}`,
                      }),
                    ),
                  ]}
                  onSelected={(ship_class) => update(row.key, { ship_class })}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Роль">
                <Dropdown
                  fluid
                  selected={row.role}
                  displayText={roles[row.role]}
                  options={roleOptions}
                  onSelected={(role) => update(row.key, { role })}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Карта">
                <Dropdown
                  fluid
                  selected={row.template}
                  displayText={
                    row.template
                      ? templates.find(
                          (item) => `${item.kind}:${item.id}` === row.template,
                        )?.name
                      : 'Готовый корпус выбранной роли'
                  }
                  options={[
                    { value: '', displayText: 'Готовый корпус выбранной роли' },
                    ...templateOptions,
                  ]}
                  onSelected={(template) => {
                    const selected = templates.find(
                      (item) => `${item.kind}:${item.id}` === template,
                    );
                    update(row.key, {
                      template,
                      ...(selected?.ai_role ? { role: selected.ai_role } : {}),
                    });
                  }}
                />
              </LabeledList.Item>
              {!row.template && (
                <LabeledList.Item label="Вооружение">
                  <Button.Checkbox
                    checked={row.unarmed}
                    onClick={() => update(row.key, { unarmed: !row.unarmed })}
                  >
                    Создать без оружия
                  </Button.Checkbox>
                </LabeledList.Item>
              )}
            </LabeledList>
          </Section>
        ))}
        <Button
          mt={1}
          icon="plus"
          onClick={() =>
            setDraft((rows) => [
              ...rows,
              {
                key: nextKey.current++,
                role: 'medium',
                name: '',
                ship_class: '',
                template: '',
                unarmed: false,
              },
            ])
          }
        >
          Добавить корабль
        </Button>
        <Button
          mt={1}
          icon="space-shuttle"
          disabled={!sector || !valid}
          onClick={() =>
            act('ai_spawn', {
              faction,
              name_template: nameTemplate,
              radio_silence: radioSilence,
              ...diplomacy,
              group,
              sector: sector?.id,
              x,
              y,
              ships: draft.map((row) => {
                const template = templates.find(
                  (item) => `${item.kind}:${item.id}` === row.template,
                );
                return {
                  role: row.role,
                  name: row.name,
                  ship_class: row.ship_class,
                  unarmed: row.unarmed,
                  template_id: template?.id || '',
                  template_kind: template?.kind,
                };
              }),
            })
          }
        >
          Создать соединение · {draft.length}
        </Button>
      </Section>
      <Section title={`ИИ-корабли · ${ships.length}`}>
        {!ships.length && <Box color="label">Соединения не созданы.</Box>}
        {groups.map((fleet) => (
          <Section
            key={fleet}
            title={fleet}
            buttons={
              <Button
                icon="plus"
                onClick={() => {
                  const member = ships.find((ship) => ship.group === fleet);
                  setGroup(fleet);
                  if (member) setFaction(member.faction);
                }}
              >
                Пополнить
              </Button>
            }
          >
            {ships
              .filter((ship) => ship.group === fleet)
              .map((ship) => (
                <Section key={ship.id} title={ship.name}>
                  <Box>
                    {roles[ship.role]}
                    {ship.role === 'heavy' && ship.tactic === 'medium'
                      ? ' · тактика среднего'
                      : ''}{' '}
                    · {factions[ship.faction]}
                  </Box>
                  <Box
                    color={
                      ship.destroyed ? 'label' : ship.ready ? 'good' : 'average'
                    }
                  >
                    {states[ship.state] || ship.state} · корпус потерян на{' '}
                    {ship.hull_loss}% · {ship.sector} {ship.x}:{ship.y}
                  </Box>
                  {!!ship.target && <Box>Цель: {ship.target}</Box>}
                  <Box mt={0.5}>
                    <Button
                      icon="wrench"
                      onClick={() => act('ai_repair', { id: ship.id })}
                    >
                      Починить
                    </Button>
                    <Button
                      disabled={!!ship.destroyed}
                      icon={ship.enabled ? 'pause' : 'play'}
                      selected={ship.enabled}
                      onClick={() => act('ai_toggle', { id: ship.id })}
                    >
                      {ship.enabled ? 'Остановить ИИ' : 'Включить ИИ'}
                    </Button>
                    <Button
                      disabled={!!ship.destroyed}
                      icon="route"
                      onClick={() => act('ai_patrol_here', { id: ship.id })}
                    >
                      Патруль здесь
                    </Button>
                    <Button
                      disabled={!!ship.destroyed}
                      icon="gamepad"
                      onClick={() => act('ai_helm', { id: ship.id })}
                    >
                      Взять управление
                    </Button>
                    <Button
                      icon="trash"
                      color="bad"
                      onClick={() => act('ai_delete', { id: ship.id })}
                    >
                      Убрать корабль
                    </Button>
                  </Box>
                </Section>
              ))}
          </Section>
        ))}
      </Section>
    </>
  );
};
