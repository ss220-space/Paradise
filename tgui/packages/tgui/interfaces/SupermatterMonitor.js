import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Section, Box, Button, Table, LabeledList, ProgressBar } from '../components';
import { Window } from '../layouts';
import { TableRow, TableCell } from '../components/Table';

export const SupermatterMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  if (data.active === 0) {
    return <SupermatterMonitorListView />;
  } else {
    return <SupermatterMonitorDataView />;
  }
};

const powerToColor = power => {
  if (power > 300) {
    return 'bad';
  } else if (power > 150) {
    return 'average';
  } else {
    return 'good';
  }
};

const temperatureToColor = temp => {
  if (temp > 5000) {
    return 'bad';
  } else if (temp > 4000) {
    return 'average';
  } else {
    return 'good';
  }
};

const pressureToColor = pressure => {
  if (pressure > 10000) {
    return 'bad';
  } else if (pressure > 5000) {
    return 'average';
  } else {
    return 'good';
  }
};

const SupermatterMonitorListView = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window>
      <Window.Content scrollable>
        <Section title="Обнаруженные осколки Суперматерии" buttons={
          <Button
            icon="sync"
            content="Обновить"
            onClick={() => act("refresh")}
          />
        }>
          <Box m={1}>
            {data.supermatters.length === 0 ? (
              <h3>Осколки не обнаружены</h3>
            ) : (
              <Table>
                <Table.Row header>
                  <TableCell>Область</TableCell>
                  <TableCell>Целостность</TableCell>
                  <TableCell>Детали</TableCell>
                </Table.Row>
                {data.supermatters.map(sm => (
                  <TableRow key={sm}>
                    <TableCell>{sm.area_name}</TableCell>
                    <TableCell>{sm.integrity}%</TableCell>
                    <TableCell>
                      <Button
                        icon="sign-in-alt"
                        content="Вид"
                        onClick={() => act('view', {
                          view: sm.uid,
                        })}
                      />
                    </TableCell>
                  </TableRow>
                ))}
              </Table>
            )}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

const SupermatterMonitorDataView = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window>
      <Window.Content>
        <Section title="Статус кристалла" buttons={
          <Button
            icon="caret-square-left"
            content="Назад"
            onClick={() => act("back")}
          />
        }>
          <LabeledList>
            <LabeledList.Item label="Целостность ядра">
              <ProgressBar
                ranges={{
                  good: [95, Infinity],
                  average: [80, 94],
                  bad: [-Infinity, 79],
                }}
                minValue="0"
                maxValue="100"
                value={data.SM_integrity}>
                {data.SM_integrity}%
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Относительный КЭЭ">
              <Box color={powerToColor(data.SM_power)}>
                {data.SM_power} <abbr title="Мегаэлектронвольт на кубический сантиметр">МэВ/см³</abbr>
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Температура">
              <Box color={temperatureToColor(data.SM_ambienttemp)}>
                {data.SM_ambienttemp} °K
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Давление">
              <Box color={pressureToColor(data.SM_ambientpressure)}>
                {data.SM_ambientpressure} кПа
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Газовый состав">
          <LabeledList>
            <LabeledList.Item label="Кислород">
              {data.SM_gas_O2}%
            </LabeledList.Item>
            <LabeledList.Item label="Оксид углерода">
              {data.SM_gas_CO2}%
            </LabeledList.Item>
            <LabeledList.Item label="Азот">
              {data.SM_gas_N2}%
            </LabeledList.Item>
            <LabeledList.Item label="Плазма">
              {data.SM_gas_PL}%
            </LabeledList.Item>
            <LabeledList.Item label="Прочее">
              {data.SM_gas_OTHER}%
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
