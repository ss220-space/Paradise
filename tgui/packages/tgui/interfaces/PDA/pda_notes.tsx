import { Box, Button, Section } from 'tgui-core/components';
import { useBackend } from '../../backend';

type NoteData = {
  note: string;
};

export const pda_notes = (_props: unknown) => {
  const { act, data } = useBackend<NoteData>();

  const { note } = data;

  return (
    <Box>
      <Section>{note}</Section>
      <Button icon="pen" onClick={() => act('Edit')}>
        Edit
      </Button>
    </Box>
  );
};
