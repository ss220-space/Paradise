import { useBackend } from '../backend';
import { Button, Box, Table } from '../components';
import { Window } from '../layouts';

const numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

export const Math = (props, context) => {
  const { act, data } = useBackend(context);
  const { tasks } = data;
  return (
    <Window resizable theme="ntos_terminal">
      <Window.Content>
        <Table border={1}>
          {Object.keys(tasks).map(task =>(
            <Table.Row key={task}>
              {numbers.map(ans => (
                <Table.Cell key={ans}>
                  <Button
                    selected = {tasks[task].choosen === ans}
                    onClick={() => act('checkAnswer', {"taskID": task, "answerID": ans})}>
                    {ans}
                  </Button>
                </Table.Cell>
              ))}
              <Table.Cell>
                MOD(|{tasks[task].op1}{tasks[task].sign}{tasks[task].op2}|)
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
        <br/>
        <Box align="center">
          <Button
            content = "open"
            onClick={() => act('open')}/>
        </Box>
      </Window.Content>
    </Window>
  );
};
