import { useBackend } from '../backend';
import { Box, Button, Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

type FoodcartData = {
  foodSlots: {
    index: number;
    name?: string;
    icon?: string;
  }[];
  drinkSlots: {
    index: number;
    name?: string;
    icon?: string;
  }[];
};

const FoodSlot = (props: {
  index: number;
  name?: string;
  icon?: string;
  onTake: (index: number) => void;
}) => {
  const { index, name, icon, onTake } = props;

  return (
    <Stack.Item>
      <Section
        title={name || `Слот ${index}`}
        buttons={
          <Button
            icon="hand-paper"
            disabled={!name}
            onClick={() => onTake(index)}
          >
            Взять
          </Button>
        }
      >
        {icon ? (
          <Box
            as="img"
            src={`data:image/png;base64,${icon}`}
            style={{
              width: '32px',
              height: '32px',
            }}
          />
        ) : (
          <Box italic textAlign="center">
            Пусто
          </Box>
        )}
      </Section>
    </Stack.Item>
  );
};

export const FoodCart = (props) => {
  const { act, data } = useBackend<FoodcartData>();
  const { foodSlots = [], drinkSlots = [] } = data;

  return (
    <Window width={600} height={500}>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Section title="Еда">
              <Stack wrap>
                {foodSlots.map((slot) => (
                  <FoodSlot
                    key={`food-${slot.index}`}
                    index={slot.index}
                    name={slot.name}
                    icon={slot.icon}
                    onTake={(index) => act('take_food', { index })}
                  />
                ))}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section title="Напитки">
              <Stack wrap>
                {drinkSlots.map((slot) => (
                  <FoodSlot
                    key={`drink-${slot.index}`}
                    index={slot.index}
                    name={slot.name}
                    icon={slot.icon}
                    onTake={(index) => act('take_drink', { index })}
                  />
                ))}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
