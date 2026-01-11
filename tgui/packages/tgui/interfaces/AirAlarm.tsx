import { useState } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Table,
  Tabs,
} from '../components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

type AirAlarmData = {
  air: Air | null;
  mode: number;
  atmos_alarm: number;
  locked: boolean;
  alarmActivated: boolean;
  rcon: number;
  target_temp: number;
  vents: Vent[];
  scrubbers: Scrubber[];
  modes: Record<string, Mode>;
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
  plasma: number;
  n2o: number;
  h2: number;
  water_vapor: number;
  other: number;
  temperature: number;
};

type AirContent = {
  oxygen: number;
  nitrogen: number;
  co2: number;
  plasma: number;
  n2o: number;
  h2: number;
  water_vapor: number;
  other: number;
};

interface AtmosMachine {
  name: string;
  power: boolean;
  id_tag: string;
}

type Vent = {
  direction: boolean;
  checks: number;
  external: number;
} & AtmosMachine;

type Scrubber = {
  scrubbing: boolean;
  widenet: boolean;
  filter_co2: boolean;
  filter_toxins: boolean;
  filter_n2o: boolean;
  filter_o2: boolean;
  filter_n2: boolean;
  filter_h2: boolean;
  filter_h2o: boolean;
} & AtmosMachine;

type Mode = {
  id: number;
  name: string;
  desc: string;
  emagonly?: boolean;
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
  val: string;
};

type TabIndexProps = {
  tabIndex: number;
  setTabIndex: (index: number) => void;
};

export const AirAlarm = (props: unknown) => {
  const { data } = useBackend<AirAlarmData>();
  const { locked } = data;
  const [tabIndex, setTabIndex] = useState(0);

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

const Danger2Colour = (danger: number): string => {
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
  if (!air) {
    areaStatus = 'No air data';
  } else if (air.danger.overall === 0) {
    if (atmos_alarm === 0) {
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
          {air.contents.h2 > 0.1 && (
            <LabeledList.Item label="Hydrogen">
              <ProgressBar
                value={air.contents.h2 / 100}
                fractionDigits={1}
                color={Danger2Colour(air.danger.h2)}
              />
            </LabeledList.Item>
          )}
          {air.contents.water_vapor > 0.1 && (
            <LabeledList.Item label="Water Vapor">
              <ProgressBar
                value={air.contents.water_vapor / 100}
                fractionDigits={1}
                color={Danger2Colour(air.danger.water_vapor)}
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
      <Tabs.Tab selected={tabIndex === 0} onClick={() => setTabIndex(0)}>
        <Icon name="sign-out-alt" /> Vent Control
      </Tabs.Tab>
      <Tabs.Tab selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
        <Icon name="sign-in-alt" /> Scrubber Control
      </Tabs.Tab>
      <Tabs.Tab selected={tabIndex === 2} onClick={() => setTabIndex(2)}>
        <Icon name="cog" /> Mode
      </Tabs.Tab>
      <Tabs.Tab selected={tabIndex === 3} onClick={() => setTabIndex(3)}>
        <Icon name="tachometer-alt" /> Thresholds
      </Tabs.Tab>
    </Tabs>
  );
};

const AirAlarmUnlockedContent = (props: { tabIndex: number }) => {
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

const AirAlarmVentsView = (_props: unknown) => {
  const { act, data } = useBackend<AirAlarmData>();
  const { vents } = data;

  return (
    <>
      {vents.map((vent) => (
        <Section title={vent.name} key={vent.id_tag}>
          <LabeledList>
            <LabeledList.Item label="Status">
              <Button
                selected={vent.power}
                icon="power-off"
                onClick={() =>
                  act('command', {
                    cmd: 'power',
                    val: !vent.power,
                    id_tag: vent.id_tag,
                  })
                }
              >
                {vent.power ? 'On' : 'Off'}
              </Button>
              <Button
                icon={vent.direction ? 'sign-out-alt' : 'sign-in-alt'}
                onClick={() =>
                  act('command', {
                    cmd: 'direction',
                    val: !vent.direction,
                    id_tag: vent.id_tag,
                  })
                }
              >
                {vent.direction ? 'Blowing' : 'Siphoning'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Pressure Checks">
              <Button
                selected={vent.checks === 1}
                onClick={() =>
                  act('command', { cmd: 'checks', val: 1, id_tag: vent.id_tag })
                }
              >
                External
              </Button>
              <Button
                selected={vent.checks === 2}
                onClick={() =>
                  act('command', { cmd: 'checks', val: 2, id_tag: vent.id_tag })
                }
              >
                Internal
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="External Pressure Target">
              <AnimatedNumber value={vent.external} /> kPa&nbsp;
              <Button
                icon="cog"
                onClick={() =>
                  act('command', {
                    cmd: 'set_external_pressure',
                    id_tag: vent.id_tag,
                  })
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
                    id_tag: vent.id_tag,
                  })
                }
              >
                Reset
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      ))}
    </>
  );
};

const AirAlarmScrubbersView = (_props: unknown) => {
  const { act, data } = useBackend<AirAlarmData>();
  const { scrubbers } = data;

  return (
    <>
      {scrubbers.map((scrubber) => (
        <Section title={scrubber.name} key={scrubber.id_tag}>
          <LabeledList>
            <LabeledList.Item label="Status">
              <Button
                selected={scrubber.power}
                icon="power-off"
                onClick={() =>
                  act('command', {
                    cmd: 'power',
                    val: !scrubber.power,
                    id_tag: scrubber.id_tag,
                  })
                }
              >
                {scrubber.power ? 'On' : 'Off'}
              </Button>
              <Button
                icon={scrubber.scrubbing ? 'filter' : 'sign-in-alt'}
                onClick={() =>
                  act('command', {
                    cmd: 'scrubbing',
                    val: !scrubber.scrubbing,
                    id_tag: scrubber.id_tag,
                  })
                }
              >
                {scrubber.scrubbing ? 'Scrubbing' : 'Siphoning'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Range">
              <Button
                selected={scrubber.widenet}
                icon="expand-arrows-alt"
                onClick={() =>
                  act('command', {
                    cmd: 'widenet',
                    val: !scrubber.widenet,
                    id_tag: scrubber.id_tag,
                  })
                }
              >
                {scrubber.widenet ? 'Extended' : 'Normal'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Filtering">
              <Button
                selected={scrubber.filter_co2}
                onClick={() =>
                  act('command', {
                    cmd: 'co2_scrub',
                    val: !scrubber.filter_co2,
                    id_tag: scrubber.id_tag,
                  })
                }
              >
                Carbon Dioxide
              </Button>
              <Button
                selected={scrubber.filter_toxins}
                onClick={() =>
                  act('command', {
                    cmd: 'tox_scrub',
                    val: !scrubber.filter_toxins,
                    id_tag: scrubber.id_tag,
                  })
                }
              >
                Plasma
              </Button>
              <Button
                selected={scrubber.filter_n2o}
                onClick={() =>
                  act('command', {
                    cmd: 'n2o_scrub',
                    val: !scrubber.filter_n2o,
                    id_tag: scrubber.id_tag,
                  })
                }
              >
                Nitrous Oxide
              </Button>
              <Button
                selected={scrubber.filter_o2}
                onClick={() =>
                  act('command', {
                    cmd: 'o2_scrub',
                    val: !scrubber.filter_o2,
                    id_tag: scrubber.id_tag,
                  })
                }
              >
                Oxygen
              </Button>
              <Button
                selected={scrubber.filter_n2}
                onClick={() =>
                  act('command', {
                    cmd: 'n2_scrub',
                    val: !scrubber.filter_n2,
                    id_tag: scrubber.id_tag,
                  })
                }
              >
                Nitrogen
              </Button>
              <Button
                selected={scrubber.filter_h2}
                onClick={() =>
                  act('command', {
                    cmd: 'h2_scrub',
                    val: !scrubber.filter_h2,
                    id_tag: scrubber.id_tag,
                  })
                }
              >
                Hydrogen
              </Button>
              <Button
                selected={scrubber.filter_h2o}
                onClick={() =>
                  act('command', {
                    cmd: 'h2o_scrub',
                    val: !scrubber.filter_h2o,
                    id_tag: scrubber.id_tag,
                  })
                }
              >
                Water Vapor
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      ))}
    </>
  );
};

const AirAlarmModesView = (_props: unknown) => {
  const { act, data } = useBackend<AirAlarmData>();
  const { modes, presets, emagged, mode, preset } = data;

  return (
    <>
      <Section title="System Mode">
        <Table>
          {Object.values(modes).map((m) => {
            if (m.emagonly && !emagged) {
              return null;
            }
            return (
              <Table.Row key={m.id}>
                <Table.Cell textAlign="right" width={1}>
                  <Button
                    selected={m.id === mode}
                    icon="cog"
                    onClick={() => act('mode', { mode: m.id })}
                  >
                    {m.name}
                  </Button>
                </Table.Cell>
                <Table.Cell>{m.desc}</Table.Cell>
              </Table.Row>
            );
          })}
        </Table>
      </Section>
      <Section title="System Presets">
        <Box italic>
          After making a selection, the system will automatically cycle in order
          to remove contaminants.
        </Box>
        <Table mt={1}>
          {presets.map((p) => (
            <Table.Row key={p.id}>
              <Table.Cell textAlign="right" width={1}>
                <Button
                  selected={p.id === preset}
                  icon="cog"
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

const AirAlarmThresholdsView = (_props: unknown) => {
  const { act, data } = useBackend<AirAlarmData>();
  const { thresholds } = data;

  return (
    <Section title="Alarm Thresholds">
      <Table>
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
              <Table.Cell key={`${t.name}-${s.env}-${s.val}`}>
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
