import { useBackend } from '../backend';
import { useState } from 'react';
import { Button, Section, Box, Flex, NoticeBox, Tabs } from '../components';
import { Window } from '../layouts';

export const DestinationTagger = (_props: unknown) => {
  const [tabName, setTab] = useState('station');
  return (
    <Window width={395} height={350}>
      <Window.Content scrollable>
        <Box fillPositionedParent>
          <Tabs>
            <Tabs.Tab
              key="Station Taggers"
              selected={tabName === 'station'}
              onClick={() => setTab('station')}
            >
              Station Taggers
            </Tabs.Tab>
            <Tabs.Tab
              key="CC Taggers"
              selected={tabName === 'centcomm'}
              onClick={() => setTab('centcomm')}
            >
              CC Taggers
            </Tabs.Tab>
            <Tabs.Tab
              key="Corp Taggers"
              selected={tabName === 'corp'}
              onClick={() => setTab('corp')}
            >
              Corp Taggers
            </Tabs.Tab>
          </Tabs>
          {tabName === 'station' ? (
            <DestinationTaggerStation />
          ) : (
            <DestinationTaggerCC iscorp={tabName === 'corp'} />
          )}
        </Box>
      </Window.Content>
    </Window>
  );
};

type DestinationData = {
  destinations: Destination[];
  corporation_destinations: Destination[];
  centcom_destinations: Destination[];
  selected_destination_id: number;
  selected_centcom_id: string;
};

type Destination = {
  id: number;
  name: string;
};

export const DestinationTaggerStation = (_props: unknown) => {
  const { act, data } = useBackend<DestinationData>();

  const { destinations, selected_destination_id } = data;

  let selected_destination = destinations[selected_destination_id - 1];

  return (
    <Section title="TagMaster 4.0" textAlign="center">
      <NoticeBox textAlign="center" style={{ fontStyle: 'normal' }}>
        Destination: {selected_destination.name ?? 'None'}
      </NoticeBox>
      <Box>
        <Flex wrap="wrap" align="start" justify="center">
          {destinations.map((destination, index) => (
            <Flex.Item key={index} m="2px">
              <Button
                width="118px"
                textAlign="center"
                selected={destination.id === selected_destination_id}
                onClick={() =>
                  act('select_destination', {
                    destination: destination.id,
                  })
                }
              >
                {destination.name}
              </Button>
            </Flex.Item>
          ))}
        </Flex>
      </Box>
    </Section>
  );
};

export const DestinationTaggerCC = (props) => {
  const { act, data } = useBackend<DestinationData>();

  const { selected_centcom_id } = data;

  let far_destinations = props.iscorp
    ? data.corporation_destinations
    : data.centcom_destinations;

  return (
    <Section title="CCTagMaster 1.1" textAlign="center">
      <NoticeBox textAlign="center" style={{ fontStyle: 'normal' }}>
        Destination: {selected_centcom_id ?? 'None'}
      </NoticeBox>
      <Box>
        <Flex wrap="wrap" align="start" justify="center">
          {far_destinations.map((destination, index) => (
            <Flex.Item key={index} m="2px">
              <Button
                width="220px"
                textAlign="center"
                selected={destination.name === selected_centcom_id}
                onClick={() =>
                  act('select_cc_destination', {
                    destination: destination.name,
                  })
                }
              >
                {destination.name}
              </Button>
            </Flex.Item>
          ))}
        </Flex>
      </Box>
    </Section>
  );
};
