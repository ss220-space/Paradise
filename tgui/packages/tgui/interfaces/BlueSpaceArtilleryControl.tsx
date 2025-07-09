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
  mapRef: string;
};

export const BlueSpaceArtilleryControl = (props: unknown) => {
  const { act, data } = useBackend<BSAData>();
  const { mapRef } = data;

  let alertStatus: ReactNode;
  if (data.ready) {
    alertStatus = (
      <LabeledList.Item label="Status" color="green">
        Ready
      </LabeledList.Item>
    );
  } else if (data.reloadtime_text) {
    alertStatus = (
      <LabeledList.Item label="Reloading In" color="red">
        {data.reloadtime_text}
      </LabeledList.Item>
    );
  } else {
    alertStatus = (
      <LabeledList.Item label="Status" color="red">
        No cannon connected!
      </LabeledList.Item>
    );
  }
  return (
    <Window width={550} height={500}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section>
              <LabeledList>
                {!!data.notice && (
                  <LabeledList.Item label="Alert" color="red">
                    {data.notice}
                  </LabeledList.Item>
                )}
                {alertStatus}
                <LabeledList.Item label="Calibrate">
                  <Button icon="crosshairs" onClick={() => act('recalibrate')}>
                    {data.target ? data.target : 'None'}
                  </Button>
                </LabeledList.Item>
                {data.connected && (
                  <LabeledList.Item label="Aim coordinate:">
                      {data.target ? data.target_coord : 'None'}
                  </LabeledList.Item>
                )}
                {data.connected && (
                  <LabeledList>
                    <LabeledList.Item label="Aim control">
                      <Button
                        onClick={() => act('aim', {
                          direction: 'north'
                        })}
                      >
                        North
                      </Button>
                      <Button
                        onClick={() => act('aim', {
                          direction: 'west'
                        })}
                      >
                        West
                      </Button>
                      <Button
                        onClick={() => act('aim', {
                          direction: 'east'
                        })}
                      >
                        East
                      </Button>
                      <Button
                        onClick={() => act('aim', {
                          direction: 'south'
                        })}
                      >
                        South
                      </Button>
                    </LabeledList.Item>
                  </LabeledList>
                )}
                {!!data.ready && !!data.target && (
                  <LabeledList.Item label="Firing">
                    <Button
                      icon="skull"
                      color="red"
                      onClick={() => act('fire')}
                    >
                      FIRE!
                    </Button>
                  </LabeledList.Item>
                )}
                {!data.connected && (
                  <LabeledList.Item label="Maintenance">
                    <Button icon="wrench" onClick={() => act('build')}>
                      Complete Deployment
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
