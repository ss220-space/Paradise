import { useBackend, useLocalState } from "../backend";
import { Button, Section, Box, Flex, NoticeBox, Tabs } from "../components";
import { Window } from "../layouts";

export const DestinationTagger = (_props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = index => {
    switch (index) {
      case 0:
        return <DestinationTaggerStation />;
      case 1:
        return <DestinationTaggerCC />;
    }
  };
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Box fillPositionedParent>
          <Tabs>
            <Tabs.Tab
              key="Station Taggers"
              selected={0 === tabIndex}
              onClick={() => setTabIndex(0)}>
              Station Taggers
            </Tabs.Tab>
            <Tabs.Tab
              key="CC Taggers"
              selected={1 === tabIndex}
              onClick={() => setTabIndex(1)}>
              CC Taggers
            </Tabs.Tab>
          </Tabs>
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};

export const DestinationTaggerStation = (_props, context) => {
  const { act, data } = useBackend(context);

  const { destinations, selected_destination_id } = data;

  let selected_destination = destinations[selected_destination_id - 1];

  return (
    <Section
      title="TagMaster 3.0"
      textAlign="center">
      <NoticeBox
        textAlign="center"
        style={{ "font-style": "normal" }}>
        Destination: {selected_destination.name ?? "None"}
      </NoticeBox>
      <Box>
        <Flex
          style={{ "display": "flex", "flex-wrap": "wrap", "align-content": "flex-start", "justify-content": "center" }}>
          {destinations.map((destination, index) => (
            <Flex.Item key={index} m="2px">
              <Button
                width="118px"
                textAlign="center"
                content={destination.name}
                selected={destination.id === selected_destination_id}
                onClick={() =>
                  act("select_destination", {
                    destination: destination.id,
                  })}
              />
            </Flex.Item>
          ))}
        </Flex>
      </Box>
    </Section>
  );
};

export const DestinationTaggerCC = (_props, context) => {
  const { act, data } = useBackend(context);

  const { centcom_destinations, selected_centcom_id } = data;

  return (
    <Section
      title="CCTagMaster 1.1"
      textAlign="center">
      <NoticeBox
        textAlign="center"
        style={{ "font-style": "normal" }}>
        Destination: {selected_centcom_id ?? "None"}
      </NoticeBox>
      <Box>
        <Flex
          style={{ "display": "flex", "flex-wrap": "wrap", "align-content": "flex-start", "justify-content": "center" }}>
          {centcom_destinations.map((destination, index) => (
            <Flex.Item key={index} m="2px">
              <Button
                width="220px"
                textAlign="center"
                content={destination.name}
                selected={destination.name === selected_centcom_id}
                onClick={() =>
                  act("select_cc_destination", {
                    destination: destination.name,
                  })}
              />
            </Flex.Item>
          ))}
        </Flex>
      </Box>
    </Section>
  );
};
