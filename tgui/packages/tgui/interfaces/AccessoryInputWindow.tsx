import { useState } from 'react';
import { Box, Button, Input, Section, Stack } from 'tgui-core/components';
import { KEY_ENTER, KEY_ESCAPE } from 'tgui-core/keycodes';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type AccessoryInputData = {
  init_value: string;
  items: string[];
  icon_prefix: string;
  preview_keys: Record<string, string>;
  large_buttons: boolean;
  message: string;
  timeout: number;
  title: string;
};

const TILE_SIZE = 92;
const PREVIEW_SIZE = 64;
const PREVIEW_SCALE = 2;
const MAX_LABEL_LENGTH = 11;

export const AccessoryInputWindow = () => {
  const { act, data } = useBackend<AccessoryInputData>();
  const {
    items = [],
    icon_prefix,
    preview_keys = {},
    message = '',
    init_value,
    timeout,
    title,
  } = data;

  const [selected, setSelected] = useState(init_value);
  const [searchQuery, setSearchQuery] = useState('');

  const filteredItems = items.filter((item) =>
    item?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <Window title={title} width={560} height={560}>
      {timeout && <Loader value={timeout} />}
      <Window.Content>
        <Section
          fill
          title={message}
          onKeyDown={(event) => {
            const keyCode = window.event ? event.which : event.keyCode;
            if (keyCode === KEY_ENTER) {
              event.preventDefault();
              act('submit', { entry: selected });
            }
            if (keyCode === KEY_ESCAPE) {
              event.preventDefault();
              act('cancel');
            }
          }}
        >
          <Stack fill vertical>
            <Stack.Item>
              <Input
                autoFocus
                autoSelect
                fluid
                expensive
                onChange={setSearchQuery}
                placeholder="Поиск..."
                value={searchQuery}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Section fill scrollable>
                <Box
                  style={{
                    display: 'flex',
                    flexWrap: 'wrap',
                    justifyContent: 'flex-start',
                  }}
                >
                  {filteredItems.map((item) => (
                    <AccessoryTile
                      key={item}
                      name={item}
                      previewKey={preview_keys[item]}
                      iconPrefix={icon_prefix}
                      selected={item === selected}
                      onSelect={() => setSelected(item)}
                      onSubmit={() => act('submit', { entry: item })}
                    />
                  ))}
                </Box>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <InputButtons
                input={selected}
                on_submit={() => act('submit', { entry: selected })}
                on_cancel={() => act('cancel')}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

type AccessoryTileProps = {
  name: string;
  previewKey: string;
  iconPrefix: string;
  selected: boolean;
  onSelect: () => void;
  onSubmit: () => void;
};

const AccessoryTile = (props: AccessoryTileProps) => {
  const { name, previewKey, iconPrefix, selected, onSelect, onSubmit } = props;

  return (
    <Button
      tooltip={name}
      selected={selected}
      m={0.5}
      p={0.5}
      style={{ width: `${TILE_SIZE}px`, textAlign: 'center' }}
      onClick={onSelect}
      onDoubleClick={onSubmit}
    >
      <Box
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          height: `${PREVIEW_SIZE}px`,
        }}
      >
        {!!previewKey && (
          <div
            className={`${iconPrefix} ${previewKey}`}
            style={{
              transform: `scale(${PREVIEW_SCALE})`,
              imageRendering: 'pixelated',
            }}
          />
        )}
      </Box>
      <Box style={{ overflow: 'hidden', whiteSpace: 'nowrap' }}>
        {name.length > MAX_LABEL_LENGTH ? <marquee>{name}</marquee> : name}
      </Box>
    </Button>
  );
};
