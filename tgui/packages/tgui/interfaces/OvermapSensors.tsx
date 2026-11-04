import {
  Box,
  Button,
  Input,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend, useLocalState } from '../backend';
import {
  OvermapCoord,
  OvermapFrame,
  OvermapList,
  OvermapRail,
  OvermapRow,
  OvermapSeg,
  OvermapStat,
  OvermapStats,
  overmapKindLabel,
} from './overmap/OvermapChrome';
import {
  type GalaxyMap,
  type HazardField,
  OvermapRadar,
  type RadarContact,
  type RadarEngine,
  type RadarObject,
  type RadarPeel,
  type RadarProjectile,
  type RadarScatterChunk,
  type RadarShape,
  type RadarTerrain,
} from './overmap/OvermapRadar';
import { RadarViewport } from './overmap/RadarViewport';

type SensorContact = {
  ref: string;
  name: string;
  kind: string;
  x: number;
  y: number;
  is_self: BooleanLike;
  stealth: BooleanLike;
  speed?: number;
  heading?: number;
  nested?: BooleanLike;
  distress?: BooleanLike;
  can_scan?: BooleanLike;
};

type JournalEntry = {
  time: string;
  text: string;
  kind?: string;
  x?: number;
  y?: number;
  name?: string;
  tone?: string;
  note?: string;
};

type ScanInfo = {
  name: string;
  kind: string;
  mass: number;
  living: number;
  engines: number;
  engines_ready: number;
  speed: number;
  heading: number;
  transponder: BooleanLike;
  size_x: number;
  size_y: number;
  has_hull?: BooleanLike;
};

type OvermapSensorsData = {
  radar_shapes?: Record<string, RadarShape>;
  radar?: RadarContact[];
  radar_drifters?: number[][];
  radar_projectiles?: RadarProjectile[];
  radar_engines?: RadarEngine[];
  radar_terrain?: RadarTerrain;
  radar_world?: number[];
  objects?: RadarObject[];
  self_pos?: number[];
  sector_size?: number;
  cell_span?: number;
  sector_id?: string;
  galaxy?: GalaxyMap;
  facing?: number;
  hazard_fields?: HazardField[];
  scan_radar?: BooleanLike;
  radar_peels?: RadarPeel[];
  radar_scatter?: RadarScatterChunk[];
  linked: BooleanLike;
  view_mode: string;
  has_long: BooleanLike;
  has_short: BooleanLike;
  long_range: BooleanLike;
  active: BooleanLike;
  scanning: BooleanLike;
  scan_error?: string;
  scan?: ScanInfo;
  scan_done?: BooleanLike;
  can_print?: BooleanLike;
  can_dump?: BooleanLike;
  dump_loaded?: BooleanLike;
  dump_name?: string;
  dump_has_data?: BooleanLike;
  dump_count?: number;
  known_count?: number;
  scan_progress?: number;
  selected?: string;
  journal: JournalEntry[];
  contacts: SensorContact[];
  vessel_name: string;
  x: number;
  y: number;
  sector_name: string;
  alerts?: { id: string; label: string; on: BooleanLike }[];
  map_jammed?: BooleanLike;
  radar_locked?: BooleanLike;
  radar_tick?: number;
  radar_epoch?: number;
};

export const OvermapSensors = () => {
  const { act, data } = useBackend<OvermapSensorsData>();
  const [tab, setTab] = useLocalState<'map' | 'log'>('sensorPane', 'map');
  const [radius, setRadius] = useLocalState('sensorRadarRadius', 1500);
  const [follow, setFollow] = useLocalState('sensorRadarFollow', false);
  const [band, setBand] = useLocalState('sensorRadarBand', 'sector');
  const [query, setQuery] = useLocalState('sensorJournalQuery', '');
  const {
    linked,
    view_mode,
    has_long,
    has_short,
    long_range,
    active,
    scanning,
    scan_error,
    scan,
    scan_done,
    can_print,
    can_dump,
    dump_loaded,
    dump_name,
    dump_has_data,
    dump_count = 0,
    known_count = 0,
    scan_progress = 0,
    selected,
    journal = [],
    contacts = [],
    vessel_name,
    x,
    y,
    sector_name,
    alerts = [],
    map_jammed,
  } = data;

  const needle = query.trim().toLowerCase();
  const filteredJournal = needle
    ? journal.filter((entry) =>
        `${entry.text} ${entry.name || ''} ${entry.kind || ''} ${entry.note || ''}`
          .toLowerCase()
          .includes(needle),
      )
    : journal;

  return (
    <OvermapFrame
      title="Sensors"
      width={1180}
      height={820}
      linked={linked}
      onRelink={() => act('relink')}
      rail={
        <OvermapRail
          name={vessel_name || 'Sensors'}
          sector={sector_name}
          xy={linked ? `${x}:${y}` : undefined}
          lamps={[
            { label: long_range ? 'дальний' : 'ближний', on: !!linked },
            { label: 'сканер', on: !!active },
            { label: 'скан', on: !!scanning },
          ]}
        />
      }
      modes={
        linked ? (
          <>
            <OvermapSeg
              value={tab}
              onChange={setTab}
              items={[
                { id: 'map', label: 'Карта' },
                { id: 'log', label: `Журнал ${journal.length}` },
              ]}
            />
            <div className="OvermapAlerts">
              {alerts.map((alert) => (
                <Button
                  key={alert.id}
                  selected={!!alert.on}
                  color={
                    alert.id === 'distress' && alert.on ? 'bad' : undefined
                  }
                  onClick={() => act('toggle_alert', { id: alert.id })}
                >
                  {alert.label}
                </Button>
              ))}
            </div>
          </>
        ) : null
      }
      actions={
        linked && tab === 'map' ? (
          <>
            {!!has_long && (
              <Button
                selected={view_mode === 'long'}
                onClick={() => act('set_mode', { mode: 'long' })}
              >
                Дальний
              </Button>
            )}
            {!!has_short && (
              <Button
                selected={view_mode === 'short'}
                onClick={() => act('set_mode', { mode: 'short' })}
              >
                Ближний
              </Button>
            )}
            <Button
              icon="power-off"
              selected={!!active}
              disabled={view_mode === 'long' ? !has_long : !has_short}
              onClick={() => act('toggle')}
            >
              {active ? 'Сканер вкл' : 'Сканер выкл'}
            </Button>
            {!!scanning && (
              <Button onClick={() => act('close_scan')}>К карте</Button>
            )}
          </>
        ) : null
      }
    >
      {tab === 'log' ? (
        <Stack fill vertical>
          <Stack.Item grow minHeight={0}>
            <Section fill scrollable>
              <OvermapList>
                {filteredJournal.map((entry, index) => (
                  <OvermapRow
                    key={index}
                    tag={entry.time}
                    title={
                      <>
                        {entry.text}
                        {entry.note ? ` · ${entry.note}` : ''}
                      </>
                    }
                    meta={<OvermapCoord x={entry.x} y={entry.y} />}
                    tone={entry.tone}
                    bad={entry.tone === 'bad' || entry.kind === 'scanned_by'}
                  />
                ))}
              </OvermapList>
              {!filteredJournal.length && (
                <NoticeBox mt={1}>
                  {journal.length ? 'Ничего не найдено.' : 'Журнал пуст.'}
                </NoticeBox>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item shrink={0}>
            <div className="OvermapConsole__pad">
              {!!can_dump && (
                <Box mb={1}>
                  {dump_loaded ? (
                    <>
                      <Button icon="download" onClick={() => act('dump_write')}>
                        Выгрузить дамп ({known_count})
                      </Button>{' '}
                      <Button
                        icon="upload"
                        disabled={!dump_has_data}
                        onClick={() => act('dump_load')}
                      >
                        Загрузить дамп
                        {dump_has_data ? ` (${dump_count})` : ''}
                      </Button>{' '}
                      <Button icon="eject" onClick={() => act('dump_eject')}>
                        Достать {dump_name || 'листок'}
                      </Button>
                    </>
                  ) : (
                    <Button disabled>Вставьте бумагу в сканер</Button>
                  )}
                </Box>
              )}
              <Input
                fluid
                placeholder="Поиск по журналу"
                value={query}
                onChange={(value) => setQuery(value)}
              />
            </div>
          </Stack.Item>
        </Stack>
      ) : (
        <Stack fill className="OvermapSensorWorkspace">
          <Stack.Item grow minWidth={0} minHeight={0}>
            <Section
              fill
              fitted
              className="OvermapMapSection OvermapScopePanel"
              title={
                data.radar_locked
                  ? 'Межсекторный переход'
                  : map_jammed
                    ? 'Помехи гипертранслятора'
                    : scanning
                      ? 'Сканирование корпуса'
                      : `${sector_name || 'Сектор'} — ${long_range ? 'дальний' : 'ближний'}`
              }
            >
              <RadarViewport>
                {map_jammed && !data.radar_locked ? (
                  <NoticeBox danger>Связь потеряна.</NoticeBox>
                ) : (
                  <OvermapRadar
                    locked={!!data.radar_locked}
                    tick={data.radar_tick}
                    epoch={data.radar_epoch}
                    peels={data.radar_peels}
                    scatter={data.radar_scatter}
                    shapes={data.radar_shapes || {}}
                    contacts={data.radar || []}
                    drifters={data.radar_drifters || []}
                    projectiles={data.radar_projectiles || []}
                    engines={data.radar_engines || []}
                    facing={data.facing || 0}
                    terrain={data.radar_terrain}
                    world={data.radar_world}
                    objects={data.objects || []}
                    self={data.self_pos}
                    sectorSize={data.sector_size}
                    cellSpan={data.cell_span}
                    sectorId={data.sector_id}
                    galaxy={data.galaxy}
                    hazardFields={data.hazard_fields || []}
                    radius={data.scan_radar ? 64 : radius}
                    onZoom={setRadius}
                    followHeading={follow}
                    onToggleFollow={() => setFollow(!follow)}
                    onSelectObject={(ref) => act('scan', { ref })}
                    onSelectPoint={(x, y) => act('scan_point', { x, y })}
                  />
                )}
              </RadarViewport>
            </Section>
          </Stack.Item>
          {!!scanning && (
            <Stack.Item grow minHeight={0}>
              <Section
                fill
                scrollable
                title="Результат"
                buttons={
                  !!scan_done &&
                  !!can_print && (
                    <Button icon="print" onClick={() => act('print_scan')}>
                      Печать
                    </Button>
                  )
                }
              >
                {!scan_done && (
                  <Box mb={1}>
                    <ProgressBar value={scan_progress} maxValue={1}>
                      Сканирование {Math.round(scan_progress * 100)}%
                    </ProgressBar>
                  </Box>
                )}
                {scan_error ? (
                  <NoticeBox danger>{scan_error}</NoticeBox>
                ) : scan ? (
                  <OvermapStats>
                    <OvermapStat scan label="объект" value={scan.name} />
                    <OvermapStat
                      scan
                      label="тип"
                      value={overmapKindLabel(scan.kind)}
                    />
                    <OvermapStat scan label="масса" value={`${scan.mass} т`} />
                    <OvermapStat
                      scan
                      label="живые сигнатуры"
                      value={scan.living}
                    />
                    <OvermapStat
                      scan
                      label="двигатели"
                      value={`${scan.engines_ready}/${scan.engines}`}
                    />
                    <OvermapStat scan label="скорость" value={scan.speed} />
                    <OvermapStat scan label="курс" value={`${scan.heading}°`} />
                    <OvermapStat
                      scan
                      label="iff"
                      value={scan.transponder ? 'активен' : 'молчит'}
                      tone={scan.transponder ? 'good' : 'warn'}
                    />
                    {!!scan.has_hull && (
                      <OvermapStat
                        scan
                        label="габарит"
                        value={`${scan.size_x}×${scan.size_y}`}
                      />
                    )}
                  </OvermapStats>
                ) : (
                  <NoticeBox>Идёт анализ сигнатуры.</NoticeBox>
                )}
              </Section>
            </Stack.Item>
          )}
          {!scanning && (
            <Stack.Item grow minHeight={0}>
              <Section fill scrollable>
                {!has_long && !has_short && (
                  <NoticeBox>
                    Нет массивов сканера. Поставьте дальний и/или ближний массив
                    на судне.
                  </NoticeBox>
                )}
                {view_mode === 'short' && !!active && (
                  <NoticeBox info>
                    Возможно подробное сканирование ближайших объектов.
                  </NoticeBox>
                )}
                <OvermapList>
                  {contacts.map((contact) => (
                    <OvermapRow
                      key={contact.ref}
                      selected={selected === contact.ref}
                      tag={overmapKindLabel(contact.kind)}
                      title={`${contact.name}${contact.stealth ? ' (скрыт)' : ''}${contact.is_self ? ' — вы' : ''}${contact.distress ? ' ⚠' : ''}`}
                      meta={
                        <>
                          <OvermapCoord x={contact.x} y={contact.y} />{' '}
                          {contact.speed ?? 0} Gm/h · {contact.heading ?? 0}°
                          {contact.nested ? ' · в доке' : ''}
                        </>
                      }
                      bad={!!contact.distress}
                      onClick={() => act('select', { ref: contact.ref })}
                    >
                      {!!contact.can_scan && (
                        <Button
                          icon="search"
                          onClick={() => {
                            act('select', { ref: contact.ref });
                            act('scan', { ref: contact.ref });
                          }}
                        >
                          Сканировать
                        </Button>
                      )}
                    </OvermapRow>
                  ))}
                </OvermapList>
                {!contacts.length && (
                  <Box color="label">Нет контактов в зоне.</Box>
                )}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      )}
    </OvermapFrame>
  );
};
