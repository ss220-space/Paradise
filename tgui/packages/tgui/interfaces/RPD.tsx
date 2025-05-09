import { useBackend } from '../backend';
import { Tabs, Button, Box, Grid, Section, Stack, Icon } from '../components';
import { Window } from '../layouts';
import { classes } from 'common/react';

const decideTab = (index: number) => {
  switch (index) {
    case 1:
      return <AtmosPipeContent />;
    case 2:
      return <DisposalPipeContent />;
    case 3:
      return <RotatePipeContent />;
    case 4:
      return <FlipPipeContent />;
    case 5:
      return <BinPipeContent />;
    default:
      return "WE SHOULDN'T BE HERE!";
  }
};

type RPDData = {
  mainmenu: MenuItem[];
  mode: number;
  auto_wrench: boolean;
  pipemenu: PipeMenuItem[];
  pipe_category: string;
  pipelist: Pipe[];
  whatpipe: string;
  whatdpipe: string;
  iconrotation: number;
};

type MenuItem = {
  category: string;
  icon: string;
  mode: number;
};

type PipeMenuItem = {
  category: string;
  pipemode: string;
};

type Pipe = {
  pipe_name: string;
  pipe_category: string;
  pipe_type: number;
  pipe_id: string;
  orientations: number;
  bendy: boolean;
  pipe_icon: string;
};

export const RPD = (_props: unknown) => {
  const { act, data } = useBackend<RPDData>();
  const { mainmenu, mode, auto_wrench } = data;

  return (
    <Window width={550} height={415}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs fluid>
              {mainmenu.map((m) => (
                <Tabs.Tab
                  key={m.category}
                  icon={m.icon}
                  selected={m.mode === mode}
                  onClick={() => act('mode', { mode: m.mode })}
                >
                  {m.category}
                </Tabs.Tab>
              ))}
              <Button
                fluid
                icon="wrench"
                textAlign="center"
                iconPosition="right"
                px={1.5}
                pt={0.8}
                mt={-0.3}
                selected={auto_wrench}
                onClick={() =>
                  act('auto_wrench', { auto_wrench: !auto_wrench })
                }
              />
            </Tabs>
          </Stack.Item>
          {decideTab(mode)}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const AtmosPipeContent = (_props: unknown) => {
  const { act, data } = useBackend<RPDData>();
  const { pipemenu, pipe_category, pipelist, whatpipe, iconrotation } = data;

  return (
    <>
      <Stack.Item>
        <Tabs fluid>
          {pipemenu.map((p) => (
            <Tabs.Tab
              key={p.category}
              textAlign="center"
              selected={p.pipemode === pipe_category}
              onClick={() =>
                act('pipe_category', { pipe_category: p.pipemode })
              }
            >
              {p.category}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow basis="50%">
            <Section fill scrollable>
              <Grid>
                <Grid.Column>
                  {pipelist
                    .filter((p) => p.pipe_type === 1)
                    .filter((p) => p.pipe_category === pipe_category)
                    .map((p) => (
                      <Box key={p.pipe_name}>
                        <Button
                          fluid
                          color="translucent"
                          icon="cog"
                          selected={p.pipe_id === whatpipe}
                          onClick={() =>
                            act('whatpipe', { whatpipe: p.pipe_id })
                          }
                          style={{ marginBottom: '2px' }}
                        >
                          {p.pipe_name}
                        </Button>
                      </Box>
                    ))}
                </Grid.Column>
              </Grid>
            </Section>
          </Stack.Item>
          <Stack.Item grow basis="50%">
            <Section fill>
              <Grid>
                <Grid.Column>
                  {pipelist
                    .filter(
                      (p) =>
                        p.pipe_type === 1 &&
                        p.pipe_id === whatpipe &&
                        p.orientations !== 1
                    )
                    .map((p) => (
                      <Box key={p.pipe_id}>
                        <Box>
                          <Button
                            fluid
                            textAlign="center"
                            selected={iconrotation === 0}
                            onClick={() =>
                              act('iconrotation', { iconrotation: 0 })
                            }
                            style={{ marginBottom: '5px' }}
                          >
                            Orient automatically
                          </Button>
                        </Box>
                        {p.bendy ? (
                          <>
                            <Grid>
                              <Grid.Column>
                                <Button
                                  fluid
                                  textAlign="center"
                                  color="translucent"
                                  selected={iconrotation === 4}
                                  onClick={() =>
                                    act('iconrotation', { iconrotation: 4 })
                                  }
                                  style={{ marginBottom: '5px' }}
                                >
                                  {
                                    <Box
                                      className={classes([
                                        'rpd32x32',
                                        `southeast-${p.pipe_icon}`,
                                      ])}
                                    />
                                  }
                                </Button>
                              </Grid.Column>
                              <Grid.Column>
                                <Button
                                  fluid
                                  textAlign="center"
                                  color="translucent"
                                  selected={iconrotation === 2}
                                  onClick={() =>
                                    act('iconrotation', { iconrotation: 2 })
                                  }
                                  style={{ marginBottom: '5px' }}
                                >
                                  {
                                    <Box
                                      className={classes([
                                        'rpd32x32',
                                        `southwest-${p.pipe_icon}`,
                                      ])}
                                    />
                                  }
                                </Button>
                              </Grid.Column>
                            </Grid>
                            <Grid>
                              <Grid.Column>
                                <Button
                                  fluid
                                  textAlign="center"
                                  color="translucent"
                                  selected={iconrotation === 1}
                                  onClick={() =>
                                    act('iconrotation', { iconrotation: 1 })
                                  }
                                  style={{ marginBottom: '5px' }}
                                >
                                  {
                                    <Box
                                      className={classes([
                                        'rpd32x32',
                                        `northeast-${p.pipe_icon}`,
                                      ])}
                                    />
                                  }
                                </Button>
                              </Grid.Column>
                              <Grid.Column>
                                <Button
                                  fluid
                                  textAlign="center"
                                  color="translucent"
                                  selected={iconrotation === 8}
                                  onClick={() =>
                                    act('iconrotation', { iconrotation: 8 })
                                  }
                                  style={{ marginBottom: '5px' }}
                                >
                                  {
                                    <Box
                                      className={classes([
                                        'rpd32x32',
                                        `northwest-${p.pipe_icon}`,
                                      ])}
                                    />
                                  }
                                </Button>
                              </Grid.Column>
                            </Grid>
                          </>
                        ) : (
                          <>
                            <Grid>
                              <Grid.Column>
                                <Button
                                  fluid
                                  textAlign="center"
                                  color="translucent"
                                  selected={iconrotation === 1}
                                  onClick={() =>
                                    act('iconrotation', { iconrotation: 1 })
                                  }
                                  style={{ marginBottom: '5px' }}
                                >
                                  {
                                    <Box
                                      className={classes([
                                        'rpd32x32',
                                        `north-${p.pipe_icon}`,
                                      ])}
                                    />
                                  }
                                </Button>
                              </Grid.Column>
                              <Grid.Column>
                                <Button
                                  fluid
                                  textAlign="center"
                                  color="translucent"
                                  selected={iconrotation === 4}
                                  onClick={() =>
                                    act('iconrotation', { iconrotation: 4 })
                                  }
                                  style={{ marginBottom: '5px' }}
                                >
                                  {
                                    <Box
                                      className={classes([
                                        'rpd32x32',
                                        `east-${p.pipe_icon}`,
                                      ])}
                                    />
                                  }
                                </Button>
                              </Grid.Column>
                            </Grid>
                            {p.orientations === 4 && (
                              <Grid>
                                <Grid.Column>
                                  <Button
                                    fluid
                                    textAlign="center"
                                    color="translucent"
                                    selected={iconrotation === 2}
                                    onClick={() =>
                                      act('iconrotation', { iconrotation: 2 })
                                    }
                                    style={{ marginBottom: '5px' }}
                                  >
                                    {
                                      <Box
                                        className={classes([
                                          'rpd32x32',
                                          `south-${p.pipe_icon}`,
                                        ])}
                                      />
                                    }
                                  </Button>
                                </Grid.Column>
                                <Grid.Column>
                                  <Button
                                    fluid
                                    textAlign="center"
                                    color="translucent"
                                    selected={iconrotation === 8}
                                    onClick={() =>
                                      act('iconrotation', { iconrotation: 8 })
                                    }
                                    style={{ marginBottom: '5px' }}
                                  >
                                    {
                                      <Box
                                        className={classes([
                                          'rpd32x32',
                                          `west-${p.pipe_icon}`,
                                        ])}
                                      />
                                    }
                                  </Button>
                                </Grid.Column>
                              </Grid>
                            )}
                          </>
                        )}
                      </Box>
                    ))}
                </Grid.Column>
              </Grid>
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </>
  );
};

const DisposalPipeContent = (_props: unknown) => {
  const { act, data } = useBackend<RPDData>();
  const { pipelist, whatdpipe, iconrotation } = data;

  return (
    <Stack.Item grow>
      <Stack fill>
        <Stack.Item grow basis="50%">
          <Section fill>
            <Grid>
              <Grid.Column>
                {pipelist
                  .filter((p) => p.pipe_type === 2)
                  .map((p) => (
                    <Box key={p.pipe_name}>
                      <Button
                        fluid
                        color="translucent"
                        icon="cog"
                        selected={p.pipe_id === whatdpipe}
                        onClick={() =>
                          act('whatdpipe', { whatdpipe: p.pipe_id })
                        }
                        style={{ marginBottom: '2px' }}
                      >
                        {p.pipe_name}
                      </Button>
                    </Box>
                  ))}
              </Grid.Column>
            </Grid>
          </Section>
        </Stack.Item>
        <Stack.Item grow basis="50%">
          <Section fill>
            <Grid>
              <Grid.Column>
                {pipelist
                  .filter(
                    (p) =>
                      p.pipe_type === 2 &&
                      p.pipe_id === whatdpipe &&
                      p.orientations !== 1
                  )
                  .map((p) => (
                    <Stack.Item key={p.pipe_id}>
                      <Box>
                        <Button
                          fluid
                          textAlign="center"
                          selected={iconrotation === 0}
                          onClick={() =>
                            act('iconrotation', { iconrotation: 0 })
                          }
                          style={{ marginBottom: '5px' }}
                        >
                          Orient automatically
                        </Button>
                      </Box>
                      <Grid>
                        <Grid.Column>
                          <Button
                            fluid
                            color="translucent"
                            textAlign="center"
                            selected={iconrotation === 1}
                            onClick={() =>
                              act('iconrotation', { iconrotation: 1 })
                            }
                            style={{ marginBottom: '5px' }}
                          >
                            {
                              <Box
                                className={classes([
                                  'rpd32x32',
                                  `north-${p.pipe_icon}`,
                                ])}
                              />
                            }
                          </Button>
                        </Grid.Column>
                        <Grid.Column>
                          <Button
                            fluid
                            color="translucent"
                            textAlign="center"
                            selected={iconrotation === 4}
                            onClick={() =>
                              act('iconrotation', { iconrotation: 4 })
                            }
                            style={{ marginBottom: '5px' }}
                          >
                            {
                              <Box
                                className={classes([
                                  'rpd32x32',
                                  `east-${p.pipe_icon}`,
                                ])}
                              />
                            }
                          </Button>
                        </Grid.Column>
                      </Grid>
                      {p.orientations === 4 && (
                        <Grid>
                          <Grid.Column>
                            <Button
                              fluid
                              color="translucent"
                              textAlign="center"
                              selected={iconrotation === 2}
                              onClick={() =>
                                act('iconrotation', { iconrotation: 2 })
                              }
                              style={{ marginBottom: '5px' }}
                            >
                              {
                                <Box
                                  className={classes([
                                    'rpd32x32',
                                    `south-${p.pipe_icon}`,
                                  ])}
                                />
                              }
                            </Button>
                          </Grid.Column>
                          <Grid.Column>
                            <Button
                              fluid
                              color="translucent"
                              textAlign="center"
                              selected={iconrotation === 8}
                              onClick={() =>
                                act('iconrotation', { iconrotation: 8 })
                              }
                              style={{ marginBottom: '5px' }}
                            >
                              {
                                <Box
                                  className={classes([
                                    'rpd32x32',
                                    `west-${p.pipe_icon}`,
                                  ])}
                                />
                              }
                            </Button>
                          </Grid.Column>
                        </Grid>
                      )}
                    </Stack.Item>
                  ))}
              </Grid.Column>
            </Grid>
          </Section>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const RotatePipeContent = (_props: unknown) => {
  return (
    <Stack.Item grow>
      <Section fill>
        <Stack fill>
          <Stack.Item bold grow textAlign="center" align="center">
            <Icon name="sync-alt" size={5} color="gray" mb={5} />
            <br />
            Device ready to rotate loose pipes...
          </Stack.Item>
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const FlipPipeContent = (_props: unknown) => {
  return (
    <Stack.Item grow>
      <Section fill>
        <Stack fill>
          <Stack.Item bold grow textAlign="center" align="center">
            <Icon name="arrows-alt-h" size={5} color="gray" mb={5} />
            <br />
            Device ready to flip loose pipes...
          </Stack.Item>
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const BinPipeContent = (_props: unknown) => {
  return (
    <Stack.Item grow>
      <Section fill>
        <Stack fill>
          <Stack.Item bold grow textAlign="center" align="center">
            <Icon name="recycle" size={5} color="gray" mb={5} />
            <br />
            Device ready to eat loose pipes...
          </Stack.Item>
        </Stack>
      </Section>
    </Stack.Item>
  );
};
