import {
  Box,
  Button,
  Divider,
  //DmIcon,
  Dropdown,
  Icon,
  Image,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

type SpacepodControlPanelData = {
  selected_tab: string;
  tabs: SpacepodControlPanelTabsData[];
  electricity: ElectricityPanelData;
  engines: EnginesPanelData;
  fuel: FuelSystemPanelData;
  weapons: WeaponsPanelData;
  life_support: LifeSupportPanelData;
  integrity: IntegrityPanelData;
  misc: MiscPanelData;
};

type SpacepodControlPanelTabsData = {
  id: string;
  name: string;
  icon: string;
};

const decideTab = (tab_id: string) => {
  switch (tab_id) {
    case 'electricity':
      return <ElectricityPanel />;
    case 'engines':
      return <EnginesPanel />;
    case 'fuel':
      return <FuelSystemPanel />;
    case 'life_support':
      return <LifeSupportPanel />;
    case 'weapons':
      return <WeaponsPanel />;
    case 'integrity':
      return <IntegrityPanel />;
    case 'instrumental':
      return <InstrumentalPanel />;
    case 'misc':
      return <MiscPanel />;
    default:
      return (
        <Section>
          <h2>НЕИЗВЕТНАЯ ОШИБКА!</h2>
          <b>Перезагрузите авионику космического челнока.</b>
        </Section>
      );
  }
};

// MARK: Window
export const SpacepodControlPanel = (props: unknown) => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { selected_tab, tabs } = data;

  return (
    <Window
      width={1030}
      height={650}
      title="Панель управления космическим челноком"
    >
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical={false}>
          <Stack.Item width="5%">
            <Tabs fluid vertical>
              {tabs.map((tab) => (
                <Tabs.Tab
                  key={tab.id}
                  icon={tab.icon}
                  selected={tab.id === selected_tab}
                  onClick={() => act('select_tab', { tab: tab.id })}
                  height="50px"
                >
                  {/* {tab.name} */}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item width="95%">
            <Section fill scrollable>
              {decideTab(selected_tab)}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

// MARK: Electricity panel
type ElectricityPanelData = {
  exists: boolean;
  link: boolean;
  battery_id: string;
  power: number;
  capacity: number;
  percent: number;
  consumers: ElectricityConsumerData[];
};

type ElectricityConsumerData = {
  id: string;
  caption: string;
  name: string;
  link: boolean;
};

const ElectricityPanel = (props: unknown) => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { electricity } = data;

  return (
    <Stack vertical fill width="100%" scrollable>
      {/* Battery section */}
      <Stack.Item>
        {electricity.exists ? (
          <Section title="Аккумуляторная батарея" ml="0" mr="0">
            <Table>
              <ToggleButtonRow
                caption="Соединение к электросети"
                enable={electricity.link}
                enable_text="Подключено"
                disable_text="Отключено"
                clicked={() =>
                  act('switch_powernet_link', { id: electricity.battery_id })
                }
              />
              <TextRow
                caption="Заряд батареи"
                value_text={`${electricity.power} Вт`}
              />
              <TextRow
                caption="Емкость аккумулятора"
                value_text={`${electricity.capacity} Вт·ч`}
              />
              <TextRow
                caption="Заряд в процентах"
                value_text={`${electricity.percent} %`}
              />
            </Table>
          </Section>
        ) : (
          <Box>
            <b>Аккумуляторная батаерея отсутствует!</b>
          </Box>
        )}
      </Stack.Item>
      {/* Electricity consumers section */}
      <Stack.Item grow>
        <Section fill scrollable title="Потребители">
          <Table>
            {electricity.consumers.map((consumer) => (
              <ToggleButtonRow
                key={consumer.id}
                caption={consumer.name}
                enable={consumer.link}
                enable_text="Подключено"
                disable_text="Отключено"
                clicked={() => act('switch_powernet_link', { id: consumer.id })}
              />
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

// MARK: Engines panel
type EnginesPanelData = {
  engines: EngineData[];
  gyroscope: GyroscopeData;
};

type EngineData = {
  id: string;
  caption: string;
  name: string;
  power_link: boolean;
  enable: boolean;
  rpm: number;
  rpm_percent: number;
  rpm_warn: boolean;
  fuel_pressure: number;
  fuel_pressure_warn: boolean;
  rpm_provide_engines: string[];
  selected_rpm_provide_engine: string;
  generator_enable: boolean;
  generated_power: number;
  temperature: number;
  temperature_warn: boolean;
  error_text: string;
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
  error_text: string;
};

const EnginesPanel = (props: unknown) => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { engines } = data;

  return (
    <Stack vertical fill width="100%" scrollable>
      {engines.engines.map((engine) => (
        <Stack.Item key={engine.id}>
          <Section title={engine.name} ml="0" mr="0">
            <Table>
              {engine.power_link !== null ? (
                <TextStatusRow
                  caption="Соединение к электросети"
                  enable={engine.power_link}
                  enable_text="Подключено"
                  disable_text="Отключено"
                />
              ) : (
                ''
              )}
              <ToggleButtonRow
                caption="Состояние"
                enable={engine.enable}
                enable_text="Запущено"
                disable_text="Отключено"
                clicked={() => act('switch_enable', { id: engine.id })}
              />
              <ColorTextRow
                caption="Обороты"
                value_text={`${engine.rpm} RPM`}
                warn={engine.rpm_warn}
              />
              <ColorTextRow
                caption="Мощность"
                value_text={`${engine.rpm_percent}%`}
                warn={engine.rpm_warn}
              />
              <ColorTextRow
                caption="Давление топлива"
                value_text={`${engine.fuel_pressure}%`}
                warn={engine.fuel_pressure_warn}
              />
              {engine.rpm_provide_engines !== null ? (
                <Table.Row>
                  <Table.Cell bold width="50%">
                    Передача крутящего момента:
                  </Table.Cell>
                  <Box pb={1}>
                    <Dropdown
                      options={engine.rpm_provide_engines}
                      selected={engine.selected_rpm_provide_engine}
                      onSelected={(value) =>
                        act('select_rpm_provider', {
                          id: engine.id,
                          destination: value,
                        })
                      }
                    />
                  </Box>
                </Table.Row>
              ) : (
                ''
              )}
              <ToggleButtonRow
                caption="Генератор"
                enable={engine.generator_enable}
                enable_text="Запущено"
                disable_text="Отключено"
                clicked={() =>
                  act('switch_generator_enable', { id: engine.id })
                }
              />
              <TextRow
                caption="Генерация электричества"
                value_text={`${engine.generated_power} Ватт`}
              />
              <ColorTextRow
                caption="Температура"
                value_text={`${engine.temperature} C`}
                warn={engine.temperature_warn}
              />
              <ErrorRow error_text={engine.error_text} />
            </Table>
          </Section>
        </Stack.Item>
      ))}
      <Stack.Divider />
      {engines.gyroscope !== null ? (
        <Stack.Item>
          <Section title={engines.gyroscope.name} ml="0" mr="0">
            <Table>
              <TextStatusRow
                caption="Соединение к электросети"
                enable={engines.gyroscope.power_link}
                enable_text="Подключено"
                disable_text="Отключено"
              />
              <ToggleButtonRow
                caption="Состояние"
                enable={engines.gyroscope.enable}
                enable_text="Запущено"
                disable_text="Отключено"
                clicked={() =>
                  act('switch_enable', { id: engines.gyroscope.id })
                }
              />
              <ColorTextRow
                caption="Обороты"
                value_text={`${engines.gyroscope.rpm} RPM`}
                warn={engines.gyroscope.rpm_warn}
              />
              <ColorTextRow
                caption="Мощность"
                value_text={`${engines.gyroscope.rpm_percent}%'`}
                warn={engines.gyroscope.rpm_warn}
              />
              <ColorTextRow
                caption="Температура"
                value_text={`${engines.gyroscope.temperature} C`}
                warn={engines.gyroscope.temperature_warn}
              />
              <ErrorRow error_text={engines.gyroscope.error_text} />
            </Table>
          </Section>
        </Stack.Item>
      ) : (
        ''
      )}
    </Stack>
  );
};

// MARK: Fuel system panel
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
  error_text: string;
};

const FuelSystemPanel = (props: unknown) => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { fuel } = data;

  return (
    <Stack vertical fill width="100%" scrollable>
      {/* Fuel tanks section */}
      {fuel.fuel_tanks.map((fuel_tank) => (
        <Stack.Item key={fuel_tank.id}>
          <Section title={fuel_tank.name} ml="0" mr="0">
            <Table>
              <TextRow
                caption="Емкость топлива"
                value_text={`${fuel_tank.fuel_capacity} л.`}
              />
              <ColorTextRow
                caption="Уровень топлива"
                value_text={`${fuel_tank.fuel_amount} л.`}
                warn={fuel_tank.level_percent < 20}
              />
              <ColorTextRow
                caption="Уровень в процентах"
                value_text={`${fuel_tank.level_percent}%`}
                warn={fuel_tank.level_percent < 20}
              />
            </Table>
          </Section>
        </Stack.Item>
      ))}
      {/* Fuel pumps section */}
      <Stack.Divider />
      {fuel.fuel_pumps.map((fuel_pump) => (
        <Stack.Item key={fuel_pump.id}>
          <Section title={fuel_pump.name} ml="0" mr="0">
            <Table>
              <TextStatusRow
                caption="Соединение к электросети"
                enable={fuel_pump.power_link}
                enable_text="Подключено"
                disable_text="Отключено"
              />
              <ToggleButtonRow
                caption="Состояние"
                enable={fuel_pump.enable}
                enable_text="Запущено"
                disable_text="Отключено"
                clicked={() => act('switch_enable', { id: fuel_pump.id })}
              />
              <TextRow
                caption="Скорость перекачки"
                value_text={`${fuel_pump.pump_speed} литр/сек`}
              />
              <ColorTextRow
                caption="Температура"
                value_text={`${fuel_pump.temperature} C`}
                warn={fuel_pump.temperature_warn}
              />
              <ErrorRow error_text={fuel_pump.error_text} />
            </Table>
          </Section>
        </Stack.Item>
      ))}
    </Stack>
  );
};

// MARK: Weapons panel
type WeaponsPanelData = {
  module: WeaponModuleData;
  guns: GunData[];
};

type WeaponModuleData = {
  id: string;
  name: string;
  enable: boolean;
  power_link: boolean;
  error_text: string;
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

const get_gun_type_name = (type: number) => {
  switch (type) {
    case 1:
      return 'Баллистический';
    case 2:
      return 'Энергетический';
  }
  return 'Неизвестно';
};

const WeaponsPanel = (props: unknown) => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { weapons } = data;

  return (
    <Stack vertical fill width="100%">
      {/* Module section */}
      {weapons.module === null ? (
        ''
      ) : (
        <Stack.Item>
          <Section title={weapons.module.name} ml="0" mr="0">
            <Table>
              <TextStatusRow
                caption="Соединение к электросети"
                enable={weapons.module.power_link}
                enable_text="Подключено"
                disable_text="Отключено"
              />
              <ToggleButtonRow
                caption="Состояние"
                enable={weapons.module.enable}
                enable_text="Запущено"
                disable_text="Отключено"
                clicked={() => act('switch_enable', { id: weapons.module.id })}
              />
              <ErrorRow error_text={weapons.module.error_text} />
            </Table>
          </Section>
        </Stack.Item>
      )}
      {/* Attached guns section */}
      <Stack.Divider />
      {weapons.guns.map((gun) => (
        <Stack.Item key={gun.id}>
          <Section title={gun.name} ml="0" mr="0">
            <Table>
              <TextRow
                caption="Слот"
                value_text={gun.primary ? 'Основное' : 'Вторичное'}
              />
              <ToggleButtonRow
                caption="Предохранитель"
                enable={gun.safety}
                enable_text="Включено"
                disable_text="Отключено"
                clicked={() => act('toggle_weapon_safety', { id: gun.id })}
              />
              <TextRow caption="Тип" value_text={get_gun_type_name(gun.type)} />
              <ColorTextRow
                caption="Боезапас"
                value_text={`${gun.ammo}/${gun.capacity}`}
                warn={gun.ammo === 0}
              />
              {gun.type === 1 ? (
                <ButtonRow
                  caption="Зарядка"
                  text="Перезарядить"
                  clicked={() => act('reload_weapon', { id: gun.id })}
                />
              ) : (
                ''
              )}
              {gun.type === 2 ? (
                <ToggleButtonRow
                  caption="Зарядка"
                  enable={gun.charging}
                  enable_text="Включено"
                  disable_text="Отключено"
                  clicked={() => act('reload_weapon', { id: gun.id })}
                />
              ) : (
                ''
              )}
            </Table>
          </Section>
        </Stack.Item>
      ))}
    </Stack>
  );
};

// MARK: Life support panel
type LifeSupportPanelData = {
  exists: boolean;
  airtank: AirtankData;
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

const LifeSupportPanel = (props: unknown) => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { life_support } = data;

  return (
    <Stack vertical fill width="100%">
      <Stack.Item>
        <Section title="Жизнеобеспечение" ml="0" mr="0">
          <Table>
            <ColorTextRow
              caption="Баллон"
              value_text={
                life_support.airtank === null
                  ? 'Отсутствует'
                  : life_support.airtank.name
              }
              warn={life_support.airtank === null}
            />
            {life_support.airtank === null ? (
              ''
            ) : (
              <>
                <TextRow
                  caption="Объем"
                  value_text={life_support.airtank.volume}
                />
                <ColorTextRow
                  caption="Давление в баллоне"
                  value_text={`${life_support.airtank.pressure} Pa`}
                  warn={life_support.airtank.low_pressure}
                />
                <ToggleButtonRow
                  caption="Подача кислорода с баллона"
                  enable={life_support.airtank.enable}
                  enable_text="Включено"
                  disable_text="Отключено"
                  clicked={() => act('switch_airtank')}
                />
              </>
            )}
            <ColorTextRow
              caption="Давление в кабине"
              value_text={`${life_support.atmos.pressure} Pa`}
              warn={life_support.atmos.low_pressure}
            />
            <ColorTextRow
              caption="Температура в кабине"
              value_text={`${life_support.atmos.temperature} K`}
              warn={life_support.atmos.low_temperature}
            />
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

// MARK: Integrity panel
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

const IntegrityPanel = (props: unknown) => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { integrity } = data;

  return (
    <Stack vertical fill width="100%">
      {/* Hull section */}
      <Stack.Item>
        <Section title={integrity.hull.name} ml="0" mr="0">
          <Table>
            <ColorTextRow
              caption="Прочность"
              value_text={`${integrity.hull.integrity}/${integrity.hull.max_integrity}`}
              warn={integrity.hull.integrity_warn}
            />
            <ColorTextRow
              caption="Количество зарядов системы пожаротушения"
              value_text={`${integrity.hull.extenguish_charges}`}
              warn={integrity.hull.extenguish_charges <= 0}
            />
          </Table>
        </Section>
      </Stack.Item>
      {/* Modules section */}
      <Stack.Item>
        <Section title="Модули" ml="0" mr="0">
          <Table>
            {integrity.modules.map((module) => (
              <>
                {module.integrity > 0 ? (
                  <Table.Row>
                    <Table.Cell bold width="50%">
                      {module.name}:
                    </Table.Cell>
                    <Box
                      inline
                      mr={1}
                      color={module.integrity_warn ? 'bad' : 'good'}
                    >
                      {`${module.integrity}/${module.max_integrity}`}
                      {module.fire ? (
                        <>
                          {' '}
                          <Icon name="fire" />{' '}
                          <Button
                            icon="fire-extinguisher"
                            disabled={integrity.hull.extenguish_charges <= 0}
                            onClick={() => act('extinguish', { id: module.id })}
                          >
                            Пожаротушение
                          </Button>
                        </>
                      ) : (
                        ''
                      )}
                    </Box>
                  </Table.Row>
                ) : (
                  <ColorTextRow
                    caption={module.name}
                    value_text="Уничтожен"
                    warn={true}
                  />
                )}
              </>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

// MARK: Misc panel
type MiscPanelData = {
  key_lock: KeyLockData;
  catapult: CatapultData;
};

type KeyLockData = {
  locked: boolean;
};

type CatapultData = {
  id: string;
  enable: boolean;
};

const MiscPanel = (props: unknown) => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { misc } = data;

  return (
    <Stack vertical fill width="100%">
      {/* Key lock section */}
      {misc.key_lock !== null ? (
        <Stack.Item>
          <Section title="Модуль замка" ml="0" mr="0">
            <Table>
              <ToggleButtonRow
                caption="Замок"
                enable={misc.key_lock.locked}
                enable_text="Закрыт"
                disable_text="Открыт"
                clicked={() => act('toggle_lock')}
              />
            </Table>
          </Section>
        </Stack.Item>
      ) : (
        ''
      )}
      {/* Catapult section */}
      {misc.catapult !== null ? (
        <Stack.Item>
          <Section title="Модуль аварийного катапультирования" ml="0" mr="0">
            <Table>
              <ToggleButtonRow
                caption="Автоматическое катапультирование"
                enable={misc.catapult.enable}
                enable_text="Включен"
                disable_text="Выключен"
                clicked={() => act('switch_enable', { id: misc.catapult.id })}
              />
              <ButtonRow
                caption="Ручное катапультирование"
                text="Активировать"
                clicked={() => act('catapult_pilot')}
              />
            </Table>
          </Section>
        </Stack.Item>
      ) : (
        ''
      )}
    </Stack>
  );
};

// MARK: Instrumental panel
const InstrumentalPanel = (props: unknown) => {
  const { act, data } = useBackend<SpacepodControlPanelData>();
  const { electricity, engines, fuel, life_support, weapons, misc } = data;

  return (
    <Stack vertical fill width="100%">
      {/* Electricity control */}
      <Stack.Item>
        <Box align="center">
          <Stack fill inlineFlex={true}>
            <Stack.Item>
              <Box pb="5px"> BATT </Box>
              <TextMeter
                caption="CHRG"
                text_upper={`${electricity.exists ? electricity.power : 0} W`}
                text_lower={`${electricity.exists ? electricity.percent : 0}%`}
                warn={!electricity.exists || electricity.percent < 25}
              />
            </Stack.Item>
            <Stack.Item>
              <Box pb="5px">PWR STAT</Box>
              <Stack wrap>
                <Stack.Item>
                  <TumblerButton
                    caption="MAIN BATT"
                    enable={electricity.link}
                    clicked={() =>
                      act('switch_powernet_link', {
                        id: electricity.battery_id,
                      })
                    }
                  />
                </Stack.Item>
                {electricity.consumers.map((consumer) => (
                  <Stack.Item key={consumer.id}>
                    <TumblerButton
                      caption={consumer.caption}
                      enable={consumer.link}
                      clicked={() =>
                        act('switch_powernet_link', { id: consumer.id })
                      }
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
          </Stack>
          <Divider />
        </Box>
      </Stack.Item>
      {/* Fuel control */}
      <Stack.Item>
        <Box align="center">
          <Stack fill inlineFlex={true}>
            <Stack.Item>
              <Box pb="5px">FUEL TANKS</Box>
              <Stack wrap>
                <Stack.Item grow />
                {fuel.fuel_tanks.map((fuel_tank) => (
                  <Stack.Item key={fuel_tank.id}>
                    <TextMeter
                      caption={fuel_tank.caption}
                      text_upper={`${fuel_tank.fuel_amount} L`}
                      text_lower={`${fuel_tank.level_percent}%`}
                      warn={fuel_tank.level_percent < 25}
                    />
                  </Stack.Item>
                ))}
                <Stack.Item grow />
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Box pb="5px">FUEL PUMPS</Box>
              <Stack wrap>
                <Stack.Item grow />
                {fuel.fuel_pumps.map((pump) => (
                  <Stack.Item key={pump.id}>
                    <TumblerButton
                      caption={pump.caption}
                      enable={pump.enable}
                      clicked={() => act('switch_enable', { id: pump.id })}
                    />
                  </Stack.Item>
                ))}
                <Stack.Item grow />
              </Stack>
            </Stack.Item>
          </Stack>
        </Box>
        <Divider />
      </Stack.Item>
      {/* Engines control */}
      <Stack.Item>
        <Box align="center" width="100%">
          <Stack fill inlineFlex={true}>
            <Stack.Item>
              <Box pb="5px">ENG START</Box>
              <Stack>
                {engines.engines.map((engine) => (
                  <Stack.Item key={engine.id}>
                    <EngineButton
                      caption={engine.caption}
                      enable={engine.enable}
                      failure={engine.error_text != null}
                      clicked={() => act('ignite_engine', { id: engine.id })}
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
            <Divider />
            <Stack.Item>
              <Box pb="5px">ENG STAT</Box>
              <Stack>
                {engines.engines.map((engine) => (
                  <Stack.Item key={engine.id}>
                    <TextMeter
                      caption={engine.caption}
                      text_upper={`${engine.rpm} RPM`}
                      text_lower={`${engine.rpm_percent}%`}
                      warn={engine.rpm_warn}
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
            <Divider />
            <Stack.Item>
              <Box pb="5px">ENG GEN</Box>
              <Stack>
                {engines.engines.map((engine) => (
                  <Stack.Item key={engine.id}>
                    <TumblerButton
                      caption={`${engine.caption} GEN`}
                      enable={engine.generator_enable}
                      clicked={() =>
                        act('switch_generator_enable', { id: engine.id })
                      }
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
            <Divider />
            {engines.gyroscope === null ? (
              ''
            ) : (
              <Stack.Item>
                <Box pb="5px">GYRO</Box>
                <Stack>
                  <Stack.Item>
                    <TumblerButton
                      caption="PWR"
                      enable={engines.gyroscope.enable}
                      clicked={() =>
                        act('switch_enable', { id: engines.gyroscope.id })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <TextMeter
                      caption="STAT"
                      text_upper={`${engines.gyroscope.rpm} RPM`}
                      text_lower={`${engines.gyroscope.rpm_percent}%`}
                      warn={
                        engines.gyroscope.rpm_percent > 0 &&
                        engines.gyroscope.rpm_warn
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            )}
          </Stack>
        </Box>
        <Divider />
      </Stack.Item>
      <Stack.Item>
        {/* Life support and weapons control */}
        <Box align="center" width="100%">
          <Stack fill inlineFlex={true}>
            {life_support.exists ? (
              <>
                <Stack.Item>
                  <Box>AIR</Box>
                  <Stack>
                    <Stack.Item>
                      <TextMeter
                        caption="PRESS"
                        text_upper={`${life_support.atmos.pressure} Pa`}
                        text_lower={`${life_support.atmos.temperature} C`}
                        warn={
                          life_support.atmos.low_pressure ||
                          life_support.atmos.low_temperature
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <TumblerButton
                        caption="PWR"
                        enable={
                          life_support.airtank === null
                            ? false
                            : life_support.airtank.enable
                        }
                        clicked={() => act('switch_airtank')}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Divider />
              </>
            ) : (
              ''
            )}
            {weapons.module ? (
              <>
                <Stack.Item>
                  <Box>WEAPON</Box>
                  <Stack>
                    <Stack.Item>
                      <TumblerButton
                        caption="PWR"
                        enable={weapons.module.enable}
                        clicked={() =>
                          act('switch_enable', { id: weapons.module.id })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Divider />
              </>
            ) : (
              ''
            )}
            {weapons.module &&
              weapons.guns.map((gun) => (
                <>
                  <Stack.Item key={gun.id}>
                    <Box>{gun.primary ? 'PRIMARY' : 'SECONDARY'}</Box>
                    <Stack>
                      <Stack.Item>
                        <TumblerButton
                          caption="ARM"
                          enable={!gun.safety}
                          clicked={() =>
                            act('toggle_weapon_safety', { id: gun.id })
                          }
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <TextMeter
                          caption="AMMO"
                          text_upper={`CUR: ${gun.ammo}`}
                          text_lower={`MAX: ${gun.capacity}`}
                          warn={gun.ammo === 0}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        {gun.type === 1 ? (
                          <SimpleButton
                            caption="REL"
                            failure={false}
                            clicked={() => act('reload_weapon', { id: gun.id })}
                          />
                        ) : (
                          ''
                        )}
                        {gun.type === 2 ? (
                          <TumblerButton
                            caption="CHRG"
                            enable={gun.charging}
                            clicked={() => act('reload_weapon', { id: gun.id })}
                          />
                        ) : (
                          ''
                        )}
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Divider />
                </>
              ))}
          </Stack>
        </Box>
      </Stack.Item>
      <Stack.Item>
        {/* Misc */}
        <Box align="center" width="100%">
          <Stack fill inlineFlex={true}>
            {/* Key lock */}
            {misc.key_lock !== null ? (
              <>
                <Stack.Item>
                  <Box pb="5px">LOCK</Box>
                  <Stack>
                    <Stack.Item>
                      <TumblerButton
                        caption="LOCK"
                        enable={misc.key_lock.locked}
                        clicked={() => act('toggle_lock')}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Divider />
              </>
            ) : (
              ''
            )}
            {/* Catapult */}
            {misc.catapult !== null ? (
              <>
                <Stack.Item>
                  <Box pb="5px">CAT</Box>
                  <Stack>
                    <Stack.Item>
                      <TumblerButton
                        caption="AUTO"
                        enable={misc.catapult.enable}
                        clicked={() =>
                          act('switch_enable', { id: misc.catapult.id })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <SimpleButton
                        caption="MAN"
                        failure={false}
                        clicked={() => act('catapult_pilot')}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Divider />
              </>
            ) : (
              ''
            )}
          </Stack>
        </Box>
      </Stack.Item>
    </Stack>
  );
};

// MARK: Elements
type ToggleButtonRowData = {
  caption: string;
  enable: boolean;
  enable_text: string;
  disable_text: string;
  clicked: any;
};

const ToggleButtonRow = (props: ToggleButtonRowData) => {
  const { caption, enable, enable_text, disable_text, clicked } = props;
  return (
    <Table.Row>
      <Table.Cell bold width="50%">
        {caption}:
      </Table.Cell>
      <Table.Cell>
        <Box pb={1}>
          <Button
            selected={enable}
            icon={enable ? 'toggle-on' : 'toggle-off'}
            onClick={() => clicked()}
          >
            {enable ? enable_text : disable_text}
          </Button>
        </Box>
      </Table.Cell>
    </Table.Row>
  );
};

type ButtonRowData = {
  caption: string;
  text: string;
  clicked: any;
};

const ButtonRow = (props: ButtonRowData) => {
  const { caption, text, clicked } = props;
  return (
    <Table.Row>
      <Table.Cell bold width="50%">
        {caption}:
      </Table.Cell>
      <Table.Cell>
        <Box pb={1}>
          <Button onClick={() => clicked()}>{text}</Button>
        </Box>
      </Table.Cell>
    </Table.Row>
  );
};

type BadColorButtonRowData = {
  caption: string;
  text: string;
  icon: string;
  clicked: any;
};

const BadColorButtonRow = (props: BadColorButtonRowData) => {
  const { caption, text, icon, clicked } = props;
  return (
    <Table.Row>
      <Table.Cell bold width="50%">
        <Box color="bad">{caption}:</Box>
      </Table.Cell>
      <Table.Cell>
        <Box pb={1}>
          <Button icon={icon} onClick={() => clicked()}>
            {text}
          </Button>
        </Box>
      </Table.Cell>
    </Table.Row>
  );
};

type TextRowData = {
  caption: string;
  value_text: string;
};

const TextRow = (props: TextRowData) => {
  const { caption, value_text } = props;
  return (
    <Table.Row>
      <Table.Cell bold width="50%">
        {caption}:
      </Table.Cell>
      <Table.Cell>
        <b>{value_text}</b>
      </Table.Cell>
    </Table.Row>
  );
};

type TextStatusRowData = {
  caption: string;
  enable: boolean;
  enable_text: string;
  disable_text: string;
};

const TextStatusRow = (props: TextStatusRowData) => {
  const { caption, enable, enable_text, disable_text } = props;
  return (
    <Table.Row>
      <Table.Cell bold width="50%">
        {caption}:
      </Table.Cell>
      <Table.Cell>
        <Box inline mr={1} color={enable ? 'good' : 'bad'}>
          {enable ? enable_text : disable_text}
        </Box>
      </Table.Cell>
    </Table.Row>
  );
};

type ColorTextRowData = {
  caption: string;
  value_text: string;
  warn: boolean;
};

const ColorTextRow = (props: ColorTextRowData) => {
  const { caption, value_text, warn } = props;
  return (
    <Table.Row>
      <Table.Cell bold width="50%">
        {caption}:
      </Table.Cell>
      <Box inline mr={1} color={warn ? 'bad' : 'good'}>
        {value_text}
      </Box>
    </Table.Row>
  );
};

type ErrorRowData = {
  error_text: string;
};

const ErrorRow = (props: ErrorRowData) => {
  const { error_text } = props;
  if (error_text !== null) {
    return (
      <Table.Row>
        <Table.Cell bold>Ошибка:</Table.Cell>
        <Box inline mr={1} color="bad">
          {error_text}
        </Box>
      </Table.Row>
    );
  }
  return '';
};

type EngineButtonData = {
  caption: string;
  enable: boolean;
  failure: boolean;
  clicked: any;
};

const EngineButton = (props: EngineButtonData) => {
  const { caption, enable, failure, clicked } = props;
  return (
    <Table style={{ borderCollapse: 'separate', borderSpacing: '0px' }}>
      {/* Строка с заголовком */}
      <Table.Row>
        <Table.Cell
          textAlign="center"
          height="28px"
          verticalAlign="center"
          backgroundColor="#414141" // Добавляем верхний левый и верхний правый радиусы
          style={{
            borderRadius: '8px 8px 0 0',
            padding: '4px',
          }}
        >
          {caption}
        </Table.Cell>
      </Table.Row>
      {/* Строка с тумблером */}
      <Table.Row>
        <Table.Cell
          backgroundColor="#414141" // Добавляем нижний левый и нижний правый радиусы
          style={{
            borderRadius: '0 0 8px 8px', // Обязательно добавляем padding, иначе контент прилипнет к краям фона
            padding: '4px',
            display: 'flex',
            justifyContent: 'center', // Центрируем картинку горизонтально
          }}
        >
          <Image
            src={resolveAsset(
              failure ? 'eng-fail.png' : enable ? 'eng-on.png' : 'eng-off.png',
            )}
            onClick={() => clicked()}
            style={{
              width: '64px',
              height: '64px',
            }}
          />
        </Table.Cell>
      </Table.Row>
    </Table>
  );
};

type SimpleButtonData = {
  caption: string;
  failure: boolean;
  clicked: any;
};

const SimpleButton = (props: SimpleButtonData) => {
  const { caption, failure, clicked } = props;
  return (
    <Table style={{ borderCollapse: 'separate', borderSpacing: '0px' }}>
      {/* Строка с заголовком */}
      <Table.Row>
        <Table.Cell
          textAlign="center"
          height="28px"
          verticalAlign="center"
          backgroundColor="#414141" // Добавляем верхний левый и верхний правый радиусы
          style={{
            borderRadius: '8px 8px 0 0',
            padding: '4px',
          }}
        >
          {caption}
        </Table.Cell>
      </Table.Row>
      {/* Строка с тумблером */}
      <Table.Row>
        <Table.Cell
          backgroundColor="#414141" // Добавляем нижний левый и нижний правый радиусы
          style={{
            borderRadius: '0 0 8px 8px', // Обязательно добавляем padding, иначе контент прилипнет к краям фона
            padding: '4px',
            display: 'flex',
            justifyContent: 'center', // Центрируем картинку горизонтально
          }}
        >
          <Image
            src={resolveAsset(failure ? 'eng-fail.png' : 'eng-idle.png')}
            onClick={() => clicked()}
            style={{
              width: '64px',
              height: '64px',
            }}
          />
        </Table.Cell>
      </Table.Row>
    </Table>
  );
};

type TumblerButtonData = {
  caption: string;
  enable: boolean;
  clicked: any;
};

const TumblerButton = (props: TumblerButtonData) => {
  const { caption, enable, clicked } = props;
  return (
    <Table style={{ borderCollapse: 'separate', borderSpacing: '0px' }}>
      {/* Строка с заголовком */}
      <Table.Row>
        <Table.Cell
          textAlign="center"
          verticalAlign="center"
          backgroundColor="#414141" // Добавляем верхний левый и верхний правый радиусы
          style={{
            borderRadius: '8px 8px 0 0',
            padding: '4px',
          }}
        >
          <Box
            width="64px"
            height="24px"
            textAlign="center"
            verticalAlign="center"
          >
            {caption}
          </Box>
        </Table.Cell>
      </Table.Row>
      {/* Строка с тумблером */}
      <Table.Row>
        <Table.Cell
          backgroundColor="#414141" // Добавляем нижний левый и нижний правый радиусы
          style={{
            borderRadius: '0 0 8px 8px', // Обязательно добавляем padding, иначе контент прилипнет к краям фона
            padding: '4px',
            display: 'flex',
            justifyContent: 'center', // Центрируем картинку горизонтально
          }}
        >
          <Image
            src={resolveAsset(enable ? 'eng-on.png' : 'eng-off-top.png')}
            onClick={() => clicked()}
            style={{
              width: '64px',
              height: '64px',
            }}
          />
        </Table.Cell>
      </Table.Row>
    </Table>
  );
};

type TextMeterData = {
  caption: string;
  text_upper: string;
  text_lower: string;
  warn: boolean;
};

const TextMeter = (props: TextMeterData) => {
  const { caption, text_upper, text_lower, warn } = props;
  return (
    <Table style={{ borderCollapse: 'separate', borderSpacing: '0px' }}>
      {/* Строка с заголовком */}
      <Table.Row backgroundColor={warn ? '#7c2f2f' : '#414141'}>
        <Table.Cell
          textAlign="center"
          verticalAlign="center"
          backgroundColor={warn ? '#7c2f2f' : '#414141'}
          style={{
            borderRadius: '8px 8px 0 0',
            padding: '4px',
          }}
        >
          <Box
            width="64px"
            height="32px"
            textAlign="center"
            verticalAlign="center"
          >
            {caption}
          </Box>
        </Table.Cell>
      </Table.Row>
      {/* Строка с литрами */}
      <Table.Row>
        <Table.Cell
          textAlign="center"
          verticalAlign="center"
          backgroundColor={warn ? '#7c2f2f' : '#414141'}
          style={{
            padding: '4px',
          }}
        >
          <Box
            width="64px"
            height="24px"
            textAlign="center"
            verticalAlign="center"
          >
            {text_upper}
          </Box>
        </Table.Cell>
      </Table.Row>
      {/* Строка с процентами */}
      <Table.Row>
        <Table.Cell
          textAlign="center"
          verticalAlign="center"
          backgroundColor={warn ? '#7c2f2f' : '#414141'}
          style={{
            borderRadius: '0 0 8px 8px',
            padding: '4px',
          }}
        >
          <Box
            width="64px"
            height="24px"
            textAlign="center"
            verticalAlign="center"
          >
            {text_lower}
          </Box>
        </Table.Cell>
      </Table.Row>
    </Table>
  );
};
