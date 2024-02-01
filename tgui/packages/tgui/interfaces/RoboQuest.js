import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Section, Button, Flex, LabeledList } from '../components';
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
    <Window theme="ntos_roboquest">
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
                Тут будут картинки с выбранным мехов и модулями
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
                  <br /><br />
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
