import { rad2deg } from 'common/math';
import { Component, Fragment, ReactNode } from 'react';
import { useBackend } from '../backend';
import { useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Icon,
  Image,
  LabeledList,
  Modal,
  Section,
  Tabs,
} from '../components';
import { Countdown } from '../components/Countdown';
import { Window } from '../layouts';
import { SectionProps } from '../components/Section';
import { BoxProps } from '../components/Box';
import { TabsProps } from '../components/Tabs';

const contractStatuses = {
  1: ['АКТИВЕН', 'good'],
  2: ['ЗАВЕРШЁН', 'good'],
  3: ['ПРОВАЛЕН', 'bad'],
};

// Lifted from /tg/station
const terminalMessages = [
  'Запись биометрических данных...',
  'Анализ встроенной информации о Синдикате...',
  'СТАТУС ПОДТВЕРЖДЁН',
  'Обращение к базе данных Синдиката...',
  'Ожидание ответа...',
  'Ожидание ответа...',
  'Ожидание ответа...',
  'Ожидание ответа...',
  'Ожидание ответа...',
  'Ожидание ответа...',
  'Получен ответ, код подтверждения ' +
    Math.round(Math.random() * 25500) +
    '...',
  'АККАУНТ ПОДТВЕРЖДЁН ' + Math.round(Math.random() * 20000),
  'Создание личной учётной записи...',
  'СОЗДАНА УЧЕТНАЯ ЗАПИСЬ КОНТРАКТНИКА',
  'Поиск доступных контрактов...',
  'Поиск доступных контрактов...',
  'Поиск доступных контрактов...',
  'Поиск доступных контрактов...',
  'КОНТРАКТЫ НАЙДЕНЫ',
  'ДОБРО ПОЖАЛОВАТЬ, АГЕНТ',
];

type ContractorData = {
  unauthorized: boolean;
  load_animation_completed: boolean;
  page: number;
  tc_available: number;
  tc_paid_out: number;
  completed_contracts: number;
  rep: number;
  contracts: Contract[];
  contract_active: boolean;
  can_extract: boolean;
  buyables: Buyable[];
};

type Buyable = {
  name: string;
  cost: number;
  uid: string;
  refundable: boolean;
  stock: number;
  description: string;
};

type Contract = {
  status: number;
  time_left: number;
  uid: string;
  target_name: string;
  has_photo: boolean;
  fluff_message: string;
  completed_time?: string;
  dead_extraction: boolean;
  fail_reason?: string;
  difficulties: Difficulty[];
  objective: Objective;
};

type Location = {
  user_area_id: string;
  target_area_id: string;
  user_coords: number[];
  target_coords: number[];
};

type Difficulty = {
  name: string;
  reward: number;
};

type Objective = {
  rewards: Reward;
  extraction_name: string;
  locs: Location;
};

type Reward = {
  tc: number;
  credits: number;
};

export const Contractor = (properties) => {
  const { act, data } = useBackend<ContractorData>();
  let body: ReactNode;
  if (data.unauthorized) {
    body = (
      <Flex.Item grow="1" backgroundColor="rgba(0, 0, 0, 0.8)">
        <FakeTerminal
          height="100%"
          allMessages={['ОШИБКА: НЕАВТОРИЗОВАННЫЙ ПОЛЬЗОВАТЕЛЬ']}
          finishedTimeout={100}
          onFinished={() => {}}
        />
      </Flex.Item>
    );
  } else if (!data.load_animation_completed) {
    body = (
      <Flex.Item grow="1" backgroundColor="rgba(0, 0, 0, 0.8)">
        <FakeTerminal
          height="100%"
          allMessages={terminalMessages}
          finishedTimeout={3000}
          onFinished={() => act('complete_load_animation')}
        />
      </Flex.Item>
    );
  } else {
    body = (
      <>
        <Flex.Item basis="content">
          <Summary />
        </Flex.Item>
        <Flex.Item basis="content" mt="0.5rem">
          <Navigation />
        </Flex.Item>
        <Flex.Item grow="1" overflow="hidden">
          {data.page === 1 ? (
            <Contracts height="100%" />
          ) : (
            <Hub height="100%" />
          )}
        </Flex.Item>
      </>
    );
  }
  const [viewingPhoto, _setViewingPhoto] = useState('');
  return (
    <Window width={600} height={800} theme="syndicate">
      {viewingPhoto && <PhotoZoom />}
      <Window.Content className="Contractor">
        <Flex direction="column" height="100%">
          {body}
        </Flex>
      </Window.Content>
    </Window>
  );
};

const Summary = (properties: SectionProps) => {
  const { act, data } = useBackend<ContractorData>();
  const { tc_available, tc_paid_out, completed_contracts, rep } = data;
  return (
    <Section
      title="Сводка"
      buttons={
        <Box verticalAlign="middle" mt="0.25rem">
          Очки репутации: {rep}
        </Box>
      }
      {...properties}
    >
      <Flex>
        <Box style={{ flexBasis: '50%' }}>
          <LabeledList>
            <LabeledList.Item label="Доступные ТК">
              <Flex align="center" height="5px">
                <Flex.Item grow="1">{tc_available} ТК</Flex.Item>
                <Button
                  disabled={tc_available <= 0}
                  mx={0.75}
                  mb="0"
                  style={{ flexBasis: 'content' }}
                  onClick={() => act('claim')}
                >
                  Забрать
                </Button>
              </Flex>
            </LabeledList.Item>
            <LabeledList.Item label="Заработано ТК" verticalAlign="middle">
              {tc_paid_out} ТК
            </LabeledList.Item>
          </LabeledList>
        </Box>
        <Box style={{ flexBasis: '50%' }}>
          <LabeledList>
            <LabeledList.Item
              label="Завершённые контракты"
              verticalAlign="middle"
            >
              <Box height="5px" lineHeight="20px" inline>
                {completed_contracts}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item
              label="Статус Контрактника"
              verticalAlign="middle"
            >
              АКТИВЕН
            </LabeledList.Item>
          </LabeledList>
        </Box>
      </Flex>
    </Section>
  );
};

const Navigation = (properties: TabsProps) => {
  const { act, data } = useBackend<ContractorData>();
  const { page } = data;
  return (
    <Tabs {...properties}>
      <Tabs.Tab
        selected={page === 1}
        mr={0.5}
        onClick={() =>
          act('page', {
            page: 1,
          })
        }
      >
        <Icon name="suitcase" mr={1} />
        Контракты
      </Tabs.Tab>
      <Tabs.Tab
        selected={page === 2}
        onClick={() =>
          act('page', {
            page: 2,
          })
        }
      >
        <Icon name="shopping-cart" mr={1} />
        Магазин
      </Tabs.Tab>
    </Tabs>
  );
};

const Contracts = (properties: SectionProps) => {
  const { act, data } = useBackend<ContractorData>();
  const { contracts, contract_active, can_extract } = data;
  const activeContract =
    !!contract_active && contracts.filter((c) => c.status === 1)[0];
  const extractionCooldown = activeContract && activeContract.time_left > 0;
  const [_viewingPhoto, setViewingPhoto] = useState('');
  return (
    <Section
      title="Доступные контракты"
      overflow="auto"
      buttons={
        <Button
          disabled={!can_extract || extractionCooldown}
          icon="parachute-box"
          onClick={() => act('extract')}
        >
          {[
            'Начать эвакуацию',
            extractionCooldown && (
              <Countdown
                timeLeft={activeContract.time_left}
                format={(v, f) => ' (' + f.substring(3) + ')'}
              />
            ),
          ]}
        </Button>
      }
      {...properties}
    >
      {contracts
        .slice()
        .sort((a, b) => {
          if (a.status === 1) {
            return -1;
          } else if (b.status === 1) {
            return 1;
          } else {
            return a.status - b.status;
          }
        })
        .map((contract) => (
          <Section
            key={contract.uid}
            title={
              <Flex>
                <Flex.Item grow="1" color={contract.status === 1 && 'good'}>
                  {contract.target_name}
                </Flex.Item>
                <Flex.Item basis="content">
                  {contract.has_photo && (
                    <Button
                      icon="camera"
                      mb="-0.5rem"
                      ml="0.5rem"
                      onClick={() =>
                        setViewingPhoto('target_photo_' + contract.uid + '.png')
                      }
                    />
                  )}
                </Flex.Item>
              </Flex>
            }
            className="Contractor__Contract"
            buttons={
              <Box width="100%">
                {!!contractStatuses[contract.status] && (
                  <Box
                    color={contractStatuses[contract.status][1]}
                    inline
                    mt={contract.status !== 1 && '0.125rem'}
                    mr="0.25rem"
                    lineHeight="20px"
                  >
                    {contractStatuses[contract.status][0]}
                  </Box>
                )}
                {contract.status === 1 && (
                  <Button.Confirm
                    icon="ban"
                    color="bad"
                    ml="0.5rem"
                    onClick={() => act('abort')}
                  >
                    Отказаться
                  </Button.Confirm>
                )}
              </Box>
            }
          >
            <Flex>
              <Flex.Item grow="2" mr="0.5rem">
                {contract.fluff_message}
                {!!contract.completed_time && (
                  <Box color="good">
                    <br />
                    <Icon name="check" mr="0.5rem" />
                    Контракт, выполнен в {contract.completed_time}
                  </Box>
                )}
                {!!contract.dead_extraction && (
                  <Box color="bad" mt="0.5rem" bold>
                    <Icon name="exclamation-triangle" mr="0.5rem" />
                    Награда в виде телекристаллов существенно уменьшилась, так
                    как цель была мертва в момент эвакуации.
                  </Box>
                )}
                {!!contract.fail_reason && (
                  <Box color="bad">
                    <br />
                    <Icon name="times" mr="0.5rem" />
                    Контракт не выполнен: {contract.fail_reason}
                  </Box>
                )}
              </Flex.Item>
              <Flex.Item flexBasis="100%">
                <Flex mb="0.5rem" color="label">
                  Зона эвакуации:&nbsp;
                  {areaArrow(contract)}
                </Flex>
                {contract.difficulties?.map((difficulty, key) => (
                  <Button.Confirm
                    key={key}
                    disabled={!!contract_active}
                    onClick={() =>
                      act('activate', {
                        uid: contract.uid,
                        difficulty: key + 1,
                      })
                    }
                  >
                    {difficulty.name + ' (' + difficulty.reward + ' ТК)'}
                  </Button.Confirm>
                ))}
                {!!contract.objective && (
                  <Box color="white" bold>
                    {contract.objective.extraction_name}
                    <br />({(contract.objective.rewards.tc || 0) + ' ТК'},&nbsp;
                    {(contract.objective.rewards.credits || 0) + ' Кредитов'})
                  </Box>
                )}
              </Flex.Item>
            </Flex>
          </Section>
        ))}
    </Section>
  );
};

const areaArrow = (contract: Contract) => {
  if (!contract.objective || contract.status > 1) {
    return;
  } else {
    const current_area_id = contract.objective.locs.user_area_id;
    const c_coords = contract.objective.locs.user_coords;
    const target_area_id = contract.objective.locs.target_area_id;
    const t_coords = contract.objective.locs.target_coords;
    const same_area = current_area_id === target_area_id;
    return (
      <Flex.Item>
        <Icon
          name={same_area ? 'dot-circle-o' : 'arrow-alt-circle-right-o'}
          color={same_area ? 'green' : 'yellow'}
          rotation={
            same_area
              ? null
              : -rad2deg(
                  Math.atan2(
                    t_coords[1] - c_coords[1],
                    t_coords[0] - c_coords[0]
                  )
                )
          }
          lineHeight={same_area ? null : '0.85'} // Needed because it jumps upwards otherwise
          size={1.5}
        />
      </Flex.Item>
    );
  }
};

const Hub = (properties: SectionProps) => {
  const { act, data } = useBackend<ContractorData>();
  const { rep, buyables } = data;
  return (
    <Section title="Доступные товары" overflow="auto" {...properties}>
      {buyables.map((buyable) => (
        <Section
          key={buyable.uid}
          title={buyable.name}
          buttons={
            !!buyable.refundable && (
              <Button.Confirm
                onClick={() =>
                  act('refund', {
                    uid: buyable.uid,
                  })
                }
              >
                {'Возврат (' + buyable.cost + ' репутации)'}
              </Button.Confirm>
            )
          }
        >
          {buyable.description}
          <br />
          <Button.Confirm
            disabled={rep < buyable.cost || buyable.stock === 0}
            icon="shopping-cart"
            mt="0.5rem"
            onClick={() =>
              act('purchase', {
                uid: buyable.uid,
              })
            }
          >
            {'Купить (' + buyable.cost + ' репутации)'}
          </Button.Confirm>
          {buyable.stock > -1 && (
            <Box as="span" color={!buyable.stock ? 'bad' : 'good'} ml="0.5rem">
              {buyable.stock} в наличии
            </Box>
          )}
        </Section>
      ))}
    </Section>
  );
};

type FakeTerminalProps = {
  allMessages: string[];
  linesPerSecond?: number;
  finishedTimeout: number;
  onFinished: () => void;
} & BoxProps;

type FakeTerminalState = {
  currentIndex: number;
  currentDisplay: string[];
};

// Lifted from /tg/station
class FakeTerminal extends Component<FakeTerminalProps, FakeTerminalState> {
  timer: NodeJS.Timeout;
  constructor(props: FakeTerminalProps) {
    super(props);
    this.timer = null;
    this.state = {
      currentIndex: 0,
      currentDisplay: [],
    };
  }

  tick() {
    const { props, state } = this;
    if (state.currentIndex <= props.allMessages.length) {
      this.setState((prevState) => {
        return {
          currentIndex: prevState.currentIndex + 1,
        };
      });
      const { currentDisplay } = state;
      currentDisplay.push(props.allMessages[state.currentIndex]);
    } else {
      clearTimeout(this.timer);
      setTimeout(props.onFinished, props.finishedTimeout);
    }
  }

  componentDidMount() {
    const { linesPerSecond = 2.5 } = this.props;
    this.timer = setInterval(() => this.tick(), 1000 / linesPerSecond);
  }

  componentWillUnmount() {
    clearTimeout(this.timer);
  }

  render() {
    return (
      <Box m={1}>
        {this.state.currentDisplay.map((value) => (
          <Fragment key={value}>
            {value}
            <br />
          </Fragment>
        ))}
      </Box>
    );
  }
}

const PhotoZoom = (properties) => {
  const [viewingPhoto, setViewingPhoto] = useState('');
  return (
    <Modal className="Contractor__photoZoom">
      <Image src={viewingPhoto} />
      <Button
        icon="times"
        color="grey"
        mt="1rem"
        onClick={() => setViewingPhoto('')}
      >
        Закрыть
      </Button>
    </Modal>
  );
};
