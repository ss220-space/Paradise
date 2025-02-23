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
    }
  | {
      group: SearchGroup;
    };

export const LootBox = (props: Props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { is_blind } = data;

  let amount = 0;
  let item: SearchItem;
  if ('group' in props) {
    amount = props.group.amount;
    item = props.group.item;
  } else {
    item = props.item;
  }

  const name = !item.name ? '???' : item.name;

  const content = (
    <Button
      p={0}
      fluid
      color="transparent"
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
        act('grab', {
          right: true,
          uid: item.uid,
        });
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
