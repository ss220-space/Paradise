import { useBackend } from '../../backend';
import { Box, Button, Section } from '../../components';

type NoteData = {
  note: string;
};

export const pda_notes = (props: unknown) => {
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
