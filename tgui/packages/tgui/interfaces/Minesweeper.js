import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

export const Minesweeper = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    matrix,
  } = data;

  const NumColor = {
    1: "blue",
    2: "green",
    3: "red",
    4: "darkblue",
    5: "brown",
    6: "lightblue",
    7: "black",
    8: "white",
  }

  const [
    currentMode,
    setMode,
  ] = useLocalState(context, 'mode', "bomb");

  return (
    <Window theme="ntOS95"
      resizable>
      <Window.Content scrollable>
        <Section title="Игровое поле"
          buttons={
            <Fragment>
              <Button
                content="*"
                textColor="black"
                selected={currentMode==="bomb"}
                onClick={() => setMode("bomb")}
              />
              <Button
                content="►"
                textColor="red"
                selected={currentMode==="flag"}
                onClick={() => setMode("flag")}
              />
            </Fragment>
          }>
          {Object.keys(matrix).map(row => (
            <Box key={row}>
              {Object.keys(matrix[row]).map(cell => (
                <Button key={cell}
                  height="20px"
                  width="20px"
                  style={{
                    'vertical-align': 'middle',
                    margin: '1px',
                  }}
                  bold
                  color={matrix[row][cell]["open"] ? "red" : " "}
                  textColor={matrix[row][cell]["open"] ? (matrix[row][cell]["bomb"] ? "black" : NumColor[matrix[row][cell]["around"]])
                    : (matrix[row][cell]["flag"] ? "red" : "gray")}
                  onClick={() => act("Square", {"X": row, "Y": cell, "mode": currentMode})}>
                  {matrix[row][cell]["open"] ?
                  (matrix[row][cell]["bomb"] ? "*" : (matrix[row][cell]["around"] ? matrix[row][cell]["around"] : "0"))
                  : (matrix[row][cell]["flag"] ? "►" : " ")}
                </Button>
              ))}
            </Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
