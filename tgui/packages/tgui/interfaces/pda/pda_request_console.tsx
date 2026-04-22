import { useBackend } from '../../backend';
import { Box, Button, Stack } from '../../components';
import { pages } from '../../interfaces/RequestConsole';

type RequestConsolePdaData = {
  screen: number;
  selected_console: string;
  consoles_data: Console[];
};

type Console = {
  priority: number;
  name: string;
  muted: boolean;
};

export const pda_request_console = (props: unknown) => {
  const { act, data } = useBackend<RequestConsolePdaData>();

  const { screen, selected_console, consoles_data } = data;

  if (!selected_console) {
    return (
      <Box>
        <Stack vertical>
          {consoles_data.map((console) => {
            return (
              <Stack.Item key={console.name}>
                <Stack>
                  <Stack.Item>
                    <Button
                      color={
                        console.priority === 1
                          ? 'green'
                          : console.priority === 2
                            ? 'red'
                            : 'default'
                      }
                      onClick={() => act('select', { name: console.name })}
                    >
                      {console.name}
                    </Button>
                    <Button
                      icon={console.muted ? 'volume-mute' : 'volume-up'}
                      onClick={() => act('mute', { name: console.name })}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            );
          })}
        </Stack>
      </Box>
    );
  }
  return (
    <Box>
      {(pages[screen] || pages.default)()}
      {screen === 0 ? (
        <Button icon="arrow-left" onClick={() => act('back')}>
          Back to console selection
        </Button>
      ) : (
        ''
      )}
    </Box>
  );
};
