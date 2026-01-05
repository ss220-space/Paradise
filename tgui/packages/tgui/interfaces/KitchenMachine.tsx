import { useBackend } from '../backend';
import { Box, Button, Icon, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

type KitchenMachineData = {
  name: string;
  operating: number;
  dirty: number;
  broken: number;
  cookVerb: string;
  ingredients: {
    name: string;
    amount: number;
    unit: string;
    pluralUnit: string;
  }[];
  reagents: {
    name: string;
    volume: number;
  }[];
};

export const KitchenMachine = (props) => {
  const { act, data } = useBackend<KitchenMachineData>();
  const {
    name,
    operating,
    dirty,
    broken,
    cookVerb,
    ingredients = [],
    reagents = [],
  } = data;

  if (broken === 1) {
    return (
      <Window width={400} height={250} theme="ntos">
        <Window.Content>
          <Section title={<Box color="bad">Неисправность!</Box>}>
            <Stack vertical align="center" mt={2}>
              <Icon name="triangle-exclamation" size={3} color="bad" />
              <Box fontSize={1.5} bold mt={2}>
                Сбой оборудования
              </Box>
              <Box textAlign="center" mt={1}>
                Требуется ремонт
              </Box>
            </Stack>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  if (dirty === 100) {
    return (
      <Window width={400} height={300} theme="ntos">
        <Window.Content>
          <Section title="Требуется очистка">
            <Stack vertical align="center" textAlign="center">
              <Icon name="broom" size={3} color="yellow" />
              <Box bold mt={1} fontSize={1.2}>
                {data['name']} требует очистки!
              </Box>
              <Box mt={1}>Загрязнение: {data['dirty']}%</Box>
              <Box mt={2} italic>
                Пожалуйста, очистите перед использованием.
              </Box>
            </Stack>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  if (operating === 1) {
    return (
      <Window width={400} height={300} theme="ntos">
        <Window.Content>
          <Section title={`${cookVerb}...`}>
            <Stack vertical align="center" textAlign="center">
              <Icon name="cookie-bite" size={3} spin mt={1} />
              <Box mt={2} italic>
                Блюдо готовится, ожидайте...
              </Box>
            </Stack>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window width={400} height={500} theme="ntos">
      <Window.Content>
        <Section
          title={
            <Stack align="center">
              <Stack.Item>
                <Icon name="temperature-high" />
              </Stack.Item>
              <Stack.Item grow>{name}</Stack.Item>
              <Stack.Item>
                {data['dirty'] > 0 && (
                  <Box
                    color={dirty > 70 ? 'bad' : dirty > 30 ? 'average' : 'good'}
                  >
                    <Icon name="soap" /> {dirty}%
                  </Box>
                )}
              </Stack.Item>
            </Stack>
          }
        >
          <Section
            title={
              <Stack>
                <Stack.Item>
                  <Icon name="list" />
                </Stack.Item>
                <Stack.Item>Ингредиенты</Stack.Item>
              </Stack>
            }
          >
            {ingredients.length === 0 ? (
              <Box italic>Ингредиенты не обнаружены</Box>
            ) : (
              <LabeledList>
                {ingredients.map((item, i) => (
                  <LabeledList.Item
                    key={i}
                    label={
                      <Stack>
                        <Stack.Item>{item.name}</Stack.Item>
                      </Stack>
                    }
                  >
                    {item.amount} шт.
                  </LabeledList.Item>
                ))}
              </LabeledList>
            )}
          </Section>

          <Section
            title={
              <Stack>
                <Stack.Item>
                  <Icon name="bottle-droplet" />
                </Stack.Item>
                <Stack.Item>Вещества</Stack.Item>
              </Stack>
            }
          >
            {reagents.length === 0 ? (
              <Box italic>Вещества не обнаружены</Box>
            ) : (
              <LabeledList>
                {reagents.map((reagent, i) => (
                  <LabeledList.Item
                    key={i}
                    label={
                      <Stack>
                        <Stack align="center">
                          <Stack.Item>{reagent.name}</Stack.Item>
                        </Stack>
                      </Stack>
                    }
                  >
                    {reagent.volume} ед.
                  </LabeledList.Item>
                ))}
              </LabeledList>
            )}
          </Section>
          <Stack mt={2}>
            <Stack.Item grow>
              <Button
                fluid
                icon="power-off"
                textAlign="center"
                disabled={
                  data['ingredients'].length === 0 &&
                  data['reagents'].length === 0
                }
                tooltip={
                  data['ingredients'].length === 0 &&
                  data['reagents'].length === 0
                    ? 'Сначала добавьте ингредиенты'
                    : undefined
                }
                onClick={() => act('start')}
              >
                Включить
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="eject"
                textAlign="center"
                disabled={
                  data['ingredients'].length === 0 &&
                  data['reagents'].length === 0
                }
                tooltip={
                  data['ingredients'].length === 0 &&
                  data['reagents'].length === 0
                    ? 'Нет ингредиентов'
                    : undefined
                }
                onClick={() => act('eject')}
              >
                Извлечь
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
