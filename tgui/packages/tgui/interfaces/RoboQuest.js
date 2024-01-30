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
    check,
    hasTask,
  } = data;
  return (
    <Window>
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
                Тут будет текстовая инфа, аля прошел ли мех проверку, можно ли отправить и тд
                <Button
                  icon="arrow-up"
                  content="Send Mech"
                  disabled={!hasID || !check}
                  onClick={() => act('SendMech')} />
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
