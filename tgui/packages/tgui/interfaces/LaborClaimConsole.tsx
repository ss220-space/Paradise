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
    ? 'ERR0R'
    : can_go_home
      ? 'Completed!'
      : 'Insufficient';
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Status">
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
            (!!emagged && 'ERR0R COMPLETED?!@') ||
            'No ID inserted'}
        </LabeledList.Item>
        <LabeledList.Item label="Shuttle controls">
          <Button
            fluid
            disabled={!can_go_home}
            onClick={() => act('move_shuttle')}
          >
            Move shuttle
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Unclaimed points">
          <Button
            fluid
            disabled={!id_inserted || !unclaimed_points}
            onClick={() => act('claim_points')}
          >
            {'Claim points (' + unclaimed_points + ')'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Inserted ID">
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
    <Section title="Material values">
      <Table>
        <Table.Row header>
          <Table.Cell>Material</Table.Cell>
          <Table.Cell collapsing textAlign="right">
            Value
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
