import { GasmixParser } from 'tgui/interfaces/common/GasmixParser';
import {
  Box,
  Button,
  Collapsible,
  DmIcon,
  Tabs,
  Table,
  Icon,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Divider,
  Dropdown,
} from '../../components';
import { formatPower } from '../../format';
import { toFixed } from 'common/math';
import { classes } from 'common/react';
import { useState } from 'react';

import { useBackend } from '../../backend';
import type { MainData, MechModule } from './data';
import { useHonk } from './honk';

export const ModulesPane = (props) => {
  const { act, data } = useBackend<MainData>();
  const {
    modules,
    selected_module_index,
    cargo,
    maint_access,
    maintance_progress,
    radio_data,
    ui_honked,
  } = data;
  const [tabIndex, setTabIndex] = useState(0);
  const honk = useHonk(ui_honked ? 0.4 : 0);
  return (
    <Stack fill vertical>
      <Tabs>
        <Tabs.Tab
          key="Modules"
          selected={0 === tabIndex}
          onClick={() => setTabIndex(0)}
        >
          <Icon name="table" /> {honk('Модули')}
        </Tabs.Tab>
        <Tabs.Tab
          key="Cargo"
          selected={1 === tabIndex}
          onClick={() => setTabIndex(1)}
        >
          <Icon name="box" /> {honk('Груз')}
        </Tabs.Tab>
        <Tabs.Tab
          key="Settings"
          selected={2 === tabIndex}
          onClick={() => setTabIndex(2)}
        >
          <Icon name="cog" /> {honk('Настройки')}
        </Tabs.Tab>
      </Tabs>
      {tabIndex === 0 && (
        <Section style={{ overflowY: 'auto' }}>
          <Stack>
            <Stack.Item>
              {modules.map((module, i) =>
                !module.ref ? (
                  <Button
                    maxWidth={16}
                    p="4px"
                    pr="8px"
                    fluid
                    key={i}
                    color="transparent"
                  >
                    <Stack>
                      <Stack.Item width="32px" height="32px" textAlign="center">
                        <Icon
                          fontSize={1.5}
                          mx={0}
                          my="8px"
                          name={'screwdriver - wrench'}
                        />
                      </Stack.Item>
                    </Stack>
                  </Button>
                ) : (
                  <Button
                    maxWidth={16}
                    p="4px"
                    pr="8px"
                    fluid
                    key={i}
                    selected={i === selected_module_index}
                    onClick={() =>
                      act('select_module', {
                        index: i,
                      })
                    }
                  >
                    <Stack>
                      <Stack.Item lineHeight="0">
                        <DmIcon
                          icon={module.icon}
                          icon_state={module.icon_state}
                          style={{
                            verticalAlign: 'middle',
                            width: '32px',
                            margin: '0px',
                            marginLeft: '0px',
                          }}
                        />
                      </Stack.Item>
                      <Stack.Item
                        lineHeight="32px"
                        style={{
                          textTransform: 'capitalize',
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
                        }}
                      >
                        {module.name}
                      </Stack.Item>
                    </Stack>
                  </Button>
                )
              )}
            </Stack.Item>
            <Stack.Item grow pl={1}>
              {selected_module_index !== null &&
                modules[selected_module_index] && (
                  <ModuleDetails module={modules[selected_module_index]} />
                )}
            </Stack.Item>
          </Stack>
        </Section>
      )}
      {tabIndex === 1 && (
        <Section fill style={{ overflowY: 'auto' }}>
          <Table.Row header>
            <Table.Cell width="50%">Название</Table.Cell>
            <Table.Cell width="45%">Количество</Table.Cell>
          </Table.Row>
          {!!cargo.cargo_list &&
            cargo.cargo_list.map((cargo_item) => (
              <Table.Row key={cargo_item.ref}>
                <Table.Cell>{cargo_item.name}</Table.Cell>
                <Table.Cell>{cargo_item.amount}</Table.Cell>
                <Table.Cell>
                  <Button
                    color="transparent"
                    icon="eject"
                    tooltip="Выбросить предмет"
                    fontSize={1.5}
                    onClick={() =>
                      act('drop_from_cargo', {
                        cargo_item: cargo_item.ref,
                      })
                    }
                  />
                </Table.Cell>
              </Table.Row>
            ))}
        </Section>
      )}
      {tabIndex === 2 && (
        <Section fill style={{ overflowY: 'auto' }}>
          <LabeledList>
            <LabeledList.Item label={honk('Разрешить тех. обслуживание')}>
              <Button
                disabled={maintance_progress}
                selected={maint_access}
                icon="power-off"
                content={maint_access ? 'Вкл' : 'Выкл'}
                onClick={() => act('toggle_maint_access')}
              />
            </LabeledList.Item>
            <LabeledList.Item label={honk('Радио')}>
              <Button
                selected={radio_data.microphone}
                icon={radio_data.microphone ? 'microphone' : 'microphone-slash'}
                onClick={() => act('toggle_microphone')}
              />
              <Button
                selected={radio_data.speaker}
                icon={radio_data.speaker ? 'volume-up' : 'volume-mute'}
                onClick={() => act('toggle_speaker')}
              />
              <NumberInput
                animated
                unit="kHz"
                step={0.2}
                stepPixelSize={10}
                minValue={radio_data.minFrequency / 10}
                maxValue={radio_data.maxFrequency / 10}
                value={radio_data.frequency / 10}
                format={(value) => toFixed(value, 1)}
                onDrag={(value) =>
                  act('set_frequency', {
                    new_frequency: value * 10,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
    </Stack>
  );
};

export const ModuleDetails = (props) => {
  const { act, data } = useBackend<MainData>();
  const { slot, name, desc, icon, detachable, ref, snowflake } = props.module;
  return (
    <Box>
      <Section>
        <Stack vertical>
          <Stack.Item>
            <Stack>
              <Stack.Item grow>
                <h2 style={{ textTransform: 'capitalize' }}>{name}</h2>
              </Stack.Item>
              {!!detachable && (
                <Stack.Item>
                  <Button
                    color="transparent"
                    icon="eject"
                    tooltip="Отсоединить"
                    fontSize={1.5}
                    onClick={() =>
                      act('equip_act', {
                        ref: ref,
                        gear_action: 'detach',
                      })
                    }
                  />
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
          <Stack.Item>{desc}</Stack.Item>
        </Stack>
      </Section>
      <Section>
        <LabeledList>
          <ModuleDetailsBasic module={props.module} />
          {!!snowflake && <ModuleDetailsExtra module={props.module} />}
        </LabeledList>
      </Section>
    </Box>
  );
};

const ModuleDetailsBasic = (props) => {
  const { act, data } = useBackend<MainData>();
  const { power_level } = data;
  const {
    ref,
    slot,
    integrity,
    can_be_toggled,
    can_be_triggered,
    active,
    active_label,
    equip_cooldown,
    energy_per_use,
  } = props.module;
  const { ui_honked } = data;
  const honk = useHonk(ui_honked ? 0.4 : 0);
  return (
    <>
      {integrity < 1 && (
        <LabeledList.Item label="Состояние">
          <ProgressBar
            ranges={{
              good: [0.75, Infinity],
              average: [0.25, 0.75],
              bad: [-Infinity, 0.25],
            }}
            value={integrity}
          />
        </LabeledList.Item>
      )}
      {!!energy_per_use && (
        <LabeledList.Item label="Затраты энергии">
          {`${formatPower(energy_per_use)}, ${
            power_level ? toFixed(power_level / energy_per_use) : 0
          } использований осталось`}
        </LabeledList.Item>
      )}
      {!!equip_cooldown && (
        <LabeledList.Item label={honk('Перезарядка')}>
          {equip_cooldown}
        </LabeledList.Item>
      )}
      {!!can_be_toggled && (
        <LabeledList.Item label={honk(active_label)}>
          <Button
            icon="power-off"
            content={honk(active ? 'Включен' : ' Выключен')}
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'toggle',
              })
            }
            selected={active}
          />
        </LabeledList.Item>
      )}
      {!!can_be_triggered && (
        <LabeledList.Item label={honk(active_label)}>
          <Button
            icon="check"
            content={honk('Выбрать')}
            disabled={active}
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'select',
              })
            }
          />
        </LabeledList.Item>
      )}
    </>
  );
};

const MECHA_SNOWFLAKE_ID_SLEEPER = 'sleeper_snowflake';
const MECHA_SNOWFLAKE_ID_SYRINGE = 'syringe_snowflake';
const MECHA_SNOWFLAKE_ID_MODE = 'mode_snowflake';
const MECHA_SNOWFLAKE_ID_EXTINGUISHER = 'extinguisher_snowflake';
const MECHA_SNOWFLAKE_ID_WEAPON_BALLISTIC = 'ballistic_weapon_snowflake';
const MECHA_SNOWFLAKE_ID_GENERATOR = 'generator_snowflake';
const MECHA_SNOWFLAKE_ID_HOLO = 'holo_snowflake';
const MECHA_SNOWFLAKE_ID_TOOLSET = 'toolset_snowflake';
const MECHA_SNOWFLAKE_ID_MULTI = 'multimodule_snowflake';
const MECHA_SNOWFLAKE_ID_CABLE = 'cable_snoflake';
const MECHA_SNOWFLAKE_ID_CAGE = 'cage_snowflake';

export const ModuleDetailsExtra = (props: { module: MechModule }) => {
  const module = props.module;
  switch (module.snowflake.snowflake_id) {
    case MECHA_SNOWFLAKE_ID_WEAPON_BALLISTIC:
      return <SnowflakeWeaponBallistic module={module} />;
    case MECHA_SNOWFLAKE_ID_EXTINGUISHER:
      return <SnowflakeExtinguisher module={module} />;
    case MECHA_SNOWFLAKE_ID_SLEEPER:
      return <SnowflakeSleeper module={module} />;
    case MECHA_SNOWFLAKE_ID_SYRINGE:
      return <SnowflakeSyringe module={module} />;
    case MECHA_SNOWFLAKE_ID_MODE:
      return <SnowflakeMode module={module} />;
    case MECHA_SNOWFLAKE_ID_GENERATOR:
      return <SnowflakeGenerator module={module} />;
    case MECHA_SNOWFLAKE_ID_TOOLSET:
      return <SnowflakeToolset module={module} />;
    case MECHA_SNOWFLAKE_ID_MULTI:
      return <SnowflakeMulti module={module} />;
    case MECHA_SNOWFLAKE_ID_CABLE:
      return <SnowflakeCable module={module} />;
    case MECHA_SNOWFLAKE_ID_HOLO:
      return <SnowflakeHolo module={module} />;
    case MECHA_SNOWFLAKE_ID_CAGE:
      return <SnowflakeCage module={module} />;
    default:
      return null;
  }
};

const SnowflakeWeaponBallistic = (props) => {
  const { act, data } = useBackend<MainData>();
  const { ref } = props.module;
  const { max_ammo, total_ammo } = props.module.snowflake;
  const { ui_honked } = data;
  const honk = useHonk(ui_honked ? 0.4 : 0);
  return (
    <LabeledList.Item
      label={honk('Боеприпасы')}
      buttons={
        max_ammo !== 0 && (
          <Button
            icon="redo"
            disabled={total_ammo === max_ammo}
            tooltip="Перезарядка"
            tooltipPosition="top"
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'rearm',
              })
            }
          />
        )
      }
    >
      {!max_ammo ? (
        total_ammo
      ) : (
        <ProgressBar value={total_ammo / max_ammo}>
          {`${total_ammo} из ${max_ammo}`}
        </ProgressBar>
      )}
    </LabeledList.Item>
  );
};

const SnowflakeSleeper = (props) => {
  const { act, data } = useBackend<MainData>();
  const { ref } = props.module;
  const {
    patient,
    contained_reagents,
    injectible_reagents,
    has_brain_damage,
    has_traumas,
  } = props.module.snowflake;
  return !patient ? (
    <LabeledList.Item label="Пациент">Отсутствует</LabeledList.Item>
  ) : (
    <>
      <LabeledList.Item
        label="Пациент"
        buttons={
          <Button
            icon="eject"
            tooltip="Eject"
            onClick={() =>
              act('equip_act', {
                ref: ref,
                gear_action: 'eject',
              })
            }
          />
        }
      >
        {patient.patient_name}
      </LabeledList.Item>
      <LabeledList.Item label="Здоровье">
        <ProgressBar
          ranges={{
            good: [0.75, Infinity],
            average: [0.25, 0.75],
            bad: [-Infinity, 0.25],
          }}
          value={patient.patient_health}
        />
      </LabeledList.Item>
      <LabeledList.Item className="candystripe" label="Состояние">
        {patient.patient_state}
      </LabeledList.Item>
      <LabeledList.Item className="candystripe" label="Tемпература">
        {patient.core_temp} C
      </LabeledList.Item>
      <LabeledList.Item className="candystripe" label="Травмы">
        {patient.brute_loss}
      </LabeledList.Item>
      <LabeledList.Item className="candystripe" label="Ожоги">
        {patient.burn_loss}
      </LabeledList.Item>
      <LabeledList.Item className="candystripe" label="Tоксины">
        {patient.toxin_loss}
      </LabeledList.Item>
      <LabeledList.Item className="candystripe" label="Кислород">
        {patient.oxygen_loss}
      </LabeledList.Item>
      {!!has_brain_damage && (
        <LabeledList.Item className="candystripe" label="Обнаружен">
          Урон мозгу
        </LabeledList.Item>
      )}
      <LabeledList.Item label="Реагенты">
        {contained_reagents.map((reagent) => (
          <LabeledList.Item
            key={reagent.name}
            className="candystripe"
            labelWrap
            label={reagent.name}
          >
            <LabeledList.Item label={`${reagent.volume}u`} />
          </LabeledList.Item>
        ))}
      </LabeledList.Item>
      <LabeledList.Item label="Инъекции">
        {injectible_reagents
          ? injectible_reagents.map((reagent) => (
              <LabeledList.Item
                labelWrap
                className="candystripe"
                key={reagent.name}
                label={reagent.name}
              >
                <LabeledList.Item label={`${reagent.volume}u`}>
                  <Button
                    onClick={() =>
                      act('equip_act', {
                        ref: ref,
                        gear_action: `inject_reagent`,
                        reagent: reagent.id,
                      })
                    }
                  >
                    Inject
                  </Button>
                </LabeledList.Item>
              </LabeledList.Item>
            ))
          : 'Недоступно'}
      </LabeledList.Item>
    </>
  );
};
type Data = {
  contained_reagents: Reagent[];
  analyzed_reagents: KnownReagent[];
};
type Reagent = {
  name: string;
  volume: number;
};
type KnownReagent = {
  name: string;
  enabled: boolean;
};
const SnowflakeSyringe = (props) => {
  const { act, data } = useBackend<MainData>();
  const { power_level } = data;
  const { ref, energy_per_use, equip_cooldown } = props.module;
  const {
    mode,
    syringe,
    max_syringe,
    reagents,
    total_reagents,
    contained_reagents,
    analyzed_reagents,
  } = props.module.snowflake;
  return (
    <>
      <LabeledList.Item label="Шприцы">
        <ProgressBar value={syringe / max_syringe}>
          {`${syringe} из ${max_syringe}`}
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label="Реагенты">
        <ProgressBar value={reagents / total_reagents}>
          {`${reagents} из ${total_reagents} юнитов`}
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label="Режим">
        <Button
          content={mode}
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'change_mode',
            })
          }
        />
      </LabeledList.Item>
      <LabeledList.Item label="Синтезирование">
        {analyzed_reagents.map((reagent) => (
          <LabeledList.Item key={reagent.name} labelWrap label={reagent.name}>
            <Button.Checkbox
              checked={reagent.enabled}
              onClick={() =>
                act('equip_act', {
                  ref: ref,
                  gear_action: `toggle_reagent`,
                  reagent: reagent.name,
                })
              }
            />
          </LabeledList.Item>
        ))}
      </LabeledList.Item>
      <LabeledList.Item>
        <Button
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: `purge_all`,
            })
          }
        >
          Purge All
        </Button>
      </LabeledList.Item>
      {contained_reagents.map((reagent) => (
        <LabeledList.Item key={reagent.name} labelWrap label={reagent.name}>
          <LabeledList.Item label={`${reagent.volume}u`}>
            <Button
              onClick={() =>
                act('equip_act', {
                  ref: ref,
                  gear_action: `purge_reagent`,
                  reagent: reagent.id,
                })
              }
            >
              Purge
            </Button>
          </LabeledList.Item>
        </LabeledList.Item>
      ))}
    </>
  );
};

const SnowflakeMode = (props) => {
  const { act, data } = useBackend<MainData>();
  const { ref } = props.module;
  const { mode, mode_label } = props.module.snowflake;
  return (
    <LabeledList.Item label={mode_label}>
      <Button
        content={mode}
        onClick={() =>
          act('equip_act', {
            ref: ref,
            gear_action: 'change_mode',
          })
        }
      />
    </LabeledList.Item>
  );
};

const SnowflakeCable = (props) => {
  const { act, data } = useBackend<MainData>();
  const { ref } = props.module;
  const { cable } = props.module.snowflake;
  return <LabeledList.Item label="Кол-во">{cable}</LabeledList.Item>;
};

const SnowflakeExtinguisher = (props) => {
  const { act, data } = useBackend<MainData>();
  const { ref } = props.module;
  const { reagents, total_reagents, reagents_required } =
    props.module.snowflake;
  return (
    <LabeledList.Item label="Вода">
      <ProgressBar value={reagents} minValue={0} maxValue={total_reagents}>
        {reagents}
      </ProgressBar>
    </LabeledList.Item>
  );
};

const SnowflakeGenerator = (props) => {
  const { act, data } = useBackend<MainData>();
  const { mineral_material_amount } = data;
  const { ref, name } = props.module;
  const { active, fuel_amount } = props.module.snowflake;
  return (
    <LabeledList.Item
      label="Топливо"
      buttons={
        <Button
          icon="power-off"
          selected={active}
          tooltip="Включить генерацию энергии"
          tooltipPosition="top"
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'toggle_generator',
            })
          }
        />
      }
    >
      {fuel_amount === null ? 'нет' : `${toFixed(fuel_amount, 0.1)} cm³`}
    </LabeledList.Item>
  );
};

const SnowflakeHolo = (props) => {
  const { act, data } = useBackend<MainData>();
  const { ref } = props.module;
  const { max_barriers, total_barriers } = props.module.snowflake;
  return (
    <LabeledList.Item label="Барьеры">
      <ProgressBar value={total_barriers / max_barriers}>
        {`${total_barriers} из ${max_barriers}`}
      </ProgressBar>
    </LabeledList.Item>
  );
};

const SnowflakeCage = (props) => {
  const { act, data } = useBackend<MainData>();
  const { ref } = props.module;
  const { prisoner } = props.module.snowflake;
  return (
    <LabeledList.Item
      buttons={
        <Button
          icon="eject"
          tooltip="Освободить"
          tooltipPosition="top"
          onClick={() =>
            act('equip_act', {
              ref: ref,
              gear_action: 'eject',
            })
          }
        />
      }
      label="Заключенный"
    >
      {prisoner ? prisoner : 'Отсутствует'}
    </LabeledList.Item>
  );
};

const SnowflakeMulti = (props) => {
  const { act, data } = useBackend<MainData>();
  const { ref } = props.module;
  const { targeted_module } = props.module.snowflake;
  return (
    <>
      <LabeledList.Item label="Выбранный модуль">
        {targeted_module ? targeted_module.name : 'Отсутствует'}
      </LabeledList.Item>
      {!!targeted_module && <ModuleDetailsExtra module={targeted_module} />}
    </>
  );
};

const SnowflakeToolset = (props) => {
  const { act, data } = useBackend<MainData>();
  const { ref } = props.module;
  const { selected_item, items } = props.module.snowflake;
  return (
    <LabeledList.Item label="Инструмент">
      <Dropdown
        options={Object.keys(items)}
        selected={selected_item}
        onSelected={(val) =>
          act('equip_act', {
            ref: ref,
            gear_action: 'change_tool',
            selected_item: items[val],
          })
        }
      />
    </LabeledList.Item>
  );
};
