import { useState } from 'react';
import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Dropdown,
  Grid,
  Icon,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from '../../components';

const DEFAULT_PURPOSE = 'Перевод через RIB';

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
  targets: string[];
};

type Page = 'main' | 'transfer' | 'subscriptions' | 'about';

type PageProps = {
  setPage: (page: Page) => void;
  data: RaingorBankData;
};

// Necessary because TSX doesn't like it when some properties are not used
// (data not used on the error page)
type PageBaseProps = {
  setPage: (page: Page) => void;
};

export const pda_bank = (props: unknown) => {
  const [page, setPage] = useState<Page>('main');
  const { data } = useBackend<RaingorBankData>();

  switch (page) {
    case 'main':
      return <MainMenuPage setPage={setPage} data={data} />;
    case 'transfer':
      return <TransferMenuPage setPage={setPage} data={data} />;
    case 'subscriptions':
      return <SubscriptionsMenuPage setPage={setPage} data={data} />;
    case 'about':
      return <AboutMenuPage setPage={setPage} data={data} />;
    default:
      return <ErrorPage setPage={setPage} />;
  }
};

const MainMenuPage = ({ setPage, data }: PageProps) => {
  const { balance, transactions, name } = data;

  return (
    <Box>
      <Section
        title={
          <Box fontSize="14px" bold>
            <Icon name="wallet" mr={1} />
            Владелец счёта
          </Box>
        }
      >
        <Box>{name}</Box>
      </Section>

      <Section
        title={
          <Box fontSize="14px" bold>
            <Icon name="money-bill" mr={1} />
            Текущий баланс
          </Box>
        }
      >
        <Box fontSize="20px" bold color={balance >= 0 ? 'good' : 'bad'}>
          {balance} кредитов
        </Box>
      </Section>

      <Section
        title={
          <Box fontSize="14px" bold>
            <Icon name="bars" mr={1} />
            Меню банка
          </Box>
        }
      >
        <Stack>
          <Stack.Item grow>
            <Button fluid onClick={() => setPage('transfer')}>
              <Stack vertical align="center">
                <Stack.Item>
                  <Icon name="exchange-alt" mx="auto" size={3} />
                </Stack.Item>
                <Stack.Item>Транзакции и переводы</Stack.Item>
              </Stack>
            </Button>
          </Stack.Item>

          <Stack.Item grow>
            <Button fluid onClick={() => setPage('subscriptions')}>
              <Stack vertical align="center">
                <Stack.Item>
                  <Icon name="credit-card" mx="auto" size={3} />
                </Stack.Item>
                <Stack.Item>Подписки</Stack.Item>
              </Stack>
            </Button>
          </Stack.Item>

          <Stack.Item grow>
            <Button fluid onClick={() => setPage('about')}>
              <Stack vertical align="center">
                <Stack.Item>
                  <Icon name="info-circle" mx="auto" size={3} />
                </Stack.Item>
                <Stack.Item>О банке</Stack.Item>
              </Stack>
            </Button>
          </Stack.Item>
        </Stack>
      </Section>

      <Section
        title={
          <Box fontSize="14px" bold>
            <Icon name="history" mr={1} />
            История операций
          </Box>
        }
      >
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

const TransferMenuPage = ({ setPage, data }: PageProps) => {
  const { balance, name, targets } = data;
  const { act } = useBackend();

  const [target, setTarget] = useState<string | null>(null);
  const [amount, setAmount] = useState<number>(0);
  const [purpose, setPurpose] = useState<string>(DEFAULT_PURPOSE);

  const sendTransfer = () => {
    act('transfer', { target, amount, purpose });
  };

  // antidurak
  const error =
    amount <= 0
      ? 'Сумма должна быть больше 0'
      : amount > balance
        ? 'Недостаточно средств'
        : !target || target === name
          ? 'Выберите получателя'
          : null;

  return (
    <Box>
      <Box textAlign="center" mb={3}>
        <Button
          fluid
          style={{ fontWeight: 'bold', fontSize: '16px' }}
          onClick={() => setPage('main')}
        >
          <Icon name="step-backward" mr={1} />В меню
        </Button>
      </Box>

      <Section
        title={
          <Box fontSize="14px" bold>
            <Icon name="exchange-alt" mr={1} />
            Переводы
          </Box>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Доступный баланс">
            <Box fontSize="18px" bold color={balance >= 0 ? 'good' : 'bad'}>
              {balance} кредитов
            </Box>
          </LabeledList.Item>
        </LabeledList>

        <LabeledList>
          <LabeledList.Item label="Получатель">
            <Dropdown
              options={targets}
              selected={target}
              onSelected={(t) => setTarget(t)}
              placeholder="Выберите счёт..."
              icon="address-book"
            />
          </LabeledList.Item>

          <LabeledList.Item label="Сумма">
            <NumberInput
              maxValue={balance}
              minValue={0}
              value={amount}
              onChange={(m) => setAmount(m)}
              step={1}
              width={6}
            />
          </LabeledList.Item>
        </LabeledList>

        <Section
          title={
            <Box fontSize="14px" bold>
              <Icon name="file-alt" mr={1} />
              Назначение платежа
            </Box>
          }
        >
          <TextArea
            height="100px"
            placeholder="Введите описание платежа"
            onChange={(t) => setPurpose(t)}
            maxLength={500}
          />
        </Section>

        {error && <Box color="bad">{error}</Box>}

        <Button fluid color="good" disabled={!!error} onClick={sendTransfer}>
          <Icon name="paper-plane" mr={1} />
          Отправить перевод
        </Button>
      </Section>
    </Box>
  );
};

const SubscriptionsMenuPage = ({ setPage, data }: PageProps) => {
  const { balance, transactions, name } = data;

  return (
    <Box>
      <Box textAlign="center" mb={3}>
        <Button
          fluid
          style={{ fontWeight: 'bold', fontSize: '16px' }}
          onClick={() => setPage('main')}
        >
          <Icon name="step-backward" mr={1} />В меню
        </Button>
      </Box>
      <Box textAlign="center" mb={3}>
        На данный момент нет никаких активных систем подписок.
      </Box>
    </Box>
  );
};

const AboutMenuPage = ({ setPage, data }: PageProps) => {
  const { balance, transactions, name } = data;

  return (
    <Box>
      <Box textAlign="center" mb={3}>
        <Button
          fluid
          style={{ fontWeight: 'bold', fontSize: '16px' }}
          onClick={() => setPage('main')}
        >
          <Icon name="step-backward" mr={1} />В меню
        </Button>
      </Box>

      <Section
        title={
          <Box fontSize="16px" bold textAlign="center">
            <Icon name="university" mr={1} />О Raingor Interstellar Banking
          </Box>
        }
      >
        {/* Основной текст лора */}
        <Box fontSize="14px" mb={2} textAlign="center">
          <b>Raingor Interstellar Banking</b> — корпорация, объединившая частное
          кредитование и систему мгновенных переводов.
        </Box>

        <Box fontSize="14px" mb={2} textAlign="center">
          Основанная в 24 веке, <b>Raingor Interstellar Banking</b> стала
          ведущим игроком в сфере частного финансирования межзвёздной экономики.
          Благодаря
          <i>
            {' '}
            беспрепятственному доступу ко всем ретрансляторам блюспейс-сети,
            полученному по эксклюзивному контракту со всеми государственными
            структурами, вошедшими в соглашение об использовании кредита в
            качестве циркуляционной валюты
          </i>
          , корпорация может управлять транзакциями и капиталом{' '}
          <b>с немыслимой скоростью</b> по всей галактике.
        </Box>

        <Box fontSize="14px" mb={2} textAlign="center">
          Наши клиенты — от частных предпринимателей до межзвёздных
          исследовательских корпораций. <b>Raingor Bank</b> предоставляет
          кредиты на развитие частных колонизационных проектов, инвестирует в
          инфраструктуру планет и поддерживает финансовую экосистему новых
          миров.
        </Box>

        <Box fontSize="14px" mb={2} textAlign="center">
          Надёжность и инновации лежат в основе каждого нашего сервиса. Мы
          обеспечиваем прозрачность операций, мгновенные переводы и сохранность
          ваших средств даже в самых удалённых уголках космоса.
        </Box>

        <Section
          title={
            <Box fontSize="14px" bold color="good" textAlign="center">
              <Icon name="star" mr={1} />
              Наш слоган
            </Box>
          }
        >
          <Box fontSize="14px" italic textAlign="center">
            «Доверие, проверенное временем и звёздами»
          </Box>
        </Section>
      </Section>
    </Box>
  );
};

const ErrorPage = ({ setPage }: PageBaseProps) => {
  return (
    <Box>
      <Section title={'ОШИБКА'} />
      <Box textAlign="center" mb={3}>
        <Button
          fluid
          style={{ fontWeight: 'bold', fontSize: '16px' }}
          onClick={() => setPage('main')}
        >
          <Icon name="step-backward" mr={1} />В меню
        </Button>
      </Box>
    </Box>
  );
};
