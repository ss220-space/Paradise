import { ReactNode, useState } from 'react';
import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  Section,
  Stack,
  ByondUi
} from '../components';
import { classes } from 'common/react';
import { Window } from '../layouts';

type BSAData = {
  ready: boolean;
  reloadtime_text: string;
  notice: string;
  target: string;
  target_coord: string;
  connected: boolean;
  casual_aim: boolean
  correction: string;
  mode: string;
  mapRef: string;
};

export const BlueSpaceArtilleryControl = (props: unknown) => {
  const { act, data } = useBackend<BSAData>();
  const { mapRef } = data;

  let alertStatus: ReactNode;
  if (data.ready) {
    alertStatus = (
      <LabeledList.Item label="Статус" color="green">
        Готов к выстрелу
      </LabeledList.Item>
    );
  } else if (data.reloadtime_text) {
    alertStatus = (
      <LabeledList.Item label="Перезарядка" color="red">
        {data.reloadtime_text}
      </LabeledList.Item>
    );
  } else {
    alertStatus = (
      <LabeledList.Item label="Статус" color="red">
        Орудие не обнаружено!
      </LabeledList.Item>
    );
  }
  return (
    <Window width={750} height={750}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item minHeight="100px">
            <Section>
              <LabeledList>
                {!!data.notice && (
                  <LabeledList.Item label="Ошибка" color="red">
                    {data.notice}
                  </LabeledList.Item>
                )}
                {alertStatus}
                {data.connected && (
                  <LabeledList.Item label="Режим стрельбы">
                    <Button icon="cog" onClick={() => act('select_mode')}>
                      {data.mode}
                    </Button>
                  </LabeledList.Item>
                )}
                <LabeledList.Item label="Калибровка">
                  <Button icon="crosshairs" onClick={() => act('recalibrate')}>
                    {data.target ? data.target : 'None'}
                  </Button>
                </LabeledList.Item>
                {data.connected && (
                  <LabeledList.Item label="Координаты">
                      {data.target ? data.target_coord : 'None'}
                  </LabeledList.Item>
                )}
                {data.connected && (
                  <LabeledList.Item label="Коррекция">
                      {data.correction}
                  </LabeledList.Item>
                )}
                {data.connected && (
                  <LabeledList.Item label="Корректировка">
                    <Button
                      onClick={() => act('aim', {
                        axis: 'x'
                      })}
                    >
                      По оси x
                    </Button>
                    <Button
                      onClick={() => act('aim', {
                        axis: 'y'
                      })}
                    >
                      По оси y
                    </Button>
                  </LabeledList.Item>
                )}
                {data.connected && (
                  <LabeledList.Item label="Стрельба">
                    <Button
                      icon="skull"
                      color={(data.ready && data.target) ? "red" : "gray"}
                      onClick={() => act('fire')}
                    >
                      ОГОНЬ!
                    </Button>
                  </LabeledList.Item>
                )}
                {!data.connected && (
                  <LabeledList.Item label="Строительство">
                    <Button icon="wrench" onClick={() => act('build')}>
                      Завершить установку
                    </Button>
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Section>
          </Stack.Item>
          {data.connected && (
            <Stack.Item grow>
              <ByondUi
                height="100%" mb="30px"
                width="100%"
                params={{
                  id: mapRef,
                  type: 'map',
                }}
              />
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
