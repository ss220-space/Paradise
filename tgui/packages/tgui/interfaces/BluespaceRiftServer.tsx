import { useBackend } from '../backend';
import {
  LabeledList,
  Section,
  ProgressBar,
  Button,
  Box,
  Icon,
} from '../components';
import { Window } from '../layouts';

const status_table = {
  0: 'OFF',
  1: 'NO_RIFTS',
  2: 'SOME_RIFTS',
  3: 'DANGER',
};

type BSRServerData = {
  emagged: boolean;
  pointsPerProbe: number;
  cooldown: number;
  goals: Goal[];
  servers: Server[];
  scanners: Scanner[];
};

type Goal = {
  riftId: string;
  riftName: string;
  targetResearchPoints: number;
  researchPoints: number;
  probePoints: number;
  rewardGiven: boolean;
};

type Server = {
  servName: string;
  servData: ServerData[];
};

type ServerData = { riftName: string; probePoints: number };

type Scanner = {
  scannerId: string;
  scannerName: string;
  scanStatus: number;
  canSwitch: boolean;
  switching: boolean;
};

export const BluespaceRiftServer = (props: unknown) => {
  const { act, data } = useBackend<BSRServerData>();
  const { emagged, pointsPerProbe, cooldown, goals, servers, scanners } = data;

  const goal = (goalData: Goal) => {
    const {
      riftId,
      riftName,
      targetResearchPoints,
      researchPoints,
      probePoints,
      rewardGiven,
    } = goalData;
    const percentage = Math.floor(
      (researchPoints / targetResearchPoints) * 100
    );
    const probesLeft =
      pointsPerProbe > 0 ? Math.floor(probePoints / pointsPerProbe) : 0;
    const pointsPerProbeMessage = emagged
      ? '@?%%!№@' + pointsPerProbe
      : pointsPerProbe;
    const enoughProbePoints = probePoints >= pointsPerProbe;
    const displayed_cooldown =
      cooldown - (cooldown % 5) + (cooldown % 5 > 0 ? 5 : 0);
    return (
      <Section title="Исследование Разлома">
        <Box color="silver" bold>
          {riftName}
        </Box>
        <ProgressBar
          color={
            percentage === 0 ? 'bad' : percentage < 100 ? 'average' : 'good'
          }
          value={researchPoints}
          maxValue={targetResearchPoints}
          mt={1}
          mb={2}
        >
          {percentage <= 100 ? percentage : 100} %
        </ProgressBar>
        <Box>
          {'Данные для зондирования: '}
          <Box
            color={
              probePoints ? (enoughProbePoints ? 'good' : 'average') : 'bad'
            }
            as="span"
          >
            {Math.floor(probePoints)}
          </Box>
          <Button
            icon="atom"
            tooltip={
              'Для генерации одного зондирующего импульса нужно собрать ' +
              pointsPerProbeMessage +
              ' данных.'
            }
            disabled={!enoughProbePoints || cooldown > 0}
            onClick={() =>
              act('probe', {
                rift_id: riftId,
              })
            }
            mx={2}
          >
            {cooldown > 0
              ? 'Подготовка ' + displayed_cooldown + ' секунд'
              : 'Зондировать (' + probesLeft + ')'}
          </Button>
          <br />
          <Button
            fluid
            textAlign="center"
            disabled={rewardGiven || percentage < 100}
            onClick={() =>
              act('reward', {
                rift_id: riftId,
              })
            }
            mt={1.4}
          >
            {rewardGiven
              ? 'Результат получен'
              : 'Получить результат исследований'}
          </Button>
        </Box>
      </Section>
    );
  };

  const server = (serverData: Server) => {
    const { servName, servData } = serverData;
    return (
      <LabeledList.Item label={servName}>
        {servData.length ? (
          servData.map((oneRiftData, index) => (
            <Box key={index}>
              {oneRiftData.riftName} — {Math.floor(oneRiftData.probePoints)}{' '}
              данных.
            </Box>
          ))
        ) : (
          <Box>Нет данных</Box>
        )}
      </LabeledList.Item>
    );
  };

  const scanner = (scannerData: Scanner) => {
    const { scannerId, scannerName, scanStatus, canSwitch, switching } =
      scannerData;

    const scanStatusTxt = status_table[scanStatus];

    const getStatusText = () => {
      if (scanStatusTxt === 'OFF') {
        return [' ', 'silver'];
      } else if (scanStatusTxt === 'NO_RIFTS') {
        return ['Нет разломов', 'silver'];
      } else if (scanStatusTxt === 'SOME_RIFTS') {
        return ['Сканирует', 'good'];
      } else if (scanStatusTxt === 'DANGER') {
        return ['Опасность! Выключите сканер!', 'bad'];
      }
    };

    const statusText = getStatusText();

    return (
      <LabeledList.Item label={scannerName}>
        {switching ? (
          <Icon
            name="circle-notch"
            color="silver"
            spin
            ml={1.85}
            mr={1.79}
            my={0.84}
          />
        ) : canSwitch ? (
          <Button
            icon="power-off"
            color={scanStatusTxt === 'OFF' ? 'bad' : 'good'}
            onClick={() =>
              act('toggle_scanner', {
                scanner_id: scannerId,
              })
            }
            ml={1}
            mr={1}
          />
        ) : (
          <Icon
            name="power-off"
            color={scanStatusTxt === 'OFF' ? 'bad' : 'good'}
            ml={1.85}
            mr={1.79}
            my={0.84}
          />
        )}
        {scanStatusTxt !== 'OFF' && (
          <Box as="span" color={statusText[1]}>
            {statusText[0]}
          </Box>
        )}
      </LabeledList.Item>
    );
  };

  return (
    <Window width={570} height={400}>
      <Window.Content scrollable>
        {goals && goals.map((goalData: Goal) => goal(goalData))}
        <Section title="Сканеры в сети">
          <LabeledList>
            {scanners &&
              scanners.map((scannerData: Scanner) => scanner(scannerData))}
          </LabeledList>
        </Section>
        <Section title="Серверы в сети">
          <LabeledList>
            {servers && servers.map((serverData: Server) => server(serverData))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
