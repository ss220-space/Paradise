import { useState } from 'react';

import raindropLogo from '../../assets/bg-brg.svg';
import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Icon,
  Image,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  Tabs,
  TextArea,
} from '../../components';
import { Window } from '../../layouts';

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
  account_balance: number;
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

type Data = {
  account: Account;
  offers: Offer[];
  world_time: number;
};

type TabName = 'market' | 'create' | 'deals' | 'about';

const PDA_UI = {
  window: { width: 600, height: 870 },
};

const ACCENT = '#ffd700';
const GOOD = '#28a745';
const BAD = '#dc3545';

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
        background: 'rgba(40, 0, 0, 0.6)',
        border: '1px solid rgba(184, 134, 11, 0.5)',
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
        textTransform: 'uppercase',
        letterSpacing: '0.5px',
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
            color={star <= value ? ACCENT : 'rgba(255, 255, 255, 0.25)'}
            style={{ cursor: 'pointer' }}
            onClick={() => onChange(star)}
          />
        </Stack.Item>
      ))}
    </Stack>
  );
};

const StarDisplay = (props: { rating: number }) => (
  <Box inline color={ACCENT}>
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
      title={<Box className="text-gold">{offer.title}</Box>}
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
          <Box className="text-white" style={{ whiteSpace: 'pre-wrap' }}>
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
                  <Box bold className="text-white">
                    {offer.client?.name || 'Неизвестно'}
                  </Box>
                  <Box className="text-muted" fontSize="0.85em">
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
                    <Box bold className="text-white">
                      {offer.worker.name}
                    </Box>
                    <Box className="text-muted" fontSize="0.85em">
                      Исполнитель · <StarDisplay rating={offer.worker.rating} />
                    </Box>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            )}

            <Stack.Item className="text-muted" fontSize="0.8em">
              {formatElapsed(worldTime, offer.created_at)}
            </Stack.Item>
          </Stack>
        </Stack.Item>

        <Stack.Item>
          <Box className="divider" style={{ margin: '8px 0' }} />
        </Stack.Item>

        <Stack.Item>
          <Stack>
            {offer.status === 'open' && !iAmClient && (
              <Stack.Item grow>
                <Button
                  fluid
                  className="btn-bank btn-bank--primary"
                  icon="handshake"
                  onClick={() => onAct('take_offer', { id: offer.id })}
                >
                  <span className="text-white">Взять заказ</span>
                </Button>
              </Stack.Item>
            )}

            {offer.status === 'open' && iAmClient && (
              <>
                <Stack.Item grow>
                  <Box className="secure-notice">
                    <Icon name="hourglass-half" mr={0.5} />
                    Ждём исполнителя…
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    className="btn-bank btn-bank--danger"
                    icon="times"
                    onClick={() => onAct('cancel_offer', { id: offer.id })}
                  >
                    <span className="text-white">Отменить</span>
                  </Button>
                </Stack.Item>
              </>
            )}

            {offer.status === 'taken' && iAmWorker && (
              <Stack.Item grow>
                <Button
                  fluid
                  className="btn-bank btn-bank--primary"
                  icon="flag-checkered"
                  onClick={() => onAct('submit_offer', { id: offer.id })}
                >
                  <span className="text-white">Работа выполнена</span>
                </Button>
              </Stack.Item>
            )}

            {offer.status === 'taken' && iAmClient && (
              <Stack.Item grow>
                <Box className="secure-notice">
                  <Icon name="wrench" mr={0.5} />
                  Исполнитель работает над заказом.
                </Box>
              </Stack.Item>
            )}

            {(offer.status === 'taken' || offer.status === 'submitted') &&
              (iAmClient || iAmWorker) && (
                <Stack.Item>
                  <Button
                    className="btn-bank btn-bank--danger"
                    icon="gavel"
                    onClick={() => onAct('dispute_offer', { id: offer.id })}
                  >
                    <span className="text-white">Спор</span>
                  </Button>
                </Stack.Item>
              )}

            {offer.status === 'submitted' && iAmClient && (
              <Stack.Item grow>
                <Stack vertical>
                  <Stack.Item>
                    <Box mb={0.5} className="field-label">
                      Оценка исполнителя
                    </Box>
                    <StarPicker value={rating} onChange={onRatingChange} />
                  </Stack.Item>
                  <Stack.Item mt={1}>
                    <Button
                      fluid
                      className="btn-bank btn-bank--primary"
                      icon="check"
                      onClick={() =>
                        onAct('complete_offer', {
                          id: offer.id,
                          rating,
                        })
                      }
                    >
                      <span className="text-white">Подтвердить и оплатить</span>
                    </Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            )}

            {offer.status === 'submitted' && iAmWorker && (
              <Stack.Item grow>
                <Box className="secure-notice">
                  <Icon name="magnifying-glass" mr={0.5} />
                  Заказчик проверяет результат.
                </Box>
              </Stack.Item>
            )}

            {offer.status === 'completed' && (
              <Stack.Item grow className="text-muted">
                <Icon name="circle-check" className="text-gold" mr={0.5} />
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
              <Stack.Item grow className="text-muted">
                <Icon name="ban" mr={0.5} />
                Заказ отменён, средства возвращены заказчику
              </Stack.Item>
            )}

            {offer.status === 'disputed' && (
              <Stack.Item grow className="text-muted">
                <Icon name="gavel" className="text-danger" mr={0.5} />
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
  const { account, offers = [], world_time = 0 } = data;

  const [tab, setTab] = useState<TabName>('market');
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [reward, setReward] = useState(100);
  const [ratings, setRatings] = useState<Record<string, number>>({});

  if (!account) {
    return (
      <Window
        width={PDA_UI.window.width}
        height={PDA_UI.window.height}
        theme="brg"
      >
        <Window.Content>
          <Section fill>
            <Stack fill align="center" justify="center" vertical>
              <Stack.Item className="text-gold" bold fontSize="1.2em" mb={1}>
                RainDrop
              </Stack.Item>
              <Stack.Item className="text-muted" textAlign="center">
                Приложите ID-карту, чтобы войти в RainDrop
              </Stack.Item>
            </Stack>
          </Section>
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

  return (
    <Window
      width={PDA_UI.window.width}
      height={PDA_UI.window.height}
      theme="brg"
    >
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Box className="card--hero" p={2} style={{ borderRadius: '6px' }}>
              <Stack align="center">
                <Stack.Item grow>
                  <Stack align="center">
                    <Stack.Item>
                      <Image src={raindropLogo} width="36px" height="36px" />
                    </Stack.Item>
                    <Stack.Item>
                      <Box fontSize={1.35} bold className="text-gold">
                        RainDrop
                      </Box>
                      <Box className="text-white" fontSize="0.85em">
                        Биржа услуг от Black Rain Group
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
                      <Box bold className="text-white">
                        {account.name}
                      </Box>
                      <Box className="text-gold" fontSize="0.85em">
                        {account.account_balance}$
                      </Box>
                      <Box fontSize="0.85em">
                        <StarDisplay rating={account.rating} />
                        <Box inline className="text-muted" ml={0.5}>
                          ({account.rating_count}) · {account.completed_count}{' '}
                          заказов
                        </Box>
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        compact
                        className="btn-bank btn-bank--danger"
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
                    <Box className="secure-notice">
                      <Icon name="inbox" mr={0.5} />
                      На бирже пока нет открытых предложений. Разместите своё во
                      вкладке «Разместить».
                    </Box>
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
              <Section
                title={<Box className="text-gold">Новое предложение</Box>}
                fill
              >
                <Stack vertical>
                  <Stack.Item>
                    <Box className="field-label">Название</Box>
                    <Input
                      fluid
                      className="input-field"
                      value={title}
                      maxLength={60}
                      onChange={(value) => setTitle(value)}
                      placeholder="Нужен инженер для ремонта шлюза"
                    />
                  </Stack.Item>

                  <Stack.Item>
                    <Box className="field-label">Оплата</Box>
                    <NumberInput
                      value={reward}
                      minValue={10}
                      maxValue={account.account_balance}
                      step={50}
                      unit="кр"
                      onChange={(value) => setReward(value)}
                      className="input-field"
                    />
                  </Stack.Item>

                  <Stack.Item grow>
                    <Box className="field-label">Описание</Box>
                    <TextArea
                      fluid
                      className="input-field"
                      height="200px"
                      value={description}
                      maxLength={300}
                      onChange={(value) => setDescription(value)}
                      placeholder="Опишите задачу, место встречи и детали заказа..."
                    />
                  </Stack.Item>

                  <Stack.Item>
                    <Box className="secure-notice">
                      <Stack justify="space-between">
                        <Stack.Item className="text-muted">
                          Спишется с вашего счёта сразу
                        </Stack.Item>
                        <Stack.Item bold className="text-white">
                          {reward} кр
                        </Stack.Item>
                      </Stack>
                      <Stack justify="space-between">
                        <Stack.Item className="text-muted">
                          Получит исполнитель по завершении
                        </Stack.Item>
                        <Stack.Item bold className="text-gold">
                          {executorPreview} кр
                        </Stack.Item>
                      </Stack>
                      <Box className="text-muted" fontSize="0.8em" mt={0.5}>
                        Разницу удерживает RainDrop как комиссию за эскроу и
                        гарантию сделки.
                      </Box>
                    </Box>
                  </Stack.Item>

                  <Stack.Item>
                    <Button
                      fluid
                      className="btn-bank btn-bank--primary"
                      icon="paper-plane"
                      disabled={!title || !description || reward <= 0}
                      onClick={() => {
                        act('create_offer', { title, description, reward });
                        setTitle('');
                        setDescription('');
                        setReward(100);
                        setTab('deals');
                      }}
                      p={2}
                    >
                      <span className="text-white">Разместить предложение</span>
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
                    <Box className="secure-notice">
                      <Icon name="briefcase" mr={0.5} />У вас пока нет активных
                      сделок.
                    </Box>
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

          {tab === 'about' && (
            <Stack.Item grow>
              <Section
                title={<Box className="text-gold">О RainDrop</Box>}
                fill
                scrollable
              >
                <Box className="lore-container">
                  <Box className="lore-paragraph">
                    <Box as="span" className="lore-highlight">
                      RainDrop
                    </Box>{' '}
                    — цифровая биржа услуг на инфраструктуре{' '}
                    <Box as="span" className="lore-highlight">
                      Black Rain Group
                    </Box>
                    . Соединяет тех, кому нужна помощь, с теми, кто готов её
                    оказать за плату, и гарантирует расчёт между сторонами через
                    эскроу-счёт.
                  </Box>

                  <Box className="lore-divider">
                    <Icon
                      name="handshake"
                      size={1}
                      className="lore-icon-decor"
                    />
                    <Icon
                      name="shield-halved"
                      size={1}
                      className="lore-icon-decor"
                    />
                    <Icon
                      name="scale-balanced"
                      size={1}
                      className="lore-icon-decor"
                    />
                  </Box>

                  <Box className="section-header">
                    <Icon name="list-check" />
                    Как это работает
                  </Box>

                  <LabeledList>
                    <LabeledList.Item label="1. Заказ" className="text-white">
                      Заказчик размещает предложение, сумма награды сразу
                      замораживается на эскроу-счёте.
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="2. Исполнение"
                      className="text-white"
                    >
                      Исполнитель берёт заказ в работу и отмечает его
                      выполненным по готовности.
                    </LabeledList.Item>
                    <LabeledList.Item label="3. Приёмка" className="text-white">
                      Заказчик проверяет результат, подтверждает оплату и
                      оставляет оценку.
                    </LabeledList.Item>
                    <LabeledList.Item label="4. Спор" className="text-white">
                      Если что-то пошло не так, любая сторона может открыть спор
                      — арбитраж RainDrop разделит средства.
                    </LabeledList.Item>
                  </LabeledList>

                  <Box className="section-header">
                    <Icon name="coins" />
                    Комиссии
                  </Box>

                  <LabeledList>
                    <LabeledList.Item
                      label="Исполнителю при завершении"
                      className="text-gold"
                    >
                      80% от суммы заказа
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Возврат при отмене (пока никто не взял)"
                      className="text-gold"
                    >
                      100% от суммы заказа
                    </LabeledList.Item>
                    <LabeledList.Item label="При споре" className="text-gold">
                      40% заказчику / 20% исполнителю
                    </LabeledList.Item>
                  </LabeledList>

                  <Box className="lore-paragraph" fontSize="0.9em">
                    RainDrop — технологический посредник и не несёт
                    ответственности за качество, сроки или содержание услуг,
                    оказываемых независимыми исполнителями. Black Rain Group
                    гарантирует лишь техническую целостность платформы и
                    безопасность транзакций.
                  </Box>

                  <Box
                    textAlign="center"
                    className="text-muted"
                    fontSize="0.8em"
                  >
                    <Icon name="copyright" mr={0.5} />
                    RainDrop PDA Client v4.2 · Raingor SecureChain™
                  </Box>
                </Box>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
