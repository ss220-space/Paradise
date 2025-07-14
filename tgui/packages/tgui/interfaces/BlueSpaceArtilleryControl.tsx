import { ReactNode } from 'react';
import { useBackend } from '../backend';
import { declension_ru } from 'common/string';
import {
  Button,
  LabeledList,
  Section,
  Stack,
  NumberInput,
  Dimmer,
  Icon,
  Box,
  Modal,
  ByondUi,
  Dropdown,
} from '../components';
import { classes } from 'common/react';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

type BSAData = {
  connected: boolean;
  notice: string;
  power: boolean;
  reload_ready: boolean;
  reloadtime_text: string;
  calibrated: boolean;
  calibrate_ready: boolean;
  calibrate_duration: string;
  target: string;
  target_coord: string;
  correction_x: number;
  correction_y: number;
  ready: boolean;
  mode: string;
  mode_options: string[];
  mapRef: string;
};

export const BlueSpaceArtilleryControl = (props: unknown) => {
  const { data } = useBackend<BSAData>();
  if (data.connected) {
    return <ControlBSAPanel />;
  }
  return <BuildBSAPanel />;
};

const getStatus = (data: BSAData) => {
  if (!data.power) {
    return { color: 'red', text: 'Нет питания' };
  }
  if (!data.reload_ready) {
    return { color: 'orange', text: 'Зарядка ' + data.reloadtime_text };
  }
  if (!data.calibrated) {
    return { color: 'red', text: 'Требуется наводка' };
  }
  if (!data.calibrate_ready) {
    return { color: 'orange', text: 'Наведение на цель' };
  }
  return { color: 'green', text: 'Готов к выстрелу' };
};

export const ControlBSAPanel = (props: unknown) => {
  const { act, data } = useBackend<BSAData>();
  const { mapRef } = data;

  let calibratingModal: ReactNode;
  if (!data.calibrate_ready) {
    calibratingModal = <BSACalibratePanel duration={data.calibrate_duration} />;
  }
  let status = getStatus(data);
  return (
    <Window width={600} height={800}>
      <Window.Content>
        <ComplexModal />
        <Stack fill vertical>
          <Stack.Item grow>
            <ByondUi
              height="100%"
              mb="30px"
              width="100%"
              params={{
                id: mapRef,
                type: 'map',
              }}
            />
          </Stack.Item>
          <Stack.Item height="162px">
            <Box position="relative" height="100%">
              {calibratingModal}
              <Section title="Управление">
                <Stack direction="horizontal" fill>
                  <Stack.Item basis="50%" grow>
                    <LabeledList>
                      <LabeledList.Item label="Статус" color={status.color}>
                        {status.text}
                      </LabeledList.Item>
                      <LabeledList.Item label="Режим стрельбы">
                        <Dropdown
                          options={data.mode_options}
                          selected={data.mode}
                          onSelected={(selected_mode) =>
                            act('select_mode', { mode: selected_mode })
                          }
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="Стрельба">
                        <Button
                          icon="skull"
                          color={data.ready ? 'red' : 'grey'}
                          width="180px"
                          align="center"
                          onClick={() => act('fire')}
                        >
                          ОГОНЬ!
                        </Button>
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack.Item basis="50%" grow>
                    <LabeledList>
                      <LabeledList.Item label="Наводка">
                        <Button
                          icon="crosshairs"
                          onClick={() => act('recalibrate')}
                        >
                          {data.target ? data.target : 'Отсутствует'}
                        </Button>
                      </LabeledList.Item>
                      <LabeledList.Item label="Координаты">
                        {data.target ? data.target_coord : 'Неизвестно'}
                      </LabeledList.Item>
                      <LabeledList.Item label="Коррекция по оси Х">
                        <Button
                          icon="angle-left"
                          onClick={() =>
                            act('aim', {
                              axis: 'x',
                              value: data.correction_x - 1,
                            })
                          }
                        />
                        <NumberInput
                          animated
                          width="4em"
                          step={1}
                          minValue={-15}
                          maxValue={15}
                          value={data.correction_x}
                          onChange={(x) => act('aim', { axis: 'x', value: x })}
                        />
                        <Button
                          icon="angle-right"
                          onClick={() =>
                            act('aim', {
                              axis: 'x',
                              value: data.correction_x + 1,
                            })
                          }
                        />
                      </LabeledList.Item>
                      <LabeledList.Item label="Коррекция по оси Y">
                        <Button
                          icon="angle-left"
                          onClick={() =>
                            act('aim', {
                              axis: 'y',
                              value: data.correction_y - 1,
                            })
                          }
                        />
                        <NumberInput
                          animated
                          width="4em"
                          step={1}
                          minValue={-15}
                          maxValue={15}
                          value={data.correction_y}
                          onChange={(y) => act('aim', { axis: 'y', value: y })}
                        />
                        <Button
                          icon="angle-right"
                          mb="100px"
                          onClick={() =>
                            act('aim', {
                              axis: 'y',
                              value: data.correction_y + 1,
                            })
                          }
                        />
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                </Stack>
              </Section>
            </Box>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const BSACalibratePanel = (props) => {
  return (
    <Dimmer textAlign="center" className="absolute fill zIndex">
      <Icon name="spinner" size={5} spin />
      <br />
      <Box color="average">
        <h1>
          <Icon name="gears" />
          &nbsp;Наведение на цель&nbsp;
          <Icon name="gears" />
        </h1>
      </Box>
      <Box color="label">
        <h3>
          В течении {props.duration} секунд
          {declension_ru(props.duration, 'ы', '', '')}
        </h3>
      </Box>
    </Dimmer>
  );
};

export const BuildBSAPanel = (props: unknown) => {
  const { act, data } = useBackend<BSAData>();
  return (
    <Window width={350} height={150}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Постройка орудия">
              <LabeledList>
                {!!data.notice && (
                  <LabeledList.Item label="Ошибка" color="red">
                    {data.notice}
                  </LabeledList.Item>
                )}
                <LabeledList.Item label="Строительство">
                  <Button icon="wrench" onClick={() => act('build')}>
                    Завершить постройку
                  </Button>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
