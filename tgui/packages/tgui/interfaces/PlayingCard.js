import { useBackend } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';

export const PlayingCard = (properties, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window width={250} height={350} theme="cardtable" title="Карты в руке">
      <Window.Content scrollable>
        <Section>
          <Stack vertical>
            {data.cards.map((card, index) => (
              <Stack.Item key={index}>
                <Button
                  width="100%"
                  onClick={() => act('pick', { card: card })}
                >
                  {card}
                </Button>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
        <Box>
          <Button color="good" onClick={() => act('turn')}>
            Перевернуть карты
          </Button>
        </Box>
      </Window.Content>
    </Window>
  );
};
