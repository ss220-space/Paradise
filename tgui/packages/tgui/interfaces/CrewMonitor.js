import { sortBy } from 'common/collections';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Icon, Input, NanoMap, Table, Tabs } from '../components';
import { TableCell } from '../components/Table';
import { COLORS } from '../constants.js';
import { Window } from '../layouts';

const getStatText = (cm, critThreshold) => {
  if (cm.dead) {
    return 'Мёртв';
  }
  if (parseInt(cm.health, 10) <= critThreshold) {
    // Critical
    return 'Критическое состояние';
  }
  if (parseInt(cm.stat, 10) === 1) {
    // Unconscious
    return 'Без сознания';
  }
  return 'Жив';
};

const getStatColor = (cm, critThreshold) => {
  if (cm.dead) {
    return 'red';
  }
  if (parseInt(cm.health, 10) <= critThreshold) {
    // Critical
    return 'orange';
  }
  if (parseInt(cm.stat, 10) === 1) {
    // Unconscious
    return 'blue';
  }
  return 'green';
};

export const CrewMonitor = (props, context) => {
  const { act, data } = useBackend(context);
  const [tabIndex, setTabIndex] = useLocalState(
    context,
    'tabIndex',
    data.IndexToggler
  );
  const decideTab = (index) => {
    switch (index) {
      case 0:
        return <ComCrewMonitorDataView />;
      case 1:
        return <SecCrewMonitorDataView />;
      case 2:
        return <MiningCrewMonitorDataView />;
      case 3:
        return <CrewMonitorDataView />;
      case 4:
        return <CrewMonitorMapView />;
      default:
        return 'ЧТО-ТО ТОЧНО НЕ ТАК!';
    }
  };

  return (
    <Window width={800} height={600}>
      <Window.Content scrollable>
        <Box fillPositionedParent>
          <Tabs>
            {data.isBS ? (
              <Tabs.Tab
                key="ComDataView"
                selected={0 === tabIndex}
                onClick={() => setTabIndex(0)}
              >
                <Icon name="table" /> Данные о Командовании
              </Tabs.Tab>
            ) : null}
            {data.isBP ? (
              <Tabs.Tab
                key="SecDataView"
                selected={1 === tabIndex}
                onClick={() => setTabIndex(1)}
              >
                <Icon name="table" /> Данные о Службе Безопасности
              </Tabs.Tab>
            ) : null}
            {data.isMM ? (
              <Tabs.Tab
                key="MiningDataView"
                selected={2 === tabIndex}
                onClick={() => setTabIndex(2)}
              >
                <Icon name="table" /> Данные о шахтёрах
              </Tabs.Tab>
            ) : null}
            <Tabs.Tab
              key="DataView"
              selected={3 === tabIndex}
              onClick={() => setTabIndex(3)}
            >
              <Icon name="table" /> Данные об Экипаже
            </Tabs.Tab>
            <Tabs.Tab
              key="MapView"
              selected={4 === tabIndex}
              onClick={() => setTabIndex(4)}
            >
              <Icon name="map-marked-alt" /> Просмотр Карты
            </Tabs.Tab>
          </Tabs>
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};

const CrewMonitorTable = ({ crewData, context }) => {
  const { act, data } = useBackend(context);
  const crew = sortBy((cm) => cm.name)(crewData || []);
  const [search, setSearch] = useLocalState(context, 'search', '');
  const searcher = createSearch(search, (cm) => {
    return cm.name + '|' + cm.assignment + '|' + cm.area;
  });
  return (
    <Box>
      <Input
        placeholder="Введите Имя, Должность или Локацию..."
        width="100%"
        onInput={(_e, value) => setSearch(value)}
      />
      <Table m="0.5rem">
        <Table.Row header>
          <Table.Cell>Имя</Table.Cell>
          <Table.Cell>Состояние</Table.Cell>
          <Table.Cell>Локация</Table.Cell>
        </Table.Row>
        {crew.filter(searcher).map((cm) => (
          <Table.Row key={cm.ref} bold={!!cm.is_command}>
            <TableCell>
              {cm.name} ({cm.assignment})
            </TableCell>
            <TableCell>
              <Box inline color={getStatColor(cm, data.critThreshold)}>
                {getStatText(cm, data.critThreshold)}
              </Box>
              {cm.sensor_type >= 2 ? (
                <Box inline>
                  {'('}
                  <Box inline color={COLORS.damageType.oxy}>
                    {cm.oxy}
                  </Box>
                  {'|'}
                  <Box inline color={COLORS.damageType.toxin}>
                    {cm.tox}
                  </Box>
                  {'|'}
                  <Box inline color={COLORS.damageType.burn}>
                    {cm.fire}
                  </Box>
                  {'|'}
                  <Box inline color={COLORS.damageType.brute}>
                    {cm.brute}
                  </Box>
                  {')'}
                </Box>
              ) : null}
            </TableCell>
            <TableCell>
              {cm.sensor_type === 3 ? (
                data.isAI ? (
                  <Button
                    fluid
                    icon="location-arrow"
                    content={cm.area + ' (' + cm.x + ', ' + cm.y + ')'}
                    onClick={() =>
                      act('track', {
                        track: cm.ref,
                      })
                    }
                  />
                ) : (
                  cm.area + ' (' + cm.x + ', ' + cm.y + ', ' + cm.z + ')'
                )
              ) : (
                'Недоступно'
              )}
            </TableCell>
          </Table.Row>
        ))}
      </Table>
    </Box>
  );
};

const CrewMonitorDataView = (_properties, context) => {
  const { act, data } = useBackend(context);
  const crew = data.crewmembers || [];
  return <CrewMonitorTable crewData={crew} context={context} />;
};

const ComCrewMonitorDataView = (_properties, context) => {
  const { act, data } = useBackend(context);
  const commandCrew = data.crewmembers.filter((cm) => cm.is_command) || [];
  return <CrewMonitorTable crewData={commandCrew} context={context} />;
};

const SecCrewMonitorDataView = (_properties, context) => {
  const { act, data } = useBackend(context);
  const securityCrew = data.crewmembers.filter((cm) => cm.is_security) || [];
  return <CrewMonitorTable crewData={securityCrew} context={context} />;
};

const MiningCrewMonitorDataView = (_properties, context) => {
  const { act, data } = useBackend(context);
  const miningCrew = data.crewmembers.filter((cm) => cm.is_shaft_miner) || [];
  return <CrewMonitorTable crewData={miningCrew} context={context} />;
};

const CrewMonitorMapView = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { stationLevelNum, stationLevelName } = data;
  const [zoom, setZoom] = useLocalState(context, 'zoom', 1);
  const [z_current, setZCurrent] = useLocalState(
    context,
    'z_current',
    stationLevelNum[0]
  );
  const getIcon = (cm) => {
    return (cm.is_command && data.isBS) || (cm.is_security && data.isBP)
      ? 'square'
      : 'circle';
  };
  const getSize = (cm) => {
    return (cm.is_command && data.isBS) || (cm.is_security && data.isBP)
      ? 10
      : 6;
  };
  const getExtendedStatColor = (cm, critThreshold) => {
    if ((cm.is_command && data.isBS) || (cm.is_security && data.isBP)) {
      if (cm.dead) {
        return 'red';
      }
      if (parseInt(cm.health, 10) <= critThreshold) {
        // Critical
        return 'orange';
      }
      if (parseInt(cm.stat, 10) === 1) {
        // Unconscious
        return 'blue';
      }
      return 'violet';
    } else {
      return getStatColor(cm, critThreshold);
    }
  };
  return (
    <Box height="526px" mb="0.5rem" overflow="hidden">
      <NanoMap
        onZoom={(v) => setZoom(v)}
        zLevels={stationLevelNum}
        zNames={stationLevelName}
        z_current={z_current}
        setZCurrent={setZCurrent}
      >
        {data.crewmembers
          .filter((x) => x.sensor_type === 3)
          .map((cm) => (
            <NanoMap.Marker
              key={cm.ref}
              x={cm.x}
              y={cm.y}
              z={cm.z}
              z_current={z_current}
              zoom={zoom}
              icon={getIcon(cm)}
              size={getSize(cm)}
              tooltip={cm.name + ' (' + cm.assignment + ')'}
              color={getExtendedStatColor(cm, data.critThreshold)}
              onClick={() => {
                if (data.isAI) {
                  act('track', {
                    track: cm.ref,
                  });
                }
              }}
            />
          ))}
      </NanoMap>
    </Box>
  );
};
