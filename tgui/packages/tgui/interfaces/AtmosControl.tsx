import { useBackend } from '../backend';
import { useState } from 'react';
import { Box, Button, Icon, NanoMap, Table, Tabs } from '../components';
import { Window } from '../layouts';

const getStatus = (level: number) => {
  if (level === 0) {
    return <Box color="green">Good</Box>;
  }
  if (level === 1) {
    return (
      <Box color="orange" bold>
        Warning
      </Box>
    );
  }
  if (level === 2) {
    return (
      <Box color="red" bold>
        DANGER
      </Box>
    );
  }
};

const getStatusColour = (level: number) => {
  if (level === 0) {
    return 'green';
  }
  if (level === 1) {
    return 'orange';
  }
  if (level === 2) {
    return 'red';
  }
};

type AtmosControlData = {
  alarms: Alarm[];
  stationLevelNum: number[];
  stationLevelName: string[];
};

type Alarm = {
  name: string;
  danger: number;
  ref: string;
  x: number;
  y: number;
  z: number;
};

export const AtmosControl = (props: unknown) => {
  const [tabIndex, setTabIndex] = useState(0);
  const decideTab = (index: number) => {
    switch (index) {
      case 0:
        return <AtmosControlDataView />;
      case 1:
        return <AtmosControlMapView />;
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Window width={800} height={600}>
      <Window.Content scrollable={tabIndex === 0}>
        <Box fillPositionedParent>
          <Tabs>
            <Tabs.Tab
              key="DataView"
              selected={tabIndex === 0}
              onClick={() => setTabIndex(0)}
            >
              <Icon name="table" /> Data View
            </Tabs.Tab>
            <Tabs.Tab
              key="MapView"
              selected={tabIndex === 1}
              onClick={() => setTabIndex(1)}
            >
              <Icon name="map-marked-alt" /> Map View
            </Tabs.Tab>
          </Tabs>
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};

const AtmosControlDataView = (_properties) => {
  const { act, data } = useBackend<AtmosControlData>();
  const { alarms } = data;
  return (
    <Box>
      <Table
        m="0.5rem"
        style={{
          borderCollapse: 'separate',
          borderSpacing: '0 5px',
        }}
      >
        <Table.Row header>
          <Table.Cell>Name</Table.Cell>
          <Table.Cell>Status</Table.Cell>
          <Table.Cell>Access</Table.Cell>
        </Table.Row>
        {alarms.map((a, i) => (
          <Table.Row key={i}>
            <Table.Cell>{a.name}</Table.Cell>
            <Table.Cell>{getStatus(a?.danger)}</Table.Cell>
            <Table.Cell>
              <Button
                icon="cog"
                onClick={() =>
                  act('open_alarm', {
                    aref: a.ref,
                  })
                }
              >
                Access
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Box>
  );
};

const AtmosControlMapView = (_properties) => {
  const { act, data } = useBackend<AtmosControlData>();
  const { alarms, stationLevelNum, stationLevelName } = data;
  const [zoom, setZoom] = useState(1);
  const [z_current, setZCurrent] = useState(stationLevelNum[0]);
  return (
    <Box height="526px" mb="0.5rem" overflow="hidden">
      <NanoMap
        onZoom={(v, n) => setZoom(n)}
        zLevels={stationLevelNum}
        zNames={stationLevelName}
        zCurrent={z_current}
        setZCurrent={setZCurrent}
      >
        {alarms.map((aa) => (
          // The AA means air alarm, and nothing else
          <NanoMap.MarkerIcon
            key={aa.ref}
            x={aa.x}
            y={aa.y}
            z={aa.z}
            z_current={z_current}
            zoom={zoom}
            icon="circle"
            tooltip={aa.name}
            tooltipPosition={aa.x > 255 / 2 ? 'bottom' : 'right'}
            color={getStatusColour(aa?.danger)}
            onClick={() =>
              act('open_alarm', {
                aref: aa.ref,
              })
            }
          />
        ))}
      </NanoMap>
    </Box>
  );
};
