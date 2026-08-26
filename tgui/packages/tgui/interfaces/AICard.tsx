import { useBackend } from '../backend';
import {
  Button,
  ProgressBar,
  LabeledList,
  Box,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type AiCartData = {
  has_ai: boolean;
} & AiData;

export type AiData = {
  integrity: number;
  name: string;
  flushing: boolean;
  has_laws: boolean;
  wireless: boolean;
  radio: boolean;
  laws: string[];
};

export const AICard = (props: unknown) => {
  const { act, data } = useBackend<AiCartData>();
  if (!data.has_ai) {
    return (
      <Window width={250} height={120}>
        <Window.Content>
          <Section title="Stored AI">
            <Box>
              <h3>No AI detected.</h3>
            </Box>
          </Section>
        </Window.Content>
      </Window>
    );
  } else {
    let integrityColor = null; // Handles changing color of the integrity bar
    if (data.integrity >= 75) {
      integrityColor = 'green';
    } else if (data.integrity >= 25) {
      integrityColor = 'yellow';
    } else {
      integrityColor = 'red';
    }

    return (
      <Window width={600} height={420}>
        <Window.Content scrollable>
          <Stack fill vertical>
            <Stack.Item>
              <Section title={data.name}>
                <LabeledList>
                  <LabeledList.Item label="Integrity">
                    <ProgressBar
                      color={integrityColor}
                      value={data.integrity / 100}
                    />
                  </LabeledList.Item>
                </LabeledList>
                <Box color="red">
                  <h2>{data.flushing ? 'Wipe of AI in progress...' : ''}</h2>
                </Box>
              </Section>
            </Stack.Item>
            <Stack.Item grow>
              <Section fill scrollable title="Laws">
                {(!!data.has_laws && (
                  <Box>
                    {data.laws.map((value, key) => (
                      <Box key={key}>{value}</Box>
                    ))}
                  </Box>
                )) || ( // Else, no laws.
                  <Box color="red">
                    <h3>No laws detected.</h3>
                  </Box>
                )}
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section title="Actions">
                <LabeledList>
                  <LabeledList.Item label="Wireless Activity">
                    <Button
                      width={10}
                      icon={data.wireless ? 'check' : 'times'}
                      color={data.wireless ? 'green' : 'red'}
                      onClick={() => act('wireless')}
                    >
                      {data.wireless ? 'Enabled' : 'Disabled'}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Subspace Transceiver">
                    <Button
                      width={10}
                      icon={data.radio ? 'check' : 'times'}
                      color={data.radio ? 'green' : 'red'}
                      onClick={() => act('radio')}
                    >
                      {data.radio ? 'Enabled' : 'Disabled'}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Wipe">
                    <Button.Confirm
                      width={10}
                      icon="trash-alt"
                      confirmIcon="trash-alt"
                      disabled={data.flushing || data.integrity === 0}
                      confirmColor="red"
                      onClick={() => act('wipe')}
                    >
                      Wipe AI
                    </Button.Confirm>
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
};
