/**
 * Карта состояния раненого для режима Mountain Wars.
 *
 * Кукла тела с подсветкой по повреждениям: чем сильнее разбита конечность, тем
 * краснее. Клик выбирает зону прицела, кнопка применяет к ней предмет из руки —
 * лечением занимается сервер, здесь только выбор.
 */
import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type Limb = {
  zone: string;
  name?: string;
  missing?: boolean;
  brute?: number;
  burn?: number;
  max_damage?: number;
  bleeding?: number;
  arterial?: boolean;
  internal?: boolean;
  fracture?: boolean;
  splinted?: boolean;
  tourniquet?: boolean;
  embedded?: number;
  infected?: boolean;
  robotic?: boolean;
};

type ChartData = {
  patient: string;
  dead: boolean;
  unconscious: boolean;
  health: number;
  max_health: number;
  pulse: string;
  blood_percent: number;
  oxy: number;
  tox: number;
  selected: string;
  held_item: string | null;
  helping: boolean;
  limbs: Limb[];
};

/**
 * Куда на кукле садится каждая зона. Координаты в системе viewBox ниже.
 *
 * Кукла стоит лицом к смотрящему, поэтому правые конечности сидят слева на экране —
 * как на панели прицела в игре (см. get_zone_at() в screen_objects.dm: там правая рука
 * тоже в левой половине иконки). Иначе окно и панель показывают разные стороны.
 */
const SHAPES: Record<
  string,
  { x: number; y: number; w: number; h: number; r: number }
> = {
  head: { x: 38, y: 4, w: 24, h: 26, r: 11 },
  chest: { x: 32, y: 33, w: 36, h: 48, r: 8 },
  groin: { x: 35, y: 82, w: 30, h: 22, r: 7 },
  r_arm: { x: 15, y: 35, w: 14, h: 46, r: 7 },
  l_arm: { x: 71, y: 35, w: 14, h: 46, r: 7 },
  r_hand: { x: 15, y: 83, w: 14, h: 16, r: 7 },
  l_hand: { x: 71, y: 83, w: 14, h: 16, r: 7 },
  r_leg: { x: 34, y: 106, w: 15, h: 52, r: 7 },
  l_leg: { x: 51, y: 106, w: 15, h: 52, r: 7 },
  r_foot: { x: 34, y: 160, w: 15, h: 16, r: 6 },
  l_foot: { x: 51, y: 160, w: 15, h: 16, r: 6 },
};

/** Целая конечность жёлтая, разбитая красная, между ними плавный переход. */
const limbColor = (limb: Limb): string => {
  if (limb.missing) {
    return '#2b2b2b';
  }
  if (limb.robotic) {
    return '#7c8a99';
  }
  const max = limb.max_damage || 100;
  const hurt = Math.min(1, ((limb.brute || 0) + (limb.burn || 0)) / max);
  const from = [214, 176, 74];
  const to = [198, 42, 34];
  const mix = from.map((channel, i) =>
    Math.round(channel + (to[i] - channel) * hurt)
  );
  return `rgb(${mix[0]}, ${mix[1]}, ${mix[2]})`;
};

/** Метки поверх куклы: кровь, перелом, шина, жгут, осколки. */
const limbMarks = (limb: Limb): string[] => {
  const marks: string[] = [];
  if (limb.arterial) {
    marks.push('АРТЕРИЯ');
  } else if (limb.bleeding) {
    marks.push('кровь');
  }
  if (limb.internal) {
    marks.push('внутреннее');
  }
  if (limb.fracture) {
    marks.push('перелом');
  }
  if (limb.splinted) {
    marks.push('шина');
  }
  if (limb.tourniquet) {
    marks.push('жгут');
  }
  if (limb.embedded) {
    marks.push(`осколки: ${limb.embedded}`);
  }
  if (limb.infected) {
    marks.push('заражение');
  }
  return marks;
};

const BodyDoll = (props: unknown) => {
  const { act, data } = useBackend<ChartData>();
  const { limbs, selected } = data;
  return (
    <svg viewBox="0 0 100 180" style={{ width: '100%', height: '100%' }}>
      {limbs.map((limb) => {
        const shape = SHAPES[limb.zone];
        if (!shape) {
          return null;
        }
        const chosen = limb.zone === selected;
        return (
          <g
            key={limb.zone}
            onClick={() => act('select', { zone: limb.zone })}
            style={{ cursor: 'pointer' }}
          >
            <rect
              x={shape.x}
              y={shape.y}
              width={shape.w}
              height={shape.h}
              rx={shape.r}
              ry={shape.r}
              fill={limbColor(limb)}
              stroke={chosen ? '#ffffff' : '#101010'}
              strokeWidth={chosen ? 2 : 1}
              strokeDasharray={limb.missing ? '3 2' : undefined}
            />
            {!!limb.arterial && (
              <circle
                cx={shape.x + shape.w / 2}
                cy={shape.y + shape.h / 2}
                r={3}
                fill="#ff2b2b"
              />
            )}
          </g>
        );
      })}
    </svg>
  );
};

const Vitals = (props: unknown) => {
  const { data } = useBackend<ChartData>();
  const {
    dead,
    unconscious,
    health,
    max_health,
    pulse,
    blood_percent,
    oxy,
    tox,
  } = data;
  return (
    <LabeledList>
      <LabeledList.Item label="Состояние">
        {dead ? (
          <Box color="bad">Мёртв</Box>
        ) : unconscious ? (
          <Box color="average">Без сознания</Box>
        ) : (
          <Box color="good">В сознании</Box>
        )}
      </LabeledList.Item>
      <LabeledList.Item label="Здоровье">
        <ProgressBar
          value={health}
          minValue={-100}
          maxValue={max_health}
          ranges={{
            good: [max_health * 0.5, max_health],
            average: [0, max_health * 0.5],
            bad: [-100, 0],
          }}
        >
          {health}
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label="Пульс">{pulse}</LabeledList.Item>
      <LabeledList.Item label="Кровь">
        <ProgressBar
          value={blood_percent}
          minValue={0}
          maxValue={100}
          ranges={{ good: [85, 100], average: [70, 85], bad: [0, 70] }}
        >
          {blood_percent}%
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label="Удушье">{oxy}</LabeledList.Item>
      <LabeledList.Item label="Токсины">{tox}</LabeledList.Item>
    </LabeledList>
  );
};

const LimbDetails = (props: unknown) => {
  const { act, data } = useBackend<ChartData>();
  const { limbs, selected, held_item, helping } = data;
  const limb = limbs.find((entry) => entry.zone === selected);
  if (!limb) {
    return <Box color="label">Выберите часть тела на кукле.</Box>;
  }
  if (limb.missing) {
    return <Box color="bad">Конечность оторвана.</Box>;
  }
  const marks = limbMarks(limb);
  return (
    <Stack vertical>
      <Stack.Item>
        <LabeledList>
          <LabeledList.Item label="Ушибы">{limb.brute}</LabeledList.Item>
          <LabeledList.Item label="Ожоги">{limb.burn}</LabeledList.Item>
          <LabeledList.Item label="Кровотечение">
            {limb.bleeding
              ? `${Math.round((limb.bleeding || 0) * 100)}%`
              : 'нет'}
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      <Stack.Item>
        {marks.length ? (
          <Box color="bad">{marks.join(', ')}</Box>
        ) : (
          <Box color="label">Осложнений не видно.</Box>
        )}
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          icon="briefcase-medical"
          disabled={!held_item}
          color={helping ? 'good' : 'average'}
          onClick={() => act('treat', { zone: limb.zone })}
        >
          {held_item ? `Применить: ${held_item}` : 'В руке ничего нет'}
        </Button>
      </Stack.Item>
      {!helping && !!held_item && (
        <Stack.Item>
          <Box color="average">
            Намерение не на помощь — так выйдет не лечение.
          </Box>
        </Stack.Item>
      )}
    </Stack>
  );
};

export const MwBodyChart = (props: unknown) => {
  const { data } = useBackend<ChartData>();
  const { patient } = data;
  return (
    <Window width={560} height={430}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow>
            <Section fill title={patient}>
              <BodyDoll />
            </Section>
          </Stack.Item>
          <Stack.Item width="300px">
            <Stack fill vertical>
              <Stack.Item>
                <Section title="Показатели">
                  <Vitals />
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section fill title="Осмотр">
                  <LimbDetails />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
