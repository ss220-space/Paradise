import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';
import { Box, Stack } from '../components';

interface Data {
  partner: string;
  interactions: Interaction[];
}

interface Interaction {
  category: string;
  action: string;
  label: string;
  danger?: boolean;
}

export const Interactions = () => {
  const { act, data } = useBackend<Data>();
  const { partner, interactions } = data;
  return (
    <Window width={320} height={540} title={`Взаимодействие с ${partner}`}>
      <Window.Content scrollable>
        <Box textAlign="center" fontSize={1.2} bold mb={1} py={0.5}>
          {partner}
        </Box>
        <Section title="">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '3px' }}>
            {interactions
              .filter((i) => i.category === '')
              .sort((a, b) => (a.danger ? 1 : 0) - (b.danger ? 1 : 0))
              .map((interaction) => (
                <Stack.Item key={interaction.action}>
                  <Button
                    color={interaction.danger ? 'bad' : 'default'}
                    onClick={() => act(interaction.action)}
                  >
                    {interaction.label}
                  </Button>
                </Stack.Item>
              ))}
          </Box>
        </Section>
        <Section title="Руки">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '3px' }}>
            {interactions
              .filter((i) => i.category === 'hands')
              .sort((a, b) => (a.danger ? 1 : 0) - (b.danger ? 1 : 0))
              .map((interaction) => (
                <Stack.Item key={interaction.action}>
                  <Button
                    color={interaction.danger ? 'bad' : 'default'}
                    onClick={() => act(interaction.action)}
                  >
                    {interaction.label}
                  </Button>
                </Stack.Item>
              ))}
          </Box>
        </Section>
        <Section title="Губы">
          <Box style={{ display: 'flex', flexDirection: 'column', gap: '3px' }}>
            {interactions
              .filter((i) => i.category === 'mouth')
              .sort((a, b) => (a.danger ? 1 : 0) - (b.danger ? 1 : 0))
              .map((interaction) => (
                <Stack.Item key={interaction.action}>
                  <Button
                    color={interaction.danger ? 'bad' : 'default'}
                    onClick={() => act(interaction.action)}
                  >
                    {interaction.label}
                  </Button>
                </Stack.Item>
              ))}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
