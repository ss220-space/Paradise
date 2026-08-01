import { useMemo, useState } from 'react';

import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Icon,
  Image,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
  Tabs,
  TextArea,
} from '../../components';
import { Window } from '../../layouts';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type OfferStatus =
  | 'open'
  | 'taken'
  | 'submitted'
  | 'completed'
  | 'cancelled'
  | 'disputed';

type Account = {
  name: string;
  account_number: number;
  photo: string | null;
  rating: number;
  rating_count: number;
  completed_count: number;
};

type Offer = {
  id: string;
  title: string;
  description: string;
  reward: number;
  status: OfferStatus;
  created_at: number;
  review_rating: number | null;
  client?: Account;
  worker?: Account;
};

type Target = {
  name: string;
  account_number: number;
};

type Data = {
  account: Account;
  offers: Offer[];
  targets: Target[];
  world_time: number;
};

type TabName = 'market' | 'create' | 'deals' | 'transfer' | 'about';

const PDA_UI = {
  window: { width: 600, height: 870 },
};

const ACCENT = '#4fa3ff';
const GOOD = '#3ecf6e';
const BAD = '#ff5c6c';

const STATUS_META: Record<
  OfferStatus,
  { label: string; color: string; icon: string }
> = {
  open: { label: 'Открыт', color: ACCENT, icon: 'circle-notch' },
  taken: { label: 'В работе', color: '#e0b23e', icon: 'hammer' },
  submitted: {
    label: 'На проверке',
    color: '#e0b23e',
    icon: 'flag-checkered',
  },
  completed: { label: 'Завершён', color: GOOD, icon: 'circle-check' },
  cancelled: { label: 'Отменён', color: '#8a8f98', icon: 'ban' },
  disputed: { label: 'Спор', color: BAD, icon: 'gavel' },
};

const formatElapsed = (worldTime: number, createdAt: number): string => {
  const seconds = Math.max(0, (worldTime - createdAt) / 10);
  const minutes = Math.floor(seconds / 60);
  if (minutes < 1) {
    return 'только что';
  }
  if (minutes < 60) {
    return `${minutes} мин назад`;
  }
  const hours = Math.floor(minutes / 60);
  if (hours < 24) {
    return `${hours} ч назад`;
  }
  const days = Math.floor(hours / 24);
  return `${days} дн назад`;
};

const isParticipant = (offer: Offer, accountNumber: number): boolean => {
  return (
    offer.client?.account_number === accountNumber ||
    offer.worker?.account_number === accountNumber
  );
};

const Avatar = (props: { photo?: string | null; size?: number }) => {
  const { photo, size = 40 } = props;
  return (
    <Box
      width={`${size}px`}
      height={`${size}px`}
      minWidth={`${size}px`}
      style={{
        borderRadius: '50%',
        overflow: 'hidden',
        background: 'rgba(255, 255, 255, 0.06)',
        border: '1px solid rgba(255, 255, 255, 0.14)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      {photo ? (
        <Image
          src={photo}
          width={`${size}px`}
          height={`${size}px`}
          objectFit="cover"
        />
      ) : (
        <Icon name="user" size={size / 22} color="rgba(255, 255, 255, 0.3)" />
      )}
    </Box>
  );
};

const StatusBadge = (props: { status: OfferStatus }) => {
  const meta = STATUS_META[props.status] || {
    label: props.status,
    color: '#8a8f98',
    icon: 'question',
  };
  return (
    <Box
      inline
      color={meta.color}
      fontSize="0.85em"
      style={{
        padding: '2px 9px',
        borderRadius: '999px',
        background: `${meta.color}22`,
        border: `1px solid ${meta.color}55`,
        whiteSpace: 'nowrap',
      }}
    >
      <Icon name={meta.icon} mr={0.5} />
      {meta.label}
    </Box>
  );
};

const RewardPill = (props: { amount: number; color?: string }) => (
  <Box
    inline
    bold
    color={props.color || GOOD}
    style={{
      padding: '2px 9px',
      borderRadius: '999px',
      background: `${props.color || GOOD}18`,
      whiteSpace: 'nowrap',
    }}
  >
    {props.amount} кр
  </Box>
);

const StarPicker = (props: {
  value: number;
  onChange: (v: number) => void;
}) => {
  const { value, onChange } = props;
  return (
    <Stack>
      {[1, 2, 3, 4, 5].map((star) => (
        <Stack.Item key={star}>
          <Icon
            name={star <= value ? 'star' : 'star-o'}
            size={1.35}
            color={star <= value ? '#ffcb4d' : 'rgba(255, 255, 255, 0.25)'}
            style={{ cursor: 'pointer' }}
            onClick={() => onChange(star)}
          />
        </Stack.Item>
      ))}
    </Stack>
  );
};

const StarDisplay = (props: { rating: number }) => (
  <Box inline color="#ffcb4d">
    <Icon name="star" mr={0.3} />
    {props.rating || '—'}
  </Box>
);

const OfferCard = (props: {
  offer: Offer;
  myAccountNumber: number;
  worldTime: number;
  rating: number;
  onRatingChange: (value: number) => void;
  onAct: (action: string, params?: Record<string, unknown>) => void;
}) => {
  const { offer, myAccountNumber, worldTime, rating, onRatingChange, onAct } =
    props;

  const iAmClient = offer.client?.account_number === myAccountNumber;
  const iAmWorker = offer.worker?.account_number === myAccountNumber;

  return (
    <Section
      backgroundColor="rgba(255, 255, 255, 0.03)"
      title={offer.title}
      buttons={
        <Stack align="center">
          <Stack.Item>
            <RewardPill amount={offer.reward} />
          </Stack.Item>
          <Stack.Item>
            <StatusBadge status={offer.status} />
          </Stack.Item>
        </Stack>
      }
    >
      <Stack vertical>
        <Stack.Item>
          <Box color="label" style={{ whiteSpace: 'pre-wrap' }}>
            {offer.description}
          </Box>
        </Stack.Item>

        <Stack.Item>
          <Stack align="center">
            <Stack.Item grow>
              <Stack align="center">
                <Stack.Item>
                  <Avatar photo={offer.client?.photo} size={28} />
                </Stack.Item>
                <Stack.Item>
                  <Box bold>{offer.client?.name || 'Неизвестно'}</Box>
                  <Box color="label" fontSize="0.85em">
                    Заказчик ·{' '}
                    <StarDisplay rating={offer.client?.rating || 0} />
                  </Box>
                </Stack.Item>
              </Stack>
            </Stack.Item>

            {!!offer.worker && (
              <Stack.Item grow>
                <Stack align="center">
                  <Stack.Item>
                    <Avatar photo={offer.worker.photo} size={28} />
                  </Stack.Item>
                  <Stack.Item>
                    <Box bold>{offer.worker.name}</Box>
                    <Box color="label" fontSize="0.85em">
                      Исполнитель · <StarDisplay rating={offer.worker.rating} />
                    </Box>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            )}

            <Stack.Item color="label" fontSize="0.8em">
              {formatElapsed(worldTime, offer.created_at)}
            </Stack.Item>
          </Stack>
        </Stack.Item>

        <Stack.Item>
          <Divider />
        </Stack.Item>

        <Stack.Item>
          <Stack>
            {offer.status === 'open' && !iAmClient && (
              <Stack.Item grow>
                <Button
                  fluid
                  color="good"
                  icon="handshake"
                  onClick={() => onAct('take_offer', { id: offer.id })}
                >
                  Взять заказ
                </Button>
              </Stack.Item>
            )}

            {offer.status === 'open' && iAmClient && (
              <>
                <Stack.Item grow>
                  <NoticeBox>Ждём исполнителя…</NoticeBox>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    color="average"
                    icon="times"
                    onClick={() => onAct('cancel_offer', { id: offer.id })}
                  >
                    Отменить
                  </Button>
                </Stack.Item>
              </>
            )}

            {offer.status === 'taken' && iAmWorker && (
              <Stack.Item grow>
                <Button
                  fluid
                  color="average"
                  icon="flag-checkered"
                  onClick={() => onAct('submit_offer', { id: offer.id })}
                >
                  Работа выполнена
                </Button>
              </Stack.Item>
            )}

            {offer.status === 'taken' && iAmClient && (
              <Stack.Item grow>
                <NoticeBox>Исполнитель работает над заказом.</NoticeBox>
              </Stack.Item>
            )}

            {(offer.status === 'taken' || offer.status === 'submitted') &&
              (iAmClient || iAmWorker) && (
                <Stack.Item>
                  <Button
                    color="bad"
                    icon="gavel"
                    onClick={() => onAct('dispute_offer', { id: offer.id })}
                  >
                    Спор
                  </Button>
                </Stack.Item>
              )}

            {offer.status === 'submitted' && iAmClient && (
              <Stack.Item grow>
                <Stack vertical>
                  <Stack.Item>
                    <Box mb={0.5} color="label">
                      Оценка исполнителя
                    </Box>
                    <StarPicker value={rating} onChange={onRatingChange} />
                  </Stack.Item>
                  <Stack.Item mt={1}>
                    <Button
                      fluid
                      color="good"
                      icon="check"
                      onClick={() =>
                        onAct('complete_offer', {
                          id: offer.id,
                          rating,
                        })
                      }
                    >
                      Подтвердить и оплатить
                    </Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            )}

            {offer.status === 'submitted' && iAmWorker && (
              <Stack.Item grow>
                <NoticeBox>Заказчик проверяет результат.</NoticeBox>
              </Stack.Item>
            )}

            {offer.status === 'completed' && (
              <Stack.Item grow color="label">
                <Icon name="circle-check" color={GOOD} mr={0.5} />
                Оплата {Math.round(offer.reward * 0.8)} кр начислена исполнителю
                {offer.review_rating !== null && (
                  <>
                    {' · оценка '}
                    <StarDisplay rating={offer.review_rating} />
                  </>
                )}
              </Stack.Item>
            )}

            {offer.status === 'cancelled' && (
              <Stack.Item grow color="label">
                <Icon name="ban" mr={0.5} />
                Заказ отменён, средства возвращены заказчику
              </Stack.Item>
            )}

            {offer.status === 'disputed' && (
              <Stack.Item grow color="label">
                <Icon name="gavel" mr={0.5} />
                Спор разрешён арбитражем RainDrop, средства разделены между
                сторонами
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const pda_rainDrop = (_props: unknown) => {
  const { act, data } = useBackend<Data>();
  const { account, offers = [], targets = [], world_time = 0 } = data;

  const [tab, setTab] = useState<TabName>('market');
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [reward, setReward] = useState(100);
  const [ratings, setRatings] = useState<Record<string, number>>({});

  const [transferTarget, setTransferTarget] = useState<Target | null>(null);
  const [transferAmount, setTransferAmount] = useState(100);
  const [transferNote, setTransferNote] = useState('');

  if (!account) {
    return (
      <Window
        width={PDA_UI.window.width}
        height={PDA_UI.window.height}
        theme="ntos_darkmode"
      >
        <Window.Content>
          <Stack fill align="center" justify="center" vertical>
            <Stack.Item>
              <Icon name="briefcase" size={3} color="rgba(255,255,255,0.2)" />
            </Stack.Item>
            <Stack.Item mt={1} color="label">
              Приложите ID-карту, чтобы войти в RainDrop
            </Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }

  const getRating = (offerId: string) => ratings[offerId] ?? 5;
  const setRating = (offerId: string, value: number) =>
    setRatings({ ...ratings, [offerId]: value });

  const openOffers = offers.filter((offer) => offer.status === 'open');
  const myDeals = offers.filter((offer) =>
    isParticipant(offer, account.account_number)
  );

  const executorPreview = Math.round(reward * 0.8);

  const targetOptions = useMemo(
    () =>
      targets.map((target) => ({
        displayText: `${target.name} · #${target.account_number}`,
        value: target.account_number,
      })),
    [targets]
  );

  return (
    <Window
      width={PDA_UI.window.width}
      height={PDA_UI.window.height}
      theme="ntos_darkmode"
    >
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Box
              style={{
                background:
                  'linear-gradient(135deg, rgba(79,163,255,0.16), rgba(79,163,255,0.02))',
                borderRadius: '6px',
                border: '1px solid rgba(79,163,255,0.25)',
                padding: '10px 12px',
              }}
            >
              <Stack align="center">
                <Stack.Item grow>
                  <Stack align="center">
                    <Stack.Item>
                      <Icon name="droplet" size={1.6} color={ACCENT} />
                    </Stack.Item>
                    <Stack.Item>
                      <Box fontSize={1.35} bold>
                        RainDrop
                      </Box>
                      <Box color="label" fontSize="0.85em">
                        Биржа услуг · Переводы Raingor Bank
                      </Box>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>

                <Stack.Item>
                  <Stack align="center">
                    <Stack.Item>
                      <Avatar photo={account.photo} size={44} />
                    </Stack.Item>
                    <Stack.Item>
                      <Box bold>{account.name}</Box>
                      <Box color="label" fontSize="0.85em">
                        #{account.account_number}
                      </Box>
                      <Box fontSize="0.85em">
                        <StarDisplay rating={account.rating} />
                        <Box inline color="label" ml={0.5}>
                          ({account.rating_count}) · {account.completed_count}{' '}
                          заказов
                        </Box>
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        compact
                        color="bad"
                        icon="sign-out-alt"
                        tooltip="Выйти из аккаунта"
                        onClick={() => act('logout')}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Box>
          </Stack.Item>

          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="store"
                selected={tab === 'market'}
                onClick={() => setTab('market')}
              >
                Биржа
              </Tabs.Tab>
              <Tabs.Tab
                icon="plus"
                selected={tab === 'create'}
                onClick={() => setTab('create')}
              >
                Разместить
              </Tabs.Tab>
              <Tabs.Tab
                icon="briefcase"
                selected={tab === 'deals'}
                onClick={() => setTab('deals')}
              >
                Мои сделки
              </Tabs.Tab>
              <Tabs.Tab
                icon="right-left"
                selected={tab === 'transfer'}
                onClick={() => setTab('transfer')}
              >
                Переводы
              </Tabs.Tab>
              <Tabs.Tab
                icon="circle-info"
                selected={tab === 'about'}
                onClick={() => setTab('about')}
              >
                О сервисе
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>

          {tab === 'market' && (
            <Stack.Item grow>
              <Stack vertical>
                {!openOffers.length && (
                  <Stack.Item>
                    <NoticeBox>
                      На бирже пока нет открытых предложений. Разместите своё во
                      вкладке «Разместить».
                    </NoticeBox>
                  </Stack.Item>
                )}
                {openOffers.map((offer) => (
                  <Stack.Item key={offer.id}>
                    <OfferCard
                      offer={offer}
                      myAccountNumber={account.account_number}
                      worldTime={world_time}
                      rating={getRating(offer.id)}
                      onRatingChange={(value) => setRating(offer.id, value)}
                      onAct={act}
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
          )}

          {tab === 'create' && (
            <Stack.Item grow>
              <Section title="Новое предложение" fill>
                <Stack vertical>
                  <Stack.Item>
                    <LabeledList>
                      <LabeledList.Item label="Название">
                        <Input
                          fluid
                          value={title}
                          maxLength={60}
                          onChange={(value) => setTitle(value)}
                          placeholder="Нужен инженер для ремонта шлюза"
                        />
                      </LabeledList.Item>

                      <LabeledList.Item label="Оплата">
                        <NumberInput
                          value={reward}
                          minValue={10}
                          maxValue={100000}
                          step={50}
                          unit="кр"
                          onChange={(value) => setReward(value)}
                        />
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>

                  <Stack.Item grow>
                    <Box mb={0.5} bold>
                      Описание
                    </Box>
                    <TextArea
                      fluid
                      height="200px"
                      value={description}
                      maxLength={300}
                      onChange={(value) => setDescription(value)}
                      placeholder="Опишите задачу, место встречи и детали заказа..."
                    />
                  </Stack.Item>

                  <Stack.Item>
                    <Box
                      style={{
                        padding: '8px 10px',
                        borderRadius: '6px',
                        background: 'rgba(255,255,255,0.04)',
                      }}
                    >
                      <Stack justify="space-between">
                        <Stack.Item color="label">
                          Спишется с вашего счёта сразу
                        </Stack.Item>
                        <Stack.Item bold>{reward} кр</Stack.Item>
                      </Stack>
                      <Stack justify="space-between">
                        <Stack.Item color="label">
                          Получит исполнитель по завершении
                        </Stack.Item>
                        <Stack.Item bold color={GOOD}>
                          {executorPreview} кр
                        </Stack.Item>
                      </Stack>
                      <Box color="label" fontSize="0.8em" mt={0.5}>
                        Разницу удерживает RainDrop как комиссию за эскроу и
                        гарантию сделки.
                      </Box>
                    </Box>
                  </Stack.Item>

                  <Stack.Item>
                    <Button
                      fluid
                      color="good"
                      icon="paper-plane"
                      disabled={!title || !description || reward <= 0}
                      onClick={() => {
                        act('create_offer', { title, description, reward });
                        setTitle('');
                        setDescription('');
                        setReward(100);
                        setTab('deals');
                      }}
                    >
                      Разместить предложение
                    </Button>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          )}

          {tab === 'deals' && (
            <Stack.Item grow>
              <Stack vertical>
                {!myDeals.length && (
                  <Stack.Item>
                    <NoticeBox>У вас пока нет активных сделок.</NoticeBox>
                  </Stack.Item>
                )}
                {myDeals.map((offer) => (
                  <Stack.Item key={offer.id}>
                    <OfferCard
                      offer={offer}
                      myAccountNumber={account.account_number}
                      worldTime={world_time}
                      rating={getRating(offer.id)}
                      onRatingChange={(value) => setRating(offer.id, value)}
                      onAct={act}
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
          )}

          {tab === 'transfer' && (
            <Stack.Item grow>
              <Section title="Перевод средств" fill>
                <Stack vertical>
                  <Stack.Item>
                    <LabeledList>
                      <LabeledList.Item label="Получатель">
                        <Dropdown
                          fluid
                          search
                          placeholder="Выберите получателя"
                          options={targetOptions}
                          selected={
                            transferTarget
                              ? targetOptions.find(
                                  (option) =>
                                    option.value ===
                                    transferTarget.account_number
                                )
                              : undefined
                          }
                          onSelected={(value) =>
                            setTransferTarget(
                              targets.find(
                                (target) => target.account_number === value
                              ) || null
                            )
                          }
                        />
                      </LabeledList.Item>

                      <LabeledList.Item label="Сумма">
                        <NumberInput
                          value={transferAmount}
                          minValue={1}
                          maxValue={100000}
                          step={50}
                          unit="кр"
                          onChange={(value) => setTransferAmount(value)}
                        />
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>

                  <Stack.Item>
                    <Box mb={0.5} bold>
                      Комментарий (необязательно)
                    </Box>
                    <Input
                      fluid
                      value={transferNote}
                      maxLength={60}
                      onChange={(value) => setTransferNote(value)}
                      placeholder="За что перевод"
                    />
                  </Stack.Item>

                  <Stack.Item>
                    <Button
                      fluid
                      color="good"
                      icon="right-left"
                      disabled={!transferTarget || transferAmount <= 0}
                      onClick={() => {
                        act('transfer_money', {
                          target: transferTarget?.account_number,
                          amount: transferAmount,
                          note: transferNote,
                        });
                        setTransferNote('');
                      }}
                    >
                      Перевести {transferAmount} кр
                    </Button>
                  </Stack.Item>

                  <Stack.Item>
                    <NoticeBox info>
                      Переводы идут напрямую, без комиссии RainDrop, и
                      необратимы — внимательно проверяйте получателя.
                    </NoticeBox>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          )}

          {tab === 'about' && (
            <Stack.Item grow>
              <Section title="О RainDrop" fill scrollable>
                <Stack vertical>
                  <Stack.Item>
                    <Box color="label">
                      Цифровая биржа услуг и платёжный сервис на инфраструктуре
                      Black Rain Group. Соединяет тех, кому нужна помощь, с
                      теми, кто готов её оказать за плату — и переводит деньги
                      между счетами напрямую.
                    </Box>
                  </Stack.Item>

                  <Stack.Item>
                    <Section title="Как это работает">
                      <LabeledList>
                        <LabeledList.Item label="1. Заказ">
                          Заказчик размещает предложение, сумма награды сразу
                          замораживается на эскроу-счёте.
                        </LabeledList.Item>
                        <LabeledList.Item label="2. Исполнение">
                          Исполнитель берёт заказ в работу и отмечает его
                          выполненным по готовности.
                        </LabeledList.Item>
                        <LabeledList.Item label="3. Приёмка">
                          Заказчик проверяет результат, подтверждает оплату и
                          оставляет оценку.
                        </LabeledList.Item>
                        <LabeledList.Item label="4. Спор">
                          Если что-то пошло не так, любая сторона может открыть
                          спор — арбитраж RainDrop разделит средства.
                        </LabeledList.Item>
                      </LabeledList>
                    </Section>
                  </Stack.Item>

                  <Stack.Item>
                    <Section title="Комиссии">
                      <LabeledList>
                        <LabeledList.Item label="Исполнителю при завершении">
                          80% от суммы заказа
                        </LabeledList.Item>
                        <LabeledList.Item label="Возврат при отмене (пока никто не взял)">
                          100% от суммы заказа
                        </LabeledList.Item>
                        <LabeledList.Item label="При споре">
                          40% заказчику / 20% исполнителю
                        </LabeledList.Item>
                        <LabeledList.Item label="P2P переводы">
                          без комиссии
                        </LabeledList.Item>
                      </LabeledList>
                    </Section>
                  </Stack.Item>

                  <Stack.Item>
                    <Box color="label" fontSize="0.9em">
                      RainDrop — технологический посредник и не несёт
                      ответственности за качество, сроки или содержание услуг,
                      оказываемых независимыми исполнителями. Black Rain Group
                      гарантирует лишь техническую целостность платформы и
                      безопасность транзакций.
                    </Box>
                  </Stack.Item>

                  <Stack.Item>
                    <Box color="label" fontSize="0.8em">
                      RainDrop PDA Client v2.0 · Raingor SecureChain™
                    </Box>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
