import { useBackend } from '../../backend';
import { Box, Button, Section, NoticeBox } from '../../components';
import { pickPage } from '../../interfaces/RequestConsole';

export const pda_request_console = (props, context) => {
  const { act, data } = useBackend(context);

  const { screen, not_found } = data;

  if (not_found) {
    return (
      <NoticeBox>
        Невозможно подключиться к консоли запросов. Консоль не найдена или не
        существует.
      </NoticeBox>
    );
  }
  return <Box>{pickPage(screen)}</Box>;
};
