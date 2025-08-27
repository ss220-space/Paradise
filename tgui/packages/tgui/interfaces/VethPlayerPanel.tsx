import { sortBy } from 'common/collections';
import { useBackend } from '../backend';
import { useState } from 'react';
import { Box, Button, Section, Table, TextArea, Grid } from '../components';
import { Window } from '../layouts';
import { createSearch } from 'common/string';

type VethPlayerPanelData = {
  Data: Player[];
};

type Player = {
  name: string;
  job: string;
  ckey: string;
  is_antagonist: boolean;
  last_ip: string;
};

export const VethPlayerPanel = (_props: unknown) => {
  const { act, data } = useBackend<VethPlayerPanelData>();

  const players = sortBy(data.Data || [], (player) => player.name);
  const [searchText, setSearchText] = useState('');
  const [selectedPlayerCkey, setSelectedPlayerCkey] = useState('');

  const searcher = createSearch<Player>(searchText, (player) => {
    return (
      player.name?.toLowerCase() +
      '|' +
      player.job?.toLowerCase() +
      '|' +
      player.ckey?.toLowerCase()
    );
  });

  const handleAction = (action: string, params?: Record<string, string>) => {
    // If params has a ckey, set it as the selected ckey
    if (params?.ckey) {
      setSelectedPlayerCkey(params.ckey); // Fixed: Use params.ckey instead of PlayerData.ckey
    }

    // Send the action to the backend with the selected ckey
    act(action, {
      ...params,
      selectedPlayerCkey: params?.ckey || selectedPlayerCkey,
    });
  };

  return (
    <Box>
      <Window title="Player Panel Veth" width={1100} height={640}>
        <Window.Content scrollable>
          <Section>
            <Button
              fluid
              icon="refresh"
              onClick={() => handleAction('refresh')}
            >
              Refresh
            </Button>
          </Section>
          <Section>
            <Grid>
              <Grid.Column>
                <Button fluid onClick={() => handleAction('gamePanel')}>
                  Game Panel
                </Button>
                <Button fluid onClick={() => handleAction('faxPanel')}>
                  Fax Panel
                </Button>
                <Button fluid onClick={() => handleAction('checkAntags')}>
                  Check Antags
                </Button>
              </Grid.Column>
              <Grid.Column>
                <Button
                  fluid
                  onClick={() => handleAction('createCommandReport')}
                >
                  Create Command Report
                </Button>
                <Button
                  fluid
                  content="Toggle Adv Admin Interact"
                  onClick={() => handleAction('adminaiinteract')}
                >
                  Toggle Adv Admin Interact
                </Button>
              </Grid.Column>
            </Grid>
          </Section>

          <Section title="Search Players">
            <TextArea
              autoFocus
              placeholder="Search by name, job, or ckey"
              value={searchText}
              onInput={(_, value) => setSearchText(value)}
              height="2rem"
            />
          </Section>

          <Section title={`Players`}>
            <Table>
              <Table.Row header>
                <Table.Cell>Ckey</Table.Cell>
                <Table.Cell>Char Name</Table.Cell>
                <Table.Cell>Job</Table.Cell>
                <Table.Cell>Antagonist</Table.Cell>
                <Table.Cell>Last IP</Table.Cell>
                <Table.Cell>Actions</Table.Cell>
              </Table.Row>
              {players.filter(searcher).map((player) => (
                <Table.Row key={player.ckey} className="candystripe">
                  <Table.Cell>{player.ckey}</Table.Cell>
                  <Table.Cell collapsing>{player.name}</Table.Cell>
                  <Table.Cell>{player.job}</Table.Cell>
                  <Table.Cell>
                    {player.is_antagonist ? (
                      <Box color="red">Yes</Box>
                    ) : (
                      <Box color="green">No</Box>
                    )}
                  </Table.Cell>
                  <Table.Cell>{player.last_ip}</Table.Cell>
                  <Table.Cell>
                    <Button
                      onClick={() =>
                        handleAction('sendPrivateMessage', {
                          ckey: player.ckey, // Use player.ckey instead of selectedPlayerCkey
                        })
                      }
                    >
                      PM
                    </Button>
                    <Button
                      onClick={() =>
                        handleAction('follow', {
                          ckey: player.ckey,
                        })
                      }
                    >
                      Follow
                    </Button>
                    <Button
                      onClick={() =>
                        handleAction('smite', {
                          ckey: player.ckey,
                        })
                      }
                      content="Smite"
                    />
                    <Button
                      onClick={() =>
                        handleAction('openAdditionalPanel', {
                          ckey: player.ckey,
                        })
                      }
                      icon="external-link"
                    >
                      PP
                    </Button>
                    <Button
                      icon="book"
                      onClick={() =>
                        act('logs', { selectedPlayerCkey: player.ckey })
                      }
                    >
                      Logs
                    </Button>
                    <Button
                      icon="clipboard"
                      onClick={() =>
                        act('notes', { selectedPlayerCkey: player.ckey })
                      }
                    >
                      Notes
                    </Button>
                    <Button
                      onClick={() =>
                        act('vv', { selectedPlayerCkey: player.ckey })
                      }
                    >
                      VV
                    </Button>
                    <Button
                      onClick={() =>
                        act('tp', { selectedPlayerCkey: player.ckey })
                      }
                    >
                      TP
                    </Button>
                    <Button
                      onClick={() =>
                        act('obs', {
                          selectedPlayerCkey: player.ckey,
                        })
                      }
                    >
                      OBS
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        </Window.Content>
      </Window>
    </Box>
  );
};
