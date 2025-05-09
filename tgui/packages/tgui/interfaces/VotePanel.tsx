import { useBackend } from '../backend';
import { Button, Box, Section } from '../components';
import { Window } from '../layouts';

type VotePanelData = {
  remaining: number;
  question: string;
  choices: string[];
  user_vote: string;
  counts: number;
  show_counts: boolean;
  show_cancel: boolean;
};

export const VotePanel = (_props: unknown) => {
  const { act, data } = useBackend<VotePanelData>();
  const {
    remaining,
    question,
    choices,
    user_vote,
    counts,
    show_counts,
    show_cancel,
  } = data;
  return (
    <Window width={400} height={500}>
      <Window.Content scrollable>
        <Section title={question}>
          <Box mb={1}>Time remaining: {Math.round(remaining / 10)}s</Box>
          {choices.map((choice) => (
            <Box key={choice}>
              <Button
                onClick={() => act('vote', { 'target': choice })}
                selected={choice === user_vote}
                mb={0.5}
              >
                {choice +
                  (show_counts ? ' (' + (counts[choice] || 0) + ')' : '')}
              </Button>
            </Box>
          ))}
          {!!show_cancel && (
            <Box key={'Cancel'}>
              <Button onClick={() => act('cancel')}>Cancel</Button>
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
