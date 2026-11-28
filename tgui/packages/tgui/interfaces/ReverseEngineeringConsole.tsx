import {
  Box,
  Button,
  DmIcon,
  NoticeBox,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Branch = {
  id: string;
  name: string;
  /** Points that can be spent. */
  points: number;
  /** The highest level found on a single destroyed item. */
  max_level: number;
  /** The most points that can be invested right now. */
  cap: number;
  /** Currently invested points. */
  allocated: number;
};

type Design = {
  id: string;
  name: string;
  desc: string;
  icon: string;
  icon_state: string;
};

type Data = {
  branches: Branch[];
  total_allocated: number;
  design: Design | null;
  match_count: number;
  match_index: number;
  busy: boolean;
  last_result: string | null;
};

export const ReverseEngineeringConsole = (_props) => {
  const { data } = useBackend<Data>();

  return (
    <Window width={640} height={640}>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <BranchesSection />
          </Stack.Item>
          <Stack.Item>
            <DesignSection />
          </Stack.Item>
          {!!data.last_result && (
            <Stack.Item>
              <NoticeBox info>Последний анализ — {data.last_result}</NoticeBox>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const BranchesSection = () => {
  const { act, data } = useBackend<Data>();
  const { branches, total_allocated } = data;

  return (
    <Section
      title="Ветки технологий"
      buttons={
        <>
          <Button
            icon="trash"
            tooltip="Уничтожить предмет, который находится в активной руке"
            onClick={() => act('destroy_held')}
          >
            Уничтожить предмет в руке
          </Button>
          <Button
            icon="undo"
            disabled={!total_allocated}
            onClick={() => act('reset_allocation')}
          >
            Сбросить
          </Button>
        </>
      }
    >
      <Box color="label" mb={1}>
        Поместите предмет в консоль, чтобы уничтожить его и получить очки.
        Вложить в ветку можно не больше очков, чем даёт лучший из уничтоженных
        предметов, и не больше, чем накоплено.
      </Box>
      <Stack vertical>
        {branches.map((branch) => (
          <Stack.Item key={branch.id}>
            <BranchRow branch={branch} />
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const BranchRow = (props: { branch: Branch }) => {
  const { act } = useBackend<Data>();
  const { branch } = props;
  const { id, name, points, max_level, cap, allocated } = branch;

  return (
    <Stack align="center">
      <Stack.Item basis="38%">
        <Box bold>{name}</Box>
        <Box color="label" fontSize="11px">
          Очки: {points} · Лучший предмет: {max_level}
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="minus"
          disabled={allocated <= 0}
          onClick={() => act('set_allocation', { id, value: allocated - 1 })}
        />
      </Stack.Item>
      <Stack.Item grow>
        {cap > 0 ? (
          <Slider
            value={allocated}
            minValue={0}
            maxValue={cap}
            step={1}
            stepPixelSize={20}
            onChange={(_e, value) =>
              act('set_allocation', { id, value: Math.round(value) })
            }
          />
        ) : (
          <Box color="grey" textAlign="center">
            нет данных
          </Box>
        )}
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="plus"
          disabled={allocated >= cap}
          onClick={() => act('set_allocation', { id, value: allocated + 1 })}
        />
      </Stack.Item>
      <Stack.Item basis="28px" textAlign="center" bold>
        {allocated}
      </Stack.Item>
    </Stack>
  );
};

const DesignSection = () => {
  const { act, data } = useBackend<Data>();
  const { design, match_count, match_index, busy, total_allocated } = data;

  if (!design) {
    return (
      <Section title="Шаблон печати">
        <Box color="label">
          {total_allocated
            ? 'Шаблонов с такими требованиями не найдено.'
            : 'Распределите очки по веткам технологий, чтобы найти шаблон.'}
        </Box>
      </Section>
    );
  }

  return (
    <Section
      title="Шаблон печати"
      buttons={
        match_count > 1 && (
          <>
            <Button
              icon="chevron-left"
              onClick={() => act('select_match', { direction: -1 })}
            />
            <Box inline mx={1}>
              {match_index} / {match_count}
            </Box>
            <Button
              icon="chevron-right"
              onClick={() => act('select_match', { direction: 1 })}
            />
          </>
        )
      }
    >
      <Stack align="center">
        <Stack.Item>
          <DmIcon
            icon={design.icon}
            icon_state={design.icon_state}
            style={{
              verticalAlign: 'middle',
              width: '64px',
              margin: '0px',
            }}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Box bold>{design.name}</Box>
          <Box color="label">{design.desc}</Box>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="save"
            color="good"
            disabled={busy}
            onClick={() => act('create_disk')}
          >
            {busy ? 'Запись...' : 'Создать дизайн'}
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
