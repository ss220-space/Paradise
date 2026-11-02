import {
  type ReactElement,
  type MouseEvent as ReactMouseEvent,
  type ReactNode,
  useEffect,
  useState,
} from 'react';
import { Button, Dropdown, Icon, Image, Tooltip } from 'tgui-core/components';
import { globalEvents } from 'tgui-core/events';
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { suspendStart } from '../events/handlers/suspense';
import { Window } from '../layouts';

// MARK: Data

type SpacepodControlPanelData = {
  vessel: string;
  electricity: ElectricityPanelData;
  engines: EnginesPanelData;
  fuel: FuelSystemPanelData;
  weapons: WeaponsPanelData;
  life_support: LifeSupportPanelData;
  integrity: IntegrityPanelData;
  misc: MiscPanelData;
};

type ElectricityPanelData = {
  exists: boolean;
  battery_id?: string;
  link?: boolean;
  power?: number;
  capacity?: number;
  percent?: number;
  consumers: ElectricityConsumerData[];
};

type ElectricityConsumerData = {
  id: string;
  caption: string;
  name: string;
  link: boolean;
};

type EnginesPanelData = {
  engines: EngineData[];
  gyroscope: GyroscopeData | null;
};

type EngineData = {
  id: string;
  caption: string;
  name: string;
  enable: boolean;
  is_apu: boolean;
  power_link: boolean | null;
  rpm: number;
  rpm_percent: number;
  rpm_warn: boolean;
  fuel_pressure: number;
  fuel_pressure_warn: boolean;
  rpm_provide_engines: string[] | null;
  selected_rpm_provide_engine: string | null;
  generator_enable: boolean;
  generated_power: number;
  temperature: number;
  temperature_warn: boolean;
  error_text: string | null;
};

type GyroscopeData = {
  id: string;
  name: string;
  power_link: boolean;
  enable: boolean;
  rpm: number;
  rpm_percent: number;
  rpm_warn: boolean;
  temperature: number;
  temperature_warn: boolean;
  error_text: string | null;
};

type FuelSystemPanelData = {
  fuel_tanks: FuelTankData[];
  fuel_pumps: FuelPumpData[];
};

type FuelTankData = {
  id: string;
  caption: string;
  name: string;
  fuel_amount: number;
  fuel_capacity: number;
  level_percent: number;
};

type FuelPumpData = {
  id: string;
  caption: string;
  name: string;
  power_link: boolean;
  enable: boolean;
  pump_speed: number;
  temperature: number;
  temperature_warn: boolean;
  error_text: string | null;
};

type WeaponsPanelData = {
  module: WeaponModuleData | null;
  guns: GunData[];
};

type WeaponModuleData = {
  id: string;
  name: string;
  enable: boolean;
  power_link: boolean;
  error_text: string | null;
};

type GunData = {
  id: string;
  name: string;
  primary: boolean;
  safety: boolean;
  type: number;
  ammo: number;
  capacity: number;
  charging: boolean;
};

type LifeSupportPanelData = {
  exists: boolean;
  airtank: AirtankData | null;
  atmos: AtmosData;
};

type AirtankData = {
  name: string;
  enable: boolean;
  volume: string;
  pressure: string;
  low_pressure: boolean;
};

type AtmosData = {
  pressure: string;
  low_pressure: boolean;
  temperature: string;
  low_temperature: boolean;
};

type IntegrityPanelData = {
  hull: HullIntegrityData;
  modules: ModuleIntegrityData[];
};

type HullIntegrityData = {
  name: string;
  integrity: number;
  max_integrity: number;
  integrity_warn: boolean;
  extenguish_charges: number;
};

type ModuleIntegrityData = {
  id: string;
  caption: string;
  name: string;
  enable: boolean;
  integrity: number;
  max_integrity: number;
  integrity_warn: boolean;
  fire: boolean;
};

type MiscPanelData = {
  key_lock: KeyLockData | null;
  catapult: CatapultData | null;
  tracker: TrackerData | null;
};

type KeyLockData = {
  locked: boolean;
};

type CatapultData = {
  id: string;
  enable: boolean;
};

type TrackerData = {
  id: string;
  enable: boolean;
};

// MARK: Helpers

const clampPercent = (value: number) =>
  Math.max(0, Math.min(100, Number.isFinite(value) ? value : 0));

const percentOf = (value: number, max: number) =>
  max > 0 ? clampPercent((value / max) * 100) : 0;

const asNumber = (value: string | number | undefined) => {
  const parsed = typeof value === 'number' ? value : Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
};

/**
 * Returns the size of the browser pane. The pane is anchored to the game
 * window, so its viewport is always the full map window area. The size is
 * intentionally captured only once: reacting to `resize` would make Window
 * push the pane size back via winset, producing a winset/resize feedback
 * loop (the "shaking" window bug).
 */
const getViewportSize = (): [number, number] => [
  window.innerWidth,
  window.innerHeight,
];

type LampState = 'ok' | 'warn' | 'bad' | 'off';

// MARK: Window

type SectionId =
  | 'power'
  | 'fuel'
  | 'engines'
  | 'systems'
  | 'integrity'
  | 'weapons';

const SECTIONS: { id: SectionId; icon: string; label: string }[] = [
  { id: 'power', icon: 'bolt', label: 'Электропитание' },
  { id: 'fuel', icon: 'gas-pump', label: 'Топливная система' },
  { id: 'engines', icon: 'tachometer-alt', label: 'Двигатели' },
  { id: 'weapons', icon: 'crosshairs', label: 'Вооружение' },
  {
    id: 'systems',
    icon: 'satellite-dish',
    label: 'Дополнительные системы',
  },
  { id: 'integrity', icon: 'shield-alt', label: 'Живучесть' },
];

export const SpacepodControlPanel = (props: unknown) => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const [viewport] = useState(getViewportSize);
  const [section, setSection] = useState<SectionId | null>(null);

  // The pane is anchored to the full game window (skin.dmf). The shared
  // Window layout applies its own centered geometry asynchronously, so the
  // pane is pinned back to the top-left corner several times after mount.
  useEffect(() => {
    const pin = () => Byond.winset(Byond.windowId, { pos: '0,0' });
    pin();
    const timers = [200, 500, 1000, 2000].map((delay) =>
      setTimeout(pin, delay),
    );
    globalEvents.on('window-geometry-finished', pin);
    return () => {
      timers.forEach(clearTimeout);
      globalEvents.off('window-geometry-finished', pin);
    };
  }, []);

  const isHudWidget = (target: EventTarget | null) =>
    !!(target as HTMLElement | null)?.closest?.(
      '.spcp-actions, .spcp-close, .spcp-topright, .spcp-bottomleft, .spcp-bottomright, .spcp-dock, .spcp-drawer, .spcp-lamps',
    );

  const sendMapClick = (
    event: ReactMouseEvent<HTMLDivElement>,
    button: 'left' | 'right' | 'middle',
  ) => {
    act('map_click', {
      x: Math.round(event.clientX),
      y: Math.round(event.clientY),
      button,
      ctrl: event.ctrlKey || undefined,
      alt: event.altKey || undefined,
      shift: event.shiftKey || undefined,
    });
  };

  // Clicks landing on transparent HUD padding are proxied to the game map
  // underneath (DM side translates pixel coords into a turf click).
  // Right-clicks are ignored here: browsers fire auxclick for them too,
  // but they are already proxied from mousedown.
  const proxyClick = (event: ReactMouseEvent<HTMLDivElement>) => {
    if (event.button === 2 || isHudWidget(event.target)) {
      return;
    }
    event.preventDefault();
    event.stopPropagation();
    sendMapClick(event, event.button === 1 ? 'middle' : 'left');
  };

  const lamps = buildLamps(data);

  return (
    <Window
      width={viewport[0]}
      height={viewport[1]}
      titleBar={false}
      transparent
    >
      <Window.Content fitted scrollable className="spcp-root">
        <div
          className="spcp-shell"
          onClick={proxyClick}
          onAuxClick={proxyClick}
          // Right-clicks are proxied from mousedown: the engine can swallow
          // the context menu event itself, so it is not a reliable trigger.
          onMouseDown={(event) => {
            event.stopPropagation();
            if (isHudWidget(event.target) || event.button !== 2) {
              return;
            }
            event.preventDefault();
            sendMapClick(event, 'right');
          }}
          onContextMenu={(event) => event.preventDefault()}
          onDragStart={(event) => {
            event.preventDefault();
            event.stopPropagation();
          }}
        >
          <div className="spcp-hud">
            <div className="spcp-actions">
              <button
                className="spcp-close"
                onClick={suspendStart}
                title="Закрыть интерфейс и вернуться в игру"
              >
                <Icon name="times" className="spcp-close__icon" />
                <span className="spcp-close__label">Закрыть интерфейс</span>
              </button>
              <button
                className="spcp-close spcp-close--exit"
                onClick={() => act('exit_pod')}
                title="Выйти из челнока"
              >
                <Icon name="sign-out-alt" className="spcp-close__icon" />
                <span className="spcp-close__label">Выйти из челнока</span>
              </button>
            </div>
            {!!data.weapons.module && (
              <div className="spcp-topright">
                <WeaponsWidget />
              </div>
            )}
            <div className="spcp-bottomleft">
              <ResourceReadouts />
            </div>
            <div className="spcp-bottomright">
              <MainReadouts />
            </div>
            <div className="spcp-lamps">
              {lamps.map((lamp) => (
                <LampBox key={lamp.label} {...lamp} />
              ))}
            </div>
            <div className="spcp-dock">
              {SECTIONS.map((meta) => {
                // The weapons section only makes sense with the module.
                if (meta.id === 'weapons' && !data.weapons.module) {
                  return null;
                }
                return (
                  <Tooltip key={meta.id} content={meta.label}>
                    <button
                      className={`spcp-dock__btn${
                        section === meta.id ? ' is-active' : ''
                      }`}
                      onClick={() =>
                        setSection(section === meta.id ? null : meta.id)
                      }
                    >
                      <Icon name={meta.icon} size={2} />
                    </button>
                  </Tooltip>
                );
              })}
            </div>
            <Drawer section={section} onClose={() => setSection(null)} />
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};

// MARK: Status lamps

type StatusLamp = {
  label: string;
  state: LampState;
  tooltip: string;
};

const buildLamps = (data: SpacepodControlPanelData): StatusLamp[] => {
  const { electricity, engines, fuel, integrity } = data;
  const batteryPercent = electricity.percent ?? 0;
  const engineFault = engines.engines.some(
    (engine) => engine.error_text || engine.rpm_warn,
  );
  const fuelLow = fuel.fuel_tanks.some((tank) => tank.level_percent < 20);
  const fire = integrity.modules.some((module) => module.fire);

  return [
    {
      label: 'БАТАРЕЯ',
      state: !electricity.exists ? 'bad' : batteryPercent < 25 ? 'warn' : 'ok',
      tooltip: electricity.exists
        ? `Заряд батареи: ${batteryPercent}%`
        : 'Аккумулятор отсутствует',
    },
    {
      label: 'ДВИГАТЕЛИ',
      state: !engines.engines.length ? 'off' : engineFault ? 'warn' : 'ok',
      tooltip: engines.engines.length
        ? engineFault
          ? 'Есть неисправность двигателя'
          : 'Двигатели в норме'
        : 'Двигатели не установлены',
    },
    {
      label: 'ТОПЛИВО',
      state: !fuel.fuel_tanks.length ? 'bad' : fuelLow ? 'warn' : 'ok',
      tooltip: !fuel.fuel_tanks.length
        ? 'Топливные баки не установлены'
        : fuelLow
          ? 'Низкий уровень топлива'
          : 'Топливная система в норме',
    },
    {
      label: 'ПОЖАР',
      state: fire ? 'bad' : 'off',
      tooltip: fire ? 'На борту пожар!' : 'Пожаров нет',
    },
    {
      label: 'КОРПУС',
      state: integrity.hull.integrity_warn ? 'bad' : 'ok',
      tooltip: `Прочность корпуса: ${integrity.hull.integrity}/${integrity.hull.max_integrity}`,
    },
  ];
};

const LampBox = (props: {
  label: string;
  state: LampState;
  tooltip: string;
}) => {
  const { label, state, tooltip } = props;
  return (
    <Tooltip content={tooltip}>
      <div className={`spcp-lampbox spcp-lampbox--${state}`}>{label}</div>
    </Tooltip>
  );
};

// MARK: Engine gauges (bottom-right)

const MainReadouts = () => {
  const booted = true;
  const { data } = useBackend<SpacepodControlPanelData>();
  const { engines } = data;

  return (
    <div className="spcp-cluster">
      {!!engines.engines.length && (
        <div className="spcp-gauges">
          {engines.engines.map((engine) => (
            <div
              className={`spcp-gaugewrap${
                engine.is_apu ? ' spcp-gaugewrap--apu' : ''
              }${engine.error_text ? ' spcp-gaugewrap--fault' : ''}`}
              key={engine.id}
            >
              <Gauge
                value={engine.rpm_percent}
                max={100}
                label="RPM"
                readout={`${engine.rpm}`}
                unit={engine.is_apu ? undefined : 'об/м'}
                danger={[105, 120]}
                warn={engine.rpm_warn || !!engine.error_text}
                booted={booted}
                size={engine.is_apu ? 52 : 100}
              />
              <span className="spcp-gaugewrap__caption">{engine.caption}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

// MARK: Battery and fuel levels (bottom-left)

const BATT_SEGMENTS = 10;

const ResourceReadouts = () => {
  const booted = true;
  const { data } = useBackend<SpacepodControlPanelData>();
  const { electricity, fuel } = data;
  const batteryPercent = electricity.percent ?? 0;

  return (
    <div className="spcp-cluster">
      {electricity.exists && (
        <div
          className={`spcp-batt${batteryPercent < 25 ? ' spcp-batt--warn' : ''}`}
        >
          <span className="spcp-batt__label">АКБ</span>
          <span className="spcp-batt__segments">
            {Array.from({ length: BATT_SEGMENTS }, (_, index) => (
              <i
                key={index}
                className={
                  index < Math.round((batteryPercent / 100) * BATT_SEGMENTS)
                    ? 'is-on'
                    : ''
                }
              />
            ))}
          </span>
          <b className="spcp-batt__value">{Math.round(batteryPercent)}%</b>
        </div>
      )}
      {!!fuel.fuel_tanks.length && (
        <div className="spcp-fuel">
          {fuel.fuel_tanks.map((tank) => (
            <div className="spcp-gaugewrap" key={tank.id}>
              <Gauge
                value={tank.level_percent}
                max={100}
                label="FUEL"
                readout={`${tank.fuel_amount}`}
                unit="л"
                warn={tank.level_percent < 20}
                booted={booted}
                size={48}
              />
              <span className="spcp-gaugewrap__caption">{tank.caption}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

// MARK: Weapons readouts (top-right)

const WeaponsWidget = () => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { weapons } = data;

  if (!weapons.module) {
    return null;
  }
  const module = weapons.module;

  return (
    <div className="spcp-weapons">
      <div className="spcp-weapons__head">
        <Icon name="crosshairs" />
        <span className="spcp-weapons__name" title={module.name}>
          {module.name}
        </span>
        <b
          className={`spcp-weapons__state ${
            module.enable ? 'is-online' : 'is-offline'
          }`}
        >
          {module.enable ? 'ONLINE' : 'OFFLINE'}
        </b>
      </div>
      {!!module.error_text && (
        <div className="spcp-error">{module.error_text}</div>
      )}
      {weapons.guns.map((gun) => (
        <div className="spcp-gun" key={gun.id}>
          <div className="spcp-gun__info">
            <span className="spcp-gun__slot">
              {gun.primary ? 'ОСН' : 'ДОП'}
            </span>
            <div
              className={`spcp-ammo${
                gun.capacity > 0 && gun.ammo === 0 ? ' spcp-ammo--empty' : ''
              }`}
              title={gun.name}
            >
              <b>{String(Math.max(0, gun.ammo)).padStart(2, '0')}</b>
              <span className="spcp-ammo__cap">/{gun.capacity}</span>
            </div>
          </div>
          <div className="spcp-gun__actions">
            <Switch
              caption="ПРЕД"
              on={gun.safety}
              onClick={() => act('toggle_weapon_safety', { id: gun.id })}
              tooltip={
                gun.safety
                  ? 'Предохранитель включён'
                  : 'Оружие готово к стрельбе'
              }
            />
            <Switch
              caption={gun.type === 2 ? 'ЗАРЯД' : 'ПЕРЕЗ'}
              on={gun.type === 2 ? gun.charging : false}
              failure={gun.type !== 2 && gun.capacity > 0 && gun.ammo === 0}
              onClick={() => act('reload_weapon', { id: gun.id })}
              tooltip={gun.type === 2 ? 'Зарядить батарею' : 'Перезарядить'}
            />
          </div>
        </div>
      ))}
    </div>
  );
};

// MARK: Drawer

const Drawer = (props: { section: SectionId | null; onClose: () => void }) => {
  const { section, onClose } = props;
  const meta = section
    ? SECTIONS.find((candidate) => candidate.id === section)
    : null;

  return (
    <div className={`spcp-drawer${section ? ' spcp-drawer--open' : ''}`}>
      {meta && (
        <>
          <div className="spcp-drawer__head">
            <Icon name={meta.icon} />
            <span>{meta.label}</span>
            <button
              className="spcp-drawer__close"
              onClick={onClose}
              title="Скрыть панель"
            >
              <Icon name="chevron-left" />
            </button>
          </div>
          <div className="spcp-drawer__body">
            {section === 'power' && <PowerSection />}
            {section === 'fuel' && <FuelSection />}
            {section === 'engines' && <EnginesSection />}
            {section === 'systems' && <SystemsSection />}
            {section === 'integrity' && <IntegritySection />}
            {section === 'weapons' && <WeaponsSection />}
          </div>
        </>
      )}
    </div>
  );
};

const SectionTitle = (props: { children: ReactNode }) => (
  <div className="spcp-sec__title">{props.children}</div>
);

// MARK: Gauge

const polar = (angle: number, radius: number): [number, number] => {
  const radians = ((angle - 90) * Math.PI) / 180;
  return [60 + radius * Math.cos(radians), 60 + radius * Math.sin(radians)];
};

const describeArc = (from: number, to: number, radius: number) => {
  const [x1, y1] = polar(from, radius);
  const [x2, y2] = polar(to, radius);
  const largeArc = Math.abs(to - from) > 180 ? 1 : 0;
  return `M ${x1} ${y1} A ${radius} ${radius} 0 ${largeArc} 1 ${x2} ${y2}`;
};

type GaugeProps = {
  value: number;
  max?: number;
  label?: string;
  readout: string;
  unit?: string;
  danger?: [number, number];
  warn?: boolean;
  booted?: boolean;
  size?: number;
  ticks?: number;
  /** Start angle of the scale, degrees (default: -135). */
  start?: number;
  /** Sweep of the scale, degrees (default: 270). */
  sweep?: number;
  /** Crops the svg, e.g. `"0 8 120 58"` for a semicircle gauge. */
  viewBox?: string;
  /** Marks the needle pivot explicitly for cropped viewBoxes. */
  half?: boolean;
};

const Gauge = (props: GaugeProps) => {
  const {
    value,
    max = 100,
    label,
    readout,
    unit,
    danger,
    warn,
    booted = true,
    size = 104,
    ticks = 12,
    start = -135,
    sweep = 270,
    viewBox = '0 0 120 120',
    half,
  } = props;

  const percent = booted ? percentOf(value, max) : 0;
  const needleAngle = start + (sweep * percent) / 100;

  const tickMarks: ReactElement[] = [];
  for (let index = 0; index <= ticks; index++) {
    const angle = start + (sweep * index) / ticks;
    const major = index % 2 === 0;
    const [x1, y1] = polar(angle, major ? 36 : 39);
    const [x2, y2] = polar(angle, 43);
    tickMarks.push(
      <line
        key={index}
        x1={x1}
        y1={y1}
        x2={x2}
        y2={y2}
        className={
          major
            ? 'spcp-gauge__tick spcp-gauge__tick--major'
            : 'spcp-gauge__tick'
        }
      />,
    );
  }

  return (
    <div
      className={`spcp-gauge${warn ? ' spcp-gauge--warn' : ''}${
        half ? ' spcp-gauge--half' : ''
      }`}
      style={{ width: `${size}px` }}
    >
      <svg viewBox={viewBox} className="spcp-gauge__svg">
        <circle cx="60" cy="60" r="57" className="spcp-gauge__rim" />
        <path
          d={describeArc(start, start + sweep, 46)}
          className="spcp-gauge__track"
        />
        {danger && (
          <path
            d={describeArc(
              start + (sweep * clampPercent((danger[0] / max) * 100)) / 100,
              start + (sweep * clampPercent((danger[1] / max) * 100)) / 100,
              46,
            )}
            className="spcp-gauge__danger"
          />
        )}
        {percent > 0.4 && (
          <path
            d={describeArc(start, needleAngle, 46)}
            className="spcp-gauge__fill"
          />
        )}
        {tickMarks}
        {!!label && (
          <text x="60" y="93" textAnchor="middle" className="spcp-gauge__label">
            {label}
          </text>
        )}
        <g
          className="spcp-gauge__needle"
          style={{ transform: `rotate(${needleAngle}deg)` }}
        >
          <line
            x1="60"
            y1="60"
            x2="60"
            y2="24"
            className="spcp-gauge__needle-line"
          />
          <circle cx="60" cy="60" r="5" className="spcp-gauge__hub" />
        </g>
      </svg>
      <div className="spcp-gauge__readout">
        {readout}
        {unit ? <span className="spcp-gauge__unit">{unit}</span> : null}
      </div>
    </div>
  );
};

// MARK: Level bar

const LevelBar = (props: {
  value: number;
  max?: number;
  label?: string;
  readout?: string;
  warn?: boolean;
  dangerBelow?: number;
  booted?: boolean;
}) => {
  const {
    value,
    max = 100,
    label,
    readout,
    warn,
    dangerBelow = 0,
    booted = true,
  } = props;
  const percent = booted ? percentOf(value, max) : 0;

  return (
    <div className={`spcp-level${warn ? ' spcp-level--warn' : ''}`}>
      {(label || readout) && (
        <div className="spcp-level__head">
          <span>{label}</span>
          <b>{readout}</b>
        </div>
      )}
      <div className="spcp-level__track">
        {dangerBelow > 0 && (
          <div
            className="spcp-level__danger"
            style={{ width: `${clampPercent(dangerBelow)}%` }}
          />
        )}
        <div className="spcp-level__fill" style={{ width: `${percent}%` }} />
      </div>
    </div>
  );
};

// MARK: Switches

type SwitchProps = {
  caption: string;
  on: boolean;
  onClick: () => void;
  tooltip?: string;
  failure?: boolean;
  disabled?: boolean;
  /** Overrides the automatic on/off/fail image. */
  image?: string;
};

const Switch = (props: SwitchProps) => {
  const { caption, on, onClick, tooltip, failure, disabled, image } = props;
  const resolvedImage = image
    ? image
    : failure
      ? 'eng-fail.png'
      : on
        ? 'eng-on.png'
        : 'eng-off-top.png';
  const body = (
    <div
      className={`spcp-switch${on ? ' spcp-switch--on' : ''}${
        failure ? ' spcp-switch--failure' : ''
      }${disabled ? ' spcp-switch--disabled' : ''}`}
      onClick={disabled ? undefined : onClick}
    >
      {!!caption && <span className="spcp-switch__caption">{caption}</span>}
      <Image
        className="spcp-switch__image"
        src={resolveAsset(resolvedImage)}
        draggable={false}
      />
      <span
        className={`spcp-lamp ${
          failure ? 'spcp-lamp--bad' : on ? 'spcp-lamp--ok' : 'spcp-lamp--off'
        }`}
      />
    </div>
  );
  return tooltip ? <Tooltip content={tooltip}>{body}</Tooltip> : body;
};

const EngineStart = (props: {
  caption: string;
  on: boolean;
  failure: boolean;
  cranking: boolean;
  onClick: () => void;
  tooltip?: string;
}) => {
  const { caption, on, failure, cranking, onClick, tooltip } = props;
  const image = failure ? 'eng-fail.png' : on ? 'eng-on.png' : 'eng-off.png';
  const body = (
    <div
      className={`spcp-switch spcp-switch--start${on ? ' spcp-switch--on' : ''}${
        failure ? ' spcp-switch--failure' : ''
      }${cranking ? ' spcp-switch--cranking' : ''}`}
      onClick={onClick}
    >
      <span className="spcp-switch__caption">
        {cranking ? 'CRANK' : caption}
      </span>
      {cranking && <span className="spcp-switch__ring" />}
      <Image
        className="spcp-switch__image"
        src={resolveAsset(image)}
        draggable={false}
      />
      <span className="spcp-switch__state">{cranking ? 'IGNITE' : ''}</span>
    </div>
  );
  return tooltip ? <Tooltip content={tooltip}>{body}</Tooltip> : body;
};

// MARK: Section — Power

const PowerSection = () => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { electricity } = data;

  return (
    <>
      <SectionTitle>Аккумулятор</SectionTitle>
      {electricity.exists ? (
        <>
          <LevelBar
            label="ЗАРЯД"
            value={electricity.percent ?? 0}
            max={100}
            readout={`${Math.round(electricity.percent ?? 0)}%`}
            warn={(electricity.percent ?? 0) < 25}
            dangerBelow={25}
          />
          <div className="spcp-readouts spcp-readouts--dense">
            <div className="spcp-readout">
              <span>ЗАРЯД</span>
              <b>{electricity.power ?? 0} Вт</b>
            </div>
            <div className="spcp-readout">
              <span>ЕМКОСТЬ</span>
              <b>{electricity.capacity ?? 0} Вт·ч</b>
            </div>
            <div className="spcp-readout">
              <span>ШИНА</span>
              <b className={electricity.link ? 'is-ok' : 'is-off'}>
                {electricity.link ? 'ПОДКЛЮЧЕНА' : 'ОТКЛЮЧЕНА'}
              </b>
            </div>
          </div>
        </>
      ) : (
        <div className="spcp-empty">АККУМУЛЯТОР НЕ УСТАНОВЛЕН</div>
      )}
      <SectionTitle>Шина питания</SectionTitle>
      <div className="spcp-row">
        <Switch
          caption="MAIN"
          on={!!electricity.link}
          disabled={!electricity.battery_id}
          onClick={() =>
            act('switch_powernet_link', { id: electricity.battery_id })
          }
          tooltip="Главная шина питания"
        />
        {electricity.consumers.map((consumer) => (
          <Switch
            key={consumer.id}
            caption={consumer.caption}
            on={consumer.link}
            onClick={() => act('switch_powernet_link', { id: consumer.id })}
            tooltip={`${consumer.name}: ${
              consumer.link ? 'подключено' : 'отключено'
            }`}
          />
        ))}
      </div>
    </>
  );
};

// MARK: Section — Fuel

const FuelSection = () => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { fuel } = data;

  return (
    <>
      <SectionTitle>Баки</SectionTitle>
      {fuel.fuel_tanks.length ? (
        fuel.fuel_tanks.map((tank) => (
          <div className="spcp-tank" key={tank.id}>
            <LevelBar
              label={tank.caption}
              value={tank.level_percent}
              max={100}
              readout={`${tank.fuel_amount}/${tank.fuel_capacity} л`}
              warn={tank.level_percent < 20}
              dangerBelow={20}
            />
            <span className="spcp-tank__name">{tank.name}</span>
          </div>
        ))
      ) : (
        <div className="spcp-empty">БАКИ НЕ УСТАНОВЛЕНЫ</div>
      )}
      <SectionTitle>Топливные насосы</SectionTitle>
      {fuel.fuel_pumps.length ? (
        <div className="spcp-row">
          {fuel.fuel_pumps.map((pump) => (
            <Switch
              key={pump.id}
              caption={pump.caption}
              on={pump.enable}
              failure={pump.error_text !== null}
              onClick={() => act('switch_enable', { id: pump.id })}
              tooltip={`${pump.name}: ${
                pump.enable ? `${pump.pump_speed} л/с` : 'остановлен'
              }`}
            />
          ))}
        </div>
      ) : (
        <div className="spcp-empty">НАСОСОВ НЕТ</div>
      )}
    </>
  );
};

// MARK: Section — Engines

const EnginesSection = () => {
  const booted = true;
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { engines } = data;
  const [starting, setStarting] = useState<Record<string, number>>({});

  useEffect(() => {
    if (!Object.keys(starting).length) {
      return;
    }
    const timer = setInterval(() => {
      const now = Date.now();
      setStarting((prev) => {
        const next: Record<string, number> = {};
        let changed = false;
        for (const key of Object.keys(prev)) {
          if (prev[key] > now) {
            next[key] = prev[key];
          } else {
            changed = true;
          }
        }
        return changed ? next : prev;
      });
    }, 250);
    return () => clearInterval(timer);
  }, [starting]);

  const toggleEngine = (engine: EngineData) => {
    if ((starting[engine.id] ?? 0) > Date.now()) {
      return;
    }
    if (!engine.enable) {
      setStarting((prev) => ({
        ...prev,
        [engine.id]: Date.now() + (engine.is_apu ? 1300 : 3300),
      }));
    }
    act('ignite_engine', { id: engine.id });
  };

  return (
    <>
      <SectionTitle>Силовая установка</SectionTitle>
      {engines.engines.length ? (
        engines.engines.map((engine) => {
          const cranking = (starting[engine.id] ?? 0) > Date.now();
          return (
            <div
              className={`spcp-engine${engine.enable ? ' spcp-engine--running' : ''}${
                engine.error_text ? ' spcp-engine--fault' : ''
              }${cranking ? ' spcp-engine--cranking' : ''}`}
              key={engine.id}
            >
              <div className="spcp-engine__head">
                <b className="spcp-engine__caption">{engine.caption}</b>
                <span
                  className={`spcp-lamp ${
                    engine.error_text
                      ? 'spcp-lamp--bad'
                      : engine.enable
                        ? 'spcp-lamp--ok'
                        : 'spcp-lamp--off'
                  }`}
                />
                <span className="spcp-engine__name" title={engine.name}>
                  {engine.name}
                </span>
              </div>
              <div className="spcp-engine__body">
                <Gauge
                  value={engine.rpm_percent}
                  max={100}
                  label="RPM"
                  readout={`${engine.rpm}`}
                  unit="об/м"
                  danger={[105, 120]}
                  warn={engine.rpm_warn}
                  booted={booted}
                  size={88}
                />
                <div className="spcp-engine__side">
                  <LevelBar
                    label="FUEL"
                    value={engine.fuel_pressure}
                    max={100}
                    readout={`${engine.fuel_pressure}%`}
                    warn={engine.fuel_pressure_warn}
                    dangerBelow={30}
                    booted={booted}
                  />
                  <div className="spcp-readouts spcp-readouts--dense">
                    <div className="spcp-readout">
                      <span>TEMP</span>
                      <b
                        className={
                          engine.temperature_warn ? 'is-bad' : undefined
                        }
                      >
                        {engine.temperature}°C
                      </b>
                    </div>
                    <div className="spcp-readout">
                      <span>GEN</span>
                      <b
                        className={engine.generator_enable ? 'is-ok' : 'is-off'}
                      >
                        {engine.generated_power} Вт
                      </b>
                    </div>
                  </div>
                  {engine.rpm_provide_engines && (
                    <div className="spcp-torque">
                      <span>КРУТЯЩИЙ МОМЕНТ</span>
                      <Dropdown
                        fluid
                        options={engine.rpm_provide_engines}
                        selected={
                          engine.selected_rpm_provide_engine ??
                          engine.rpm_provide_engines[0]
                        }
                        onSelected={(value) =>
                          act('select_rpm_provider', {
                            id: engine.id,
                            destination: value,
                          })
                        }
                      />
                    </div>
                  )}
                </div>
              </div>
              {!!engine.error_text && (
                <div className="spcp-error">{engine.error_text}</div>
              )}
              <div className="spcp-engine__foot">
                <Switch
                  caption="GEN"
                  on={engine.generator_enable}
                  onClick={() =>
                    act('switch_generator_enable', { id: engine.id })
                  }
                  tooltip="Генератор двигателя"
                />
                <Switch
                  caption="BUS"
                  on={!!engine.power_link}
                  disabled={engine.power_link === null}
                  onClick={() => act('switch_powernet_link', { id: engine.id })}
                  tooltip="Подключение к электросети"
                />
                <EngineStart
                  caption={engine.is_apu ? 'APU' : 'START'}
                  on={engine.enable}
                  failure={!!engine.error_text}
                  cranking={cranking}
                  onClick={() => toggleEngine(engine)}
                  tooltip={
                    engine.enable
                      ? 'Остановить'
                      : engine.is_apu
                        ? 'Запустить вспомогательную установку'
                        : 'Запустить двигатель от APU'
                  }
                />
              </div>
            </div>
          );
        })
      ) : (
        <div className="spcp-empty">ДВИГАТЕЛИ НЕ УСТАНОВЛЕНЫ</div>
      )}
      <SectionTitle>Гироскопический стабилизатор</SectionTitle>
      {engines.gyroscope ? (
        <div className="spcp-gyro">
          <div className="spcp-readouts spcp-readouts--dense">
            <div className="spcp-readout">
              <span>ОБОРОТЫ</span>
              <b className={engines.gyroscope.rpm_warn ? 'is-bad' : undefined}>
                {engines.gyroscope.rpm} об/м
              </b>
            </div>
            <div className="spcp-readout">
              <span>ТЕМПЕРАТУРА</span>
              <b
                className={
                  engines.gyroscope.temperature_warn ? 'is-bad' : undefined
                }
              >
                {engines.gyroscope.temperature}°C
              </b>
            </div>
            <div className="spcp-readout">
              <span>ПИТАНИЕ</span>
              <b className={engines.gyroscope.power_link ? 'is-ok' : 'is-bad'}>
                {engines.gyroscope.power_link ? 'НОРМА' : 'НЕТ'}
              </b>
            </div>
          </div>
          <Switch
            caption="GYRO"
            on={engines.gyroscope.enable}
            failure={!!engines.gyroscope.error_text}
            onClick={() => act('switch_enable', { id: engines.gyroscope?.id })}
            tooltip={engines.gyroscope.name}
          />
          {!!engines.gyroscope.error_text && (
            <div className="spcp-error">{engines.gyroscope.error_text}</div>
          )}
        </div>
      ) : (
        <div className="spcp-empty">ГИРОСКОП НЕ УСТАНОВЛЕН</div>
      )}
    </>
  );
};

// MARK: Section — Systems

const SystemsSection = () => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { life_support, misc } = data;

  const pressureKpa = life_support.exists
    ? asNumber(life_support.atmos.pressure) / 1000
    : 0;
  const temperatureC = life_support.exists
    ? asNumber(life_support.atmos.temperature) - 273.15
    : 0;
  const airtank = life_support.airtank;

  return (
    <>
      <SectionTitle>Жизнеобеспечение</SectionTitle>
      {life_support.exists ? (
        <>
          <div className="spcp-readouts spcp-readouts--dense">
            <div className="spcp-readout">
              <span>ДАВЛЕНИЕ КАБИНЫ</span>
              <b
                className={
                  life_support.atmos.low_pressure ? 'is-bad' : undefined
                }
              >
                {pressureKpa.toFixed(1)} кПа
              </b>
            </div>
            <div className="spcp-readout">
              <span>ТЕМПЕРАТУРА КАБИНЫ</span>
              <b
                className={
                  life_support.atmos.low_temperature ? 'is-bad' : undefined
                }
              >
                {temperatureC.toFixed(1)} °C
              </b>
            </div>
          </div>
          <div className="spcp-air__tank">
            <div className="spcp-readouts spcp-readouts--dense">
              <div className="spcp-readout">
                <span>БАЛЛОН</span>
                <b className={airtank ? undefined : 'is-bad'}>
                  {airtank ? airtank.name : 'ОТСУТСТВУЕТ'}
                </b>
              </div>
              {airtank && (
                <>
                  <div className="spcp-readout">
                    <span>ОБЪЁМ</span>
                    <b>{airtank.volume} л</b>
                  </div>
                  <div className="spcp-readout">
                    <span>ДАВЛЕНИЕ</span>
                    <b className={airtank.low_pressure ? 'is-bad' : 'is-ok'}>
                      {(asNumber(airtank.pressure) / 1000).toFixed(1)} кПа
                    </b>
                  </div>
                </>
              )}
            </div>
            <Switch
              caption="AIR"
              on={!!airtank?.enable}
              disabled={!airtank}
              failure={!airtank}
              onClick={() => act('switch_airtank')}
              tooltip="Подача кислорода из баллона"
            />
          </div>
        </>
      ) : (
        <div className="spcp-empty">СИСТЕМА НЕ УСТАНОВЛЕНА</div>
      )}
      <SectionTitle>Прочие системы</SectionTitle>
      {misc.key_lock || misc.tracker || misc.catapult ? (
        <div className="spcp-syscards">
          {misc.key_lock && (
            <div className="spcp-syscard">
              <span>ЗАМОК</span>
              <Switch
                caption="LOCK"
                on={misc.key_lock.locked}
                onClick={() => act('toggle_lock')}
                tooltip={misc.key_lock.locked ? 'Замок закрыт' : 'Замок открыт'}
              />
            </div>
          )}
          {misc.tracker && (
            <div className="spcp-syscard">
              <span>МАЯЧОК</span>
              <Switch
                caption="GPS"
                on={misc.tracker.enable}
                onClick={() => act('switch_enable', { id: misc.tracker?.id })}
                tooltip={
                  misc.tracker.enable ? 'Маячок включён' : 'Маячок выключен'
                }
              />
            </div>
          )}
          {misc.catapult && (
            <div className="spcp-syscard">
              <span>АВТОКАТАПУЛЬТ</span>
              <Switch
                caption="AUTO"
                on={misc.catapult.enable}
                onClick={() => act('switch_enable', { id: misc.catapult?.id })}
                tooltip="Автоматическое катапультирование"
              />
            </div>
          )}
          {misc.catapult && (
            <div className="spcp-syscard">
              <span>КАТАПУЛЬТ</span>
              <Switch
                caption="MANUAL"
                image="eng-idle.png"
                on={false}
                onClick={() => act('catapult_pilot')}
                tooltip="Катапультировать пилота"
              />
            </div>
          )}
        </div>
      ) : (
        <div className="spcp-empty">ДОПОЛНИТЕЛЬНЫХ МОДУЛЕЙ НЕТ</div>
      )}
    </>
  );
};

// MARK: Section — Integrity

const IntegritySection = () => {
  const booted = true;
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { integrity } = data;
  const { hull } = integrity;

  return (
    <>
      <SectionTitle>
        Корпус{` · ОГНЕТУШИТЕЛЬ: ${hull.extenguish_charges}`}
      </SectionTitle>
      <div className="spcp-hull">
        <LevelBar
          label="КОРПУС"
          value={hull.integrity}
          max={hull.max_integrity}
          readout={`${hull.integrity}/${hull.max_integrity}`}
          warn={hull.integrity_warn}
          dangerBelow={25}
          booted={booted}
        />
      </div>
      <SectionTitle>Модули</SectionTitle>
      {integrity.modules.length ? (
        <div className="spcp-modules">
          {integrity.modules.map((module) => (
            <div
              className={`spcp-module${module.fire ? ' spcp-module--fire' : ''}`}
              key={module.id}
            >
              <span className="spcp-module__caption" title={module.name}>
                {module.caption}
              </span>
              <LevelBar
                value={module.integrity}
                max={module.max_integrity}
                dangerBelow={50}
                warn={module.integrity_warn}
                booted={booted}
              />
              <b
                className={`spcp-module__value ${
                  module.integrity <= 0
                    ? 'is-bad'
                    : module.integrity_warn
                      ? 'is-warn'
                      : 'is-ok'
                }`}
              >
                {module.integrity > 0
                  ? `${module.integrity}/${module.max_integrity}`
                  : 'УНИЧТОЖЕН'}
              </b>
              {module.fire ? (
                <Button
                  compact
                  color="bad"
                  icon="fire-extinguisher"
                  disabled={hull.extenguish_charges <= 0}
                  onClick={() => act('extinguish', { id: module.id })}
                >
                  ТУШИТЬ
                </Button>
              ) : (
                ''
              )}
            </div>
          ))}
        </div>
      ) : (
        <div className="spcp-empty">МОДУЛЕЙ НЕТ</div>
      )}
    </>
  );
};

// MARK: Section — Weapons

const WeaponsSection = () => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { weapons } = data;

  if (!weapons.module) {
    return null;
  }
  const module = weapons.module;

  return (
    <>
      <SectionTitle>Модуль вооружения</SectionTitle>
      <div className="spcp-weaponhead">
        <span title={module.name}>{module.name}</span>
        <Switch
          caption="PWR"
          on={module.enable}
          failure={!!module.error_text}
          onClick={() => act('switch_enable', { id: module.id })}
          tooltip="Питание вооружения"
        />
      </div>
      {!!module.error_text && (
        <div className="spcp-error">{module.error_text}</div>
      )}
      {weapons.guns.length ? (
        weapons.guns.map((gun) => (
          <div className="spcp-guncard" key={gun.id}>
            <div className="spcp-guncard__head">
              <b>{gun.primary ? 'PRIMARY' : 'SECONDARY'}</b>
              <span title={gun.name}>{gun.name}</span>
              <em>
                {gun.type === 1
                  ? 'БАЛЛИСТИЧЕСКОЕ'
                  : gun.type === 2
                    ? 'ЭНЕРГЕТИЧЕСКОЕ'
                    : 'НЕИЗВЕСТНО'}
              </em>
            </div>
            <LevelBar
              label="AMMO"
              value={gun.ammo}
              max={gun.capacity > 0 ? gun.capacity : 1}
              readout={`${gun.ammo}/${gun.capacity}`}
              warn={gun.capacity > 0 && gun.ammo === 0}
              dangerBelow={25}
            />
            <div className="spcp-gun__actions">
              <Switch
                caption="ПРЕД"
                on={gun.safety}
                onClick={() => act('toggle_weapon_safety', { id: gun.id })}
                tooltip={
                  gun.safety
                    ? 'Предохранитель включён'
                    : 'Оружие готово к стрельбе'
                }
              />
              <Switch
                caption={gun.type === 2 ? 'ЗАРЯД' : 'ПЕРЕЗ'}
                on={gun.type === 2 ? gun.charging : false}
                failure={gun.type !== 2 && gun.capacity > 0 && gun.ammo === 0}
                onClick={() => act('reload_weapon', { id: gun.id })}
                tooltip={gun.type === 2 ? 'Зарядить батарею' : 'Перезарядить'}
              />
            </div>
          </div>
        ))
      ) : (
        <div className="spcp-empty">ОРУДИЯ НЕ УСТАНОВЛЕНЫ</div>
      )}
    </>
  );
};
