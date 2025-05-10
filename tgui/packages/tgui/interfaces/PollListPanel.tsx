import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Divider } from '../components';
import { Window } from '../layouts';

type PollListPanelData = {
  polls: Poll[];
};

type Poll = {
  question: string;
  id: string;
  description: string;
};

export const PollListPanel = (_props: unknown) => {
  const { act, data } = useBackend<PollListPanelData>();
  const polls = data.polls || [];

  return (
    <Window title="Poll List Panel" width={700} height={400}>
      <Window.Content scrollable>
        <Section title="Poll List Panel">
          Currently running polls Note when editing polls or their options
          changes are not saved until you press Sumbit Poll.
          <br />
          <Button onClick={() => act('newpoll')}>New Poll</Button>
          <LabeledList>
            {polls.map((poll) => (
              <LabeledList.Item key="poll" label={poll.question}>
                <Button
                  onClick={() => act('editpoll', { poll_to_edit: poll.id })}
                >
                  Edit
                </Button>
                <Button
                  onClick={() => act('deletepoll', { poll_to_delete: poll.id })}
                >
                  Delete
                </Button>
                <Button
                  onClick={() =>
                    act('resultspoll', { poll_to_result: poll.id })
                  }
                >
                  Results
                </Button>
                <Box>{poll.description}</Box>
                <Divider />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
