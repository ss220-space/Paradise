import { createSearch } from 'common/string';
import { useBackend } from '../backend';
import React, { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  Stack,
  Input,
  ImageButton,
  NoticeBox,
  Section,
} from '../components';
import { Window } from '../layouts';
import { CollapsibleProps } from '../components/Collapsible';

const sortTypes = {
  'Alphabetical': (a: number, b: number) => a - b,
  'Availability': (a: Item, b: Item) =>
    -((a.affordable as any) - (b.affordable as any)),
  'Price': (a: Item, b: Item) => a.price - b.price,
};

export const MiningVendor = (_properties) => {
  const [gridLayout, setGridLayout] = useState(false);
  return (
    <Window width={400} height={525}>
      <Window.Content>
        <Stack fill vertical>
          <MiningVendorUser />
          <MiningVendorSearch
            gridLayout={gridLayout}
            setGridLayout={setGridLayout}
          />
          <MiningVendorItems gridLayout={gridLayout} />
        </Stack>
      </Window.Content>
    </Window>
  );
};

type MiningVendorData = {
  has_id: boolean;
  id: ID;
  items: Record<string, Record<string, Item>>;
};

type ID = {
  name: string;
  points: number;
};

type Item = {
  name: string;
  affordable: boolean;
  price: number;
  icon: string;
  icon_state: string;
};

const MiningVendorUser = (_properties) => {
  const { act, data } = useBackend<MiningVendorData>();
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
            style={{
              float: 'right',
            }}
            onClick={() => act('logoff')}
          >
            Eject ID
          </Button>
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

type MiningVendorItemsProps = {
  gridLayout?: boolean;
};

const MiningVendorItems = (properties: MiningVendorItemsProps) => {
  const { data } = useBackend<MiningVendorData>();
  const { has_id, id, items } = data;
  const { gridLayout } = properties;
  // Search thingies
  const [searchText, _setSearchText] = useState('');
  const [sortOrder, _setSortOrder] = useState('Alphabetical');
  const [descending, _setDescending] = useState(false);
  const searcher = createSearch<[string, Item]>(searchText, (item) => {
    return item[0];
  });

  let has_contents = false;
  let contents = Object.entries(items).map((kv, _i) => {
    let items_in_cat = Object.entries(kv[1] as Record<string, Item>)
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
        gridLayout={gridLayout}
      />
    );
  });
  return (
    <Stack.Item grow mt={0.5}>
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

type MiningVendorSearchProps = {
  gridLayout: boolean;
  setGridLayout: React.Dispatch<React.SetStateAction<boolean>>;
};

const MiningVendorSearch = (properties: MiningVendorSearchProps) => {
  const { gridLayout, setGridLayout } = properties;
  const [_searchText, setSearchText] = useState('');
  const [_sortOrder, setSortOrder] = useState('');
  const [descending, setDescending] = useState(false);
  return (
    <Box>
      <Stack fill>
        <Stack.Item grow>
          <Input
            mt={0.2}
            placeholder="Search by item name.."
            width="100%"
            onInput={(_e, value) => setSearchText(value)}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={gridLayout ? 'list' : 'table-cells-large'}
            height={1.75}
            tooltip={gridLayout ? 'Toggle List Layout' : 'Toggle Grid Layout'}
            tooltipPosition="bottom-start"
            onClick={() => setGridLayout(!gridLayout)}
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
            height={1.75}
            tooltip={descending ? 'Descending order' : 'Ascending order'}
            tooltipPosition="bottom-start"
            onClick={() => setDescending(!descending)}
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};

type MiningVendorProps = {
  items: Item[];
  gridLayout: boolean;
} & CollapsibleProps;

const MiningVendorItemsCategory = (properties: MiningVendorProps) => {
  const { act, data } = useBackend<MiningVendorData>();
  const { title, items, gridLayout, ...rest } = properties;
  return (
    <Collapsible open title={title} {...rest}>
      {items.map((item) =>
        gridLayout ? (
          <ImageButton
            key={item.name}
            mb={0.5}
            imageSize={57.5}
            dmIcon={item.icon}
            dmIconState={item.icon_state}
            disabled={!data.has_id || data.id.points < item.price}
            tooltip={item.name}
            tooltipPosition="top"
            onClick={() =>
              act('purchase', {
                cat: title,
                name: item.name,
              })
            }
          >
            {item.price.toLocaleString('en-US')}
          </ImageButton>
        ) : (
          <ImageButton
            key={item.name}
            fluid
            mb={0.5}
            imageSize={32}
            dmIcon={item.icon}
            dmIconState={item.icon_state}
            buttons={
              <Button
                color="translucent"
                width={3.75}
                disabled={!data.has_id || data.id.points < item.price}
                onClick={() =>
                  act('purchase', {
                    cat: title,
                    name: item.name,
                  })
                }
              >
                {item.price.toLocaleString('en-US')}
              </Button>
            }
          >
            <Box textAlign={'left'}>{item.name}</Box>
          </ImageButton>
        )
      )}
    </Collapsible>
  );
};
