import {
  Box,
  Button,
  Divider,
  Dropdown,
  Flex,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { Window } from '../layouts';

interface ConsoleData {
  drone_fab: boolean;
  fab_power: boolean | null;
  drone_prod: boolean | null;
  drone_progress: number | null;
  selected_area: string;
  ping_cd: boolean;
  drones: DroneData[];
}

interface ConsoleStaticData {
  area_list: string[];
}

type AllData = ConsoleData & ConsoleStaticData;

interface DroneData {
  name: string;
  uid: string;
  stat: number;
  client: boolean;
  health: number;
  charge: number;
  location: string;
  sync_cd: boolean;
}

export const DroneConsole = (props) => {
  return (
    <Window width={420} height={500}>
      <Window.Content scrollable>
        <Fabricator />
        <DroneList />
      </Window.Content>
    </Window>
  );
};

const Fabricator = (props) => {
  const { act, data } = useBackend<ConsoleData>();
  const { drone_fab, fab_power, drone_prod, drone_progress } = data;

  const FabDetected = () => {
    if (drone_fab) {
      return (
        <LabeledList>
          <LabeledList.Item label="Внешнее питание">
            <Box color={fab_power ? 'good' : 'bad'}>
              [ {fab_power ? 'Вкл' : 'Выкл'} ]
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Производство дронов">
            <ProgressBar
              value={drone_progress !== null ? drone_progress / 100 : 0}
              ranges={{
                good: [0.7, Infinity],
                average: [0.4, 0.7],
                bad: [-Infinity, 0.4],
              }}
            />
          </LabeledList.Item>
        </LabeledList>
      );
    } else {
      return (
        <NoticeBox textAlign="center" danger>
          <Flex inline direction="column">
            <Flex.Item>ФАБРИКАТОР НЕ ОБНАРУЖЕН.</Flex.Item>
            <Flex.Item>
              <Button icon="search" onClick={() => act('find_fab')}>
                Поиск
              </Button>
            </Flex.Item>
          </Flex>
        </NoticeBox>
      );
    }
  };

  return (
    <Section
      title="Фабрикатор дронов"
      buttons={
        <Button
          icon="power-off"
          color={drone_prod ? 'green' : 'red'}
          onClick={() => act('toggle_fab')}
        >
          {drone_prod ? 'Активен' : 'Неактивен'}
        </Button>
      }
    >
      {FabDetected()}
    </Section>
  );
};

const DroneList = (props) => {
  const { act, data } = useBackend<AllData>();
  const { drones, area_list, selected_area, ping_cd } = data;

  const status = (stat: number, client: boolean) => {
    let box_color: string;
    let text: string;
    if (stat === 2) {
      box_color = 'bad';
      text = 'Отключён';
    } else if (stat === 1 || !client) {
      box_color = 'average';
      text = 'Неактивен';
    } else {
      box_color = 'good';
      text = 'Активен';
    }
    return <Box color={box_color}>{text}</Box>;
  };

  const Divide = () => {
    if (drones.length) {
      return (
        <Box py={0.2}>
          <Divider />
        </Box>
      );
    }
    return null;
  };

  return (
    <Section title="Ремонтные дроны">
      <Flex>
        <Flex.Item>Запросить присутствие дрона в зоне:&nbsp;</Flex.Item>
        <Flex.Item>
          <Dropdown
            options={area_list}
            selected={selected_area}
            width="125px"
            onSelected={(value) =>
              act('set_area', {
                area: value,
              })
            }
          />
        </Flex.Item>
      </Flex>
      <Button
        icon="broadcast-tower"
        disabled={ping_cd || !drones.length}
        tooltip={!drones.length ? 'Нет активных дронов!' : undefined}
        fluid
        textAlign="center"
        py={0.4}
        mt={0.6}
        onClick={() => act('ping')}
      >
        Отправить пинг
      </Button>
      <Divide />
      {drones.map((drone) => (
        <Section
          key={drone.uid}
          title={toTitleCase(drone.name)}
          buttons={
            <Stack>
              <Stack.Item>
                <Button
                  icon="sync"
                  disabled={drone.stat === 2 || drone.sync_cd}
                  onClick={() =>
                    act('resync', {
                      uid: drone.uid,
                    })
                  }
                >
                  Синхронизировать
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button.Confirm
                  icon="power-off"
                  disabled={drone.stat === 2}
                  color="bad"
                  onClick={() =>
                    act('shutdown', {
                      uid: drone.uid,
                    })
                  }
                >
                  Отключить
                </Button.Confirm>
              </Stack.Item>
            </Stack>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Статус">
              {status(drone.stat, drone.client)}
            </LabeledList.Item>
            <LabeledList.Item label="Целостность">
              <ProgressBar
                value={drone.health}
                ranges={{
                  good: [0.7, Infinity],
                  average: [0.4, 0.7],
                  bad: [-Infinity, 0.4],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Заряд">
              <ProgressBar
                value={drone.charge}
                ranges={{
                  good: [0.7, Infinity],
                  average: [0.4, 0.7],
                  bad: [-Infinity, 0.4],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Местоположение">
              {drone.location}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      ))}
    </Section>
  );
};
