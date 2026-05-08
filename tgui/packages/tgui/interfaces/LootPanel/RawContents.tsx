import { createSearch } from 'common/string';

import { Flex } from '../../components';
import { LootBox } from './LootBox';
import { SearchItem } from './types';

type Props = {
  contents: SearchItem[];
  searchText: string;
  selectedUids: Set<string>;
  onToggleSelection: (uid: string) => void;
};

export const RawContents = (props: Props) => {
  const { contents, searchText, selectedUids, onToggleSelection } = props;

  const filteredContents = contents.filter(
    createSearch(searchText, (item: SearchItem) => item.name)
  );

  return (
    <Flex wrap>
      {filteredContents.map((item) => (
        <Flex.Item key={item.uid} m={1}>
          <LootBox
            item={item}
            selected={selectedUids.has(item.uid)}
            onToggleSelection={onToggleSelection}
          />
        </Flex.Item>
      ))}
    </Flex>
  );
};
