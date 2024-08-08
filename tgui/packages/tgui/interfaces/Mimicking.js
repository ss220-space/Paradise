import { useBackend } from '../backend';
import { Box, Button, Section, Stack } from '../components';
import { Window } from '../layouts';

export const Mimicking = (props, context) => {
  const { act, data } = useBackend(context);
  const slots = data.slots || [];

  return (
    <Window width={400} height={300}>
      <Window.Content scrollable>
        <Stack vertical fill>
          <Section fill scrollable>
            {slots.map((voice) => (
              <Section
                mb={0.5}
                title={voice.name}
                key={voice.id}
                level={2}
                buttons={
                  <>
                    <Button
                      content="Choose"
                      selected={voice.selected}
                      onClick={() => act('Choose', { 'id': voice.id })}
                    />
                    <Button
                      content="Delete"
                      color="bad"
                      onClick={() => act('Delete', { 'id': voice.id })}
                    />
                  </>
                }
              >
                <Box preserveWhitespace textColor="#878787" fontSize="14px">
                  Voice: {voice.voice}
                </Box>
              </Section>
            ))}
            <Button fluid content="Add" onClick={() => act('Add')} />
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
