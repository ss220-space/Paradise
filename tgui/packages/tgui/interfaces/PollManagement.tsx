import { useBackend } from '../backend';
import { useState } from 'react';
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
import { Window } from '../layouts';

type PollManagementData = {
  poll: Poll;
  has_poll: boolean;
  poll_types: string[]; // static
  interval_types: string[];
};

type Poll = {
  question: string;
  poll_type: string;
  options_allowed: boolean;
  admin_only: boolean;
  dont_show: boolean;
  allow_revoting: boolean;
  interval: string;
  duration: number;
  start_datetime: string;
  end_datetime: string;
  subtitle: string;
  minimum_playtime: number;
  run_duration: boolean;
  run_start: boolean;
  poll_votes: number;
  clear_votes: boolean;
  options: Options[];
};

type Options = {
  id: string;
  text: string;
  min_val: number;
  max_val: number;
  desc_min: string;
  desc_mid: string;
  desc_max: string;
  num: number;
};

export const PollManagement = (_props: unknown) => {
  const { act, data } = useBackend<PollManagementData>();
  const {
    poll,
    has_poll,
    poll_types, // static
    interval_types,
  } = data;

  const [question, set_question] = useState(poll.question);
  const [poll_type, setPollType] = useState(poll.poll_type);
  const [options_allowed, set_options_allowed] = useState(poll.options_allowed);
  const [admin_only, set_admin_only] = useState(poll.admin_only);
  const [dont_show, set_dont_show] = useState(poll.dont_show);
  const [allow_revoting, set_allow_revoting] = useState(poll.allow_revoting);
  const [interval, set_interval] = useState(poll.interval);
  const [duration, set_duration] = useState(poll.duration);
  const [start_datetime, set_start_datetime] = useState(poll.start_datetime);
  const [end_datetime, set_end_datetime] = useState(poll.end_datetime);
  const [subtitle, set_subtitle] = useState(poll.subtitle);
  const [minimum_playtime, set_minimum_playtime] = useState(
    poll.minimum_playtime
  );

  const [run_duration, set_run_duration] = useState(poll.run_duration);
  const [run_start, set_run_start] = useState(poll.run_start);
  const [clear_votes, set_clear_votes] = useState(poll.clear_votes);

  return (
    <Window title="Poll Management" width={600} height={640}>
      <Window.Content scrollable>
        <Section title="Poll Creation">
          <Box>
            <Stack vertical>
              <Stack>
                <Stack.Item>Question:</Stack.Item>
                <Stack.Item>
                  <Input
                    width={40}
                    placeholder="Question goes here"
                    value={question}
                    onChange={(_, value) => set_question(value)}
                  />
                </Stack.Item>
              </Stack>
              <br />
              <Stack mb={2}>
                <Box mr={45}>Choice:</Box>{' '}
                <Dropdown
                  width={20}
                  disabled={has_poll}
                  options={poll_types}
                  selected={poll_type}
                  onSelected={(value) => setPollType(value)}
                />
              </Stack>
              {has_poll && poll_type !== 'Multiple Choice' ? null : (
                <Box inline>
                  Mult-choice options allowed:
                  <Button.Checkbox
                    checked={options_allowed}
                    onClick={() => set_options_allowed(!options_allowed)}
                  />
                </Box>
              )}
              <br />
              <Stack mb={2}>
                <Button.Checkbox
                  checked={admin_only}
                  onClick={() => set_admin_only(!admin_only)}
                >
                  Admin only
                </Button.Checkbox>
                <Button.Checkbox
                  checked={dont_show}
                  onClick={() => set_dont_show(!dont_show)}
                >
                  {"Don't show"}
                </Button.Checkbox>
                <Button.Checkbox
                  checked={allow_revoting}
                  onClick={() => set_allow_revoting(!allow_revoting)}
                >
                  Allow revoting
                </Button.Checkbox>
              </Stack>
              <Stack mb={2}>
                <Stack.Item>Min. playtime to vote (in hours):</Stack.Item>
                <Stack.Item inline ml={1}>
                  <NumberInput
                    width={3}
                    minValue={0}
                    step={1}
                    maxValue={Infinity}
                    value={minimum_playtime}
                    onChange={(value) => set_minimum_playtime(value)}
                  />
                </Stack.Item>
              </Stack>
            </Stack>
          </Box>
          <Stack fill vertical>
            <Stack.Item width="50%">
              <Stack mb={2}>
                <Stack.Item>Duration</Stack.Item>
                <Stack.Item>
                  <Button
                    icon="chevron-right"
                    onClick={() => set_run_duration(!run_duration)}
                  >
                    {run_duration ? 'Run for' : 'Run until'}
                  </Button>
                </Stack.Item>
                {run_duration ? (
                  <Stack.Item>
                    <Stack>
                      <NumberInput
                        width={3}
                        minValue={0}
                        maxValue={100}
                        step={1}
                        value={duration}
                        onChange={(value) => set_duration(value)}
                      />
                      <Dropdown
                        options={interval_types}
                        selected={interval}
                        onSelected={(value) => set_interval(value)}
                      />
                    </Stack>
                  </Stack.Item>
                ) : (
                  <Stack.Item>
                    <Stack>
                      <Stack.Item>Until:</Stack.Item>
                      <Stack.Item>
                        <Input
                          width={15}
                          placeholder="YYYY-MM-DD HH:MM:SS"
                          value={
                            end_datetime ? end_datetime : '1970-01-01 00:00:01'
                          }
                          onChange={(_, value) => set_end_datetime(value)}
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                )}
              </Stack>
            </Stack.Item>
            <Stack.Item mb={5}>
              <Stack>
                <Box>Start</Box>
                <Button onClick={() => set_run_start(!run_start)}>
                  {run_start ? 'Now' : 'At datetime'}
                </Button>
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
              </Stack>
            </Stack.Item>
          </Stack>
          <Stack fill>
            <Stack.Item>
              Subtitle (Optional)
              <br />
              <TextArea
                height={10}
                width={20}
                value={subtitle}
                onChange={(_, value) => set_subtitle(value)}
              />
            </Stack.Item>
            <Stack.Item>
              {has_poll ? (
                <Stack vertical>
                  <Stack.Item>
                    <Button onClick={() => act('clear_poll_votes')}>
                      Clear poll votes
                    </Button>
                    {poll.poll_votes} players have voted
                  </Stack.Item>
                  <Stack.Item>
                    <Button.Checkbox
                      checked={clear_votes}
                      onClick={() => set_clear_votes(!clear_votes)}
                    >
                      Clear votes on edit
                    </Button.Checkbox>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      p={2}
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
                    >
                      Submit Poll
                    </Button>
                  </Stack.Item>
                </Stack>
              ) : (
                <Stack>
                  <Stack.Item>
                    <Button
                      p={1}
                      m={2}
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
                    >
                      Initliaze Question
                    </Button>
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

const PollMenu = (_props: unknown) => {
  const { act, data } = useBackend<PollManagementData>();
  const { poll } = data;
  const { options } = poll;
  const [poll_type, setPollType] = useState(null);

  return (
    <Stack>
      <Stack.Item>
        <Button onClick={() => act('add_poll_option')}>Add Option</Button>
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
                onClick={() =>
                  act('edit_poll_option', { option_to_edit: option.id })
                }
              >
                Edit
              </Button>
              <Button
                onClick={() =>
                  act('delete_poll_option', { option_to_delete: option.id })
                }
              >
                Delete
              </Button>
              <Divider />
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Stack.Item>
    </Stack>
  );
};
