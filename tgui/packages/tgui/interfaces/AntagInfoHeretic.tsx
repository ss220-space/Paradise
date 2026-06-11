import { useState } from 'react';
import { Box, Button, DmIcon, Flex, Section, Stack, Tabs } from '../components';
import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const hereticRed = {
  color: '#e03c3c',
};

const hereticBlue = {
  fontWeight: 'bold',
  color: '#2185d0',
};

const hereticPurple = {
  fontWeight: 'bold',
  color: '#bd54e0',
};

const hereticGreen = {
  fontWeight: 'bold',
  color: '#20b142',
};

const hereticYellow = {
  fontWeight: 'bold',
  color: 'yellow',
};

type IconParams = {
  icon: string;
  state: string;
  frame: number;
  dir: number;
  moving: BooleanLike;
};

type Knowledge = {
  path: string;
  icon_params: IconParams;
  name: string;
  desc: string;
  gainFlavor: string;
  cost: number;
  bgr: string;
  depth: number;
  disabled: BooleanLike;
  finished: BooleanLike;
  ascension: BooleanLike;
};

type KnowledgeTier = {
  nodes: Knowledge[];
};

type Passive = {
  name: string;
  description: string[];
};

type HereticPath = {
  route: string;
  complexity: string;
  complexity_color: string;
  description: string[];
  pros: string[];
  cons: string[];
  tips: string[];
  passive?: Passive;
  starting_knowledge: Knowledge;
  preview_abilities: Knowledge[];
};

type Info = {
  charges: number;
  total_sacrifices: number;
  ascended: BooleanLike;
  knowledge_tiers: KnowledgeTier[];
  knowledge_shop: Knowledge[];
  passive_level: number;
  paths: HereticPath[];
};

const declension = (n: number, one: string, few: string, many: string) => {
  const mod10 = n % 10;
  const mod100 = n % 100;
  if (mod10 === 1 && mod100 !== 11) {
    return one;
  }
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
    return few;
  }
  return many;
};

const IntroductionSection = (props) => {
  return (
    <Stack justify="space-evenly" height="100%" width="100%">
      <Stack.Item grow>
        <Section title="Вы Еретик!" fill fontSize="14px">
          <Stack vertical>
            <FlavorSection />
            <Stack.Divider />
            <GuideSection />
            <Stack.Divider />
            <InformationSection />
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const FlavorSection = () => {
  return (
    <Stack.Item>
      <Stack vertical textAlign="center" fontSize="14px">
        <Stack.Item>
          <i>
            Ещё один день на бессмысленной работе. Вы видите&nbsp;
            <span style={hereticBlue}>мерцание</span>
            &nbsp;вокруг, и чувствуете нечто&nbsp;
            <span style={hereticRed}>великое</span>.
          </i>
        </Stack.Item>
        <Stack.Item>
          <b>
            <span style={hereticPurple}>Врата Мансуса</span>
            &nbsp;открыты в вашем сознании!
          </b>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const GuideSection = () => {
  return (
    <Stack.Item>
      <Stack vertical fontSize="12px">
        <Stack.Item>
          - Найдите&nbsp;
          <span style={hereticPurple}>расколы реальности</span>
          &nbsp;на станции, невидимые для обычного глаза и нажмите&nbsp;
          <b>Кодексом Истезания</b> чтобы поглотить их силу и получить&nbsp;
          <span style={hereticBlue}>очки знаний</span>. Поглощение сделает их
          видимыми для всех через некоторое время.
        </Stack.Item>
        <Stack.Item>
          - Используйте&nbsp;
          <span style={hereticRed}>Живое Сердце</span>
          &nbsp;чтобы отследить&nbsp;
          <span style={hereticRed}>своих жертв</span>, но будьте осторожны:
          Используя его, вы издадите звук сердцебиения, который могут услышать
          находящиеся поблизости люди. Эта способность связана с вашим
          <b>сердцем</b> — если вы его потеряете, вам необходимо провести
          ритуал, чтобы вернуть её.
        </Stack.Item>
        <Stack.Item>
          - Начертите&nbsp;
          <span style={hereticGreen}>Руну Трансформации</span> используя ручку
          или мелок на полу, пока используете&nbsp;
          <span style={hereticGreen}>Прикосновение Мансуса</span>
          &nbsp;свободной рукой. Эта руна позволит вам совершать ритуалы и
          жертвоприношения.
        </Stack.Item>
        <Stack.Item>
          - Следуйте подсказкам <span style={hereticRed}>Живого Сердца</span>,
          чтобы найти своих жертв. Притащите их на&nbsp;
          <span style={hereticGreen}>Руну Трансформации</span> в критическом
          состоянии или мертвыми и&nbsp;
          <span style={hereticRed}>принесите их в жертву</span> чтобы получить
          &nbsp;
          <span style={hereticBlue}>очки знаний</span>. Мансус принимает{' '}
          <b> ТОЛЬКО</b>
          тех, на кого указало
          <span style={hereticRed}> Живое Сердце</span>.
        </Stack.Item>
        <Stack.Item>
          - Сделайте себе <span style={hereticYellow}>амулет</span> чтобы иметь
          возможность применять различные продвинутые заклинания, которые
          помогут вам в принесении все более и более сложных жертв.
        </Stack.Item>
        <Stack.Item>
          - Достигните всех своих целей, чтобы иметь возможность изучить{' '}
          <span style={hereticYellow}>последний ритуал</span>. Завершите ритуал,
          чтобы стать всемогущим!
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const InformationSection = (props) => {
  const { data } = useBackend<Info>();
  const { charges, total_sacrifices, ascended } = data;
  return (
    <Stack.Item>
      <Stack vertical fill>
        {!!ascended && (
          <Stack.Item>
            <Stack align="center">
              <Stack.Item>Вы</Stack.Item>
              <Stack.Item fontSize="24px">
                <Box inline color="yellow">
                  ВОЗНЕСЛИСЬ
                </Box>
                !
              </Stack.Item>
            </Stack>
          </Stack.Item>
        )}
        <Stack.Item>
          У вас <b>{charges || 0}</b>&nbsp;
          <span style={hereticBlue}>
            очк{declension(charges || 0, 'о', 'а', 'ов')} знаний
          </span>
          .
        </Stack.Item>
        <Stack.Item>
          Вы принесли в общей сложности&nbsp;
          <b>{total_sacrifices || 0}</b>&nbsp;
          <span style={hereticRed}>
            жертв{declension(total_sacrifices || 0, 'у', 'ы', '')}
          </span>
          .
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

type KnowledgeNodeProps = {
  node: Knowledge;
  canBuy?: boolean;
};

const KnowledgeNode = (props: KnowledgeNodeProps) => {
  const { node, canBuy = true } = props;
  const { act } = useBackend<Info>();
  const buyable = canBuy && !node.disabled && !node.finished;

  // Preview nodes (canBuy=false) always show the path's background, never locked/finished states.
  const bgrState = !canBuy
    ? node.bgr
    : node.disabled
      ? 'node_locked'
      : node.finished
        ? 'node_finished'
        : node.bgr;

  return (
    <Button
      color="transparent"
      tooltip={`${node.name}:
        ${node.desc}`}
      onClick={buyable ? () => act('research', { path: node.path }) : undefined}
      width={node.ascension ? '192px' : '64px'}
      height={node.ascension ? '192px' : '64px'}
      m="8px"
      style={{
        borderRadius: '50%',
      }}
    >
      <DmIcon
        icon="icons/ui_icons/antags/heretic/knowledge.dmi"
        icon_state={bgrState}
        height={node.ascension ? '192px' : '64px'}
        width={node.ascension ? '192px' : '64px'}
        top="0px"
        left="0px"
        position="absolute"
      />
      <DmIcon
        icon={node.icon_params.icon}
        icon_state={node.icon_params.state}
        frame={node.icon_params.frame}
        direction={node.icon_params.dir}
        movement={node.icon_params.moving}
        height={node.ascension ? '152px' : '64px'}
        width={node.ascension ? '152px' : '64px'}
        top={node.ascension ? '20px' : '0px'}
        left={node.ascension ? '20px' : '0px'}
        position="absolute"
      />
      <Box
        position="absolute"
        top="0px"
        left="0px"
        backgroundColor="black"
        textColor="white"
        bold
      >
        {!node.finished && (node.cost > 0 ? node.cost : 'FREE')}
      </Box>
    </Button>
  );
};

const KnowledgeTree = (props) => {
  const { data } = useBackend<Info>();
  const { knowledge_tiers } = data;

  const tiersToShow = knowledge_tiers.filter((tier) => tier.nodes.length > 0);

  return (
    <Section title="Дерево прокачки" fill scrollable>
      <Box textAlign="center" fontSize="32px">
        <span style={hereticYellow}>РАССВЕТ</span>
      </Box>
      <Stack vertical>
        {tiersToShow.length === 0
          ? 'Нет!'
          : tiersToShow.map((tier, i) => (
              <Stack.Item key={i}>
                <Flex
                  justify="center"
                  align="center"
                  backgroundColor="transparent"
                  wrap="wrap"
                >
                  {tier.nodes.map((node) => (
                    <Flex.Item key={node.name}>
                      <KnowledgeNode node={node} />
                      {!!node.ascension && (
                        <Box textAlign="center" fontSize="32px">
                          <span style={hereticPurple}>СУМЕРКИ</span>
                        </Box>
                      )}
                    </Flex.Item>
                  ))}
                </Flex>
                <hr />
              </Stack.Item>
            ))}
      </Stack>
    </Section>
  );
};

// The Knowledge Shop - general (non-path-locked) purchases, shown beside the research tree (grouped by tier).
const KnowledgeShop = (props) => {
  const { data } = useBackend<Info>();
  const { knowledge_shop } = data;
  const shop = knowledge_shop ?? [];

  if (shop.length === 0) {
    return null;
  }

  // Group the shop knowledges into tiers by their depth.
  const tiers: Knowledge[][] = shop.reduce((acc, node) => {
    const tierIndex = (node.depth || 1) - 1;
    (acc[tierIndex] ??= []).push(node);
    return acc;
  }, [] as Knowledge[][]);

  return (
    <Section title="Магазин знаний" fill scrollable>
      <Stack vertical>
        {tiers.map(
          (tier, index) =>
            tier?.length > 0 && (
              <Stack.Item key={index}>
                <Flex justify="center" align="center" wrap="wrap">
                  {tier.map((node) => (
                    <Flex.Item key={node.name}>
                      <KnowledgeNode node={node} />
                    </Flex.Item>
                  ))}
                </Flex>
                <hr />
              </Stack.Item>
            ),
        )}
      </Stack>
    </Section>
  );
};

// The "Прокачка" tab - the research tree and the knowledge shop side by side (matching TG).
const ResearchInfo = (props) => {
  const { data } = useBackend<Info>();
  const { charges, knowledge_shop } = data;
  const hasShop = (knowledge_shop ?? []).length > 0;

  return (
    <Stack vertical fill>
      <Stack.Item fontSize="20px" textAlign="center">
        У вас <b>{charges || 0}</b>&nbsp;
        <span style={hereticBlue}>
          очк{declension(charges || 0, 'о', 'а', 'ов')} знаний
        </span>
        .
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow>
            <KnowledgeTree />
          </Stack.Item>
          {hasShop && (
            <Stack.Item grow>
              <KnowledgeShop />
            </Stack.Item>
          )}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const passiveCardStyle = {
  margin: '0.5em 0',
  backgroundColor: '#808080',
  borderRadius: '5px',
  padding: '0.5em',
};

const passiveCardActiveStyle = {
  ...passiveCardStyle,
  backgroundColor: '#62cc67',
};

const PathInfo = ({ currentPath }: { currentPath?: HereticPath }) => {
  const { data } = useBackend<Info>();
  const { paths } = data;

  const pathChosenIndex = paths.findIndex(
    (path) => currentPath && path.route === currentPath.route,
  );

  const [currentTab, setCurrentTab] = useState(
    pathChosenIndex !== -1 ? pathChosenIndex : 0,
  );

  const path = paths[currentTab];
  if (!path) {
    return <Section fill>Нет доступных путей.</Section>;
  }

  return (
    <Stack fill>
      {!currentPath && (
        <Stack.Item>
          <Tabs vertical>
            {paths.map((p, index) => (
              <Tabs.Tab
                key={index}
                icon="info"
                selected={currentTab === index}
                onClick={() => setCurrentTab(index)}
              >
                {p.route}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
      )}
      <Stack.Item grow>
        <PathContent path={path} isPathSelected={!!currentPath} />
      </Stack.Item>
    </Stack>
  );
};

const PathContent = ({
  path,
  isPathSelected,
}: {
  path: HereticPath;
  isPathSelected: boolean;
}) => {
  const { data } = useBackend<Info>();
  const { passive_level } = data;

  return (
    <Section title={path.route} textAlign="center" fill scrollable>
      <Stack vertical>
        {!isPathSelected && (
          <Stack.Item textAlign="center">
            <h2>Выбрать путь:</h2>
            <KnowledgeNode node={path.starting_knowledge} />
            <div>
              <b>Сложность: </b>
              <span style={{ color: path.complexity_color }}>
                {path.complexity}
              </span>
            </div>
          </Stack.Item>
        )}

        <Stack.Item textAlign="left">
          <b>Описание:</b>
          {(path.description ?? []).map((line, index) => (
            <div key={index}>{line}</div>
          ))}
        </Stack.Item>

        {!!path.passive &&
          (!isPathSelected ? (
            <Stack.Item style={{ justifyItems: 'center' }}>
              <b style={hereticPurple}>Усиление: {path.passive.name}</b>
              <div style={{ ...passiveCardStyle, width: '50%' }}>
                {(path.passive.description ?? [])[0]}
              </div>
            </Stack.Item>
          ) : (
            <Stack.Item>
              <b style={hereticPurple}>
                Усиление: {path.passive.name} (уровень {passive_level})
              </b>
              <Stack>
                {(path.passive.description ?? []).map((line, index) => {
                  const unlocked = passive_level >= index + 1;
                  return (
                    <Stack.Item
                      key={index}
                      grow
                      style={
                        unlocked ? passiveCardActiveStyle : passiveCardStyle
                      }
                    >
                      Уровень {index + 1}
                      <br />
                      {line}
                    </Stack.Item>
                  );
                })}
              </Stack>
            </Stack.Item>
          ))}

        {!isPathSelected && (path.preview_abilities ?? []).length > 0 && (
          <Stack.Item>
            <b>Гарантированные способности:</b>
            <Stack wrap="wrap" justify="center">
              {(path.preview_abilities ?? []).map((ability) => (
                <Stack.Item key={ability.path} m={1}>
                  <KnowledgeNode node={ability} canBuy={false} />
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
        )}

        {!isPathSelected && (path.pros ?? []).length > 0 && (
          <Stack.Item textAlign="left">
            <b style={hereticGreen}>Плюсы:</b>
            {(path.pros ?? []).map((pro, index) => (
              <div key={index}>+ {pro}</div>
            ))}
          </Stack.Item>
        )}
        {!isPathSelected && (path.cons ?? []).length > 0 && (
          <Stack.Item textAlign="left">
            <b style={hereticRed}>Минусы:</b>
            {(path.cons ?? []).map((con, index) => (
              <div key={index}>− {con}</div>
            ))}
          </Stack.Item>
        )}

        {isPathSelected && (path.tips ?? []).length > 0 && (
          <Stack.Item textAlign="left">
            <b style={hereticYellow}>Советы:</b>
            <ul style={{ marginTop: '2px' }}>
              {(path.tips ?? []).map((tip, index) => (
                <li key={index}>{tip}</li>
              ))}
            </ul>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

// Per-path window background gradients (matching TG's AntagInfoHeretic.scss theme variables).
const pathBackgrounds: Record<string, string> = {
  'Ash Path':
    'radial-gradient(circle, rgba(24,9,9,1) 54%, rgba(31,10,10,1) 60%, rgba(46,11,11,1) 80%, rgba(47,14,14,1) 100%)',
  'Rust Path':
    'radial-gradient(circle, rgb(120,48,9) 54%, rgb(139,48,9) 60%, rgb(150,48,9) 80%, rgb(160,48,9) 100%)',
  'Flesh Path':
    'radial-gradient(circle, rgb(153,26,26) 54%, rgba(130,9,9,1) 60%, rgb(150,33,30) 80%, rgb(141,30,26) 100%)',
  'Void Path':
    'radial-gradient(circle, rgb(13,13,66) 54%, rgb(22,22,66) 60%, rgb(25,25,99) 80%, rgb(42,42,192) 100%)',
  'Blade Path':
    'radial-gradient(circle, rgb(139,141,137) 54%, rgb(139,141,137) 60%, rgb(170,188,186) 80%, rgb(185,188,182) 100%)',
  'Cosmic Path':
    'radial-gradient(circle, rgb(78,38,110) 54%, rgb(78,38,110) 60%, rgb(78,38,110) 80%, rgb(78,38,110) 100%)',
  'Lock Path':
    'radial-gradient(circle, rgba(3,3,7,1) 54%, rgba(9,9,26,1) 60%, rgba(8,5,15,1) 80%, rgba(13,7,26,1) 100%)',
  'Moon Path':
    'radial-gradient(circle, rgb(215,179,218) 54%, rgb(163,139,165) 60%, rgb(108,92,109) 80%, rgba(13,7,26,1) 100%)',
};

const defaultBackground =
  'radial-gradient(circle, rgba(9,9,24,1) 54%, rgba(10,10,31,1) 60%, rgba(21,11,46,1) 80%, rgba(24,14,47,1) 100%)';

const ascendedBackground =
  'radial-gradient(circle, rgba(24,9,9,1) 54%, rgba(31,10,10,1) 60%, rgba(46,11,11,1) 80%, rgba(47,14,14,1) 100%)';

export const AntagInfoHeretic = (props) => {
  const { data } = useBackend<Info>();
  const { ascended, paths } = data;

  const [currentTab, setTab] = useState(0);

  // The path we're actually walking (its starting knowledge is researched), if any.
  const currentPath = (paths ?? []).find(
    (path) => path.starting_knowledge?.finished,
  );

  const tabs = [
    { icon: 'info', label: 'Информация', content: <IntroductionSection /> },
    {
      icon: 'compass',
      label: 'Пути',
      content: <PathInfo currentPath={currentPath} />,
    },
    {
      icon: currentTab === 2 ? 'book-open' : 'book',
      label: 'Прокачка',
      content: <ResearchInfo />,
    },
  ];

  const background = ascended
    ? ascendedBackground
    : currentPath
      ? (pathBackgrounds[currentPath.route] ?? defaultBackground)
      : defaultBackground;

  return (
    <Window width={675} height={635}>
      <Window.Content
        style={{
          backgroundImage: 'none',
          background: background,
        }}
      >
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              {tabs.map((tab, index) => (
                <Tabs.Tab
                  key={index}
                  icon={tab.icon}
                  selected={currentTab === index}
                  onClick={() => setTab(index)}
                >
                  {tab.label}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{tabs[currentTab].content}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
