import { createSearch } from 'common/string';
import { Box } from '../../components';

import { LootBox } from './LootBox';
import { SearchGroup, SearchItem } from './types';

type Props = {
  contents: Record<string, SearchItem[]>;
  searchText: string;
  selectedUids: Set<string>;
  onToggleSelection: (uid: string) => void;
};

export const GroupedContents = (props: Props) => {
  const { contents, searchText, selectedUids, onToggleSelection } = props;

  const filteredContents: SearchGroup[] = Object.entries(contents)
    .filter(createSearch(searchText, ([_, items]) => items[0].name))
    .map(([_, items]) => ({ amount: items.length, item: items[0] }));

  return (
    <Box m={-0.5}>
      {filteredContents.map((group) => (
        <LootBox
          key={group.item.uid}
          group={group}
          selected={selectedUids.has(group.item.uid)}
          onToggleSelection={onToggleSelection}
        />
      ))}
    </Box>
  );
};
