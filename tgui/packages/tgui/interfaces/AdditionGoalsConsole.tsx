import { ReactNode } from 'react';
import { useBackend } from '../backend';
import { declension_ru } from 'common/string';
import {
  Button,
  LabeledList,
  Section,
  Stack,
  NumberInput,
  Dimmer,
  Icon,
  Box,
  Modal,
  ByondUi,
  Dropdown,
} from '../components';
import { classes } from 'common/react';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

type AdditionGoalsConsoleData = {
  state: number;
  shuttle_loc: string;
  refresh_available: boolean;
  available_goals: AvailableAdditionGoalData[];
  current_goal: AvailableAdditionGoalData;
};

type AvailableAdditionGoalData = {
  id: string;
  name: string;
};

export const AdditionGoalsConsole = (props: unknown) => {
  const { act, data } = useBackend<AdditionGoalsConsoleData>();

  let contentBlock: ReactNode;
  if (data.state === 10) {
    contentBlock = <AvailableAdditionGoalsListBlock />;
  } else if (data.state === 11 || data.state === 20 || data.state === 21) {
    contentBlock = <CurrentAdditionGoalBlock />;
  } else {
    contentBlock = (
      <Box>
        <h3>Нет данных!</h3>
      </Box>
    );
  }
  return (
    <Window width={600} height={800}>
      <Window.Content>
        <ComplexModal />
        <Stack fill vertical>
          <Stack.Item>
            <AdditionGoalsStateBlock />
          </Stack.Item>
          <Stack.Item grow>{contentBlock}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const getStateText = (s) => {
  if (s === 10) {
    return 'Нет текущей цели.';
  }
  if (s === 11) {
    return 'Шаттл в пути.';
  }
  if (s === 20) {
    return 'Цель в процессе выполнения.';
  }
  if (s === 21) {
    return 'Завершение цели.';
  }
  return 'Дополнительные цели смены недоступны.';
};

const AdditionGoalsStateBlock = (props: unknown) => {
  const { act, data } = useBackend<AdditionGoalsConsoleData>();
  return (
    <Section title="Состояние">
      <Box>
        <LabeledList>
          <LabeledList.Item label="Состояние">
            {getStateText(data.state)}
          </LabeledList.Item>
          <LabeledList.Item label="Шаттл">{data.shuttle_loc}</LabeledList.Item>
        </LabeledList>
      </Box>
    </Section>
  );
};

const AvailableAdditionGoalsListBlock = (props: unknown) => {
  const { act, data } = useBackend<AdditionGoalsConsoleData>();
  const { available_goals } = data;

  return (
    <Section
      title="Доступные дополнительные цели"
      buttons={
        <Button
          icon="refresh"
          color={data.refresh_available ? 'green' : 'grey'}
          onClick={() => act('refresh_available_goals')}
        >
          Обновить список
        </Button>
      }
    >
      <Box>
        <LabeledList>
          {available_goals.map((goal) => (
            <LabeledList.Item label={goal.name} key={goal.name}>
              <Button
                icon="plus"
                color="green"
                align="center"
                onClick={() => act('accept_goal', { goal: goal.id })}
              >
                Взять в работу
              </Button>
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Box>
    </Section>
  );
};

const CurrentAdditionGoalBlock = (props: unknown) => {
  const { act, data } = useBackend<AdditionGoalsConsoleData>();
  const { current_goal } = data;

  return (
    <Section title="Текущая дополнительная цель смены">
      <Stack fill vertical>
        <Stack.Item>
          <Box>
            <b>Идентификатор:</b> {current_goal.id}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box>
            <b>Название:</b> {current_goal.name}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="check"
            color={data.state === 20 ? 'green' : 'grey'}
            width="180px"
            align="center"
            fontSize="12px"
            onClick={() => act('complete_goal')}
          >
            Завершить цель
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
