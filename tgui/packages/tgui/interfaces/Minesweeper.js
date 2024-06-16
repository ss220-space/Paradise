import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, Section } from '../components';
import { Window } from '../layouts';
import { FlexItem } from '../components/Flex';

export const Minesweeper = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    matrix,
    showMessage,
    tokens,
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
      <Window.Content>
        <Section title="Игровое поле"
          textAlign="center"
          height="100%"
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
                    height="25px"
                    width="25px"
                    className={matrix[row][cell]["open"] ? "Minesweeper__open" : "Minesweeper__closed"}
                    bold
                    color="transparent"
                    textColor={matrix[row][cell]["open"] ? (matrix[row][cell]["bomb"] ? "black" : NumColor[matrix[row][cell]["around"]])
                      : (matrix[row][cell]["flag"] ? "red" : "gray")}
                    onClick={() => act("Square", {"X": row, "Y": cell, "mode": currentMode})}>
                    {matrix[row][cell]["open"] ?
                    (matrix[row][cell]["bomb"] ? "*" : (matrix[row][cell]["around"] ? matrix[row][cell]["around"] : " "))
                    : (matrix[row][cell]["flag"] ? "►" : " ")}
                  </Button>
                ))}
              </Box>
            ))}
          <Box textAlign="center" className="Minesweeper__message">
            Для победы нужно пометить флажками все бомбы,
            а также открыть все пустые клетки.
            <br/>
            Баланс токенов: {tokens}
            <br/>
            {showMessage}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
