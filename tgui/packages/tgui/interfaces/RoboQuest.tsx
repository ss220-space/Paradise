import { Fragment } from 'react';
import { useBackend } from '../backend';
import { useState } from 'react';
import {
  Box,
  Section,
  Button,
  Stack,
  ImageButton,
  Divider,
  DmIcon,
} from '../components';
import { Window } from '../layouts';

type RoboQuestData = {
  hasID: boolean;
  name: string;
  questInfo: QuestInfo;
  hasTask: boolean;
  canCheck: boolean;
  canSend: boolean;
  checkMessage: string;
  style: string;
  cooldown: string;
  instant_teleport: boolean;
  shopItems: Record<string, Item[]>;
  points: Points;
};

type QuestInfo = {
  name: string;
  desc: string;
  icon: string;
  icon_state: string;
  modules: Molule[];
};

type Points = {
  working: number;
  medical: number;
  security: number;
  robo: number;
};

type Item = {
  name: string;
  desc: string;
  path: string;
  icon: string;
  icon_state: string;
  cost: Points;
  emagOnly: boolean;
};

type Molule = {
  name: string;
  id: number;
  icon: string;
  icon_state: string;
};

export const RoboQuest = (_props: unknown) => {
  const { act, data } = useBackend<RoboQuestData>();
  const {
    hasID,
    name,
    questInfo,
    hasTask,
    canCheck,
    canSend,
    checkMessage,
    style,
    cooldown,
    instant_teleport,
    shopItems,
    points,
  } = data;

  const [shopState, changeShopState] = useState(false);

  const cat_to_color = {
    'medical': 'blue',
    'working': 'brown',
    'security': 'red',
    'working_medical': 'olive',
    'medical_security': 'violet',
    'working_medical_security': 'grey',
  };

  return (
    <Window theme={style} width={1000} height={540}>
      <Window.Content>
        <Stack fill>
          <Stack.Item basis={40}>
            {!shopState && (
              <Section
                fill
                title="Выбранный заказ"
                buttons={
                  <Button
                    icon="search"
                    tooltipPosition="bottom"
                    tooltip="Проверка экзокостюма на наличие необходимых для заказа модулей."
                    disabled={!hasID || !hasTask || !canCheck || !!cooldown}
                    onClick={() => act('Check')}
                  >
                    Проверка меха
                  </Button>
                }
              >
                <Stack>
                  <Stack.Item basis={120} textAlign="center" align="center">
                    {!!hasTask && (
                      <DmIcon
                        width="100%"
                        height="100%"
                        icon={questInfo.icon}
                        icon_state={questInfo.icon_state}
                      />
                    )}
                  </Stack.Item>
                  <Stack.Item>
                    <Divider vertical />
                  </Stack.Item>
                  <Stack.Item basis={42}>
                    <Stack vertical>
                      {!!hasTask &&
                        questInfo.modules.map(
                          (i) =>
                            i.id < 4 && (
                              <Stack.Item key={i.id}>
                                <DmIcon
                                  key={i.id}
                                  width="100%"
                                  height="100%"
                                  icon={i.icon}
                                  icon_state={i.icon_state}
                                />
                              </Stack.Item>
                            )
                        )}
                    </Stack>
                  </Stack.Item>
                </Stack>
                <>
                  <Divider />
                  <b>{checkMessage}</b>
                </>
                {!!cooldown && (
                  <>
                    <b>
                      За отказ от заказа, вы были отстранены от работы на
                      некоторое время.
                    </b>
                    <br />
                    <b>{cooldown}</b>
                  </>
                )}
              </Section>
            )}
            {!!shopState && (
              <Section
                fill
                title={
                  <Box>
                    Магазин чертежей
                    <Box>
                      Очки: <b style={{ color: 'brown' }}>{points.working}</b>|
                      <b style={{ color: 'teal' }}>{points.medical}</b>|
                      <b style={{ color: 'red' }}>{points.security}</b>
                    </Box>
                  </Box>
                }
              >
                {/* <Box overflowY="auto" overflowX="hiddem"> */}
                {Object.keys(shopItems).map((cat) => (
                  <Fragment key={cat}>
                    {!(
                      shopItems[cat] === undefined ||
                      shopItems[cat].length === 0 ||
                      cat === 'robo'
                    ) &&
                      shopItems[cat].map((i) => (
                        <ImageButton
                          key={i.path}
                          color={cat_to_color[cat]}
                          dmIcon={i.icon}
                          dmIconState={i.icon_state}
                          dmFallback={i.name}
                          imageSize={90}
                          tooltip={
                            <>
                              <b>{i.name}</b>
                              <br />
                              {i.desc}
                            </>
                          }
                          onClick={() =>
                            act('buyItem', {
                              item: i.path,
                            })
                          }
                        >
                          <Box
                            inline
                            backgroundColor="rgb(42.21, 3.35, 61.64)"
                            style={{
                              borderRadius: '10px',
                            }}
                            p={0.5}
                            px={3}
                          >
                            <b style={{ color: 'brown' }}>{i.cost.working}</b>|
                            <b style={{ color: 'lightblue' }}>
                              {i.cost.medical}
                            </b>
                            |<b style={{ color: 'red' }}>{i.cost.security}</b>
                          </Box>
                        </ImageButton>
                      ))}
                  </Fragment>
                ))}
              </Section>
            )}
          </Stack.Item>
          <Stack.Item basis={20}>
            <Section
              fill
              title="Другое"
              buttons={
                <>
                  <Button
                    width="7rem"
                    icon="shopping-cart"
                    onClick={() => changeShopState(!shopState)}
                  >
                    Магазин
                  </Button>
                  <Button
                    icon="cog"
                    tooltipPosition="bottom"
                    tooltip="Изменение стиля интерфейса."
                    onClick={() => act('ChangeStyle')}
                  />
                </>
              }
            >
              {!!name && (
                <>
                  Здраствуйте,
                  <br />
                  <b>{name}</b>
                  <br />
                </>
              )}

              <>
                <br />
                При получении заказа на экзкостюм, выбор подтипа меха определяет
                тип специализированных очков, которые будут начислены за
                выполнение заказа.
                <br />
                <br />
                Рабочие экзокостюмы приносят{' '}
                <Box inline color={'brown'}>
                  {' '}
                  коричневые
                </Box>{' '}
                очки. Медицинские экзокостюмы приносят{' '}
                <Box inline color={'teal'}>
                  {' '}
                  голубые
                </Box>{' '}
                очки. Боевые экзокостюмы приносят{' '}
                <Box inline color={'red'}>
                  {' '}
                  красные
                </Box>{' '}
                очки.
                <br />
                <br />
                Каждый мех, вне зависимости от подтипа, приносит некоторое
                количество очков для магазина особых наград.
              </>
            </Section>
          </Stack.Item>
          <Stack.Item basis={38}>
            {!shopState && (
              <Section
                fill
                scrollable
                title="Инфо"
                buttons={
                  <>
                    <Button
                      icon="id-card"
                      disabled={!hasID}
                      onClick={() => act('RemoveID')}
                    >
                      Вынуть ID
                    </Button>
                    {!hasTask && (
                      <Button
                        icon="arrow-down"
                        disabled={!hasID || !!cooldown}
                        onClick={() => act('GetTask')}
                      >
                        Получить мех
                      </Button>
                    )}
                    {!!hasTask && (
                      <>
                        <Button
                          content="Печать"
                          icon="print"
                          onClick={() => act('printOrder')}
                          disabled={!hasTask}
                        >
                          Печать
                        </Button>
                        <Button
                          icon="trash"
                          disabled={!hasID || !!cooldown}
                          onClick={() => act('RemoveTask')}
                        >
                          Отказаться
                        </Button>
                      </>
                    )}
                  </>
                }
              >
                <Box mx="0.5rem" mb="1rem">
                  <b>Название: </b>
                  {questInfo.name}
                  <br />
                  <b>Описание: </b>
                  {questInfo.desc}
                </Box>
                <Section title="Требуемые Модули:">
                  <Box mx="0.5rem" mb="0.5rem">
                    {!!hasTask &&
                      questInfo.modules.map((i) => (
                        <Fragment key={i.id}>
                          <b>Module {i.id}</b>: {i.name} <br />
                          <br />
                        </Fragment>
                      ))}
                  </Box>
                </Section>
                <Box mb="0.5rem" textAlign="center">
                  <Button
                    icon="arrow-up"
                    width="14rem"
                    bold
                    textAlign="center"
                    tooltipPosition="top"
                    tooltip="Отправка меха на выбранный вами телепад."
                    disabled={!hasID || !hasTask || !canSend || !!cooldown}
                    onClick={() => act('SendMech', { type: 'send' })}
                  >
                    Отправить мех
                  </Button>
                  <Button
                    icon="arrow-up"
                    width="14rem"
                    bold
                    textAlign="center"
                    tooltipPosition="top"
                    tooltip="Упаковка меха для самостоятельной доставки в карго."
                    disabled={!hasID || !hasTask || !canSend || !!cooldown}
                    onClick={() => act('SendMech', { type: 'only_packing' })}
                  >
                    Упаковать мех
                  </Button>
                </Box>
                <Box mb="1.5rem" textAlign="center">
                  <Button
                    icon="arrow-up"
                    width="30rem"
                    bold
                    textAlign="center"
                    tooltipPosition="bottom"
                    tooltip="Мгновенная телепортация меха заказчику."
                    disabled={
                      !hasID ||
                      !hasTask ||
                      !canSend ||
                      !!cooldown ||
                      !instant_teleport
                    }
                    onClick={() => act('SendMech', { type: 'instant' })}
                  >
                    Телепортировать мех
                  </Button>
                </Box>
              </Section>
            )}
            {!!shopState && (
              <Section
                fill
                scrollable
                title={
                  <>
                    Магазин особых наград
                    <Box>Очки: {points.robo}</Box>
                  </>
                }
              >
                {shopItems.robo.map(
                  (i) =>
                    (!i.emagOnly || style === 'syndicate') && (
                      <ImageButton
                        key={i.name}
                        color="purple"
                        dmIcon={i.icon}
                        dmIconState={i.icon_state}
                        imageSize={90}
                        dmFallback={i.name}
                        tooltip={
                          <>
                            <b>{i.name}</b>
                            <br />
                            {i.desc}
                          </>
                        }
                        onClick={() =>
                          act('buyItem', {
                            item: i.path,
                          })
                        }
                      >
                        {i.cost.robo}
                      </ImageButton>
                    )
                )}
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
