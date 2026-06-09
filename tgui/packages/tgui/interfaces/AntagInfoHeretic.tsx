import { useState } from 'react';
import { Box, Button, DmIcon, Flex, Section, Stack, Tabs } from '../components';
import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  Objective,
  ObjectivePrintout,
  ReplaceObjectivesButton,
} from './common/Objectives';

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
  disabled: BooleanLike;
  finished: BooleanLike;
  ascension: BooleanLike;
};

type KnowledgeInfo = {
  knowledge_tiers: KnowledgeTier[];
};

type KnowledgeTier = {
  nodes: Knowledge[];
};

type Info = {
  charges: number;
  total_sacrifices: number;
  ascended: BooleanLike;
  objectives: Objective[];
  can_change_objective: BooleanLike;
};

const IntroductionSection = (props) => {
  const { data, act } = useBackend<Info>();
  const { objectives, ascended, can_change_objective } = data;

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
            очк
            {charges === 1
              ? 'о '
              : charges === 2 || charges === 3 || charges === 4
                ? 'а '
                : 'ов '}
            знаний
          </span>
          .
        </Stack.Item>
        <Stack.Item>
          Вы принесли в общей сложности&nbsp;
          <b>{total_sacrifices || 0}</b>&nbsp;
          <span style={hereticRed}>
            жертв
            {total_sacrifices === 1
              ? 'у'
              : total_sacrifices === 2 ||
                  total_sacrifices === 3 ||
                  total_sacrifices === 4
                ? 'ы'
                : ''}
          </span>
          .
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const KnowledgeTree = (props) => {
  const { data, act } = useBackend<KnowledgeInfo>();
  const { knowledge_tiers } = data;

  return (
    <Section title="Дерево прокачки" fill scrollable>
      <Box textAlign="center" fontSize="32px">
        <span style={hereticYellow}>РАССВЕТ</span>
      </Box>
      <Stack vertical>
        {knowledge_tiers.length === 0
          ? 'Нет!'
          : knowledge_tiers.map((tier, i) => (
              <Stack.Item key={i}>
                <Flex
                  justify="center"
                  align="center"
                  backgroundColor="transparent"
                  wrap="wrap"
                >
                  {tier.nodes.map((node) => (
                    <Flex.Item key={node.name}>
                      <Button
                        color="transparent"
                        tooltip={`${node.name}:
                          ${node.desc}`}
                        onClick={
                          node.disabled || node.finished
                            ? undefined
                            : () => act('research', { path: node.path })
                        }
                        width={node.ascension ? '192px' : '64px'}
                        height={node.ascension ? '192px' : '64px'}
                        m="8px"
                        style={{
                          borderRadius: '50%',
                        }}
                      >
                        <DmIcon
                          icon="icons/ui_icons/antags/heretic/knowledge.dmi"
                          icon_state={
                            node.disabled
                              ? 'node_locked'
                              : node.finished
                                ? 'node_finished'
                                : node.bgr
                          }
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
                          {!node.finished &&
                            (node.cost > 0 ? node.cost : 'FREE')}
                        </Box>
                      </Button>
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

const ResearchInfo = (props) => {
  const { data } = useBackend<Info>();
  const { charges } = data;

  return (
    <Stack vertical fill>
      <Stack.Item fontSize="20px" textAlign="center">
        У вас <b>{charges || 0}</b>&nbsp;
        <span style={hereticBlue}>
          очк
          {charges === 1
            ? 'о '
            : charges === 2 || charges === 3 || charges === 4
              ? 'а '
              : 'ов '}
          знаний
        </span>
        .
      </Stack.Item>
      <Stack.Item grow>
        <KnowledgeTree />
      </Stack.Item>
    </Stack>
  );
};

export const AntagInfoHeretic = (props) => {
  const { data } = useBackend<Info>();
  const { ascended } = data;

  const [currentTab, setTab] = useState(0);

  return (
    <Window width={675} height={635}>
      <Window.Content
        style={{
          backgroundImage: 'none',
          background: ascended
            ? 'radial-gradient(circle, rgba(24,9,9,1) 54%, rgba(31,10,10,1) 60%, rgba(46,11,11,1) 80%, rgba(47,14,14,1) 100%);'
            : 'radial-gradient(circle, rgba(9,9,24,1) 54%, rgba(10,10,31,1) 60%, rgba(21,11,46,1) 80%, rgba(24,14,47,1) 100%);',
        }}
      >
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="info"
                selected={currentTab === 0}
                onClick={() => setTab(0)}
              >
                Информация
              </Tabs.Tab>
              <Tabs.Tab
                icon={currentTab === 1 ? 'book-open' : 'book'}
                selected={currentTab === 1}
                onClick={() => setTab(1)}
              >
                Прокачка
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {(currentTab === 0 && <IntroductionSection />) || <ResearchInfo />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
