import { useBackend } from '../backend';
import {
  Button,
  ProgressBar,
  Box,
  LabeledList,
  Section,
  Stack,
  Icon,
} from '../components';
import { Window } from '../layouts';
import { AiData } from './AICard';

type AIFixerData = { occupant: string; stat: number; active: boolean } & AiData;

export const AIFixer = (props: unknown) => {
  const { act, data } = useBackend<AIFixerData>();
  if (data.occupant === null) {
    return (
      <Window width={550} height={500}>
        <Window.Content>
          <Section fill title="Stored AI">
            <Stack fill>
              <Stack.Item
                bold
                grow
                textAlign="center"
                align="center"
                color="average"
              >
                <Icon.Stack style={{ transform: 'translate(-40px, -55px)' }}>
                  <Icon name="robot" size={5} color="silver" />
                  <Icon name="slash" size={5} color="red" />
                </Icon.Stack>
                <br />
                <h3>No Artificial Intelligence detected.</h3>
              </Stack.Item>
            </Stack>
          </Section>
        </Window.Content>
      </Window>
    );
  } else {
    let workingAI = true; // If the AI is dead (stat = 2) or isn't existent
    if (data.stat === 2 || data.stat === null) {
      workingAI = false;
    }

    let integrityColor = null; // Handles changing color of the integrity bar
    if (data.integrity >= 75) {
      integrityColor = 'green';
    } else if (data.integrity >= 25) {
      integrityColor = 'yellow';
    } else {
      integrityColor = 'red';
    }

    let repairable = true; // Is the AI repairable? (Stat 2 = dead)
    if (data.integrity >= 100 && data.stat !== 2) {
      repairable = false;
    }

    return (
      <Window>
        <Window.Content scrollable>
          <Stack fill vertical>
            <Stack.Item>
              <Section title={data.occupant}>
                <LabeledList>
                  <LabeledList.Item label="Integrity">
                    <ProgressBar
                      color={integrityColor}
                      value={data.integrity / 100}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Status"
                    color={workingAI ? 'green' : 'red'}
                  >
                    {workingAI ? 'Functional' : 'Non-Functional'}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Stack.Item>
            <Stack.Item grow>
              <Section fill scrollable title="Laws">
                {(!!data.has_laws && (
                  <Box>
                    {data.laws.map((value, key) => (
                      <Box key={key} inline>
                        {value}
                      </Box>
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
                      icon={data.wireless ? 'times' : 'check'}
                      color={data.wireless ? 'red' : 'green'}
                      onClick={() => act('wireless')}
                    >
                      {data.wireless ? 'Disabled' : 'Enabled'}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Subspace Transceiver">
                    <Button
                      icon={data.radio ? 'times' : 'check'}
                      color={data.radio ? 'red' : 'green'}
                      onClick={() => act('radio')}
                    >
                      {data.radio ? 'Disabled' : 'Enabled'}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Start Repairs">
                    <Button
                      icon="wrench"
                      disabled={!repairable || data.active}
                      onClick={() => act('fix')}
                    >
                      {!repairable || data.active
                        ? 'Already Repaired'
                        : 'Repair'}
                    </Button>
                  </LabeledList.Item>
                </LabeledList>
                <Box color="green" lineHeight={2}>
                  {data.active ? 'Reconstruction in progress.' : ''}
                </Box>
              </Section>
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
};
