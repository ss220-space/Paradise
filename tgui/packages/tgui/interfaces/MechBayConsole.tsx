import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from '../components';
import { Window } from '../layouts';

type MechBayConsoleData = {
  recharge_port: Port;
};

type Port = {
  mech: Mech;
};

type Mech = {
  name: string;
  cell: Cell;
  health: number;
  maxhealth: number;
};

type Cell = {
  charge: number;
  maxcharge: number;
};

export const MechBayConsole = (props: unknown) => {
  const { act, data } = useBackend<MechBayConsoleData>();
  const { recharge_port } = data;
  const mech = recharge_port && recharge_port.mech;
  const cell = mech && mech.cell;
  const name = mech && mech.name;
  return (
    <Window width={400} height={150}>
      <Window.Content>
        <Section
          title={!name ? 'Mech status' : 'Mech status: ' + name}
          textAlign="center"
          buttons={
            <Button icon="sync" onClick={() => act('reconnect')}>
              Sync
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Integrity">
              {(!recharge_port && (
                <NoticeBox>No power port detected. Please re-sync.</NoticeBox>
              )) ||
                (!mech && <NoticeBox>No mech detected.</NoticeBox>) || (
                  <ProgressBar
                    value={mech.health / mech.maxhealth}
                    ranges={{
                      good: [0.7, Infinity],
                      average: [0.3, 0.7],
                      bad: [-Infinity, 0.3],
                    }}
                  />
                )}
            </LabeledList.Item>
            <LabeledList.Item label="Power">
              {(!recharge_port && (
                <NoticeBox>No power port detected. Please re-sync.</NoticeBox>
              )) ||
                (!mech && <NoticeBox>No mech detected.</NoticeBox>) ||
                (!cell && <NoticeBox>No cell is installed.</NoticeBox>) || (
                  <ProgressBar
                    value={cell.charge / cell.maxcharge}
                    ranges={{
                      good: [0.7, Infinity],
                      average: [0.3, 0.7],
                      bad: [-Infinity, 0.3],
                    }}
                  >
                    <AnimatedNumber value={cell.charge} />
                    {' / ' + cell.maxcharge}
                  </ProgressBar>
                )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
