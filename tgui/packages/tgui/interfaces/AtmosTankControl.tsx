import {
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from '../components';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { getGasColor, getGasLabel } from '../constants';
import { Window } from '../layouts';

type GasType = 'o2' | 'n2' | 'plasma' | 'co2' | 'n2o' | 'h2' | 'h2o';

type SensorData = {
  pressure?: number;
  temperature?: number;
  [key: string]: number | undefined;
};

type InletData = {
  uid: string;
  name: string;
  on: boolean;
  rate: number;
};

type VentOutletData = {
  uid: string;
  name: string;
  on: boolean;
  checks: number;
  rate: number;
};

type ScrubberOutletData = {
  id_tag: string;
  name: string;
  power: boolean;
  scrubbing: boolean;
  widenet: boolean;
  filter_co2: boolean;
  filter_toxins: boolean;
  filter_n2o: boolean;
  filter_o2: boolean;
  filter_n2: boolean;
  filter_h2: boolean;
  filter_h2o: boolean;
};

type AtmosTankControlData = {
  sensors: Record<string, SensorData>;
  inlets: InletData[];
  vent_outlets: VentOutletData[];
  scrubber_outlets: ScrubberOutletData[];
};

export const AtmosTankControl = (props: unknown) => {
  const { act, data } = useBackend<AtmosTankControlData>();

  const {
    sensors = {},
    inlets = [],
    vent_outlets = [],
    scrubber_outlets = [],
  } = data;

  const gasesToShow: GasType[] = [
    'o2',
    'n2',
    'plasma',
    'co2',
    'n2o',
    'h2',
    'h2o',
  ];

  return (
    <Window width={400} height={435}>
      <Window.Content scrollable>
        {Object.keys(sensors).map((sensorName) => (
          <Section key={sensorName} title={sensorName}>
            <LabeledList>
              {sensors[sensorName].pressure !== undefined && (
                <LabeledList.Item label="Pressure">
                  {sensors[sensorName].pressure} kpa
                </LabeledList.Item>
              )}

              {sensors[sensorName].temperature !== undefined && (
                <LabeledList.Item label="Temperature">
                  {sensors[sensorName].temperature} K
                </LabeledList.Item>
              )}

              {gasesToShow.map((gas) =>
                sensors[sensorName][gas] !== undefined ? (
                  <LabeledList.Item key={gas} label={getGasLabel(gas)}>
                    <ProgressBar
                      color={getGasColor(gas)}
                      value={sensors[sensorName][gas] || 0}
                      minValue={0}
                      maxValue={100}
                    >
                      {toFixed(sensors[sensorName][gas] || 0, 2) + '%'}
                    </ProgressBar>
                  </LabeledList.Item>
                ) : null
              )}
            </LabeledList>
          </Section>
        ))}

        <Section title="Inlets">
          {inlets.length > 0
            ? inlets.map((inlet) => (
                <Section title={inlet.name} key={inlet.uid}>
                  <LabeledList>
                    <LabeledList.Item label="Power">
                      <Button
                        icon="power-off"
                        color={inlet.on ? undefined : 'red'}
                        selected={inlet.on}
                        onClick={() =>
                          act('toggle_inlet_active', { dev: inlet.uid })
                        }
                      >
                        {inlet.on ? 'On' : 'Off'}
                      </Button>
                    </LabeledList.Item>

                    <LabeledList.Item label="Rate">
                      <NumberInput
                        animated
                        unit={'L/s'}
                        width={6.1}
                        lineHeight={1.5}
                        step={1}
                        minValue={0}
                        maxValue={50}
                        value={inlet.rate}
                        onChange={(value) =>
                          act('set_inlet_volume_rate', {
                            dev: inlet.uid,
                            val: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              ))
            : 'No inlets found'}
        </Section>

        <Section title="Outlets">
          {vent_outlets.length > 0
            ? vent_outlets.map((outlet) => (
                <Section title={`Outlet: ${outlet.name}`} key={outlet.uid}>
                  <LabeledList>
                    <LabeledList.Item label="Status">
                      <Button
                        icon="power-off"
                        color={outlet.on ? undefined : 'red'}
                        selected={outlet.on}
                        onClick={() =>
                          act('toggle_outlet_active', { dev: outlet.uid })
                        }
                      >
                        {outlet.on ? 'On' : 'Off'}
                      </Button>
                    </LabeledList.Item>

                    <LabeledList.Item label="Pressure Checks">
                      <Button
                        selected={outlet.checks === 1}
                        onClick={() =>
                          act('set_outlet_reference', {
                            dev: outlet.uid,
                            val: 1,
                          })
                        }
                      >
                        External
                      </Button>
                      <Button
                        selected={outlet.checks === 2}
                        onClick={() =>
                          act('set_outlet_reference', {
                            dev: outlet.uid,
                            val: 2,
                          })
                        }
                      >
                        Internal
                      </Button>
                    </LabeledList.Item>

                    <LabeledList.Item label="Rate">
                      <NumberInput
                        animated
                        unit={'kPa'}
                        width={6.1}
                        lineHeight={1.5}
                        step={10}
                        minValue={0}
                        maxValue={5066}
                        value={outlet.rate}
                        onChange={(value) =>
                          act('set_outlet_pressure', {
                            dev: outlet.uid,
                            val: value,
                          })
                        }
                      />
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              ))
            : 'No vent outlets found'}

          {scrubber_outlets.length > 0 && <TankControlScrubbersView />}
        </Section>
      </Window.Content>
    </Window>
  );
};

const TankControlScrubbersView = (props: unknown) => {
  const { act, data } = useBackend<AtmosTankControlData>();

  return (
    <>
      {data.scrubber_outlets.map((scrubber) => (
        <Section title={`Outlet: ${scrubber.name}`} key={scrubber.id_tag}>
          <LabeledList>
            <LabeledList.Item label="Status">
              <Button
                selected={scrubber.power}
                icon="power-off"
                onClick={() =>
                  act('command', {
                    cmd: 'power',
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
