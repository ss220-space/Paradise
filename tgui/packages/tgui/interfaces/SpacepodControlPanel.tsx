import { type ReactElement, type ReactNode, useEffect, useState } from 'react';
import { Button, Dropdown, Icon, Image, Tooltip } from 'tgui-core/components';
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

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

const useClock = () => {
  const [now, setNow] = useState(() => new Date());
  useEffect(() => {
    const timer = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);
  return now.toISOString().slice(11, 19);
};

const getGunTypeName = (type: number) => {
  switch (type) {
    case 1:
      return 'БАЛЛИСТИЧЕСКОЕ';
    case 2:
      return 'ЭНЕРГЕТИЧЕСКОЕ';
    default:
      return 'НЕИЗВЕСТНО';
  }
};

type LampState = 'ok' | 'warn' | 'bad' | 'off';

type Annunciator = {
  label: string;
  state: LampState;
  tooltip: string;
};

const buildAnnunciators = (data: SpacepodControlPanelData): Annunciator[] => {
  const { electricity, engines, fuel, integrity, life_support, weapons } = data;
  const batteryPercent = electricity.percent ?? 0;
  const fuelLow = fuel.fuel_tanks.some((tank) => tank.level_percent < 20);
  const engineFault = engines.engines.some(
    (engine) => engine.error_text || engine.rpm_warn,
  );
  const gyroFault = !!engines.gyroscope?.error_text;
  const fire = integrity.modules.some((module) => module.fire);
  const airFault =
    life_support.exists &&
    (life_support.atmos.low_pressure || life_support.atmos.low_temperature);
  const gunsDry = weapons.guns.some(
    (gun) => gun.capacity > 0 && gun.ammo === 0,
  );

  return [
    {
      label: 'BATT',
      state: !electricity.exists ? 'bad' : batteryPercent < 25 ? 'warn' : 'ok',
      tooltip: electricity.exists
        ? `Заряд батареи: ${batteryPercent}%`
        : 'Аккумулятор отсутствует',
    },
    {
      label: 'FUEL',
      state: !fuel.fuel_tanks.length ? 'bad' : fuelLow ? 'warn' : 'ok',
      tooltip: !fuel.fuel_tanks.length
        ? 'Топливные баки не установлены'
        : fuelLow
          ? 'Низкий уровень топлива'
          : 'Топливная система в норме',
    },
    {
      label: 'ENG',
      state: engines.engines.length ? (engineFault ? 'warn' : 'ok') : 'off',
      tooltip: engines.engines.length
        ? engineFault
          ? 'Есть неисправность двигателя'
          : 'Двигатели в норме'
        : 'Двигатели не установлены',
    },
    {
      label: 'GYRO',
      state: !engines.gyroscope
        ? 'off'
        : gyroFault
          ? 'warn'
          : engines.gyroscope.enable
            ? 'ok'
            : 'warn',
      tooltip: !engines.gyroscope
        ? 'Гироскоп не установлен'
        : gyroFault
          ? engines.gyroscope.error_text || 'Неисправность гироскопа'
          : engines.gyroscope.enable
            ? 'Гироскоп работает'
            : 'Гироскоп выключен',
    },
    {
      label: 'AIR',
      state: !life_support.exists ? 'off' : airFault ? 'bad' : 'ok',
      tooltip: !life_support.exists
        ? 'Жизнеобеспечение не установлено'
        : airFault
          ? 'Параметры кабины вне нормы'
          : 'Параметры кабины в норме',
    },
    {
      label: 'WPN',
      state: !weapons.module ? 'off' : gunsDry ? 'warn' : 'ok',
      tooltip: !weapons.module
        ? 'Оружейный модуль не установлен'
        : gunsDry
          ? 'Один из стволов пуст'
          : 'Вооружение в норме',
    },
    {
      label: 'HULL',
      state: integrity.hull.integrity_warn ? 'bad' : 'ok',
      tooltip: `Прочность корпуса: ${integrity.hull.integrity}/${integrity.hull.max_integrity}`,
    },
    {
      label: 'FIRE',
      state: fire ? 'bad' : 'off',
      tooltip: fire ? 'На борту пожар!' : 'Пожаров нет',
    },
  ];
};

// MARK: Window

export const SpacepodControlPanel = (props: unknown) => {
  const { data } = useBackend<SpacepodControlPanelData>();
  const [booted, setBooted] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => setBooted(true), 2700);
    return () => clearTimeout(timer);
  }, []);

  const annunciators = buildAnnunciators(data);
  const cautionCount = annunciators.filter(
    (item) => item.state === 'bad' || item.state === 'warn',
  ).length;
  const masterState: LampState = annunciators.some(
    (item) => item.state === 'bad',
  )
    ? 'bad'
    : cautionCount
      ? 'warn'
      : 'ok';

  return (
    <Window
      width={1180}
      height={700}
      title="Панель управления космическим челноком"
    >
      <Window.Content scrollable>
        <ComplexModal />
        <div className="spcp-shell">
          <CockpitBoot
            active={!booted}
            annunciators={annunciators}
            vessel={data.vessel}
            onSkip={() => setBooted(true)}
          />
          <TopStrip
            annunciators={annunciators}
            masterState={masterState}
            warnings={cautionCount}
            vessel={data.vessel}
          />
          <div className="spcp-grid">
            <div className="spcp-col">
              <PowerPanel booted={booted} />
              <FuelPanel booted={booted} />
              <GyroPanel booted={booted} />
            </div>
            <div className="spcp-col">
              <EnginesPanel booted={booted} />
              <IntegrityPanel booted={booted} />
            </div>
            <div className="spcp-col">
              <LifeSupportPanel booted={booted} />
              <WeaponsPanel booted={booted} />
              <MiscPanel />
            </div>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};

// MARK: Boot sequence

type BootLine = {
  label: string;
  value: string;
  state: LampState;
};

const buildBootLines = (data: SpacepodControlPanelData): BootLine[] => {
  const { electricity, engines, fuel, integrity, life_support, weapons } = data;
  const lines: BootLine[] = [
    {
      label: 'POWER BUS',
      value: !electricity.exists
        ? 'OFFLINE'
        : `${Math.round(electricity.percent ?? 0)}% CHARGE`,
      state: !electricity.exists
        ? 'bad'
        : (electricity.percent ?? 0) < 25
          ? 'warn'
          : 'ok',
    },
    {
      label: 'FUEL SYSTEM',
      value: fuel.fuel_tanks.length
        ? `${fuel.fuel_tanks.length} TANK(S) PRESSURIZED`
        : 'NO TANKS',
      state: fuel.fuel_tanks.length ? 'ok' : 'bad',
    },
    {
      label: 'ENGINE BUS',
      value: engines.engines.length
        ? `${engines.engines.length} UNIT(S) DETECTED`
        : 'NO ENGINES',
      state: engines.engines.length ? 'ok' : 'warn',
    },
    {
      label: 'GYROSTAB',
      value: !engines.gyroscope
        ? 'NOT INSTALLED'
        : engines.gyroscope.enable
          ? 'SPINNING'
          : 'STANDBY',
      state: !engines.gyroscope
        ? 'off'
        : engines.gyroscope.enable
          ? 'ok'
          : 'warn',
    },
    {
      label: 'LIFE SUPPORT',
      value: !life_support.exists
        ? 'NOT INSTALLED'
        : life_support.airtank?.enable
          ? 'INTERNAL ATMOS'
          : 'EXTERNAL ATMOS',
      state: !life_support.exists
        ? 'off'
        : life_support.atmos.low_pressure
          ? 'warn'
          : 'ok',
    },
    {
      label: 'WEAPON BUS',
      value: !weapons.module
        ? 'NOT INSTALLED'
        : weapons.module.enable
          ? 'ARMED'
          : 'SAFE',
      state: !weapons.module ? 'off' : weapons.module.enable ? 'warn' : 'ok',
    },
    {
      label: 'HULL SENSORS',
      value: integrity.hull.integrity_warn
        ? 'DAMAGE DETECTED'
        : `${integrity.hull.integrity}/${integrity.hull.max_integrity}`,
      state: integrity.hull.integrity_warn ? 'bad' : 'ok',
    },
  ];
  return lines;
};

const CockpitBoot = (props: {
  active: boolean;
  annunciators: Annunciator[];
  vessel: string;
  onSkip: () => void;
}) => {
  const { active, annunciators, vessel, onSkip } = props;
  const { data } = useBackend<SpacepodControlPanelData>();
  const lines = buildBootLines(data);
  const faults = annunciators.filter(
    (item) => item.state === 'bad' || item.state === 'warn',
  ).length;

  return (
    <div
      className={`spcp-boot${active ? '' : ' spcp-boot--hidden'}`}
      onClick={onSkip}
    >
      <div className="spcp-boot__scan" />
      <div className="spcp-boot__inner">
        <div className="spcp-boot__header">
          <div>
            <div className="spcp-boot__title">SPACEPOD</div>
            <div className="spcp-boot__subtitle">
              AVIONICS CONTROL SYSTEM · REV 6.0
            </div>
          </div>
          <div className="spcp-boot__vessel">
            <span>VESSEL</span>
            <b>{vessel || 'UNNAMED'}</b>
          </div>
        </div>
        <div className="spcp-boot__lines">
          {lines.map((line, index) => (
            <div
              className={`spcp-boot__line spcp-boot__line--${line.state}`}
              key={line.label}
              style={{ animationDelay: `${0.2 + index * 0.13}s` }}
            >
              <span>{line.label}</span>
              <span className="spcp-boot__dots" />
              <b>{line.value}</b>
            </div>
          ))}
        </div>
        <div className="spcp-boot__progress">
          <div className="spcp-boot__progress-fill" />
        </div>
        <div
          className={`spcp-boot__summary${faults ? ' spcp-boot__summary--warn' : ''}`}
        >
          {faults ? `ВНИМАНИЕ: ${faults} СООБЩЕНИЙ` : 'ВСЕ СИСТЕМЫ В НОРМЕ'}
        </div>
        <div className="spcp-boot__hint">НАЖМИТЕ, ЧТОБЫ ПРОПУСТИТЬ</div>
      </div>
    </div>
  );
};

// MARK: Top strip

const TopStrip = (props: {
  annunciators: Annunciator[];
  masterState: LampState;
  warnings: number;
  vessel: string;
}) => {
  const { annunciators, masterState, warnings, vessel } = props;
  const clock = useClock();

  return (
    <div className="spcp-top">
      <div className="spcp-top__brand">
        <span className="spcp-top__logo">SPACEPOD</span>
        <span className="spcp-top__vessel">{vessel || 'UNNAMED'}</span>
      </div>
      <Tooltip
        content={
          warnings
            ? annunciators
                .filter((item) => item.state !== 'ok' && item.state !== 'off')
                .map((item) => `${item.label}: ${item.tooltip}`)
                .join('\n')
            : 'Все системы в норме'
        }
      >
        <div className={`spcp-master spcp-master--${masterState}`}>
          <Icon name="exclamation-triangle" />
          <span>MASTER</span>
        </div>
      </Tooltip>
      <div className="spcp-top__lamps">
        {annunciators.map((item) => (
          <Lamp
            key={item.label}
            label={item.label}
            state={item.state}
            tooltip={item.tooltip}
          />
        ))}
      </div>
      <div className="spcp-top__clock">
        <span>UTC</span>
        <b>{clock}</b>
      </div>
    </div>
  );
};

// MARK: Primitives

const Panel = (props: {
  title: string;
  hint?: string;
  children: ReactNode;
  className?: string;
}) => {
  const { title, hint, children, className } = props;
  return (
    <div className={`spcp-panel${className ? ` ${className}` : ''}`}>
      <div className="spcp-panel__head">
        <span className="spcp-panel__title">{title}</span>
        {!!hint && <span className="spcp-panel__hint">{hint}</span>}
      </div>
      {children}
    </div>
  );
};

const Lamp = (props: { label: string; state: LampState; tooltip?: string }) => {
  const { label, state, tooltip } = props;
  const body = (
    <div className={`spcp-annunciator spcp-annunciator--${state}`}>
      <span className="spcp-annunciator__led" />
      <span className="spcp-annunciator__label">{label}</span>
    </div>
  );
  return tooltip ? <Tooltip content={tooltip}>{body}</Tooltip> : body;
};

// MARK: Gauge

const GAUGE_START = -135;
const GAUGE_SWEEP = 270;

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
  label: string;
  readout: string;
  unit?: string;
  max?: number;
  danger?: [number, number];
  warn?: boolean;
  booted?: boolean;
  size?: number;
  ticks?: number;
};

const Gauge = (props: GaugeProps) => {
  const {
    value,
    label,
    readout,
    unit,
    max = 100,
    danger,
    warn,
    booted = true,
    size = 104,
    ticks = 12,
  } = props;

  const percent = booted ? percentOf(value, max) : 0;
  const needleAngle = GAUGE_START + (GAUGE_SWEEP * percent) / 100;

  const tickMarks: ReactElement[] = [];
  for (let index = 0; index <= ticks; index++) {
    const angle = GAUGE_START + (GAUGE_SWEEP * index) / ticks;
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
      className={`spcp-gauge${warn ? ' spcp-gauge--warn' : ''}`}
      style={{ width: `${size}px` }}
    >
      <svg viewBox="0 0 120 120" className="spcp-gauge__svg">
        <circle cx="60" cy="60" r="57" className="spcp-gauge__rim" />
        <path
          d={describeArc(GAUGE_START, GAUGE_START + GAUGE_SWEEP, 46)}
          className="spcp-gauge__track"
        />
        {danger && (
          <path
            d={describeArc(
              GAUGE_START +
                (GAUGE_SWEEP * clampPercent((danger[0] / max) * 100)) / 100,
              GAUGE_START +
                (GAUGE_SWEEP * clampPercent((danger[1] / max) * 100)) / 100,
              46,
            )}
            className="spcp-gauge__danger"
          />
        )}
        {percent > 0.4 && (
          <path
            d={describeArc(GAUGE_START, needleAngle, 46)}
            className="spcp-gauge__fill"
          />
        )}
        {tickMarks}
        <text x="60" y="93" textAnchor="middle" className="spcp-gauge__label">
          {label}
        </text>
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
};

const Switch = (props: SwitchProps) => {
  const { caption, on, onClick, tooltip, failure, disabled } = props;
  const image = failure
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
      <span className="spcp-switch__caption">{caption}</span>
      <Image
        className="spcp-switch__image"
        src={resolveAsset(image)}
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
      <span className="spcp-switch__state">
        {cranking ? 'ЗАПУСК…' : on ? 'РАБОТА' : 'СТОП'}
      </span>
    </div>
  );
  return tooltip ? <Tooltip content={tooltip}>{body}</Tooltip> : body;
};

// MARK: Power

const PowerPanel = (props: { booted: boolean }) => {
  const { booted } = props;
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { electricity } = data;
  const percent = electricity.percent ?? 0;

  return (
    <Panel
      title="Электропитание"
      hint={electricity.exists ? `${Math.round(percent)}%` : 'OFFLINE'}
    >
      {electricity.exists ? (
        <>
          <div className="spcp-power">
            <Gauge
              value={percent}
              max={100}
              label="BATT"
              readout={`${Math.round(percent)}`}
              unit="%"
              danger={[0, 25]}
              warn={percent < 25}
              booted={booted}
              size={112}
            />
            <div className="spcp-readouts">
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
          </div>
          <div className="spcp-switch-grid">
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
      ) : (
        <div className="spcp-empty">АККУМУЛЯТОР НЕ УСТАНОВЛЕН</div>
      )}
    </Panel>
  );
};

// MARK: Fuel

const FuelPanel = (props: { booted: boolean }) => {
  const { booted } = props;
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { fuel } = data;

  return (
    <Panel title="Топливная система" hint={`${fuel.fuel_tanks.length} БАК`}>
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
              booted={booted}
            />
            <span className="spcp-tank__name">{tank.name}</span>
          </div>
        ))
      ) : (
        <div className="spcp-empty">БАКИ НЕ УСТАНОВЛЕНЫ</div>
      )}
      {!!fuel.fuel_pumps.length && (
        <div className="spcp-switch-grid">
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
      )}
    </Panel>
  );
};

// MARK: Engines

const EnginesPanel = (props: { booted: boolean }) => {
  const { booted } = props;
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
    <Panel title="Силовая установка" hint={`${engines.engines.length} ДВИГ.`}>
      {engines.engines.length ? (
        <div className="spcp-engines">
          {engines.engines.map((engine) => {
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
                          className={
                            engine.generator_enable ? 'is-ok' : 'is-off'
                          }
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
                    onClick={() =>
                      act('switch_powernet_link', { id: engine.id })
                    }
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
          })}
        </div>
      ) : (
        <div className="spcp-empty">ДВИГАТЕЛИ НЕ УСТАНОВЛЕНЫ</div>
      )}
    </Panel>
  );
};

// MARK: Gyroscope

const GyroPanel = (props: { booted: boolean }) => {
  const { booted } = props;
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { gyroscope } = data.engines;

  return (
    <Panel
      title="Гироскопический стабилизатор"
      hint={gyroscope ? (gyroscope.enable ? 'SPIN' : 'STBY') : 'N/A'}
    >
      {gyroscope ? (
        <div className="spcp-gyro">
          <Gauge
            value={gyroscope.rpm_percent}
            max={100}
            label="GYRO"
            readout={`${gyroscope.rpm}`}
            unit="об/м"
            danger={[0, 10]}
            warn={gyroscope.rpm_warn}
            booted={booted}
            size={88}
          />
          <div className="spcp-gyro__side">
            <div className="spcp-readouts spcp-readouts--dense">
              <div className="spcp-readout">
                <span>МОЩНОСТЬ</span>
                <b>{gyroscope.rpm_percent}%</b>
              </div>
              <div className="spcp-readout">
                <span>ТЕМПЕРАТУРА</span>
                <b
                  className={gyroscope.temperature_warn ? 'is-bad' : undefined}
                >
                  {gyroscope.temperature}°C
                </b>
              </div>
              <div className="spcp-readout">
                <span>ПИТАНИЕ</span>
                <b className={gyroscope.power_link ? 'is-ok' : 'is-bad'}>
                  {gyroscope.power_link ? 'НОРМА' : 'НЕТ'}
                </b>
              </div>
            </div>
            <Switch
              caption="GYRO"
              on={gyroscope.enable}
              failure={!!gyroscope.error_text}
              onClick={() => act('switch_enable', { id: gyroscope.id })}
              tooltip={gyroscope.name}
            />
          </div>
          {!!gyroscope.error_text && (
            <div className="spcp-error">{gyroscope.error_text}</div>
          )}
        </div>
      ) : (
        <div className="spcp-empty">ГИРОСКОП НЕ УСТАНОВЛЕН</div>
      )}
    </Panel>
  );
};

// MARK: Life support

const LifeSupportPanel = (props: { booted: boolean }) => {
  const { booted } = props;
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { life_support } = data;

  if (!life_support.exists) {
    return (
      <Panel title="Жизнеобеспечение" hint="N/A">
        <div className="spcp-empty">СИСТЕМА НЕ УСТАНОВЛЕНА</div>
      </Panel>
    );
  }

  const pressureKpa = asNumber(life_support.atmos.pressure) / 1000;
  const temperatureC = asNumber(life_support.atmos.temperature) - 273.15;
  const airtank = life_support.airtank;

  return (
    <Panel
      title="Жизнеобеспечение"
      hint={airtank?.enable ? 'INTERNAL' : 'EXTERNAL'}
    >
      <div className="spcp-air">
        <Gauge
          value={pressureKpa}
          max={150}
          label="CABIN"
          readout={pressureKpa.toFixed(1)}
          unit="кПа"
          danger={[0, 25]}
          warn={life_support.atmos.low_pressure}
          booted={booted}
          size={88}
        />
        <Gauge
          value={temperatureC}
          max={60}
          label="TEMP"
          readout={temperatureC.toFixed(1)}
          unit="°C"
          danger={[45, 60]}
          warn={life_support.atmos.low_temperature}
          booted={booted}
          size={88}
        />
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
    </Panel>
  );
};

// MARK: Weapons

const WeaponsPanel = (props: { booted: boolean }) => {
  const { booted } = props;
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { weapons } = data;

  return (
    <Panel
      title="Вооружение"
      hint={weapons.module ? (weapons.module.enable ? 'ARMED' : 'SAFE') : 'N/A'}
    >
      {weapons.module ? (
        <>
          <div className="spcp-weapon-head">
            <span>{weapons.module.name}</span>
            <div className="spcp-lamps">
              <Lamp
                label="PWR"
                state={weapons.module.power_link ? 'ok' : 'bad'}
                tooltip="Питание оружейного модуля"
              />
              <Lamp
                label="BUS"
                state={weapons.module.enable ? 'ok' : 'off'}
                tooltip="Состояние оружейного модуля"
              />
            </div>
            <Switch
              caption="PWR"
              on={weapons.module.enable}
              failure={!!weapons.module.error_text}
              onClick={() => act('switch_enable', { id: weapons.module?.id })}
              tooltip="Питание вооружения"
            />
          </div>
          {!!weapons.module.error_text && (
            <div className="spcp-error">{weapons.module.error_text}</div>
          )}
          {weapons.guns.length ? (
            weapons.guns.map((gun) => (
              <div className="spcp-gun" key={gun.id}>
                <div className="spcp-gun__head">
                  <b>{gun.primary ? 'PRIMARY' : 'SECONDARY'}</b>
                  <span className="spcp-gun__name" title={gun.name}>
                    {gun.name}
                  </span>
                  <span className="spcp-gun__type">
                    {getGunTypeName(gun.type)}
                  </span>
                </div>
                <LevelBar
                  label="AMMO"
                  value={gun.ammo}
                  max={gun.capacity > 0 ? gun.capacity : 1}
                  readout={`${gun.ammo}/${gun.capacity}`}
                  warn={gun.capacity > 0 && gun.ammo === 0}
                  dangerBelow={25}
                  booted={booted}
                />
                <div className="spcp-gun__actions">
                  <Switch
                    caption="SAFE"
                    on={gun.safety}
                    onClick={() => act('toggle_weapon_safety', { id: gun.id })}
                    tooltip={
                      gun.safety
                        ? 'Предохранитель включён'
                        : 'Оружие готово к стрельбе'
                    }
                  />
                  {gun.type === 1 && (
                    <Button
                      compact
                      icon="redo"
                      fluid
                      onClick={() => act('reload_weapon', { id: gun.id })}
                    >
                      ПЕРЕЗАРЯДИТЬ
                    </Button>
                  )}
                  {gun.type === 2 && (
                    <Switch
                      caption="CHRG"
                      on={gun.charging}
                      onClick={() => act('reload_weapon', { id: gun.id })}
                      tooltip="Циклическая зарядка"
                    />
                  )}
                </div>
              </div>
            ))
          ) : (
            <div className="spcp-empty">ОРУДИЯ НЕ УСТАНОВЛЕНЫ</div>
          )}
        </>
      ) : (
        <div className="spcp-empty">ОРУЖЕЙНЫЙ МОДУЛЬ НЕ УСТАНОВЛЕН</div>
      )}
    </Panel>
  );
};

// MARK: Misc

const MiscPanel = () => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { misc } = data;

  return (
    <Panel title="Прочие системы" hint="MISC">
      <div className="spcp-misc">
        <div className="spcp-misc__cards">
          {misc.key_lock && (
            <div className="spcp-misc__card">
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
            <div className="spcp-misc__card">
              <span>GPS МАЯЧОК</span>
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
        </div>
        {misc.catapult && (
          <div className="spcp-misc__launch">
            <Switch
              caption="AUTO"
              on={misc.catapult.enable}
              onClick={() => act('switch_enable', { id: misc.catapult?.id })}
              tooltip="Автоматическое катапультирование"
            />
            <Button.Confirm
              compact
              color="bad"
              icon="rocket"
              confirmContent="ТОЧНО?"
              onClick={() => act('catapult_pilot')}
            >
              КАТАПУЛЬТ
            </Button.Confirm>
          </div>
        )}
      </div>
      {!misc.key_lock && !misc.tracker && !misc.catapult && (
        <div className="spcp-empty">ДОПОЛНИТЕЛЬНЫХ МОДУЛЕЙ НЕТ</div>
      )}
    </Panel>
  );
};

// MARK: Integrity

const IntegrityPanel = (props: { booted: boolean }) => {
  const { booted } = props;
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { integrity } = data;
  const { hull } = integrity;

  return (
    <Panel title="Живучесть" hint={`ОГНЕТУШИТЕЛЬ: ${hull.extenguish_charges}`}>
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
        <div className="spcp-lamps">
          <Lamp
            label="HULL"
            state={hull.integrity_warn ? 'bad' : 'ok'}
            tooltip="Целостность корпуса"
          />
          <Lamp
            label="EXT"
            state={hull.extenguish_charges > 0 ? 'ok' : 'warn'}
            tooltip="Заряды системы пожаротушения"
          />
        </div>
      </div>
      <div className="spcp-modules">
        {integrity.modules.length ? (
          integrity.modules.map((module) => (
            <div
              className={`spcp-module${module.fire ? ' spcp-module--fire' : ''}`}
              key={module.id}
            >
              <div className="spcp-module__head">
                <span title={module.name}>{module.caption}</span>
                <b
                  className={
                    module.integrity <= 0
                      ? 'is-bad'
                      : module.integrity_warn
                        ? 'is-warn'
                        : 'is-ok'
                  }
                >
                  {module.integrity > 0
                    ? `${module.integrity}/${module.max_integrity}`
                    : 'УНИЧТОЖЕН'}
                </b>
              </div>
              <LevelBar
                value={module.integrity}
                max={module.max_integrity}
                dangerBelow={50}
                warn={module.integrity_warn}
                booted={booted}
              />
              {module.fire && (
                <Button
                  compact
                  fluid
                  color="bad"
                  icon="fire-extinguisher"
                  disabled={hull.extenguish_charges <= 0}
                  onClick={() => act('extinguish', { id: module.id })}
                >
                  ТУШИТЬ
                </Button>
              )}
            </div>
          ))
        ) : (
          <div className="spcp-empty">МОДУЛЕЙ НЕТ</div>
        )}
      </div>
    </Panel>
  );
};
