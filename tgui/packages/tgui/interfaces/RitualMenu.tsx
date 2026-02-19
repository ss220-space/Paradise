import { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Stack, Dropdown } from '../components';
import { Window } from '../layouts';

type RitualMenuData = {
  rituals: string[];
  selected_ritual: string;
  description: string;
  params: string[];
  things: string[];
  ritual_available: boolean;
  time_left: number;
};

export const RitualMenu = (_props: unknown) => {
  const { act, data } = useBackend<RitualMenuData>();
  const [startButtonColor, SetStartButtonColor] = useState('#3c3c3c');
  const {
    rituals,
    selected_ritual,
    description,
    params,
    things,
    ritual_available,
    time_left,
  } = data;
  const [selectedRitual, SetSelectedRitual] = useState(selected_ritual);

  return (
    <Window width={550} height={600}>
      <Stack vertical fill m="15px">
        <Stack.Item>
          <Box
            backgroundColor="#3c3c3c"
            p="12px"
            color="white"
            style={{
              color: 'white',
              borderRadius: '10px',
              fontWeight: 'bold',
            }}
          >
            <Stack vertical>
              <Stack.Item style={{ marginBottom: '2px' }}>
                Выбор ритуала
              </Stack.Item>
              <Stack.Item>
                <Dropdown
                  width="100%"
                  noChevron
                  options={rituals}
                  selected={
                    selectedRitual ? selectedRitual : 'Ритуал не выбран'
                  }
                  mt={1}
                  onSelected={(val) => {
                    SetSelectedRitual(val);
                    act('select_ritual', { selected_ritual: val });
                  }}
                  style={{
                    color: 'white',
                    border: '1px solid #444',
                    backgroundColor: '#2a2a2a',
                    borderRadius: '5px',
                  }}
                />
              </Stack.Item>
            </Stack>
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
                      color: 'white',
                      borderRadius: '6px 6px 0 0',
                      borderBottom: '2px solid #888',
                      fontWeight: 'bold',
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
                      color: 'white',
                      borderRadius: '6px 6px 0 0',
                      borderBottom: '2px solid #888',
                      fontWeight: 'bold',
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
                      color: 'white',
                      borderRadius: '8px',
                      boxShadow: 'inset 0 0 8px #000',
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
                    <ul style={{ marginLeft: '15px' }}>
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
                      color: 'white',
                      borderRadius: '8px',
                      boxShadow: 'inset 0 0 8px #000',
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
                width="40em"
                backgroundColor={startButtonColor}
                style={{
                  color: 'white',
                  border: '1px solid #555',
                  padding: '10px 20px',
                  borderRadius: '10px',
                  cursor: 'pointer',
                  fontWeight: 'bold',
                  textAlign: 'center',
                }}
                disabled={!ritual_available}
                onMouseOver={(e) => SetStartButtonColor('#555')}
                onMouseLeave={(e) => SetStartButtonColor('#3c3c3c')}
                onClick={() => {
                  SetSelectedRitual(null);
                  act('start_ritual');
                }}
              >
                {ritual_available
                  ? 'Запуск ритуала'
                  : `Недоступно (${time_left}с)`}
              </Button>
            </Stack.Item>
          </>
        ) : (
          <Stack.Item width="100%" height="70%">
            <Box
              width="100%"
              height="100%"
              style={{
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                fontSize: '2em',
                fontWeight: 'bold',
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
