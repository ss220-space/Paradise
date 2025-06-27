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
            <Box>Could not scan your card or could not find account!</Box>
            <Box>Please wear or hold your ID and try again.</Box>
          </Section>
        </Window.Content>
      </Window>
    );
  } else {
    let playerText: string;
    if (data.plays === 1) {
      playerText = data.plays + ' player has tried their luck today!';
    } else {
      playerText = data.plays + ' players have tried their luck today!';
    }
    return (
      <Window width={350} height={200}>
        <Window.Content>
          <Section>
            <Box lineHeight={2}>{playerText}</Box>
            <LabeledList>
              <LabeledList.Item label="Credits Remaining">
                <AnimatedNumber value={data.money} />
              </LabeledList.Item>
              <LabeledList.Item label="50 credits to spin">
                <Button
                  icon="coins"
                  disabled={data.working}
                  onClick={() => act('spin')}
                >
                  {data.working ? 'Spinning...' : 'Spin'}
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
