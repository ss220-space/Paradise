import { useState } from 'react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, Button, Section, Stack, Tabs } from '../components';

type Spell = {
  index: number;
  name: string;
  desc: string;
  cost: number;
  category: string;
  refundable: number;
  buy_word: string;
  can_buy: boolean;
  can_refund: boolean;
  cooldown: number | null;
  clothes_req: boolean | null;
};

type SpellbookData = {
  points: number;
  entries: Spell[];
};

export const Spellbook = (props) => {
  const { act, data } = useBackend<SpellbookData>();
  const { points, entries = [] } = data;
  const [mainTab, setMainTab] = useState('Spells');
  const [subTab, setSubTab] = useState('Offensive');
  const visibleSpells = entries.filter((s) => s.category === subTab);

  return (
    <Window title="Spellbook" width={800} height={600} theme="admin">
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={mainTab === 'Spells'}
                onClick={() => {
                  setMainTab('Spells');
                  setSubTab('Offensive');
                }}
              >
                Spells
              </Tabs.Tab>
              <Tabs.Tab
                selected={mainTab === 'Items'}
                onClick={() => {
                  setMainTab('Items');
                  setSubTab('Artefacts');
                }}
              >
                Magical Items
              </Tabs.Tab>
              <Tabs.Tab
                selected={mainTab === 'Loadouts'}
                onClick={() => {
                  setMainTab('Loadouts');
                  setSubTab('Standard');
                }}
              >
                Loadouts
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>

          <Stack.Item grow>
            <Stack fill>
              <Stack.Item width="30%">
                <Section fill title={`Points: ${points}`}>
                  <Tabs vertical>
                    {mainTab === 'Spells' && (
                      <>
                        <Tabs.Tab
                          selected={subTab === 'Offensive'}
                          onClick={() => setSubTab('Offensive')}
                        >
                          Offensive
                        </Tabs.Tab>
                        <Tabs.Tab
                          selected={subTab === 'Defensive'}
                          onClick={() => setSubTab('Defensive')}
                        >
                          Defensive
                        </Tabs.Tab>
                        <Tabs.Tab
                          selected={subTab === 'Mobility'}
                          onClick={() => setSubTab('Mobility')}
                        >
                          Mobility
                        </Tabs.Tab>
                        <Tabs.Tab
                          selected={subTab === 'Assistance'}
                          onClick={() => setSubTab('Assistance')}
                        >
                          Assistance
                        </Tabs.Tab>
                        <Tabs.Tab
                          selected={subTab === 'Rituals'}
                          onClick={() => setSubTab('Rituals')}
                        >
                          Rituals
                        </Tabs.Tab>
                      </>
                    )}
                    {mainTab === 'Items' && (
                      <>
                        <Tabs.Tab
                          selected={subTab === 'Artefacts'}
                          onClick={() => setSubTab('Artefacts')}
                        >
                          Artefacts
                        </Tabs.Tab>
                        <Tabs.Tab
                          selected={subTab === 'Spell books'}
                          onClick={() => setSubTab('Spell books')}
                        >
                          Spell books
                        </Tabs.Tab>
                        <Tabs.Tab
                          selected={subTab === 'Weapons and Armors'}
                          onClick={() => setSubTab('Weapons and Armors')}
                        >
                          Weapons and Armors
                        </Tabs.Tab>
                        <Tabs.Tab
                          selected={subTab === 'Staves'}
                          onClick={() => setSubTab('Staves')}
                        >
                          Staves
                        </Tabs.Tab>
                        <Tabs.Tab
                          selected={subTab === 'Summons'}
                          onClick={() => setSubTab('Summons')}
                        >
                          Summons
                        </Tabs.Tab>
                      </>
                    )}
                    {mainTab === 'Loadouts' && (
                      <>
                        <Tabs.Tab
                          selected={subTab === 'Standard'}
                          onClick={() => setSubTab('Standard')}
                        >
                          Standard
                        </Tabs.Tab>
                        <Tabs.Tab
                          selected={subTab === 'Unique'}
                          onClick={() => setSubTab('Unique')}
                        >
                          Unique
                        </Tabs.Tab>
                      </>
                    )}
                  </Tabs>
                </Section>
              </Stack.Item>

              <Stack.Item grow>
                <Section fill scrollable>
                  <Stack vertical>
                    {visibleSpells.map((spell) => (
                      <Stack.Item key={spell.index} mb={1}>
                        <Section
                          title={spell.name}
                          buttons={
                            <>
                              {!!spell.can_refund && (
                                <Button
                                  color="bad"
                                  icon="undo"
                                  onClick={() =>
                                    act('refund', { index: spell.index })
                                  }
                                >
                                  Refund
                                </Button>
                              )}

                              <Button
                                disabled={!spell.can_buy}
                                icon="magic"
                                onClick={() =>
                                  act('buy', { index: spell.index })
                                }
                              >
                                {`${spell.buy_word} (${spell.cost < 0 ? `+${Math.abs(spell.cost)}` : spell.cost})`}
                              </Button>
                            </>
                          }
                        >
                          <Stack vertical mt={1}>
                            {spell.cooldown !== null && (
                              <Stack.Item>
                                <Box bold color="label">
                                  Cooldown: {spell.cooldown}s
                                </Box>
                              </Stack.Item>
                            )}
                            {spell.clothes_req !== null && (
                              <Stack.Item>
                                <Box
                                  bold
                                  color={spell.clothes_req ? 'bad' : 'good'}
                                >
                                  {spell.clothes_req
                                    ? 'Needs wizard garb'
                                    : 'Can be cast without wizard garb'}
                                </Box>
                              </Stack.Item>
                            )}
                            <Stack.Item>
                              {spell.desc ? (
                                <Box italic>{spell.desc}</Box>
                              ) : (
                                <Box color="label" italic>
                                  No description.
                                </Box>
                              )}
                            </Stack.Item>
                          </Stack>
                        </Section>
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
