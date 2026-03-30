import { Button, LabeledList, NumberInput, Section } from 'tgui/components';

import { useBackend } from '../../backend';
import { GASES } from '../../constants';
import { BooleanLike } from 'common/react';
import { ReactNode } from 'react';

export interface AtmosMachine {
  name: string;
  machine_type: string;
  uid: string;
  power: BooleanLike;
}

export const AtmosMachineView = (props: AtmosMachine): ReactNode => {
  const { machine_type } = props;
  switch (machine_type) {
    case 'AVP':
      return <VentPumpView {...(props as VentPump)} />;

    case 'AScr':
      return <ScrubbersView {...(props as Scrubber)} />;

    case 'AO':
      return <InletView {...(props as Inlet)} />;

    case 'ADVP':
      return <DpVentPumpView {...(props as DpVentPump)} />;

    case 'AGP':
      return <PassiveGateView {...(props as PassiveGate)} />;

    case 'APV':
      return <VolumePumpView {...(props as VolumePump)} />;
    default:
      return null;
  }
};

type Inlet = {
  volume_rate: number;
} & AtmosMachine;

type PassiveGate = {
  target_output: number;
} & AtmosMachine;

type VolumePump = {
  transfer_rate: number;
} & AtmosMachine;

type Scrubber = {
  scrubbing: BooleanLike;
  widenet: BooleanLike;
  filter: number;
} & AtmosMachine;

type VentPump = {
  checks: number;
  direction: string;
  external: number;
  internal: number;
} & AtmosMachine;

type DpVentPump = {
  checks: number;
  direction: string;
  input: number;
  output: number;
  external: number;
} & AtmosMachine;

const InletView = (props: Inlet) => {
  const { name, power, uid, volume_rate } = props;
  const { act } = useBackend();

  return (
    <Section title={name} key={uid}>
      <LabeledList>
        <LabeledList.Item label="Power">
          <Button
            icon={power ? 'power-off' : 'power-off'}
            color={power ? null : 'red'}
            selected={power}
            onClick={() =>
              act('command', {
                cmd: 'power_toggle',
                uid: uid,
              })
            }
          >
            {power ? 'On' : 'Off'}
          </Button>
          <Button
            onClick={() =>
              act('command', {
                cmd: 'inject',
                uid: uid,
              })
            }
          >
            Inject
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
            value={volume_rate}
            onChange={(value) =>
              act('command', {
                cmd: 'set_volume_rate',
                uid: uid,
                val: value,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const PassiveGateView = (props: PassiveGate) => {
  const { name, power, uid, target_output } = props;
  const { act } = useBackend();

  return (
    <Section title={name} key={uid}>
      <LabeledList>
        <LabeledList.Item label="Power">
          <Button
            icon={power ? 'power-off' : 'power-off'}
            color={power ? null : 'red'}
            selected={power}
            onClick={() =>
              act('command', {
                cmd: 'power_toggle',
                uid: uid,
              })
            }
          >
            {power ? 'On' : 'Off'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Output Pressure Target">
          <NumberInput
            animated
            unit={'kPa'}
            width={6.1}
            lineHeight={1.5}
            step={10}
            minValue={0}
            maxValue={5066}
            value={target_output}
            onChange={(value) =>
              act('command', {
                cmd: 'set_output_pressure',
                uid: uid,
                val: value,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const VolumePumpView = (props: VolumePump) => {
  const { name, power, uid, transfer_rate } = props;
  const { act } = useBackend();

  return (
    <Section title={name} key={uid}>
      <LabeledList>
        <LabeledList.Item label="Power">
          <Button
            icon={power ? 'power-off' : 'power-off'}
            color={power ? null : 'red'}
            selected={power}
            onClick={() =>
              act('command', {
                cmd: 'power_toggle',
                uid: uid,
              })
            }
          >
            {power ? 'On' : 'Off'}
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
            value={transfer_rate}
            onChange={(value) =>
              act('command', {
                cmd: 'set_transfer_rate',
                uid: uid,
                val: value,
              })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const DpVentPumpView = (props: DpVentPump) => {
  const { name, power, uid, checks, direction, input, output, external } =
    props;
  const { act } = useBackend();

  return (
    <Section title={name} key={uid}>
      <LabeledList>
        <LabeledList.Item label="Status">
          <Button
            icon={power ? 'power-off' : 'power-off'}
            color={power ? null : 'red'}
            selected={power}
            onClick={() =>
              act('command', {
                cmd: 'power_toggle',
                uid: uid,
              })
            }
          >
            {power ? 'On' : 'Off'}
          </Button>
          <Button
            icon={direction === 'release' ? 'sign-out-alt' : 'sign-in-alt'}
            onClick={() =>
              act('command', {
                cmd: 'direction',
                val: direction === 'release' ? 0 : 1,
                uid: uid,
              })
            }
          >
            {direction === 'release' ? 'Blowing' : 'Siphoning'}
          </Button>
        </LabeledList.Item>

        <LabeledList.Item label="Pressure Checks">
          <Button
            selected={checks === 1}
            onClick={() =>
              act('command', {
                cmd: 'checks',
                uid: uid,
                val: 1,
              })
            }
          >
            External
          </Button>
          <Button
            selected={checks === 2}
            onClick={() =>
              act('command', {
                cmd: 'checks',
                uid: uid,
                val: 2,
              })
            }
          >
            Internal
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="External Pressure Target">
          <NumberInput
            animated
            unit={'kPa'}
            width={6.1}
            lineHeight={1.5}
            step={10}
            minValue={0}
            maxValue={5066}
            value={external}
            onChange={(value) =>
              act('command', {
                cmd: 'set_external_pressure',
                uid: uid,
                val: value,
              })
            }
          />
          <Button
            icon="redo-alt"
            onClick={() =>
              act('command', {
                cmd: 'set_external_pressure',
                val: 101.325,
                uid: uid,
              })
            }
          >
            Reset
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Input Pressure Target">
          <NumberInput
            animated
            unit={'kPa'}
            width={6.1}
            lineHeight={1.5}
            step={10}
            minValue={0}
            maxValue={5066}
            value={input}
            onChange={(value) =>
              act('command', {
                cmd: 'set_input_pressure',
                uid: uid,
                val: value,
              })
            }
          />
          <Button
            icon="redo-alt"
            onClick={() =>
              act('command', {
                cmd: 'set_input_pressure',
                val: 101.325,
                uid: uid,
              })
            }
          >
            Reset
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Output Pressure Target">
          <NumberInput
            animated
            unit={'kPa'}
            width={6.1}
            lineHeight={1.5}
            step={10}
            minValue={0}
            maxValue={5066}
            value={output}
            onChange={(value) =>
              act('command', {
                cmd: 'set_output_pressure',
                uid: uid,
                val: value,
              })
            }
          />
          <Button
            icon="redo-alt"
            onClick={() =>
              act('command', {
                cmd: 'set_output_pressure',
                val: 101.325,
                uid: uid,
              })
            }
          >
            Reset
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const VentPumpView = (props: VentPump) => {
  const { name, power, uid, checks, direction, internal, external } = props;
  const { act } = useBackend();

  return (
    <Section title={name} key={uid}>
      <LabeledList>
        <LabeledList.Item label="Status">
          <Button
            icon={power ? 'power-off' : 'power-off'}
            color={power ? null : 'red'}
            selected={power}
            onClick={() =>
              act('command', {
                cmd: 'power_toggle',
                uid: uid,
              })
            }
          >
            {power ? 'On' : 'Off'}
          </Button>
          <Button
            icon={direction === 'release' ? 'sign-out-alt' : 'sign-in-alt'}
            onClick={() =>
              act('command', {
                cmd: 'direction',
                val: direction === 'release' ? 0 : 1,
                uid: uid,
              })
            }
          >
            {direction === 'release' ? 'Blowing' : 'Siphoning'}
          </Button>
        </LabeledList.Item>

        <LabeledList.Item label="Pressure Checks">
          <Button
            selected={checks === 1}
            onClick={() =>
              act('command', {
                cmd: 'checks',
                uid: uid,
                val: 1,
              })
            }
          >
            External
          </Button>
          <Button
            selected={checks === 2}
            onClick={() =>
              act('command', {
                cmd: 'checks',
                uid: uid,
                val: 2,
              })
            }
          >
            Internal
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="External Pressure Target">
          <NumberInput
            animated
            unit={'kPa'}
            width={6.1}
            lineHeight={1.5}
            step={10}
            minValue={0}
            maxValue={5066}
            value={external}
            onChange={(value) =>
              act('command', {
                cmd: 'set_external_pressure',
                uid: uid,
                val: value,
              })
            }
          />
          <Button
            icon="redo-alt"
            onClick={() =>
              act('command', {
                cmd: 'set_external_pressure',
                val: 101.325,
                uid: uid,
              })
            }
          >
            Reset
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Internal Pressure Target">
          <NumberInput
            animated
            unit={'kPa'}
            width={6.1}
            lineHeight={1.5}
            step={10}
            minValue={0}
            maxValue={5066}
            value={internal}
            onChange={(value) =>
              act('command', {
                cmd: 'set_internal_pressure',
                uid: uid,
                val: value,
              })
            }
          />
          <Button
            icon="redo-alt"
            onClick={() =>
              act('command', {
                cmd: 'set_internal_pressure',
                val: 101.325,
                uid: uid,
              })
            }
          >
            Reset
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ScrubbersView = (props: Scrubber) => {
  const { name, power, uid, scrubbing, widenet, filter } = props;
  const { act } = useBackend();

  return (
    <Section title={name} key={name}>
      <LabeledList>
        <LabeledList.Item label="Status">
          <Button
            selected={power}
            icon="power-off"
            onClick={() =>
              act('command', {
                cmd: 'power_toggle',
                uid: uid,
              })
            }
          >
            {power ? 'On' : 'Off'}
          </Button>
          <Button
            icon={scrubbing ? 'filter' : 'sign-in-alt'}
            onClick={() =>
              act('command', {
                cmd: 'toggle_scrubbing',
                uid: uid,
              })
            }
          >
            {scrubbing ? 'Scrubbing' : 'Siphoning'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Range">
          <Button
            selected={widenet}
            icon="expand-arrows-alt"
            onClick={() =>
              act('command', {
                cmd: 'toggle_widenet',
                uid: uid,
              })
            }
          >
            {widenet ? 'Extended' : 'Normal'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Filtering">
          {GASES.map((item) => {
            return (
              <Button
                key={item.id}
                selected={filter & item.scrubFlag}
                onClick={() =>
                  act('command', {
                    cmd: 'scrub',
                    val: item.scrubFlag,
                    uid: uid,
                  })
                }
              >
                {item.label}
              </Button>
            );
          })}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
