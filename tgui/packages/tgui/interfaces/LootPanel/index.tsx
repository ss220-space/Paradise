import { BooleanLike } from 'common/react';

import { useBackend } from '../../backend';
import { useCallback, useState } from 'react';
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
    if (grouping) {
      // For grouped mode, rebuild the groups to match by uid
      const groupedMap: Record<string, { uid: string; name: string; amount: number }> = {};
      for (const item of contents) {
        const key = item.path ? item.path + item.name : item.uid;
        if (!groupedMap[key]) {
          groupedMap[key] = { uid: item.uid, name: item.name, amount: 1 };
        } else {
          groupedMap[key].amount++;
        }
      }
      for (const group of Object.values(groupedMap)) {
        if (selectedUids.has(group.uid)) {
          selectedNames.push(group.amount > 1 ? `${group.name} x${group.amount}` : group.name);
        }
      }
    } else {
      for (const item of contents) {
        if (selectedUids.has(item.uid)) {
          selectedNames.push(item.name);
        }
      }
    }
    if (selectedNames.length > 0) {
      const text = selectedNames.join(', ');
      navigator.clipboard.writeText(text).catch(() => {});
    }
    clearSelection();
  }, [selectedUids, contents, grouping, clearSelection]);

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
            disabled={selectedUids.size === 0}
            onClick={copySelected}
            tooltip="Copy selected items"
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
