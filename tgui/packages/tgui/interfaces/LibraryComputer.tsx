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

type LibraryComputerData = {
  scanner: string;
  cache: string;
  cache_title: string;
  cache_author: string;
  cache_dat: string;
  cache_icon: string;
  cache_icon_state: string
  ui_theme: string;
};

export const LibraryComputer = (props: unknown) => {
  const { act, data } = useBackend<LibraryComputerData>();
  return (
    <Window
      width={700}
      height={400}
      theme={data.ui_theme}
      title="Библиотечный Компьютер"
    >
      <Window.Content scrollable>
        <Stack fill>
          <Stack.Item basis="70%">
            <Stack fill vertical>
              <Section title="Меню">
                <Stack fill vertical mt={2} mb={40}>
                  <Stack.Item mb={1}>
                    <Button
                      textAlign="center"
                      icon={'chain'}
                      onClick={() => act('link_scanner')}
                      disabled={!!data.scanner}
                    >
                      Присоединить сканнер
                    </Button>
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
                        dmIcon={data.cache_icon}
                        dmIconState={data.cache_icon_state}
                      >
                        <Stack.Item>
                         Навзание: {data.cache ? data.cache_title : "-----"}
                        </Stack.Item>
                        <Stack.Item mt="10%">
                         Автор: {data.cache ? data.cache_author : "-----"}
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
