import { BooleanLike } from 'common/react';
import { useBackend } from '../../backend';
import { IconDisplay } from './IconDisplay';
import { SearchGroup, SearchItem } from './types';
import { Button, Stack } from '../../components';

type Data = {
  is_blind: BooleanLike;
};

type Props =
  | {
      item: SearchItem;
      selected?: boolean;
      onToggleSelection?: (uid: string) => void;
    }
  | {
      group: SearchGroup;
      selected?: boolean;
      onToggleSelection?: (uid: string) => void;
    };

export const LootBox = (props: Props) => {
  const { act, data } = useBackend<Data>();
  const { is_blind } = data;

  let amount = 0;
  let item: SearchItem;
  let selected = false;
  let onToggleSelection: ((uid: string) => void) | undefined;
  if ('group' in props) {
    amount = props.group.amount;
    item = props.group.item;
    selected = props.selected ?? false;
    onToggleSelection = props.onToggleSelection;
  } else {
    item = props.item;
    selected = props.selected ?? false;
    onToggleSelection = props.onToggleSelection;
  }

  const name = !item.name ? '???' : item.name;

  const content = (
    <Button
      p={0}
      fluid
      color={selected ? 'good' : 'transparent'}
      style={
        selected ? { backgroundColor: 'hsl(94, 63%, 31%, 0.25)' } : undefined
      }
      onClick={(event) =>
        act('grab', {
          alt: event.altKey,
          ctrl: event.ctrlKey,
          uid: item.uid,
          shift: event.shiftKey,
        })
      }
      onContextMenu={(event) => {
        event.preventDefault();
        if (onToggleSelection) {
          onToggleSelection(item.uid);
        } else {
          act('grab', {
            right: true,
            uid: item.uid,
          });
        }
      }}
    >
      <Stack>
        <Stack.Item mb={-1} minWidth={'36px'} minHeight={'42px'}>
          <IconDisplay item={item} />
        </Stack.Item>
        <Stack.Item
          lineHeight="34px"
          overflow="hidden"
          style={{ textOverflow: 'ellipsis' }}
          color={selected ? 'good' : undefined}
        >
          {!is_blind && name}
        </Stack.Item>
        <Stack.Item lineHeight="34px" pr={1}>
          {amount > 1 && 'x' + amount}
        </Stack.Item>
      </Stack>
    </Button>
  );

  if (is_blind) return content;

  return content;
};
