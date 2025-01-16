import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
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

  const [question, set_question] = useLocalState(poll, 'question', null);
  const [poll_type, setPollType] = useLocalState(
    poll,
    'poll_type',
    'Single Option'
  );
  const [options_allowed, set_options_allowed] = useLocalState(
    poll,
    'options_allowed',
    null
  );
  const [admin_only, set_admin_only] = useLocalState(poll, 'admin_only', null);
  const [dont_show, set_dont_show] = useLocalState(poll, 'dont_show', null);
  const [allow_revoting, set_allow_revoting] = useLocalState(
    poll,
    'allow_revoting',
    null
  );
  const [interval, set_interval] = useLocalState(poll, 'interval', null);
  const [duration, set_duration] = useLocalState(poll, 'duration', null);
  const [start_datetime, set_start_datetime] = useLocalState(
    poll,
    'start_datetime',
    null
  );
  const [end_datetime, set_end_datetime] = useLocalState(
    poll,
    'end_datetime',
    null
  );
  const [subtitle, set_subtitle] = useLocalState(poll, 'subtitle', null);
  const [minimum_playtime, set_minimum_playtime] = useLocalState(
    poll,
    'minimum_playtime',
    null
  );

  const [run_duration, set_run_duration] = useLocalState(
    poll,
    'run_duration',
    true
  );
  const [run_start, set_run_start] = useLocalState(poll, 'run_start', true);

  return (
    <Window title="Poll Management" width={780} height={640}>
      <Window.Content scrollable>
        <Section title="Poll Creation">
          <Box>
            <Dropdown
              disabled={has_poll}
              options={poll_types}
              selected={poll_type}
              onSelected={(value) => setPollType(value)}
            />
            Question
            <Input
              placeholder="Question goes here"
              value={question}
              onChange={(_, value) => set_question(value)}
            />
            Multiple-choice options allowed
            <NumberInput
              value={options_allowed}
              onChange={(_, value) => set_options_allowed(!options_allowed)}
            />
            <ButtonCheckbox
              checked={admin_only}
              onClick={() => set_admin_only(!admin_only)}
            />
            <ButtonCheckbox
              checked={dont_show}
              onClick={() => set_dont_show(!dont_show)}
            />
            <ButtonCheckbox
              checked={allow_revoting}
              onClick={() => set_allow_revoting(!allow_revoting)}
            />
          </Box>
          <Divider />
          <Stack fill horizontal>
            <Stack.Item width="50%">
              Duration
              <Box>
                <Button
                  content={run_duration ? 'Run for' : 'Run until'}
                  onClick={() => set_run_duration(!run_duration)}
                />
                <NumberInput
                  placeholder="Amount number"
                  value={duration}
                  onChange={(_, value) => set_duration(value)}
                />
                <Dropdown
                  options={interval_types}
                  selected={interval}
                  onSelected={(value) => set_interval(value)}
                />
              </Box>
              <br />
              Until:{' '}
              <Input
                placeholder="YYYY-MM-DD HH:MM:SS"
                value={end_datetime}
                onChange={(_, value) => set_end_datetime(value)}
              />
            </Stack.Item>
            <Stack.Item width="50%">
              Start
              <Box>
                <Button
                  content={run_start ? 'Now' : 'At datetime'}
                  onClick={() => set_run_start(!run_start)}
                />
              </Box>
              <Input
                placeholder="YYYY-MM-DD HH:MM:SS"
                value={start_datetime}
                onChange={(_, value) => set_start_datetime(value)}
              />
              Minimum playtime to vote (in hours)
              <Box>
                <NumberInput
                  placeholder="Number of hours"
                  value={minimum_playtime}
                  onChange={(_, value) => set_minimum_playtime(value)}
                />
              </Box>
            </Stack.Item>
          </Stack>
          <Stack fill>
            <Stack.Item>
              Subtitle (Optional)
              <Input
                rows="12"
                value={subtitle}
                onChange={(_, value) => set_subtitle(value)}
              />
            </Stack.Item>
            <Stack.Item>
              {has_poll ? <PollUpdateTab /> : <PollCreationTab />}
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

const PollUpdateTab = (props, context) => {
  const { act, data } = useBackend(context);
  const { poll } = data;
  const [clear_votes, set_clear_votes] = useLocalState(
    poll,
    'clear_votes',
    null
  );

  return (
    <Stack>
      <Stack.Item>
        <Button
          content="Submit Poll"
          onClick={() => act('submit_poll')}
          // onClick={() => act('setstat', { statdisp: 'alert', alert: ib.alert })}
        />
        <ButtonCheckbox
          content="Clear votes on edit"
          checked={clear_votes}
          onClick={() => set_clear_votes(!clear_votes)}
        />
      </Stack.Item>
      <Stack.Item>
        <Button
          content="Clear poll votes"
          onClick={() => act('clear_poll_votes')}
        />
        {poll.poll_votes} players have voted
      </Stack.Item>
    </Stack>
  );
};

const PollCreationTab = (props, context) => {
  const { act, data } = useBackend(context);

  retun(
    <Stack>
      <Stack.Item>
        <Button
          content="Initliaze Question"
          onClick={() => act('initialize_poll')}
        />
      </Stack.Item>
    </Stack>
  );
};

const PollMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { poll } = data;
  const [poll_type, setPollType] = useLocalState(
    poll,
    'poll_type',
    'Single Option'
  );

  return (
    <Stack>
      <Stack.Item>
        <Button content="Add Option" onClick={() => act('add_poll_option')} />
      </Stack.Item>
      <Stack.Item>
        <LabeledList>
          {poll.options.map((option) => (
            <LabeledList.Item key="option" label={'Option ' + option.num}>
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
              <br />
              {option.text}
              {poll_type === 'Rating' ? null : (
                <Box>
                  Minimum value: {option.min_val} | Maximum value:{' '}
                  {option.max_val}
                  Minimum description: {option.desc_min}
                  Middle description: {option.desc_mid}
                  Maximum description: {option.desc_max}
                </Box>
              )}
              <Divider />
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Stack.Item>
    </Stack>
  );
};
