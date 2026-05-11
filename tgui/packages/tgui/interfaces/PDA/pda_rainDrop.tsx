import { useBackend } from '../../backend';
import {
  Box,
  Button,
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
import { useState } from 'react';

type Account = {
  name: string;
  account_number: number;
  rating: number;
  rating_count: number;
};

type Offer = {
  id: string;
  title: string;
  description: string;
  reward: number;
  status: string;

  client?: Account;
  worker?: Account;
};

type Data = {
  account: Account;
  offers: Offer[];
};

const OFFER_STATUS_COLOR = {
  open: 'good',
  taken: 'average',
  completed: 'good',
  cancelled: 'bad',
  disputed: 'bad',
};

const OFFER_STATUS_TEXT = {
  open: 'Открыт',
  taken: 'В работе',
  completed: 'Завершен',
  cancelled: 'Отменен',
  disputed: 'Спор',
};
const PDA_UI = {
  window: {
    width: 580,
    height: 850,
  },
};
export const pda_rainDrop = (props: unknown) => {
  const { act, data } = useBackend<Data>();

  const { account, offers = [] } = data;

  const [tab, setTab] = useState('market');

  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [reward, setReward] = useState(100);
  const [ratings, setRatings] = useState<Record<string, number>>({});
  if (!account) {
    return (
      <Window
        width={PDA_UI.window.width}
        height={PDA_UI.window.height}
        theme="ntos_darkmode"
      >
        <Window.Content>
          <Section>
            <NoticeBox>Загрузка аккаунта...</NoticeBox>
          </Section>
        </Window.Content>
      </Window>
    );
  }
  const renderRatingStars = (offerId: string) => {
    const currentRating = ratings[offerId] ?? 5;

    return (
      <Stack>
        {[1, 2, 3, 4, 5].map((star) => (
          <Stack.Item key={star}>
            <Button
              compact
              icon={star <= currentRating ? 'star' : 'star-o'}
              color={star <= currentRating ? 'yellow' : 'label'}
              onClick={() =>
                setRatings({
                  ...ratings,
                  [offerId]: star,
                })
              }
            />
          </Stack.Item>
        ))}
      </Stack>
    );
  };
  return (
    <Window
      width={PDA_UI.window.width}
      height={PDA_UI.window.height}
      theme="ntos_darkmode"
    >
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack align="center">
                <Stack.Item grow>
                  <Box fontSize={1.4} bold>
                    RainDrop
                  </Box>
                  <Box color="label">Безопасная биржа услуг</Box>
                </Stack.Item>

                <Stack.Item>
                  <Box textAlign="right">
                    <Box bold>{account.name}</Box>
                    <Box color="label">#{account.account_number}</Box>
                    <Box color="yellow">
                      ★ {account.rating} ({account.rating_count})
                    </Box>
                  </Box>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                selected={tab === 'market'}
                onClick={() => setTab('market')}
              >
                Биржа
              </Tabs.Tab>

              <Tabs.Tab
                selected={tab === 'create'}
                onClick={() => setTab('create')}
              >
                Создать
              </Tabs.Tab>

              <Tabs.Tab selected={tab === 'my'} onClick={() => setTab('my')}>
                Мои сделки
              </Tabs.Tab>

              <Tabs.Tab
                selected={tab === 'about'}
                onClick={() => setTab('about')}
              >
                О сервисе
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>

          {tab === 'market' && (
            <Stack.Item grow>
              <Section title="Доступные предложения" fill>
                {!offers.length && (
                  <NoticeBox>На бирже пока нет предложений.</NoticeBox>
                )}

                <Stack vertical>
                  {offers.map((offer) => (
                    <Stack.Item key={offer.id}>
                      <Section
                        title={offer.title}
                        buttons={
                          <Box
                            color={OFFER_STATUS_COLOR[offer.status] || 'label'}
                          >
                            {OFFER_STATUS_TEXT[offer.status] || offer.status}
                          </Box>
                        }
                      >
                        <Stack vertical>
                          <Stack.Item>
                            <Box color="label">{offer.description}</Box>
                          </Stack.Item>

                          <Stack.Item>
                            <LabeledList>
                              <LabeledList.Item label="Награда">
                                {offer.reward} cr
                              </LabeledList.Item>

                              <LabeledList.Item label="Заказчик">
                                {offer.client?.name || 'Неизвестно'}
                              </LabeledList.Item>

                              {offer.worker && (
                                <LabeledList.Item label="Исполнитель">
                                  {offer.worker.name}
                                </LabeledList.Item>
                              )}
                            </LabeledList>
                          </Stack.Item>

                          <Stack.Item>
                            <Stack>
                              {offer.status === 'open' && (
                                <Stack.Item grow>
                                  <Button
                                    fluid
                                    color="good"
                                    icon="handshake"
                                    onClick={() =>
                                      act('take_offer', {
                                        id: offer.id,
                                      })
                                    }
                                  >
                                    Взять заказ
                                  </Button>
                                </Stack.Item>
                              )}

                              {offer.status === 'taken' && (
                                <>
                                  <>
                                    <Stack.Item>
                                      <NumberInput
                                        width="65px"
                                        value={ratings[offer.id] ?? 5}
                                        minValue={0}
                                        maxValue={5}
                                        step={1}
                                        onChange={(value) =>
                                          setRatings({
                                            ...ratings,
                                            [offer.id]: Number(value),
                                          })
                                        }
                                      />
                                    </Stack.Item>

                                    <Stack.Item grow>
                                      <Stack vertical>
                                        <Stack.Item>
                                          <Box mb={0.5} color="label">
                                            Оценка исполнителя
                                          </Box>

                                          {renderRatingStars(offer.id)}
                                        </Stack.Item>

                                        <Stack.Item mt={1}>
                                          <Button
                                            fluid
                                            color="good"
                                            icon="check"
                                            onClick={() =>
                                              act('complete_offer', {
                                                id: offer.id,
                                                rating: ratings[offer.id] ?? 5,
                                              })
                                            }
                                          >
                                            Завершить
                                          </Button>
                                        </Stack.Item>
                                      </Stack>
                                    </Stack.Item>
                                  </>

                                  <Stack.Item grow>
                                    <Button
                                      fluid
                                      color="bad"
                                      icon="gavel"
                                      onClick={() =>
                                        act('dispute_offer', {
                                          id: offer.id,
                                        })
                                      }
                                    >
                                      Спор
                                    </Button>
                                  </Stack.Item>
                                </>
                              )}

                              {(offer.status === 'open' ||
                                offer.status === 'taken') && (
                                <Stack.Item grow>
                                  <Button
                                    fluid
                                    color="average"
                                    icon="times"
                                    onClick={() =>
                                      act('cancel_offer', {
                                        id: offer.id,
                                      })
                                    }
                                  >
                                    Отменить
                                  </Button>
                                </Stack.Item>
                              )}
                            </Stack>
                          </Stack.Item>
                        </Stack>
                      </Section>
                    </Stack.Item>
                  ))}
                </Stack>
              </Section>
            </Stack.Item>
          )}

          {tab === 'create' && (
            <Stack.Item grow>
              <Section title="Создание предложения" fill>
                <Stack vertical>
                  <Stack.Item>
                    <LabeledList>
                      <LabeledList.Item label="Название">
                        <Input
                          fluid
                          value={title}
                          onChange={(value) => setTitle(value)}
                          placeholder="Нужен инженер для ремонта шлюза"
                        />
                      </LabeledList.Item>

                      <LabeledList.Item label="Оплата">
                        <NumberInput
                          fluid
                          value={reward}
                          minValue={1}
                          maxValue={100000}
                          step={50}
                          onChange={(value) => setReward(value)}
                        />
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>

                  <Stack.Item grow>
                    <Box mb={1} bold>
                      Описание
                    </Box>

                    <TextArea
                      fluid
                      height="220px"
                      value={description}
                      onChange={(value) => setDescription(value)}
                      placeholder="Опишите задачу, место встречи и детали заказа..."
                    />
                  </Stack.Item>

                  <Stack.Item>
                    <Button
                      fluid
                      color="good"
                      icon="plus"
                      disabled={!title || !description || reward <= 0}
                      onClick={() => {
                        act('create_offer', {
                          title,
                          description,
                          reward,
                        });

                        setTitle('');
                        setDescription('');
                        setReward(100);
                      }}
                    >
                      Создать предложение
                    </Button>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
          )}

          {tab === 'my' && (
            <Stack.Item grow>
              <Section title="Мои сделки" fill>
                <Stack vertical>
                  {offers
                    .filter((offer) => {
                      return (
                        offer.client?.account_number ===
                          account.account_number ||
                        offer.worker?.account_number === account.account_number
                      );
                    })
                    .map((offer) => (
                      <Stack.Item key={offer.id}>
                        <Section
                          title={offer.title}
                          buttons={
                            <Box
                              color={
                                OFFER_STATUS_COLOR[offer.status] || 'label'
                              }
                            >
                              {OFFER_STATUS_TEXT[offer.status] || offer.status}
                            </Box>
                          }
                        >
                          <Stack vertical>
                            <Stack.Item>
                              <Box color="label">{offer.description}</Box>
                            </Stack.Item>

                            <Stack.Item>
                              <LabeledList>
                                <LabeledList.Item label="Награда">
                                  {offer.reward} cr
                                </LabeledList.Item>

                                <LabeledList.Item label="Заказчик">
                                  {offer.client?.name || 'Неизвестно'}
                                </LabeledList.Item>

                                <LabeledList.Item label="Исполнитель">
                                  {offer.worker?.name || 'Не назначен'}
                                </LabeledList.Item>
                              </LabeledList>
                            </Stack.Item>

                            <Stack.Item>
                              <Stack>
                                {offer.status === 'taken' && (
                                  <>
                                    <Stack.Item grow>
                                      <Stack vertical>
                                        <Stack.Item>
                                          <Box mb={0.5} color="label">
                                            Оценка исполнителя
                                          </Box>

                                          {renderRatingStars(offer.id)}
                                        </Stack.Item>

                                        <Stack.Item mt={1}>
                                          <Button
                                            fluid
                                            color="good"
                                            icon="check"
                                            onClick={() =>
                                              act('complete_offer', {
                                                id: offer.id,
                                                rating: ratings[offer.id] ?? 5,
                                              })
                                            }
                                          >
                                            Завершить
                                          </Button>
                                        </Stack.Item>
                                      </Stack>
                                    </Stack.Item>

                                    <Stack.Item grow>
                                      <Button
                                        fluid
                                        color="bad"
                                        icon="gavel"
                                        onClick={() =>
                                          act('dispute_offer', {
                                            id: offer.id,
                                          })
                                        }
                                      >
                                        Спор
                                      </Button>
                                    </Stack.Item>
                                  </>
                                )}

                                {(offer.status === 'open' ||
                                  offer.status === 'taken') && (
                                  <Stack.Item grow>
                                    <Button
                                      fluid
                                      color="average"
                                      icon="times"
                                      onClick={() =>
                                        act('cancel_offer', {
                                          id: offer.id,
                                        })
                                      }
                                    >
                                      Отменить
                                    </Button>
                                  </Stack.Item>
                                )}
                              </Stack>
                            </Stack.Item>
                          </Stack>
                        </Section>
                      </Stack.Item>
                    ))}

                  {!offers.filter((offer) => {
                    return (
                      offer.client?.account_number === account.account_number ||
                      offer.worker?.account_number === account.account_number
                    );
                  }).length && (
                    <NoticeBox>У вас пока нет активных сделок.</NoticeBox>
                  )}
                </Stack>
              </Section>
            </Stack.Item>
          )}

          {tab === 'about' && (
            <Stack.Item grow>
              <Section title="О RainDrop" fill scrollable>
                <Stack vertical>
                  <Stack.Item>
                    <NoticeBox info>
                      RainDrop — цифровая платформа биржи услуг, функционирующая
                      на инфраструктуре Black Rain Group.
                    </NoticeBox>
                  </Stack.Item>

                  <Stack.Item>
                    <Box>
                      Платформа предоставляет экипажам станций NanoTrasen и
                      гражданским секторам инструменты для безопасного
                      взаимодействия: поиска исполнителей, заключения
                      микро-контрактов и проведения платежей. Мы не нанимаем
                      специалистов напрямую. Мы предоставляем среду, где
                      репутация каждого участника прозрачна, а финансовые
                      операции защищены протоколами Raingor Interstellar Bank.
                      Благодаря системе верификации Raingor Interstellar Bank,
                      каждый исполнитель имеет свой рейтинг, а каждая сделка
                      защищена финансовыми гарантиями холдинга. Эффективность.
                      Безопасность. Результат.
                    </Box>
                  </Stack.Item>

                  <Stack.Item>
                    <Section title="Почему RainDrop?">
                      <LabeledList>
                        <LabeledList.Item label="Рейтинговая система">
                          Качество услуг определяется исключительно отзывами
                          сообщества. Изучайте историю исполнителя перед
                          заключением сделки.
                        </LabeledList.Item>

                        <LabeledList.Item label="Финансовая защита">
                          Средства резервируются на эскроу-счетах Raingor Bank
                          до подтверждения выполнения заказа.
                        </LabeledList.Item>

                        <LabeledList.Item label="Безопасность данных">
                          Интеграция с RIB обеспечивает шифрование переписки и
                          защиту персональных данных согласно стандартам BRG.
                        </LabeledList.Item>
                      </LabeledList>
                    </Section>
                  </Stack.Item>

                  <Stack.Item>
                    <Section title="Юридическая информация">
                      <Box color="label">
                        RainDrop является технологическим посредником и не несет
                        ответственности за качество, сроки или содержание услуг,
                        оказываемых независимыми исполнителями. Вся
                        ответственность за результат сделки лежит на сторонах
                        контракта. Black Rain Group гарантирует лишь техническую
                        целостность платформы и безопасность финансовых
                        транзакций в рамках действующего законодательства.
                        Использование сервиса подразумевает согласие с
                        Пользовательским соглашением BRG v4.2.
                      </Box>
                    </Section>
                  </Stack.Item>

                  <Stack.Item>
                    <Section title="Версия клиента">
                      <Box>RainDrop PDA Client v1.9.8.4</Box>
                      <Box color="label">
                        Защищён протоколом Raingor SecureChain™
                      </Box>
                    </Section>
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
