import type { ReactNode } from 'react';
import { Box, Button, LabeledList } from 'tgui-core/components';
import { useBackend } from '../../backend';

type DoorjackInfo = {
  cable: boolean;
  machine: boolean;
  inprogress: boolean;
};

export const pai_doorjack = (_props: unknown) => {
  const { act, data } = useBackend<PaiData<DoorjackInfo>>();
  const { cable, machine, inprogress } = data.app_data;

  let cableContent: ReactNode;

  if (machine) {
    cableContent = <Button selected content="Connected" />;
  } else {
    cableContent = (
      <Button color={cable ? 'orange' : null} onClick={() => act('cable')}>
        {cable ? 'Extended' : 'Retracted'}
      </Button>
    );
  }

  let hackContent: ReactNode;
  if (machine) {
    hackContent = (
      <LabeledList.Item label="Hack">
        <Box color={inprogress ? 'green' : 'red'}>
          {' '}
          In progress: {inprogress ? 'Yes' : 'No'}{' '}
        </Box>
        {inprogress ? (
          <Button mt={1} color="red" onClick={() => act('cancel')}>
            Abort
          </Button>
        ) : (
          <Button mt={1} onClick={() => act('jack')}>
            Start
          </Button>
        )}
      </LabeledList.Item>
    );
  }

  return (
    <LabeledList>
      <LabeledList.Item label="Cable">{cableContent}</LabeledList.Item>
      {hackContent}
    </LabeledList>
  );
};
