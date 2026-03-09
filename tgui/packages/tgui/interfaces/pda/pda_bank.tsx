import { useState } from 'react';
import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from '../../components';

import { Window } from '../../layouts';

const DEFAULT_PURPOSE = 'Перевод через RIB';

type Transaction = {
  date: string;
  time: string;
  target_name: string;
  purpose: string;
  amount: number;
  source_terminal: string;
};

type Subscription = {
  subscription_name: string;
  recipient_name: string;
  cost: number;
  interval: number;
  status: boolean;
  description: string;
  secure: boolean;
};

type AvailableSubscription = {
  available_subscription_name: string;
  description: string;
  cost: number;
  interval: number;
  provider: string;
};

type RaingorBankData = {
  balance: number;
  transactions: Transaction[];
  name: string;
  targets: string[];

  subscriptions: Subscription[];
  availableSubs: AvailableSubscription[];

  loginState: LoginState;
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
  const { loginState } = data;

  if (!loginState.logged_in) {
    return (
      <Window width={600} height={650}>
        <Window.Content>
          <Stack fill vertical>
            <Section
              title={
                <Box fontSize="22px" bold textAlign="center">
                  <Icon name="university" color="blue" mr={1} />
                  Raingor Interstellar Banking
                </Box>
              }
            >
              <Box fontSize="20px" bold mb={1} textAlign="center">
                {data?.name && data.name !== '' && data.name !== 'unknown'
                  ? `Добрый день, ${data.name}!`
                  : 'Добро пожаловать'}
              </Box>
              <Stack fill vertical align="center" justify="center">
                <Box textAlign="center" color="label" fontSize="18px" bold>
                  Для доступа к банковским операциям
                  <br />
                  вставьте ID-карту в слот КПК.
                </Box>
              </Stack>
            </Section>
          </Stack>
        </Window.Content>
      </Window>
    );
  }
  let PageContent;
  switch (page) {
    case 'main':
      PageContent = <UMainMenuPage setPage={setPage} data={data} />;
      break;
    case 'transfer':
      PageContent = <TransferMenuPage setPage={setPage} data={data} />;
      break;
    case 'subscriptions':
      PageContent = <SubscriptionsMenuPage setPage={setPage} data={data} />;
      break;
    case 'about':
      PageContent = <AboutMenuPage setPage={setPage} data={data} />;
      break;
    default:
      PageContent = <ErrorPage setPage={setPage} />;
  }
  return (
    <Window width={600} height={650}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Section fill scrollable>
            {PageContent}
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MainMenuPage = ({ setPage, data }: PageProps) => {
  const { balance, transactions, name } = data;
  const { act } = useBackend();
  const handleLogout = () => {
    act('login_logout');
  };

  return (
    <Box>
      <Box textAlign="center" mb={3}>
        <Button
          fluid
          style={{ fontWeight: 'bold', fontSize: '16px' }}
          onClick={handleLogout}
        >
          <Icon name="step-backward" mr={1} /> Выйти с аккаунта
        </Button>
        <Box color="bad" fontSize={0.85} mt={1} textAlign="center">
          <Icon name="exclamation-triangle" mr={0.5} />
          Для выхода из аккаунта сначала извлеките ID-карту из КПК
        </Box>
      </Box>

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

// Update design
const UMainMenuPage = ({ setPage, data }: PageProps) => {
  const { balance, transactions, name } = data;
  const { act } = useBackend();

  const handleLogout = () => {
    act('login_logout');
  };

  return (
    <Box>
      <Section
        fill
        mb={2}
        style={{
          background:
            'linear-gradient(135deg, #722F37 0%, #800020 50%, #9B2335 100%)',
          borderRadius: '8px',
          border: '2px solid #B8860B',
        }}
      >
        <Stack vertical align="center" justify="center" p={3}>
          <Icon name="university" color="yellow" size={4} mb={1} />
          <Box
            fontSize="16px"
            bold
            color="yellow"
            mb={2}
            style={{ letterSpacing: '1px' }}
          >
            RAINGOR INTERSTELLAR BANKING
          </Box>

          <Box
            fontSize="14px"
            color="white"
            mb={1}
            style={{ textShadow: '2px 2px 4px rgba(0,0,0,0.8)' }}
          >
            <Icon name="user-circle" mr={0.5} />
            Клиент: {name || 'Неизвестно'}
          </Box>

          <Box
            fontSize="42px"
            bold
            color="yellow"
            mb={1}
            style={{
              textShadow: '3px 3px 6px rgba(0,0,0,0.9)',
              letterSpacing: '2px',
            }}
          >
            {balance.toLocaleString()} кредитов
          </Box>

          <Box
            fontSize="12px"
            color="white"
            style={{ textShadow: '1px 1px 3px rgba(0,0,0,0.8)' }}
          >
            <Icon name="shield-alt" mr={0.5} />
            Защищённый счёт
          </Box>
        </Stack>
      </Section>

      <Box fontSize="16px" bold mb={1} color="red">
        <Icon name="bolt" mr={0.5} />
        Быстрые операции
      </Box>

      <Stack mb={1}>
        <Stack.Item grow>
          <Button
            fluid
            color="bad"
            onClick={() => setPage('transfer')}
            p={3}
            style={{
              height: '100px',
              borderRadius: '8px',
              border: '2px solid #800020',
              background: 'linear-gradient(180deg, #800020 0%, #500000 100%)',
            }}
          >
            <Stack vertical align="center" justify="center">
              <Icon name="exchange-alt" color="yellow" size={4} mb={1} />
              <Box fontSize="14px" bold color="white">
                Переводы
              </Box>
            </Stack>
          </Button>
        </Stack.Item>

        <Stack.Item grow ml={1}>
          <Button
            fluid
            color="bad"
            onClick={() => setPage('subscriptions')}
            p={3}
            style={{
              height: '100px',
              borderRadius: '8px',
              border: '2px solid #800020',
              background: 'linear-gradient(180deg, #800020 0%, #500000 100%)',
            }}
          >
            <Stack vertical align="center" justify="center">
              <Icon name="credit-card" color="yellow" size={4} mb={1} />
              <Box fontSize="14px" bold color="white">
                Подписки
              </Box>
            </Stack>
          </Button>
        </Stack.Item>
      </Stack>

      <Stack mb={2}>
        <Stack.Item grow>
          <Button
            fluid
            color="bad"
            onClick={() => setPage('about')}
            p={2}
            style={{
              borderRadius: '6px',
              border: '1px solid #800020',
              background: 'linear-gradient(180deg, #800020 0%, #600015 100%)',
            }}
          >
            <Icon name="info-circle" color="yellow" mr={1} />
            <Box fontSize="13px" bold color="white">
              О банке
            </Box>
          </Button>
        </Stack.Item>

        <Stack.Item grow ml={1}>
          <Button
            fluid
            color="bad"
            onClick={handleLogout}
            p={2}
            style={{
              borderRadius: '6px',
              border: '1px solid #800020',
              background: 'linear-gradient(180deg, #800020 0%, #600015 100%)',
            }}
          >
            <Icon name="sign-out-alt" color="yellow" mr={1} />
            <Box fontSize="13px" bold color="white">
              Выйти из аккаунта
            </Box>
          </Button>
        </Stack.Item>
      </Stack>

      <Section
        p={2}
        style={{
          borderRadius: '6px',
          border: '2px solid #800020',
          background: 'linear-gradient(180deg, #500000 0%, #400000 100%)',
        }}
      >
        <Box textAlign="center" color="yellow" fontSize={1} bold>
          <Icon name="exclamation-triangle" mr={0.5} />
          Для выхода из аккаунта сначала извлеките ID-карту из КПК
        </Box>
      </Section>

      <Section title="История операций" mt={2}>
        {transactions.length === 0 && (
          <Box italic color="label" textAlign="center" p={2}>
            <Icon name="inbox" size={2} mb={1} />
            Операции отсутствуют
          </Box>
        )}

        {transactions.map((t, i) => (
          <Section
            key={i}
            title={`${t.date} ${t.time}`}
            mb={1}
            style={{
              borderLeft: `3px solid ${t.amount >= 0 ? '#28a745' : '#dc3545'}`,
              paddingLeft: '8px',
            }}
          >
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
                <Box
                  fontSize="16px"
                  bold
                  color={t.amount >= 0 ? 'good' : 'bad'}
                >
                  {t.amount >= 0 ? '+' : ''}
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
  const { subscriptions, availableSubs } = data;
  const { act } = useBackend();

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
            <Icon name="credit-card" mr={1} />
            Доступные подписки
          </Box>
        }
      >
        {availableSubs.length === 0 && <Box italic>Нет доступных подписок</Box>}
        {availableSubs.map((e) => (
          <Section
            key={e.available_subscription_name}
            title={e.available_subscription_name}
          >
            <Box mb={1}>{e.description}</Box>

            <LabeledList.Item label="Интервал">
              {Math.round(e.interval / 600)} минут
            </LabeledList.Item>

            <LabeledList.Item label="Стоимость">
              <Box> {e.cost} кредитов</Box>
            </LabeledList.Item>

            <Button
              color="good"
              onClick={() => {
                act('add_subscription', {
                  available_subscription_name: e.available_subscription_name,
                });
              }}
            >
              <Icon name="plus" mr={1} />
              Подписаться
            </Button>
          </Section>
        ))}
      </Section>

      <Section
        title={
          <Box fontSize="14px" bold>
            <Icon name="credit-card-alt" mr={1} />
            Ваши подписки
          </Box>
        }
      >
        {subscriptions.length === 0 && (
          <Box italic>У вас нет оформленных подписок</Box>
        )}

        {subscriptions.map((e) => (
          <Section key={e.subscription_name} title={e.subscription_name}>
            <LabeledList>
              <LabeledList.Item label="Поставщик">
                {e.recipient_name}
              </LabeledList.Item>

              <LabeledList.Item label="Описание">
                <Box mb={1}>{e.description}</Box>
              </LabeledList.Item>

              <LabeledList.Item label="Цена">{e.cost}</LabeledList.Item>

              <LabeledList.Item label="Интервал">
                {Math.round(e.interval / 600)} минут
              </LabeledList.Item>

              <LabeledList.Item label="Статус">
                <Box color={e.status ? 'good' : 'bad'}>
                  {e.status ? 'Активна' : 'Остановлена'}
                </Box>
              </LabeledList.Item>
            </LabeledList>

            {e.status ? (
              e.secure ? (
                <Box color="grey" fontSize={0.8}>
                  Не подлежит изменению. <br />
                  По вопросам обратитесь к Главе Персонала.
                </Box>
              ) : (
                <Button
                  color="bad"
                  onClick={() =>
                    act('cancel_subscription', {
                      subscription_name: e.subscription_name,
                    })
                  }
                >
                  <Icon name="times" mr={1} />
                  Отменить подписку
                </Button>
              )
            ) : e.secure ? (
              <Box color="grey" fontSize={0.8}>
                Не подлежит изменению. <br />
                По вопросам обратитесь к Главе Персонала.
              </Box>
            ) : (
              <Button
                color="good"
                onClick={() =>
                  act('resume_subscription', {
                    subscription_name: e.subscription_name,
                  })
                }
              >
                <Icon name="redo" mr={1} />
                Восстановить подписку
              </Button>
            )}
          </Section>
        ))}
      </Section>
    </Box>
  );
};

const AboutMenuPage = ({ setPage, data }: PageProps) => {
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

// I don't know how, but if he gets an error, he can go to the main folder.
// Last hope
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
