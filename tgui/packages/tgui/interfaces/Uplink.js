import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';

import { createSearch, decodeHtmlEntities } from 'common/string';
import { Countdown } from '../components/Countdown';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Input,
  Section,
  Stack,
  Divider,
  Tabs,
  LabeledList,
  Icon,
} from '../components';
import { Window } from '../layouts';
import {
  ComplexModal,
  modalOpen,
  modalAnswer,
  modalRegisterBodyOverride,
} from './common/ComplexModal';

const PickTab = (index) => {
  switch (index) {
    case 0:
      return <ItemsPage />;
    case 1:
      return <CartPage />;
    case 2:
      return <ExploitableInfoPage />;
    default:
      return 'SOMETHING WENT VERY WRONG PLEASE AHELP';
  }
};

export const Uplink = (props, context) => {
  const { act, data } = useBackend(context);
  const { cart } = data;

  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  return (
    <Window width={900} height={600} theme="syndicate">
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                key="PurchasePage"
                selected={tabIndex === 0}
                onClick={() => {
                  setTabIndex(0);
                  setSearchText('');
                }}
                icon="store"
              >
                View Market
              </Tabs.Tab>
              <Tabs.Tab
                key="Cart"
                selected={tabIndex === 1}
                onClick={() => {
                  setTabIndex(1);
                  setSearchText('');
                }}
                icon="shopping-cart"
              >
                View Shopping Cart{' '}
                {cart && cart.length ? '(' + cart.length + ')' : ''}
              </Tabs.Tab>
              <Tabs.Tab
                key="ExploitableInfo"
                selected={tabIndex === 2}
                onClick={() => {
                  setTabIndex(2);
                  setSearchText('');
                }}
                icon="user"
              >
                Exploitable Information
              </Tabs.Tab>

              {!!data.can_get_intelligence_data && (
                <Tabs.Tab
                  key="GetIntelligenceВata"
                  // This cant ever be selected. Its just a close button.
                  onClick={() => act('intel_data')}
                  icon="intel_data"
                >
                  Запросить разведданные
                </Tabs.Tab>
              )}

              {!!data.contractor && (
                <Tabs.Tab
                  key="BecomeContractor"
                  color={
                    !!data.contractor.available && !data.contractor.accepted
                      ? 'yellow'
                      : 'transparent'
                  }
                  onClick={() => modalOpen(context, 'become_contractor')}
                  icon="suitcase"
                >
                  Contracting Opportunity
                  {!data.contractor.is_admin_forced &&
                  !data.contractor.accepted ? (
                    data.contractor.available_offers > 0 ? (
                      <i>[Left:{data.contractor.available_offers}]</i>
                    ) : (
                      <i>[Offers over]</i>
                    )
                  ) : (
                    ''
                  )}
                  {data.contractor.accepted ? (
                    <i>&nbsp;(Accepted)</i>
                  ) : !data.contractor.is_admin_forced &&
                    data.contractor.available_offers <= 0 ? (
                    ''
                  ) : (
                    <Countdown
                      timeLeft={data.contractor.time_left}
                      format={(v, f) => ' (' + f + ')'}
                      bold
                    />
                  )}
                </Tabs.Tab>
              )}

              {!!data.can_bonus_objectives && (
                <Tabs.Tab
                  key="BonusObjectives"
                  color={'transparent'}
                  onClick={() => act('give_bonus_objectives', {})}
                  icon="suitcase"
                >
                  Запросить дополнительные цели
                </Tabs.Tab>
              )}

              <Tabs.Tab
                key="LockUplink"
                // This cant ever be selected. Its just a close button.
                onClick={() => act('lock')}
                icon="lock"
              >
                Lock Uplink
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{PickTab(tabIndex)}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ItemsPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { crystals, cats } = data;
  // Default to first
  const [uplinkItems, setUplinkItems] = useLocalState(
    context,
    'uplinkItems',
    cats[0].items
  );

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const SelectEquipment = (cat, searchText = '') => {
    const EquipmentSearch = createSearch(searchText, (item) => {
      let is_hijack = item.hijack_only === 1 ? '|' + 'hijack' : '';
      return item.name + '|' + item.desc + '|' + item.cost + 'tc' + is_hijack;
    });
    return flow([
      filter((item) => item?.name), // Make sure it has a name
      searchText && filter(EquipmentSearch), // Search for anything
      sortBy((item) => item?.name), // Sort by name
    ])(cat);
  };
  const handleSearch = (value) => {
    setSearchText(value);
    if (value === '') {
      return setUplinkItems(cats[0].items);
    }
    setUplinkItems(
      SelectEquipment(cats.map((category) => category.items).flat(), value)
    );
  };

  const [showDesc, setShowDesc] = useLocalState(context, 'showDesc', 1);

  return (
    <Stack fill vertical>
      <Stack vertical>
        <Stack.Item>
          <Section
            title={'Current Balance: ' + crystals + 'TC'}
            buttons={
              <>
                <Button.Checkbox
                  content="Show Descriptions"
                  checked={showDesc}
                  onClick={() => setShowDesc(!showDesc)}
                />
                <Button
                  content="Random Item"
                  icon="question"
                  onClick={() => act('buyRandom')}
                />
                <Button
                  content="Refund Currently Held Item"
                  icon="undo"
                  onClick={() => act('refund')}
                />
              </>
            }
          >
            <Input
              fluid
              placeholder="Search Equipment"
              onInput={(e, value) => {
                handleSearch(value);
              }}
              value={searchText}
            />
          </Section>
        </Stack.Item>
      </Stack>
      <Stack fill mt={0.3}>
        <Stack.Item width="30%">
          <Section fill scrollable>
            <Tabs vertical>
              {cats.map((c) => (
                <Tabs.Tab
                  key={c}
                  selected={searchText !== '' ? false : c.items === uplinkItems}
                  onClick={() => {
                    setUplinkItems(c.items);
                    setSearchText('');
                  }}
                >
                  {c.cat}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section fill scrollable>
            <Stack vertical>
              {uplinkItems.map((i) => (
                <Stack.Item
                  key={decodeHtmlEntities(i.name)}
                  p={1}
                  backgroundColor={'rgba(255, 0, 0, 0.1)'}
                >
                  <UplinkItem
                    i={i}
                    showDecription={showDesc}
                    key={decodeHtmlEntities(i.name)}
                  />
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Stack>
  );
};

const CartPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { cart, crystals, cart_price } = data;

  const [showDesc, setShowDesc] = useLocalState(context, 'showDesc', 0);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={'Current Balance: ' + crystals + 'TC'}
          buttons={
            <>
              <Button.Checkbox
                content="Show Descriptions"
                checked={showDesc}
                onClick={() => setShowDesc(!showDesc)}
              />
              <Button
                content="Empty Cart"
                icon="trash"
                onClick={() => act('empty_cart')}
                disabled={!cart}
              />
              <Button
                content={'Purchase Cart (' + cart_price + 'TC)'}
                icon="shopping-cart"
                onClick={() => act('purchase_cart')}
                disabled={!cart || cart_price > crystals}
              />
            </>
          }
        >
          <Stack vertical>
            {cart ? (
              cart.map((i) => (
                <Stack.Item
                  key={decodeHtmlEntities(i.name)}
                  p={1}
                  mr={1}
                  backgroundColor={'rgba(255, 0, 0, 0.1)'}
                >
                  <UplinkItem
                    i={i}
                    showDecription={showDesc}
                    buttons={<CartButtons i={i} />}
                  />
                </Stack.Item>
              ))
            ) : (
              <Box italic>Your Shopping Cart is empty!</Box>
            )}
          </Stack>
        </Section>
      </Stack.Item>
      <Advert />
    </Stack>
  );
};
const Advert = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { cats, lucky_numbers } = data;

  return (
    <Stack.Item grow>
      <Section
        fill
        scrollable
        title="Suggested Purchases"
        buttons={
          <Button
            icon="dice"
            content="See more suggestions"
            onClick={() => act('shuffle_lucky_numbers')}
          />
        }
      >
        <Stack wrap>
          {lucky_numbers
            .map((number) => cats[number.cat].items[number.item])
            .filter((item) => item !== undefined && item !== null)
            .map((item, index) => (
              <Stack.Item
                key={index}
                p={1}
                mb={1}
                ml={1}
                width={34}
                backgroundColor={'rgba(255, 0, 0, 0.15)'}
              >
                <UplinkItem grow i={item} />
              </Stack.Item>
            ))}
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const UplinkItem = (props, context) => {
  const {
    i,
    showDecription = 1,
    buttons = <UplinkItemButtons i={i} />,
  } = props;

  return (
    <Section
      title={decodeHtmlEntities(i.name)}
      showBottom={showDecription}
      buttons={buttons}
    >
      {showDecription ? <Box italic>{decodeHtmlEntities(i.desc)}</Box> : null}
    </Section>
  );
};

const UplinkItemButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const { i } = props;
  const { crystals } = data;

  return (
    <>
      <Button
        icon="shopping-cart"
        color={i.hijack_only === 1 && 'red'}
        tooltip="Add to cart."
        tooltipPosition="left"
        onClick={() =>
          act('add_to_cart', {
            item: i.obj_path,
          })
        }
        disabled={i.cost > crystals}
      />
      <Button
        content={
          'Buy (' + i.cost + 'TC)' + (i.refundable ? ' [Refundable]' : '')
        }
        color={i.hijack_only === 1 && 'red'}
        // Yes I care this much about both of these being able to render at the same time
        tooltip={i.hijack_only === 1 && 'Hijack Agents Only!'}
        tooltipPosition="left"
        onClick={() =>
          act('buyItem', {
            item: i.obj_path,
          })
        }
        disabled={i.cost > crystals}
      />
    </>
  );
};

const CartButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const { i } = props;
  const { exploitable } = data;

  return (
    <Stack>
      <Button
        icon="times"
        content={'(' + i.cost * i.amount + 'TC)'}
        tooltip="Remove from cart."
        tooltipPosition="left"
        onClick={() =>
          act('remove_from_cart', {
            item: i.obj_path,
          })
        }
      />
      <Button
        icon="minus"
        tooltip={i.limit === 0 && 'Discount already redeemed!'}
        ml="5px"
        onClick={() =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: --i.amount, // one lower
          })
        }
        disabled={i.amount <= 0}
      />
      <Button.Input
        content={i.amount}
        width="45px"
        tooltipPosition="bottom-end"
        tooltip={i.limit === 0 && 'Discount already redeemed!'}
        onCommit={(e, value) =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: value,
          })
        }
        disabled={i.limit !== -1 && i.amount >= i.limit && i.amount <= 0}
      />
      <Button
        mb={0.3}
        icon="plus"
        tooltipPosition="bottom-start"
        tooltip={i.limit === 0 && 'Discount already redeemed!'}
        onClick={() =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: ++i.amount, // one higher
          })
        }
        disabled={i.limit !== -1 && i.amount >= i.limit}
      />
    </Stack>
  );
};

const ExploitableInfoPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { exploitable } = data;
  // Default to first
  const [selectedRecord, setSelectedRecord] = useLocalState(
    context,
    'selectedRecord',
    exploitable[0]
  );

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  // Search for peeps
  const SelectMembers = (people, searchText = '') => {
    const MemberSearch = createSearch(searchText, (member) => member.name);
    return flow([
      // Null member filter
      filter((member) => member?.name),
      // Optional search term
      searchText && filter(MemberSearch),
      // Slightly expensive, but way better than sorting in BYOND
      sortBy((member) => member.name),
    ])(people);
  };

  const crew = SelectMembers(exploitable, searchText);

  return (
    <Section fill title="Exploitable Records">
      <Stack fill>
        <Stack.Item width="30%" fill>
          <Section fill scrollable>
            <Input
              fluid
              mb={1}
              placeholder="Search Crew"
              onInput={(e, value) => setSearchText(value)}
            />
            <Tabs vertical>
              {crew.map((r) => (
                <Tabs.Tab
                  key={r}
                  selected={r === selectedRecord}
                  onClick={() => setSelectedRecord(r)}
                >
                  {r.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Section>
        </Stack.Item>
        <Divider vertical />
        <Stack.Item grow>
          <Section fill title={selectedRecord.name} scrollable>
            <LabeledList>
              <LabeledList.Item label="Age">
                {selectedRecord.age}
              </LabeledList.Item>
              <LabeledList.Item label="Fingerprint">
                {selectedRecord.fingerprint}
              </LabeledList.Item>
              <LabeledList.Item label="Rank">
                {selectedRecord.rank}
              </LabeledList.Item>
              <LabeledList.Item label="Sex">
                {selectedRecord.sex}
              </LabeledList.Item>
              <LabeledList.Item label="Species">
                {selectedRecord.species}
              </LabeledList.Item>
              <LabeledList.Item label="Records">
                {selectedRecord.exploit_record}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

modalRegisterBodyOverride('become_contractor', (modal, context) => {
  const { data } = useBackend(context);
  const { time_left } = data.contractor || {};
  const isAvailable = !!data?.contractor?.available;
  const isAffordable = !!data?.contractor?.affordable;
  const isAccepted = !!data?.contractor?.accepted;
  const { available_offers } = data.contractor || {};
  const isAdminForced = !!data?.contractor?.is_admin_forced;
  return (
    <Section
      height="65%"
      level="2"
      m="-1rem"
      pb="1rem"
      title={
        <>
          <Icon name="suitcase" />
          &nbsp; Contracting Opportunity
        </>
      }
    >
      <Box mx="0.5rem" mb="0.5rem">
        <b>
          Your achievements for the Syndicate have not gone unnoticed, agent. We
          have decided to give you the rare opportunity of becoming a
          Contractor.
        </b>
        <br />
        <br />
        For the small price of 100 telecrystals, we will upgrade your rank to
        that of a Contractor, allowing you to undertake kidnapping contracts for
        TC and credits.
        <br />
        In addition, you will be supplied with a Contractor Kit which contains a
        Contractor Uplink, standard issue contractor gear and three random low
        cost items.
        <br />
        <br />
        More detailed instructions can be found within your kit, should you
        accept this offer.
        {!isAdminForced ? (
          <Box>
            Hurry up. You are not the only one who received this offer. Their
            number is limited. If other traitors accept all offers before you,
            you will not be able to accept one of them.
            <br />
            <b>Available offers: {available_offers}</b>
          </Box>
        ) : (
          ''
        )}
      </Box>
      <Button.Confirm
        disabled={!isAvailable || isAccepted}
        italic={!isAvailable}
        bold={isAvailable}
        icon={isAvailable && !isAccepted && 'check'}
        color="good"
        content={
          isAccepted ? (
            'Accepted'
          ) : isAvailable ? (
            [
              'Accept Offer',
              <Countdown
                key="countdown"
                timeLeft={time_left}
                format={(v, f) => ' (' + f + ')'}
              />,
            ]
          ) : !isAffordable ? (
            'Insufficient TC'
          ) : !data.contractor.is_admin_forced ? (
            data.contractor.available_offers > 0 ? (
              <i>[Left:{data.contractor.available_offers}]</i>
            ) : (
              <i>[Offers are over]</i>
            )
          ) : (
            'Offer expired'
          )
        }
        position="absolute"
        right="1rem"
        bottom="-0.75rem"
        onClick={() => modalAnswer(context, modal.id, 1)}
      />
    </Section>
  );
});
