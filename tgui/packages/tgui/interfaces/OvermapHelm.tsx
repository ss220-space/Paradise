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
  OvermapFrame,
  OvermapRail,
  OvermapStat,
  OvermapStats,
} from './overmap/OvermapChrome';
import { HelmContacts, HelmWeapons } from './overmap/HelmControls';
import { HelmSpeedControl } from './overmap/HelmSpeedControl';
import { HelmHeading } from './overmap/HelmHeading';
import { useHelmFlightKeys } from './overmap/useHelmFlightKeys';
import {
  HelmAutopilot,
  helmPointSelection,
  type HelmSelection,
  HelmTargetCard,
} from './overmap/HelmNavigation';
import type { RadarPose } from './overmap/OvermapRadar';
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

export type OvermapHelmData = {
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
  radar_docked?: BooleanLike;
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
    cooldown_total?: number;
    arc: number;
    heading: number;
    x: number;
    y: number;
  }[];
  galaxy?: GalaxyMap | null;
  local_space?: BooleanLike;
  dest?: number[];
  dest_name?: string;
  dest_range?: number;
  dest_relay?: string;
  max_speed: number;
  stealth_speed?: number;
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
  radar_poses?: RadarPose[];
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
  useHelmFlightKeys(!!linked && !!data.piloting && !data.map_jammed);
  const [radius, setRadius] = useLocalState('helmRadarZoom', 160);

  const [followHeading, setFollowHeading] = useLocalState(
    'helmRadarFollow',
    false,
  );
  const [landingPicker, setLandingPicker] = useState(false);
  const [selection, setSelection] = useState<HelmSelection | null>(null);
  useEffect(
    () => setSelection(null),
    [data.sector_id, data.vessel_name, data.linked],
  );
  useEffect(() => {
    act('helm_tab', { tab: 'flight' });
  }, []);
  useEffect(() => {
    if (!data.can_land) setLandingPicker(false);
  }, [data.can_land]);

  return (
    <OvermapFrame
      title="Штурвал"
      width={1320}
      height={900}
      linked={linked}
      onRelink={() => act('relink')}
      rail={
        <div className="OvermapHelmHeader">
          <OvermapRail
            name={data.vessel_name || 'Штурвал'}
            sector={data.sector_name}
            xy={linked ? `клетка ${data.x}:${data.y}` : undefined}
            lamps={[
              {
                label: `Двигатели: ${(data.engines || []).filter((engine) => engine.on).length}/${(data.engines || []).length}`,
                on:
                  !!data.engines_on &&
                  (data.engines || []).some((engine) => engine.on),
                warn:
                  !data.engines_on ||
                  !(data.engines || []).some((engine) => engine.on),
              },
              {
                label: data.angular_dampeners
                  ? 'Вращение: гашение'
                  : 'Вращение: свободно',
                on: !!data.angular_dampeners,
              },
              {
                label: data.dampeners ? 'Движение: гашение' : 'Движение: дрейф',
                on: !!data.dampeners,
              },
              {
                label: data.broadcasting ? 'транспондер в эфире' : 'скрыт',
                on: !!data.broadcasting,
                warn: !data.broadcasting,
              },
              ...(data.distress ? [{ label: 'SOS', bad: true, on: true }] : []),
              {
                label: data.autopilot
                  ? data.avoiding
                    ? 'Автопилот: обход'
                    : 'Автопилот: в пути'
                  : 'Автопилот: выкл',
                on: !!data.autopilot,
              },
            ]}
          />
        </div>
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
          <div className="OvermapHelmBridge">
            <div className="OvermapHelmBridge__stage">
              <div className="OvermapHelmBridge__radar">
                <RadarPanel
                  radius={radius}
                  onZoom={setRadius}
                  followHeading={followHeading}
                  filter="all"
                  landingPicker={landingPicker}
                  onLandingPicker={setLandingPicker}
                  onSelect={setSelection}
                  selection={selection}
                />
              </div>
              <div className="OvermapHelmBridge__left">
                <Speedometer />
                <div className="OvermapHelmBridge__maneuver OvermapHelmBridge__pilot">
                  <Section title="Управление" className="OvermapHelmBox">
                    <HelmPilotButton />
                    <div className="OvermapHelmBridge__keys">
                      <span>WASD · движение</span>
                      <span>Q / E · поворот</span>
                      <span>Пробел · тормоз</span>
                    </div>
                  </Section>
                </div>
                <HelmWeapons />
              </div>
              <div className="OvermapHelmBridge__right">
                {selection && (
                  <HelmTargetCard
                    selection={selection}
                    onCancel={() => setSelection(null)}
                  />
                )}
                <div className="OvermapHelmBridge__contacts">
                  <HelmContacts selection={selection} onSelect={setSelection} />
                </div>
              </div>
            </div>
            <div className="OvermapHelmBridge__console">
              <div className="OvermapHelmBridge__deck OvermapHelmBridge__deck--speed">
                <section className="HelmDeck">
                  <div className="HelmDeck__body">
                    <SpeedLever />
                  </div>
                </section>
              </div>
              <div className="OvermapHelmBridge__deck OvermapHelmBridge__deck--heading">
                <HelmHeading
                  onLanding={() => setLandingPicker(true)}
                  followHeading={followHeading}
                  onToggleFollow={() => setFollowHeading(!followHeading)}
                />
              </div>
              <div className="OvermapHelmBridge__deck OvermapHelmBridge__deck--autopilot">
                <HelmAutopilot />
              </div>
              <div className="OvermapHelmBridge__deck OvermapHelmBridge__deck--systems">
                <GaugesPanel />
              </div>
            </div>
          </div>
        </div>
        {!!programmed_locked && <RouteLock />}
      </div>
    </OvermapFrame>
  );
};

const HelmPilotButton = () => {
  const { act, data } = useBackend<OvermapHelmData>();
  const { piloting, pilot_name, can_steer } = data;
  return (
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
    </div>
  );
};

const Speedometer = () => {
  const { data } = useBackend<OvermapHelmData>();
  const angle = (value: number) =>
    `${Math.round(((value % 360) + 360) % 360)
      .toString()
      .padStart(3, '0')}°`;
  return (
    <div className="OvermapHelmMotion">
      <div className="OvermapHelmMotion__label">Ход</div>
      <div className="OvermapHelmMotion__speed">
        <strong>{data.speed.toFixed(1)}</strong>
        <span>м/с</span>
        <div>
          <small>задано</small>
          <b>{data.braking ? '—' : data.max_speed}</b>
        </div>
      </div>
      <div className="OvermapHelmMotion__readouts">
        <div>
          <small>Курс</small>
          <b>{angle(data.facing)}</b>
        </div>
        <div>
          <small>Вектор</small>
          <b>{data.speed > 0 ? angle(data.heading) : '—'}</b>
        </div>
        <div>
          <small>Ускорение</small>
          <b>{data.accel} м/с²</b>
        </div>
      </div>
      <div className="OvermapHelmHint">
        {phaseTitle(data)}
        {data.pilot_name ? ` · за штурвалом ${data.pilot_name}` : ''}
      </div>
    </div>
  );
};

const SpeedLever = () => {
  const { act, data } = useBackend<OvermapHelmData>();
  const [speed, setSpeed] = useSlider(
    data.braking ? 0 : data.max_speed,
    (next) => act('set_max_speed', { value: next }),
  );
  return <HelmSpeedControl speed={speed} onChange={setSpeed} />;
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
  filter: string;
  landingPicker: boolean;
  onLandingPicker: (open: boolean) => void;
  onSelect: (selection: HelmSelection | null) => void;
  selection: HelmSelection | null;
}) => {
  const { act, data } = useBackend<OvermapHelmData>();
  const { radius, onZoom, followHeading, filter } = props;
  const { landingPicker, onLandingPicker: setLandingPicker } = props;
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
        <OvermapRadar
          fillViewport
          interpolationDelay={0}
          clickTarget={
            props.selection?.kind === 'object'
              ? { id: props.selection.id }
              : props.selection
                ? { x: props.selection.x, y: props.selection.y }
                : undefined
          }
          onFirePoint={(x, y) => act('fire_radar', { x, y })}
          outlines={data.radar_outlines}
          locked={!!data.radar_locked}
          docked={!!data.radar_docked}
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
                          act('prepare_landing', {
                            id: dock.id,
                          });
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
                      <small>Подлетите к объекту с посадочными маяками.</small>
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
            if (dock)
              props.onSelect(
                helmPointSelection(data, dock.x, dock.y, dock.name),
              );
          }}
          onSelectPoint={(x, y) =>
            props.onSelect(helmPointSelection(data, x, y))
          }
          onSelectObject={(id) => {
            const object = data.objects?.find((entry) => entry.id === id);
            if (object)
              props.onSelect({ kind: 'object', id, name: object.name });
          }}
          shapes={data.radar_shapes || {}}
          contacts={data.radar || []}
          drifters={data.radar_drifters || []}
          projectiles={data.radar_projectiles || []}
          weapons={data.weapons || []}
          weaponArcs={(data.weapons || []).filter((weapon) => weapon.selected)}
          facing={data.facing || 0}
          terrain={data.radar_terrain}
          world={data.radar_world}
          engines={data.radar_engines || []}
          poses={data.radar_poses}
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
          dest={data.dest}
          filter={filter}
          hazardFields={data.hazard_fields || []}
        />
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
