import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  NumberInput,
  Input,
  LabeledList,
  Section,
  Stack,
  TextArea,
} from '../components';
import { ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

export const PollManagement = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    poll,
    has_poll,
    poll_types, // static
    interval_types,
  } = data;

  const [question, set_question] = useLocalState(
    context,
    'question',
    poll.question
  );
  const [poll_type, setPollType] = useLocalState(
    context,
    'poll_type',
    poll.poll_type
  );
  const [options_allowed, set_options_allowed] = useLocalState(
    context,
    'options_allowed',
    poll.options_allowed
  );
  const [admin_only, set_admin_only] = useLocalState(
    context,
    'admin_only',
    poll.admin_only
  );
  const [dont_show, set_dont_show] = useLocalState(
    context,
    'dont_show',
    poll.dont_show
  );
  const [allow_revoting, set_allow_revoting] = useLocalState(
    context,
    'allow_revoting',
    poll.allow_revoting
  );
  const [interval, set_interval] = useLocalState(
    context,
    'interval',
    poll.interval
  );
  const [duration, set_duration] = useLocalState(
    context,
    'duration',
    poll.duration
  );
  const [start_datetime, set_start_datetime] = useLocalState(
    context,
    'start_datetime',
    poll.start_datetime
  );
  const [end_datetime, set_end_datetime] = useLocalState(
    context,
    'end_datetime',
    poll.end_datetime
  );
  const [subtitle, set_subtitle] = useLocalState(
    context,
    'subtitle',
    poll.subtitle
  );
  const [minimum_playtime, set_minimum_playtime] = useLocalState(
    context,
    'minimum_playtime',
    poll.minimum_playtime
  );

  const [run_duration, set_run_duration] = useLocalState(
    context,
    'run_duration',
    poll.run_duration
  );
  const [run_start, set_run_start] = useLocalState(
    context,
    'run_start',
    poll.run_start
  );
  const [clear_votes, set_clear_votes] = useLocalState(
    context,
    'clear_votes',
    poll.clear_votes
  );

  return (
    <Window title="Poll Management" width={600} height={640}>
      <Window.Content scrollable>
        <Section title="Poll Creation">
          <Box>
            Question:
            <Input
              width={40}
              placeholder="Question goes here"
              value={question}
              onChange={(_, value) => set_question(value)}
            />
            <br />
            <Box inline pl={1}>
              Choice:
            </Box>
            <Dropdown
              width={10}
              disabled={has_poll}
              options={poll_types}
              selected={poll_type}
              onSelected={(value) => setPollType(value)}
            />
            {has_poll & (poll_type !== 'Multiple Choice') ? null : (
              <Box inline>
                Mult-choice options allowed:
                <NumberInput
                  width={3}
                  minValue={0}
                  maxValue={100}
                  value={options_allowed}
                  onChange={(_, value) => set_options_allowed(!options_allowed)}
                />
              </Box>
            )}
            <br />
            <ButtonCheckbox
              content="Admin only"
              checked={admin_only}
              onClick={() => set_admin_only(!admin_only)}
            />
            <ButtonCheckbox
              content="Don't show"
              checked={dont_show}
              onClick={() => set_dont_show(!dont_show)}
            />
            <ButtonCheckbox
              content="Allow revoting"
              checked={allow_revoting}
              onClick={() => set_allow_revoting(!allow_revoting)}
            />
            Min. playtime to vote (in hours):
            <Box inline ml={1}>
              <NumberInput
                width={3}
                placeholder="Number of hours"
                value={minimum_playtime}
                onChange={(_, value) => set_minimum_playtime(value)}
              />
            </Box>
          </Box>
          <Stack fill>
            <Stack.Item width="50%">
              <Box>Duration</Box>
              <Button
                icon="chevron-right"
                py={1}
                content={run_duration ? 'Run for' : 'Run until'}
                onClick={() => set_run_duration(!run_duration)}
              />
              {run_duration ? (
                <Box inline>
                  <NumberInput
                    placeholder="Amount number"
                    width={3}
                    minValue={0}
                    maxValue={100}
                    value={duration}
                    onChange={(_, value) => set_duration(value)}
                  />
                  <Dropdown
                    options={interval_types}
                    selected={interval}
                    onSelected={(value) => set_interval(value)}
                  />
                </Box>
              ) : (
                <Box inline>
                  Until:
                  <br />
                  <Input
                    width={15}
                    placeholder="YYYY-MM-DD HH:MM:SS"
                    value={end_datetime ? end_datetime : '1970-01-01 00:00:01'}
                    onChange={(_, value) => set_end_datetime(value)}
                  />
                </Box>
              )}
            </Stack.Item>
            <Stack.Item>
              <Box>Start</Box>
              <Button
                content={run_start ? 'Now' : 'At datetime'}
                onClick={() => set_run_start(!run_start)}
              />
              {run_start ? null : (
                <Input
                  width={15}
                  placeholder="YYYY-MM-DD HH:MM:SS"
                  value={
                    start_datetime ? start_datetime : '1970-01-01 00:00:01'
                  }
                  onChange={(_, value) => set_start_datetime(value)}
                />
              )}
            </Stack.Item>
          </Stack>
          <Stack fill>
            <Stack.Item>
              Subtitle (Optional)
              <br />
              <TextArea
                height={10}
                width={20}
                rows="12"
                value={subtitle}
                onChange={(_, value) => set_subtitle(value)}
              />
            </Stack.Item>
            <Stack.Item>
              {has_poll ? (
                <Stack vertical>
                  <Stack.Item>
                    <Button
                      content="Clear poll votes"
                      onClick={() => act('clear_poll_votes')}
                    />
                    {poll.poll_votes} players have voted
                  </Stack.Item>
                  <Stack.Item>
                    <ButtonCheckbox
                      content="Clear votes on edit"
                      checked={clear_votes}
                      onClick={() => set_clear_votes(!clear_votes)}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      p={2}
                      content="Submit Poll"
                      onClick={() =>
                        act('submit_poll', {
                          question: question,
                          poll_type: poll_type,
                          options_allowed: options_allowed,
                          admin_only: admin_only,
                          dont_show: dont_show,
                          allow_revoting: allow_revoting,
                          interval: interval,
                          duration: duration,
                          start_datetime: start_datetime,
                          end_datetime: end_datetime,
                          subtitle: subtitle,
                          poll_votes: minimum_playtime,
                          run_duration: run_duration,
                          run_start: run_start,
                          clear_votes: clear_votes,
                        })
                      }
                      // onClick={() => act('setstat', { statdisp: 'alert', alert: ib.alert })}
                    />
                  </Stack.Item>
                </Stack>
              ) : (
                <Stack>
                  <Stack.Item>
                    <Button
                      p={1}
                      m={2}
                      content="Initliaze Question"
                      onClick={() =>
                        act('initialize_poll', {
                          question: question,
                          poll_type: poll_type,
                          options_allowed: options_allowed,
                          admin_only: admin_only,
                          dont_show: dont_show,
                          allow_revoting: allow_revoting,
                          interval: interval,
                          duration: duration,
                          start_datetime: start_datetime,
                          end_datetime: end_datetime,
                          subtitle: subtitle,
                          poll_votes: minimum_playtime,
                          run_duration: run_duration,
                          run_start: run_start,
                          clear_votes: clear_votes,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              )}
            </Stack.Item>
          </Stack>
        </Section>
        <Section title="Questions Manage">
          {has_poll ? (
            <PollMenu />
          ) : (
            <Box>
              First enter the poll question details and press Initialize
              Question. Then add poll options and press Submit Poll to save and
              create the question and options. No options are required for Text
              Reply polls.
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

const PollMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { poll } = data;
  const { options } = poll;
  const [poll_type, setPollType] = useLocalState(context, 'poll_type', null);

  return (
    <Stack>
      <Stack.Item>
        <Button content="Add Option" onClick={() => act('add_poll_option')} />
      </Stack.Item>
      <Stack.Item>
        <LabeledList>
          {options.map((option) => (
            <LabeledList.Item key="option" label={'Option ' + option.num}>
              {option.text}
              {poll_type === 'Rating' ? (
                <Box>
                  Minimum value: {option.min_val} | Maximum value:{' '}
                  {option.max_val}
                  Minimum description: {option.desc_min}
                  Middle description: {option.desc_mid}
                  Maximum description: {option.desc_max}
                </Box>
              ) : null}
              <br />
              <Button
                content="Edit"
                onClick={() =>
                  act('edit_poll_option', { option_to_edit: option.id })
                }
              />
              <Button
                content="Delete"
                onClick={() =>
                  act('delete_poll_option', { option_to_delete: option.id })
                }
              />
              <Divider />
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Stack.Item>
    </Stack>
  );
};
