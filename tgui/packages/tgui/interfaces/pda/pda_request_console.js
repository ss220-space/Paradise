import { useBackend } from '../../backend';
import { Box, Button, Section, NoticeBox, Stack } from '../../components';
import { pickPage } from '../../interfaces/RequestConsole';

export const pda_request_console = (props, context) => {
  const { act, data } = useBackend(context);

  const { screen, selected_console, consoles_data, app } = data;

  if (!selected_console) {
    return (
      <Box>
        <Stack vertical>
          {consoles_data.map((console) => {
            return (
              <Stack.Item key={console['name']}>
                <Button
                  content={console['name']}
                  color={
                    console['priority'] === 1
                      ? 'green'
                      : console['priority'] === 2
                        ? 'red'
                        : 'default'
                  }
                  onClick={() => act('select', { name: console['name'] })}
                />
              </Stack.Item>
            );
          })}
        </Stack>
      </Box>
    );
  }
  return (
    <Box>
      {pickPage(screen)}
      {screen === 0 ? (
        <Button
          content="Back to console selection"
          icon="arrow-left"
          onClick={() => act('back')}
        />
      ) : (
        ''
      )}
    </Box>
  );
};
