import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { useBackend } from '../../backend';
import {
  AIDiplomacy,
  type AIRelation,
  type AIRelationOption,
} from './AIDiplomacy';

type Fleet = {
  id: string;
  name: string;
  faction: string;
  enemies: string[];
  friends: string[];
  relations: AIRelation[];
  sector: string;
  sector_id: string;
  size: number;
  min: number;
  max: number;
  alive: number;
  count: number;
  order: string;
};
type Target = { id: string; name: string; sector_id: string; fleet?: string };
type Point = { x: number; y: number };
type Data = {
  ai?: {
    fleets?: Fleet[];
    targets?: Target[];
    faction_options?: Record<string, string>;
    relation_options?: AIRelationOption[];
  };
};
const commands: Record<string, string> = {
  move: 'Двигаться к точке',
  attack: 'Атаковать цель',
  patrol: 'Патрулировать точки',
  suppress: 'Огонь на подавление',
  hold: 'Остановиться',
  auto: 'Отменить приказ · свободные действия',
};
const factions: Record<string, string> = {
  erw: 'Eisenwehr Raumfahrtwerke',
  neutral: 'Нейтральная',
  nt: 'Нанотрейзен',
  syndicate: 'Синдикат',
};

export const AIFleetOrders = () => {
  const { act, data } = useBackend<Data>();
  const fleets = data.ai?.fleets || [];
  const [fleetId, setFleetId] = useState('');
  const [command, setCommand] = useState('move');
  const [targetId, setTargetId] = useState('');
  const fleet = fleets.find((item) => item.id === fleetId) || fleets[0];
  const [points, setPoints] = useState<Point[]>([
    { x: (fleet?.size || 20) / 2, y: (fleet?.size || 20) / 2 },
  ]);
  const [size, setSize] = useState(40);
  const coordinateCommand = ['move', 'patrol', 'suppress'].includes(command);
  const visiblePoints = command === 'patrol' ? points : points.slice(0, 1);
  const targets = (data.ai?.targets || []).filter(
    (target) =>
      target.sector_id === fleet?.sector_id && target.fleet !== fleet?.id,
  );
  const valid =
    !!fleet?.alive &&
    (command !== 'attack' ||
      targets.some((target) => target.id === targetId)) &&
    (!coordinateCommand ||
      visiblePoints.every(
        (point) =>
          Number.isFinite(point.x) &&
          Number.isFinite(point.y) &&
          point.x >= fleet!.min &&
          point.x <= fleet!.max &&
          point.y >= fleet!.min &&
          point.y <= fleet!.max,
      ));
  return (
    <Section title="Приказы соединению">
      <LabeledList>
        <LabeledList.Item label="Соединение">
          <Dropdown
            fluid
            selected={fleet?.id}
            displayText={
              fleet
                ? `${fleet.name} · ${factions[fleet.faction]} · ${fleet.sector}`
                : undefined
            }
            placeholder="Соединения не созданы"
            options={fleets.map((item) => ({
              value: item.id,
              displayText: `${item.name} · ${factions[item.faction]} · ${item.sector}`,
            }))}
            onSelected={(id) => {
              setFleetId(id);
              setTargetId('');
              const selected = fleets.find((item) => item.id === id);
              if (selected)
                setPoints([{ x: selected.size / 2, y: selected.size / 2 }]);
            }}
          />
        </LabeledList.Item>
        {!!fleet && (
          <LabeledList.Item label="Дипломатия">
            <AIDiplomacy
              value={fleet}
              factions={data.ai?.faction_options || {}}
              contacts={data.ai?.relation_options || []}
              onChange={(value) =>
                act('ai_diplomacy', { fleet: fleet.id, ...value })
              }
            />
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Приказ">
          <Dropdown
            fluid
            selected={command}
            displayText={commands[command]}
            options={Object.entries(commands).map(([value, displayText]) => ({
              value,
              displayText,
            }))}
            onSelected={setCommand}
          />
        </LabeledList.Item>
        {!!fleet && (
          <LabeledList.Item label="Состояние">
            Живых: {fleet.alive}/{fleet.count} ·{' '}
            {commands[fleet.order] || 'Свободные действия'}
          </LabeledList.Item>
        )}
        {command === 'attack' && (
          <LabeledList.Item label="Цель">
            <Dropdown
              fluid
              selected={targetId}
              displayText={
                targets.find((target) => target.id === targetId)?.name
              }
              placeholder="Выберите корабль или станцию"
              options={targets.map((target) => ({
                value: target.id,
                displayText: target.name,
              }))}
              onSelected={setTargetId}
            />
          </LabeledList.Item>
        )}
      </LabeledList>
      {coordinateCommand &&
        visiblePoints.map((point, index) => (
          <Stack key={index} mt={1} align="center">
            <Stack.Item width="7em">
              {command === 'suppress' ? 'Центр квадрата' : `Точка ${index + 1}`}
            </Stack.Item>
            <Stack.Item>
              X{' '}
              <NumberInput
                value={point.x}
                minValue={fleet?.min || 1}
                maxValue={fleet?.max || 20}
                step={0.05}
                width="100px"
                onChange={(x) =>
                  setPoints((list) =>
                    list.map((item, i) =>
                      i === index ? { ...item, x } : item,
                    ),
                  )
                }
              />
            </Stack.Item>
            <Stack.Item>
              Y{' '}
              <NumberInput
                value={point.y}
                minValue={fleet?.min || 1}
                maxValue={fleet?.max || 20}
                step={0.05}
                width="100px"
                onChange={(y) =>
                  setPoints((list) =>
                    list.map((item, i) =>
                      i === index ? { ...item, y } : item,
                    ),
                  )
                }
              />
            </Stack.Item>
            {command === 'patrol' && (
              <Stack.Item>
                <Button
                  icon="trash"
                  disabled={points.length <= 1}
                  onClick={() =>
                    setPoints((list) => list.filter((_, i) => i !== index))
                  }
                >
                  Убрать точку
                </Button>
              </Stack.Item>
            )}
          </Stack>
        ))}
      {command === 'patrol' && (
        <Button
          mt={1}
          icon="plus"
          disabled={points.length >= 16}
          onClick={() =>
            setPoints((list) => [...list, { ...list[list.length - 1] }])
          }
        >
          Добавить точку
        </Button>
      )}
      {command === 'suppress' && (
        <Box mt={1}>
          Сторона квадрата, м:{' '}
          <NumberInput
            value={size}
            minValue={5}
            maxValue={500}
            step={5}
            onChange={setSize}
          />
        </Box>
      )}
      {command === 'patrol' && (
        <Box color="label">
          Точки обходятся по кругу. После боя корабли возвращаются на маршрут.
        </Box>
      )}
      {command === 'attack' && (
        <Box color="label">
          Указанная цель имеет приоритет над фракцией транспондера. Потеряв
          контакт, корабли ищут её у последней известной позиции.
        </Box>
      )}
      {command === 'suppress' && (
        <Box color="label">
          Корабли занимают огневые позиции и выбирают случайную точку квадрата
          для каждого выстрела.
        </Box>
      )}
      <Button
        mt={1}
        icon="flag"
        disabled={!valid}
        onClick={() =>
          act('ai_order', {
            fleet: fleet?.id,
            command,
            target: targetId,
            points: coordinateCommand ? visiblePoints : [],
            size,
          })
        }
      >
        Передать приказ
      </Button>
    </Section>
  );
};
