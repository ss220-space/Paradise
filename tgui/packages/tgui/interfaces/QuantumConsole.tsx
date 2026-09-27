import type { BooleanLike } from 'tgui-core/react';
import { useBackend, useSharedState } from '../backend';
import { Button, Collapsible, Icon, NoticeBox, ProgressBar, Section, Stack, Table, Tabs, Tooltip } from 'tgui-core/components';
import { Window } from '../layouts';

type Data =
  | {
      connected: 0;
    }
  | {
      available_domains: Domain[];
      avatars: Avatar[];
      broadcasting: BooleanLike;
      broadcasting_on_cd: BooleanLike;
      connected: 1;
      generated_domain: string | null;
      occupants: number;
      points: number;
      randomized: BooleanLike;
      ready: BooleanLike;
      retries_left: number;
      scanner_tier: number;
    };

type Avatar = {
  brute: number;
  burn: number;
  health: number;
  name: string;
  oxy: number;
  pilot: string;
  tox: number;
};

type Domain = {
  cost: number;
  desc: string;
  difficulty: number;
  id: string;
  name: string;
  reward: number | string;
};

enum Difficulty {
  None,
  Low,
  Medium,
  High,
}

const difficultyTabs = [
  { difficulty: Difficulty.None, label: 'Мирный', textColor: 'white' },
  { difficulty: Difficulty.Low, label: 'Лёгкий', textColor: 'white' },
  { difficulty: Difficulty.Medium, label: 'Средний', textColor: 'white' },
  { difficulty: Difficulty.High, label: 'Тяжёлый', textColor: 'white' },
];

const isConnected = (data: Data): data is Data & { connected: 1 } =>
  data.connected === 1;

const getColor = (difficulty: number) => {
  switch (difficulty) {
    case Difficulty.Low:
      return 'yellow';
    case Difficulty.Medium:
      return 'average';
    case Difficulty.High:
      return 'bad';
    default:
      return 'green';
  }
};

export const QuantumConsole = (_properties) => {
  return (
    <Window width={500} height={520}>
      <Window.Content>
        <AccessView />
      </Window.Content>
    </Window>
  );
};

const AccessView = (_properties) => {
  const { act, data } = useBackend<Data>();
  const [tab, setTab] = useSharedState('tab', 0);

  if (!isConnected(data)) {
    return <NoticeBox danger>Сервер не подключён!</NoticeBox>;
  }

  const {
    available_domains = [],
    broadcasting,
    broadcasting_on_cd,
    generated_domain,
    occupants,
    points,
    randomized,
    ready,
    scanner_tier,
  } = data;

  const sorted = [...available_domains].sort((a, b) => a.cost - b.cost);
  const filtered = sorted.filter((domain) => domain.difficulty === tab);

  let selected: string | undefined;
  if (!generated_domain) {
    selected = 'Ничего не загружено';
  } else if (randomized) {
    selected = '???';
  } else {
    selected = sorted.find(({ id }) => id === generated_domain)?.name;
  }

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          buttons={
            <Stack align="center">
              <Stack.Item>
                <Button.Checkbox
                  checked={broadcasting}
                  disabled={broadcasting_on_cd}
                  onClick={() => act('broadcast')}
                  tooltip="Транслировать происходящее в домене на развлекательные мониторы станции."
                >
                  Трансляция
                </Button.Checkbox>
              </Stack.Item>
              <Stack.Item>
                <Button
                  disabled={
                    !ready || occupants > 0 || points < 1 || !!generated_domain
                  }
                  icon="random"
                  onClick={() => act('random_domain')}
                  tooltip="Случайный домен по карману сервера. Награда выше, но что внутри — сюрприз."
                >
                  Наугад
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Tooltip content="Уровень сканера. Чем он выше, тем больше видно о сложных доменах.">
                  <Icon color="blue" name="satellite-dish" mr={1} />
                </Tooltip>
                {scanner_tier}
              </Stack.Item>
              <Stack.Item>
                <Tooltip content="Накопленные очки на сборку доменов.">
                  <Icon color="pink" name="star" mr={1} />
                </Tooltip>
                {points}
              </Stack.Item>
            </Stack>
          }
          fill
          scrollable
          title="Виртуальные домены"
        >
          <Tabs fluid>
            {difficultyTabs.map(({ difficulty, label, textColor }) => (
              <Tabs.Tab
                backgroundColor={getColor(difficulty)}
                icon="chevron-down"
                key={difficulty}
                onClick={() => setTab(difficulty)}
                selected={tab === difficulty}
                textColor={textColor}
              >
                {label}
              </Tabs.Tab>
            ))}
          </Tabs>
          {filtered.length === 0 ? (
            <NoticeBox>Домены этой сложности не найдены.</NoticeBox>
          ) : (
            filtered.map((domain) => (
              <DomainEntry key={domain.id} domain={domain} />
            ))
          )}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <AvatarDisplay />
      </Stack.Item>
      <Stack.Item>
        <Section>
          <Stack align="center">
            <Stack.Item grow>
              <NoticeBox info={!!generated_domain} mb={0}>
                {ready ? selected : 'Сервер остывает...'}
              </NoticeBox>
            </Stack.Item>
            <Stack.Item>
              <Button.Confirm
                disabled={!ready || !generated_domain}
                onClick={() => act('stop_domain')}
                tooltip="Начинает отключение. Всех подключённых предупредят."
              >
                Остановить домен
              </Button.Confirm>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const DomainEntry = (properties: { domain: Domain }) => {
  const { act, data } = useBackend<Data>();
  const {
    domain: { cost, desc, difficulty, id, name, reward },
  } = properties;

  if (!isConnected(data)) {
    return null;
  }

  const { generated_domain, occupants, points, randomized, ready } = data;
  const current = generated_domain === id;

  let buttonIcon: string | undefined;
  let buttonName: string;
  if (randomized) {
    buttonName = '???';
  } else if (current) {
    buttonIcon = 'download';
    buttonName = 'Собран';
  } else {
    buttonIcon = 'coins';
    buttonName = 'Собрать';
  }

  return (
    <Collapsible
      buttons={
        <Button
          disabled={
            !!generated_domain || !ready || occupants > 0 || points < cost
          }
          icon={buttonIcon}
          onClick={() => act('set_domain', { id })}
          tooltip={generated_domain && 'Сначала остановите текущий домен.'}
        >
          {buttonName}
        </Button>
      }
      color={getColor(difficulty)}
      textColor="white"
      title={name}
    >
      <Stack>
        <Stack.Item color="label" grow={4}>
          {desc}
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <Table>
            <Table.Row>
              <Tooltip content="Цена сборки домена.">
                <DisplayDetails amount={cost} color="pink" icon="star" />
              </Tooltip>
            </Table.Row>
            <Table.Row>
              <Tooltip content="Награда за выполненный домен.">
                <DisplayDetails amount={reward} color="gold" icon="coins" />
              </Tooltip>
            </Table.Row>
          </Table>
        </Stack.Item>
      </Stack>
    </Collapsible>
  );
};

const AvatarDisplay = (_properties) => {
  const { data } = useBackend<Data>();

  if (!isConnected(data)) {
    return null;
  }

  const { avatars = [], generated_domain, retries_left } = data;

  return (
    <Section
      title="Подключённые клиенты"
      buttons={
        !!generated_domain && (
          <Tooltip content="Свободный канал для новых подключений.">
            <DisplayDetails
              amount={retries_left}
              color="green"
              icon="broadcast-tower"
            />
          </Tooltip>
        )
      }
    >
      {avatars.length === 0 ? (
        <NoticeBox mb={0}>Никто не подключён.</NoticeBox>
      ) : (
        <Table>
          {avatars.map(({ brute, burn, health, name, oxy, pilot, tox }) => (
            <Table.Row key={name}>
              <Table.Cell color="label">
                {pilot} под именем{' '}
                <span style={{ color: 'white' }}>&quot;{name}&quot;</span>
              </Table.Cell>
              <Table.Cell collapsing>
                <Stack>
                  <Stack.Item>
                    <Icon color={brute > 50 ? 'bad' : 'gray'} name="tint" />
                  </Stack.Item>
                  <Stack.Item>
                    <Icon color={burn > 50 ? 'average' : 'gray'} name="fire" />
                  </Stack.Item>
                  <Stack.Item>
                    <Icon
                      color={tox > 50 ? 'green' : 'gray'}
                      name="skull-crossbones"
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Icon color={oxy > 50 ? 'blue' : 'gray'} name="lungs" />
                  </Stack.Item>
                </Stack>
              </Table.Cell>
              <Table.Cell>
                <ProgressBar
                  minValue={-100}
                  maxValue={100}
                  ranges={{
                    good: [90, Infinity],
                    average: [50, 89],
                    bad: [-Infinity, 45],
                  }}
                  value={health}
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};

const DisplayDetails = (properties: {
  amount: number | string;
  color: string;
  icon: string;
}) => {
  const { amount, color, icon } = properties;

  if (typeof amount === 'string') {
    return <Table.Cell color="label">{amount}</Table.Cell>;
  }

  if (amount === 0) {
    return <Table.Cell color="label">Нет</Table.Cell>;
  }

  if (amount > 4) {
    return (
      <Table.Cell>
        <Stack>
          <Stack.Item>{amount}</Stack.Item>
          <Stack.Item>
            <Icon color={color} name={icon} />
          </Stack.Item>
        </Stack>
      </Table.Cell>
    );
  }

  return (
    <Table.Cell>
      <Stack>
        {Array.from({ length: amount }, (_unused, index) => (
          <Stack.Item key={index}>
            <Icon color={color} name={icon} />
          </Stack.Item>
        ))}
      </Stack>
    </Table.Cell>
  );
};
