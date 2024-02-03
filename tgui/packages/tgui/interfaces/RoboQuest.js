import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
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
    canCheck,
    canSend,
    checkMessage,
    style,
    cooldown,
    shopItems,
  } = data;
  const [ shopState, changeShopState ] = useLocalState(context, "shopState", false);
  return (
    <Window theme={style} resizable>
      <Window.Content>
        <Flex>
          <FlexItem basis={40}>
            <Section title="Mecha"
              buttons={(
                  <Fragment>
                    <Button
                      content="Check Mech"
                      disabled={!hasID || !hasTask || !canCheck || cooldown}
                      onClick={() => act('Check')} />
                    <Button
                      icon="cog"
                      onClick={() => act('ChangeStyle')} />
                  </Fragment>
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
                {!!hasTask &&
                  <Fragment>
                    <Divider/>
                    <b>{checkMessage}</b>
                  </Fragment>}
                {!!cooldown &&
                  <Fragment>
                    <b>За отказ от заказа, вы были отстранены от работы на некоторое время.</b>
                    <br />
                    <b>{cooldown}</b>
                  </Fragment>}
            </Section>
          </FlexItem>
          <FlexItem basis={20}>
            <Section title="Other"
            buttons={
              <Button
                content="Shop"
                onClick={() => changeShopState(!shopState)}/>
            } />
          </FlexItem>
          <FlexItem basis={40}>
            {!shopState &&
              <Section title="Task's info"
                buttons={(
                  <Fragment>
                    <Button
                      icon="id-card"
                      content="Eject ID"
                      disabled={!hasID}
                      onClick={() => act('RemoveID')} />
                    {!hasTask &&
                      <Button
                      icon="arrow-down"
                      content="Get Task"
                      disabled={!hasID || cooldown}
                      onClick={() => act('GetTask')} />}
                    {!!hasTask &&
                      <Button
                        icon="arrow-down"
                        content="Remove Task"
                        disabled={!hasID || cooldown}
                        onClick={() => act('RemoveTask')} />}
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
                  disabled={!hasID || !hasTask || !canSend || cooldown}
                  onClick={() => act('SendMech')}/>
              </Box>
            </Section>}
            {!!shopState &&
              <Section title = "Shop">
                <Box maxHeight={30} overflowY="auto" overflowX="hidden">
                  {shopItems.map(i => (
                    <Section
                      key={i.name}
                      title={i.name}
                      buttons={
                        <Button
                          content={
                            "Buy ("
                            + i.cost
                            + "P)"
                          }
                        />
                      }>
                      <Box italic>{i.desc}</Box>
                    </Section>
                  ))}
                </Box>
              </Section>
            }
          </FlexItem>
        </Flex>
      </Window.Content>
    </Window>
  );
};
