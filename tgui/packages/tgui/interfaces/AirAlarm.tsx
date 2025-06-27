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

type AirAlarmData = {
  air: Air;
  mode: number;
  atmos_alarm: boolean;
  locked: boolean;
  alarmActivated: boolean;
  rcon: number;
  target_temp: number;
  vents: Vent[];
  scrubbers: Scrubber[];
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
  co2: number;
  n2o: number;
  plasma: number;
  other: number;
  temperature: number;
};

type AirContent = {
  oxygen: number;
  nitrogen: number;
  co2: number;
  n2o: number;
  plasma: number;
  other: number;
};

interface AtmosMachine {
  name: string;
  power: boolean;
  id_tag: string;
  direction: string;
}

type Vent = {
  checks: number;
  external: number;
} & AtmosMachine;

type Scrubber = {
  scrubbing: boolean;
  widenet: boolean;
  filter_n2o: boolean;
  filter_co2: boolean;
  filter_toxins: boolean;
  filter_o2: boolean;
  filter_n2: boolean;
} & AtmosMachine;

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

const Danger2Colour = (danger: number) => {
  if (danger === 0) {
    return 'green';
  }
  if (danger === 1) {
    return 'orange';
  }
  return 'red';
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
          <LabeledList.Item label="Oxygen">
            <ProgressBar
              value={air.contents.oxygen / 100}
              fractionDigits={1}
              color={Danger2Colour(air.danger.oxygen)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Nitrogen">
            <ProgressBar
              value={air.contents.nitrogen / 100}
              fractionDigits={1}
              color={Danger2Colour(air.danger.nitrogen)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Carbon Dioxide">
            <ProgressBar
              value={air.contents.co2 / 100}
              fractionDigits={1}
              color={Danger2Colour(air.danger.co2)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Toxins">
            <ProgressBar
              value={air.contents.plasma / 100}
              fractionDigits={1}
              color={Danger2Colour(air.danger.plasma)}
            />
          </LabeledList.Item>
          {air.contents.n2o > 0.1 && (
            <LabeledList.Item label="Nitrous Oxide">
              <ProgressBar
                value={air.contents.n2o / 100}
                fractionDigits={1}
                color={Danger2Colour(air.danger.n2o)}
              />
            </LabeledList.Item>
          )}
          {air.contents.other > 0.1 && (
            <LabeledList.Item label="Other">
              <ProgressBar
                value={air.contents.other / 100}
                fractionDigits={1}
                color={Danger2Colour(air.danger.other)}
              />
            </LabeledList.Item>
          )}
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
  const { act, data } = useBackend<AirAlarmData>();
  const { vents } = data;
  return vents.map((v) => (
    <Section title={v.name} key={v.name}>
      <LabeledList>
        <LabeledList.Item label="Status">
          <Button
            selected={v.power}
            icon="power-off"
            onClick={() =>
              act('command', {
                cmd: 'power',
                val: v.power ? 0 : 1,
                id_tag: v.id_tag,
              })
            }
          >
            {v.power ? 'On' : 'Off'}
          </Button>
          <Button
            icon={v.direction === 'release' ? 'sign-out-alt' : 'sign-in-alt'}
            onClick={() =>
              act('command', {
                cmd: 'direction',
                val: v.direction === 'release' ? 0 : 1,
                id_tag: v.id_tag,
              })
            }
          >
            {v.direction === 'release' ? 'Blowing' : 'Siphoning'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Pressure Checks">
          <Button
            selected={v.checks === 1}
            onClick={() =>
              act('command', { cmd: 'checks', val: 1, id_tag: v.id_tag })
            }
          >
            External
          </Button>
          <Button
            selected={v.checks === 2}
            onClick={() =>
              act('command', { cmd: 'checks', val: 2, id_tag: v.id_tag })
            }
          >
            Internal
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="External Pressure Target">
          <AnimatedNumber value={v.external} /> kPa&nbsp;
          <Button
            icon="cog"
            onClick={() =>
              act('command', { cmd: 'set_external_pressure', id_tag: v.id_tag })
            }
          >
            Set
          </Button>
          <Button
            icon="redo-alt"
            onClick={() =>
              act('command', {
                cmd: 'set_external_pressure',
                val: 101.325,
                id_tag: v.id_tag,
              })
            }
          >
            Reset
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  ));
};

const AirAlarmScrubbersView = (props: unknown) => {
  const { act, data } = useBackend<AirAlarmData>();
  const { scrubbers } = data;
  return scrubbers.map((s) => (
    <Section title={s.name} key={s.name}>
      <LabeledList>
        <LabeledList.Item label="Status">
          <Button
            selected={s.power}
            icon="power-off"
            onClick={() =>
              act('command', {
                cmd: 'power',
                val: s.power ? 0 : 1,
                id_tag: s.id_tag,
              })
            }
          >
            {s.power ? 'On' : 'Off'}
          </Button>
          <Button
            icon={s.scrubbing ? 'filter' : 'sign-in-alt'}
            onClick={() =>
              act('command', {
                cmd: 'scrubbing',
                val: !s.scrubbing ? 1 : 0,
                id_tag: s.id_tag,
              })
            }
          >
            {s.scrubbing ? 'Scrubbing' : 'Siphoning'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Range">
          <Button
            selected={s.widenet}
            icon="expand-arrows-alt"
            onClick={() =>
              act('command', {
                cmd: 'widenet',
                val: !s.widenet ? 1 : 0,
                id_tag: s.id_tag,
              })
            }
          >
            {s.widenet ? 'Extended' : 'Normal'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Filtering">
          <Button
            selected={s.filter_co2}
            onClick={() =>
              act('command', {
                cmd: 'co2_scrub',
                val: !s.filter_co2 ? 1 : 0,
                id_tag: s.id_tag,
              })
            }
          >
            Carbon Dioxide
          </Button>
          <Button
            selected={s.filter_toxins}
            onClick={() =>
              act('command', {
                cmd: 'tox_scrub',
                val: !s.filter_toxins ? 1 : 0,
                id_tag: s.id_tag,
              })
            }
          >
            Plasma
          </Button>
          <Button
            selected={s.filter_n2o}
            onClick={() =>
              act('command', {
                cmd: 'n2o_scrub',
                val: !s.filter_n2o ? 1 : 0,
                id_tag: s.id_tag,
              })
            }
          >
            Nitrous Oxide
          </Button>
          <Button
            selected={s.filter_o2}
            onClick={() =>
              act('command', {
                cmd: 'o2_scrub',
                val: !s.filter_o2 ? 1 : 0,
                id_tag: s.id_tag,
              })
            }
          >
            Oxygen
          </Button>
          <Button
            selected={s.filter_n2}
            onClick={() =>
              act('command', {
                cmd: 'n2_scrub',
                val: !s.filter_n2 ? 1 : 0,
                id_tag: s.id_tag,
              })
            }
          >
            Nitrogen
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  ));
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
          {modes.map(
            (m) =>
              (!m.emagonly || (m.emagonly && !!emagged)) && (
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
              )
          )}
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
                    act('command', {
                      cmd: 'set_threshold',
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
