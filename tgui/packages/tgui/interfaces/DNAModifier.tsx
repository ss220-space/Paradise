import { ReactNode } from 'react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dimmer,
  Flex,
  Stack,
  Icon,
  Knob,
  LabeledList,
  ProgressBar,
  Section,
  Tabs,
} from '../components';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

const stats = [
  ['good', 'Норма'],
  ['average', 'Критическое состояние'],
  ['bad', 'Зафиксирована смерть'],
];

const operations = [
  ['ui', 'Модификация УИ', 'dna'],
  ['se', 'Модификация СФ', 'dna'],
  ['buffer', 'Буфер данных', 'syringe'],
  ['rejuvenators', 'Химикаты', 'flask'],
];

const rejuvenatorsDoses = [5, 10, 20, 30, 50];

type DNAModifierData = {
  irradiating: boolean;
  dnaBlockSize: number;
  occupant: DNAModifierOccupantData;
  locked: boolean;
  hasOccupant: boolean;
  selectedMenuKey: string;
  selectedUIBlock: number;
  selectedUISubBlock: number;
  selectedUITarget: number;
  selectedSEBlock: number;
  selectedSESubBlock: number;
  radiationIntensity: number;
  radiationDuration: number;
  isInjectorReady: boolean;
  hasDisk: boolean;
  disk: Disk;
  buffers: Buffer[];
};

type Disk = Buffer;

type DNAModifierOccupantData = {
  structuralEnzymes: string;
  isViableSubject: boolean;
  uniqueIdentity: string;
  minHealth: number;
  radiationLevel: number;
  uniqueEnzymes: string;
} & Occupant;

export const DNAModifier = (props: unknown) => {
  const { data } = useBackend<DNAModifierData>();
  const { irradiating, dnaBlockSize, occupant } = data;

  const isDNAInvalid =
    !occupant.isViableSubject ||
    !occupant.uniqueIdentity ||
    !occupant.structuralEnzymes;
  let radiatingModal: ReactNode;
  if (irradiating) {
    radiatingModal = <DNAModifierIrradiating duration={irradiating} />;
  }
  return (
    <Window width={660} height={775}>
      <ComplexModal />
      {radiatingModal}
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <DNAModifierOccupant isDNAInvalid={isDNAInvalid} />
          </Stack.Item>
          <Stack.Item grow>
            <DNAModifierMain
              isDNAInvalid={isDNAInvalid}
              dnaBlockSize={dnaBlockSize}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type DNAModifierOccupantProps = {
  isDNAInvalid?: boolean;
};

const DNAModifierOccupant = ({ isDNAInvalid }: DNAModifierOccupantProps) => {
  const { act, data } = useBackend<DNAModifierData>();
  const { locked, hasOccupant, occupant } = data;
  return (
    <Section
      title="Субъект"
      buttons={
        <>
          <Box color="label" inline mr="0.5rem">
            Электронный замок:
          </Box>
          <Button
            disabled={!hasOccupant}
            selected={locked}
            icon={locked ? 'toggle-on' : 'toggle-off'}
            onClick={() => act('toggleLock')}
          >
            {locked ? 'Включён' : 'Выключен'}
          </Button>
          <Button
            disabled={!hasOccupant || locked}
            icon="user-slash"
            onClick={() => act('ejectOccupant')}
          >
            Извлечь субъект
          </Button>
        </>
      }
    >
      {hasOccupant ? (
        <>
          <Box>
            <LabeledList>
              <LabeledList.Item label="Имя">{occupant.name}</LabeledList.Item>
              <LabeledList.Item label="Оценка здоровья">
                <ProgressBar
                  minValue={occupant.minHealth}
                  maxValue={occupant.maxHealth}
                  value={occupant.health / occupant.maxHealth}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0, 0.5],
                    bad: [-Infinity, 0],
                  }}
                />
              </LabeledList.Item>
              <LabeledList.Item
                label="Состояние"
                color={stats[occupant.stat][0]}
              >
                {stats[occupant.stat][1]}
              </LabeledList.Item>
              <LabeledList.Divider />
            </LabeledList>
          </Box>
          {isDNAInvalid ? (
            <Box color="bad">
              <Icon name="exclamation-circle" />
              &nbsp; Неподходящий субъект. Проведение манипуляций со структурой
              ДНК невозможно.
            </Box>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Радиационное поражение">
                <ProgressBar
                  minValue={0}
                  maxValue={100}
                  value={occupant.radiationLevel / 100}
                  color="average"
                />
              </LabeledList.Item>
              <LabeledList.Item label="Уникальные Ферменты">
                {data.occupant.uniqueEnzymes ? (
                  data.occupant.uniqueEnzymes
                ) : (
                  <Box color="bad">
                    <Icon name="exclamation-circle" />
                    &nbsp; Н/Д
                  </Box>
                )}
              </LabeledList.Item>
            </LabeledList>
          )}
        </>
      ) : (
        <Box color="label">Капсула ДНК-модификатора пуста.</Box>
      )}
    </Section>
  );
};

type DNAModifierMainProps = {
  isDNAInvalid?: boolean;
  dnaBlockSize?: number;
};

const DNAModifierMain = (props: DNAModifierMainProps) => {
  const { isDNAInvalid, dnaBlockSize } = props;
  const { act, data } = useBackend<DNAModifierData>();
  const { selectedMenuKey, hasOccupant } = data;
  if (!hasOccupant) {
    return (
      <Section fill>
        <Stack fill>
          <Stack.Item grow align="center" textAlign="center" color="label">
            <Icon name="user-slash" mb="0.5rem" size={5} />
            <br />
            Капсула ДНК-модификатора пуста.
          </Stack.Item>
        </Stack>
      </Section>
    );
  } else if (isDNAInvalid) {
    return (
      <Section fill>
        <Stack fill>
          <Stack.Item grow align="center" textAlign="center" color="label">
            <Icon name="user-slash" mb="0.5rem" size={5} />
            <br />
            Манипуляции со структурой ДНК субъекта невозможны.
          </Stack.Item>
        </Stack>
      </Section>
    );
  }
  let body: ReactNode;
  if (selectedMenuKey === 'ui') {
    body = (
      <>
        <DNAModifierMainUI dnaBlockSize={dnaBlockSize} />
        <DNAModifierMainRadiationEmitter />
      </>
    );
  } else if (selectedMenuKey === 'se') {
    body = (
      <>
        <DNAModifierMainSE dnaBlockSize={dnaBlockSize} />
        <DNAModifierMainRadiationEmitter />
      </>
    );
  } else if (selectedMenuKey === 'buffer') {
    body = <DNAModifierMainBuffers />;
  } else if (selectedMenuKey === 'rejuvenators') {
    body = <DNAModifierMainRejuvenators />;
  }
  return (
    <Section fill>
      <Tabs>
        {operations.map((op, i) => (
          <Tabs.Tab
            key={i}
            icon={op[2]}
            selected={selectedMenuKey === op[0]}
            onClick={() => act('selectMenuKey', { key: op[0] })}
          >
            {op[1]}
          </Tabs.Tab>
        ))}
      </Tabs>
      {body}
    </Section>
  );
};

type DNAModifierMainUIProps = {
  dnaBlockSize?: number;
};

const DNAModifierMainUI = ({ dnaBlockSize }: DNAModifierMainUIProps) => {
  const { act, data } = useBackend<DNAModifierData>();
  const { selectedUIBlock, selectedUISubBlock, selectedUITarget, occupant } =
    data;
  return (
    <Section title="Модификация Уникальных Идентификаторов">
      <DNAModifierBlocks
        dnaString={occupant.uniqueIdentity}
        selectedBlock={selectedUIBlock}
        selectedSubblock={selectedUISubBlock}
        blockSize={dnaBlockSize}
        action="selectUIBlock"
      />
      <LabeledList>
        <LabeledList.Item label="Выбранный блок">
          <Knob
            minValue={1}
            maxValue={15}
            stepPixelSize={20}
            value={selectedUITarget}
            format={(value) => value.toString(16).toUpperCase()}
            ml="0"
            onChange={(e, val) => act('changeUITarget', { value: val })}
          />
        </LabeledList.Item>
      </LabeledList>
      <Button
        icon="radiation"
        mt="0.5rem"
        onClick={() => act('pulseUIRadiation')}
      >
        Облучить выбранный блок
      </Button>
    </Section>
  );
};

type DNAModifierMainSEProps = {
  dnaBlockSize?: number;
};

const DNAModifierMainSE = ({ dnaBlockSize }: DNAModifierMainSEProps) => {
  const { act, data } = useBackend<DNAModifierData>();
  const { selectedSEBlock, selectedSESubBlock, occupant } = data;
  return (
    <Section title="Модификация Структурных Ферментов">
      <DNAModifierBlocks
        dnaString={occupant.structuralEnzymes}
        selectedBlock={selectedSEBlock}
        selectedSubblock={selectedSESubBlock}
        blockSize={dnaBlockSize}
        action="selectSEBlock"
      />
      <Button icon="radiation" onClick={() => act('pulseSERadiation')}>
        Облучить выбранный блок
      </Button>
    </Section>
  );
};

const DNAModifierMainRadiationEmitter = (props: unknown) => {
  const { act, data } = useBackend<DNAModifierData>();
  const { radiationIntensity, radiationDuration } = data;
  return (
    <Section title="Излучатель радиации">
      <LabeledList>
        <LabeledList.Item label="Мощность">
          <Knob
            minValue={1}
            maxValue={10}
            stepPixelSize={20}
            value={radiationIntensity}
            ml="0"
            onChange={(e, val) => act('radiationIntensity', { value: val })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Длительность">
          <Knob
            minValue={1}
            maxValue={20}
            stepPixelSize={10}
            unit="s"
            value={radiationDuration}
            ml="0"
            onChange={(e, val) => act('radiationDuration', { value: val })}
          />
        </LabeledList.Item>
      </LabeledList>
      <Button
        icon="radiation"
        tooltip="Мутирует случайный блок, УИ или СФ субъекта."
        tooltipPosition="top-start"
        mt="0.5rem"
        onClick={() => act('pulseRadiation')}
      >
        Облучить радиацией
      </Button>
    </Section>
  );
};

const DNAModifierMainBuffers = (props: unknown) => {
  const { data } = useBackend<DNAModifierData>();
  const { buffers } = data;
  let bufferElements = buffers.map((buffer, i) => (
    <DNAModifierMainBuffersElement
      key={i}
      id={i + 1}
      name={'Ячейка буфера №' + (i + 1)}
      buffer={buffer}
    />
  ));
  return (
    <Stack fill vertical>
      <Stack.Item height="75%" mt={1}>
        <Section fill scrollable title="Буфер">
          {bufferElements}
        </Section>
      </Stack.Item>
      <Stack.Item height="25%">
        <DNAModifierMainBuffersDisk />
      </Stack.Item>
    </Stack>
  );
};

type DNAModifierBuffersElementProps = {
  id: number;
  name: string;
  buffer: Buffer;
};

type Buffer = {
  data: boolean;
  label: string;
  owner: string;
  type: string;
  ue: string;
};

const DNAModifierMainBuffersElement = (
  props: DNAModifierBuffersElementProps
) => {
  const { act, data } = useBackend<DNAModifierData>();
  const { id, name, buffer } = props;
  const isInjectorReady = data.isInjectorReady;
  const realName = name + (buffer.data ? ' - ' + buffer.label : '');
  return (
    <Box backgroundColor="rgba(0, 0, 0, 0.33)" mb="0.5rem">
      <Section
        title={realName}
        mx="0"
        lineHeight="18px"
        buttons={
          <>
            <Button.Confirm
              disabled={!buffer.data}
              icon="trash"
              onClick={() =>
                act('bufferOption', {
                  option: 'clear',
                  id: id,
                })
              }
            >
              Очистить
            </Button.Confirm>
            <Button
              disabled={!buffer.data}
              icon="pen"
              onClick={() =>
                act('bufferOption', {
                  option: 'changeLabel',
                  id: id,
                })
              }
            >
              Переименовать
            </Button>
            <Button
              disabled={!buffer.data || !data.hasDisk}
              icon="save"
              tooltip="Экспортировать выбранную ячейку буфера на дискету."
              tooltipPosition="bottom-start"
              onClick={() =>
                act('bufferOption', {
                  option: 'saveDisk',
                  id: id,
                })
              }
            >
              Экспортировать
            </Button>
          </>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Записать в буфер">
            <Button
              icon="arrow-circle-down"
              mb="0"
              onClick={() =>
                act('bufferOption', {
                  option: 'saveUI',
                  id: id,
                })
              }
            >
              УИ субъекта
            </Button>
            <Button
              icon="arrow-circle-down"
              mb="0"
              onClick={() =>
                act('bufferOption', {
                  option: 'saveUIAndUE',
                  id: id,
                })
              }
            >
              УИ и УФ субъета
            </Button>
            <Button
              icon="arrow-circle-down"
              mb="0"
              onClick={() =>
                act('bufferOption', {
                  option: 'saveSE',
                  id: id,
                })
              }
            >
              СФ субъекта
            </Button>
            <Button
              disabled={!data.hasDisk || !data.disk.data}
              icon="arrow-circle-down"
              mb="0"
              onClick={() =>
                act('bufferOption', {
                  option: 'loadDisk',
                  id: id,
                })
              }
            >
              С дискеты
            </Button>
          </LabeledList.Item>
          {!!buffer.data && (
            <>
              <LabeledList.Item label="Субъект">
                {buffer.owner || <Box color="average">Неизвестно</Box>}
              </LabeledList.Item>
              <LabeledList.Item label="Тип данных">
                {buffer.type === 'ui'
                  ? 'Уникальные Идентификаторы'
                  : 'Структурные Ферменты'}
                {!!buffer.ue && ' и Уникальные Ферменты'}
              </LabeledList.Item>
              <LabeledList.Item label="Передача данных">
                <Button
                  disabled={!isInjectorReady}
                  icon={isInjectorReady ? 'syringe' : 'spinner'}
                  iconSpin={!isInjectorReady}
                  mb="0"
                  onClick={() =>
                    act('bufferOption', {
                      option: 'createInjector',
                      id: id,
                    })
                  }
                >
                  Инъектор
                </Button>
                <Button
                  disabled={!isInjectorReady}
                  icon={isInjectorReady ? 'syringe' : 'spinner'}
                  iconSpin={!isInjectorReady}
                  mb="0"
                  onClick={() =>
                    act('bufferOption', {
                      option: 'createInjector',
                      id: id,
                      block: 1,
                    })
                  }
                >
                  Инъектор блока
                </Button>
                <Button
                  icon="user"
                  mb="0"
                  onClick={() =>
                    act('bufferOption', {
                      option: 'transfer',
                      id: id,
                    })
                  }
                >
                  Субъект
                </Button>
              </LabeledList.Item>
            </>
          )}
        </LabeledList>
        {!buffer.data && (
          <Box color="label" mt="0.5rem">
            Буфер данных пуст.
          </Box>
        )}
      </Section>
    </Box>
  );
};

const DNAModifierMainBuffersDisk = (props: unknown) => {
  const { act, data } = useBackend<DNAModifierData>();
  const { hasDisk, disk } = data;
  return (
    <Section
      title="Дискета"
      buttons={
        <>
          <Button.Confirm
            disabled={!hasDisk || !disk.data}
            icon="trash"
            onClick={() => act('wipeDisk')}
          >
            Очистить
          </Button.Confirm>
          <Button
            disabled={!hasDisk}
            icon="eject"
            onClick={() => act('ejectDisk')}
          >
            Извлечь
          </Button>
        </>
      }
    >
      {hasDisk ? (
        disk.data ? (
          <LabeledList>
            <LabeledList.Item label="Этикетка">
              {disk.label ? disk.label : 'Отсутствует'}
            </LabeledList.Item>
            <LabeledList.Item label="Субъект">
              {disk.owner ? disk.owner : <Box color="average">Неизвестно</Box>}
            </LabeledList.Item>
            <LabeledList.Item label="Тип данных">
              {disk.type === 'ui'
                ? 'Уникальные Идентификаторы'
                : 'Структурные Ферменты'}
              {!!disk.ue && ' и Уникальные Ферменты'}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          <Box color="label">Данные отсутствуют.</Box>
        )
      ) : (
        <Box color="label" textAlign="center" my="1rem">
          <Icon name="save-o" size={4} />
          <br />
          Дискета не вставлена.
        </Box>
      )}
    </Section>
  );
};

type DNAModifierBeakerData = {
  isBeakerLoaded: boolean;
  beakerVolume: number;
  beakerLabel: string;
};

const DNAModifierMainRejuvenators = (props: unknown) => {
  const { act, data } = useBackend<DNAModifierBeakerData>();
  const { isBeakerLoaded, beakerVolume, beakerLabel } = data;
  return (
    <Section
      fill
      title="Химикаты и ёмкости"
      buttons={
        <Button
          disabled={!isBeakerLoaded}
          icon="eject"
          onClick={() => act('ejectBeaker')}
        >
          Извлечь ёмкость
        </Button>
      }
    >
      {isBeakerLoaded ? (
        <LabeledList>
          <LabeledList.Item label="Ввести химикаты">
            {rejuvenatorsDoses.map((a, i) => (
              <Button
                key={i}
                disabled={a > beakerVolume}
                icon="syringe"
                onClick={() =>
                  act('injectRejuvenators', {
                    amount: a,
                  })
                }
              >
                {a}
              </Button>
            ))}
            <Button
              disabled={beakerVolume <= 0}
              icon="syringe"
              onClick={() =>
                act('injectRejuvenators', {
                  amount: beakerVolume,
                })
              }
            >
              Все
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Ёмкость">
            <Box mb="0.5rem">
              {beakerLabel ? beakerLabel : 'Этикетка отсутствует'}
            </Box>
            {beakerVolume ? (
              <Box color="good">Осталось: {beakerVolume}u</Box>
            ) : (
              <Box color="bad">Пусто</Box>
            )}
          </LabeledList.Item>
        </LabeledList>
      ) : (
        <Stack fill>
          <Stack.Item bold grow textAlign="center" align="center" color="label">
            <Icon.Stack style={{ transform: 'translate(-30px, -50px)' }}>
              <Icon name="flask" size={5} color="silver" />
              <Icon
                name="slash"
                size={5}
                color="red"
                style={{ transform: 'translate(-10px, 0)' }}
              />
            </Icon.Stack>
            <br />
            <h3>Ёмкость не вставлена.</h3>
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

const DNAModifierIrradiating = (props) => {
  return (
    <Dimmer textAlign="center">
      <Icon name="spinner" size={5} spin />
      <br />
      <Box color="average">
        <h1>
          <Icon name="radiation" />
          &nbsp;Облучение субъекта&nbsp;
          <Icon name="radiation" />
        </h1>
      </Box>
      <Box color="label">
        <h3>
          В течении {props.duration} секунд
          {props.duration % 10 === 1 && !(props.duration % 100 === 11)
            ? 'ы'
            : ''}
        </h3>
      </Box>
    </Dimmer>
  );
};

type DNAModifierBlocksProps = {
  dnaString: string;
  selectedBlock: number;
  selectedSubblock: number;
  blockSize: number;
  action: string;
};

const DNAModifierBlocks = (props: DNAModifierBlocksProps) => {
  const { act } = useBackend();
  const { dnaString, selectedBlock, selectedSubblock, blockSize, action } =
    props;

  const characters = dnaString.split('');
  let dnaBlocks = [];
  for (let block = 0; block < characters.length; block += blockSize) {
    const realBlock = block / blockSize + 1;
    let subBlocks = [];
    for (let subblock = 0; subblock < blockSize; subblock++) {
      const realSubblock = subblock + 1;
      subBlocks.push(
        <Button
          selected={
            selectedBlock === realBlock && selectedSubblock === realSubblock
          }
          mb="0"
          onClick={() =>
            act(action, {
              block: realBlock,
              subblock: realSubblock,
            })
          }
        >
          {characters[block + subblock]}
        </Button>
      );
    }
    dnaBlocks.push(
      <Stack.Item mb="1rem" mr="1rem" width={7.8} textAlign="right">
        <Box inline mr="0.5rem" fontFamily="monospace">
          {realBlock}
        </Box>
        {subBlocks}
      </Stack.Item>
    );
  }
  return <Flex wrap="wrap">{dnaBlocks}</Flex>;
};
