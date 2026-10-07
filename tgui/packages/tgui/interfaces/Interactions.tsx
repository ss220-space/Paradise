import { Window } from 'tgui/layouts';
import { Box, Button, Section, Stack } from 'tgui-core/components';
import { useBackend } from '../backend';

interface Data {
  partner: string;
  interactions: Interaction[];
}

interface Interaction {
  category: string;
  action: string;
  danger?: boolean;
}

interface InteractionListProps {
  title: string;
  category: string;
  interactions: Interaction[];
}

const InteractionList = (props: InteractionListProps) => {
  const { act } = useBackend<Data>();
  const { title, category, interactions } = props;
  const filtered = interactions
    .filter((i) => i.category === category)
    .sort((a, b) => (a.danger ? 1 : 0) - (b.danger ? 1 : 0));

  if (filtered.length === 0) {
    return null;
  }

  return (
    <Section title={title}>
      <Stack g={1} vertical>
        {filtered.map((interaction) => (
          <Stack.Item key={interaction.action}>
            <Button
              color={interaction.danger ? 'bad' : 'default'}
              onClick={() =>
                act('interact', { interaction: interaction.action })
              }
            >
              {interaction.action}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

export const Interactions = () => {
  const { data } = useBackend<Data>();
  const { partner, interactions } = data;
  const uniqueCategories = [
    ...new Set(interactions.map((item) => item.category)),
  ];
  return (
    <Window width={320} height={540} title={`Взаимодействие с ${partner}`}>
      <Window.Content scrollable>
        <Box textAlign="center" fontSize={1.2} bold mb={1} py={0.5}>
          {partner}
        </Box>
        {uniqueCategories.map((category) => (
          <InteractionList
            key={category}
            title={category}
            category={category}
            interactions={interactions}
          />
        ))}
      </Window.Content>
    </Window>
  );
};
