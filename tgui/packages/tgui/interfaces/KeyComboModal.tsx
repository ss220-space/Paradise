import { useState, useEffect, useRef } from 'react';
import { Box, Button, Section, Stack } from 'tgui/components';
import { isEscape, KEY } from 'common/keys';
import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type KeyInputData = {
  init_value: string;
  large_buttons: BooleanLike;
  message: string;
  timeout: number;
  title: string;
};

const isStandardKey = (event: React.KeyboardEvent<HTMLDivElement>): boolean => {
  return (
    event.key !== KEY.Alt &&
    event.key !== KEY.Control &&
    event.key !== KEY.Shift &&
    !isEscape(event.key)
  );
};

const KEY_CODE_TO_BYOND: Record<string, string> = {
  DEL: 'Delete',
  DOWN: 'South',
  END: 'Southwest',
  HOME: 'Northwest',
  INSERT: 'Insert',
  LEFT: 'West',
  PAGEDOWN: 'Southeast',
  PAGEUP: 'Northeast',
  RIGHT: 'East',
  SPACEBAR: 'Space',
  ' ': 'Space',
  UP: 'North',
};

const DOM_KEY_LOCATION_NUMPAD = 3;

const formatKeyboardEvent = (
  event: React.KeyboardEvent<HTMLDivElement>
): string => {
  let text = '';

  if (event.altKey) {
    text += 'Alt';
  }

  if (event.ctrlKey) {
    text += 'Ctrl';
  }

  if (event.shiftKey) {
    text += 'Shift';
  }

  if (event.location === DOM_KEY_LOCATION_NUMPAD) {
    text += 'Numpad';
  }

  if (isStandardKey(event)) {
    const key = event.key.toUpperCase();
    text += KEY_CODE_TO_BYOND[key] || key;
  }

  return text;
};

export const KeyComboModal = (props: unknown) => {
  const { act, data } = useBackend<KeyInputData>();
  const { init_value, large_buttons, message = '', title, timeout } = data;
  const [input, setInput] = useState(init_value);
  const [binding, setBinding] = useState(true);
  const contentRef = useRef<HTMLDivElement>(null);

  // Фокусируем элемент при монтировании и при сбросе биндинга
  useEffect(() => {
    contentRef.current?.focus();
  }, [binding]);

  const handleKeyDown = (event: React.KeyboardEvent<HTMLDivElement>) => {
    if (isEscape(event.key)) {
      event.preventDefault();
      act('cancel');
      return;
    }

    if (!binding) {
      if (event.key === KEY.Enter) {
        event.preventDefault();
        act('submit', { entry: input });
      }
      return;
    }

    event.preventDefault();

    if (isStandardKey(event)) {
      const newValue = formatKeyboardEvent(event);
      setInput(newValue);
      setBinding(false);
      return;
    }
  };

  const resetBinding = () => {
    setInput(init_value);
    setBinding(true);
  };

  const windowHeight =
    130 +
    (message.length > 30 ? Math.ceil(message.length / 3) : 0) +
    (message.length && large_buttons ? 5 : 0);

  return (
    <Window title={title} width={240} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content>
        <div
          ref={contentRef}
          tabIndex={0}
          onKeyDown={handleKeyDown}
          style={{
            width: '100%',
            height: '100%',
            outline: 'none',
          }}
        >
          <Section fill>
            <Stack fill vertical>
              <Stack.Item grow>
                <Box color="label">{message}</Box>
              </Stack.Item>
              <Stack.Item>
                <Button
                  disabled={binding}
                  fluid
                  textAlign="center"
                  onClick={resetBinding}
                >
                  {binding ? 'Awaiting input...' : input}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <InputButtons input={input} />
              </Stack.Item>
            </Stack>
          </Section>
        </div>
      </Window.Content>
    </Window>
  );
};
