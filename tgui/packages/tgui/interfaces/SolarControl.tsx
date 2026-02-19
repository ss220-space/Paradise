import { useBackend } from '../backend';
import {
  Box,
  Button,
  Grid,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

type SolarControlData = {
  generated: number;
  generated_ratio: number;
  tracking_state: number;
  tracking_rate: number;
  connected_panels: number;
  connected_tracker: boolean;
  cdir: number;
  direction: string;
  rotating_direction: string;
};

export const SolarControl = (_props: unknown) => {
  const { act, data } = useBackend<SolarControlData>();
  const TRACKER_OFF = 0;
  const TRACKER_TIMED = 1;
  const TRACKER_AUTO = 2;
  const {
    generated,
    generated_ratio,
    tracking_state,
    tracking_rate,
    connected_panels,
    connected_tracker,
    cdir,
    direction,
    rotating_direction,
  } = data;
  return (
    <Window width={490} height={300}>
      <Window.Content>
        <Section
          title="Status"
          buttons={
            <Button icon="sync" onClick={() => act('refresh')}>
              Scan for new hardware
            </Button>
          }
        >
          <Grid>
            <Grid.Column>
              <LabeledList>
                <LabeledList.Item
                  label="Solar tracker"
                  color={connected_tracker ? 'good' : 'bad'}
                >
                  {connected_tracker ? 'OK' : 'N/A'}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Solar panels"
                  color={connected_panels > 0 ? 'good' : 'bad'}
                >
                  {connected_panels}
                </LabeledList.Item>
              </LabeledList>
            </Grid.Column>
            <Grid.Column size={2}>
              <LabeledList>
                <LabeledList.Item label="Power output">
                  <ProgressBar
                    ranges={{
                      good: [0.66, Infinity],
                      average: [0.33, 0.66],
                      bad: [-Infinity, 0.33],
                    }}
                    minValue={0}
                    maxValue={1}
                    value={generated_ratio}
                  >
                    {generated + ' W'}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Panel orientation">
                  {cdir}&deg; ({direction})
                </LabeledList.Item>
                <LabeledList.Item label="Tracker rotation">
                  {tracking_state === TRACKER_AUTO && <Box> Automated </Box>}
                  {tracking_state === TRACKER_TIMED && (
                    <Box>
                      {' '}
                      {tracking_rate}&deg;/h ({rotating_direction}){' '}
                    </Box>
                  )}
                  {tracking_state === TRACKER_OFF && (
                    <Box> Tracker offline </Box>
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Grid.Column>
          </Grid>
        </Section>
        <Section title="Controls">
          <LabeledList>
            <LabeledList.Item label="Panel orientation">
              {tracking_state !== TRACKER_AUTO && (
                <NumberInput
                  unit="°"
                  step={1}
                  stepPixelSize={1}
                  minValue={0}
                  maxValue={359}
                  value={cdir}
                  onDrag={(cdir) => act('cdir', { cdir })}
                />
              )}
              {tracking_state === TRACKER_AUTO && (
                <Box lineHeight="19px"> Automated </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Tracker status">
              <Button
                icon="times"
                selected={tracking_state === TRACKER_OFF}
                onClick={() => act('track', { track: TRACKER_OFF })}
              >
                Off
              </Button>
              <Button
                icon="clock-o"
                selected={tracking_state === TRACKER_TIMED}
                onClick={() => act('track', { track: TRACKER_TIMED })}
              >
                Timed
              </Button>
              <Button
                icon="sync"
                selected={tracking_state === TRACKER_AUTO}
                disabled={!connected_tracker}
                onClick={() => act('track', { track: TRACKER_AUTO })}
              >
                Auto
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Tracker rotation">
              {tracking_state === TRACKER_TIMED && (
                <NumberInput
                  unit="°/h"
                  step={1}
                  stepPixelSize={1}
                  minValue={-7200}
                  maxValue={7200}
                  value={tracking_rate}
                  format={(tracking_rate) => {
                    const sign = Math.sign(tracking_rate) > 0 ? '+' : '-';
                    return sign + Math.abs(tracking_rate);
                  }}
                  onDrag={(tdir) => act('tdir', { tdir })}
                />
              )}
              {tracking_state === TRACKER_OFF && (
                <Box lineHeight="19px"> Tracker offline </Box>
              )}
              {tracking_state === TRACKER_AUTO && (
                <Box lineHeight="19px"> Automated </Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
