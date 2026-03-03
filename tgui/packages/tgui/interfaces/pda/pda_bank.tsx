import { useBackend } from '../../backend';
import { Box, LabeledList, Section } from '../../components';

type Transaction = {
  date: string;
  time: string;
  target_name: string;
  purpose: string;
  amount: number;
  source_terminal: string;
};

type RaingorBankData = {
  balance: number;
  transactions: Transaction[];
  name: string;
};
export const pda_bank = (props: unknown) => {
  const { data } = useBackend<RaingorBankData>();
  const { balance, transactions, name } = data;

  return (
    <Box>
      <Section title={'Владелец счёта'}>
        <Box>{name}</Box>
      </Section>

      <Section title={'Текущий баланс'}>
        <Box fontSize="20px" bold color={balance >= 0 ? 'good' : 'bad'}>
          {balance} кредитов
        </Box>
      </Section>

      <Section title={'История операций'}>
        {transactions.length === 0 && <Box italic>Операции отсутствуют.</Box>}

        {transactions.map((t, i) => (
          <Section key={i} title={`${t.date} ${t.time}`}>
            <LabeledList>
              <LabeledList.Item label="Назначение">
                {t.purpose}
              </LabeledList.Item>

              <LabeledList.Item label="Контрагент">
                {t.target_name}
              </LabeledList.Item>

              <LabeledList.Item label="Терминал">
                {t.source_terminal}
              </LabeledList.Item>

              <LabeledList.Item label="Сумма">
                <Box color={t.amount >= 0 ? 'good' : 'bad'}>
                  {t.amount} кредитов
                </Box>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ))}
      </Section>
    </Box>
  );
};
