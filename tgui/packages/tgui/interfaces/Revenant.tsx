import { useState } from 'react';
import { Box, Button, Section, Stack, Tabs } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type RevenantSpell = {
  index: number;
  name: string;
  desc: string;
  cost: number;
  cast_cost: string;
  can_buy: boolean;
  cooldown: number | null;
  stun: number;
  reveal: number;
  buyword: string;
  radius: number;
  u_radius: number
  u_cast: number;
  u_stun: number;
  u_reveal: number;
  u_cooldown: number;
};

type RevenantData = {
}

export const Revenant = (_props: unknown) => {
	  const { act, data } = useBackend<RevenantData>();
	  const {spells = [] } = data;
	  const visibleSpells = spells;
	  return (
		<Window title="Призрачный Гримуар" width={800} height={600} theme="revenant">
		  <Window.Content scrollable fitted>
			    <Section fill scrollable>
                  <Stack vertical>
                    {visibleSpells.map((spell) => (
                      <Stack.Item key={spell.index} mb={1}>
                        <Section
                          title={spell.name}
                          buttons={
                            <>

                              <Button
                                disabled={!spell.can_buy}
                                icon="magic"
                                onClick={() =>
                                  act('buy', { index: spell.index })
                                }
                              >
								{`${spell.buy_word}`}
                              </Button>
                            </>
                          }
                        >
                          <Stack vertical mt={1}>
							   <Stack.Item>
                              {spell.desc ? (
                                <Box italic>{spell.desc}</Box>
                              ) : (
                                <Box color="label" italic>
                                  No description.
                                </Box>
                              )}
                            </Stack.Item>
                            {spell.cooldown !== null && (
                              <Stack.Item>
                                <Box bold color="label">
                                  Время перезарядки: {spell.cooldown}s {spell.u_cooldown ? ` --> ${spell.u_cooldown/10}s` : null}
                                </Box>

                              </Stack.Item>
                            )}
							<Stack.Item>
                                <Box bold color="label">
                                  Радиус действия: {spell.radius} {spell.u_radius ? ` --> ${spell.u_radius}` : null}
                                </Box>
                              </Stack.Item>
							  <Stack.Item>
                                <Box bold color="label">
                                  Цена: {spell.cost}
                                </Box>

                              </Stack.Item>
							  <Stack.Item>
                                <Box bold color="label">
                                  Цена использования: {spell.cast_cost} {spell.u_cast ? ` --> ${spell.u_cast}` : null}
                                </Box>

                              </Stack.Item>
							   <Stack.Item>
                                <Box bold color="label">
                                  Время обездвиживания: {spell.stun/10}s {spell.u_stun ? ` --> ${spell.u_stun/10}s` : null}
                                </Box>

                              </Stack.Item>
							   <Stack.Item>
                                <Box bold color="label">
                                  Время раскрытия: {spell.reveal/10}s {spell.u_reveal ? ` --> ${spell.u_reveal/10}s` : null}
                                </Box>

                              </Stack.Item>

                          </Stack>
                        </Section>
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
			</Window.Content>
			</Window>
	  )
}
