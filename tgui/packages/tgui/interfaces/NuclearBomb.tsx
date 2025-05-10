import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type NuclearBombData = {
  extended: boolean;
  authdisk: boolean;
  diskname: string;
  authcode: boolean;
  codemsg: string;
  anchored: boolean;
  authfull: boolean;
  time: number;
  timer: boolean;
  safety: boolean;
};

export const NuclearBomb = (_props: unknown) => {
  const { act, data } = useBackend<NuclearBombData>();

  if (!data.extended) {
    return (
      <Window width={450} height={300}>
        <Window.Content>
          <Section title="Deployment">
            <Button icon="exclamation-triangle" onClick={() => act('deploy')}>
              Deploy Nuclear Device (will bolt device to floor)
            </Button>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window width={450} height={300}>
      <Window.Content>
        <Section title="Authorization">
          <LabeledList>
            <LabeledList.Item label="Auth Disk">
              <Button
                icon={data.authdisk ? 'eject' : 'id-card'}
                selected={data.authdisk}
                tooltip={data.authdisk ? 'Eject Disk' : 'Insert Disk'}
                onClick={() => act('auth')}
              >
                {data.diskname ? data.diskname : '-----'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Auth Code">
              <Button
                icon="key"
                disabled={!data.authdisk}
                selected={data.authcode}
                onClick={() => act('code')}
              >
                {data.codemsg}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Arming & Disarming">
          <LabeledList>
            <LabeledList.Item label="Bolted to floor">
              <Button
                icon={data.anchored ? 'check' : 'times'}
                selected={data.anchored}
                disabled={!data.authfull}
                onClick={() => act('toggle_anchor')}
              >
                {data.anchored ? 'YES' : 'NO'}
              </Button>
            </LabeledList.Item>
            {(data.authfull && (
              <LabeledList.Item label="Time Left">
                <Button
                  icon="stopwatch"
                  disabled={!data.authfull}
                  tooltip="Set Timer"
                  onClick={() => act('set_time')}
                >
                  {data.time}
                </Button>
              </LabeledList.Item>
            )) || (
              <LabeledList.Item
                label="Time Left"
                color={data.timer ? 'red' : ''}
              >
                {data.time + 's'}
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Safety">
              <Button
                icon={data.safety ? 'check' : 'times'}
                selected={data.safety}
                disabled={!data.authfull}
                tooltip={data.safety ? 'Disable Safety' : 'Enable Safety'}
                onClick={() => act('toggle_safety')}
              >
                {data.safety ? 'ON' : 'OFF'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Arm/Disarm">
              <Button
                icon={data.timer ? 'bomb' : 'bomb'}
                disabled={data.safety || !data.authfull}
                color="red"
                onClick={() => act('toggle_armed')}
              >
                {data.timer ? 'DISARM THE NUKE' : 'ARM THE NUKE'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
