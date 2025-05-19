import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';

type WiresData = {
  wires: Wire[];
  status?: string[];
};

type Wire = {
  seen_color: string;
  color_name: string;
  cut: boolean;
  color: string;
  attached: boolean;
  wire: string;
};

export const Wires = (_props: unknown) => {
  const { act, data } = useBackend<WiresData>();

  const wires = data.wires || [];
  const statuses = data.status || [];
  const dynamicHeight =
    130 + wires.length * 23 + (data.status ? 0 : 15 + statuses.length * 17);

  return (
    <Window width={350} height={dynamicHeight}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section fill scrollable>
              <LabeledList>
                {wires.map((wire) => (
                  <LabeledList.Item
                    key={wire.seen_color}
                    className="candystripe"
                    label={wire.color_name}
                    labelColor={wire.seen_color}
                    color={wire.seen_color}
                    buttons={
                      <>
                        <Button
                          content={wire.cut ? 'Mend' : 'Cut'}
                          onClick={() =>
                            act('cut', {
                              wire: wire.color,
                            })
                          }
                        >
                          {wire.cut ? 'Mend' : 'Cut'}
                        </Button>
                        <Button
                          onClick={() =>
                            act('pulse', {
                              wire: wire.color,
                            })
                          }
                        >
                          Pulse
                        </Button>
                        <Button
                          onClick={() =>
                            act('attach', {
                              wire: wire.color,
                            })
                          }
                        >
                          {wire.attached ? 'Detach' : 'Attach'}
                        </Button>
                      </>
                    }
                  >
                    {!!wire.wire && <i>({wire.wire})</i>}
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Section>
          </Stack.Item>
          {!!statuses.length && (
            <Stack.Item>
              <Section>
                {statuses.map((status) => (
                  <Box key={status} color="lightgray">
                    {status}
                  </Box>
                ))}
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
