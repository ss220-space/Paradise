import { useBackend } from '../backend';
import { useState } from 'react';
import { Box, Button, Section, Input, Table } from '../components';
import { Window } from '../layouts';

export type Options = {
  id: string;
  text: string;
  min_val: number;
  max_val: number;
  desc_min_check: boolean;
  desc_mid_check: boolean;
  desc_max_check: boolean;
  desc_min_text: string;
  desc_mid_text: string;
  desc_max_text: string;
  default_percentage_calc: boolean;
};

type PollOptionPanelData = {
  option: Options;
  poll_question: string;
  is_rating: boolean;
};

export const PollOptionPanel = (_props: unknown) => {
  const { act, data } = useBackend<PollOptionPanelData>();
  const { poll_question, is_rating, option } = data;

  const [text, set_text] = useState(option.text);
  const [default_percentage_calc, set_default_percentage_calc] = useState(
    option.default_percentage_calc
  );

  const [min_val, _set_min_val] = useState(option.min_val);
  const [max_val, _set_max_val] = useState(option.max_val);

  const [desc_min_check, set_desc_min_check] = useState(option.desc_min_check);
  const [desc_mid_check, set_desc_mid_check] = useState(option.desc_mid_check);
  const [desc_max_check, set_desc_max_check] = useState(option.desc_max_check);
  const [desc_min_text, set_desc_min_text] = useState(option.desc_min_text);
  const [desc_mid_text, set_desc_mid_text] = useState(option.desc_mid_text);
  const [desc_max_text, set_desc_max_text] = useState(option.desc_min_text);

  return (
    <Window
      title="Poll Option Panel"
      width={400}
      height={is_rating ? 320 : 180}
    >
      <Window.Content>
        <Section title={poll_question}>
          <Box>
            <Input width="100%" value={text} onChange={set_text} />
          </Box>
          <br />
          {is_rating ? (
            <Box>
              Minimum value
              <Input value={min_val.toString()} />
              Maximum Value
              <Input value={min_val.toString()} />
              <Table>
                <Table.Row header>
                  <Table.Cell>
                    <Button.Checkbox
                      checked={desc_min_check}
                      onClick={() => set_desc_min_check(!desc_min_check)}
                    >
                      Minimum description
                    </Button.Checkbox>
                  </Table.Cell>
                  <Table.Cell>
                    <Button.Checkbox
                      checked={desc_mid_check}
                      onClick={() => set_desc_mid_check(!desc_mid_check)}
                    >
                      Middle description
                    </Button.Checkbox>
                  </Table.Cell>
                  <Table.Cell>
                    <Button.Checkbox
                      checked={desc_max_check}
                      onClick={() => set_desc_max_check(!desc_max_check)}
                    >
                      Maximum description
                    </Button.Checkbox>
                  </Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell>
                    <Input value={desc_min_text} onEnter={set_desc_min_text} />
                  </Table.Cell>
                  <Table.Cell>
                    <Input value={desc_mid_text} onEnter={set_desc_mid_text} />
                  </Table.Cell>
                  <Table.Cell>
                    <Input value={desc_max_text} onEnter={set_desc_max_text} />
                  </Table.Cell>
                </Table.Row>
              </Table>
              <br />
            </Box>
          ) : null}
          <Button.Checkbox
            checked={default_percentage_calc}
            onClick={() =>
              set_default_percentage_calc(!default_percentage_calc)
            }
          >
            Включить опцию в расчет процента результатов опроса
          </Button.Checkbox>
          <br />
          <Button
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
          >
            Sumbit
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
