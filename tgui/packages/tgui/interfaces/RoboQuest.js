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
    points
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
                  <FlexItem basis={42}>
                    <Flex>
                      <FlexItem>
                        {!!hasTask && questInfo.modules.map(i => (
                            i.id < 4 && <img
                              key={i.id}
                              height="64px"
                              width="64px"
                              src={`data:image/jpeg;base64,${i.icon}`}
                              style={{
                                "margin-left": "0px",
                                "-ms-interpolation-mode": "nearest-neighbor",
                              }} />
                          ))}
                      </FlexItem>
                      <FlexItem>
                        {!!hasTask && questInfo.modules.map(i => (
                            i.id > 3 && <img
                              key={i.id}
                              height="64px"
                              width="64px"
                              src={`data:image/jpeg;base64,${i.icon}`}
                              style={{
                                "margin-left": "0px",
                                "-ms-interpolation-mode": "nearest-neighbor",
                              }} />
                          ))}
                      </FlexItem>
                    </Flex>
                  </FlexItem>
                </Flex>
                  <Fragment>
                    <Divider/>
                    <b>{checkMessage}</b>
                  </Fragment>
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
              <Fragment>
                <Button
                  content="Print"
                  onClick={() => act("printOrder")}
                  disabled = {!hasTask}/>
                <Button
                  content="Shop"
                  onClick={() => changeShopState(!shopState)}/>
              </Fragment>
            }>
            Здраствуйте,
            <br />
            <b>{name}</b>
            <br />
            Текущий баланс:
            <br />
            <b>{points}</b> очков
            </Section>
          </FlexItem>
          <FlexItem basis={38}>
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
                      {!!hasTask && questInfo.modules.map(i => (
                        <Fragment key={i.id}><b>Module {i.id}</b>: {i.name} <br /><br /></Fragment>
                        ))
                      }
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
                    (!i.emagOnly || style==="syndicate") && <Section
                      key={i.name}
                      title={i.name}
                      buttons={
                        <Button
                          content={
                            "Buy ("
                            + i.cost
                            + "P)"
                          }
                          onClick={() =>
                            act("buyItem", {
                              item: i.path,
                              cost: i.cost,
                            })}
                          disabled={!hasID || i.cost > points}
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
