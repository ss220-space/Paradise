import { useBackend } from '../backend';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';

type IcecreamData = {
  name: string;
  beaker: boolean;
  beakerContents: Reagent[];
  machineContents: Reagent[];
  totalVolume: number;
  maxVolume: number;
};

type Reagent = {
  name: string;
  volume: number;
  id: string;
  color: string;
};

export const IcecreamMachine = (props) => {
  const { act, data } = useBackend<IcecreamData>();
  const {
    name,
    beaker,
    beakerContents = [],
    machineContents = [],
    totalVolume,
    maxVolume,
  } = data;

  return (
    <Window width={600} height={600} theme="ntos">
      <Window.Content>
        <Section title={name}>
          <Section
            title="Контейнер"
            buttons={
              <Button
                icon="eject"
                disabled={!beaker}
                onClick={() => act('eject')}
              >
                Извлечь
              </Button>
            }
          >
            {beaker ? (
              <LabeledList>
                {beakerContents.map((reagent) => (
                  <ReagentEntry
                    key={reagent.id}
                    reagent={reagent}
                    onAdd={(amount) =>
                      act('add', {
                        id: reagent.id,
                        amount: amount,
                      })
                    }
                  />
                ))}
              </LabeledList>
            ) : (
              <Box italic>
                Вставьте ёмкость с веществами, чтобы добавить их в мороженое.
              </Box>
            )}
          </Section>

          <Section title="Содержимое машины">
            <LabeledList>
              {machineContents.map((reagent) => (
                <ReagentEntry
                  key={reagent.id}
                  reagent={reagent}
                  onRemove={(amount) =>
                    act('remove', {
                      id: reagent.id,
                      amount: amount,
                    })
                  }
                />
              ))}
            </LabeledList>
            <ProgressBar
              value={totalVolume / maxVolume}
              ranges={{
                good: [0, 0.5],
                average: [0.5, 0.8],
                bad: [0.8, 1],
              }}
              mt={1}
            >
              {totalVolume}/{maxVolume} ед.
            </ProgressBar>
          </Section>

          <Section title="Наполнители">
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="wine-bottle"
                  onClick={() => act('synthcond', { type: 2 })}
                >
                  Газировка
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="glass-whiskey"
                  onClick={() => act('synthcond', { type: 3 })}
                >
                  Алкоголь
                </Button>
              </Stack.Item>
            </Stack>
          </Section>

          <Section title="Завершающие ингредиенты">
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="whiskey-glass"
                  onClick={() => act('synthcond', { type: 4 })}
                >
                  Сливки
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="glass-water"
                  onClick={() => act('synthcond', { type: 5 })}
                >
                  Вода
                </Button>
              </Stack.Item>
            </Stack>
          </Section>

          <Section title="Создать мороженое">
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="ice-cream"
                  color="good"
                  onClick={() => act('createcone')}
                >
                  В рожок
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="ice-cream"
                  color="good"
                  onClick={() => act('createcup')}
                >
                  В стаканчик
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};

const ReagentEntry = (props: {
  reagent: Reagent;
  onAdd?: (amount: number) => void;
  onRemove?: (amount: number) => void;
}) => {
  const { reagent, onAdd, onRemove } = props;

  return (
    <LabeledList.Item
      label={
        <Stack align="center">
          <Stack.Item>
            <Box
              width="16px"
              height="16px"
              backgroundColor={reagent.color || '#ffffff'}
              style={{ borderRadius: '50%' }}
            />
          </Stack.Item>
          <Stack.Item>{reagent.name}</Stack.Item>
        </Stack>
      }
    >
      <Stack align="center">
        <Stack.Item>{reagent.volume} ед.</Stack.Item>
        <Stack.Item>
          {onAdd && (
            <>
              <Button tooltip="Добавить 5 ед." onClick={() => onAdd(5)}>
                5
              </Button>
              <Button
                icon="arrow-right"
                tooltip="Добавить все"
                onClick={() => onAdd(reagent.volume)}
              />
            </>
          )}
          {onRemove && (
            <>
              <Button tooltip="Убрать 5 ед." onClick={() => onRemove(5)}>
                5
              </Button>
              <Button
                icon="arrow-left"
                tooltip="Убрать все"
                onClick={() => onRemove(reagent.volume)}
              />
            </>
          )}
        </Stack.Item>
      </Stack>
    </LabeledList.Item>
  );
};
