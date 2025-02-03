import { useBackend, useLocalState } from '../backend';
import { Box, Button, Stack, Dropdown } from '../components';
import { Window } from '../layouts';

export const RitualMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    rituals,
    selected_ritual,
    description,
    params,
    things,
    ritual_available,
    time_left,
  } = data;

  return (
    <Window width={550} height={600}>
      <Stack vertical fill m="15px">
        <Stack.Item>
          <Box
            backgroundColor="#3c3c3c"
            p="12px"
            color="white"
            style={{
              'color': 'white',
              'border-radius': '10px',
              'font-weight': 'bold',
            }}
          >
            <span>Выбор ритуала</span>
            <Dropdown
              width="100%"
              options={rituals}
              selected={selected_ritual ? selected_ritual : 'Ритуал не выбран'}
              backgroundColor="#2a2a2a"
              mt="10px"
              onSelected={(val) => {
                act('select_ritual', { selected_ritual: val });
              }}
              style={{
                'color': 'white',
                'border': '1px solid #444',
                'border-radius': '5px',
              }}
            />
          </Box>
        </Stack.Item>
        {selected_ritual ? (
          <>
            <Stack.Item>
              <Stack fill m="20px 0">
                <Stack.Item width="55%">
                  <Box
                    textAlign="center"
                    fontWeight="bold"
                    p="8px"
                    backgroundColor="#3a3a3a"
                    style={{
                      'color': 'white',
                      'border-radius': '6px 6px 0 0',
                      'border-bottom': '2px solid #888',
                      'font-weight': 'bold',
                    }}
                  >
                    Свойства:
                  </Box>
                </Stack.Item>
                <Stack.Item width="45%">
                  <Box
                    textAlign="center"
                    p="8px"
                    color="#ffffff"
                    backgroundColor="#3a3a3a"
                    style={{
                      'color': 'white',
                      'border-radius': '6px 6px 0 0',
                      'border-bottom': '2px solid #888',
                      'font-weight': 'bold',
                    }}
                  >
                    Результат:
                  </Box>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack fill m="12px 0">
                <Stack.Item width="55%">
                  <Box
                    backgroundColor="#3c3c3c"
                    p="12px"
                    color="white"
                    style={{
                      'color': 'white',
                      'border-radius': '8px',
                      'box-shadow': 'inset 0 0 8px #000',
                    }}
                  >
                    {params
                      ? Object.entries(params).map(([key, value]) => {
                          return (
                            <span key={key}>
                              {key} <b>{` ${value}`}</b>
                              <br />
                            </span>
                          );
                        })
                      : ''}
                    <br />
                    Список необходимых предметов:
                    <ul style={{ 'margin-left': '15px' }}>
                      {things
                        ? Object.entries(things).map(([key, value]) => {
                            return (
                              <li key={key}>
                                {key} <b>{` ${value}`}</b>
                                <br />
                              </li>
                            );
                          })
                        : ''}
                    </ul>
                  </Box>
                </Stack.Item>
                <Stack.Item width="45%">
                  <Box
                    backgroundColor="#3c3c3c"
                    p="12px"
                    color="white"
                    style={{
                      'color': 'white',
                      'border-radius': '8px',
                      'box-shadow': 'inset 0 0 8px #000',
                    }}
                  >
                    {description}
                  </Box>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item align="center" mt="auto">
              <Button
                mb="1.8em"
                content={
                  ritual_available
                    ? 'Запуск ритуала'
                    : `Недоступно (${time_left}с)`
                }
                width="40em"
                backgroundColor="#3c3c3c"
                style={{
                  'color': 'white',
                  'border': '1px solid #555',
                  'padding': '10px 20px',
                  'border-radius': '10px',
                  'cursor': 'pointer',
                  'font-weight': 'bold',
                  'text-align': 'center',
                }}
                disabled={!ritual_available}
                onMouseOver={(e) => (e.target.style.backgroundColor = '#555')}
                onMouseOut={(e) => (e.target.style.backgroundColor = '#3c3c3c')}
                onClick={() => act('start_ritual')}
              />
            </Stack.Item>
          </>
        ) : (
          <Stack.Item width="100%" height="70%">
            <Box
              width="100%"
              height="100%"
              style={{
                'display': 'flex',
                'justify-content': 'center',
                'align-items': 'center',
                'font-size': '2em',
                'font-weight': 'bold',
              }}
            >
              Ритуал не выбран
            </Box>
          </Stack.Item>
        )}
      </Stack>
    </Window>
  );
};
