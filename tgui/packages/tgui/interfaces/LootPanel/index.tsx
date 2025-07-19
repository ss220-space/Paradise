import { BooleanLike } from 'common/react';

import { useBackend } from '../../backend';
import { useState } from 'react';
import { Box, Button, Input, Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { GroupedContents } from './GroupedContents';
import { RawContents } from './RawContents';
import { SearchItem } from './types';
import { clamp } from 'common/math';
import { isEscape } from 'common/keys';

type Data = {
  contents: SearchItem[];
  searching: BooleanLike;
};

export const LootPanel = (props: unknown) => {
  const { act, data } = useBackend<Data>();
  const { contents = [], searching } = data;

  // limitations: items with different stack counts, charges etc.
  // const [contentsByPathName, setPresets] = useLocalState<Preset[]>('presets', []);
  // Тут был useMemo из 'react'. Я скушал его потому что не мог достать по другому. Он был кислым. Н
  const contentsByPathName: Record<string, SearchItem[]> = {};
  for (let i = 0; i < contents.length; i++) {
    const item = contents[i];
    if (item.path) {
      if (!contentsByPathName[item.path + item.name]) {
        contentsByPathName[item.path + item.name] = [];
      }
      contentsByPathName[item.path + item.name].push(item);
    } else {
      contentsByPathName[item.uid] = [item];
    }
  }

  // Search
  const [showSearchBar, setShowSearchBar] = useState(false);

  const [grouping, setGrouping] = useState(true);
  const [searchText, setSearchText] = useState('');

  const headerHeight = 38;
  const itemHeight = 38;
  const minHeight = headerHeight + itemHeight;
  const maxHeight = headerHeight + itemHeight * 10;
  const height: number = clamp(
    headerHeight +
      (!grouping ? contents.length : Object.keys(contentsByPathName).length) *
        itemHeight,
    minHeight,
    maxHeight
  );

  return (
    <Window
      width={300}
      height={height}
      buttons={
        <Box align={'left'}>
          {!showSearchBar && (
            <Button
              icon="search"
              tooltip="Search..."
              onClick={() => {
                setShowSearchBar(!showSearchBar);
              }}
            />
          )}
          {showSearchBar && (
            <Input
              expensive
              onChange={setSearchText}
              placeholder={`Search items...`}
            />
          )}
          <Button
            icon={grouping ? 'layer-group' : 'object-ungroup'}
            selected={grouping}
            onClick={() => setGrouping(!grouping)}
            tooltip="Toggle Grouping"
          />
          <Button
            icon="sync"
            onClick={() => act('refresh')}
            tooltip="Refresh"
          />
        </Box>
      }
    >
      <Window.Content
        fitted
        scrollable={height === maxHeight}
        onKeyDown={(event) => {
          if (isEscape(event.key)) {
            Byond.sendMessage('close');
          }
        }}
      >
        <Section>
          {grouping ? (
            <GroupedContents
              contents={contentsByPathName}
              searchText={searchText}
            />
          ) : (
            <RawContents contents={contents} searchText={searchText} />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
