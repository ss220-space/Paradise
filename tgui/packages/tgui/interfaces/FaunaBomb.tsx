import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Section,
  Stack,
  Table,
  AnimatedNumber,
  Icon,
  LabeledList,
  ProgressBar,
  NumberInput,
  Tabs,
} from '../components';
import { Window } from '../layouts';

const PickTab = (index) => {
  switch (index) {
    case 0:
      return <Commands />;
    case 1:
      return <Scans />;
    default:
      return 'SOMETHING WENT VERY WRONG PLEASE AHELP';
  }
};

type FaunaBombData = {
  charge: number;
  max_charge: number;
  charge_speed: number;
  created_len: number;
};

export const FaunaBomb = (props) => {
  const { act, data } = useBackend<FaunaBombData>();
  const { charge, max_charge, charge_speed, created_len } = data;
  const [tabIndex, setTabIndex] = useLocalState<number>('tabIndex', 0);
  return (
    <Window width={710} height={500} title="Меню управления проекциями">
      <Window.Content>
        <Box italic mt="5px">
          Заряд: {charge}/{max_charge} Скорость зарядки: {charge_speed}{' '}
          Проекций: {created_len}/12
        </Box>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                key="Commands"
                selected={tabIndex === 0}
                onClick={() => {
                  setTabIndex(0);
                }}
                icon="user"
              >
                Контроль
              </Tabs.Tab>
              <Tabs.Tab
                key="Scans"
                selected={tabIndex === 1}
                onClick={() => {
                  setTabIndex(1);
                }}
                icon="user"
              >
                Проецирование
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{PickTab(tabIndex)}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Commands = (_properties, context) => {
  const { act, data } = useBackend();

  return (
    <Stack vertical>
      <Stack.Item>
        <Button content="Атаковать" onClick={() => act('attack')} />
      </Stack.Item>
      <Stack.Item>
        <Button content="Следовать" onClick={() => act('go')} />
      </Stack.Item>
      <Stack.Item>
        <Button content="Прекратить" onClick={() => act('stop')} />
      </Stack.Item>
    </Stack>
  );
};

type ScansData = {
  scans;
  selected_scan_ind;
};

const Scans = (_properties) => {
  const { act, data } = useBackend<ScansData>();
  const { scans, selected_scan_ind } = data;
  const [scanIndex, setScanIndex] = useLocalState<number>('scanIndex', 0);

  return (
    <Stack fill vertical>
      <Stack fill mt={0.3}>
        <Stack.Item width="30%">
          <Section fill scrollable>
            <Tabs vertical>
              {scans.map((i) => (
                <Tabs.Tab
                  key={i}
                  selected={i.index - 1 === scanIndex}
                  onClick={() => {
                    setScanIndex(i.index - 1);
                  }}
                >
                  {i.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          {scans.length ? (
            <Stack vertical>
              <Stack.Item>
                {
                  <img
                    src={`data:image/jpeg;base64,${scans[scanIndex]['icon']}`}
                    style={{
                      width: '64px',
                      margin: '0px',
                    }}
                  />
                }
              </Stack.Item>
              <Stack.Item>Существо: {scans[scanIndex]['name']}</Stack.Item>
              <Stack.Item>Здоровье: {scans[scanIndex]['health']}</Stack.Item>
              <Stack.Item>
                Минимальный урон: {scans[scanIndex]['dmg_low']}
              </Stack.Item>
              <Stack.Item>
                Максимальный урон: {scans[scanIndex]['dmg_high']}
              </Stack.Item>
              <Stack.Item>
                Урон по объектам: {scans[scanIndex]['dmg_obj']}
              </Stack.Item>
              <Stack.Item>
                Требует заряда: {scans[scanIndex]['cost']}
              </Stack.Item>
              <Stack.Item>
                <Button
                  content="Спроецировать"
                  onClick={() =>
                    act('create', {
                      index: scans[scanIndex]['index'],
                    })
                  }
                />
                <Button
                  content="Развеять"
                  onClick={() =>
                    act('kill', {
                      index: scans[scanIndex]['index'],
                    })
                  }
                />
                <Button
                  content="Забыть"
                  onClick={() =>
                    act('forget', {
                      index: scans[scanIndex]['index'],
                    })
                  }
                />
              </Stack.Item>
            </Stack>
          ) : null}
        </Stack.Item>
      </Stack>
    </Stack>
  );
};
