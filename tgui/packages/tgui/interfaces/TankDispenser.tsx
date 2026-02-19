import { useBackend } from '../backend';
import { Button, Box } from '../components';
import { Window } from '../layouts';

type TankDispenserData = {
  o_tanks: number;
  p_tanks: number;
};

export const TankDispenser = (_props: unknown) => {
  const { act, data } = useBackend<TankDispenserData>();
  const { o_tanks, p_tanks } = data;
  return (
    <Window width={275} height={100}>
      <Window.Content>
        <Box m="5px">
          <Button
            disabled={o_tanks === 0}
            icon="arrow-circle-down"
            onClick={() => act('oxygen')}
          >
            {'Dispense Oxygen Tank (' + o_tanks + ')'}
          </Button>
        </Box>
        <Box m="5px">
          <Button
            disabled={p_tanks === 0}
            icon="arrow-circle-down"
            onClick={() => act('plasma')}
          >
            {'Dispense Plasma Tank (' + p_tanks + ')'}
          </Button>
        </Box>
      </Window.Content>
    </Window>
  );
};
