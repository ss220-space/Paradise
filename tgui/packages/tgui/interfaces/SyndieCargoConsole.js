import { flow } from 'common/fp';
import { Component, Fragment } from 'inferno';
import { classes } from '../../common/react';
import { filter, sortBy } from 'common/collections';
import { useBackend, useSharedState, useLocalState } from "../backend";
import { Button, Flex, LabeledList, Box, NoticeBox, AnimatedNumber, Section, Dropdown, Input, Table, Modal, Tabs } from "../components";
import { Window } from "../layouts";
import { LabeledListItem } from "../components/LabeledList";
import { createSearch, toTitleCase } from 'common/string';
/*
export const SyndieCargoConsole = (properties, context) => {
  const { data } = useBackend(context);
  return (
    <Window theme={data.ui_theme}>
      <Window.Content className="Menu">
        <Flex direction="column" height="100%">
          {body}
        </Flex>
      </Window.Content>
    </Window>
  );
};
*/
export const SyndieCargoConsole = (properties, context) => {
  const { act, data } = useBackend(context);
  let body;
  if (data.page === 0) {
    body = (
      <Flex
        direction="column"
        spacing={1}>
        <Flex.Item basis="content" >
          <PagePane />
        </Flex.Item>
        <Flex.Item mt={1}>
          <ContentsModal />
          <StatusPane />
          <CataloguePane />
          <DetailsPane />
        </Flex.Item>
      </Flex>
    );
  } else if (data.page === 1) {
    body = (
      <Flex
        direction="column"
        spacing={1}>
        <Flex.Item basis="content">
          <PagePane />
        </Flex.Item>
        <Flex.Item mt={1}>
          <ContentsModal />
          <QuestStatusPane />
        </Flex.Item>
      </Flex>
    );
  }
  return (
    <Window theme={data.ui_theme}>
      <Window.Content className="SyndieCargoConsole">
        <Flex direction="column" height="100%">
          {body}
        </Flex>
      </Window.Content>
    </Window>
  );
};

const ContentsModal = (properties, context) => {
  const [
    contentsModal,
    setContentsModal,
  ] = useLocalState(context, 'contentsModal', null);

  const [
    contentsModalTitle,
    setContentsModalTitle,
  ] = useLocalState(context, 'contentsModalTitle', null);
  if ((contentsModal !== null) && (contentsModalTitle !== null)) {
    return (
      <Modal
        maxWidth="75%"
        width={(window.innerWidth) + "px"}
        maxHeight={(window.innerHeight * 0.75) + "px"}
        mx="auto">
        <Box width="100%" bold><h1>{contentsModalTitle} contents:</h1></Box>
        <Box>
          {contentsModal.map(i => (
            // This needs keying. I hate it.
            <Box key={i}>
              - {i}
            </Box>
          ))}
        </Box>
        <Box m={2}>
          <Button
            content="Close"
            onClick={() => {
              setContentsModal(null);
              setContentsModalTitle(null);
            }}
          />
        </Box>
      </Modal>
    );
  } else {
    return;
  }
};

const PagePane = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    page,
  } = data;

  let ButtonText = "";
  if (page === 0) {
    ButtonText = "Открыть меню контрактов";
  } else if (page === 1) {
    ButtonText = "Закрыть меню контрактов";
  }

  return (
    <Section title="">
      <Table m="0.5rem">
        <Table.Row>
          <Table.Cell textAlign="center" pr={1}>
            <Button
              width="200px"
              textAlign="center"
              content={ButtonText}
              tooltip="Открывает меню доступных контрактов. Выполняя заказы для чёрного рынка вы сможете заработать деньги для своих нужд!"
              onClick={() => act("openContracts")}
            />
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

// Cargo
const StatusPane = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    is_public = 0,
    cash,
    wait_time,
    is_cooldown,
    telepads_status,
    adminAddCash,
  } = data;


  // Shuttle status text
  let statusText = telepads_status;
  let dynamicTooltip = "";
  let block = 0;
  let teleportButtonText = "";
  if (telepads_status === "Pads not linked!") {
    block = 0;
    dynamicTooltip = "Attempts to link telepads to the console.";
    teleportButtonText = "Link pads";
  } else if (!is_cooldown) {
    block = 0;
    dynamicTooltip = "Teleports your crates to the market. A reminder, some of the crates are directly stolen from NT trading routes. That means they can be locked. We are NOT sorry for the inconvenience";
    teleportButtonText = "Teleport";
  } else if (is_cooldown) {
    teleportButtonText = "Cooldown...";
    dynamicTooltip = "Pads are cooling off...";
    block = 1;
    if (wait_time !== 1) {
      statusText = "" + telepads_status + " (ETA: " + wait_time + " seconds)";
    } else {
      statusText = "" + telepads_status + " (ETA: " + wait_time + " second)";
    }
  }

  return (
    <Section title="Status">
      <LabeledList>
        {is_public === 0 && (
          <LabeledList.Item label="Money Available">
            <Table m="0.5rem">
              <Table.Row>
                <Table.Cell textAlign="left" pr={1}>
                  <Button
                    icon="credit-card"
                    tooltip="Withdraw money from the console"
                    tooltipPosition="right"
                    content={cash}
                    onClick={() => act("withdraw", cash)}
                  />
                </Table.Cell>
                <Table.Cell textAlign="right" pr={1}>
                  <Button
                    textAlign="center"
                    width="150px"
                    icon="lock"
                    content={adminAddCash}
                    tooltip="Bless the players with da money!"
                    tooltipPosition="left"
                    onClick={() => act("add_money", cash)}
                  />
                </Table.Cell>
              </Table.Row>
            </Table>

          </LabeledList.Item>
        )}
        <LabeledList.Item label="Telepads Status">
          <Table m="0.5rem">
            <Table.Row>
              <Table.Cell textAlign="left" pr={1}>
                {statusText}
              </Table.Cell>
            </Table.Row>
          </Table>
        </LabeledList.Item>
        {is_public === 0 && (
          <LabeledList.Item label="Controls">
            <Table m="0.5rem">
              <Table.Row>
                <Table.Cell textAlign="left" pr={1}>
                  <Button
                    content={teleportButtonText}
                    tooltip={dynamicTooltip}
                    tooltipPosition="right"
                    disabled={block}
                    onClick={() => act("teleport")}
                  />
                </Table.Cell>
                <Table.Cell textAlign="right" pr={1}>
                  <Button
                    icon="server"
                    textAlign="center"
                    width="150px"
                    content="Black Market Log"
                    tooltip="View your syndicate cargo account activity log."
                    tooltipPosition="left"
                    onClick={() => act("showMessages")}
                  />
                </Table.Cell>
              </Table.Row>
            </Table>
          </LabeledList.Item>
        )}

      </LabeledList>
    </Section>
  );
};


const CataloguePane = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    categories,
    supply_packs,
  } = data;

  const [
    category,
    setCategory,
  ] = useSharedState(context, "category", "Emergency");

  const [
    searchText,
    setSearchText,
  ] = useSharedState(context, "search_text", "");

  const [
    contentsModal,
    setContentsModal,
  ] = useLocalState(context, 'contentsModal', null);

  const [
    contentsModalTitle,
    setContentsModalTitle,
  ] = useLocalState(context, 'contentsModalTitle', null);

  const packSearch = createSearch(searchText, crate => crate.name);

  const cratesToShow = flow([
    filter(pack => (pack.cat === categories.filter(
      c => c.name === category)[0].category || searchText)
    ), searchText && filter(packSearch),
    sortBy(pack => pack.name.toLowerCase()),
  ])(supply_packs);

  let titleText = "Crate Catalogue";
  if (searchText) {
    titleText = "Results for '" + searchText + "':";
  } else if (category) {
    titleText = "Browsing " + category;
  }
  return (
    <Section
      title={titleText}
      buttons={
        <Dropdown
          textAlign="center"
          width="150px"
          options={categories.map(r => r.name)}
          selected={category}
          onSelected={val => setCategory(val)} />
      }>
      <Input
        fluid
        placeholder="Search for..."
        onInput={(e, v) => setSearchText(v)}
        mb={1} />
      <Box maxHeight={25} overflowY="auto" overflowX="hidden">
        <Table m="0.5rem">
          {cratesToShow.map(c => (
            <Table.Row key={c.name}>
              <Table.Cell bold>
                {c.name} ({c.cost} Credits)
              </Table.Cell>
              <Table.Cell textAlign="right" pr={1}>
                <Button
                  content="Order 1"
                  icon="shopping-cart"
                  onClick={() => act("order", {
                    crate: c.ref,
                    multiple: 0,
                  })}
                />
                <Button
                  content="Order Multiple"
                  icon="cart-plus"
                  onClick={() => act("order", {
                    crate: c.ref,
                    multiple: 1,
                  })}
                />
                <Button
                  content="View Contents"
                  icon="search"
                  onClick={() => {
                    setContentsModal(c.contents);
                    setContentsModalTitle(c.name);
                  }}
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Box>
    </Section>
  );
};

const DetailsPane = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    requests,
    canapprove,
    orders,
  } = data;
  return (
    <Section title="Details">
      <Box maxHeight={15} overflowY="auto" overflowX="hidden">
        <Box bold>Requests</Box>
        <Table m="0.5rem">
          {requests.map(r => (
            <Table.Row key={r.ordernum}>
              <Table.Cell>
                <Box>
                  - #{r.ordernum}: {r.supply_type} for <b>{r.orderedby}</b>
                </Box>
                <Box italic>
                  Reason: {r.comment}
                </Box>
              </Table.Cell>
              <Table.Cell textAlign="right" pr={1}>
                <Button
                  content="Approve"
                  color="green"
                  disabled={!canapprove}
                  onClick={() => act("approve", {
                    ordernum: r.ordernum,
                  })}
                />
                <Button
                  content="Deny"
                  color="red"
                  onClick={() => act("deny", {
                    ordernum: r.ordernum,
                  })}
                />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
        <Box bold>Confirmed Orders</Box>
        <Table m="0.5rem">
          {orders.map(r => (
            <Table.Row key={r.ordernum}>
              <Table.Cell>
                <Box>
                  - #{r.ordernum}: {r.supply_type} for <b>{r.orderedby}</b>
                </Box>
                <Box italic>
                  Reason: {r.comment}
                </Box>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Box>
    </Section>
  );
};

// Quests
const QuestStatusPane = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    telepads_status,
  } = data;

  return (
    <Flex
      direction="row"
      alignContent="center"
      spacing={1}>
      <Flex.Item
        width="33%"
        shrink={1}
        className="SyndieCargoConsole--flex">
        <Box align="center" fontSize={1.25}>
          <NoticeBox success={0} danger={0} align="center">
            <Box align="center" fontSize={1.25}>
              <Button
                fluid={1}
                height="20px"
                textAlign="center"
                content="Взять контракт"
                tooltip="Взять контракт?"
                onClick={() => act("openContracts")}
              />
            </Box>
            <marquee>
              {"Название контракта писать тут"}
            </marquee>
          </NoticeBox>
        </Box>
        <Section>
          <Box bold align="center" textAlign="left" maxHeight={30}>
            Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit, amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur? At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.
          </Box>
        </Section>
      </Flex.Item>
      <Flex.Item
        width="33%"
        shrink={1}
        className="SyndieCargoConsole--flex">
        <Box align="center" fontSize={1.25}>
          <NoticeBox success={0} danger={0} align="center">
            <Box align="center" fontSize={1.25}>
              <Button
                fluid={1}
                height="20px"
                textAlign="center"
                content="Взять контракт"
                tooltip="Взять контракт?"
                onClick={() => act("openContracts")}
              />
            </Box>
            <marquee>
              {"Название контракта писать тут"}
            </marquee>
          </NoticeBox>
        </Box>
        <Section>
          <Box bold align="center" textAlign="left" maxHeight={30}>
            Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit, amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur? At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.
          </Box>
        </Section>
      </Flex.Item>
      <Flex.Item
        width="33%"
        shrink={1}
        className="SyndieCargoConsole--flex">
        <Box align="center" fontSize={1.25}>
          <NoticeBox success={0} danger={0} align="center">
            <Box align="center" fontSize={1.25}>
              <Button
                fluid={1}
                height="20px"
                textAlign="center"
                content="Взять контракт"
                tooltip="Взять контракт?"
                onClick={() => act("openContracts")}
              />
            </Box>
            <marquee>
              {"Название контракта писать тут"}
            </marquee>
          </NoticeBox>
        </Box>
        <Section>
          <Box bold align="center" textAlign="left" maxHeight={30}>
            Sed ut perspiciatis, unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa, quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt, explicabo. Nemo enim ipsam voluptatem, quia voluptas sit, aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos, qui ratione voluptatem sequi nesciunt, neque porro quisquam est, qui dolorem ipsum, quia dolor sit, amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt, ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit, qui in ea voluptate velit esse, quam nihil molestiae consequatur, vel illum, qui dolorem eum fugiat, quo voluptas nulla pariatur? At vero eos et accusamus et iusto odio dignissimos ducimus, qui blanditiis praesentium voluptatum deleniti atque corrupti, quos dolores et quas molestias excepturi sint, obcaecati cupiditate non provident, similique sunt in culpa, qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio, cumque nihil impedit, quo minus id, quod maxime placeat, facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet, ut et voluptates repudiandae sint et molestiae non recusandae. Itaque earum rerum hic tenetur a sapiente delectus, ut aut reiciendis voluptatibus maiores alias consequatur aut perferendis doloribus asperiores repellat.
          </Box>
        </Section>
      </Flex.Item>
    </Flex>
  );
};

