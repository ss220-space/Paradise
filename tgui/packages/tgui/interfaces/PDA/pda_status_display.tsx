import { useBackend } from '../../backend';
import { Box, Button, LabeledList } from '../../components';

type StatusDisplayData = {
  records: Records;
};

type Records = {
  message1: string;
  message2: string;
};

export const pda_status_display = (props: unknown) => {
  const { act, data } = useBackend<StatusDisplayData>();

  const { records } = data;

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Code">
          <Button
            color="transparent"
            icon="trash"
            onClick={() => act('Status', { statdisp: 'blank' })}
          >
            Clear
          </Button>
          <Button
            color="transparent"
            icon="clock"
            onClick={() => act('Status', { statdisp: 'shuttle' })}
          >
            Evac ETA
          </Button>
          <Button
            color="transparent"
            icon="edit"
            onClick={() => act('Status', { statdisp: 'message' })}
          >
            Message
          </Button>
          <Button
            color="transparent"
            icon="exclamation-triangle"
            onClick={() =>
              act('Status', {
                statdisp: 'alert',
                alert: 'redalert',
              })
            }
          >
            Red Alert
          </Button>
          <Button
            color="transparent"
            icon="boxes"
            onClick={() =>
              act('Status', {
                statdisp: 'alert',
                alert: 'default',
              })
            }
          >
            NT Logo
          </Button>
          <Button
            color="transparent"
            icon="lock"
            onClick={() =>
              act('Status', {
                statdisp: 'alert',
                alert: 'lockdown',
              })
            }
          >
            Lockdown
          </Button>
          <Button
            color="transparent"
            icon="biohazard"
            onClick={() =>
              act('Status', {
                statdisp: 'alert',
                alert: 'biohazard',
              })
            }
          >
            Biohazard
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Message line 1">
          <Button
            icon="pen"
            onClick={() => act('Status', { statdisp: 'setmsg1' })}
          >
            {records.message1 + ' (set)'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Message line 2">
          <Button
            icon="pen"
            onClick={() => act('Status', { statdisp: 'setmsg2' })}
          >
            {records.message2 + ' (set)'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};
