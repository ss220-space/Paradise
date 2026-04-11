import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  Icon,
  Knob,
  LabeledControls,
  LabeledList,
  Section,
  Stack,
  Tooltip,
} from '../components';
import { formatSiUnit } from '../format';
import { Window } from '../layouts';

type CanisterData = {
  portConnected: boolean;
  tankPressure: number;
  releasePressure: number;
  defaultReleasePressure: number;
  minReleasePressure: number;
  maxReleasePressure: number;
  valveOpen: boolean;
  name: string;
  canLabel: boolean;
  hasHoldingTank: boolean;
  holdingTank: HoldingTank;
};

type HoldingTank = {
  name: string;
  tankPressure: number;
};

export const Canister = (_props: unknown) => {
  const { act, data } = useBackend<CanisterData>();
  const {
    portConnected,
    tankPressure,
    releasePressure,
    defaultReleasePressure,
    minReleasePressure,
    maxReleasePressure,
    valveOpen,
    name,
    canLabel,
    hasHoldingTank,
    holdingTank,
  } = data;

  return (
    <Window width={600} height={230}>
      <Window.Content>
        <Section
          title={name}
          buttons={
            <Stack>
              <Stack.Item>
                <Button
                  icon="pencil-alt"
                  disabled={!canLabel}
                  onClick={() => act('relabel')}
                >
                  Relabel
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  icon="palette"
                  disabled={!canLabel}
                  onClick={() => act('select_color')}
                />
              </Stack.Item>
            </Stack>
          }
        >
          <LabeledControls>
            <LabeledControls.Item minWidth="66px" label="Pressure">
              <AnimatedNumber
                value={tankPressure}
                format={(value) => {
                  if (value < 10000) {
                    return toFixed(value) + ' kPa';
                  }
                  return formatSiUnit(value * 1000, 1, 'Pa');
                }}
              />
            </LabeledControls.Item>
            <LabeledControls.Item label="Regulator">
              <Box position="relative" left="-8px">
                <Knob
                  size={1.25}
                  color={!!valveOpen && 'yellow'}
                  value={releasePressure}
                  unit="kPa"
                  minValue={minReleasePressure}
                  maxValue={maxReleasePressure}
                  tickWhileDragging
                  step={5}
                  stepPixelSize={1}
                  onChange={(e, value) =>
                    act('pressure', {
                      pressure: value,
                    })
                  }
                />
                <Button
                  fluid
                  position="absolute"
                  top="-2px"
                  right="-20px"
                  color="transparent"
                  icon="fast-forward"
                  tooltip="Max Release Pressure"
                  onClick={() =>
                    act('pressure', {
                      pressure: maxReleasePressure,
                    })
                  }
                />
                <Button
                  fluid
                  position="absolute"
                  top="16px"
                  right="-20px"
                  color="transparent"
                  icon="undo"
                  tooltip="Reset Release Pressure"
                  onClick={() =>
                    act('pressure', {
                      pressure: defaultReleasePressure,
                    })
                  }
                />
              </Box>
            </LabeledControls.Item>
            <LabeledControls.Item label="Valve">
              <Button
                my={0.5}
                width="50px"
                lineHeight={2}
                fontSize="11px"
                color={
                  valveOpen ? (hasHoldingTank ? 'caution' : 'danger') : null
                }
                onClick={() => act('valve')}
              >
                {valveOpen ? 'Open' : 'Closed'}
              </Button>
            </LabeledControls.Item>
            <LabeledControls.Item mr={1} label="Port">
              <Tooltip
                content={portConnected ? 'Connected' : 'Disconnected'}
                position="top"
              >
                <Box position="relative">
                  <Icon
                    size={1.25}
                    name={portConnected ? 'plug' : 'times'}
                    color={portConnected ? 'good' : 'bad'}
                  />
                </Box>
              </Tooltip>
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
        <Section
          title="Holding Tank"
          buttons={
            !!hasHoldingTank && (
              <Button icon="eject" onClick={() => act('eject')}>
                Eject
              </Button>
            )
          }
        >
          {!!hasHoldingTank && (
            <LabeledList>
              <LabeledList.Item label="Label">
                {holdingTank.name}
              </LabeledList.Item>
              <LabeledList.Item label="Pressure">
                <AnimatedNumber value={holdingTank.tankPressure} /> kPa
              </LabeledList.Item>
            </LabeledList>
          )}
          {!hasHoldingTank && <Box color="average">No Holding Tank</Box>}
        </Section>
      </Window.Content>
    </Window>
  );
};
