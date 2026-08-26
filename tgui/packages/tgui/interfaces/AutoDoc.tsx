import { Fragment } from 'react';
import { useBackend } from '../backend';
import { useState } from 'react';
import { Box, Section, Button, Flex, Image } from '../components';
import { Window } from '../layouts';

type AutoDocData = {
  HasTray;
  TguiIcons;
  occupant;
  isHealing;
  fixtimer;
  healtimer;
};

export const AutoDoc = (props: unknown) => {
  const { act, data } = useBackend<AutoDocData>();
  const { HasTray, TguiIcons, occupant, isHealing, fixtimer, healtimer } = data;
  const [ChoosenPart, ChoosePart] = useState('chest');
  return (
    <Window theme="ntOS95">
      <Window.Content>
        <Flex width="100%">
          <Flex.Item basis="30%">
            <Image
              height="256px"
              width="256px"
              src={`data:image/jpeg;base64,${TguiIcons['human']}`}
              fixBlur
              style={{
                position: 'absolute',
              }}
            />
            <Image
              height="256px"
              width="256px"
              src={`data:image/jpeg;base64,${TguiIcons[ChoosenPart]}`}
              fixBlur
              style={{
                position: 'absolute',
              }}
            />
          </Flex.Item>
          <Flex.Item basis="70%">
            <Section
              title="Info"
              buttons={
                <>
                  {Object.keys(TguiIcons).map(
                    (part) =>
                      !(part === 'human') && (
                        <Button
                          key={part}
                          selected={part === ChoosenPart}
                          onClick={() => ChoosePart(part)}
                        >
                          {part}
                        </Button>
                      )
                  )}

                  <Button
                    style={{
                      marginLeft: '30px',
                    }}
                    disabled={isHealing}
                    onClick={() => act('ChangeTrayState')}
                  >
                    {HasTray ? 'Eject Tray' : 'Reject Tray'}
                  </Button>
                </>
              }
            >
              <Box>
                {!!(occupant[ChoosenPart] && occupant[ChoosenPart].extOrgan) &&
                  occupant[ChoosenPart].extOrgan.map((organ) => (
                    <Fragment key={organ.name}>
                      <b>{organ.name}</b>
                      <br />
                      {organ.open ? 'opened' : ''}
                      {organ.broken ? 'broken' : ''}
                      {!!organ.broken && (
                        <>
                          <Button
                            style={{
                              marginLeft: '30px',
                            }}
                            disabled={isHealing}
                            onClick={() =>
                              act('FixOrgan', {
                                organ: organ.name,
                                type: 'fracture',
                              })
                            }
                          >
                            Fix
                          </Button>
                          <br />
                        </>
                      )}
                      {organ.internalBleeding ? 'bleeding' : ''}
                      {!!organ.internalBleeding && (
                        <>
                          <Button
                            style={{
                              marginLeft: '30px',
                            }}
                            disabled={isHealing}
                            onClick={() =>
                              act('FixOrgan', {
                                organ: organ.name,
                                type: 'bleeding',
                              })
                            }
                          >
                            Fix
                          </Button>
                          <br />
                        </>
                      )}
                      Internals:
                      <Button
                        style={{
                          marginLeft: '10px',
                        }}
                        disabled={isHealing}
                        onClick={() =>
                          act('FixOrgan', {
                            organ: organ.name,
                            type: 'completeInternal',
                          })
                        }
                      >
                        Complete
                      </Button>
                      <br />
                      {organ.dead ? 'dead' : ''}
                      {!!organ.dead && <br />}
                      {organ.germ_level
                        ? 'Germ level is ' + organ.germ_level
                        : ''}
                      {!!organ.germ_level && <br />}
                      {organ.totalLoss
                        ? 'Total damage is ' + organ.totalLoss
                        : ''}
                      <br />
                    </Fragment>
                  ))}
                {!!(occupant[ChoosenPart] && occupant[ChoosenPart].intOrgan) &&
                  occupant[ChoosenPart].intOrgan.map((organ) => (
                    <Fragment key={organ.name}>
                      <b>{organ.name}</b>
                      <Button
                        style={{
                          marginLeft: '1.5rem',
                        }}
                        disabled={isHealing}
                        onClick={() =>
                          act('FixOrgan', { organ: organ.name, type: 'remove' })
                        }
                      >
                        Remove
                      </Button>
                      <br />
                      {organ.dead ? 'dead' : ''}
                      {!!organ.dead && <br />}
                      {organ.germ_level
                        ? 'Germ level is ' + organ.germ_level
                        : ''}
                      {!!organ.germ_level && <br />}
                      {organ.totalLoss ? 'Total damage is ' + organ.damage : ''}
                      {!!organ.totalLoss && (
                        <>
                          <Button
                            style={{
                              marginLeft: '30px',
                            }}
                            disabled={isHealing}
                            onClick={() =>
                              act('FixOrgan', {
                                organ: organ.name,
                                type: 'damage',
                              })
                            }
                          >
                            Heal
                          </Button>
                          <br />
                        </>
                      )}
                    </Fragment>
                  ))}
                {!!occupant.TotalBruteBurn && (
                  <>
                    Total external damage is {occupant.TotalBruteBurn}
                    <Button
                      style={{
                        marginLeft: '30px',
                      }}
                      onClick={() => act('HealBruteBurn')}
                    >
                      Start Healing
                    </Button>
                    <Button
                      style={{
                        marginLeft: '30px',
                      }}
                      onClick={() => act('CompleteExternal')}
                    >
                      Reattach externals
                    </Button>
                  </>
                )}
                <br />
                {!!fixtimer && <b>Fixing organ: {fixtimer}</b>}
                {!!healtimer && <b>Healing external damage: {healtimer}</b>}
              </Box>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
