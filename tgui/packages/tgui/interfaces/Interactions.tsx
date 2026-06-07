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

interface InteractionListProps {
  title: string;
  category: string;
  interactions: Interaction[];
  act: (action: string) => void;
}

const InteractionList = (props: InteractionListProps) => {
  const { title, category, interactions, act } = props;
  const filtered = interactions
    .filter((i) => i.category === category)
    .sort((a, b) => (a.danger ? 1 : 0) - (b.danger ? 1 : 0));

  if (filtered.length === 0) {
    return null;
  }

  return (
    <Section title={title}>
      <Box style={{ display: 'flex', flexDirection: 'column', gap: '3px' }}>
        {interactions
          .filter((i) => i.category === category)
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
  );
};

export const Interactions = () => {
  const { act, data } = useBackend<Data>();
  const { partner, interactions } = data;
  return (
    <Window width={320} height={540} title={`Взаимодействие с ${partner}`}>
      <Window.Content scrollable>
        <Box textAlign="center" fontSize={1.2} bold mb={1} py={0.5}>
          {partner}
        </Box>
        <InteractionList
          title=""
          category=""
          interactions={interactions}
          act={act}
        />
        <InteractionList
          title="Руки"
          category="hands"
          interactions={interactions}
          act={act}
        />
        <InteractionList
          title="Губы"
          category="mouth"
          interactions={interactions}
          act={act}
        />
      </Window.Content>
    </Window>
  );
};
