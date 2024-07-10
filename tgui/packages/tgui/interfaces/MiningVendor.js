import { createSearch } from 'common/string';

import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  Stack,
  ImageButton,
  Input,
  NoticeBox,
  Section,
} from '../components';
import { Window } from '../layouts';

const sortTypes = {
  'Alphabetical': (a, b) => a - b,
  'Availability': (a, b) => -(a.affordable - b.affordable),
  'Price': (a, b) => a.price - b.price,
};

export const MiningVendor = (_properties, _context) => {
  return (
    <Window width={400} height={450}>
      <Window.Content className="Layout__content--flexColumn">
        <Stack fill vertical>
          <MiningVendorUser />
          <MiningVendorSearch />
          <MiningVendorItems />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MiningVendorUser = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { has_id, id } = data;
  return (
    <NoticeBox success={has_id}>
      {has_id ? (
        <>
          <Box
            inline
            verticalAlign="middle"
            style={{
              float: 'left',
            }}
          >
            Logged in as {id.name}.<br />
            You have {id.points.toLocaleString('en-US')} points.
          </Box>
          <Button
            icon="eject"
            content="Eject ID"
            style={{
              float: 'right',
            }}
            onClick={() => act('logoff')}
          />
          <Box
            style={{
              clear: 'both',
            }}
          />
        </>
      ) : (
        'Please insert an ID in order to make purchases.'
      )}
    </NoticeBox>
  );
};

const MiningVendorItems = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { has_id, id, items } = data;
  // Search thingies
  const [searchText, _setSearchText] = useLocalState(context, 'search', '');
  const [sortOrder, _setSortOrder] = useLocalState(
    context,
    'sort',
    'Alphabetical'
  );
  const [descending, _setDescending] = useLocalState(
    context,
    'descending',
    false
  );
  const searcher = createSearch(searchText, (item) => {
    return item[0];
  });

  let has_contents = false;
  let contents = Object.entries(items).map((kv, _i) => {
    let items_in_cat = Object.entries(kv[1])
      .filter(searcher)
      .map((kv2) => {
        kv2[1].affordable = has_id && id.points >= kv2[1].price;
        return kv2[1];
      })
      .sort(sortTypes[sortOrder]);
    if (items_in_cat.length === 0) {
      return;
    }
    if (descending) {
      items_in_cat = items_in_cat.reverse();
    }

    has_contents = true;
    return (
      <MiningVendorItemsCategory
        key={kv[0]}
        title={kv[0]}
        items={items_in_cat}
      />
    );
  });
  return (
    <Stack.Item grow>
      <Section fill scrollable>
        {has_contents ? (
          contents
        ) : (
          <Box color="label">No items matching your criteria was found!</Box>
        )}
      </Section>
    </Stack.Item>
  );
};

const MiningVendorSearch = (_properties, context) => {
  const [_searchText, setSearchText] = useLocalState(context, 'search', '');
  const [_sortOrder, setSortOrder] = useLocalState(context, 'sort', '');
  const [descending, setDescending] = useLocalState(
    context,
    'descending',
    false
  );
  return (
    <Box>
      <Stack>
        <Stack.Item grow>
          <Input
            placeholder="Search by item name.."
            width="100%"
            onInput={(_e, value) => setSearchText(value)}
          />
        </Stack.Item>
        <Stack.Item basis="30%">
          <Dropdown
            selected="Alphabetical"
            options={Object.keys(sortTypes)}
            width="100%"
            onSelected={(v) => setSortOrder(v)}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={descending ? 'arrow-down' : 'arrow-up'}
            height="21px"
            tooltip={descending ? 'Descending order' : 'Ascending order'}
            tooltipPosition="bottom-start"
            onClick={() => setDescending(!descending)}
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const MiningVendorItemsCategory = (properties, context) => {
  const { act, data } = useBackend(context);
  const { title, items, ...rest } = properties;
  return (
    <Collapsible open title={title} {...rest}>
      {items.map((item) => (
        <ImageButton
          key={item.name}
          bold
          asset
          color="brown"
          imageSize="64px"
          image={item.imageId}
          imageAsset={'mining_vendor64x64'}
          content={item.name}
        >
          <ImageButton.Item
            bold
            horizontal
            width={'64px'}
            fontSize={1}
            content={item.price}
            icon="shopping-cart"
            iconSize={1}
            iconColor={
              !data.has_id || data.id.points < item.price ? 'grey' : 'good'
            }
            color={'good'}
            disabled={!data.has_id || data.id.points < item.price}
            onClick={() => act('purchase', { cat: title, name: item.name })}
          />
        </ImageButton>
      ))}
    </Collapsible>
  );
};
