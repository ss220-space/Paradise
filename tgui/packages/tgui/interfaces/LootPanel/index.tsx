import { BooleanLike } from 'common/react';

import { useBackend } from '../../backend';
import { useCallback, useMemo, useState } from 'react';
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
  const contentsByPathName = useMemo(() => {
    const result: Record<string, { items: SearchItem[]; path: string }> = {};
    for (let i = 0; i < contents.length; i++) {
      const item = contents[i];
      const groupKey = item.path ? item.path + item.name : item.uid;
      if (!result[groupKey]) {
        result[groupKey] = { items: [], path: item.path || '' };
      }
      result[groupKey].items.push(item);
    }
    return result;
  }, [contents]);

  // Floor is always the first item in the list
  const hasCopyableItems = contents.length > 1;

  // Search
  const [showSearchBar, setShowSearchBar] = useState(false);

  const [grouping, setGrouping] = useState(true);
  const [searchText, setSearchText] = useState('');

  // Selection
  const [selectedUids, setSelectedUids] = useState<Set<string>>(new Set());

  const toggleSelection = useCallback((uid: string) => {
    setSelectedUids((prev) => {
      const next = new Set(prev);
      if (next.has(uid)) {
        next.delete(uid);
      } else {
        next.add(uid);
      }
      return next;
    });
  }, []);

  const clearSelection = useCallback(() => {
    setSelectedUids(new Set());
  }, []);

  const copySelected = useCallback(() => {
    const selectedNames: string[] = [];
    if (selectedUids.size > 0) {
      // Copy selected items
      if (grouping) {
        for (const value of Object.values(contentsByPathName)) {
          const firstItem = value.items[0];
          if (selectedUids.has(firstItem.uid)) {
            selectedNames.push(
              value.items.length > 1
                ? `${firstItem.name} x${value.items.length}`
                : firstItem.name
            );
          }
        }
      } else {
        for (const item of contents) {
          if (selectedUids.has(item.uid)) {
            selectedNames.push(item.name);
          }
        }
      }
    } else {
      // Copy all items (skip first — it's always the floor)
      if (grouping) {
        const values = Object.values(contentsByPathName);
        for (let i = 1; i < values.length; i++) {
          const value = values[i];
          const amount = value.items.length;
          const name = value.items[0].name;
          selectedNames.push(amount > 1 ? `${name} x${amount}` : name);
        }
      } else {
        for (let i = 1; i < contents.length; i++) {
          selectedNames.push(contents[i].name);
        }
      }
    }
    if (selectedNames.length > 0) {
      const text = selectedNames.join(', ');
      navigator.clipboard.writeText(text).catch(() => {});
    }
    clearSelection();
  }, [selectedUids, contents, grouping, contentsByPathName, clearSelection]);

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
          <Button
            icon="copy"
            disabled={!hasCopyableItems}
            onClick={copySelected}
            tooltip="Copy items (all if none selected)"
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
              selectedUids={selectedUids}
              onToggleSelection={toggleSelection}
            />
          ) : (
            <RawContents
              contents={contents}
              searchText={searchText}
              selectedUids={selectedUids}
              onToggleSelection={toggleSelection}
            />
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
