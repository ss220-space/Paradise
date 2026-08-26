import { flow } from 'common/fp';

import { filter, sortBy } from 'common/collections';
import { useBackend, useSharedState } from '../backend';
import { useState } from 'react';
import {
  Button,
  LabeledList,
  Box,
  Section,
  Dropdown,
  Input,
  Table,
  Modal,
} from '../components';
import { Window } from '../layouts';
import { createSearch } from 'common/string';
import { CataloguePaneProps, ContentsModalProps } from './CargoConsole';

export const SyndieCargoConsole = (_props: unknown) => {
  const [contentsModal, setContentsModal] = useState<string[]>(null);
  const [contentsModalTitle, setContentsModalTitle] = useState<string>(null);

  return (
    <Window width={900} height={800} theme="syndicate">
      <Window.Content>
        <ContentsModal
          contentsModal={contentsModal}
          setContentsModal={setContentsModal}
          contentsModalTitle={contentsModalTitle}
          setContentsModalTitle={setContentsModalTitle}
        />
        <StatusPane />
        <CataloguePane
          setContentsModal={setContentsModal}
          setContentsModalTitle={setContentsModalTitle}
        />
        <DetailsPane />
      </Window.Content>
    </Window>
  );
};

type SyndieCargoConsoleData = {
  is_public: boolean;
  cash: number;
  wait_time: number;
  is_cooldown: boolean;
  telepads_status: string;
  adminAddCash: string;
};

const ContentsModal = (properties: ContentsModalProps) => {
  const {
    contentsModal,
    setContentsModal,
    contentsModalTitle,
    setContentsModalTitle,
  } = properties;
  if (contentsModal !== null && contentsModalTitle !== null) {
    return (
      <Modal
        maxWidth="75%"
        width={window.innerWidth + 'px'}
        maxHeight={window.innerHeight * 0.75 + 'px'}
        mx="auto"
      >
        <Box width="100%" bold>
          <h1>{contentsModalTitle} contents:</h1>
        </Box>
        <Box>
          {contentsModal.map((i) => (
            // This needs keying. I hate it.
            <Box key={i}>- {i}</Box>
          ))}
        </Box>
        <Box m={2}>
          <Button
            onClick={() => {
              setContentsModal(null);
              setContentsModalTitle(null);
            }}
          >
            Close
          </Button>
        </Box>
      </Modal>
    );
  } else {
    return;
  }
};

const StatusPane = (_properties) => {
  const { act, data } = useBackend<SyndieCargoConsoleData>();
  const {
    is_public = false,
    cash,
    wait_time,
    is_cooldown,
    telepads_status,
    adminAddCash,
  } = data;

  // Shuttle status text
  let statusText = telepads_status;
  let dynamicTooltip = '';
  let block = 0;
  let teleportButtonText = '';
  if (telepads_status === 'Pads not linked!') {
    block = 0;
    dynamicTooltip = 'Attempts to link telepads to the console.';
    teleportButtonText = 'Link pads';
  } else if (!is_cooldown) {
    block = 0;
    dynamicTooltip =
      'Teleports your crates to the market. A reminder, some of the crates are directly stolen from NT trading routes. That means they can be locked. We are NOT sorry for the inconvenience';
    teleportButtonText = 'Teleport';
  } else if (is_cooldown) {
    teleportButtonText = 'Cooldown...';
    dynamicTooltip = 'Pads are cooling off...';
    block = 1;
    if (wait_time !== 1) {
      statusText = '' + telepads_status + ' (ETA: ' + wait_time + ' seconds)';
    } else {
      statusText = '' + telepads_status + ' (ETA: ' + wait_time + ' second)';
    }
  }

  return (
    <Section title="Status">
      <LabeledList>
        {!is_public && (
          <LabeledList.Item label="Money Available">
            {cash}
            <Button
              tooltip="Withdraw money from the console"
              onClick={() => act('withdraw', { cash })}
            >
              Withdraw
            </Button>
            <Button
              tooltip="Bless the players with da money!"
              onClick={() => act('add_money', { cash })}
            >
              {adminAddCash}
            </Button>
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Telepads Status">
          {statusText}
        </LabeledList.Item>
        {!is_public && (
          <LabeledList.Item label="Controls">
            <Button
              tooltip={dynamicTooltip}
              disabled={block}
              onClick={() => act('teleport')}
            >
              {teleportButtonText}
            </Button>
            <Button onClick={() => act('showMessages')}>
              View Syndicate Black Market Log
            </Button>
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

const CataloguePane = (properties: CataloguePaneProps) => {
  const { act, data } = useBackend<CataloguePaneData>();
  const { categories, supply_packs } = data;

  const [category, setCategory] = useSharedState('category', 'Emergency');

  const [searchText, setSearchText] = useSharedState('search_text', '');

  const { setContentsModal, setContentsModalTitle } = properties;

  const packSearch = createSearch<SupplyPack>(
    searchText,
    (crate) => crate.name
  );

  const cratesToShow = flow([
    (supply_packs: SupplyPack[]) =>
      filter(
        supply_packs,
        (pack) =>
          pack.cat ===
          (categories.filter((c) => c.name === category)[0].category ||
            searchText)
      ),
    (supply_packs: SupplyPack[]) =>
      searchText ? filter(supply_packs, packSearch) : supply_packs,
    (supply_packs: SupplyPack[]) =>
      sortBy(supply_packs, (pack) => pack.name.toLowerCase()),
  ])(supply_packs);

  let titleText = 'Crate Catalogue';
  if (searchText) {
    titleText = "Results for '" + searchText + "':";
  } else if (category) {
    titleText = 'Browsing ' + category;
  }
  return (
    <Section
      title={titleText}
      buttons={
        <Dropdown
          width="190px"
          options={categories.map((r) => r.name)}
          selected={category}
          onSelected={(val) => setCategory(val)}
        />
      }
    >
      <Input
        fluid
        placeholder="Search for..."
        expensive
        onChange={setSearchText}
        mb={1}
      />
      <Box maxHeight={25} overflowY="auto" overflowX="hidden">
        <Table m="0.5rem">
          {cratesToShow.map((c) => (
            <Table.Row key={c.name}>
              <Table.Cell bold>
                {c.name} ({c.cost} Credits)
              </Table.Cell>
              <Table.Cell textAlign="right" pr={1}>
                <Button
                  icon="shopping-cart"
                  onClick={() =>
                    act('order', {
                      crate: c.ref,
                      multiple: 0,
                    })
                  }
                >
                  Order 1
                </Button>
                <Button
                  icon="cart-plus"
                  onClick={() =>
                    act('order', {
                      crate: c.ref,
                      multiple: 1,
                    })
                  }
                >
                  Order Multiple
                </Button>
                <Button
                  icon="search"
                  onClick={() => {
                    setContentsModal(c.contents);
                    setContentsModalTitle(c.name);
                  }}
                >
                  View Contents
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Box>
    </Section>
  );
};

const DetailsPane = (_properties) => {
  const { act, data } = useBackend<DetailsPaneData>();
  const { requests, canapprove, orders } = data;
  return (
    <Section title="Details">
      <Box maxHeight={15} overflowY="auto" overflowX="hidden">
        <Box bold>Requests</Box>
        <Table m="0.5rem">
          {requests.map((r) => (
            <Table.Row key={r.ordernum}>
              <Table.Cell>
                <Box>
                  - #{r.ordernum}: {r.supply_type} for <b>{r.orderedby}</b>
                </Box>
                <Box italic>Reason: {r.comment}</Box>
              </Table.Cell>
              <Table.Cell textAlign="right" pr={1}>
                <Button
                  color="green"
                  disabled={!canapprove}
                  onClick={() =>
                    act('approve', {
                      ordernum: r.ordernum,
                    })
                  }
                >
                  Approve
                </Button>
                <Button
                  color="red"
                  onClick={() =>
                    act('deny', {
                      ordernum: r.ordernum,
                    })
                  }
                >
                  Deny
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
        <Box bold>Confirmed Orders</Box>
        <Table m="0.5rem">
          {orders.map((r) => (
            <Table.Row key={r.ordernum}>
              <Table.Cell>
                <Box>
                  - #{r.ordernum}: {r.supply_type} for <b>{r.orderedby}</b>
                </Box>
                <Box italic>Reason: {r.comment}</Box>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Box>
    </Section>
  );
};
