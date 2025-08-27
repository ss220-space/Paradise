import { useBackend } from '../backend';
import {
  Section,
  Box,
  Button,
  Table,
  LabeledList,
  ProgressBar,
} from '../components';
import { Window } from '../layouts';

type SupermatterMonitorData = {
  active: boolean;
  supermatters: Supermatter[];
  SM_integrity: number;
  SM_power: number;
  SM_ambienttemp: number;
  SM_ambientpressure: number;
  SM_gas_O2: number;
  SM_gas_CO2: number;
  SM_gas_N2: number;
  SM_gas_PL: number;
  SM_gas_OTHER: number;
};

type Supermatter = {
  area_name: string;
  uid: string;
  integrity: number;
};

export const SupermatterMonitor = (_props: unknown) => {
  const { data } = useBackend<SupermatterMonitorData>();
  if (!data.active) {
    return <SupermatterMonitorListView />;
  } else {
    return <SupermatterMonitorDataView />;
  }
};

const powerToColor = (power: number) => {
  if (power > 300) {
    return 'bad';
  } else if (power > 150) {
    return 'average';
  } else {
    return 'good';
  }
};

const temperatureToColor = (temp: number) => {
  if (temp > 5000) {
    return 'bad';
  } else if (temp > 4000) {
    return 'average';
  } else {
    return 'good';
  }
};

const pressureToColor = (pressure: number) => {
  if (pressure > 10000) {
    return 'bad';
  } else if (pressure > 5000) {
    return 'average';
  } else {
    return 'good';
  }
};

const SupermatterMonitorListView = (_props: unknown) => {
  const { act, data } = useBackend<SupermatterMonitorData>();
  return (
    <Window width={600} height={325}>
      <Window.Content scrollable>
        <Section
          title="Detected Supermatter Shards"
          buttons={
            <Button icon="sync" onClick={() => act('refresh')}>
              Refresh
            </Button>
          }
        >
          <Box m={1}>
            {data.supermatters.length === 0 ? (
              <h3>No shards detected</h3>
            ) : (
              <Table>
                <Table.Row header>
                  <Table.Cell>Area</Table.Cell>
                  <Table.Cell>Integrity</Table.Cell>
                  <Table.Cell>Details</Table.Cell>
                </Table.Row>
                {data.supermatters.map((sm) => (
                  <Table.Row key={sm.uid}>
                    <Table.Cell>{sm.area_name}</Table.Cell>
                    <Table.Cell>{sm.integrity}%</Table.Cell>
                    <Table.Cell>
                      <Button
                        icon="sign-in-alt"
                        onClick={() =>
                          act('view', {
                            view: sm.uid,
                          })
                        }
                      >
                        View
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            )}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

const SupermatterMonitorDataView = (_props: unknown) => {
  const { act, data } = useBackend<SupermatterMonitorData>();
  return (
    <Window width={600} height={325}>
      <Window.Content>
        <Section
          title="Crystal Status"
          buttons={
            <Button icon="caret-square-left" onClick={() => act('back')}>
              Back
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Core Integrity">
              <ProgressBar
                ranges={{
                  good: [95, Infinity],
                  average: [80, 94],
                  bad: [-Infinity, 79],
                }}
                minValue={0}
                maxValue={100}
                value={data.SM_integrity}
              >
                {data.SM_integrity}%
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Relative EER">
              <Box color={powerToColor(data.SM_power)}>
                {data.SM_power} MeV/cm3
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Temperature">
              <Box color={temperatureToColor(data.SM_ambienttemp)}>
                {data.SM_ambienttemp} K
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">
              <Box color={pressureToColor(data.SM_ambientpressure)}>
                {data.SM_ambientpressure} kPa
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Gas Composition">
          <LabeledList>
            <LabeledList.Item label="Oxygen">
              {data.SM_gas_O2}%
            </LabeledList.Item>
            <LabeledList.Item label="Carbon Dioxide">
              {data.SM_gas_CO2}%
            </LabeledList.Item>
            <LabeledList.Item label="Nitrogen">
              {data.SM_gas_N2}%
            </LabeledList.Item>
            <LabeledList.Item label="Plasma">
              {data.SM_gas_PL}%
            </LabeledList.Item>
            <LabeledList.Item label="Other">
              {data.SM_gas_OTHER}%
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
