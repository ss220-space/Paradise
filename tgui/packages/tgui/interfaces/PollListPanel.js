import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Divider,
} from '../components';
import { Window } from '../layouts';

export const PollListPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const polls = data.polls || {};

  return (
    <Window title="Poll List Panel" width={700} height={400}>
      <Window.Content scrollable>
        <Section title="Poll List Panel">
          Currently running polls Note when editing polls or their options
          changes are not saved until you press Sumbit Poll.
          <br />
          <Button content="New Poll" onClick={() => act('newpoll')} />
          <LabeledList>
            {polls.map((poll) => (
              <LabeledList.Item key="poll" label={poll.question}>
                <Button
                  content="Edit"
                  onClick={() => act('editpoll', { poll_to_edit: poll.id })}
                />
                <Button
                  content="Delete"
                  onClick={() => act('deletepoll', { poll_to_delete: poll.id })}
                />
                <Button
                  content="Results"
                  onClick={() =>
                    act('resultspoll', { poll_to_result: poll.id })
                  }
                />
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
