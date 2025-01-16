import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Divider,
} from '../components';
import { ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

export const PollOptionPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { poll_question, is_rating, option_list } = data;

  const [text, set_text] = useLocalState(option_list, 'text', null);
  const [default_percentage_calc, set_default_percentage_calc] = useLocalState(
    option_list,
    'default_percentage_calc',
    false
  );

  return (
    <Window
      title="Poll Option Panel"
      width={700}
      height={is_rating ? 320 : 180}
    >
      <Window.Content>
        <Section title={poll_question}>
          <Input content={text} onChange={(_, value) => set_text(value)} />
          <br />
          {is_rating ? <PollRating /> : null}
          <ButtonCheckbox
            checked={default_percentage_calc}
            content="Include option in poll's results percentage calculation"
            onClick={() =>
              set_default_percentage_calc(!default_percentage_calc)
            }
          />
          <Button content="Sumbit" onClick={() => act('submit_option')} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const PollRating = (props, context) => {
  const { act, data } = useBackend(context);
  const { option_list } = data;

  const [min_val, set_min_val] = useLocalState(option_list, 'min_val', '0');
  const [max_val, set_max_val] = useLocalState(option_list, 'max_val', '10');

  const [desc_min_check, set_desc_min_check] = useLocalState(
    option_list,
    'desc_min_check',
    false
  );
  const [desc_mid_check, set_desc_mid_check] = useLocalState(
    option_list,
    'desc_mid_check',
    false
  );
  const [desc_max_check, set_desc_max_check] = useLocalState(
    option_list,
    'desc_max_check',
    false
  );

  const [desc_min_text, set_desc_min_text] = useLocalState(
    option_list,
    'desc_min_text',
    ''
  );
  const [desc_mid_text, set_desc_mid_text] = useLocalState(
    option_list,
    'desc_mid_text',
    ''
  );
  const [desc_max_text, set_desc_max_text] = useLocalState(
    option_list,
    'desc_max_text',
    ''
  );

  return (
    <Box>
      Minimum value
      <Input value={min_val} />
      Maximum Value
      <Input value={max_val} />
      <Table>
        <Table.Row header>
          <Table.Cell>
            <ButtonCheckbox
              content="Minimum description"
              checked={desc_min_check}
              onClick={() => set_desc_min_check(!desc_min_check)}
            />
          </Table.Cell>
          <Table.Cell>
            <ButtonCheckbox
              content="Middle description"
              checked={desc_mid_check}
              onClick={() => set_desc_mid_check(!desc_mid_check)}
            />
          </Table.Cell>
          <Table.Cell>
            <ButtonCheckbox
              content="Maximum description"
              checked={desc_max_check}
              onClick={() => set_desc_max_check(!desc_max_check)}
            />
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Input
              value={desc_min_text}
              onEnter={(_, value) => set_desc_min_text(value)}
            />
          </Table.Cell>
          <Table.Cell>
            <Input
              value={desc_mid_text}
              onEnter={(_, value) => set_desc_mid_text(value)}
            />
          </Table.Cell>
          <Table.Cell>
            <Input
              value={desc_max_text}
              onEnter={(_, value) => set_desc_max_text(value)}
            />
          </Table.Cell>
        </Table.Row>
      </Table>
      <br />
    </Box>
  );
};
