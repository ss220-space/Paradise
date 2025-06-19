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
            Очистить
          </Button>
          <Button
            color="transparent"
            icon="clock"
            onClick={() => act('Status', { statdisp: 'shuttle' })}
          >
            Время прибытия эвак. шаттла
          </Button>
          <Button
            color="transparent"
            icon="edit"
            onClick={() => act('Status', { statdisp: 'message' })}
          >
            Сообщение
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
            Тревога
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
            Логотип НТ
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
            Локдаун
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
            Биоугроза
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Первая строка сообщения:">
          <Button
            icon="pen"
            onClick={() => act('Status', { statdisp: 'setmsg1' })}
          >
            {records.message1 + ' (изменить)'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Вторая строка сообщения:">
          <Button
            icon="pen"
            onClick={() => act('Status', { statdisp: 'setmsg2' })}
          >
            {records.message2 + ' (изменить)'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};
