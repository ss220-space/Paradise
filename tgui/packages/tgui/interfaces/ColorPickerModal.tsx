/**
 * @file
 * @copyright 2023 itsmeow
 * @license MIT
 */

import { Loader } from './common/Loader';
import { useBackend } from '../backend';
import { useState } from 'react';
import { Autofocus, Box, Section, Stack } from '../components';
import { Window } from '../layouts';
import { hexToHsva, HsvaColor, hsvaToHex } from 'common/color';
import { InputButtons } from './common/InputButtons';
import { ColorSelector } from './common/ColorSelector';

type ColorPickerData = {
  autofocus: boolean;
  buttons: string[];
  message: string;
  large_buttons: boolean;
  swapped_buttons: boolean;
  timeout: number;
  title: string;
  default_color: string;
};

export const ColorPickerModal = (_) => {
  const { data } = useBackend<ColorPickerData>();
  const {
    timeout,
    message,
    title,
    autofocus,
    default_color = '#000000',
  } = data;
  let [selectedColor, setSelectedColor] = useState<HsvaColor>(
    hexToHsva(default_color)
  );

  return (
    <Window height={400} title={title} width={600} theme="generic">
      {!!timeout && <Loader value={timeout} />}
      <Window.Content>
        <Stack fill vertical>
          {message && (
            <Stack.Item m={1}>
              <Section fill>
                <Box color="label" overflow="hidden">
                  {message}
                </Box>
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section fill>
              {!!autofocus && <Autofocus />}
              <ColorSelector
                color={selectedColor}
                setColor={setSelectedColor}
                defaultColor={default_color}
              />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <InputButtons input={hsvaToHex(selectedColor)} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
