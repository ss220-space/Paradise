import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  NoticeBox,
  Section,
} from '../components';
import { Window } from '../layouts';

type RoboticsControlConsoleData = {
  can_hack: boolean;
  safety: boolean;
  auth: boolean;
  show_detonate_all: boolean;
  cyborgs?: Cyborg[];
};

type Cyborg = {
  uid: string;
  name: string;
  hackable: boolean;
  emagged: boolean;
  locked_down: boolean;
  status: boolean;
  locstring: string;
  health: number;
  charge: number;
  cell_capacity: number;
  is_hacked: boolean;
  synchronization: boolean;
  module: string;
};

export const RoboticsControlConsole = (_props: unknown) => {
  const { act, data } = useBackend<RoboticsControlConsoleData>();
  const { safety, show_detonate_all, cyborgs = [] } = data;
  return (
    <Window width={500} height={460}>
      <Window.Content scrollable>
        {!!show_detonate_all && (
          <Section title="Emergency Self Destruct">
            <Button
              icon={safety ? 'lock' : 'unlock'}
              selected={safety}
              onClick={() => act('arm', {})}
            >
              {safety ? 'Disable Safety' : 'Enable Safety'}
            </Button>
            <Button
              icon="bomb"
              disabled={safety}
              color="bad"
              onClick={() => act('nuke', {})}
            >
              Destroy ALL Cyborgs
            </Button>
          </Section>
        )}
        <Cyborgs cyborgs={cyborgs} />
      </Window.Content>
    </Window>
  );
};

type CyborgsProps = {
  cyborgs: Cyborg[];
};

const Cyborgs = (props: CyborgsProps) => {
  const { cyborgs } = props;
  const { act, data } = useBackend<RoboticsControlConsoleData>();
  if (!cyborgs.length) {
    return (
      <NoticeBox>No cyborg units detected within access parameters.</NoticeBox>
    );
  }
  return cyborgs.map((cyborg) => {
    return (
      <Section
        key={cyborg.uid}
        title={cyborg.name}
        buttons={
          <>
            {!!cyborg.hackable && !cyborg.emagged && (
              <Button
                icon="terminal"
                color="bad"
                onClick={() =>
                  act('hackbot', {
                    uid: cyborg.uid,
                  })
                }
              >
                Hack
              </Button>
            )}
            <Button.Confirm
              icon={cyborg.locked_down ? 'unlock' : 'lock'}
              color={cyborg.locked_down ? 'good' : 'default'}
              disabled={!data.auth}
              onClick={() =>
                act('stopbot', {
                  uid: cyborg.uid,
                })
              }
            >
              {cyborg.locked_down ? 'Release' : 'Lockdown'}
            </Button.Confirm>
            <Button.Confirm
              icon="bomb"
              disabled={!data.auth}
              color="bad"
              onClick={() =>
                act('killbot', {
                  uid: cyborg.uid,
                })
              }
            >
              Detonate
            </Button.Confirm>
          </>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Status">
            <Box
              color={
                cyborg.status ? 'bad' : cyborg.locked_down ? 'average' : 'good'
              }
            >
              {cyborg.status
                ? 'Not Responding'
                : cyborg.locked_down
                  ? 'Locked Down'
                  : 'Nominal'}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Location">
            <Box>{cyborg.locstring}</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Integrity">
            <ProgressBar
              color={cyborg.health > 50 ? 'good' : 'bad'}
              value={cyborg.health / 100}
            />
          </LabeledList.Item>
          {(typeof cyborg.charge === 'number' && (
            <>
              <LabeledList.Item label="Cell Charge">
                <ProgressBar
                  color={cyborg.charge > 30 ? 'good' : 'bad'}
                  value={cyborg.charge / 100}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Cell Capacity">
                <Box color={cyborg.cell_capacity < 30000 ? 'average' : 'good'}>
                  {cyborg.cell_capacity}
                </Box>
              </LabeledList.Item>
            </>
          )) || (
            <LabeledList.Item label="Cell">
              <Box color="bad">No Power Cell</Box>
            </LabeledList.Item>
          )}
          {!!cyborg.is_hacked && (
            <LabeledList.Item label="Safeties">
              <Box color="bad">DISABLED</Box>
            </LabeledList.Item>
          )}
          <LabeledList.Item label="Module">{cyborg.module}</LabeledList.Item>
          <LabeledList.Item label="Master AI">
            <Box color={cyborg.synchronization ? 'default' : 'average'}>
              {cyborg.synchronization || 'None'}
            </Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    );
  });
};
