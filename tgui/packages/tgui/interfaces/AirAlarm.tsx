import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  Box,
  AnimatedNumber,
  Section,
  ProgressBar,
  Icon,
  Tabs,
  Table,
} from '../components';
import { useState } from 'react';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';
import { AtmosMachine, AtmosMachineView } from './common/AtmosMachine';
import { GASES } from '../constants';
import { Danger2Colour } from './common/AtmosScan';

type AirAlarmData = {
  air: Air;
  mode: number;
  atmos_alarm: boolean;
  locked: boolean;
  alarmActivated: boolean;
  rcon: number;
  target_temp: number;
  vents: AtmosMachine[];
  scrubbers: AtmosMachine[];
  modes: Mode[];
  presets: Preset[];
  emagged: boolean;
  preset: number;
  thresholds: Threshold[];
};

type Air = {
  danger: Danger;
  contents: AirContent;
  pressure: number;
  thermostat_state: boolean;
  temperature: number;
  temperature_c: number;
};

type Danger = {
  overall: number;
  pressure: number;
  oxygen: number;
  nitrogen: number;
  carbon_dioxide: number;
  nitrous_oxide: number;
  hydrogen: number;
  water_vapor: number;
  plasma: number;
  other: number;
  temperature: number;
};

type AirContent = {
  oxygen: number;
  nitrogen: number;
  carbon_dioxide: number;
  nitrous_oxide: number;
  hydrogen: number;
  water_vapor: number;
  plasma: number;
  other: number;
};

type Mode = {
  id: number;
  name: string;
  desc: string;
  emagonly: boolean;
};

type Preset = {
  id: number;
  name: string;
  desc: string;
};

type Threshold = {
  name: string;
  settings: Setting[];
};

type Setting = {
  selected: number;
  env: string;
  val: number;
};

export const AirAlarm = (props: unknown) => {
  const { data } = useBackend<AirAlarmData>();
  const { locked } = data;
  const [tabIndex, setTabIndex] = useState(0);
  // Bail straight away if there is no air
  return (
    <Window width={570} height={locked ? 310 : 755}>
      <Window.Content scrollable>
        <InterfaceLockNoticeBox />
        <AirStatus />
        {!locked && (
          <>
            <AirAlarmTabs tabIndex={tabIndex} setTabIndex={setTabIndex} />
            <AirAlarmUnlockedContent tabIndex={tabIndex} />
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const AirStatus = (_props: unknown) => {
  const { act, data } = useBackend<AirAlarmData>();
  const { air, mode, atmos_alarm, locked, alarmActivated, rcon, target_temp } =
    data;

  let areaStatus: string;
  if (air.danger.overall === 0) {
    if (!atmos_alarm) {
      areaStatus = 'Optimal';
    } else {
      areaStatus = 'Caution: Atmos alert in area';
    }
  } else if (air.danger.overall === 1) {
    areaStatus = 'Caution';
  } else {
    areaStatus = 'DANGER: Internals Required';
  }

  let permanentGases = ['oxygen', 'nitrogen', 'carbon_dioxide', 'plasma'];

  return (
    <Section title="Air Status">
      {air ? (
        <LabeledList>
          <LabeledList.Item label="Pressure">
            <Box color={Danger2Colour(air.danger.pressure)}>
              <AnimatedNumber value={air.pressure} /> kPa
              {!locked && (
                <>
                  &nbsp;
                  <Button
                    selected={mode === 3}
                    icon="exclamation-triangle"
                    onClick={() => act('mode', { mode: mode === 3 ? 1 : 3 })}
                  >
                    {mode === 3
                      ? 'Deactivate Panic Siphon'
                      : 'Activate Panic Siphon'}
                  </Button>
                </>
              )}
            </Box>
          </LabeledList.Item>
          {GASES.map((gas, id) => {
            if (
              gas.tlv in permanentGases ||
              air.contents[gas.tlv] ||
              0 >= 0.1
            ) {
              return (
                <LabeledList.Item key={id} label={gas.label}>
                  <ProgressBar
                    value={(air.contents[gas.tlv] || 0) / 100}
                    fractionDigits={1}
                    color={Danger2Colour(air.danger[gas.tlv] || 0)}
                  />
                </LabeledList.Item>
              );
            } else return '';
          })}
          <LabeledList.Item label="Temperature">
            <Box color={Danger2Colour(air.danger.temperature)}>
              <AnimatedNumber value={air.temperature} /> K /{' '}
              <AnimatedNumber value={air.temperature_c} /> C&nbsp;
              <Button
                icon="thermometer-full"
                onClick={() => act('temperature')}
              >
                {target_temp + ' C'}
              </Button>
              <Button
                selected={air.thermostat_state}
                icon="power-off"
                onClick={() => act('thermostat_state')}
              >
                {air.thermostat_state ? 'On' : 'Off'}
              </Button>
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Local Status">
            <Box color={Danger2Colour(air.danger.overall)}>
              {areaStatus}
              {!locked && (
                <>
                  &nbsp;
                  <Button
                    selected={alarmActivated}
                    onClick={() =>
                      act(alarmActivated ? 'atmos_reset' : 'atmos_alarm')
                    }
                  >
                    {alarmActivated ? 'Reset Alarm' : 'Activate Alarm'}
                  </Button>
                </>
              )}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Remote Control Settings">
            <Button
              selected={rcon === 1}
              onClick={() => act('set_rcon', { rcon: 1 })}
            >
              Off
            </Button>
            <Button
              selected={rcon === 2}
              onClick={() => act('set_rcon', { rcon: 2 })}
            >
              Auto
            </Button>
            <Button
              selected={rcon === 3}
              onClick={() => act('set_rcon', { rcon: 3 })}
            >
              On
            </Button>
          </LabeledList.Item>
        </LabeledList>
      ) : (
        <Box>Unable to acquire air sample!</Box>
      )}
    </Section>
  );
};

const AirAlarmTabs = (props: TabIndexProps) => {
  const { tabIndex, setTabIndex } = props;
  return (
    <Tabs>
      <Tabs.Tab
        key="Vents"
        selected={0 === tabIndex}
        onClick={() => setTabIndex(0)}
      >
        <Icon name="sign-out-alt" /> Vent Control
      </Tabs.Tab>
      <Tabs.Tab
        key="Scrubbers"
        selected={1 === tabIndex}
        onClick={() => setTabIndex(1)}
      >
        <Icon name="sign-in-alt" /> Scrubber Control
      </Tabs.Tab>
      <Tabs.Tab
        key="Mode"
        selected={2 === tabIndex}
        onClick={() => setTabIndex(2)}
      >
        <Icon name="cog" /> Mode
      </Tabs.Tab>
      <Tabs.Tab
        key="Thresholds"
        selected={3 === tabIndex}
        onClick={() => setTabIndex(3)}
      >
        <Icon name="tachometer-alt" /> Thresholds
      </Tabs.Tab>
    </Tabs>
  );
};

const AirAlarmUnlockedContent = (props: TabIndexProps) => {
  const { tabIndex } = props;
  switch (tabIndex) {
    case 0:
      return <AirAlarmVentsView />;
    case 1:
      return <AirAlarmScrubbersView />;
    case 2:
      return <AirAlarmModesView />;
    case 3:
      return <AirAlarmThresholdsView />;
    default:
      return "WE SHOULDN'T BE HERE!";
  }
};

const AirAlarmVentsView = (props: unknown) => {
  const { data } = useBackend<AirAlarmData>();
  const { vents } = data;
  return vents.map((v) => <AtmosMachineView key={v.uid} {...v} />);
};

const AirAlarmScrubbersView = (props: unknown) => {
  const { data } = useBackend<AirAlarmData>();
  const { scrubbers } = data;
  return scrubbers.map((s) => <AtmosMachineView key={s.uid} {...s} />);
};

const AirAlarmModesView = (props: unknown) => {
  const { act, data } = useBackend<AirAlarmData>();
  const { modes, presets, emagged, mode, preset } = data;
  return (
    <>
      <Section title="System Mode">
        <Table
          style={{
            borderCollapse: 'separate',
            borderSpacing: '0 1px',
          }}
        >
          {Object.keys(modes).map((key) => {
            let m = modes[key];
            if (!m.emagonly || !!emagged) {
              return (
                <Table.Row key={m.name}>
                  <Table.Cell textAlign="right" width={1}>
                    <Button
                      icon="cog"
                      selected={m.id === mode}
                      onClick={() => act('mode', { mode: m.id })}
                    >
                      {m.name}
                    </Button>
                  </Table.Cell>
                  <Table.Cell>{m.desc}</Table.Cell>
                </Table.Row>
              );
            }
          })}
        </Table>
      </Section>
      <Section title="System Presets">
        <Box italic>
          After making a selection, the system will automatically cycle in order
          to remove contaminants.
        </Box>
        <Table
          mt={1}
          style={{
            borderCollapse: 'separate',
            borderSpacing: '0 1px',
          }}
        >
          {presets.map((p) => (
            <Table.Row key={p.name}>
              <Table.Cell textAlign="right" width={1}>
                <Button
                  icon="cog"
                  selected={p.id === preset}
                  onClick={() => act('preset', { preset: p.id })}
                >
                  {p.name}
                </Button>
              </Table.Cell>
              <Table.Cell>{p.desc}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </>
  );
};

const AirAlarmThresholdsView = (props: unknown) => {
  const { act, data } = useBackend<AirAlarmData>();
  const { thresholds } = data;
  return (
    <Section title="Alarm Thresholds">
      <Table
        style={{
          borderCollapse: 'separate',
          borderSpacing: '0 5px',
        }}
      >
        <Table.Row header>
          <Table.Cell width="20%">Value</Table.Cell>
          <Table.Cell color="red" width="20%">
            Danger Min
          </Table.Cell>
          <Table.Cell color="orange" width="20%">
            Warning Min
          </Table.Cell>
          <Table.Cell color="orange" width="20%">
            Warning Max
          </Table.Cell>
          <Table.Cell color="red" width="20%">
            Danger Max
          </Table.Cell>
        </Table.Row>
        {thresholds.map((t) => (
          <Table.Row key={t.name}>
            <Table.Cell>{t.name}</Table.Cell>
            {t.settings.map((s) => (
              <Table.Cell key={s.val}>
                <Button
                  onClick={() =>
                    act('set_threshold', {
                      env: s.env,
                      var: s.val,
                    })
                  }
                >
                  {s.selected === -1 ? 'Off' : s.selected}
                </Button>
              </Table.Cell>
            ))}
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
