import { useBackend } from '../backend';
import { Button, LabeledList, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

type DisposalBinData = {
  mode: number;
  pressure: number;
  isAI: boolean;
  panel_open: boolean;
  flushing: boolean;
};

export const DisposalBin = (props: unknown) => {
  const { act, data } = useBackend<DisposalBinData>();
  let stateColor: string;
  let stateText: string;
  if (data.mode === 2) {
    stateColor = 'good';
    stateText = 'Ready';
  } else if (data.mode <= 0) {
    stateColor = 'bad';
    stateText = 'N/A';
  } else if (data.mode === 1) {
    stateColor = 'average';
    stateText = 'Pressurizing';
  } else {
    stateColor = 'average';
    stateText = 'Idle';
  }
  return (
    <Window width={300} height={260}>
      <Window.Content>
        <Section title="Status">
          <LabeledList>
            <LabeledList.Item label="State" color={stateColor}>
              {stateText}
            </LabeledList.Item>
            <LabeledList.Item label="Pressure">
              <ProgressBar
                ranges={{
                  bad: [-Infinity, 0],
                  average: [0, 99],
                  good: [99, Infinity],
                }}
                value={data.pressure}
                minValue={0}
                maxValue={100}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Controls">
          <LabeledList>
            <LabeledList.Item label="Handle">
              <Button
                icon="toggle-off"
                disabled={data.isAI || data.panel_open}
                selected={!data.flushing}
                onClick={() => act('disengageHandle')}
              >
                Disengaged
              </Button>
              <Button
                icon="toggle-on"
                disabled={data.isAI || data.panel_open}
                selected={data.flushing}
                onClick={() => act('engageHandle')}
              >
                Engaged
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Power">
              <Button
                icon="toggle-off"
                disabled={data.mode === -1}
                selected={!data.mode}
                onClick={() => act('pumpOff')}
              >
                Off
              </Button>
              <Button
                icon="toggle-on"
                disabled={data.mode === -1}
                selected={!!data.mode}
                onClick={() => act('pumpOn')}
              >
                On
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Eject">
              <Button
                icon="sign-out-alt"
                disabled={data.isAI}
                onClick={() => act('eject')}
              >
                Eject Contents
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
