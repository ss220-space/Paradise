import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Divider,
  Input,
} from '../components';
import { ButtonCheckbox } from '../components/Button';
import { Window } from '../layouts';

export const PollOptionPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { poll_question, is_rating, option } = data;

  const [text, set_text] = useLocalState(context, 'text', option.text);
  const [default_percentage_calc, set_default_percentage_calc] = useLocalState(
    context,
    'default_percentage_calc',
    option.default_percentage_calc
  );

  const [min_val, set_min_val] = useLocalState(
    context,
    'min_val',
    option.min_val
  );
  const [max_val, set_max_val] = useLocalState(
    context,
    'max_val',
    option.max_val
  );

  const [desc_min_check, set_desc_min_check] = useLocalState(
    context,
    'desc_min_check',
    option.desc_min_check
  );
  const [desc_mid_check, set_desc_mid_check] = useLocalState(
    context,
    'desc_mid_check',
    option.desc_mid_check
  );
  const [desc_max_check, set_desc_max_check] = useLocalState(
    context,
    'desc_max_check',
    option.desc_max_check
  );
  const [desc_min_text, set_desc_min_text] = useLocalState(
    context,
    'desc_min_text',
    option.desc_min_text
  );
  const [desc_mid_text, set_desc_mid_text] = useLocalState(
    context,
    'desc_mid_text',
    option.desc_min_text
  );
  const [desc_max_text, set_desc_max_text] = useLocalState(
    context,
    'desc_max_text',
    option.desc_min_text
  );

  return (
    <Window
      title="Poll Option Panel"
      width={400}
      height={is_rating ? 320 : 180}
    >
      <Window.Content>
        <Section title={poll_question}>
          <Box>
            <Input
              width="100%"
              content={text}
              onChange={(_, value) => set_text(value)}
            />
          </Box>
          <br />
          {is_rating ? (
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
          ) : null}
          <ButtonCheckbox
            checked={default_percentage_calc}
            content="Включить опцию в расчет процента результатов опроса"
            onClick={() =>
              set_default_percentage_calc(!default_percentage_calc)
            }
          />
          <br />
          <Button
            content="Sumbit"
            onClick={() =>
              act('submit_option', {
                text: text,
                default_percentage_calc: default_percentage_calc,
                min_val: min_val,
                max_val: max_val,
                desc_min_check: desc_min_check,
                desc_mid_check: desc_mid_check,
                desc_max_check: desc_max_check,
                desc_min_text: desc_min_text,
                desc_mid_text: desc_mid_text,
                desc_max_text: desc_max_text,
              })
            }
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
