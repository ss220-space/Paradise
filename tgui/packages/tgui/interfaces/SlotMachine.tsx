import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  Box,
  AnimatedNumber,
  Section,
} from '../components';
import { Window } from '../layouts';

type SlotMachineData = {
  money: number;
  plays: number;
  working: boolean;
  resultlvl: string;
  result: string;
};

export const SlotMachine = (_props: unknown) => {
  const { act, data } = useBackend<SlotMachineData>();
  if (data.money === null) {
    return (
      <Window width={350} height={200}>
        <Window.Content>
          <Section>
            <Box bold>Невозможно определить платежный аккаунт!</Box>
            <Box>
              Пожалуйста наденьте или держите в руках вашу карту и попробуйте
              заново.
            </Box>
          </Section>
        </Window.Content>
      </Window>
    );
  } else {
    return (
      <Window width={350} height={200}>
        <Window.Content>
          <Section>
            <Box lineHeight={2}>
              Игроков попытаваших удачу сегодня: {data.plays}
            </Box>
            <LabeledList>
              <LabeledList.Item label="Кредитов доступно">
                <AnimatedNumber value={data.money} />
              </LabeledList.Item>
              <LabeledList.Item label="50 кредитов для игры">
                <Button
                  icon="coins"
                  disabled={data.working}
                  onClick={() => act('spin')}
                >
                  {data.working ? 'Подождите...' : 'Крутить'}
                </Button>
              </LabeledList.Item>
            </LabeledList>
            <Box bold lineHeight={2} color={data.resultlvl}>
              {data.result}
            </Box>
          </Section>
        </Window.Content>
      </Window>
    );
  }
};
