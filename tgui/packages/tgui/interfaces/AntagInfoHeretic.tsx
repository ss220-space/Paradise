import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  DmIcon,
  Flex,
  Section,
  Stack,
  Tabs,
} from '../components';
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
  notice?: string;
  transmuteText?: string;
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
  points_to_aura: number;
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
        <Section title="Вы Еретик!" fill fontSize="14px" scrollable>
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
            <span style={hereticPurple}>Врата Обители</span>
            &nbsp;открыты в вашем сознании!
          </b>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const GuideSection = () => {
  const { data } = useBackend<Info>();
  const { points_to_aura } = data;
  return (
    <Stack.Item>
      <Stack vertical fontSize="12px">
        <Stack.Item>
          - Найдите на станции невидимые для обычного глаза&nbsp;
          <span style={hereticPurple}>расколы реальности</span> и нажмите по ним
          пустой рукой, чтобы поглотить их силу и заработать&nbsp;
          <span style={hereticBlue}>очки знаний</span>. Разломы,
          поглощённые&nbsp;
          <b>Кодексом Истязания</b>, приносят дополнительное очко. Поглощение
          сделает разломыми видимыми для всех спустя некоторое время.
        </Stack.Item>
        <Stack.Item>
          - Используйте&nbsp;
          <span style={hereticRed}>Живое Сердце</span>, чтобы отследить&nbsp;
          <span style={hereticRed}>своих жертв</span>, но будьте осторожны:
          используя его, вы издадите звук сердцебиения, который могут услышать
          находящиеся поблизости люди. Эта способность связана с вашим&nbsp;
          <b>сердцем</b> — если вы его потеряете, вам необходимо провести
          ритуал, чтобы вернуть её.
        </Stack.Item>
        <Stack.Item>
          - Начертите&nbsp;
          <span style={hereticGreen}>Руну Трансформации</span>, используя ручку
          или мелок на полу с <span style={hereticGreen}>Хваткой Обители</span>{' '}
          в свободной руке. Эта руна позволит вам совершать ритуалы и
          жертвоприношения.
        </Stack.Item>
        <Stack.Item>
          - Следуйте подсказкам <span style={hereticRed}>Живого Сердца</span>,
          чтобы найти своих жертв. Притащите их на&nbsp;
          <span style={hereticGreen}>Руну Трансформации</span> в критическом
          состоянии или мёртвыми и&nbsp;
          <span style={hereticRed}>принесите их в жертву</span>, чтобы
          получить&nbsp;
          <span style={hereticBlue}>очки знаний</span>. Обитель принимает{' '}
          <b> ТОЛЬКО</b> тех, на кого указало
          <span style={hereticRed}> Живое Сердце</span>.
        </Stack.Item>
        <Stack.Item>
          - Сделайте себе <span style={hereticYellow}>амулет</span>, или любой
          другой источник <b>фокуса</b>, чтобы иметь возможность применять
          различные продвинутые заклинания, которые помогут вам в принесении все
          более и более сложных жертв.
        </Stack.Item>
        <Stack.Item>
          - Достигните всех своих целей, чтобы иметь возможность изучить{' '}
          <span style={hereticYellow}>последний ритуал</span>. Завершите ритуал,
          чтобы стать всемогущим!
        </Stack.Item>
        <Stack.Item>
          - Накопив в общей сложности <b>{points_to_aura}</b>&nbsp;
          <span style={hereticBlue}>очков знаний</span>, вы проявите вокруг себя
          видимую ауру&nbsp;
          <span style={hereticPurple}>энергии Обители</span>. Эта аура будет
          видна всем окружающим и выдаст в вас еретика. Взвесьте риски, прежде
          чем накапливать слишком много знаний!
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

const formatTooltipText = (text: string) => {
  return (
    <Stack vertical>
      {text.split('<br>').map((line, index) => {
        const isBulletPoint = line.includes('&bull;');
        if (isBulletPoint) {
          line = line.replace(/&bull;/g, '•');
        }
        return (
          <Stack.Item
            key={index}
            fontSize={isBulletPoint ? '10px' : undefined}
            width={isBulletPoint ? '110%' : undefined}
          >
            {line}
          </Stack.Item>
        );
      })}
    </Stack>
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
      tooltip={
        <Stack vertical>
          <Stack.Item align="center" fontSize="16px">
            <b>{node.name}</b>
          </Stack.Item>
          <Stack.Item>
            <BlockQuote>
              <span style={hereticPurple}>Результат: </span>{' '}
            </BlockQuote>
            {formatTooltipText(node.desc)}
          </Stack.Item>
          {!!node.notice && (
            <Stack.Item color="red">
              {formatTooltipText(node.notice)}
            </Stack.Item>
          )}
          {!!node.transmuteText && (
            <Stack.Item>
              <BlockQuote>
                <span style={hereticGreen}>Рецепт: </span>{' '}
              </BlockQuote>
              {formatTooltipText(node.transmuteText)}
            </Stack.Item>
          )}
        </Stack>
      }
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
        {buyable && (node.cost > 0 ? node.cost : 'FREE')}
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
                <b>Тир {index + 1}</b>
                <Flex justify="center" align="center" wrap="wrap">
                  {tier.map((node) => (
                    <Flex.Item key={node.name}>
                      <KnowledgeNode node={node} />
                    </Flex.Item>
                  ))}
                </Flex>
                <hr />
              </Stack.Item>
            )
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
    (path) => currentPath && path.route === currentPath.route
  );

  const [currentTab, setCurrentTab] = useState(
    pathChosenIndex !== -1 ? pathChosenIndex : 0
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

const PathProCons = ({
  proconlist,
  title,
  titleStyle,
  bullet,
}: {
  proconlist: string[];
  title: string;
  titleStyle: Record<string, string>;
  bullet: string;
}) => {
  return (
    <Stack vertical>
      <Stack.Item>
        <b style={titleStyle}>{title}:</b>
      </Stack.Item>
      <Stack.Item textAlign="left">
        {proconlist.map((item, index) => (
          <div key={index} style={{ marginBottom: '0.5em' }}>
            {bullet} {item}
          </div>
        ))}
      </Stack.Item>
    </Stack>
  );
};

const PathContentUnselected = ({ path }: { path: HereticPath }) => {
  return (
    <Stack vertical>
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
      <Stack.Item textAlign="left">
        {(path.description ?? []).map((line, index) => (
          <div key={index}>{line}</div>
        ))}
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <Stack>
          <Stack.Item width="50%">
            {!!path.passive && (
              <Stack vertical>
                <Stack.Item>
                  <b style={hereticPurple}>Усиление: {path.passive.name}</b>
                </Stack.Item>
                <Stack.Item style={passiveCardStyle}>
                  {(path.passive.description ?? [])[0]}
                </Stack.Item>
              </Stack>
            )}
          </Stack.Item>
          <Stack.Item width="50%">
            <Stack vertical>
              <Stack.Item>
                <b>Способности пути:</b>
              </Stack.Item>
              <Stack.Item>
                <Stack wrap="wrap" justify="center">
                  {(path.preview_abilities ?? []).map((ability) => (
                    <Stack.Item key={ability.path} m={1}>
                      <KnowledgeNode node={ability} canBuy={false} />
                    </Stack.Item>
                  ))}
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <Stack>
          <Stack.Item width="50%">
            <PathProCons
              proconlist={path.pros ?? []}
              title="Плюсы"
              titleStyle={hereticGreen}
              bullet="+"
            />
          </Stack.Item>
          <Stack.Item width="50%">
            <PathProCons
              proconlist={path.cons ?? []}
              title="Минусы"
              titleStyle={hereticRed}
              bullet="−"
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const PathContentSelected = ({
  path,
  passiveLevel,
}: {
  path: HereticPath;
  passiveLevel: number;
}) => {
  return (
    <Stack vertical>
      <Stack.Item textAlign="left">
        {(path.description ?? []).map((line, index) => (
          <div key={index}>{line}</div>
        ))}
      </Stack.Item>
      {!!path.passive && (
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <b style={hereticPurple}>
                Усиление: {path.passive.name} (уровень {passiveLevel})
              </b>
            </Stack.Item>
            {(path.passive.description ?? []).map((line, index) => (
              <Stack.Item
                key={index}
                style={
                  passiveLevel >= index + 1
                    ? passiveCardActiveStyle
                    : passiveCardStyle
                }
              >
                <b>Уровень {index + 1}</b>
                <br />
                {line}
              </Stack.Item>
            ))}
          </Stack>
        </Stack.Item>
      )}
      {(path.tips ?? []).length > 0 && (
        <Stack.Item textAlign="left" mt={2} mb={1}>
          <b style={hereticYellow}>Советы:</b>
          <Stack vertical mt={1}>
            {(path.tips ?? []).map((tip, index) => (
              <Stack.Item key={index}>• {tip}</Stack.Item>
            ))}
          </Stack>
        </Stack.Item>
      )}
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
      {isPathSelected ? (
        <PathContentSelected path={path} passiveLevel={passive_level} />
      ) : (
        <PathContentUnselected path={path} />
      )}
    </Section>
  );
};

// Per-path window background gradients (matching TG's AntagInfoHeretic.scss theme variables).
const pathBackgrounds: Record<string, string> = {
  'Путь Пепла':
    'radial-gradient(circle, rgba(24,9,9,1) 54%, rgba(31,10,10,1) 60%, rgba(46,11,11,1) 80%, rgba(47,14,14,1) 100%)',
  'Путь Ржавчины':
    'radial-gradient(circle, rgb(120,48,9) 54%, rgb(139,48,9) 60%, rgb(150,48,9) 80%, rgb(160,48,9) 100%)',
  'Путь Плоти':
    'radial-gradient(circle, rgb(153,26,26) 54%, rgba(130,9,9,1) 60%, rgb(150,33,30) 80%, rgb(141,30,26) 100%)',
  'Путь Пустоты':
    'radial-gradient(circle, rgb(13,13,66) 54%, rgb(22,22,66) 60%, rgb(25,25,99) 80%, rgb(42,42,192) 100%)',
  'Путь Клинка':
    'radial-gradient(circle, rgb(139,141,137) 54%, rgb(139,141,137) 60%, rgb(170,188,186) 80%, rgb(185,188,182) 100%)',
  'Путь Космоса':
    'radial-gradient(circle, rgb(78,38,110) 54%, rgb(78,38,110) 60%, rgb(78,38,110) 80%, rgb(78,38,110) 100%)',
  'Путь Замка́':
    'radial-gradient(circle, rgba(3,3,7,1) 54%, rgba(9,9,26,1) 60%, rgba(8,5,15,1) 80%, rgba(13,7,26,1) 100%)',
  'Путь Луны':
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
    (path) => path.starting_knowledge?.finished
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
    <Window width={750} height={635}>
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
