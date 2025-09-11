import { useState } from 'react';
import {
  Button,
  ByondUi,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from '../../components';
import { formatSiUnit } from '../../format';

import { AccessList } from '../common/AccessList';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { AlertPane } from './AlertPane';
import type { MainData } from './data';
import { ModulesPane } from './ModulesPane';
import { useHonk } from './honk';

export const Mecha = (props) => {
  const { data } = useBackend<MainData>();
  return (
    <Window theme={data.ui_theme} width={800} height={560}>
      <Window.Content>
        <Content />
      </Window.Content>
    </Window>
  );
};

export const Content = (props) => {
  const { act, data } = useBackend<MainData>();
  const [edit_access, editAccess] = useState(false);
  const {
    name,
    mech_view,
    id_lock_on,
    accesses,
    one_access,
    regions,
    ui_honked,
  } = data;
  const honk = useHonk(ui_honked ? 0.4 : 0);

  return (
    <Stack fill>
      <Stack.Item grow={1}>
        <Stack vertical fill>
          <Stack.Item grow overflow="hidden">
            <Section
              fill
              title={name}
              buttons={
                <Button
                  icon="edit"
                  tooltip="Переименовать"
                  tooltipPosition="left"
                  onClick={() => act('changename')}
                />
              }
            >
              <Stack fill vertical>
                <Stack.Item>
                  <ByondUi
                    height="170px"
                    params={{
                      id: mech_view,
                      zoom: 5,
                      type: 'map',
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <LabeledList>
                    <IntegrityBar />
                    <PowerBar />
                    <LightsBar />
                    <CabinSeal />
                    <DNALock />
                    <LabeledList.Item label={honk('ID блок')}>
                      <Button
                        icon={id_lock_on ? 'lock' : 'lock-open'}
                        content={
                          id_lock_on ? honk('Включен') : honk('Выключен')
                        }
                        tooltipPosition="top"
                        onClick={() => {
                          editAccess(false);
                          act('toggle_id_lock');
                        }}
                        selected={id_lock_on}
                      />
                      {!!id_lock_on && (
                        <>
                          <Button
                            tooltip="Редактировать доступы"
                            tooltipPosition="top"
                            icon="id-card-o"
                            onClick={() => editAccess(!edit_access)}
                            selected={edit_access}
                          />
                          <Button
                            tooltip={
                              one_access ? 'Требуется любой' : 'Требуются все'
                            }
                            tooltipPosition="top"
                            icon={one_access ? 'check' : 'check-double'}
                            onClick={() => act('one_access')}
                          />
                        </>
                      )}
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <AlertPane />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow={2}>
        {edit_access ? (
          <AccessList
            accesses={regions}
            selectedList={accesses}
            accessMod={(ref) =>
              act('set', {
                access: ref,
              })
            }
            grantAll={() => act('grant_all')}
            denyAll={() => act('clear_all')}
            grantDep={(ref) =>
              act('grant_region', {
                region: ref,
              })
            }
            denyDep={(ref) =>
              act('deny_region', {
                region: ref,
              })
            }
          />
        ) : (
          <ModulesPane />
        )}
      </Stack.Item>
    </Stack>
  );
};

const PowerBar = (props) => {
  const { act, data } = useBackend<MainData>();
  const { power_level, power_max, ui_honked } = data;
  const honk = useHonk(ui_honked ? 0.4 : 0);
  return (
    <LabeledList.Item label={honk('Энергия')}>
      <ProgressBar
        value={power_max ? power_level / power_max : 0}
        ranges={{
          good: [0.5, Infinity],
          average: [0.25, 0.5],
          bad: [-Infinity, 0.25],
        }}
        style={{
          textShadow: '1px 1px 0 black',
        }}
      >
        {honk(
          power_max === null
            ? 'Батарея отсутствует'
            : power_level === 1e31
              ? '<Бесконечна>'
              : `${formatSiUnit(power_level, 0, 'J')} из ${formatSiUnit(
                  power_max,
                  0,
                  'J'
                )}`
        )}
      </ProgressBar>
    </LabeledList.Item>
  );
};

const IntegrityBar = (props) => {
  const { act, data } = useBackend<MainData>();
  const { integrity, integrity_max, ui_honked } = data;
  const honk = useHonk(ui_honked ? 0.4 : 0);
  return (
    <LabeledList.Item label={honk('Состояние')}>
      <ProgressBar
        value={integrity / integrity_max}
        ranges={{
          good: [0.5, Infinity],
          average: [0.25, 0.5],
          bad: [-Infinity, 0.25],
        }}
        style={{
          textShadow: '1px 1px 0 black',
        }}
      >
        {`${integrity} из ${integrity_max}`}
      </ProgressBar>
    </LabeledList.Item>
  );
};

const LightsBar = (props) => {
  const { act, data } = useBackend<MainData>();
  const { power_level, power_max, lights, ui_honked } = data;
  const honk = useHonk(ui_honked ? 0.4 : 0);
  const lights_on = lights;
  return (
    <LabeledList.Item label={honk('Свет')}>
      <Button
        icon="lightbulb"
        content={honk(lights_on ? 'Вкл' : 'Выкл')}
        selected={lights_on}
        disabled={!power_max || !power_level}
        onClick={() => act('toggle_lights')}
      />
    </LabeledList.Item>
  );
};

const CabinSeal = (props) => {
  const { act, data } = useBackend<MainData>();
  const {
    use_internal_tank,
    cabin_temp,
    cabin_pressure,
    cabin_pressure_warning_min,
    cabin_pressure_hazard_min,
    cabin_pressure_warning_max,
    cabin_pressure_hazard_max,
    cabin_temp_warning_min,
    cabin_temp_warning_max,
    ui_honked,
  } = data;
  const temp_warning =
    cabin_temp < cabin_temp_warning_min || cabin_temp > cabin_temp_warning_max;
  const pressure_warning =
    cabin_pressure < cabin_pressure_warning_min ||
    cabin_pressure > cabin_pressure_warning_max;
  const pressure_hazard =
    cabin_pressure < cabin_pressure_hazard_min ||
    cabin_pressure > cabin_pressure_hazard_max;
  const honk = useHonk(ui_honked ? 0.4 : 0);
  return (
    <LabeledList.Item
      label={honk('Воздух')}
      buttons={
        !!use_internal_tank && (
          <>
            <Button
              color={temp_warning ? 'average' : 'transparent'}
              icon="temperature-low"
              tooltipPosition="top"
              tooltip={`Температура воздуха: ${cabin_temp}°C`}
            />
            <Button
              color={
                pressure_hazard
                  ? 'danger'
                  : pressure_warning
                    ? 'average'
                    : 'transparent'
              }
              icon="gauge-high"
              tooltipPosition="top"
              tooltip={`Давление воздуха: ${cabin_pressure} кПа`}
            />
          </>
        )
      }
    >
      <Button
        icon={use_internal_tank ? 'mask-ventilator' : 'wind'}
        content={honk(use_internal_tank ? 'Баллон' : 'Атмосфера')}
        onClick={() => act('toggle_internal_tank')}
        selected={use_internal_tank}
      />
    </LabeledList.Item>
  );
};

const DNALock = (props) => {
  const { act, data } = useBackend<MainData>();
  const { dna_lock, ui_honked } = data;
  const honk = useHonk(ui_honked ? 0.4 : 0);
  return (
    <LabeledList.Item label={honk('ДНК блок')}>
      <Button
        onClick={() => act('dna_lock')}
        icon="syringe"
        content={honk(dna_lock ? 'Установлен' : 'Отсутствует')}
        tooltip="Установить новый ДНК ключ"
        selected={!!dna_lock}
        tooltipPosition="top"
      />
      {!!dna_lock && (
        <>
          <Button
            icon="key"
            tooltip={`Ключ ДНК: ${dna_lock}`}
            tooltipPosition="top"
            disabled={!dna_lock}
          />
          <Button
            onClick={() => act('reset_dna')}
            icon="ban"
            tooltip="Убрать ДНК блок"
            tooltipPosition="top"
            disabled={!dna_lock}
          />
        </>
      )}
    </LabeledList.Item>
  );
};
