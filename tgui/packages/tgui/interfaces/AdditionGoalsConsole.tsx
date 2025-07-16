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
  online: boolean;
  shuttle_loc: string;
};


export const AdditionGoalsConsole = (props: unknown) => {
  const { act, data } = useBackend<AdditionGoalsConsoleData>();

  if(!data.online) {
    return (
      <Window width={600} height={800}>
        <Window.Content>
          <Box textColor="red">
            Ошибка: Шаттл не обнаружен!
          </Box>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window width={600} height={800}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <LabeledList>
              <LabeledList.Item label="Местоположение шаттла">
                {data.shuttle_loc}
              </LabeledList.Item>
              <LabeledList.Item label="Вызов шаттла">
                <Button
                  icon="location-arrow"
                  color={data.online ? 'green' : 'grey'}
                  width="180px"
                  align="center"
                  onClick={() => act('call_shuttle')}
                >
                  Вызвать
                </Button>
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
