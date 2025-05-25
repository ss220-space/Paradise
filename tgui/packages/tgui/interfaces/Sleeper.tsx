import { round } from 'common/math';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';
import { ReactNode } from 'react';

const stats = [
  ['good', 'Норма'],
  ['average', 'Критическое состояние'],
  ['bad', 'Зафиксирована смерть'],
];

const damages = [
  ['Удушье', 'oxyLoss'],
  ['Отравление', 'toxLoss'],
  ['Мех.', 'bruteLoss'],
  ['Терм.', 'fireLoss'],
];

const damageRange: Record<string, [number, number]> = {
  average: [0.25, 0.5],
  bad: [0.5, Infinity],
};

const tempColors = [
  'bad',
  'average',
  'average',
  'good',
  'average',
  'average',
  'bad',
];

type SleeperData = {
  hasOccupant: boolean;
  occupant: SleeperOcupant;
  auto_eject_dead: boolean;
  isBeakerLoaded: boolean;
  beakerMaxSpace: number;
  beakerFreeSpace: number;
  dialysis: boolean;
  chemicals: Chemical[];
  maxchem: number;
  amounts: number[];
};

type Chemical = {
  title: string;
  id: string;
  od_warning: boolean;
  overdosing: boolean;
  occ_amount: number;
  pretty_amount: number;
  injectable: boolean;
};

type SleeperOcupant = {
  maxTemp: number;
  temperatureSuitability: number;
  btCelsius: number;
  btFaren: number;
  hasBlood: boolean;
  bloodMax: number;
  bloodLevel: number;
  bloodPercent: number;
  pulse: number;
  oxyLoss: number;
  toxLoss: number;
  bruteLoss: number;
  fireLoss: number;
} & Occupant;

export const Sleeper = (_props: unknown) => {
  const { data } = useBackend<SleeperData>();
  const { hasOccupant } = data;
  const body = hasOccupant ? <SleeperMain /> : <SleeperEmpty />;
  return (
    <Window width={550} height={760}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item grow>{body}</Stack.Item>
          <Stack.Item>
            <SleeperDialysis />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SleeperMain = (_props: unknown) => {
  return (
    <>
      <SleeperOccupant />
      <SleeperDamage />
      <SleeperChemicals />
    </>
  );
};

const SleeperOccupant = (_props: unknown) => {
  const { act, data } = useBackend<SleeperData>();
  const { occupant, auto_eject_dead } = data;
  return (
    <Section
      title="Пациент"
      buttons={
        <>
          <Box color="label" inline>
            Авто-извлечение трупов:&nbsp;
          </Box>
          <Button
            icon={auto_eject_dead ? 'toggle-on' : 'toggle-off'}
            selected={auto_eject_dead}
            onClick={() =>
              act('auto_eject_dead_' + (auto_eject_dead ? 'off' : 'on'))
            }
          >
            {auto_eject_dead ? 'Да' : 'Нет'}
          </Button>
          <Button icon="user-slash" onClick={() => act('ejectify')}>
            Извлечь пациента
          </Button>
        </>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Имя">{occupant.name}</LabeledList.Item>
        <LabeledList.Item label="Оценка здорвоья">
          <ProgressBar
            minValue={0}
            maxValue={occupant.maxHealth}
            value={occupant.health}
            ranges={{
              good: [0.5, Infinity],
              average: [0, 0.5],
              bad: [-Infinity, 0],
            }}
          >
            {round(occupant.health, 0)}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Состояние" color={stats[occupant.stat][0]}>
          {stats[occupant.stat][1]}
        </LabeledList.Item>
        <LabeledList.Item label="Температура">
          <ProgressBar
            minValue={0}
            maxValue={occupant.maxTemp}
            value={occupant.bodyTemperature}
            color={tempColors[occupant.temperatureSuitability + 3]}
          >
            {round(occupant.btCelsius, 0)}&deg;C,
            {round(occupant.btFaren, 0)}&deg;F
          </ProgressBar>
        </LabeledList.Item>
        {!!occupant.hasBlood && (
          <>
            <LabeledList.Item label="Уровень крови">
              <ProgressBar
                minValue={0}
                maxValue={occupant.bloodMax}
                value={occupant.bloodLevel}
                ranges={{
                  bad: [-Infinity, 0.6],
                  average: [0.6, 0.9],
                  good: [0.6, Infinity],
                }}
              >
                {occupant.bloodPercent}%, {occupant.bloodLevel}cl
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Пульс" verticalAlign="middle">
              {occupant.pulse} BPM
            </LabeledList.Item>
          </>
        )}
      </LabeledList>
    </Section>
  );
};

const SleeperDamage = (_props: unknown) => {
  const { data } = useBackend<SleeperData>();
  const { occupant } = data;
  return (
    <Section title="Общий урон">
      <LabeledList>
        {damages.map((d, i) => (
          <LabeledList.Item key={i} label={d[0]}>
            <ProgressBar
              key={i}
              minValue={0}
              maxValue={100}
              value={occupant[d[1]]}
              ranges={damageRange}
            >
              {round(occupant[d[1]], 0)}
            </ProgressBar>
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const SleeperDialysis = (_props: unknown) => {
  const { act, data } = useBackend<SleeperData>();
  const {
    hasOccupant,
    isBeakerLoaded,
    beakerMaxSpace,
    beakerFreeSpace,
    dialysis,
  } = data;
  const canDialysis = dialysis && beakerFreeSpace > 0;
  return (
    <Section
      title="Диализ"
      buttons={
        <>
          <Button
            disabled={!isBeakerLoaded || beakerFreeSpace <= 0 || !hasOccupant}
            selected={canDialysis}
            icon={canDialysis ? 'toggle-on' : 'toggle-off'}
            onClick={() => act('togglefilter')}
          >
            {canDialysis ? 'Включено' : 'Выключено'}
          </Button>
          <Button
            disabled={!isBeakerLoaded}
            icon="eject"
            onClick={() => act('removebeaker')}
          >
            Извлечь
          </Button>
        </>
      }
    >
      {isBeakerLoaded ? (
        <LabeledList>
          <LabeledList.Item label="Остаточный объём">
            <ProgressBar
              minValue={0}
              maxValue={beakerMaxSpace}
              value={beakerFreeSpace}
              ranges={{
                good: [0.5, Infinity],
                average: [0.25, 0.5],
                bad: [-Infinity, 0.25],
              }}
            >
              {beakerFreeSpace}u
            </ProgressBar>
          </LabeledList.Item>
        </LabeledList>
      ) : (
        <Box color="label">Ёмкость не установлена.</Box>
      )}
    </Section>
  );
};

const SleeperChemicals = (_props: unknown) => {
  const { act, data } = useBackend<SleeperData>();
  const { occupant, chemicals, maxchem, amounts } = data;
  return (
    <Section title="Кровоток пациента">
      {chemicals.map((chem, i) => {
        let barColor = '';
        let odWarning: ReactNode;
        if (chem.overdosing) {
          barColor = 'bad';
          odWarning = (
            <Box color="bad">
              <Icon name="exclamation-circle" />
              &nbsp; Передозировка!
            </Box>
          );
        } else if (chem.od_warning) {
          barColor = 'average';
          odWarning = (
            <Box color="average">
              <Icon name="exclamation-triangle" />
              &nbsp; Риск передозировки
            </Box>
          );
        }
        return (
          <Box key={i} backgroundColor="rgba(0, 0, 0, 0.33)" mb="0.5rem">
            <Section
              title={chem.title}
              mx="0"
              lineHeight="18px"
              buttons={odWarning}
            >
              <Stack>
                <ProgressBar
                  minValue={0}
                  maxValue={maxchem}
                  value={chem.occ_amount}
                  color={barColor}
                  mr="0.5rem"
                >
                  {chem.pretty_amount}/{maxchem}u
                </ProgressBar>
                {amounts.map((a, i) => (
                  <Button
                    key={i}
                    disabled={
                      !chem.injectable ||
                      chem.occ_amount + a > maxchem ||
                      occupant.stat === 2
                    }
                    icon="syringe"
                    tooltip={
                      'Ввести ' + a + 'u вещества ' + chem.title + ' в пациента'
                    }
                    mb="0"
                    height="19px"
                    onClick={() =>
                      act('chemical', {
                        chemid: chem.id,
                        amount: a,
                      })
                    }
                  >
                    {'Ввести ' + a + 'u'}
                  </Button>
                ))}
              </Stack>
            </Section>
          </Box>
        );
      })}
    </Section>
  );
};

const SleeperEmpty = (_props: unknown) => {
  return (
    <Section fill textAlign="center">
      <Stack fill>
        <Stack.Item grow align="center" color="label">
          <Icon name="user-slash" mb="0.5rem" size={5} />
          <br />
          Пациент внутри не обнаружен.
        </Stack.Item>
      </Stack>
    </Section>
  );
};
