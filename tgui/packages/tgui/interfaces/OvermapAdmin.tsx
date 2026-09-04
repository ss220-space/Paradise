import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Dropdown,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Sector = {
  id: string;
  name: string;
  size: number;
};

type SpawnType = {
  path: string;
  name: string;
  group: string;
};

type Template = {
  id: string;
  name: string;
  width: number;
  height: number;
  kind: string;
};

type Token = {
  uid: string;
  name: string;
  type: string;
  kind: string;
  icon: string;
  icon_state: string;
  sector_id?: string;
  sector_name?: string;
  x?: number;
  y?: number;
  docked: BooleanLike;
  nested_in?: string;
  pos_x?: number;
  pos_y?: number;
  speed_x?: number;
  speed_y?: number;
  movable?: BooleanLike;
  halted?: BooleanLike;
  immune?: BooleanLike;
  visible?: BooleanLike;
  hidden?: BooleanLike;
  wraparound?: BooleanLike;
  is_entity?: BooleanLike;
  status?: string;
  sensors_on?: BooleanLike;
  has_flight?: BooleanLike;
};

type Console = {
  uid: string;
  name: string;
};

type IffChannel = {
  id: string;
  label: string;
  permanent: BooleanLike;
  receive: BooleanLike;
  transmit: BooleanLike;
};

type Transponder = {
  uid: string;
  name: string;
  vessel?: string;
  broadcast_name?: string;
  broadcasting: BooleanLike;
  distress: BooleanLike;
  channels: IffChannel[] | Record<string, IffChannel>;
};

type CommsMessage = {
  id: string;
  sender: string;
  key?: string;
  text: string;
  scrambled?: string;
};

type CommsSector = {
  id: string;
  name: string;
  messages: CommsMessage[] | Record<string, CommsMessage>;
};

type Data = {
  picking: BooleanLike;
  pick_for_dump: BooleanLike;
  filter_name: string;
  filter_sector: string;
  filter_x?: number | null;
  filter_y?: number | null;
  filter_docked: BooleanLike;
  candidates?: Token[] | Record<string, Token>;
  selected?: Token | null;
  dump_list: Token[] | Record<string, Token>;
  consoles: Console[] | Record<string, Console>;
  sectors: Sector[] | Record<string, Sector>;
  icons: string[] | Record<string, string>;
  icon_file: string;
  spawn_types: SpawnType[] | Record<string, SpawnType>;
  templates: Template[] | Record<string, Template>;
  uploaded_dmm?: string;
  uploaded_w?: number;
  uploaded_h?: number;
  pool_medium?: number;
  pool_large?: number;
  suggest_x?: number;
  suggest_y?: number;
  suggest_sector?: string;
  iff_centcom?: string;
  iff_syndicate?: string;
  transponders?: Transponder[] | Record<string, Transponder>;
  comms?: CommsSector[] | Record<string, CommsSector>;
};

const TAB_CONTROL = 0;
const TAB_SPAWN = 1;
const TAB_DUMP = 2;
const TAB_IFF = 3;
const TAB_COMMS = 4;

const asList = <T,>(value: T[] | Record<string, T> | null | undefined): T[] => {
  if (Array.isArray(value)) {
    return value;
  }
  if (value && typeof value === 'object') {
    return Object.values(value);
  }
  return [];
};

const dropdownOptions = (values: string[]) =>
  values.map((value) => ({
    value,
    displayText: value,
  }));

const sendFilter = (
  act: (action: string, params?: Record<string, unknown>) => void,
  data: Data,
  patch: Partial<{
    name: string;
    sector: string;
    x: string | number | null;
    y: string | number | null;
    docked: boolean;
  }>,
) => {
  act('set_filter', {
    name: patch.name ?? data.filter_name ?? '',
    sector: patch.sector ?? data.filter_sector ?? '',
    x: patch.x === undefined ? (data.filter_x ?? '') : (patch.x ?? ''),
    y: patch.y === undefined ? (data.filter_y ?? '') : (patch.y ?? ''),
    docked: patch.docked ?? !!data.filter_docked,
  });
};

const Picker = () => {
  const { act, data } = useBackend<Data>();
  const candidates = asList(data.candidates);
  const sectors = asList(data.sectors);
  return (
    <Section
      title={data.pick_for_dump ? 'Выбор для дампа' : 'Выбор объекта'}
      buttons={
        <Button icon="times" onClick={() => act('pick_cancel')}>
          Закрыть
        </Button>
      }
    >
      <Stack vertical>
        <Stack.Item>
          <Input
            fluid
            placeholder="Название или тип"
            value={data.filter_name}
            onChange={(value) => sendFilter(act, data, { name: value })}
          />
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item grow>
              <Dropdown
                width="100%"
                options={[
                  { value: '', displayText: 'Любой сектор' },
                  ...sectors.map((sector) => ({
                    value: sector.id,
                    displayText: `${sector.name} (${sector.id})`,
                  })),
                ]}
                selected={data.filter_sector || ''}
                onSelected={(value) => sendFilter(act, data, { sector: value })}
              />
            </Stack.Item>
            <Stack.Item>
              <NumberInput
                width="56px"
                minValue={0}
                maxValue={99}
                step={1}
                value={data.filter_x || 0}
                onChange={(value) => sendFilter(act, data, { x: value || '' })}
              />
            </Stack.Item>
            <Stack.Item>
              <NumberInput
                width="56px"
                minValue={0}
                maxValue={99}
                step={1}
                value={data.filter_y || 0}
                onChange={(value) => sendFilter(act, data, { y: value || '' })}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                selected={!!data.filter_docked}
                onClick={() =>
                  sendFilter(act, data, { docked: !data.filter_docked })
                }
              >
                В доке
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          {candidates.map((token) => (
            <Box key={token.uid} mb={0.5}>
              <Button
                fluid
                onClick={() => act('pick_token', { uid: token.uid })}
              >
                {token.name} [{token.kind}] {token.sector_id || '—'} {token.x}:
                {token.y}
                {token.docked ? ' (в доке)' : ''}
                {token.nested_in ? ` @ ${token.nested_in}` : ''}
              </Button>
            </Box>
          ))}
          {!candidates.length && <Box color="average">Ничего не найдено.</Box>}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const FlagButton = (props: {
  uid: string;
  field: string;
  value: BooleanLike | undefined;
  label: string;
}) => {
  const { act } = useBackend<Data>();
  return (
    <Button
      selected={!!props.value}
      onClick={() =>
        act('set_field', {
          uid: props.uid,
          field: props.field,
          value: !props.value,
        })
      }
    >
      {props.label}
    </Button>
  );
};

const ControlTab = () => {
  const { act, data } = useBackend<Data>();
  const selected = data.selected;
  const sectors = asList(data.sectors);
  const icons = asList(data.icons);
  const [teleX, setTeleX] = useState(selected?.x || 1);
  const [teleY, setTeleY] = useState(selected?.y || 1);
  const [teleSector, setTeleSector] = useState(selected?.sector_id || '');
  if (data.picking) {
    return <Picker />;
  }
  return (
    <Section
      title="Управление объектами"
      buttons={
        <Button icon="search" onClick={() => act('pick_start')}>
          Выбрать объект
        </Button>
      }
    >
      {!selected && <Box color="average">Объект не выбран.</Box>}
      {!!selected && (
        <Stack vertical>
          <Stack.Item>
            <Stack>
              <Stack.Item>
                <DmIcon
                  icon={selected.icon || data.icon_file}
                  icon_state={selected.icon_state}
                  style={{ width: '64px', height: '64px' }}
                />
              </Stack.Item>
              <Stack.Item grow>
                <LabeledList>
                  <LabeledList.Item label="Имя">
                    <Input
                      fluid
                      value={selected.name}
                      onChange={(value) =>
                        act('set_field', {
                          uid: selected.uid,
                          field: 'name',
                          value,
                        })
                      }
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Тип">
                    {selected.type}
                  </LabeledList.Item>
                  <LabeledList.Item label="Положение">
                    {selected.sector_name || selected.sector_id || '—'}{' '}
                    {selected.x}:{selected.y}
                    {selected.docked ? ' (в доке)' : ''}
                  </LabeledList.Item>
                  <LabeledList.Item label="Иконка">
                    <Dropdown
                      width="100%"
                      options={dropdownOptions(icons)}
                      selected={selected.icon_state || ''}
                      onSelected={(value) =>
                        act('set_field', {
                          uid: selected.uid,
                          field: 'icon_state',
                          value,
                        })
                      }
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <LabeledList>
              <LabeledList.Item label="Микрокоординаты">
                <NumberInput
                  width="70px"
                  minValue={-0.49}
                  maxValue={0.49}
                  step={0.01}
                  value={selected.pos_x || 0}
                  onChange={(value) =>
                    act('set_field', {
                      uid: selected.uid,
                      field: 'pos_x',
                      value,
                    })
                  }
                />
                <NumberInput
                  width="70px"
                  minValue={-0.49}
                  maxValue={0.49}
                  step={0.01}
                  value={selected.pos_y || 0}
                  onChange={(value) =>
                    act('set_field', {
                      uid: selected.uid,
                      field: 'pos_y',
                      value,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Скорость">
                <NumberInput
                  width="70px"
                  minValue={-1}
                  maxValue={1}
                  step={0.001}
                  value={selected.speed_x || 0}
                  onChange={(value) =>
                    act('set_field', {
                      uid: selected.uid,
                      field: 'speed_x',
                      value,
                    })
                  }
                />
                <NumberInput
                  width="70px"
                  minValue={-1}
                  maxValue={1}
                  step={0.001}
                  value={selected.speed_y || 0}
                  onChange={(value) =>
                    act('set_field', {
                      uid: selected.uid,
                      field: 'speed_y',
                      value,
                    })
                  }
                />
              </LabeledList.Item>
              <LabeledList.Item label="Телепорт">
                <Dropdown
                  width="180px"
                  options={sectors.map((sector) => ({
                    value: sector.id,
                    displayText: `${sector.name} (${sector.id})`,
                  }))}
                  selected={teleSector || selected.sector_id || ''}
                  onSelected={setTeleSector}
                />
                <NumberInput
                  width="50px"
                  minValue={1}
                  maxValue={99}
                  step={1}
                  value={teleX}
                  onChange={setTeleX}
                />
                <NumberInput
                  width="50px"
                  minValue={1}
                  maxValue={99}
                  step={1}
                  value={teleY}
                  onChange={setTeleY}
                />
                <Button
                  icon="location-arrow"
                  onClick={() =>
                    act('teleport', {
                      uid: selected.uid,
                      sector: teleSector || selected.sector_id,
                      x: teleX,
                      y: teleY,
                    })
                  }
                >
                  Переместить
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Флаги">
                <FlagButton
                  uid={selected.uid}
                  field="movable"
                  value={selected.movable}
                  label="Движение"
                />
                <FlagButton
                  uid={selected.uid}
                  field="halted"
                  value={selected.halted}
                  label="Стоп"
                />
                <FlagButton
                  uid={selected.uid}
                  field="immune"
                  value={selected.immune}
                  label="Иммунитет"
                />
                <FlagButton
                  uid={selected.uid}
                  field="visible"
                  value={selected.visible}
                  label="Видим без сканера"
                />
                <FlagButton
                  uid={selected.uid}
                  field="hidden"
                  value={selected.hidden}
                  label="Скрыт"
                />
                <FlagButton
                  uid={selected.uid}
                  field="wraparound"
                  value={selected.wraparound}
                  label="Wrap"
                />
              </LabeledList.Item>
            </LabeledList>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="eye"
              onClick={() => act('sensors', { uid: selected.uid })}
            >
              Сенсоры
            </Button>
            <Button
              icon="rocket"
              onClick={() =>
                act('set_field', {
                  uid: selected.uid,
                  field: 'flight',
                  value: 1,
                })
              }
            >
              Полёт
            </Button>
            <Button
              icon="compass"
              onClick={() => act('helm', { uid: selected.uid })}
            >
              Helm
            </Button>
            <Button
              icon="street-view"
              onClick={() => act('jump_self', { uid: selected.uid })}
            >
              Телепортироваться
            </Button>
            <Button
              icon="code"
              onClick={() => act('vv', { uid: selected.uid })}
            >
              VV
            </Button>
            <Button
              icon="trash"
              color="bad"
              onClick={() => act('delete', { uid: selected.uid })}
            >
              Удалить
            </Button>
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

const SpawnTab = () => {
  const { act, data } = useBackend<Data>();
  const sectors = asList(data.sectors);
  const spawnTypes = asList(data.spawn_types);
  const templates = asList(data.templates);
  const icons = asList(data.icons);
  const [kind, setKind] = useState('token');
  const [sectorId, setSectorId] = useState(
    data.suggest_sector || sectors[0]?.id || '',
  );
  const [coordX, setCoordX] = useState(data.suggest_x || 1);
  const [coordY, setCoordY] = useState(data.suggest_y || 1);
  const [spawnType, setSpawnType] = useState('/obj/overmap/feature');
  const [templateId, setTemplateId] = useState('');
  const [templateKind, setTemplateKind] = useState('map');
  const [templateSearch, setTemplateSearch] = useState('');
  const [useUpload, setUseUpload] = useState(false);
  const [large, setLarge] = useState(false);
  const [spawnName, setSpawnName] = useState('');
  const [iconState, setIconState] = useState('object');
  const [movable, setMovable] = useState(false);
  const [immune, setImmune] = useState(false);
  const [visible, setVisible] = useState(false);
  const [hidden, setHidden] = useState(false);
  const [destSector, setDestSector] = useState(sectors[0]?.id || '');
  const [destX, setDestX] = useState(1);
  const [destY, setDestY] = useState(1);
  const tokenTypes = spawnTypes.filter((entry) => entry.group !== 'ruin');
  const filteredTemplates = templates.filter((template) => {
    if (kind === 'shuttle' && template.kind !== 'shuttle') {
      return false;
    }
    if (kind === 'ruin' && template.kind === 'shuttle') {
      return false;
    }
    if (!templateSearch) {
      return true;
    }
    const needle = templateSearch.toLowerCase();
    return (
      template.name.toLowerCase().includes(needle) ||
      template.id.toLowerCase().includes(needle)
    );
  });
  const selectedType =
    tokenTypes.find((entry) => entry.path === spawnType) || tokenTypes[0];
  return (
    <Section
      title="Спавн объектов"
      buttons={
        <Box>
          пул: {data.pool_medium || 0} средних / {data.pool_large || 0} больших
        </Box>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Тип">
          <Button selected={kind === 'token'} onClick={() => setKind('token')}>
            Точка / объект
          </Button>
          <Button
            selected={kind === 'hazard'}
            onClick={() => {
              setKind('hazard');
              setSpawnType('/obj/overmap/feature/hazard');
            }}
          >
            Угроза
          </Button>
          <Button
            selected={kind === 'portal'}
            onClick={() => {
              setKind('portal');
              setSpawnType('/obj/overmap/portal');
            }}
          >
            Портал
          </Button>
          <Button selected={kind === 'ruin'} onClick={() => setKind('ruin')}>
            Руина
          </Button>
          <Button
            selected={kind === 'shuttle'}
            onClick={() => setKind('shuttle')}
          >
            Шаттл
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Сектор">
          <Dropdown
            width="100%"
            options={sectors.map((sector) => ({
              value: sector.id,
              displayText: `${sector.name} (${sector.id}, ${sector.size}x${sector.size})`,
            }))}
            selected={sectorId}
            onSelected={setSectorId}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Клетка">
          <NumberInput
            width="56px"
            minValue={1}
            maxValue={99}
            step={1}
            value={coordX}
            onChange={setCoordX}
          />
          <NumberInput
            width="56px"
            minValue={1}
            maxValue={99}
            step={1}
            value={coordY}
            onChange={setCoordY}
          />
          <Button
            onClick={() => {
              setCoordX(data.suggest_x || coordX);
              setCoordY(data.suggest_y || coordY);
            }}
          >
            Ближайшая свободная
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Имя">
          <Input fluid value={spawnName} onChange={setSpawnName} />
        </LabeledList.Item>
        <LabeledList.Item label="Иконка">
          <Dropdown
            width="100%"
            options={dropdownOptions(icons)}
            selected={iconState}
            onSelected={setIconState}
          />
        </LabeledList.Item>
        {(kind === 'token' || kind === 'hazard' || kind === 'portal') && (
          <LabeledList.Item label="Путь">
            <Dropdown
              width="100%"
              options={tokenTypes
                .filter(
                  (entry) => kind === 'token' || entry.group === kind,
                )
                .map((entry) => ({
                  value: entry.path,
                  displayText: `${entry.name} (${entry.path})`,
                }))}
              selected={selectedType?.path || spawnType}
              onSelected={setSpawnType}
            />
          </LabeledList.Item>
        )}
        {kind === 'portal' && (
          <LabeledList.Item label="Выход портала">
            <Dropdown
              width="180px"
              options={sectors.map((sector) => ({
                value: sector.id,
                displayText: sector.name,
              }))}
              selected={destSector}
              onSelected={setDestSector}
            />
            <NumberInput
              width="50px"
              minValue={1}
              maxValue={99}
              step={1}
              value={destX}
              onChange={setDestX}
            />
            <NumberInput
              width="50px"
              minValue={1}
              maxValue={99}
              step={1}
              value={destY}
              onChange={setDestY}
            />
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Флаги">
          <Button selected={movable} onClick={() => setMovable(!movable)}>
            Движение
          </Button>
          <Button selected={immune} onClick={() => setImmune(!immune)}>
            Иммунитет
          </Button>
          <Button selected={visible} onClick={() => setVisible(!visible)}>
            Видим без сканера
          </Button>
          <Button selected={hidden} onClick={() => setHidden(!hidden)}>
            Скрыт
          </Button>
        </LabeledList.Item>
        {(kind === 'ruin' || kind === 'shuttle') && (
          <>
            <LabeledList.Item label="Размер уровня">
              <Button selected={!large} onClick={() => setLarge(false)}>
                Средний
              </Button>
              <Button selected={large} onClick={() => setLarge(true)}>
                Большой
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="DMM">
              <Button
                selected={!useUpload}
                onClick={() => setUseUpload(false)}
              >
                Из шаблонов
              </Button>
              <Button selected={useUpload} onClick={() => setUseUpload(true)}>
                С игрока
              </Button>
              {useUpload ? (
                <Box mt={0.5}>
                  <Button icon="upload" onClick={() => act('upload_dmm')}>
                    Загрузить .dmm
                  </Button>
                  <Box>
                    {data.uploaded_dmm
                      ? `${data.uploaded_dmm} (${data.uploaded_w}x${data.uploaded_h})`
                      : 'Файл не выбран'}
                  </Box>
                </Box>
              ) : (
                <Box mt={0.5}>
                  <Input
                    fluid
                    placeholder="Поиск шаблона"
                    value={templateSearch}
                    onChange={setTemplateSearch}
                  />
                  <Box mt={0.5}>
                    <Dropdown
                      width="100%"
                      options={[
                        { value: '', displayText: 'Пустой (без карты)' },
                        ...filteredTemplates.slice(0, 200).map((template) => ({
                          value: `${template.kind}:${template.id}`,
                          displayText: `${template.name} [${template.width}x${template.height}]`,
                        })),
                      ]}
                      selected={
                        templateId ? `${templateKind}:${templateId}` : ''
                      }
                      onSelected={(value) => {
                        if (!value) {
                          setTemplateId('');
                          return;
                        }
                        const split = value.indexOf(':');
                        setTemplateKind(value.slice(0, split));
                        setTemplateId(value.slice(split + 1));
                      }}
                    />
                  </Box>
                </Box>
              )}
            </LabeledList.Item>
          </>
        )}
      </LabeledList>
      <Box mt={1}>
        <Button
          icon="plus"
          color="good"
          onClick={() =>
            act('spawn', {
              kind,
              sector: sectorId,
              x: coordX,
              y: coordY,
              spawn_type: spawnType,
              template_id: templateId,
              template_kind: useUpload ? 'upload' : templateKind,
              large,
              name: spawnName,
              icon_state: iconState,
              movable,
              immune,
              visible,
              hidden,
              dest_sector: destSector,
              dest_x: destX,
              dest_y: destY,
            })
          }
        >
          Заспавнить
        </Button>
      </Box>
    </Section>
  );
};

const TransponderTab = () => {
  const { act, data } = useBackend<Data>();
  const transponders = asList(data.transponders);
  const [newKey, setNewKey] = useState('');
  return (
    <Section title="Транспондеры">
      <Box mb={1}>
        ЦК: <b>{data.iff_centcom || '—'}</b>
        {' | '}
        Синдикат: <b>{data.iff_syndicate || '—'}</b>
      </Box>
      {transponders.map((beacon) => (
        <Section
          key={beacon.uid}
          title={`${beacon.broadcast_name || beacon.name} (${beacon.vessel || 'нет судна'})`}
          buttons={
            <Button
              selected={!!beacon.broadcasting}
              onClick={() => act('iff_broadcast', { uid: beacon.uid })}
            >
              Эфир
            </Button>
          }
        >
          {asList(beacon.channels).map((channel) => (
            <Box key={channel.id} mb={0.4}>
              {channel.label} [{channel.id}]{' '}
              <Button
                selected={!!channel.receive}
                onClick={() =>
                  act('iff_toggle', {
                    uid: beacon.uid,
                    id: channel.id,
                    flag: 'receive',
                  })
                }
              >
                RX
              </Button>
              <Button
                selected={!!channel.transmit}
                onClick={() =>
                  act('iff_toggle', {
                    uid: beacon.uid,
                    id: channel.id,
                    flag: 'transmit',
                  })
                }
              >
                TX
              </Button>
              {!channel.permanent && (
                <Button
                  color="bad"
                  onClick={() =>
                    act('iff_remove', { uid: beacon.uid, id: channel.id })
                  }
                >
                  Удалить
                </Button>
              )}
            </Box>
          ))}
          <Input
            placeholder="Ключ или id канала"
            value={newKey}
            onChange={setNewKey}
          />
          <Button
            onClick={() => {
              act('iff_add', { uid: beacon.uid, key: newKey });
              setNewKey('');
            }}
          >
            Добавить канал
          </Button>
        </Section>
      ))}
    </Section>
  );
};

const CommsTab = () => {
  const { act, data } = useBackend<Data>();
  const sectors = asList(data.comms);
  const [sectorId, setSectorId] = useState(sectors[0]?.id || '');
  const [body, setBody] = useState('');
  const [key, setKey] = useState('');
  const [sender, setSender] = useState('Админ');
  const current = sectors.find((sector) => sector.id === sectorId) || sectors[0];
  return (
    <Section title="Межсекторная связь">
      <LabeledList>
        <LabeledList.Item label="Сектор">
          <Dropdown
            width="100%"
            options={sectors.map((sector) => ({
              value: sector.id,
              displayText: sector.name,
            }))}
            selected={current?.id || ''}
            onSelected={setSectorId}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Отправитель">
          <Input value={sender} onChange={setSender} />
        </LabeledList.Item>
        <LabeledList.Item label="Ключ">
          <Input value={key} onChange={setKey} />
        </LabeledList.Item>
        <LabeledList.Item label="Текст">
          <Input fluid value={body} onChange={setBody} />
        </LabeledList.Item>
      </LabeledList>
      <Box mt={1} mb={1}>
        <Button
          icon="paper-plane"
          onClick={() =>
            act('comms_send', {
              sector: current?.id,
              text: body,
              key,
              sender,
            })
          }
        >
          Отправить
        </Button>
        <Button
          color="bad"
          onClick={() => act('comms_clear', { sector: current?.id })}
        >
          Очистить сектор
        </Button>
      </Box>
      {asList(current?.messages).map((message) => (
        <Box key={message.id} mb={0.6}>
          <Button
            color="bad"
            icon="times"
            onClick={() =>
              act('comms_delete', { sector: current?.id, id: message.id })
            }
          />{' '}
          <b>{message.sender}</b>
          {message.key ? ` [${message.key}]` : ' [открыто]'}: {message.text}
        </Box>
      ))}
    </Section>
  );
};

const DumpTab = () => {
  const { act, data } = useBackend<Data>();
  if (data.picking) {
    return <Picker />;
  }
  const dumpList = asList(data.dump_list);
  const consoles = asList(data.consoles);
  return (
    <Section
      title="Дамп секторов"
      buttons={
        <Button icon="search" onClick={() => act('pick_dump_start')}>
          Добавить объект
        </Button>
      }
    >
      {dumpList.map((token) => (
        <Box key={token.uid} mb={0.5}>
          <Button
            icon="times"
            color="bad"
            onClick={() => act('dump_remove', { uid: token.uid })}
          />{' '}
          {token.name} {token.sector_id} {token.x}:{token.y}
        </Box>
      ))}
      {!dumpList.length && (
        <Box color="average" mb={1}>
          Список пуст.
        </Box>
      )}
      <Box mt={1}>
        <Button icon="file" onClick={() => act('dump_paper')}>
          Дамп-листок
        </Button>
        <Button icon="hand-pointer" onClick={() => act('dump_click')}>
          Клик по консоли
        </Button>
        <Button icon="trash" onClick={() => act('dump_clear')}>
          Очистить
        </Button>
      </Box>
      <Box mt={1}>
        {consoles.map((console) => (
          <Box key={console.uid} mb={0.4}>
            <Button
              fluid
              icon="upload"
              onClick={() => act('dump_console', { uid: console.uid })}
            >
              {console.name}
            </Button>
          </Box>
        ))}
      </Box>
    </Section>
  );
};

export const OvermapAdmin = () => {
  const [tab, setTab] = useState(TAB_CONTROL);
  return (
    <Window title="Овермап" width={760} height={820}>
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={tab === TAB_CONTROL}
            onClick={() => setTab(TAB_CONTROL)}
          >
            Управление объектами
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === TAB_SPAWN}
            onClick={() => setTab(TAB_SPAWN)}
          >
            Спавн объектов
          </Tabs.Tab>
          <Tabs.Tab selected={tab === TAB_DUMP} onClick={() => setTab(TAB_DUMP)}>
            Дамп секторов
          </Tabs.Tab>
          <Tabs.Tab selected={tab === TAB_IFF} onClick={() => setTab(TAB_IFF)}>
            Транспондеры
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === TAB_COMMS}
            onClick={() => setTab(TAB_COMMS)}
          >
            Связь
          </Tabs.Tab>
        </Tabs>
        {tab === TAB_CONTROL && <ControlTab />}
        {tab === TAB_SPAWN && <SpawnTab />}
        {tab === TAB_DUMP && <DumpTab />}
        {tab === TAB_IFF && <TransponderTab />}
        {tab === TAB_COMMS && <CommsTab />}
      </Window.Content>
    </Window>
  );
};
