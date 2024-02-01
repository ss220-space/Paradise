import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Section, Button, Flex, LabeledList, Divider } from '../components';
import { Window } from '../layouts';
import { FlexItem } from '../components/Flex';

export const RoboQuest = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    hasID,
    name,
    questInfo,
    hasTask,
  } = data;
  return (
    <Window theme="ntos_roboquest" resizable>
      <Window.Content>
        <Flex>
          <FlexItem basis={40}>
            <Section title="Mecha"
              buttons={(
                <Button
                    content="Check Mech"
                    disabled={!hasID || !hasTask}
                    onClick={() => act('Check')} />
              )}>
                <Flex>
                  <FlexItem basis={60} textAlign="center" align="center">
                    {!!hasTask && (
                      <img
                        height="128px"
                        width="128px"
                        src={`data:image/jpeg;base64,${questInfo.icon}`}
                        style={{
                          "margin-left": "0px",
                          "-ms-interpolation-mode": "nearest-neighbor",
                        }} />
                      )}
                  </FlexItem>
                  <FlexItem>
                    <Divider vertical/>
                  </FlexItem>
                  <FlexItem basis={40}>
                      {!!questInfo.module1 && (
                        <img
                          height="64px"
                          width="64px"
                          src={`data:image/jpeg;base64,${questInfo.module1_icon}`}
                          style={{
                            "margin-left": "0px",
                            "-ms-interpolation-mode": "nearest-neighbor",
                          }} />
                      )}
                      {!!questInfo.module2 && (
                        <img
                          height="64px"
                          width="64px"
                          src={`data:image/jpeg;base64,${questInfo.module2_icon}`}
                          style={{
                            "margin-left": "0px",
                            "-ms-interpolation-mode": "nearest-neighbor",
                          }} />
                      )}
                      {!!questInfo.module3 && (
                        <img
                          height="64px"
                          width="64px"
                          src={`data:image/jpeg;base64,${questInfo.module3_icon}`}
                          style={{
                            "margin-left": "0px",
                            "-ms-interpolation-mode": "nearest-neighbor",
                          }} />
                      )}
                      {!!questInfo.module4 && (
                        <img
                          height="64px"
                          width="64px"
                          src={`data:image/jpeg;base64,${questInfo.module4_icon}`}
                          style={{
                            "margin-left": "0px",
                            "-ms-interpolation-mode": "nearest-neighbor",
                          }} />
                      )}
                  </FlexItem>
                </Flex>
            </Section>
          </FlexItem>
          <FlexItem basis={20}/>
          <Flex.Item grow={1} basis={40}>
            <Section title="Task's info"
              buttons={(
                <Fragment>
                  <Button
                    icon="id-card"
                    content="Eject ID"
                    disabled={!hasID}
                    onClick={() => act('RemoveID')} />
                  <Button
                    icon="arrow-down"
                    content="Get Task"
                    disabled={!hasID || hasTask}
                    onClick={() => act('GetTask')} />
                </Fragment>
              )}>
                <Box mx="0.5rem" mb="1rem">
                  <b>Name: </b>{questInfo.name}
                  <br />
                  <b>Desc: </b>{questInfo.desc}
                </Box>
                <Section title="Modules" level = {2}>
                  <Box mx="0.5rem" mb="0.5rem">
                      <b>Module 1: </b>{questInfo.module1}
                      <br /><br />
                      <b>Module 2: </b>{questInfo.module2}
                      <br /><br />
                      <b>Module 3: </b>{questInfo.module3}
                      <br /><br />
                      <b>Module 4: </b>{questInfo.module4}
                  </Box>
              </Section>
              <Box mb="0.5rem" textAlign="center">
                <br />
                <Button
                  icon="arrow-up"
                  width="15rem"
                  bold
                  content="Send Mech"
                  textAlign="center"
                  disabled={!hasID || !hasTask}
                  onClick={() => act('SendMech')}/>
              </Box>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
