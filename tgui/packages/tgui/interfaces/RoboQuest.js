import { classes } from 'common/react';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Section,
  Tooltip,
  Button,
  Stack,
  LabeledList,
  Divider,
} from '../components';
import { Window } from '../layouts';

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
    points,
    cats,
  } = data;

  const [shopState, changeShopState] = useLocalState(
    context,
    'shopState',
    false
  );

  return (
    <Window theme={style} width={940} height={540}>
      <Window.Content>
        <Stack fill>
          <Stack.Item basis={40}>
            {!shopState && (
              <Section
                fill
                title="Mecha"
                buttons={
                  <Button
                    content="Check Mech"
                    icon="search"
                    disabled={!hasID || !hasTask || !canCheck || cooldown}
                    onClick={() => act('Check')}
                  />
                }
              >
                <Stack>
                  <Stack.Item basis={60} textAlign="center" align="center">
                    {!!hasTask && (
                      <img
                        className={classes([
                          'roboquest_large128x128',
                          questInfo.icon,
                        ])}
                      />
                    )}
                  </Stack.Item>
                  <Stack.Item>
                    <Divider vertical />
                  </Stack.Item>
                  <Stack.Item basis={42}>
                    <Stack>
                      <Stack.Item>
                        {!!hasTask &&
                          questInfo.modules.map(
                            (i) =>
                              i.id < 4 && (
                                <img
                                  key={i.id}
                                  className={classes([
                                    'roboquest64x64',
                                    i.icon,
                                  ])}
                                />
                              )
                          )}
                      </Stack.Item>
                      <Stack.Item>
                        {!!hasTask &&
                          questInfo.modules.map(
                            (i) =>
                              i.id > 3 && (
                                <img
                                  key={i.id}
                                  className={classes([
                                    'roboquest64x64',
                                    i.icon,
                                  ])}
                                />
                              )
                          )}
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                </Stack>
                <>
                  <Divider />
                  <b>{checkMessage}</b>
                </>
                {!!cooldown && (
                  <>
                    <b>
                      За отказ от заказа, вы были отстранены от работы на
                      некоторое время.
                    </b>
                    <br />
                    <b>{cooldown}</b>
                  </>
                )}
              </Section>
            )}
            {!!shopState && (
              <Section
                fill
                title={
                  <Box>
                    Corps bounties
                    <Box>
                      Points: <b style={{ color: 'brown' }}>{points.working}</b>
                      |<b style={{ color: 'lightblue' }}>{points.medical}</b>|
                      <b style={{ color: 'red' }}>{points.security}</b>
                    </Box>
                  </Box>
                }
              >
                {/* <Box overflowY="auto" overflowX="hiddem"> */}
                <Stack direction="column" alignContent="center">
                  {cats.number.map((stage) => (
                    <Stack.Item key={stage}>
                      <Stack
                        alignContent="center"
                        textAlign="center"
                        mr={8}
                        ml={8}
                      >
                        {cats[stage].map((cat) => (
                          <Stack.Item grow="1" key={cat}>
                            <Stack vertical alignContent="center">
                              {!(
                                shopItems[cat] === undefined ||
                                shopItems[cat].length === 0
                              ) &&
                                shopItems[cat].map((i) => (
                                  <Stack.Item grow="1" basis="33" key={i.path}>
                                    {/* <Button
                                      height="64px"
                                      width="64px"
                                      onClick={() =>
                                        act('buyItem', {
                                          item: i.path,
                                        })
                                      }
                                    >
                                      <img
                                        className={classes([
                                          'roboquest64x64',
                                          i.icon,
                                        ])}
                                      />
                                      <Tooltip
                                        title={i.name}
                                        content={`${i.desc}\n ${i.cost.working + '|' + i.cost.medical + '|' + i.cost.security}`}
                                      />
                                    </Button> */}
                                  </Stack.Item>
                                ))}
                            </Stack>
                          </Stack.Item>
                        ))}
                      </Stack>
                    </Stack.Item>
                  ))}
                </Stack>
              </Section>
            )}
          </Stack.Item>
          <Stack.Item basis={20}>
            <Section
              fill
              title="Other"
              buttons={
                <>
                  <Button
                    content="Shop"
                    icon="shopping-cart"
                    onClick={() => changeShopState(!shopState)}
                  />
                  <Button icon="cog" onClick={() => act('ChangeStyle')} />
                </>
              }
            >
              {!!name && (
                <>
                  Здраствуйте,
                  <br />
                  <b>{name}</b>
                  <br />
                </>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item basis={38}>
            {!shopState && (
              <Section
                fill
                scrollable
                title="Info"
                buttons={
                  <>
                    <Button
                      icon="id-card"
                      content="Eject ID"
                      disabled={!hasID}
                      onClick={() => act('RemoveID')}
                    />
                    {!hasTask && (
                      <Button
                        icon="arrow-down"
                        content="Get Task"
                        disabled={!hasID || cooldown}
                        onClick={() => act('GetTask')}
                      />
                    )}
                    {!!hasTask && (
                      <>
                        <Button
                          content="Print"
                          icon="print"
                          onClick={() => act('printOrder')}
                          disabled={!hasTask}
                        />
                        <Button
                          icon="trash"
                          content="Remove Task"
                          disabled={!hasID || cooldown}
                          onClick={() => act('RemoveTask')}
                        />
                      </>
                    )}
                  </>
                }
              >
                <Box mx="0.5rem" mb="1rem">
                  <b>Name: </b>
                  {questInfo.name}
                  <br />
                  <b>Desc: </b>
                  {questInfo.desc}
                </Box>
                <Section title="Modules" level={2}>
                  <Box mx="0.5rem" mb="0.5rem">
                    {!!hasTask &&
                      questInfo.modules.map((i) => (
                        <Fragment key={i.id}>
                          <b>Module {i.id}</b>: {i.name} <br />
                          <br />
                        </Fragment>
                      ))}
                  </Box>
                </Section>
                <Box mb="0.5rem" textAlign="center">
                  <Button
                    icon="arrow-up"
                    width="15rem"
                    bold
                    content="Send Mech"
                    textAlign="center"
                    disabled={!hasID || !hasTask || !canSend || cooldown}
                    onClick={() => act('SendMech', { type: 'send' })}
                  />
                  <Button
                    icon="arrow-up"
                    width="15rem"
                    bold
                    content="Pack"
                    textAlign="center"
                    disabled={!hasID || !hasTask || !canSend || cooldown}
                    onClick={() => act('SendMech', { type: 'only_packing' })}
                  />
                </Box>
              </Section>
            )}
            {!!shopState && (
              <Section
                fill
                title={
                  <>
                    RoboQuest Shop
                    <Box>Points: {points.robo}</Box>
                  </>
                }
              >
                <Box maxHeight={30} overflowY="auto" overflowX="hidden">
                  {shopItems.robo.map(
                    (i) =>
                      (!i.emagOnly || style === 'syndicate') && (
                        <Section
                          fill
                          key={i.name}
                          title={i.name}
                          buttons={
                            <Button
                              content={'Buy (' + i.cost.robo + 'P)'}
                              onClick={() =>
                                act('buyItem', {
                                  item: i.path,
                                })
                              }
                            />
                          }
                        >
                          <Box italic>{i.desc}</Box>
                        </Section>
                      )
                  )}
                </Box>
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
