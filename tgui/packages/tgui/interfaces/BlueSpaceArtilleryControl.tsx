import { ReactNode } from 'react';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

type BSAData = {
  ready: boolean;
  reloadtime_text: string;
  notice: string;
  target: string;
  connected: boolean;
};

export const BlueSpaceArtilleryControl = (props: unknown) => {
  const { act, data } = useBackend<BSAData>();
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
    <Window width={400} height={150}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section fill scrollable>
              <LabeledList>
                {!!data.notice && (
                  <LabeledList.Item label="Alert" color="red">
                    {data.notice}
                  </LabeledList.Item>
                )}
                {alertStatus}
                <LabeledList.Item label="Target">
                  <Button icon="crosshairs" onClick={() => act('recalibrate')}>
                    {data.target ? data.target : 'None'}
                  </Button>
                </LabeledList.Item>
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
        </Stack>
      </Window.Content>
    </Window>
  );
};
