import { round } from 'common/math';
import { Fragment } from 'inferno';
import { useBackend } from "../backend";
import { AnimatedNumber, Box, Button, Flex, Icon, LabeledList, ProgressBar, Section, Table, Tooltip } from "../components";
import { Window } from "../layouts";

const stats = [
  ['good', 'Жив'],
  ['average', 'Критическое состояние'],
  ['bad', 'МЁРТВ'],
];

const abnormalities = [
  ['hasBorer', 'bad', 'Во фронтальной коре обнаружен крупный нарост. Потенциальная онкология. '
    + 'Рекомендуется хирургическое вмешательство.'],
  ['hasVirus', 'bad', 'В крови обнаружен вирусный патоген.'],
  ['blind', 'average', 'Обнаружена катаракта.'],
  ['colourblind', 'average', 'Обнаружена аномалия фоторецепторов.'],
  ['nearsighted', 'average', 'Обнаружено смещение сетчатки.'],
];

const damages = [
  ['Асфиксия', 'oxyLoss'],
  ['Мозг', 'brainLoss'],
  ['Интоксикация', 'toxLoss'],
  ['Радиационные', 'radLoss'],
  ['Раны', 'bruteLoss'],
  ['Генетические', 'cloneLoss'],
  ['Ожоги', 'fireLoss'],
  ['Паралич', 'paralysis'],
];

const damageRange = {
  average: [0.25, 0.5],
  bad: [0.5, Infinity],
};

const mapTwoByTwo = (a, c) => {
  let result = [];
  for (let i = 0; i < a.length; i += 2) {
    result.push(c(a[i], a[i + 1], i));
  }
  return result;
};

const reduceOrganStatus = A => {
  return A.length > 0
    ? A
      .filter(s => !!s)
      .reduce((a, s) => (
        <Fragment>
          {a}
          <Box key={s}>
            {s}
          </Box>
        </Fragment>
      ), null)
    : null;
};

const germStatus = i => {
  if (i > 100) {
    if (i < 300) { return "лёгкое заражение"; }
    if (i < 400) { return "лёгкое заражение+"; }
    if (i < 500) { return "лёгкое заражение++"; }
    if (i < 700) { return "острая инфекция"; }
    if (i < 800) { return "острая инфекция+"; }
    if (i < 900) { return "острая инфекция++"; }
    if (i >= 900) { return "сепсис"; }
  }

  return "";
};

export const BodyScanner = (props, context) => {
  const { data } = useBackend(context);
  const {
    occupied,
    occupant = {},
  } = data;
  const body = occupied ? (
    <BodyScannerMain occupant={occupant} />
  ) : (
    <BodyScannerEmpty />
  );
  return (
    <Window resizable>
      <Window.Content scrollable className="Layout__content--flexColumn">
        {body}
      </Window.Content>
    </Window>
  );
};

const BodyScannerMain = props => {
  const {
    occupant,
  } = props;
  return (
    <Box>
      <BodyScannerMainOccupant occupant={occupant} />
      <BodyScannerMainAbnormalities occupant={occupant} />
      <BodyScannerMainDamage occupant={occupant} />
      <BodyScannerMainOrgansExternal organs={occupant.extOrgan} />
      <BodyScannerMainOrgansInternal organs={occupant.intOrgan} />
    </Box>
  );
};

const BodyScannerMainOccupant = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    occupant,
  } = data;
  return (
    <Section
      title="Пациент"
      buttons={(
        <Fragment>
          <Button
            icon="print"
            onClick={() => act('print_p')}>
            Напечатать отчёт
          </Button>
          <Button
            icon="user-slash"
            onClick={() => act('ejectify')}>
            Извлечь
          </Button>
        </Fragment>
      )}>
      <LabeledList>
        <LabeledList.Item label="Имя">
          {occupant.name}
        </LabeledList.Item>
        <LabeledList.Item label="Здоровье">
          <ProgressBar
            min="0"
            max={occupant.maxHealth}
            value={occupant.health / occupant.maxHealth}
            ranges={{
              good: [0.5, Infinity],
              average: [0, 0.5],
              bad: [-Infinity, 0],
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Статус" color={stats[occupant.stat][0]}>
          {stats[occupant.stat][1]}
        </LabeledList.Item>
        <LabeledList.Item label="Температура">
          <AnimatedNumber value={round(occupant.bodyTempC, 0)} /> °C
        </LabeledList.Item>
        <LabeledList.Item label="Импланты">
          {occupant.implant_len ? (
            <Box>
              {occupant.implant.map(im => im.name).join(', ')}
            </Box>
          ) : (
            <Box color="label">
              Нет
            </Box>
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const BodyScannerMainAbnormalities = props => {
  const {
    occupant,
  } = props;
  if (!(occupant.hasBorer || occupant.blind
        || occupant.colourblind || occupant.nearsighted
        || occupant.hasVirus)) {
    return (
      <Section title="Патологии">
        <Box color="label">
          Патологий не найдено.
        </Box>
      </Section>
    );
  }

  return (
    <Section title="Патологии">
      {abnormalities.map((a, i) => {
        if (occupant[a[0]]) {
          return (
            <Box color={a[1]} bold={a[1] === "bad"}>
              {a[2]}
            </Box>
          );
        }
      })}
    </Section>
  );
};

const BodyScannerMainDamage = props => {
  const {
    occupant,
  } = props;
  return (
    <Section title="Повреждения">
      <Table>
        {mapTwoByTwo(damages, (d1, d2, i) => (
          <Fragment>
            <Table.Row color="label">
              <Table.Cell>
                {d1[0]}:
              </Table.Cell>
              <Table.Cell>
                {!!d2 && d2[0] + ":"}
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <BodyScannerMainDamageBar
                  value={occupant[d1[1]]}
                  marginBottom={i < (damages.length - 2)}
                />
              </Table.Cell>
              <Table.Cell>
                {!!d2 && (
                  <BodyScannerMainDamageBar value={occupant[d2[1]]} />
                )}
              </Table.Cell>
            </Table.Row>
          </Fragment>
        ))}
      </Table>
    </Section>
  );
};

const BodyScannerMainDamageBar = props => {
  return (
    <ProgressBar
      min="0"
      max="100"
      value={props.value / 100}
      mt="0.5rem"
      mb={!!props.marginBottom && "0.5rem"}
      ranges={damageRange}>
      {round(props.value, 0)}
    </ProgressBar>
  );
};

const BodyScannerMainOrgansExternal = props => {
  if (props.organs.length === 0) {
    return (
      <Section title="Конечности">
        <Box color="label">
          Не обнаружены
        </Box>
      </Section>
    );
  }

  return (
    <Section title="Конечности">
      <Table>
        <Table.Row header>
          <Table.Cell>
            Название
          </Table.Cell>
          <Table.Cell textAlign="center">
            Повреждения
          </Table.Cell>
          <Table.Cell textAlign="right">
            Травмы
          </Table.Cell>
        </Table.Row>
        {props.organs.map((o, i) => (
          <Table.Row key={i} textTransform="capitalize">
            <Table.Cell
              color={
                !!o.status.dead && "bad"
                || ((!!o.internalBleeding || !!o.lungRuptured || !!o.status.broken || !!o.open || o.germ_level > 100) && "average")
                || (!!o.status.robotic && "label")
              }
              width="33%">
              {o.name}
            </Table.Cell>
            <Table.Cell textAlign="center" q>
              <ProgressBar
                min="0"
                max={o.maxHealth}
                mt={i > 0 && "0.5rem"}
                value={o.totalLoss / 100}
                ranges={damageRange}>
                <Box float="left" display="inline">
                  {!!o.bruteLoss && (
                    <Box display="inline" position="relative">
                      <Icon name="bone" />
                      {round(o.bruteLoss, 0)}&nbsp;
                      <Tooltip
                        position="top"
                        content="Раны"
                      />
                    </Box>)}
                  {!!o.fireLoss && (
                    <Box display="inline" position="relative">
                      <Icon name="fire" />
                      {round(o.fireLoss, 0)}
                      <Tooltip
                        position="top"
                        content="Ожоги"
                      />
                    </Box>)}
                </Box>
                <Box display="inline">
                  {round(o.totalLoss, 0)}
                </Box>
              </ProgressBar>
            </Table.Cell>
            <Table.Cell
              textAlign="right"
              verticalAlign="top"
              width="33%"
              pt={i > 0 && "calc(0.5rem + 2px)"}>
              <Box color="average" display="inline">
                {reduceOrganStatus([
                  !!o.internalBleeding && "Внутреннее кровотечение",
                  !!o.lungRuptured && "Разорванное лёгкое",
                  !!o.status.broken && o.status.broken,
                  germStatus(o.germ_level),
                  !!o.open && "Открытый разрез",
                ])}
              </Box>
              <Box display="inline">
                {reduceOrganStatus([
                  !!o.status.splinted && <Box color="good">Наложена шина</Box>,
                  !!o.status.robotic && <Box color="label">Робопротез</Box>,
                  !!o.status.dead && <Box color="bad" bold>МЁРТВ</Box>,
                ])}
                {reduceOrganStatus(o.shrapnel.map(
                  s => s.known
                    ? s.name
                    : "Неизвестный объект"
                ))}
              </Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const BodyScannerMainOrgansInternal = props => {
  if (props.organs.length === 0) {
    return (
      <Section title="Внутренние органы">
        <Box color="label">
          Нет
        </Box>
      </Section>
    );
  }

  return (
    <Section title="Внутренние органы">
      <Table>
        <Table.Row header>
          <Table.Cell>
            Название
          </Table.Cell>
          <Table.Cell textAlign="center">
            Повреждения
          </Table.Cell>
          <Table.Cell textAlign="right">
            Травмы
          </Table.Cell>
        </Table.Row>
        {props.organs.map((o, i) => (
          <Table.Row key={i} textTransform="capitalize">
            <Table.Cell
              color={
                !!o.dead && "bad"
                || (o.germ_level > 100 && "average")
                || (o.robotic > 0 && "label")
              }
              width="33%">
              {o.name}
            </Table.Cell>
            <Table.Cell textAlign="center">
              <ProgressBar
                min="0"
                max={o.maxHealth}
                value={o.damage / 100}
                mt={i > 0 && "0.5rem"}
                ranges={damageRange}>
                {round(o.damage, 0)}
              </ProgressBar>
            </Table.Cell>
            <Table.Cell
              textAlign="right"
              verticalAlign="top"
              width="33%"
              pt={i > 0 && "calc(0.5rem + 2px)"}>
              <Box color="average" display="inline">
                {reduceOrganStatus([
                  germStatus(o.germ_level),
                ])}
              </Box>
              <Box display="inline">
                {reduceOrganStatus([
                  (o.robotic === 1) && <Box color="label">Робопротез</Box>,
                  (o.robotic === 2) && <Box color="label">Assisted</Box>,
                  !!o.dead && <Box color="bad" bold>МЁРТВ</Box>,
                ])}
              </Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const BodyScannerEmpty = () => {
  return (
    <Section textAlign="center" flexGrow="1">
      <Flex height="100%">
        <Flex.Item grow="1" align="center" color="label">
          <Icon
            name="user-slash"
            mb="0.5rem"
            size="5"
          /><br />
          Пациент не обнаружен.
        </Flex.Item>
      </Flex>
    </Section>
  );
};
