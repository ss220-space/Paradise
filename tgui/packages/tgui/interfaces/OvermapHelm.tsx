import { useEffect, useRef, useState } from 'react';
import {
  Box,
  Button,
  Icon,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { type BooleanLike, classes } from 'tgui-core/react';

import { useBackend, useLocalState } from '../backend';
import {
  OVERMAP_KIND_ORDER,
  OvermapFrame,
  OvermapList,
  OvermapRail,
  OvermapRow,
  OvermapStat,
  OvermapStats,
  overmapKindIcon,
  overmapKindLabel,
} from './overmap/OvermapChrome';
import {
  formatRadarDistance,
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

type OvermapObject = RadarObject & {
  nested?: BooleanLike;
  speed?: number;
  docked_to?: string;
};

type EngineInfo = {
  name: string;
  ref: string;
  on: BooleanLike;
  thrust: number;
  limit: number;
  status: string;
  push?: number | null;
};

type ProgrammedRoute = {
  id: string;
  name: string;
  selected: BooleanLike;
};

type ShipPower = {
  cell_power?: BooleanLike;
  cell_charge?: number;
  cell_max?: number;
  apc_charge: number;
  apc_max: number;
  smes_charge: number;
  smes_max: number;
  sources: number;
};

type Phase = 'route' | 'jump' | 'relay' | 'docked' | 'transit' | 'flight';

type OvermapHelmData = {
  radar_outlines?: Record<string, string>;
  radar_peels?: RadarPeel[];
  radar_scatter?: RadarScatterChunk[];
  linked: BooleanLike;
  radar_docks?: { id: string; name: string; x: number; y: number }[];
  dock_preview?: { x: number; y: number; facing: number; tiles: number[] };
  docks?: {
    id: string;
    name: string;
    can_dock: BooleanLike;
    reason?: string;
  }[];
  can_ship_undock?: BooleanLike;
  can_stop?: BooleanLike;
  can_land?: BooleanLike;
  dock_ready?: BooleanLike;
  dock_in_range?: BooleanLike;
  dock_aligning?: BooleanLike;
  vessel_name: string;
  vessel_kind: string;
  status: string;
  phase: Phase;
  x: number;
  y: number;
  sector_name: string;
  sector_id?: string;
  sector_size: number;
  cell_span?: number;
  self_pos?: number[];
  view_range?: number;
  speed: number;
  heading: number;
  facing: number;
  accel: number;
  piloting: BooleanLike;
  pilot_name?: string | null;
  radar_enabled?: BooleanLike;
  radar_locked?: BooleanLike;
  radar_tick?: number;
  radar_epoch?: number;
  can_relay_jump?: BooleanLike;
  radar_reach?: number;
  radar_shapes?: Record<string, RadarShape>;
  radar?: RadarContact[];
  radar_drifters?: number[][];
  radar_projectiles?: RadarProjectile[];
  radar_terrain?: RadarTerrain | null;
  radar_world?: number[];
  radar_engines?: RadarEngine[];
  weapons?: {
    id: string;
    name: string;
    selected: BooleanLike;
    auto: BooleanLike;
    turret: BooleanLike;
    cooldown: number;
    arc: number;
    heading: number;
    x: number;
    y: number;
  }[];
  galaxy?: GalaxyMap | null;
  can_jump?: BooleanLike;
  local_space?: BooleanLike;
  jump_left?: number;
  jump_progress?: number;
  dest?: number[];
  dest_name?: string;
  dest_range?: number;
  dest_relay?: string;
  dest_jump_time?: number;
  max_speed: number;
  engines_on: BooleanLike;
  braking: BooleanLike;
  dampeners?: BooleanLike;
  angular_dampeners?: BooleanLike;
  avoid_obstacles?: BooleanLike;
  autopilot: BooleanLike;
  matching_velocity?: BooleanLike;
  navigation_target?: string;
  navigation_target_id?: string;
  programmed_cancellable?: BooleanLike;
  autopilot_status?: string;
  avoiding?: BooleanLike;
  eta?: number;
  thrust_sides?: number[];
  turn_accel?: number;
  top_speed?: number;
  omni_thrust?: BooleanLike;
  thrust: number;
  mass: number;
  thrust_limit: number;
  engines: EngineInfo[];
  power?: ShipPower;
  thrust_hint?: string;
  has_transponder: BooleanLike;
  transponder: {
    broadcasting: BooleanLike;
    distress: BooleanLike;
    transmitting?: BooleanLike;
  } | null;
  is_shuttle: BooleanLike;
  is_pod?: BooleanLike;
  can_undock: BooleanLike;
  can_steer: BooleanLike;
  map_jammed: BooleanLike;
  at_station: BooleanLike;
  host_name?: string;
  distress?: BooleanLike;
  broadcasting?: BooleanLike;
  objects: OvermapObject[];
  hazard_fields?: HazardField[];
  programmed_locked?: BooleanLike;
  programmed_has_routes?: BooleanLike;
  programmed_busy?: BooleanLike;
  programmed_windup?: number;
  programmed_eta?: string;
  programmed_selected?: string;
  programmed_routes?: ProgrammedRoute[];
};

const phaseTitle = (data: OvermapHelmData) => {
  switch (data.phase) {
    case 'route':
      return 'Полёт по маршруту';
    case 'jump':
      return 'Гиперпрыжок';
    case 'relay':
      return 'Прыжок через ретранслятор';
    case 'docked':
      return data.status;
    case 'transit':
      return 'Гиперпространство';
    default:
      return data.local_space ? 'Свободный полёт' : 'Открытый космос';
  }
};

const etaText = (seconds?: number) => {
  if (!seconds) {
    return '—';
  }
  const minutes = Math.floor(seconds / 60);
  const rest = Math.round(seconds % 60);
  return minutes ? `${minutes} мин ${rest} с` : `${rest} с`;
};

const SLIDER_THROTTLE = 120;

const useSlider = (value: number, send: (next: number) => void) => {
  const [draft, setDraft] = useState<number | null>(null);
  const pending = useRef<number | null>(null);
  const lastSent = useRef(0);
  const timer = useRef<number | null>(null);
  const flush = () => {
    timer.current = null;
    if (pending.current === null) {
      return;
    }
    lastSent.current = Date.now();
    send(pending.current);
    pending.current = null;
  };
  const change = (next: number) => {
    setDraft(next);
    pending.current = next;
    const wait = SLIDER_THROTTLE - (Date.now() - lastSent.current);
    if (wait <= 0) {
      flush();
      return;
    }
    if (timer.current === null) {
      timer.current = window.setTimeout(flush, wait);
    }
  };
  useEffect(() => {
    if (draft !== null && Math.abs(draft - value) <= 0.001) {
      setDraft(null);
    }
  }, [value, draft]);
  useEffect(
    () => () => {
      if (timer.current !== null) {
        window.clearTimeout(timer.current);
      }
    },
    [],
  );
  return [draft ?? value, change] as const;
};

export const OvermapHelm = () => {
  const { act, data } = useBackend<OvermapHelmData>();
  const { linked, programmed_locked } = data;
  const [radius, setRadius] = useLocalState('helmRadarZoom', 64);

  const [followHeading, setFollowHeading] = useLocalState(
    'helmRadarFollow',
    false,
  );
  const [kindFilter, setKindFilter] = useLocalState<string>(
    'helmKindFilter',
    'all',
  );
  useEffect(() => {
    act('helm_tab', { tab: 'flight' });
  }, []);

  return (
    <OvermapFrame
      title="Штурвал"
      width={1320}
      height={800}
      linked={linked}
      onRelink={() => act('relink')}
      rail={
        <OvermapRail
          name={data.vessel_name || 'Штурвал'}
          sector={data.sector_name}
          xy={linked ? `клетка ${data.x}:${data.y}` : undefined}
          lamps={[
            {
              label: data.broadcasting ? 'транспондер в эфире' : 'скрыт',
              on: !!data.broadcasting,
              warn: !data.broadcasting,
            },
            ...(data.distress ? [{ label: 'SOS', bad: true, on: true }] : []),
            ...(data.autopilot
              ? [
                  {
                    label: data.avoiding ? 'автопилот: обход' : 'автопилот',
                    on: true,
                  },
                ]
              : []),
          ]}
        />
      }
    >
      <div className="OvermapHelmLockHost">
        <div
          className={
            programmed_locked
              ? 'OvermapHelmLockHost__dim'
              : 'OvermapHelmLockHost__body'
          }
        >
          <div className="OvermapHelmShell">
            <div className="OvermapHelmShell__column">
              <ShipPanel />
              <ThrustPanel />
              <InertiaPanel />
              <GaugesPanel />
            </div>
            <div className="OvermapHelmShell__center">
              <RadarPanel
                radius={radius}
                onZoom={setRadius}
                followHeading={followHeading}
                onToggleFollow={() => setFollowHeading(!followHeading)}
                filter={kindFilter}
              />
            </div>
            <div className="OvermapHelmShell__column">
              <ObjectPanel filter={kindFilter} onFilter={setKindFilter} />
              <AutopilotPanel />
              <WeaponsPanel />
            </div>
          </div>
        </div>
        {!!programmed_locked && <RouteLock />}
      </div>
    </OvermapFrame>
  );
};

const RadarBottomBar = (props: { onLanding: () => void }) => {
  const { act, data } = useBackend<OvermapHelmData>();
  const {
    piloting,
    pilot_name,
    can_steer,
    can_undock,
    max_speed,
    can_jump,
    phase,
    local_space,
    dest_jump_time,
  } = data;
  const [speed, setSpeed] = useSlider(max_speed, (next) =>
    act('set_max_speed', { value: next }),
  );
  return (
    <div className="OvermapRadarBottom">
      <div className="OvermapRadarBottom__buttons">
        {!data.is_pod && (
          <button
            type="button"
            className={classes([
              'OvermapTouch',
              'OvermapTouch--onScope',
              piloting && 'OvermapTouch--on',
            ])}
            disabled={!can_steer || (!!pilot_name && !piloting)}
            onClick={() => act('take_helm')}
          >
            <Icon name={piloting ? 'hand' : 'gamepad'} />
            <span>
              {piloting
                ? 'Отпустить штурвал'
                : pilot_name
                  ? `Управляет: ${pilot_name}`
                  : 'Взять штурвал'}
            </span>
          </button>
        )}
        <button
          type="button"
          className="OvermapTouch OvermapTouch--onScope"
          disabled={
            !!data.radar_locked ||
            !!data.dock_aligning ||
            (!!data.dock_preview && !!data.dock_in_range && !data.dock_ready) ||
            (!data.dock_preview &&
              !can_undock &&
              !data.can_ship_undock &&
              !data.can_land &&
              !data.can_relay_jump &&
              !data.can_stop)
          }
          title={
            data.dock_preview && !data.dock_ready
              ? 'Нажмите повторно, чтобы отменить заход'
              : undefined
          }
          onClick={() => {
            if (data.dock_preview) act('align_dock');
            else if (data.can_ship_undock) act('dock_ship');
            else if (can_undock) act('undock');
            else if (data.can_relay_jump) act('relay_jump');
            else if (data.can_land) props.onLanding();
            else act('prepare_stop');
          }}
        >
          <Icon
            name={
              data.dock_preview
                ? 'anchor'
                : data.can_land
                  ? 'shuttle-space'
                  : 'arrow-up-from-bracket'
            }
          />
          <span>
            {data.radar_locked
              ? 'Прыжок…'
              : data.dock_preview
                ? data.dock_aligning
                  ? 'Автодоводка…'
                  : data.dock_ready
                    ? 'Состыковаться'
                    : 'Стыковка'
                : can_undock || data.can_ship_undock
                  ? 'Отстыковка'
                  : data.can_relay_jump
                    ? 'Прыжок'
                    : data.can_land
                      ? 'Посадка'
                      : data.is_pod
                        ? 'Стыковка'
                        : 'Остановиться'}
          </span>
        </button>
        {phase === 'flight' && !!can_jump && !local_space && (
          <button
            type="button"
            className="OvermapTouch OvermapTouch--onScope OvermapTouch--good"
            onClick={() => act('hyperjump')}
          >
            <Icon name="bolt" />
            <span>
              Гиперпрыжок{dest_jump_time ? ` ≈${dest_jump_time} с` : ''}
            </span>
          </button>
        )}
      </div>
      <label className="OvermapSpeedRow">
        <Icon name="gauge-high" />
        <span>макс. скорость</span>
        <input
          type="range"
          min={1}
          max={45}
          step={1}
          value={speed}
          onChange={(event) => setSpeed(Number(event.target.value))}
        />
        <em>{speed} м/с</em>
      </label>
    </div>
  );
};

const InertiaPanel = () => {
  const { act, data } = useBackend<OvermapHelmData>();
  const { dampeners, angular_dampeners } = data;
  return (
    <Section title="Инерция" className="OvermapHelmBox">
      <div className="OvermapInertiaPanel">
        <button
          type="button"
          className={classes([
            'OvermapTouch',
            'OvermapTouch--inline',
            dampeners && 'OvermapTouch--on',
          ])}
          title="Двигатели сами гасят линейную скорость, когда штурвал отпущен"
          onClick={() => act('toggle_dampeners')}
        >
          <Icon name="anchor-lock" />
          <span>{dampeners ? 'Ход' : 'Гашение хода'}</span>
        </button>
        <button
          type="button"
          className={classes([
            'OvermapTouch',
            'OvermapTouch--inline',
            angular_dampeners && 'OvermapTouch--on',
          ])}
          title="Двигатели сами гасят вращение, когда штурвал отпущен"
          onClick={() => act('toggle_angular_dampeners')}
        >
          <Icon name="arrows-rotate" />
          <span>{angular_dampeners ? 'Вращение' : 'Гашение вращения'}</span>
        </button>
      </div>
    </Section>
  );
};

const ShipPanel = () => {
  const { data } = useBackend<OvermapHelmData>();
  const transmitting = data.transponder?.transmitting ?? data.broadcasting;
  const distress = data.distress ?? data.transponder?.distress;
  return (
    <Section title="Корабль" className="OvermapHelmBox">
      <div className="OvermapShipName">{data.vessel_name || '—'}</div>
      <OvermapStats>
        <OvermapStat
          label="транспондер"
          value={transmitting ? 'в эфире' : 'скрыт'}
          tone={distress ? 'bad' : transmitting ? 'good' : 'warn'}
        />
        <OvermapStat label="сектор" value={data.sector_name || '—'} />
        <OvermapStat label="клетка" value={`${data.x}:${data.y}`} />
        <OvermapStat label="скорость" value={`${data.speed}`} />
      </OvermapStats>
      <Box mt={0.5} className="OvermapHelmHint">
        {phaseTitle(data)}
        {data.pilot_name ? ` · за штурвалом ${data.pilot_name}` : ''}
      </Box>
    </Section>
  );
};

const ThrustPanel = () => {
  const { act, data } = useBackend<OvermapHelmData>();
  const sides = data.thrust_sides || [0, 0, 0, 0];
  const engines = data.engines || [];
  const offline = engines.filter((engine) => !engine.on);
  const [limit, setLimit] = useSlider(data.thrust_limit, (next) =>
    act('set_thrust_limit', { value: next }),
  );
  const labels: Record<string, string> = {
    front: 'вперёд',
    right: 'вправо',
    back: 'назад',
    left: 'влево',
  };
  const slot = (index: number, key: string) => (
    <div className={`OvermapThrust__slot OvermapThrust__slot--${key}`}>
      <span>{labels[key]}</span>
      <em>{sides[index] || 0} м/с²</em>
    </div>
  );
  return (
    <Section title="Тяга" className="OvermapHelmBox">
      <div className="OvermapThrust">
        {slot(0, 'front')}
        {slot(3, 'left')}
        <div className="OvermapThrust__slot OvermapThrust__slot--center">
          <input
            type="range"
            className="OvermapThrust__slider"
            min={0}
            max={100}
            step={5}
            value={limit}
            onChange={(event) => setLimit(Number(event.target.value))}
          />
          <span className="OvermapThrust__percent">{limit}%</span>
        </div>
        {slot(1, 'right')}
        {slot(2, 'back')}
      </div>
      <div className="OvermapThrust__foot">
        <span>
          двигатели {engines.filter((engine) => engine.on).length}/
          {engines.length}
        </span>
        {!!offline.length && (
          <button
            type="button"
            className="OvermapTouch OvermapTouch--inline"
            onClick={() =>
              offline.forEach((engine) => {
                act('toggle_engine', { ref: engine.ref });
              })
            }
          >
            <Icon name="power-off" />
            <span>Включить</span>
          </button>
        )}
        <span>поворот {data.turn_accel || 0}°/с²</span>
      </div>
      {!!data.thrust_hint && (
        <div className="OvermapThrust__warning">
          <Icon name="triangle-exclamation" />
          <span>{data.thrust_hint}</span>
        </div>
      )}
    </Section>
  );
};

const GaugesPanel = () => {
  const { data } = useBackend<OvermapHelmData>();
  const power = data.power;
  const enginesOn = (data.engines || []).filter((engine) => engine.on).length;
  const gauge = (label: string, charge: number, max: number, cell = false) => {
    const percent = max > 0 ? Math.min(100, (charge / max) * 100) : 0;
    return (
      <div className="OvermapGaugeRow" key={label}>
        <div className="OvermapGaugeRow__head">
          <span>{label}</span>
          <span>{max > 0 ? `${Math.round(percent)}%` : '—'}</span>
        </div>
        <div className="OvermapGauge">
          <div
            className="OvermapGauge__fill"
            style={{ width: `${percent}%` }}
          />
        </div>
        <div className="OvermapGaugeRow__meta">
          {max > 0
            ? cell
              ? `${Math.round(charge)} / ${Math.round(max)} ед.`
              : `${Math.round(charge / 1000)} / ${Math.round(max / 1000)} кДж`
            : 'нет источника'}
        </div>
      </div>
    );
  };
  return (
    <Section title="Энергия и двигатели" className="OvermapHelmBox">
      {power?.cell_power ? (
        power.sources > 0 ? (
          gauge(
            'Аккумулятор',
            power.cell_charge || 0,
            power.cell_max || 0,
            true,
          )
        ) : (
          <NoticeBox>Аккумулятор не установлен.</NoticeBox>
        )
      ) : power && power.sources > 0 ? (
        <>
          {gauge('APC', power.apc_charge, power.apc_max)}
          {gauge('СМЭС', power.smes_charge, power.smes_max)}
        </>
      ) : (
        <NoticeBox>На борту нет силовой сети.</NoticeBox>
      )}
      <OvermapStats>
        <OvermapStat
          label="двигатели"
          value={`${enginesOn}/${(data.engines || []).length}`}
          tone={enginesOn ? 'good' : 'bad'}
        />
        <OvermapStat label="тяга" value={`${data.thrust}`} />
        <OvermapStat label="масса" value={`${data.mass} т`} />
        <OvermapStat label="ускорение" value={`${data.accel}`} />
      </OvermapStats>
    </Section>
  );
};

const RadarPanel = (props: {
  radius: number;
  onZoom: (radius: number) => void;
  followHeading: boolean;
  onToggleFollow: () => void;
  filter: string;
}) => {
  const { act, data } = useBackend<OvermapHelmData>();
  const { radius, onZoom, followHeading, onToggleFollow, filter } = props;
  const [landingPicker, setLandingPicker] = useState(false);
  useEffect(() => {
    if (!data.can_land) setLandingPicker(false);
  }, [data.can_land]);
  return (
    <Section
      className="OvermapHelmBox OvermapRadarSection"
      title={`${data.sector_name || 'Сектор'} · клетка ${data.x}:${data.y}`}
      buttons={
        <span className="OvermapHelmHint">
          {data.radar_enabled ? `${data.radar_reach ?? 0} м` : 'не в космосе'}
        </span>
      }
    >
      {data.map_jammed && !data.radar_locked ? (
        <div className="OvermapRadarJam">
          <NoticeBox danger>Сигнал потерян: идёт прыжок.</NoticeBox>
        </div>
      ) : (
        <>
          <OvermapRadar
            outlines={data.radar_outlines}
            locked={!!data.radar_locked}
            tick={data.radar_tick}
            epoch={data.radar_epoch}
            overlay={
              landingPicker ? (
                <div className="OvermapLandingPicker">
                  <div className="OvermapLandingPicker__head">
                    <div>
                      <small>НАВИГАЦИЯ / ПОСАДКА</small>
                      <h2>Посадочные зоны</h2>
                    </div>
                    <button
                      type="button"
                      onClick={() => setLandingPicker(false)}
                      title="Вернуться к радару"
                    >
                      <Icon name="xmark" />
                    </button>
                  </div>
                  <p>Выберите площадку для построения захода.</p>
                  <div className="OvermapLandingPicker__list">
                    {(data.docks || [])
                      .filter((dock) => dock.id !== '__overmap_custom')
                      .map((dock, index) => (
                        <button
                          type="button"
                          key={dock.id}
                          disabled={!dock.can_dock}
                          title={dock.reason}
                          onClick={() => {
                            act('prepare_landing', { id: dock.id });
                            setLandingPicker(false);
                          }}
                        >
                          <span className="OvermapLandingPicker__number">
                            {String(index + 1).padStart(2, '0')}
                          </span>
                          <span>
                            <strong>{dock.name}</strong>
                            <small>{dock.reason || 'Подготовить заход'}</small>
                          </span>
                          <Icon name="arrow-right" />
                        </button>
                      ))}
                    {!(data.docks || []).filter(
                      (dock) => dock.id !== '__overmap_custom',
                    ).length && (
                      <div className="OvermapLandingPicker__empty">
                        <Icon name="satellite-dish" />
                        <p>Посадочные зоны не обнаружены</p>
                        <small>
                          Подлетите к объекту с посадочными маяками.
                        </small>
                      </div>
                    )}
                  </div>
                </div>
              ) : undefined
            }
            peels={data.radar_peels}
            scatter={data.radar_scatter}
            dockTargets={data.radar_docks}
            dockPreview={data.dock_preview}
            onSelectDock={(id) => {
              const dock = data.radar_docks?.find((entry) => entry.id === id);
              if (dock && data.weapons?.some((weapon) => weapon.selected)) {
                act('radar_point', { x: dock.x, y: dock.y });
              } else {
                act('select_radar_dock', { id });
              }
            }}
            onSelectPoint={(x, y) => act('radar_point', { x, y })}
            onSelectObject={(id) => act('set_dest', { id, x: 1, y: 1 })}
            shapes={data.radar_shapes || {}}
            contacts={data.radar || []}
            drifters={data.radar_drifters || []}
            projectiles={data.radar_projectiles || []}
            weaponArcs={(data.weapons || []).filter(
              (weapon) => weapon.selected,
            )}
            facing={data.facing || 0}
            terrain={data.radar_terrain}
            world={data.radar_world}
            engines={data.radar_engines || []}
            objects={data.objects}
            self={data.self_pos}
            sectorSize={data.sector_size}
            cellSpan={data.cell_span}
            sectorId={data.sector_id}
            galaxy={data.galaxy}
            radius={radius}
            onZoom={onZoom}
            onReach={(reach) => {
              if (reach !== data.radar_reach) {
                act('helm_radar_reach', { reach });
              }
            }}
            followHeading={followHeading}
            onToggleFollow={onToggleFollow}
            dest={data.dest}
            filter={filter}
            hazardFields={data.hazard_fields || []}
          />
          <RadarBottomBar onLanding={() => setLandingPicker(true)} />
        </>
      )}
    </Section>
  );
};

const ObjectPanel = (props: {
  filter: string;
  onFilter: (filter: string) => void;
}) => {
  const { act, data } = useBackend<OvermapHelmData>();
  const { filter, onFilter } = props;
  const { objects = [], self_pos, dest } = data;
  const visible = objects.filter((object) => !object.is_self);
  const distance = (object: { x: number; y: number }) =>
    self_pos
      ? Math.round(
          Math.max(
            Math.abs(object.x - self_pos[0]),
            Math.abs(object.y - self_pos[1]),
          ),
        )
      : 0;
  const kinds = OVERMAP_KIND_ORDER.filter(
    (kind) => kind === 'unknown' || visible.some((o) => o.kind === kind),
  );
  const shown = visible
    .filter((object) => filter === 'all' || object.kind === filter)
    .sort((a, b) => distance(a) - distance(b));
  const isDest = (object: { id?: string; x: number; y: number }) =>
    data.navigation_target_id
      ? data.navigation_target_id === object.id
      : !!dest && dest[0] === object.x && dest[1] === object.y;
  return (
    <Section
      className="OvermapHelmBox"
      title={`Объекты · ${visible.length}`}
      buttons={
        <Button
          icon="times"
          compact
          tooltip="Сбросить цель"
          disabled={!dest}
          onClick={() => act('clear_dest')}
        />
      }
    >
      <div className="OvermapKindFilter">
        <button
          type="button"
          className={
            filter === 'all'
              ? 'OvermapKindFilter__item OvermapKindFilter__item--on'
              : 'OvermapKindFilter__item'
          }
          onClick={() => onFilter('all')}
        >
          все
        </button>
        {kinds.map((kind) => (
          <button
            key={kind}
            type="button"
            className={
              filter === kind
                ? 'OvermapKindFilter__item OvermapKindFilter__item--on'
                : 'OvermapKindFilter__item'
            }
            title={overmapKindLabel(kind)}
            onClick={() => onFilter(kind)}
          >
            <Icon name={overmapKindIcon(kind)} />
          </button>
        ))}
      </div>
      <div className="OvermapObjectList">
        <OvermapList>
          {shown.map((object) => (
            <OvermapRow
              key={`${object.kind}-${object.name}-${object.x}-${object.y}`}
              tag={
                <>
                  <Icon name={overmapKindIcon(object.kind)} />{' '}
                  {overmapKindLabel(object.kind)}
                </>
              }
              title={
                <Box color={object.color} inline>
                  {object.name}
                  {object.distress ? ' ⚠' : ''}
                </Box>
              }
              meta={`${object.x}:${object.y} · ${distance(object)} кл.${
                object.kind === 'relay' && object.leads_to
                  ? ` → ${object.leads_to}`
                  : ''
              }`}
              selected={isDest(object)}
              bad={!!object.distress}
              onClick={() =>
                act('set_dest', {
                  id: object.id,
                  x: object.x,
                  y: object.y,
                  name: object.name,
                })
              }
            />
          ))}
        </OvermapList>
        {!shown.length && (
          <Box className="OvermapHelmHint">Сенсоры не видят ничего рядом.</Box>
        )}
      </div>
    </Section>
  );
};

const WeaponsPanel = () => {
  const { data, act } = useBackend<OvermapHelmData>();
  const weapons = data.weapons || [];
  return (
    <section className="OvermapHelmBox OvermapWeapons">
      <h3>
        <Icon name="crosshairs" /> Орудия{' '}
        <small>
          {weapons.filter((weapon) => weapon.selected).length} выбрано
        </small>
      </h3>
      {!weapons.length && <p>Корабельные орудия не обнаружены</p>}
      {weapons.map((weapon) => (
        <div key={weapon.id}>
          <button
            type="button"
            className={weapon.selected ? 'is-active' : ''}
            onClick={() => act('select_weapon', { id: weapon.id })}
          >
            <Icon name={weapon.selected ? 'square-check' : 'square'} />
            <span>
              {weapon.name}
              <small>
                {weapon.arc}° ·{' '}
                {weapon.cooldown > 0
                  ? `${weapon.cooldown.toFixed(1)} с`
                  : 'готово'}
              </small>
            </span>
          </button>
          {!!weapon.turret && (
            <button
              type="button"
              title="Автоматическая стрельба по целям турели"
              className={weapon.auto ? 'is-active' : ''}
              onClick={() => act('weapon_auto', { id: weapon.id })}
            >
              Авто
            </button>
          )}
        </div>
      ))}
      {weapons.some((weapon) => weapon.selected) && <p>Орудие наготове.</p>}
    </section>
  );
};

const AutopilotPanel = () => {
  const { act, data } = useBackend<OvermapHelmData>();
  const {
    autopilot,
    autopilot_status,
    avoiding,
    eta,
    max_speed,
    dest,
    dest_name,
    can_steer,
    avoid_obstacles,
  } = data;
  return (
    <Section title="Автопилот" className="OvermapHelmBox">
      <OvermapStats>
        <OvermapStat
          hero
          label="статус"
          value={autopilot ? (avoiding ? 'обход' : 'в пути') : 'выключен'}
          tone={autopilot ? (avoiding ? 'warn' : 'good') : undefined}
        />
        <OvermapStat label="ETA" value={autopilot ? etaText(eta) : '—'} />
      </OvermapStats>

      {!!autopilot_status && (
        <Box mt={0.5} className="OvermapHelmHint">
          {autopilot_status}
        </Box>
      )}
      <Button
        fluid
        mt={0.5}
        icon="route"
        selected={!!autopilot}
        disabled={!can_steer || !dest}
        onClick={() => act('toggle_autopilot')}
      >
        {autopilot
          ? 'Остановить автопилот'
          : dest
            ? `Лететь к ${dest_name || 'цели'}`
            : 'Сначала выберите цель'}
      </Button>
      <Button
        fluid
        mt={0.3}
        icon="arrows-left-right-to-line"
        selected={!!data.matching_velocity}
        disabled={!can_steer || !data.navigation_target}
        onClick={() => act('match_velocity')}
      >
        Сближение{data.navigation_target ? `: ${data.navigation_target}` : ''}
      </Button>
      {!!data.programmed_cancellable && (
        <Button
          fluid
          mt={0.3}
          color="bad"
          icon="stop"
          onClick={() => act('cancel_programmed')}
        >
          Отменить программный рейс
        </Button>
      )}
      <Button
        fluid
        mt={0.3}
        icon="shield-halved"
        selected={!!avoid_obstacles}
        tooltip="Автопилот обходит станции, руины и сервисные площадки, а не таранит их"
        onClick={() => act('toggle_avoidance')}
      >
        {avoid_obstacles ? 'Объекты: обходить' : 'Объекты: не объезжать'}
      </Button>
      {!!data.view_range && (
        <Box mt={0.5} className="OvermapHelmHint">
          дальность сенсоров {data.view_range}
          {formatRadarDistance((data.view_range || 0) * 100)}
        </Box>
      )}
    </Section>
  );
};

const RouteLock = () => {
  const { act, data } = useBackend<OvermapHelmData>();
  const {
    programmed_has_routes,
    programmed_busy,
    programmed_windup,
    programmed_eta,
    programmed_selected,
    programmed_routes = [],
  } = data;
  return (
    <div className="OvermapHelmLockOverlay">
      <div className="OvermapHelmLockOverlay__card">
        <div className="OvermapHelmLockOverlay__title">
          Прямое управление заблокировано поставщиком
        </div>
        <div className="OvermapHelmLockOverlay__sub">
          Используйте заранее заготовленный маршрут
        </div>
        {!!programmed_has_routes && (
          <>
            <Box mt={1.5} mb={0.5} className="OvermapStat__label">
              назначение
            </Box>
            <Stack vertical>
              {programmed_routes.map((route) => (
                <Stack.Item key={route.id}>
                  <Button
                    fluid
                    selected={
                      !!route.selected || programmed_selected === route.id
                    }
                    disabled={!!programmed_busy}
                    onClick={() => act('select_programmed', { id: route.id })}
                  >
                    {route.name}
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
            <Box mt={1.5}>
              <Button
                icon="play"
                color="good"
                disabled={!programmed_routes.length || !!programmed_busy}
                onClick={() =>
                  act('execute_programmed', { id: programmed_selected })
                }
              >
                Исполнить
              </Button>
            </Box>
            {!!programmed_busy && (
              <Box mt={1} className="OvermapRail__meta">
                {programmed_windup
                  ? `Отправление через ${programmed_windup} с`
                  : `В пути ${programmed_eta || ''}`}
              </Box>
            )}
          </>
        )}
      </div>
    </div>
  );
};
