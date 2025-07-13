import { cache } from 'webpack';
import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  Section,
  Box,
  Stack,
  ImageButton,
} from '../components';
import { Window } from '../layouts';
import { string } from 'prop-types';

type LibraryScannerData = {
  book: string;
  title: string;
  icon: string;
  icon_state: string;
  author: string;
  ui_theme: string;
  cache: string;
  Message: string;
};

export const LibraryScanner = (props: unknown) => {
  const { act, data } = useBackend<LibraryScannerData>();
  return (
    <Window
      width={700}
      height={400}
      theme={data.ui_theme}
      title="Интерфейс управления сканером"
    >
      <Window.Content scrollable>
        <Stack fill>
          <Stack.Item basis="45%">
            <Stack fill vertical>
              <Section title="Меню">
                <Stack fill vertical mt={2} mb={30}>
                  <Stack.Item mb={1}>
                    <Button
                      fluid
                      textAlign="center"
                      icon={'sign-in'}
                      selected={!!data.book}
                      onClick={() => act('scan')}
                      disabled={!data.book}
                    >
                      Сканировать
                    </Button>
                  </Stack.Item>
                  <Stack.Item mb={1}>
                    <Button
                      fluid
                      textAlign="center"
                      icon={data.book ? 'eject' : 'book'}
                      onClick={() => act('book')}
                    >
                      {data.book ? 'достать книгу' : 'положить книгу'}
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      fluid
                      textAlign="center"
                      icon={'trash'}
                      onClick={() => act('erase')}
                    >
                      Очистить Память
                    </Button>
                  </Stack.Item>
                  <Stack.Item
                    color="red"
                    bold
                    textAlign="center"
                    verticalAlign="middle"
                    mt="10%"
                  >
                    {data.Message}
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack>
          </Stack.Item>
          <Stack.Item basis="55%">
            <Section title="Книга">
              <Stack fill vertical mt={2} mb={1.2}>
                <Section mt={3}>
                  <Stack>
                    <Stack.Item
                        grow
                        textAlign="center"
                        verticalAlign="top"
                        fontSize={1.25}
                      >
                      <ImageButton

                        m={0.5}
                        imageSize={150}
                        dmIcon={data.icon}
                        dmIconState={data.icon_state}
                      >
                        <Stack.Item>
                         Навзание: {data.cache ? data.title : "-----"}
                        </Stack.Item>
                        <Stack.Item mt="10%">
                         Автор: {data.cache ? data.author : "-----"}
                        </Stack.Item>
                      </ImageButton>
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
