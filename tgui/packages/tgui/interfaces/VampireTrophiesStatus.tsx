import { useBackend } from '../backend';
import { Button, Box, Table, Section, Stack, DmIcon } from '../components';
import { Window } from '../layouts';

const roundTenths = (input: number) => {
  return (Math.round(input * 10) / 10).toFixed(1);
};

export const VampireTrophiesStatus = (_props: unknown) => {
  return (
    <Window theme="ntos_spooky" width={700} height={800}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Trophies />
          <Passives />
          <InfectedTrophy />
          <Lunge />
          <MarkPrey />
          <MetamorphosisBats />
          <ResonantShriek />
          <Anabiosis />
          <SummonBats />
          <MetamorphosisHound />
          <LungeFinale />
        </Stack>
      </Window.Content>
    </Window>
  );
};

type VampireTrophiesStatusData = {
  hearts: number;
  lungs: number;
  livers: number;
  kidneys: number;
  eyes: number;
  ears: number;
  trophies_max_gen: number;
  trophies_max_crit: number;
  organs_icon: string;
  icon_hearts: string;
  icon_lungs: string;
  icon_livers: string;
  icon_kidneys: string;
  icon_eyes: string;
  icon_ears: string;
  suck_rate: number;
  trophies_brute: number;
  trophies_burn: number;
  trophies_oxy: number;
  trophies_tox: number;
  trophies_brain: number;
  trophies_clone: number;
  trophies_stamina: number;
  trophies_flash: number;
  trophies_welding: number;
  trophies_xray: number;
  trophies_bang: number;
  trophies_blood: number;
  full_power: boolean;
};

const Trophies = (_props: unknown) => {
  const { data } = useBackend<VampireTrophiesStatusData>();
  const {
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
    trophies_max_gen,
    trophies_max_crit,
    organs_icon,
    icon_hearts,
    icon_lungs,
    icon_livers,
    icon_kidneys,
    icon_eyes,
    icon_ears,
  } = data;
  return (
    <Stack.Item>
      <Section
        title="Трофеи"
        color="red"
        textAlign="center"
        verticalAlign="middle"
      >
        <Stack fill>
          <Box inline width="16.6%">
            <DmIcon
              icon={organs_icon}
              icon_state={icon_hearts}
              verticalAlign="middle"
              style={{
                marginLeft: '-32px',
                marginRight: '-48px',
                marginTop: '-32px',
                marginBottom: '-48px',
                height: '128px',
                width: '128px',
              }}
            />
            <Box
              bold
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
              fontSize="20px"
            >
              {hearts}
            </Box>
            <Button
              tooltipPosition="right"
              tooltip="Cердце - трофей, который веками повышал жизненную силу и крепость тела наших сородичей. Критичный орган. Максимальное количество трофеев этого типа - 6."
              color="transparent"
            >
              СЕРДЦЕ
            </Button>
          </Box>
          <Box inline width="16.6%">
            <DmIcon
              icon={organs_icon}
              icon_state={icon_lungs}
              verticalAlign="middle"
              style={{
                marginLeft: '-8px',
                marginRight: '-16px',
                marginTop: '-12px',
                marginBottom: '-12px',
                height: '72px',
                width: '72px',
              }}
            />
            <Box
              bold
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
              fontSize="20px"
            >
              {lungs}
            </Box>
            <Button
              tooltipPosition="right"
              tooltip="Легкие - трофей, который всегда использовался в ритуалах для повышения ловкости и выносливости наших сородичей. Критичный орган. Максимальное количество трофеев этого типа - 6."
              color="transparent"
            >
              ЛЕГКИЕ
            </Button>
          </Box>
          <Box inline width="16.6%">
            <DmIcon
              icon={organs_icon}
              icon_state={icon_livers}
              verticalAlign="middle"
              style={{
                marginLeft: '-24px',
                marginRight: '-24px',
                marginTop: '-28px',
                marginBottom: '-20px',
                height: '96px',
                width: '96px',
              }}
            />
            <Box
              bold
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
              fontSize="20px"
            >
              {livers}
            </Box>
            <Button
              tooltipPosition="right"
              tooltip="Печень - всегда использовалась в традиционных вампирских обрядах для усиления контроля крови, что снижает затраты крови для использования способностей. Максимальное количество трофеев этого типа - 10."
              color="transparent"
            >
              ПЕЧЕНЬ
            </Button>
          </Box>
          <Box inline width="16.6%">
            <DmIcon
              icon={organs_icon}
              icon_state={icon_kidneys}
              verticalAlign="middle"
              style={{
                marginLeft: '-22px',
                marginRight: '-26px',
                marginTop: '-28px',
                marginBottom: '-20px',
                height: '96px',
                width: '96px',
              }}
            />
            <Box
              bold
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
              fontSize="20px"
            >
              {kidneys}
            </Box>
            <Button
              tooltipPosition="left"
              tooltip="Почки - используются вампирами в качестве катализатора для усиления эффектов от способностей. Максимальное количество трофеев этого типа - 10."
              color="transparent"
            >
              ПОЧКИ
            </Button>
          </Box>
          <Box inline width="16.6%">
            <DmIcon
              icon={organs_icon}
              icon_state={icon_eyes}
              verticalAlign="middle"
              style={{
                marginLeft: '-26px',
                marginRight: '-22px',
                marginTop: '-22px',
                marginBottom: '-26px',
                height: '96px',
                width: '96px',
              }}
            />
            <Box
              bold
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
              fontSize="20px"
            >
              {eyes}
            </Box>
            <Button
              tooltipPosition="left"
              tooltip="Глаза - один из самых важных ингредиентов, позволяющий обойти любые недостатки зрения, присущие смертному телу. Максимальное количество трофеев этого типа - 10."
              color="transparent"
            >
              ГЛАЗА
            </Button>
          </Box>
          <Box inline width="16.6%">
            <DmIcon
              icon={organs_icon}
              icon_state={icon_ears}
              verticalAlign="middle"
              style={{
                marginLeft: '-8px',
                marginRight: '-8px',
                marginTop: '-8px',
                marginBottom: '-8px',
                height: '64px',
                width: '64px',
              }}
            />
            <Box
              bold
              textColor={ears < trophies_max_gen ? 'average' : 'good'}
              fontSize="20px"
            >
              {ears}
            </Box>
            <Button
              tooltipPosition="left"
              tooltip="Уши - всегда помогали нашим сородичам улучшить контроль над эмоциями, что предавло нашим способностям больший радиус действия. Максимальное количество трофеев этого типа - 10."
              color="transparent"
            >
              УШИ
            </Button>
          </Box>
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const Passives = (_props: unknown) => {
  const { data } = useBackend<VampireTrophiesStatusData>();
  const {
    suck_rate,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
    trophies_max_gen,
    trophies_max_crit,
    trophies_brute,
    trophies_burn,
    trophies_oxy,
    trophies_tox,
    trophies_brain,
    trophies_clone,
    trophies_stamina,
    trophies_flash,
    trophies_welding,
    trophies_xray,
    trophies_bang,
    trophies_blood,
  } = data;
  return (
    <Section
      title="Пассивные способности"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Улучшается при извлечении сердец"
              color="transparent"
            >
              Защита от травм:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {hearts < trophies_max_crit
                ? Math.ceil(hearts * (trophies_brute / trophies_max_crit))
                : trophies_brute}
              %{hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Улучшается при извлечении легких"
              color="transparent"
            >
              Защита от ожогов:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {hearts < trophies_max_crit
                ? Math.ceil(hearts * (trophies_burn / trophies_max_crit))
                : trophies_burn}
              %{hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Улучшается при извлечении легких"
              color="transparent"
            >
              Защита от гипоксии:
            </Button>
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {lungs < trophies_max_crit
                ? Math.ceil(lungs * (trophies_oxy / trophies_max_crit))
                : trophies_oxy}
              %{lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Улучшается при извлечении печени"
              color="transparent"
            >
              Защита от токсинов:
            </Button>
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {livers < trophies_max_gen
                ? livers * (trophies_tox / trophies_max_gen)
                : trophies_tox}
              %{livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Улучшается при извлечении почек"
              color="transparent"
            >
              Защита мозга:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys < trophies_max_gen
                ? kidneys * (trophies_brain / trophies_max_gen)
                : trophies_brain}
              %{kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Улучшается при извлечении почек"
              color="transparent"
            >
              Клеточная защита:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys < trophies_max_gen
                ? kidneys * (trophies_clone / trophies_max_gen)
                : trophies_clone}
              %{kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Улучшается при извлечении легких"
              color="transparent"
            >
              Защита выносливости:
            </Button>
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {lungs < trophies_max_crit
                ? Math.ceil(lungs * (trophies_stamina / trophies_max_crit))
                : trophies_stamina}
              %{lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Улучшается при извлечении печени"
              color="transparent"
            >
              Снижения затрат крови:
            </Button>
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {livers < trophies_max_gen
                ? livers * (trophies_blood / trophies_max_gen)
                : trophies_blood}
              {livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Время, затрачиваемое на каждый цикл поглощения крови, чем меньше, тем лучше. Снижается при извлечении почек."
              color="transparent"
            >
              Скорость поглощения:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {suck_rate}с.
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Становится доступно при извлечении ушей"
              color="transparent"
            >
              Защита от вспышек:
            </Button>
            <Box inline textColor={eyes < trophies_flash ? 'bad' : 'good'}>
              {eyes < trophies_flash ? 'НЕТ' : 'ЕСТЬ'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Становится доступно при извлечении ушей"
              color="transparent"
            >
              Защита от сварки:
            </Button>
            <Box inline textColor={eyes < trophies_welding ? 'bad' : 'good'}>
              {eyes < trophies_welding ? 'НЕТ' : 'ЕСТЬ'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Становится доступно при извлечении глаз"
              color="transparent"
            >
              X-Ray зрение:
            </Button>
            <Box inline textColor={eyes < trophies_xray ? 'bad' : 'good'}>
              {eyes < trophies_xray ? 'НЕТ' : 'ЕСТЬ'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Становится доступно при извлечении ушей"
              color="transparent"
            >
              Защита ушей:
            </Button>
            <Box inline textColor={ears < trophies_bang ? 'bad' : 'good'}>
              {ears < trophies_bang ? 'НЕТ' : 'ЕСТЬ'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const InfectedTrophy = (_props: unknown) => {
  const { data } = useBackend<VampireTrophiesStatusData>();
  const { trophies_max_gen, trophies_max_crit, hearts, livers, eyes, ears } =
    data;
  return (
    <Section
      title="Зараженный трофей"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Расстояние, которое пролетит череп, перед исчезновением. Увеличивается при извлечении глаз."
              color="transparent"
            >
              Дальность полета:
            </Button>
            <Box
              inline
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
            >
              {5 + eyes}
              {eyes < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Радиус зоны поражения, с центром в точке попадания. Все живые мобы в области будут задеты. Увеличивается при извлечении ушей."
              color="transparent"
            >
              Радиус поражения:
            </Button>
            <Box
              inline
              textColor={ears < trophies_max_gen ? 'average' : 'good'}
            >
              {Math.floor(ears / 4)}
              {ears < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Количество физического урона, которое получит каждый живой моб в области поражения. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Урон:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {hearts * 5}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Время, которое каждый живой моб в области поражения будет оглушен. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Время оглушения:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {roundTenths(hearts / 2)}с.
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Вероятность того, что каждый живой гуманоид в в области поражения будет заражен могильной лихорадкой. Увеличивается при извлечении печени."
              color="transparent"
            >
              Шанс заражения:
            </Button>
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {10 + livers * 3}%{livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const Lunge = (_props: unknown) => {
  const { data } = useBackend<VampireTrophiesStatusData>();
  const { trophies_max_gen, trophies_max_crit, hearts, lungs, kidneys, ears } =
    data;
  return (
    <Section
      title="Рывок"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Максимальное расстояние, на котором рывок прервывется автоматически. Увеличивается при извлечении легких."
              color="transparent"
            >
              Дистанция:
            </Button>
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {5 + lungs}
              {lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Радиус зоны поражения, с центром в конечной точке рывка. Все живые мобы в области будут задеты. Увеличивается при извлечении ушей."
              color="transparent"
            >
              Радиус поражения:
            </Button>
            <Box
              inline
              textColor={ears < trophies_max_gen ? 'average' : 'good'}
            >
              {1 + Math.floor(ears / 5)}
              {ears < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Время, которое каждый живой моб в области поражения будет оглушен. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Время оглушения:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {roundTenths(1 + hearts / 2)}с.
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Время, которое каждый живой моб в области поражения будет в замешательстве. Увеличивается при извлечении почек."
              color="transparent"
            >
              Время замешательства:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {roundTenths(kidneys * 2)}с.
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Количество крови, которое потеряет каждый живой гуманоид в области поражения. Увеличивается при извлечении почек."
              color="transparent"
            >
              Кровопотеря:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys * 10}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Количество крови, которое получит вампир от каждого живого разумного гуманоида в области поражения. Увеличивается при извлечении почек."
              color="transparent"
            >
              Поглощение крови:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const MarkPrey = (_props: unknown) => {
  const { data } = useBackend<VampireTrophiesStatusData>();
  const { trophies_max_gen, trophies_max_crit, hearts, kidneys, eyes } = data;
  return (
    <Section
      title="Пометить добычу"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Максимальная дистанция, на которой можно применить способность. Увеличивается при извлечении глаз."
              color="transparent"
            >
              Дальность применения:
            </Button>
            <Box
              inline
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
            >
              {3 + Math.floor(eyes / 2)}
              {eyes < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Время, в течение которого метка будет действовать. Увеличивается при извлечении почек."
              color="transparent"
            >
              Продолжительность:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {roundTenths(5 + kidneys)}s.
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Объём термических повреждений, которые получит жертва, если сработает поджог. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Терм. повреждения:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {hearts}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Шанс на то, что поджог сработает. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Шанс на поджог:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {hearts * 10}%{hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Шанс на то, что цель спонтанно атакует ближайшую цель или же саму себя. Увеличивается при извлечении глаз."
              color="transparent"
            >
              Шанс на безумие:
            </Button>
            <Box
              inline
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
            >
              {30 + eyes * 7}%{eyes < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const MetamorphosisBats = (_props: unknown) => {
  const { data } = useBackend<VampireTrophiesStatusData>();
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
  } = data;
  return (
    <Section
      title="Метаморфоза - Летучие мыши"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Максимальное здоровье летучих мышей. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Здоровье:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {130 + hearts * 20}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Порог, ниже которого летучим мышам не может быть нанесен урон. Работает только на атаки ближнего боя. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Порог урона:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {3 + hearts * 2}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Скорость передвижения летучих мышей. Чем ниже, тем лучше. Снижается при извлечении легких."
              color="transparent"
            >
              Скорость:
            </Button>
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {(-lungs * 0.05).toFixed(2)}
              {lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Наименьший урон, который могут нанести летучие мыши. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Минимум урона:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {10 + Math.floor(hearts / 2)}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Наибольший урон, который могут нанести летучие мыши. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Максимум урона:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {15 + hearts}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Количество здоровья, которое летучие мыши преобразуют в свое собственное после каждой успешной атаки. Увеличивается при извлечении почек."
              color="transparent"
            >
              Восстановление:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Количество крови, которое получат летучие мыши от каждого живого гуманоида после каждой успешной атаки. Увеличивается при извлечении печени."
              color="transparent"
            >
              Поглощение крови:
            </Button>
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {Math.floor(livers / 2)}
              {livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Шанс для летучих мышей на оглушение жертвы на 1 секунду после каждой успешной атаки. Увеличивается при извлечении глаз."
              color="transparent"
            >
              Шанс на испуг:
            </Button>
            <Box
              inline
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
            >
              {eyes * 3}%{eyes < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const ResonantShriek = (_props: unknown) => {
  const { data } = useBackend<VampireTrophiesStatusData>();
  const { trophies_max_gen, trophies_max_crit, hearts, kidneys, eyes, ears } =
    data;
  return (
    <Section
      title="Оглушительный вопль"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Радиус зоны поражения, с центром в точке нахождения вампира. Все живые мобы в области будут задеты. Увеличивается при извлечении ушей."
              color="transparent"
            >
              Радиус поражения:
            </Button>
            <Box
              inline
              textColor={ears < trophies_max_gen ? 'average' : 'good'}
            >
              {2 + Math.floor(ears / 3)}
              {ears < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Время, которое каждый живой моб в области поражения будет оглушен. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Время оглушения:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {roundTenths(hearts / 3)}s.
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Время, которое каждый живой моб в области поражения будет в замешательстве. Увеличивается при извлечении почек."
              color="transparent"
            >
              Время замешательства:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {roundTenths(kidneys)}s.
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Количество урона мозгу, которое получит каждый живой моб в области поражения. Увеличивается при извлечении глаз."
              color="transparent"
            >
              Урон мозгу:
            </Button>
            <Box
              inline
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
            >
              {eyes * 3}
              {eyes < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const Anabiosis = (_props: unknown) => {
  const { data } = useBackend<VampireTrophiesStatusData>();
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    full_power,
  } = data;
  return (
    <Section
      title="Анабиоз"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Максимально количество травм, которое может вылечить вампир во время анабиоза. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Лечение травм:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {15 * (hearts + 4)}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Максимально количество ожогов, которое может вылечить вампир во время анабиоза. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Лечение ожогов:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {15 * (hearts + 4)}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Максимально количество токсинов, которое может вылечить вампир во время анабиоза. Увеличивается при извлечении печени."
              color="transparent"
            >
              Лечение токсинов:
            </Button>
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {15 * (livers + 4)}
              {livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Максимально количество удушья, которое может вылечить вампир во время анабиоза. Увеличивается при извлечении легких."
              color="transparent"
            >
              Лечение гипоксии:
            </Button>
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {15 * (lungs * 2 + 8)}
              {lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Максимально количество клеточных повреждений, которое может вылечить вампир во время анабиоза. Увеличивается при извлечении почек."
              color="transparent"
            >
              Клеточное восстановление:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {15 * Math.round(kidneys / 2 + 2)}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Максимально количество крови, которое может восстановить тело вампира во время анабиоза. Увеличивается при извлечении почек."
              color="transparent"
            >
              Восстановление крови:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {15 * (kidneys * 2 + 12)}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Максимально количество повреждений внутренним органам, которое может вылечить вампир во время анабиоза. Увеличивается при извлечении почек."
              color="transparent"
            >
              Лечение органов:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {15 * Math.round(kidneys / 5 + 1)}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Максимально количество реагентов, которое может вывести тело вампира во время анабиоза. Увеличивается при извлечении печени."
              color="transparent"
            >
              Выведение реагентов:
            </Button>
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {15 * (livers + 5)}
              {livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Шанс срастить сломанные кости за цикл анабиоза (15 всего циклов). Увеличивается при извлечении сердец."
              color="transparent"
            >
              Сращивание перелома:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {hearts * 4}%{hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Шанс избавиться от внутреннего кровотечения за цикл анабиоза (15 всего циклов). Увеличивается при извлечении сердец."
              color="transparent"
            >
              Снятие кровотечения:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {hearts * 4}%{hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Шанс отрастить конечность за цикл анабиоза (15 всего циклов). Увеличивается при извлечении легких."
              color="transparent"
            >
              Отращивание конечности:
            </Button>
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {lungs * 2}%{lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Одноразовая способность: убирает все наложенные эффекты, восстанавливает все мертвые органы и конечности, излечивает все вредные вирусы и выводит всех паразитов."
              color="transparent"
            >
              Полное исцеление:
            </Button>
            <Box inline textColor={full_power ? 'good' : 'bad'}>
              {full_power ? 'ЕСТЬ' : 'НЕТ'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const SummonBats = (_props: unknown) => {
  const { data } = useBackend<VampireTrophiesStatusData>();
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  let allTrophies = hearts + lungs + livers + kidneys + eyes + ears;
  let maxBats =
    1 +
    (allTrophies < 40 ? Math.round(allTrophies / 2) : allTrophies < 52 ? 2 : 3);
  return (
    <Section
      title="Призыв летучих мышей"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Максимальное здоровье, которое могут иметь летучие мыши. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Здоровье:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {80 + hearts * 10}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Порог, ниже которого летучим мышам не может быть нанесен урон. Работает только на атаки ближнего боя. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Порог урона:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {3 + hearts}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Скорость передвижения летучих мышей. Чем ниже, тем лучше. Снижается при извлечении легких."
              color="transparent"
            >
              Скорость:
            </Button>
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {(1 - lungs * 0.1).toFixed(2)}
              {lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Наименьший урон, который могут нанести летучие мыши. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Минимум урона:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {5 + Math.floor(hearts / 2)}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Наибольший урон, который могут нанести летучие мыши. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Максимум урона:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {10 + hearts}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Количество здоровья, которое летучие мыши преобразуют в свое собственное после каждой успешной атаки. Увеличивается при извлечении почек."
              color="transparent"
            >
              Восстановление:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Количество крови, которое получат летучие мыши от каждого живого разумного гуманоида после каждой успешной атаки. Увеличивается при извлечении печени."
              color="transparent"
            >
              Поглощение крови:
            </Button>
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {Math.floor(livers / 2)}
              {livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Шанс для летучих мышей на оглушение жертвы на 0.5 секунды после каждой успешной атаки. Увеличивается при извлечении глаз."
              color="transparent"
            >
              Шанс на испуг:
            </Button>
            <Box
              inline
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
            >
              {Math.floor(eyes * 1.5)}%{eyes < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Количество летучих мышей, призываемых за раз. Увеличивается при извлечении любого трофейного органа."
              color="transparent"
            >
              Количество:
            </Button>
            <Box inline textColor={allTrophies < 52 ? 'average' : 'good'}>
              {maxBats}
              {allTrophies < 52 ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const MetamorphosisHound = (_props: unknown) => {
  const { data } = useBackend<VampireTrophiesStatusData>();
  const { trophies_max_gen, trophies_max_crit, hearts, lungs, livers, eyes } =
    data;
  return (
    <Section
      title="Метаморфоза - Гончая"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Максимальное здоровье гончей. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Здоровье:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {200 + hearts * 30}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Порог, ниже которого гончей не может быть нанесен урон. Работает только на атаки ближнего боя. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Порог урона:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {10 + hearts * 3}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Скорость передвижения гончей. Чем ниже, тем лучше. Снижается при извлечении легких."
              color="transparent"
            >
              Скорость:
            </Button>
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {(-lungs * 0.05).toFixed(2)}
              {lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Наименьший урон, который может нанести гончая. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Минимум урона:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {15 + hearts}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Наименьший урон, который может нанести гончая. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Максимум урона
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {20 + hearts}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Шанс для гончей на оглушение жертвы на 1 секунду после каждой успешной атаки. Увеличивается при извлечении глаз."
              color="transparent"
            >
              Шанс на испуг:
            </Button>
            <Box
              inline
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
            >
              {eyes * 3}%{eyes < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Количество крови, которое будет тратить вампир, чтобы оставаться в форме гончей. Снижается при извлечении печени."
              color="transparent"
            >
              Потребление крови:
            </Button>
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {15 - livers} крови / 6с.
              {livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const LungeFinale = (_props: unknown) => {
  const { data } = useBackend<VampireTrophiesStatusData>();
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  let allTrophies = hearts + lungs + livers + kidneys + eyes + ears;
  return (
    <Section
      title="Финальный рывок"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Радиус вокруг вампира, внутри которой ищется цель для рывка. Увеличивается при извлечении легких."
              color="transparent"
            >
              Радиус поиска:
            </Button>
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {5 + Math.round(lungs / 2)}
              {lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Радиус зоны поражения, с центром в конечной точке рывка. Все живые мобы в области будут задеты. Увеличивается при извлечении ушей."
              color="transparent"
            >
              Радиус поражения:
            </Button>
            <Box
              inline
              textColor={ears < trophies_max_gen ? 'average' : 'good'}
            >
              {Math.floor(ears / 5)}
              {ears < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Время, которое каждый живой моб в области поражения будет оглушен. Увеличивается при извлечении сердец."
              color="transparent"
            >
              Время оглушения:
            </Button>
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {roundTenths(1 + hearts / 2)}s.
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Время, которое каждый живой моб в области поражения будет в замешательстве. Увеличивается при извлечении почек."
              color="transparent"
            >
              Время замешательства:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {roundTenths(kidneys * 2)}с.
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Количество крови, которое потеряет каждый живой гуманоид в области поражения. Увеличивается при извлечении почек."
              color="transparent"
            >
              Кровопотеря:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys * 5}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Количество крови, которое получит вампир от каждого живого разумного гуманоида в области поражения. Увеличивается при извлечении почек."
              color="transparent"
            >
              Поглощение крови:
            </Button>
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Количество рывков, которое совершит гончая. Увеличивается при извлечении любого трофейного органа."
              color="transparent"
            >
              Количество рывков:
            </Button>
            <Box inline textColor={allTrophies < 50 ? 'average' : 'good'}>
              {1 + Math.floor(allTrophies / 10)}
              {allTrophies < 50 ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="После активации способности гончая выполнит определенное количество рывков по любым живым разумным целям в области поиска, ставя приоритет на новые цели."
              color="transparent"
            >
              Дополнительная информация
            </Button>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};
