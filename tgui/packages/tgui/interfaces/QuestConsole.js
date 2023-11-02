import { useBackend, useLocalState } from "../backend";
import { Button, Tabs, Box, Flex, Section, Tooltip, Collapsible } from "../components";
import { Window } from "../layouts";
import { decodeHtmlEntities } from 'common/string';
import { FlexItem } from '../components/Flex';

export const QuestConsole = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = index => {
    switch (index) {
      case 0:
        return (<QuestPage
          source_customer="centcomm"
        />);
      case 1:
        return (<QuestPage
          source_customer="corporation"
        />);
      case 2:
        return (<QuestPage
          source_customer="plasma"
        />);
      case 3:
        return <StatusPane />;
    }
  };
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Box fillPositionedParent>
          <Tabs>
            <Tabs.Tab
              key="NT Requests"
              selected={0 === tabIndex}
              onClick={() => setTabIndex(0)}>
              NT Requests
            </Tabs.Tab>
            <Tabs.Tab
              key="Commercial"
              selected={1 === tabIndex}
              onClick={() => setTabIndex(1)}>
              Commercial
            </Tabs.Tab>
            <Tabs.Tab
              key="Plasma Supply"
              selected={2 === tabIndex}
              onClick={() => setTabIndex(2)}>
              Plasma Supply
            </Tabs.Tab>
            <Tabs.Tab
              key="Management"
              selected={3 === tabIndex}
              onClick={() => setTabIndex(3)}>
              Management
            </Tabs.Tab>
          </Tabs>
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};


const StatusPane = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    points,
    timeleft,
    moving,
    at_station,
    techs,
  } = data;
  { techs.map(tech => (
    tech
  )); }

  // Shuttle status text
  let statusText;
  if (!moving && !at_station) {
    statusText = "Docked off-station";
  } else if (!moving && at_station) {
    statusText = "Docked at the station";
  } else if (moving) {
    if (timeleft !== 1) {
      statusText = "Shuttle is en route (ETA: " + timeleft + " minutes)";
    } else {
      statusText = "Shuttle is en route (ETA: " + timeleft + " minute)";
    }
  }

  return (
    <Box>
      <Section title="Status">
        <Box> Points Available: {points}</Box>
        <Box> Shuttle Status: {statusText}</Box>
      </Section>
      <Section title="Sent Technologies">
        {techs.map((tech, index) => (
          <Box key={index}> {tech.tech_name}: {tech.tech_level || "0"}</Box>
        ))}
      </Section>
    </Box>
  );
};

const QuestPage = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    source_customer,
  } = properties;
  const {
    quests,
  } = data;
  return (
    <Box>
      {quests.map((quest, index) => (
        (source_customer !== quest.customer
        ) || (
          <Section
            title={"Quest " + ++index}
            className={"QuestConsole__Section"+quest.reward_color}
            buttons={
              <Box>
                <Button
                  content={quest.active ? <Box bold> QUEST ACTIVE</Box> : 'Activate'}
                  disabled={quest.active}
                  onClick={() => act('activate', { uid: quest.ref })}
                />
                <Button
                  content={<Box bold>Reroll</Box>}
                  disabled={quest.active}
                  onClick={() => act('denied', { uid: quest.ref })}
                />
              </Box>
            }
            style={{
              'text-align': 'center',
              'background-color': '#4b4d4b',
              'white-space': 'pre',
              margin: '10px',
              'border-radius': '15px',
              'margin-right': '5%',
              'margin-top': '25px',
              'bottom-color': '#111111',
            }}>
            <Flex
              style={{
                'text-align': 'left',
                'vertical-align': 'middle',
                'flex-direction': 'column',
                spacing: '1',
              }}>
              <FlexItem>
                {quest.quests_items.map((task, index) => (
                  <Flex key={index} >
                    <FlexItem
                      width={'64px'}
                      style={{
                        'margin-bottom': '6px',
                        'margin-left': '35px',
                      }}>
                      <Box position="relative">
                        <Tooltip
                          position="right"
                          content={"Send " + task.quest_type_name} />
                        <img
                          src={`data:image/jpeg;base64,${task.image}`}
                          style={{
                            'vertical-align': 'middle',
                            width: '64px',
                            margin: '0px',
                            'margin-left': '0px',
                            'border-style': 'outset',
                            'border-color': '#E8E4C9',
                            outline: '3px solid #161613',
                            'background-color': '#808080',
                          }}
                        />
                      </Box>
                    </FlexItem>
                    <FlexItem
                      style={{
                        'margin-bottom': '6px',
                        'margin-left': '15px',
                      }}>
                      {decodeHtmlEntities(task.desc)}
                    </FlexItem>
                  </Flex>
                ))}
              </FlexItem>
              <Flex style={{
                'vertical-align': 'middle',
                margin: '0px',
                'margin-left': '15px',
                outline: '3px solid #161613',
                'background-color': '#3e3d4a',
              }}>
                <FlexItem basis="45%">
                  <Box bold color={quest.fast_bonus ? 'green' : 'bad'}>Time left: {quest.timer} - Fast time bonus {quest.fast_bonus ? 'active' : 'expired'}</Box>
                </FlexItem>
                <FlexItem basis="25%">
                  PROFIT: +{quest.reward} {quest.customer === "corporation" ? 'credits' : 'points'}
                </FlexItem>
                <FlexItem basis="35%">
                  <Box bold color="good">Send to {quest.target_departament}</Box>
                </FlexItem>
              </Flex>
            </Flex>
          </Section>
        )
      ))}
    </Box>
  );
};


