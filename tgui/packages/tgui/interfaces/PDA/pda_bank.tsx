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
  subscription_type: string;
  direction: 'outgoing' | 'incoming';
};

type AvailableSubscription = {
  available_subscription_name: string;
  description: string;
  cost: number;
  interval: number;
  provider: string;
  secure: boolean;
  subscription_type: string;
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
      <Window width={600} height={850}>
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
      PageContent = <UUMainMenuPage setPage={setPage} data={data} />;
      break;
    case 'transfer':
      PageContent = <UUTransferMenuPage setPage={setPage} data={data} />;
      break;
    case 'subscriptions':
      PageContent = <UUSubscriptionsMenuPage setPage={setPage} data={data} />;
      break;
    case 'about':
      PageContent = <UUAboutMenuPage setPage={setPage} data={data} />;
      break;
    default:
      PageContent = <UUErrorPage setPage={setPage} />;
  }
  return (
    <Window width={600} height={650}>
      <Window.Content>
        <Stack fill vertical>
          <Section fill scrollable>
            {PageContent}
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const UUMainMenuPage = ({ setPage, data }: PageProps) => {
  const { balance, transactions, name } = data;
  const { act } = useBackend();

  const handleLogout = () => {
    act('login_logout');
  };

  return (
    <Box>
      {/* Hero Card */}
      <Section className="card--hero" fill mb={2}>
        <Stack vertical align="center" justify="center" p={3}>
          {/* Bank Logo + FULL NAME - PROMINENT */}
          <Icon name="university" className="text-gold" size={3} mb={2} />
          <Box
            fontSize="15px"
            bold
            className="text-gold"
            mb={2}
            textAlign="center"
            style={{ letterSpacing: '1.5px' }}
          >
            RAINGOR
          </Box>
          <Box
            fontSize="13px"
            className="text-white"
            mb={3}
            textAlign="center"
            style={{ letterSpacing: '2px', opacity: 0.9 }}
          >
            INTERSTELLAR BANKING
          </Box>

          {/* Divider */}
          <Box
            className="divider"
            style={{ width: '60%', margin: '0 auto 20px' }}
          />

          {/* Client Info */}
          <Box fontSize="12px" className="text-white" mb={1}>
            <Icon name="user-circle" mr={0.5} size={0.8} />
            {name || 'Неизвестно'}
          </Box>

          {/* Balance - THE HERO */}
          <Box fontSize="48px" bold className="text-gold" mb={1}>
            {balance.toLocaleString()}
          </Box>
          <Box
            fontSize="13px"
            className="text-white"
            mb={2}
            style={{ opacity: 0.85 }}
          >
            кредитов
          </Box>

          {/* Security Badge */}
          <Box fontSize="11px" className="text-white" style={{ opacity: 0.75 }}>
            <Icon name="shield-alt" mr={0.5} size={0.8} />
            Защищённый счёт
          </Box>
        </Stack>
      </Section>

      {/* Quick Operations Header */}
      <Box fontSize="16px" bold mb={1} className="text-gold">
        <Icon name="bolt" mr={0.5} />
        Быстрые операции
      </Box>

      {/* Action Buttons */}
      <Stack mb={1}>
        <Stack.Item grow>
          <Button
            fluid
            onClick={() => setPage('transfer')}
            p={3}
            className="btn-bank"
          >
            <Stack vertical align="center" justify="center">
              <Icon name="exchange-alt" className="text-gold" size={4} mb={1} />
              <Box fontSize="14px" bold className="text-white">
                Переводы
              </Box>
            </Stack>
          </Button>
        </Stack.Item>
        <Stack.Item grow ml={1}>
          <Button
            fluid
            onClick={() => setPage('subscriptions')}
            p={3}
            className="btn-bank"
          >
            <Stack vertical align="center" justify="center">
              <Icon name="credit-card" className="text-gold" size={4} mb={1} />
              <Box fontSize="14px" bold className="text-white">
                Подписки
              </Box>
            </Stack>
          </Button>
        </Stack.Item>
      </Stack>

      {/* Secondary Buttons */}
      <Stack mb={2}>
        <Stack.Item grow>
          <Button
            fluid
            onClick={() => setPage('about')}
            p={2}
            className="btn-bank"
          >
            <Icon name="info-circle" className="text-gold" mr={1} />
            <Box fontSize="13px" bold className="text-white">
              О банке
            </Box>
          </Button>
        </Stack.Item>
        <Stack.Item grow ml={1}>
          <Button fluid onClick={handleLogout} p={2} className="btn-bank">
            <Icon name="sign-out-alt" className="text-gold" mr={1} />
            <Box fontSize="13px" bold className="text-white">
              Выйти из аккаунта
            </Box>
          </Button>
        </Stack.Item>
      </Stack>

      {/* Warning Notice */}
      <Section className="secure-notice" p={2}>
        <Box textAlign="center" className="text-gold" fontSize={1} bold>
          <Icon name="exclamation-triangle" mr={0.5} />
          Для полного выхода извлеките ID-карту из КПК
        </Box>
      </Section>

      {/* Transaction History */}
      <Section title="История операций" mt={2}>
        {transactions.length === 0 ? (
          <Box italic className="text-muted" textAlign="center" p={2}>
            <Icon name="inbox" size={2} mb={1} />
            Операции отсутствуют
          </Box>
        ) : (
          transactions.map((t, i) => (
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
                <LabeledList.Item label="Назначение" className="text-white">
                  {t.purpose}
                </LabeledList.Item>
                <LabeledList.Item label="Контрагент" className="text-white">
                  {t.target_name}
                </LabeledList.Item>
                <LabeledList.Item label="Терминал" className="text-white">
                  {t.source_terminal}
                </LabeledList.Item>
                <LabeledList.Item label="Сумма">
                  <Box
                    fontSize="16px"
                    bold
                    className={t.amount >= 0 ? 'text-gold' : 'text-danger'}
                  >
                    {t.amount >= 0 ? '+' : ''}
                    {t.amount} кредитов
                  </Box>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          ))
        )}
      </Section>
    </Box>
  );
};

const UUTransferMenuPage = ({ setPage, data }: PageProps) => {
  const { balance, name, targets } = data;
  const { act } = useBackend();

  const [target, setTarget] = useState<string | null>(null);
  const [amount, setAmount] = useState<number>(0);
  const [purpose, setPurpose] = useState<string>(DEFAULT_PURPOSE);

  const sendTransfer = () => {
    act('transfer', { target, amount, purpose });
  };

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
      {/* Back Button */}
      <Box textAlign="center" mb={3}>
        <Button fluid className="btn-bank" onClick={() => setPage('main')}>
          <Icon name="step-backward" className="text-gold" mr={1} />
          <span className="text-white">Вернуться в меню</span>
        </Button>
      </Box>

      {/* Balance Display */}
      <Box className="balance-display">
        <Box className="balance-label">Доступный баланс</Box>
        <Box className="balance-amount">
          {balance.toLocaleString()}{' '}
          <Box as="span" fontSize="18px">
            кредитов
          </Box>
        </Box>
      </Box>

      {/* Transfer Form */}
      <Section>
        <Box className="section-header" mb={3} textAlign="center">
          <Icon name="exchange-alt" className="text-gold" mr={1} />
          <Box as="span" fontSize="16px" bold>
            Межзвёздный перевод
          </Box>
        </Box>

        {/* Recipient */}
        <Box mb={3}>
          <Box className="field-label" mb={1}>
            <Icon name="user" mr={0.5} />
            Получатель
          </Box>
          <Dropdown
            fluid
            width="100%"
            options={targets}
            selected={target}
            onSelected={(t) => setTarget(t)}
            placeholder="Выберите счёт из реестра..."
            icon="address-book"
            className="input-field input-field--large"
            style={{ width: '100%' }}
          />
        </Box>

        {/* Amount */}
        <Box mb={3}>
          <Box className="field-label" mb={1}>
            <Icon name="coins" mr={0.5} />
            Сумма перевода
          </Box>
          <NumberInput
            fluid
            maxValue={balance}
            minValue={0}
            value={amount}
            onChange={(m) => setAmount(m)}
            step={1}
            className="input-field"
          />
          <Box
            fontSize="11px"
            className="text-muted"
            mt={0.5}
            textAlign="right"
          >
            Макс: {balance} кредитов
          </Box>
        </Box>

        {/* Divider */}
        <Box className="divider" />

        {/* Purpose */}
        <Box mb={3}>
          <Box className="field-label" mb={1}>
            <Icon name="file-alt" mr={0.5} />
            Назначение платежа
          </Box>
          <TextArea
            height="80px"
            placeholder="Например: Оплата контракта #2451..."
            value={purpose}
            onChange={(t) => setPurpose(t)}
            maxLength={500}
            className="input-field"
          />
          <Box
            fontSize="11px"
            className="text-muted"
            mt={0.5}
            textAlign="right"
          >
            {purpose.length}/500
          </Box>
        </Box>

        {/* Error Message */}
        {error && (
          <Box className="error-message" mb={2}>
            <Icon name="exclamation-circle" mr={0.5} />
            {error}
          </Box>
        )}

        {/* Submit Button */}
        <Button
          fluid
          className="btn-bank btn-bank--primary"
          disabled={!!error}
          onClick={sendTransfer}
          p={3}
        >
          <Stack align="center" justify="center">
            <Icon name="paper-plane" className="text-gold" mr={2} size={2} />
            <Box fontSize="14px" bold className="text-white">
              Подтвердить перевод
            </Box>
          </Stack>
        </Button>

        {/* Security Notice */}
        <Box fontSize="10px" className="text-muted" textAlign="center" mt={2}>
          <Icon name="shield-alt" mr={0.5} />
          Перевод защищён протоколом Raingor SecureChain™
        </Box>
      </Section>
    </Box>
  );
};

const UUSubscriptionsMenuPage = ({ setPage, data }: PageProps) => {
  const { subscriptions, availableSubs } = data;
  const { act } = useBackend();

  return (
    <Box>
      {/* Back Button */}
      <Box textAlign="center" mb={3}>
        <Button fluid className="btn-bank" onClick={() => setPage('main')}>
          <Icon name="step-backward" className="text-gold" mr={1} />
          <span className="text-white">Вернуться в меню</span>
        </Button>
      </Box>

      {/* Available Subscriptions */}
      <Section mb={2}>
        <Box className="section-header">
          <Icon name="credit-card" className="text-gold" mr={1} />
          <Box as="span">Доступные подписки</Box>
        </Box>

        {availableSubs.filter((e) => !e.secure).length === 0 ? (
          <Box italic className="text-muted" textAlign="center" p={3}>
            <Icon name="inbox" size={2} mb={2} />
            Нет доступных подписок
          </Box>
        ) : (
          availableSubs
            .filter((e) => !e.secure)
            .map((e) => (
              <Box key={e.available_subscription_name} className="card" mb={2}>
                <Box className="subscription-title">
                  <Icon name="star" size={1} />
                  {e.available_subscription_name}
                </Box>
                <Box className="text-white" mb={2}>
                  {e.description}
                </Box>
                <Box className="subscription-meta" mb={2}>
                  <Box className="subscription-meta-item">
                    Интервал:{' '}
                    <Box as="span" className="value">
                      {Math.round(e.interval / 600)} мин
                    </Box>
                  </Box>
                  <Box className="subscription-meta-item">
                    Стоимость:{' '}
                    <Box as="span" className="value">
                      {e.cost} кредитов
                    </Box>
                  </Box>
                </Box>
                <Button
                  fluid
                  className="btn-bank"
                  onClick={() => {
                    act('add_subscription', {
                      available_subscription_name:
                        e.available_subscription_name,
                      subscription_type: e.subscription_type,
                    });
                  }}
                >
                  <Icon name="plus" className="text-gold" mr={1} />
                  <span className="text-white">Подписаться</span>
                </Button>
              </Box>
            ))
        )}
      </Section>

      {/* Divider */}
      <Box className="divider" />

      {/* Your Subscriptions */}
      <Section>
        <Box className="section-header">
          <Icon name="credit-card-alt" className="text-gold" mr={1} />
          <Box as="span">Ваши подписки</Box>
        </Box>

        {subscriptions.length === 0 ? (
          <Box italic className="text-muted" textAlign="center" p={3}>
            <Icon name="credit-card" size={2} mb={2} />У вас нет оформленных
            подписок
          </Box>
        ) : (
          subscriptions.map((e) => (
            <Box key={e.subscription_name} className="card" mb={2}>
              <Box className="subscription-title">
                <Icon name="bookmark" size={1} />
                {e.subscription_name}
              </Box>

              <Box className="text-muted" mb={1}>
                <Box as="span" className="field-label">
                  {e.direction === 'outgoing' ? 'Поставщик:' : 'Плательщик:'}
                </Box>
                {e.recipient_name}
              </Box>

              <Box className="text-white" mb={2}>
                {e.description}
              </Box>

              <Box className="subscription-meta" mb={2}>
                <Box className="subscription-meta-item">
                  Цена:{' '}
                  <Box as="span" className="value">
                    {e.cost} кредитов
                  </Box>
                </Box>
                <Box className="subscription-meta-item">
                  Интервал:{' '}
                  <Box as="span" className="value">
                    {Math.round(e.interval / 600)} мин
                  </Box>
                </Box>
              </Box>

              <Box mb={2}>
                <Box className="field-label" mb={0.5}>
                  Статус:
                </Box>
                <Box
                  className={`status-badge ${
                    e.status ? 'status-badge--active' : 'status-badge--paused'
                  } ${e.secure ? 'status-badge--secure' : ''}`}
                >
                  {e.secure && <Icon name="lock" mr={0.5} size={0.8} />}
                  {e.status ? ' Активна ' : ' Остановлена '}
                  {e.secure && ' • Защищена'}
                </Box>
              </Box>

              {/* Кнопки действий — ИСПРАВЛЕННАЯ ЛОГИКА */}
              {e.status ? (
                // Активна
                e.secure ? (
                  <Box className="secure-notice">
                    <Icon name="shield-alt" mr={0.5} />
                    Не подлежит изменению. По вопросам обратитесь к Главе
                    Персонала.
                  </Box>
                ) : (
                  <Button
                    className="btn-bank btn-bank--danger"
                    onClick={() =>
                      act('cancel_subscription', {
                        subscription_name: e.subscription_name,
                        subscription_type: e.subscription_type,
                      })
                    }
                  >
                    <Icon name="times" className="text-danger" mr={1} />
                    <span className="text-white">Отменить</span>
                  </Button>
                )
              ) : e.secure ? (
                // Не активна + защищена
                <Box className="secure-notice">
                  <Icon name="shield-alt" mr={0.5} />
                  Не подлежит изменению. По вопросам обратитесь к Главе
                  Персонала.
                </Box>
              ) : (
                // Не активна + НЕ защищена
                <Button
                  className="btn-bank"
                  onClick={() =>
                    act('resume_subscription', {
                      subscription_name: e.subscription_name,
                      subscription_type: e.subscription_type,
                    })
                  }
                >
                  <Icon name="redo" className="text-gold" mr={1} />
                  <span className="text-white">Восстановить</span>
                </Button>
              )}
            </Box>
          ))
        )}
      </Section>
    </Box>
  );
};

const UUAboutMenuPage = ({ setPage, data }: PageProps) => {
  return (
    <Box>
      {/* Back Button */}
      <Box textAlign="center" mb={4}>
        <Button fluid className="btn-bank" onClick={() => setPage('main')}>
          <Icon name="step-backward" className="text-gold" mr={1} />
          <span className="text-white">Вернуться в меню</span>
        </Button>
      </Box>

      {/* Main Section */}
      <Section>
        {/* Заголовок — ПО ЦЕНТРУ */}
        <Box className="lore-section-title" textAlign="center" mb={3}>
          <Icon name="university" className="text-gold" size={2} mr={1} />
          <Box as="span">О Raingor Interstellar Banking</Box>
        </Box>

        <Box className="lore-container">
          {/* Paragraph 1 */}
          <Box className="lore-paragraph">
            <Box as="span" className="lore-highlight">
              Raingor Interstellar Banking
            </Box>{' '}
            — корпорация, объединившая частное кредитование и систему мгновенных
            переводов.
          </Box>

          {/* Paragraph 2 */}
          <Box className="lore-paragraph">
            Основанная в 24 веке,{' '}
            <Box as="span" className="lore-highlight">
              Raingor Interstellar Banking
            </Box>{' '}
            стала ведущим игроком в сфере частного финансирования межзвёздной
            экономики. Благодаря
            <Box as="span" className="lore-italic">
              {' '}
              беспрепятственному доступу ко всем ретрансляторам блюспейс-сети,
              полученному по эксклюзивному контракту со всеми государственными
              структурами, вошедшими в соглашение об использовании кредита в
              качестве циркуляционной валюты
            </Box>
            , корпорация может управлять транзакциями и капиталом{' '}
            <Box as="span" className="lore-highlight">
              с немыслимой скоростью
            </Box>{' '}
            по всей галактике.
          </Box>

          {/* Decorative Divider */}
          <Box className="lore-divider">
            <Icon name="star" size={1} className="lore-icon-decor" />
            <Icon name="star" size={1} className="lore-icon-decor" />
            <Icon name="star" size={1} className="lore-icon-decor" />
          </Box>

          {/* Paragraph 3 */}
          <Box className="lore-paragraph">
            Наши клиенты — от частных предпринимателей до межзвёздных
            исследовательских корпораций.{' '}
            <Box as="span" className="lore-highlight">
              Raingor Bank
            </Box>{' '}
            предоставляет кредиты на развитие частных колонизационных проектов,
            инвестирует в инфраструктуру планет и поддерживает финансовую
            экосистему новых миров.
          </Box>

          {/* Paragraph 4 */}
          <Box className="lore-paragraph">
            Надёжность и инновации лежат в основе каждого нашего сервиса. Мы
            обеспечиваем прозрачность операций, мгновенные переводы и
            сохранность ваших средств даже в самых удалённых уголках космоса.
          </Box>

          {/* Quote / Slogan */}
          <Box className="card--quote">
            <Icon
              name="quote-left"
              className="lore-icon-decor"
              mr={1}
              size={1.5}
            />
            <Box className="lore-quote-text">
              «Доверие, проверенное временем и звёздами»
            </Box>
            <Icon
              name="quote-right"
              className="lore-icon-decor"
              ml={1}
              size={1.5}
            />
          </Box>
        </Box>
      </Section>

      {/* Footer */}
      <Box textAlign="center" mt={3} className="text-muted" fontSize={0.9}>
        <Icon name="copyright" mr={0.5} />
        Raingor Interstellar Banking © 24XX
      </Box>
    </Box>
  );
};

// I don't know how, but if he gets an error, he can go to the main folder.
// Last hope
const UUErrorPage = ({ setPage }: PageBaseProps) => {
  return (
    <Box>
      {/* Error Card */}
      <Box className="card card--error">
        <Box className="error-icon" textAlign="center">
          <Icon name="exclamation-triangle" />
        </Box>
        <Box className="error-title" textAlign="center">
          Ошибка
        </Box>
        <Box className="divider" />
        <Box className="error-message" textAlign="center">
          Произошла непредвиденная ошибка при обработке запроса.
          <br />
          Пожалуйста, попробуйте снова или вернитесь в главное меню.
        </Box>
        <Box className="divider" />
        <Button
          fluid
          className="btn-bank btn-bank--danger"
          onClick={() => setPage('main')}
          p={3}
        >
          <Stack align="center" justify="center">
            <Icon name="step-backward" mr={2} className="text-white" />
            <Box fontSize="14px" className="text-white">
              Вернуться в меню
            </Box>
          </Stack>
        </Button>
      </Box>

      {/* Footer Notice */}
      <Box textAlign="center" mt={3} className="text-muted" fontSize={0.9}>
        <Icon name="info-circle" mr={0.5} />
        Если ошибка повторяется, обратитесь в службу поддержки Raingor
      </Box>
    </Box>
  );
};
