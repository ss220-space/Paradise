import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  ProgressBar,
  LabeledList,
  Section,
  Table,
} from '../components';
import { Window } from '../layouts';

export const LaborClaimConsole = (props: unknown) => {
  return (
    <Window width={320} height={470}>
      <Window.Content scrollable>
        <ShuttleControlSection />
        <MaterialValuesSection />
      </Window.Content>
    </Window>
  );
};

type LaborClaimData = {
  can_go_home: boolean;
  emagged: boolean;
  id_inserted: boolean;
  id_name: string;
  id_points: number;
  id_goal: number;
  unclaimed_points: number;
  ores: Ore[];
};

type Ore = {
  ore: string;
  value: number;
};

const ShuttleControlSection = (props: unknown) => {
  const { act, data } = useBackend<LaborClaimData>();
  const {
    can_go_home,
    emagged,
    id_inserted,
    id_name,
    id_points,
    id_goal,
    unclaimed_points,
  } = data;
  const bad_progress = emagged ? 0 : 1;
  const completionStatus = emagged
    ? 'ОШИБКА'
    : can_go_home
      ? 'Цель достигнута!'
      : 'Недостаточно';
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Статус">
          {(!!id_inserted && (
            <ProgressBar
              value={id_points / id_goal}
              ranges={{
                good: [bad_progress, Infinity],
                bad: [-Infinity, bad_progress],
              }}
            >
              {id_points + ' / ' + id_goal + ' ' + completionStatus}
            </ProgressBar>
          )) ||
            (!!emagged && 'ОШИБКА ЦЕЛЬ ДОСТИНГУТА?!@') ||
            'Не вставлена ID-карта'}
        </LabeledList.Item>
        <LabeledList.Item label="Управление шаттлом">
          <Button
            fluid
            disabled={!can_go_home}
            onClick={() => act('move_shuttle')}
          >
            Переместить шаттл
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Несобранные очки">
          <Button
            fluid
            disabled={!id_inserted || !unclaimed_points}
            onClick={() => act('claim_points')}
          >
            {'Получить очки (' + unclaimed_points + ')'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Вставленная ID-карта">
          <Button fluid onClick={() => act('handle_id')}>
            {id_inserted ? id_name : '-------------'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const MaterialValuesSection = (props: unknown) => {
  const { data } = useBackend<LaborClaimData>();
  const { ores } = data;
  return (
    <Section title="Ценность минералов (в очках)">
      <Table>
        <Table.Row header>
          <Table.Cell>Минерал</Table.Cell>
          <Table.Cell collapsing textAlign="right">
            Ценность
          </Table.Cell>
        </Table.Row>
        {ores.map((ore) => (
          <Table.Row key={ore.ore}>
            <Table.Cell>{toTitleCase(ore.ore)}</Table.Cell>
            <Table.Cell collapsing textAlign="right">
              <Box color="label" inline>
                {ore.value}
              </Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
