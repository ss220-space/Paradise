import { useBackend } from '../../backend';
import { Box, Section } from '../../components';

type RaingorBankData = {
  balance: number;
  transactions: { id: number; description: string; amount: number }[];
};

export const pda_bank = (props: unknown) => {
  const { act, data } = useBackend<RaingorBankData>();

  const { balance, transactions } = data;

  return (
    <Box>
      <Section>Hello</Section>
    </Box>
  );
};
