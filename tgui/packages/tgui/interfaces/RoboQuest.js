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
  ImageButton,
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

  const cat_to_color = {
    'medical': 'blue',
    'working': 'brown',
    'security': 'red',
    'working_medical': 'olive',
    'medical_security': 'violet',
    'working_medical_security': 'grey',
  };

  return (
    <Window theme={style} width={1000} height={540}>
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
                {Object.keys(shopItems).map((cat) => (
                  <Fragment fill key={cat}>
                    {!(
                      shopItems[cat] === undefined ||
                      shopItems[cat].length === 0 ||
                      cat === 'robo'
                    ) &&
                      shopItems[cat].map((i) => (
                        <ImageButton
                          key={i.path}
                          asset
                          color={cat_to_color[cat]}
                          image={i.icon}
                          imageAsset="roboquest64x64"
                          title={
                            <Box nowrap inline>
                              {i.name}{' '}
                              <b style={{ color: 'brown' }}>{i.cost.working}</b>
                              |
                              <b style={{ color: 'lightblue' }}>
                                {i.cost.medical}
                              </b>
                              |<b style={{ color: 'red' }}>{i.cost.security}</b>
                            </Box>
                          }
                          content={i.desc}
                          onClick={() =>
                            act('buyItem', {
                              item: i.path,
                            })
                          }
                        />
                      ))}
                  </Fragment>
                ))}
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
                scrollable
                title={
                  <>
                    RoboQuest Shop
                    <Box>Points: {points.robo}</Box>
                  </>
                }
              >
                {shopItems.robo.map(
                  (i) =>
                    (!i.emagOnly || style === 'syndicate') && (
                      <ImageButton
                        key={i.name}
                        asset
                        color="purple"
                        image={i.icon}
                        imageAsset="roboquest64x64"
                        title={
                          <Box nowrap inline>
                            {i.name}{' '}
                            <b style={{ color: 'purple' }}>{i.cost.robo}</b>
                          </Box>
                        }
                        content={i.desc}
                        onClick={() =>
                          act('buyItem', {
                            item: i.path,
                          })
                        }
                      />
                    )
                )}
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
