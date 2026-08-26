import { Box, Button, NoticeBox, Section, Table } from '../components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  previous_attempts: Attempts[];
  attempts_left: number;
};

type Attempts = {
  attempt: string;
  bulls: number;
  cows: number;
};

const check_attempts = (attempts_to_check: number) => {
  return attempts_to_check === 1
    ? 'при следующей неудачной попытке доступа.'
    : `после ${attempts_to_check} неудачных попыток доступа.`;
};

const BULLS_COWS_INFO = `Коды состоят из последовательности неповторяющихся цифр.
Каждая неверная попытка вернет количество правильных цифр в правильных позициях,
и количество правильных цифр в неправильных позициях.`;

export const AbandonedCrate = (props) => {
  const { data } = useBackend<Data>();
  const { previous_attempts, attempts_left } = data;

  return (
    <Window width={335} height={190 + previous_attempts.length * 35}>
      <Window.Content scrollable>
        <Section
          title="Деко-кодовый замок"
          buttons={
            <Button
              tooltip={BULLS_COWS_INFO}
              icon="info"
              tooltipPosition="left"
            />
          }
        >
          <NoticeBox color="bad">
            Бомба защиты от несанкционированного доступа активируется{' '}
            {check_attempts(attempts_left)}
          </NoticeBox>
          <Table>
            {!!previous_attempts.length && (
              <Table.Row fontSize="125%" bold>
                <Table.Cell
                  collapsing
                  color="white"
                  textAlign="center"
                  pr="5px"
                >
                  Попытка
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  <Button
                    tooltip={`Правильные цифры на правильных позициях`}
                    icon="check"
                    color="green"
                    tooltipPosition="top"
                  />
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  <Button
                    tooltip={`Правильные цифры на неправильных позициях`}
                    icon="asterisk"
                    color="yellow"
                    tooltipPosition="top"
                  />
                </Table.Cell>
              </Table.Row>
            )}
            {previous_attempts.map((previous_attempts) => (
              <Table.Row
                key={previous_attempts.attempt}
                style={{ borderTop: '2px solid #222' }}
              >
                <Table.Cell collapsing textAlign="center" pr="5px">
                  <Box color="white" inline fontSize="125%">
                    {previous_attempts.attempt}
                  </Box>
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  <Box color="green" inline fontSize="125%">
                    {previous_attempts.bulls}
                  </Box>
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  <Box color="yellow" inline fontSize="125%">
                    {previous_attempts.cows}
                  </Box>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Window.Content>
    </Window>
  );
};
