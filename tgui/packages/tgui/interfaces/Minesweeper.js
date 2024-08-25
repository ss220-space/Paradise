import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Stack, Section } from '../components';
import { Window } from '../layouts';

export const Minesweeper = (props, context) => {
  const { act, data } = useBackend(context);
  const { matrix, showMessage, tokens, uiWidth } = data;

  const NumColor = {
    1: 'blue',
    2: 'green',
    3: 'red',
    4: 'darkblue',
    5: 'brown',
    6: 'lightblue',
    7: 'black',
    8: 'white',
  };

  document.addEventListener('contextmenu', (event) => event.preventDefault());
  const handleClick = (e, row, cell) => {
    if (e.button !== 0 && e.button !== 2) {
      return;
    }
    act('Square', {
      'X': row,
      'Y': cell,
      'mode': e.button === 2 ? altMode[currentMode] : currentMode,
    });
  };

  const [currentMode, setMode] = useLocalState(context, 'mode', 'bomb');

  const altMode = {
    'flag': 'bomb',
    'bomb': 'flag',
  };

  return (
    <Window theme="ntOS95" width={uiWidth + 80} height={750}>
      <Window.Content>
        <Stack fill vertical>
          <Section
            title="Игровое поле"
            textAlign="center"
            fill
            fitted
            buttons={
              <>
                <Button
                  icon="bomb"
                  iconColor="black"
                  selected={currentMode === 'bomb'}
                  onClick={() => setMode('bomb')}
                />
                <Button
                  icon="flag"
                  iconColor="red"
                  selected={currentMode === 'flag'}
                  onClick={() => setMode('flag')}
                />
                <Button
                  icon="cog"
                  onClick={() => act('Mode', { 'mode': '16x30' })}
                />
              </>
            }
          >
            <p />
            {Object.keys(matrix).map((row) => (
              <Box key={row}>
                {Object.keys(matrix[row]).map((cell) => (
                  <Button
                    key={cell}
                    m="1px"
                    height="30px"
                    width="30px"
                    className={
                      matrix[row][cell]['open']
                        ? 'Minesweeper__open'
                        : 'Minesweeper__closed'
                    }
                    bold
                    color="transparent"
                    icon={
                      matrix[row][cell]['open']
                        ? matrix[row][cell]['bomb']
                          ? 'bomb'
                          : ''
                        : matrix[row][cell]['flag']
                          ? 'flag'
                          : ''
                    }
                    textColor={
                      matrix[row][cell]['open']
                        ? matrix[row][cell]['bomb']
                          ? 'black'
                          : NumColor[matrix[row][cell]['around']]
                        : matrix[row][cell]['flag']
                          ? 'red'
                          : 'gray'
                    }
                    onMouseDown={(e) => handleClick(e, row, cell)}
                  >
                    {!!matrix[row][cell]['open'] &&
                    !matrix[row][cell]['bomb'] &&
                    matrix[row][cell]['around']
                      ? matrix[row][cell]['around']
                      : ' '}
                  </Button>
                ))}
              </Box>
            ))}
            <p />
            <Box textAlign="center" className="Minesweeper__message">
              Для победы нужно пометить флажками все бомбы, а также открыть все
              пустые клетки.
              <br />
              Баланс токенов: {tokens}
              <br />
              {showMessage}
            </Box>
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
