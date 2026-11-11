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
};
type Draft = {
  key: number;
  role: string;
  name: string;
  template: string;
  unarmed: boolean;
};
type Data = {
  ai: {
    enemy_options: Record<string, string>;
    default_enemies: Record<string, string[]>;
    ships: Ship[];
    uploads: Template[];
    limit: number;
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
  syndicate: 'Синдикат',
  nt: 'Нанотрейзен',
  rogue: 'Агрессивные автоматы',
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
  const [enemyDrafts, setEnemyDrafts] = useState<Record<string, string[]>>({});
  const enemies =
    enemyDrafts[faction] ?? data.ai?.default_enemies?.[faction] ?? [];
  const [group, setGroup] = useState('');
  const [x, setX] = useState(data.suggest_x || 10);
  const [y, setY] = useState(data.suggest_y || 10);
  const [search, setSearch] = useState('');
  const [draft, setDraft] = useState<Draft[]>([
    { key: 0, role: 'medium', name: '', template: '', unarmed: false },
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
      item.width <= 64 &&
      item.height <= 64,
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
          <LabeledList.Item label="Атаковать при обнаружении">
            {Object.entries(data.ai?.enemy_options || {}).map(([id, label]) => (
              <Button.Checkbox
                key={id}
                checked={enemies.includes(id)}
                onClick={() =>
                  setEnemyDrafts({
                    ...enemyDrafts,
                    [faction]: enemies.includes(id)
                      ? enemies.filter((enemy) => enemy !== id)
                      : [...enemies, id],
                  })
                }
              >
                {label}
              </Button.Checkbox>
            ))}
            <Box color="label">
              Пустой список отключает автоматический выбор врагов. При
              пополнении соединения настройки применятся ко всему его составу.
            </Box>
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
              <LabeledList.Item label="Название">
                <Input
                  fluid
                  value={row.name}
                  placeholder="По роли корабля"
                  onChange={(name) => update(row.key, { name })}
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
                  onSelected={(template) => update(row.key, { template })}
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
          disabled={draft.length >= 32}
          onClick={() =>
            setDraft((rows) => [
              ...rows,
              {
                key: nextKey.current++,
                role: 'medium',
                name: '',
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
          disabled={
            !sector ||
            !valid ||
            ships.length + draft.length > (data.ai?.limit || 32)
          }
          onClick={() =>
            act('ai_spawn', {
              faction,
              enemies,
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
        <Box mt={1} color="label">
          Карты до 64×64, оружие необязательно. Безоружные корабли отступают от
          врага. Уничтожение — потеря 35% клеток корпуса. Чтобы пополнить
          существующее соединение, укажите его название и фракцию.
        </Box>
      </Section>
      <Section title={`ИИ-корабли · ${ships.length}/${data.ai?.limit || 32}`}>
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
