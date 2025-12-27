import { useState } from 'react';
import {
  AnimatedNumber,
  Box,
  Button,
  Collapsible,
  ColorBox,
  Dimmer,
  Dropdown,
  Icon,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Table,
} from '../components';
import { formatSiUnit } from '../format';
import type { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type MODsuitData = {
  // Static
  ui_theme: string;
  complexity_max: number;
  // Dynamic
  suit_status: SuitStatus;
  user_status: UserStatus;
  module_custom_status: ModuleCustomStatus;
  module_info: Module[];
  control: string;
  parts: PartData[];
};

type PartData = {
  slot: string;
  name: string;
  deployed: BooleanLike;
  ref: string;
};

type SuitStatus = {
  core_name: string;
  charge_current: number;
  charge_max: number;
  chargebar_color: string;
  chargebar_string: string;
  active: BooleanLike;
  open: BooleanLike;
  seconds_electrified: number;
  malfunctioning: BooleanLike;
  locked: BooleanLike;
  interface_break: BooleanLike;
  complexity: number;
  selected_module: string;
};

type UserStatus = {
  user_name: string;
  user_assignment: string;
};

type ModuleCustomStatus = {
  health: number;
  health_max: number;
  loss_brute: number;
  loss_fire: number;
  loss_tox: number;
  loss_oxy: number;
  is_user_irradiated: BooleanLike;
  background_radiation_level: number;
  display_time: BooleanLike;
  shift_time: string;
  shift_id: string;
  body_temperature: number;
  nutrition: number;
  dna_unique_identity: string;
  dna_unique_enzymes: string;
  viruses: VirusData[];
};

type VirusData = {
  name: string;
  type: string;
  stage: number;
  maxstage: number;
  cure: string;
};

type Module = {
  module_name: string;
  description: string;
  module_type: number;
  module_active: BooleanLike;
  pinned: BooleanLike;
  idle_power: number;
  active_power: number;
  use_energy: number;
  module_complexity: number;
  cooldown_time: number;
  cooldown: number;
  id: string;
  ref: string;
  configuration_data: ModuleConfig[];
};

type ModuleConfig = {
  display_name: string;
  type: string;
  value: number;
  values: [];
};

export const MODsuit = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const { ui_theme } = data;
  const { interface_break } = data.suit_status;
  return (
    <Window
      width={700}
      height={600}
      theme={ui_theme}
      title="Интерфейс управления МЭК"
    >
      <Window.Content scrollable={!interface_break}>
        <MODsuitContent />
      </Window.Content>
    </Window>
  );
};

export const MODsuitContent = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const { interface_break } = data.suit_status;
  return (
    <Box>
      {interface_break ? (
        <LockedInterface />
      ) : (
        <Stack vertical>
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <SuitStatusSection />
              </Stack.Item>
              <Stack.Item grow>
                <UserStatusSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <ModuleSection />
          </Stack.Item>
          <Stack.Item>
            <HardwareSection />
          </Stack.Item>
        </Stack>
      )}
    </Box>
  );
};

const ConfigureNumberEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  return (
    <NumberInput
      value={value}
      minValue={-50}
      maxValue={50}
      step={1}
      stepPixelSize={5}
      width="39px"
      onChange={(value) =>
        act('configure', {
          key: name,
          value: value,
          ref: module_ref,
        })
      }
    />
  );
};

const ConfigureBoolEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  return (
    <Button.Checkbox
      checked={value}
      onClick={() =>
        act('configure', {
          key: name,
          value: !value,
          ref: module_ref,
        })
      }
    />
  );
};

const ConfigureColorEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  return (
    <>
      <Button
        icon="paint-brush"
        onClick={() =>
          act('configure', {
            key: name,
            ref: module_ref,
          })
        }
      />
      <ColorBox color={value} mr={0.5} />
    </>
  );
};

const ConfigureListEntry = (props) => {
  const { name, value, values, module_ref } = props;
  const { act } = useBackend();
  return (
    <Dropdown
      selected={value}
      options={values}
      onSelected={(value) =>
        act('configure', {
          key: name,
          value: value,
          ref: module_ref,
        })
      }
    />
  );
};

const ConfigurePinEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  return (
    <Button
      onClick={() =>
        act('configure', { key: name, value: !value, ref: module_ref })
      }
      icon="thumbtack"
      selected={value}
      tooltip="Закрепить"
      tooltipPosition="left"
    />
  );
};

// fuck u smartkar configs werent meant to be used as actions 🖕🖕🖕
// and really u couldnt be bothered to make this and instead used
// the pin entry? 🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕🖕
const ConfigureButtonEntry = (props) => {
  const { name, value, module_ref } = props;
  const { act } = useBackend();
  return (
    <Button
      onClick={() => act('configure', { key: name, ref: module_ref })}
      icon={value}
    />
  );
};

const ConfigureDataEntry = (props) => {
  const { name, display_name, type, value, values, module_ref } = props;
  const configureEntryTypes = {
    number: <ConfigureNumberEntry {...props} />,
    bool: <ConfigureBoolEntry {...props} />,
    color: <ConfigureColorEntry {...props} />,
    list: <ConfigureListEntry {...props} />,
    button: <ConfigureButtonEntry {...props} />,
    pin: <ConfigurePinEntry {...props} />,
  };
  return (
    <LabeledList.Item label={display_name}>
      {configureEntryTypes[type]}
    </LabeledList.Item>
  );
};

const LockedInterface = () => (
  <Section align="center" fill>
    <Icon color="red" name="exclamation-triangle" size={15} />
    <Box fontSize="30px" color="red">
      ОШИБКА: ИНТЕРФЕЙС НЕ ОТВЕЧАЕТ
    </Box>
  </Section>
);

const LockedModule = (props) => {
  const { act, data } = useBackend();
  return (
    <Dimmer>
      <Stack>
        <Stack.Item fontSize="16px" color="blue">
          КОСТЮМ НЕ ЗАПИТАН
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const ConfigureScreen = (props) => {
  const { configuration_data, module_ref, module_name } = props;
  const configuration_keys = Object.keys(configuration_data);
  return (
    <Box pb={1}>
      <LabeledList>
        {configuration_keys.map((key) => {
          const data = configuration_data[key];
          return (
            <ConfigureDataEntry
              key={data.key}
              name={key}
              display_name={data.display_name}
              type={data.type}
              value={data.value}
              values={data.values}
              module_ref={module_ref}
            />
          );
        })}
      </LabeledList>
    </Box>
  );
};

const moduleTypeAction = (param) => {
  switch (param) {
    case 1:
      return 'Использовать';
    case 2:
      return 'Включить/Выключить';
    case 3:
      return 'Выбрать';
  }
};

const radiationLevels = (param) => {
  switch (param) {
    case 1:
      return 'Низкий';
    case 2:
      return 'Умеренный';
    case 3:
      return 'Высокий';
    case 4:
      return 'Критический';
  }
};

const SuitStatusSection = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const {
    charge_current,
    charge_max,
    chargebar_color,
    chargebar_string,
    active,
    open,
    seconds_electrified,
    malfunctioning,
    locked,
  } = data.suit_status;
  const { display_time, shift_time, shift_id } = data.module_custom_status;
  const status = malfunctioning
    ? 'Неисправен'
    : active
      ? 'Активен'
      : 'Не активен';

  return (
    <Section
      title="Статус"
      fill
      buttons={
        <Button
          icon="power-off"
          color={active ? 'good' : 'default'}
          content={status}
          onClick={() => act('activate')}
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Заряд">
          <ProgressBar
            value={charge_current / charge_max}
            color={chargebar_color}
            style={{
              textShadow: '1px 1px 0 black',
            }}
          >
            {chargebar_string}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="ID блок.">
          <Button
            icon={locked ? 'lock' : 'lock-open'}
            color={locked ? 'good' : 'default'}
            content={locked ? 'Заблокировано' : 'Разблокировано'}
            onClick={() => act('lock')}
          />
        </LabeledList.Item>
        {!!open && (
          <LabeledList.Item label="Крышка">
            <Box color="red">Открыта</Box>
          </LabeledList.Item>
        )}
        {!!seconds_electrified && (
          <LabeledList.Item label="Платы">
            <Box color="red">Короткое замыкание</Box>
          </LabeledList.Item>
        )}
      </LabeledList>

      {!!display_time && (
        <Section title="Операция" mt={2}>
          <LabeledList.Item label="Время">
            {active ? shift_time : '00:00:00'}
          </LabeledList.Item>
          <LabeledList.Item label="Номер">
            {active && shift_id ? shift_id : '???'}
          </LabeledList.Item>
        </Section>
      )}
    </Section>
  );
};

const HardwareSection = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const { control } = data;
  const { core_name } = data.suit_status;
  return (
    <Section title="Оборудование" style={{ textTransform: 'capitalize' }}>
      <LabeledList>
        <LabeledList.Item label="Блок управления">{control}</LabeledList.Item>
        <LabeledList.Item label="Ядро">
          {core_name || 'Ядро не обнаружено'}
        </LabeledList.Item>
        <ModParts />
      </LabeledList>
    </Section>
  );
};

const ModParts = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const { parts } = data;
  return (
    <>
      {parts.map((part) => {
        return (
          <LabeledList.Item
            key={part.slot}
            label={`${part.slot}`}
            buttons={
              <Button
                selected={part.deployed}
                icon={part.deployed ? 'arrow-down' : 'arrow-up'}
                content={part.deployed ? 'Свернуть' : 'Развернуть'}
                onClick={() => act('deploy', { ref: part.ref })}
              />
            }
          >
            {part.name}
          </LabeledList.Item>
        );
      })}
    </>
  );
};

const UserStatusSection = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const { active } = data.suit_status;
  const { user_name, user_assignment } = data.user_status;
  const {
    health,
    health_max,
    loss_brute,
    loss_fire,
    loss_tox,
    loss_oxy,
    is_user_irradiated,
    body_temperature,
    nutrition,
    dna_unique_identity,
    dna_unique_enzymes,
    viruses,
  } = data.module_custom_status;
  return (
    <Section title="Пользователь" fill>
      {!active && <LockedModule />}
      <LabeledList>
        {health !== undefined && (
          <LabeledList.Item label="Оценка здоровья">
            <ProgressBar
              value={active ? health / health_max : 0}
              ranges={{
                good: [0.5, Infinity],
                average: [0.2, 0.5],
                bad: [-Infinity, 0.2],
              }}
            >
              <AnimatedNumber value={active ? health : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_brute !== undefined && (
          <LabeledList.Item label="Мех. повреждения">
            <ProgressBar
              value={active ? loss_brute / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? loss_brute : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_fire !== undefined && (
          <LabeledList.Item label="Терм. повреждения">
            <ProgressBar
              value={active ? loss_fire / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? loss_fire : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_oxy !== undefined && (
          <LabeledList.Item label="Удушье">
            <ProgressBar
              value={active ? loss_oxy / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? loss_oxy : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {loss_tox !== undefined && (
          <LabeledList.Item label="Отравление">
            <ProgressBar
              value={active ? loss_tox / health_max : 0}
              ranges={{
                good: [-Infinity, 0.2],
                average: [0.2, 0.5],
                bad: [0.5, Infinity],
              }}
            >
              <AnimatedNumber value={active ? loss_tox : 0} />
            </ProgressBar>
          </LabeledList.Item>
        )}
        {is_user_irradiated !== undefined && (
          <LabeledList.Item label="Уровень радиации">
            {!active ? (
              'Неизвестно'
            ) : is_user_irradiated ? (
              <NoticeBox danger>Пользователь облучён</NoticeBox>
            ) : (
              <NoticeBox info>Не обнаружено</NoticeBox>
            )}
          </LabeledList.Item>
        )}
        {body_temperature !== undefined && (
          <LabeledList.Item label="Температура">
            {`${active ? Math.round(body_temperature) : 0} K`}
          </LabeledList.Item>
        )}
        {nutrition !== undefined && (
          <LabeledList.Item label="Насыщение">
            {`${active ? Math.round(nutrition) : 0}`}
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Имя">{user_name}</LabeledList.Item>
        <LabeledList.Item label="Должность">{user_assignment}</LabeledList.Item>
        {dna_unique_identity !== undefined && (
          <LabeledList.Item label="Отпечатки">
            <Box
              style={{
                wordBreak: 'break-all',
                wordWrap: 'break-word',
              }}
            >
              {active ? dna_unique_identity : '???'}
            </Box>
          </LabeledList.Item>
        )}
        {dna_unique_enzymes !== undefined && (
          <LabeledList.Item label="ДНК">
            <Box
              style={{
                wordBreak: 'break-all',
                wordWrap: 'break-word',
              }}
            >
              {active ? dna_unique_enzymes : '???'}
            </Box>
          </LabeledList.Item>
        )}
      </LabeledList>
      {!!viruses && (
        <Section title="Болезни">
          {viruses.map((virus) => {
            return (
              <Collapsible title={virus.name} key={virus.name}>
                <LabeledList>
                  <LabeledList.Item label="Распространение">
                    {virus.type}
                  </LabeledList.Item>
                  <LabeledList.Item label="Стадия">
                    {virus.stage}/{virus.maxstage}
                  </LabeledList.Item>
                  <LabeledList.Item label="Лечение">
                    {virus.cure}
                  </LabeledList.Item>
                </LabeledList>
              </Collapsible>
            );
          })}
        </Section>
      )}
    </Section>
  );
};

const ModuleSection = (props) => {
  const { act, data } = useBackend<MODsuitData>();
  const { complexity_max, module_info } = data;
  const { complexity } = data.suit_status;
  const [configureState, setConfigureState] = useState('');

  return (
    <Section
      title="Модули"
      fill
      buttons={`Использовано ${complexity}/${complexity_max}`}
    >
      {!module_info.length ? (
        <NoticeBox>Модули не обнаружены</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell colSpan={3}>Действия</Table.Cell>
            <Table.Cell>Название</Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="plug"
                tooltip="Пассивное потребление(Ватт)"
                tooltipPosition="top"
              />
            </Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="lightbulb"
                tooltip="Активное потребление(Ватт)"
                tooltipPosition="top"
              />
            </Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="bolt"
                tooltip="Разовое потребление(Джоули)"
                tooltipPosition="top"
              />
            </Table.Cell>
            <Table.Cell width={1} textAlign="center">
              <Button
                color="transparent"
                icon="save"
                tooltip="Размер"
                tooltipPosition="top"
              />
            </Table.Cell>
          </Table.Row>
          {module_info.map((module) => {
            return (
              <Table.Row key={module.ref}>
                <Table.Cell width={1}>
                  <Button
                    onClick={() => act('select', { ref: module.ref })}
                    icon={
                      module.module_type === 3
                        ? module.module_active
                          ? 'check-square-o'
                          : 'square-o'
                        : 'power-off'
                    }
                    selected={module.module_active}
                    tooltip={moduleTypeAction(module.module_type)}
                    tooltipPosition="left"
                    disabled={!module.module_type || module.cooldown > 0}
                  />
                </Table.Cell>
                <Table.Cell width={1}>
                  <Button
                    onClick={() =>
                      setConfigureState(
                        configureState === module.ref ? '' : module.ref
                      )
                    }
                    icon="cog"
                    selected={configureState === module.ref}
                    tooltip="Настроить"
                    tooltipPosition="left"
                    disabled={module.configuration_data.length === 0}
                  />
                </Table.Cell>
                <Table.Cell width={1}>
                  <Button
                    onClick={() => act('pin', { ref: module.ref })}
                    icon="thumbtack"
                    selected={module.pinned}
                    tooltip="Закрепить"
                    tooltipPosition="left"
                    disabled={!module.module_type}
                  />
                </Table.Cell>
                <Table.Cell>
                  <Collapsible
                    title={module.module_name}
                    color={module.module_active ? 'green' : 'default'}
                  >
                    <Section mr={-19}>{module.description}</Section>
                  </Collapsible>
                  {configureState === module.ref && (
                    <ConfigureScreen
                      configuration_data={module.configuration_data}
                      module_ref={module.ref}
                      module_name={module.module_name}
                    />
                  )}
                </Table.Cell>
                <Table.Cell textAlign="center">
                  {formatSiUnit(module.idle_power, 0)}
                </Table.Cell>
                <Table.Cell textAlign="center">
                  {formatSiUnit(module.active_power, 0)}
                </Table.Cell>
                <Table.Cell textAlign="center">
                  {formatSiUnit(module.use_energy, 0)}
                </Table.Cell>
                <Table.Cell textAlign="center">
                  {module.module_complexity}
                </Table.Cell>
              </Table.Row>
            );
          })}
        </Table>
      )}
    </Section>
  );
};
