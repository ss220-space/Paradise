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
    <Window theme="ntOS95">
      <Window.Content>
        <Flex>
          <FlexItem basis={36}>
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
          <Flex.Item grow={1} basis={0}>
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
                <Box mx="0.5rem" mb="0.5rem">
                  <b>Name: </b>{questInfo.name}
                  <br /><br />
                  <b>Desc: </b>{questInfo.desc}
                </Box>
                <Section title="Modules" level = {2} >
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
            </Section>

            <Button
              icon="arrow-up"
              content="Send Mech"
              disabled={!hasID || !hasTask}
              onClick={() => act('SendMech')} />
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
