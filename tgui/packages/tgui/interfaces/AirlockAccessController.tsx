import { ReactNode } from 'react';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type AirlockAccessData = {
  exterior_status: string;
  interior_status: string;
  processing: boolean;
};

export const AirlockAccessController = (props: unknown) => {
  const { act, data } = useBackend<AirlockAccessData>();
  const { exterior_status, interior_status, processing } = data;
  let exteriorbutton: ReactNode;
  let interiorbutton: ReactNode;
  // If exterior is open, then it can be locked, if closed, it can be cycled to. Vice versa for interior

  if (exterior_status === 'open') {
    exteriorbutton = (
      <Button
        width="50%"
        icon={'exclamation-triangle'}
        disabled={processing}
        onClick={() => act('force_ext')}
      >
        Lock Exterior Door
      </Button>
    );
  } else {
    exteriorbutton = (
      <Button
        width="50%"
        icon={'arrow-circle-left'}
        disabled={processing}
        onClick={() => act('cycle_ext_door')}
      >
        Cycle to Exterior
      </Button>
    );
  }
  if (interior_status === 'open') {
    interiorbutton = (
      <Button
        width="49%"
        icon={'exclamation-triangle'}
        disabled={processing}
        color={
          interior_status === 'open' ? 'red' : processing ? 'yellow' : null
        }
        onClick={() => act('force_int')}
      >
        Lock Interior Door
      </Button>
    );
  } else {
    interiorbutton = (
      <Button
        width="49%"
        icon={'arrow-circle-right'}
        disabled={processing}
        onClick={() => act('cycle_int_door')}
      >
        Cycle to Interior
      </Button>
    );
  }
  return (
    <Window width={330} height={200}>
      <Window.Content>
        <Section title="Information">
          <LabeledList>
            <LabeledList.Item label="External Door Status">
              {exterior_status === 'closed' ? 'Locked' : 'Open'}
            </LabeledList.Item>
            <LabeledList.Item label="Internal Door Status">
              {interior_status === 'closed' ? 'Locked' : 'Open'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Actions">
          <Box>
            {exteriorbutton}
            {interiorbutton}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
