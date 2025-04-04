import { sortBy } from 'common/collections';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Table, TextArea, Grid } from '../components';
import { Window } from '../layouts';
import { createSearch } from 'common/string';

export const VethPlayerPanel = (props, context) => {
  const { act, data } = useBackend(context);

  const players = sortBy((player) => player.name)(data.Data || []);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [selectedPlayerCkey, setSelectedPlayerCkey] = useLocalState(
    context,
    'selectedPlayerCkey',
    ''
  );

  const searcher = createSearch(searchText, (player) => {
    return (
      player.name?.toLowerCase() +
      '|' +
      player.job?.toLowerCase() +
      '|' +
      player.ckey?.toLowerCase()
    );
  });

  const handleAction = (action, params) => {
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
        <Window.Content>
          <Section>
            <Button
              fluid
              icon="refresh"
              content="Refresh"
              onClick={() => handleAction('refresh')}
            />
          </Section>
          <Section>
            <Grid>
              <Grid.Column>
                <Button
                  fluid
                  content="Game Panel"
                  onClick={() => handleAction('gamePanel')}
                />
                <Button
                  fluid
                  content="Fax Panel"
                  onClick={() => handleAction('faxPanel')}
                />
                <Button
                  fluid
                  content="Check Antags"
                  onClick={() => handleAction('checkAntags')}
                />
              </Grid.Column>
              <Grid.Column>
                <Button
                  fluid
                  content="Create Command Report"
                  onClick={() => handleAction('createCommandReport')}
                />
                <Button
                  fluid
                  content="Toggle Adv Admin Interact"
                  onClick={() => handleAction('adminaiinteract')}
                />
              </Grid.Column>
            </Grid>
          </Section>

          <Section title="Search Players">
            <TextArea
              autoFocus
              placeholder="Search by name, job, or ckey"
              value={searchText}
              onInput={(_, value) => setSearchText(value)}
              rows={1}
              height="2rem"
            />
          </Section>

          <Section title={`Players`} scrollable>
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
                      content="PM"
                    />
                    <Button
                      onClick={() =>
                        handleAction('follow', {
                          ckey: player.ckey,
                        })
                      }
                      content="Follow"
                    />
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
                      content="PP"
                      icon="external-link"
                    />
                    <Button
                      icon="book"
                      content="Logs"
                      onClick={() =>
                        act('logs', { selectedPlayerCkey: player.ckey })
                      }
                    />
                    <Button
                      icon="clipboard"
                      content="Notes"
                      onClick={() =>
                        act('notes', { selectedPlayerCkey: player.ckey })
                      }
                    />
                    <Button
                      content="VV"
                      onClick={() =>
                        act('vv', { selectedPlayerCkey: player.ckey })
                      }
                    />
                    <Button
                      content="TP"
                      onClick={() =>
                        act('tp', { selectedPlayerCkey: player.ckey })
                      }
                    />
                    <Button
                      content="OBS"
                      onClick={() =>
                        act('obs', {
                          selectedPlayerCkey: player.ckey,
                        })
                      }
                    />
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
