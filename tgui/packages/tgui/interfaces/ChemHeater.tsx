import { round, toFixed } from 'common/math';
import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from '../components';
import { BeakerContents } from '../interfaces/common/BeakerContents';
import { Window } from '../layouts';

export const ChemHeater = (_props: unknown) => {
  return (
    <Window width={450} height={275}>
      <Window.Content>
        <Stack fill vertical>
          <ChemHeaterSettings />
          <ChemHeaterBeaker />
        </Stack>
      </Window.Content>
    </Window>
  );
};

type ChemHeaterData = {
  targetTemp: number;
  targetTempReached: boolean;
  autoEject: boolean;
  isActive: boolean;
  currentTemp: number;
  isBeakerLoaded: boolean;
};

const ChemHeaterSettings = (_properties) => {
  const { act, data } = useBackend<ChemHeaterData>();
  const {
    targetTemp,
    targetTempReached,
    autoEject,
    isActive,
    currentTemp,
    isBeakerLoaded,
  } = data;
  return (
    <Stack.Item>
      <Section
        fill
        title="Параметры"
        buttons={
          <>
            <Button
              icon={autoEject ? 'toggle-on' : 'toggle-off'}
              selected={autoEject}
              onClick={() => act('toggle_autoeject')}
            >
              Авто-извлечение
            </Button>
            <Button
              icon="power-off"
              selected={isActive}
              disabled={!isBeakerLoaded}
              onClick={() => act('toggle_on')}
            >
              {isActive ? 'Включено' : 'Выключено'}
            </Button>
          </>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Целевая температура">
            <NumberInput
              width="65px"
              unit="K"
              step={10}
              stepPixelSize={3}
              value={round(targetTemp, 0)}
              minValue={0}
              maxValue={1000}
              onDrag={(value) =>
                act('adjust_temperature', {
                  target: value,
                })
              }
            />
          </LabeledList.Item>
          <LabeledList.Item
            label="Текущая температура"
            color={targetTempReached ? 'good' : 'average'}
          >
            {(isBeakerLoaded && (
              <AnimatedNumber
                value={currentTemp}
                format={(value) => toFixed(value) + ' K'}
              />
            )) ||
              '—'}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const ChemHeaterBeaker = (_properties) => {
  const { act, data } = useBackend<BeakerData>();
  const {
    isBeakerLoaded,
    beakerCurrentVolume,
    beakerMaxVolume,
    beakerContents,
  } = data;
  return (
    <Stack.Item grow>
      <Section
        title="Ёмкость"
        fill
        scrollable
        buttons={
          !!isBeakerLoaded && (
            <Box>
              <Box inline color="label" mr={2}>
                {beakerCurrentVolume} / {beakerMaxVolume} единиц
              </Box>
              <Button icon="eject" onClick={() => act('eject_beaker')}>
                Извлечь
              </Button>
            </Box>
          )
        }
      >
        <BeakerContents
          beakerLoaded={isBeakerLoaded}
          beakerContents={beakerContents}
        />
      </Section>
    </Stack.Item>
  );
};
