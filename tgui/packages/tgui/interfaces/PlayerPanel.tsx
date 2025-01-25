import { useBackend } from '../backend';
import { Box, Button, Section, Table, Stack, Grid } from '../components';
import { Window } from '../layouts';

interface MuteStates {
  ic: boolean;
  ooc: boolean;
  pray: boolean;
  adminhelp: boolean;
  deadchat: boolean;
  emote: boolean;
  tts: boolean;
  all: boolean;
}

interface playerData {
  characterName: string;
  ckey: string;
  ipAddress: string;
  CID: string;
  discord: string;
  gameState: string;
  rank: string;
  byondVersion: string;
  mobType: string;
  relatedByCid: string;
  relatedByIp: string;
  firstSeen: string;
  accountRegistered: string;
  muteStates: MuteStates;
  adminRights: string;
}

const isMobType = (currentType: string, checkType: string): boolean => {
  const types = {
    ghost: ['ghost', 'dead', 'observer'],
    human: ['human', 'carbon'],
    monkey: ['monkey'],
    cyborg: ['cyborg', 'robot', 'borg'],
    ai: ['ai', 'artificial intelligence'],
    animal: ['simple', 'animal'],
  };
  return (
    types[checkType]?.some((type) =>
      currentType.toLowerCase().includes(type)
    ) || false
  );
};

export const PlayerPanel = (props, context) => {
  const { act, data } = useBackend<playerData>(context);

  const isButtonAllowed = (checkRight: string): boolean => {
    return data.adminRights.toLowerCase().includes(checkRight) || false;
  };

  const handleAction = (action: string, params = {}) => {
    act(action, { selectedPlayerCkey: data.ckey, ...params });
  };

  const toggleMute = (type: string) => {
    if (!data.ckey) {
      return;
    }
    handleAction('toggleMute', { type });
  };

  // Add error display if critical data is missing
  if (!data.ckey) {
    return (
      <Window title="Options Panel - Error" width={800} height={1050}>
        <Window.Content>
          <Section title="Error">
            <Box color="red">
              No valid player data found. Please refresh or select a valid
              player.
            </Box>
            <Button
              icon="sync"
              content="Refresh"
              onClick={() => act('refresh')}
            />
          </Section>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window title={`Options Panel - ${data.ckey}`} width={800} height={850}>
      <Window.Content>
        <Stack vertical>
          <Stack.Item>
            <Button
              icon="sync"
              content="Refresh"
              onClick={() => handleAction('refresh')}
            />
          </Stack.Item>

          <Stack.Item>
            <Section title="Player Information">
              <Table>
                <Table.Row>
                  <Table.Cell bold>Character:</Table.Cell>
                  <Table.Cell>{data.characterName}</Table.Cell>
                  <Table.Cell bold>Ckey:</Table.Cell>
                  <Table.Cell>{data.ckey}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>IP Address:</Table.Cell>
                  <Table.Cell>{data.ipAddress}</Table.Cell>
                  <Table.Cell bold>Discord:</Table.Cell>
                  <Table.Cell>{data.discord}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Rank:</Table.Cell>
                  <Table.Cell>{data.rank}</Table.Cell>
                  <Table.Cell bold>Byond Version:</Table.Cell>
                  <Table.Cell>{data.byondVersion}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Mob Type:</Table.Cell>
                  <Table.Cell>{data.mobType}</Table.Cell>
                  <Table.Cell bold>CID:</Table.Cell>
                  <Table.Cell>{data.CID}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Game State:</Table.Cell>
                  <Table.Cell>{data.gameState}</Table.Cell>
                  <Table.Cell bold>Account Registered:</Table.Cell>
                  <Table.Cell>{data.accountRegistered}</Table.Cell>
                </Table.Row>
                <Table.Row>
                  <Table.Cell bold>Related By CID:</Table.Cell>
                  <Button
                    content="Related by CID"
                    color="blue"
                    onClick={() => handleAction('relatedbycid')}
                  />
                  <Table.Cell bold>Related By IP:</Table.Cell>
                  <Button
                    content="Related by IP"
                    color="blue"
                    onClick={() => handleAction('relatedbyip')}
                  />
                </Table.Row>
              </Table>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Grid>
              <Grid.Column>
                <Section title="Punish">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="times"
                        content="KICK"
                        color="red"
                        onClick={() => handleAction('kick')}
                      />
                      {isButtonAllowed('event') ? (
                        <Button
                          fluid
                          icon="bolt"
                          content="SMITE"
                          color="red"
                          hidden={!isButtonAllowed('event')}
                          onClick={() => handleAction('smite')}
                        />
                      ) : null}
                      {isButtonAllowed('event') ? (
                        <Button
                          fluid
                          icon="hand-holding-heart"
                          content="BLESS"
                          onClick={() => handleAction('bless')}
                        />
                      ) : null}
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="ban"
                        content="BAN"
                        color="red"
                        disabled={!isButtonAllowed('ban')}
                        onClick={() => handleAction('ban')}
                      />
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          icon="bullseye"
                          content="ADD TO WATCHLIST"
                          color="red"
                          onClick={() => handleAction('watchlist')}
                        />
                      ) : null}
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>

              <Grid.Column>
                <Section title="Message">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="comment"
                        content="PM"
                        onClick={() => handleAction('pm')}
                      />
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          icon="comment-alt"
                          content="NARRATE"
                          onClick={() => handleAction('narrate')}
                        />
                      ) : null}
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          icon="user-secret"
                          content="SEND ALERT"
                          onClick={() => handleAction('sendalert')}
                        />
                      ) : null}
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="user-secret"
                        content="SM"
                        disabled={!isButtonAllowed('event')}
                        onClick={() => handleAction('sm')}
                      />
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          icon="crown"
                          content="MAN UP"
                          onClick={() => handleAction('manup')}
                        />
                      ) : null}
                      {isButtonAllowed('sound') ? (
                        <Button
                          fluid
                          icon="music"
                          content="PLAY SOUND TO"
                          onClick={() => handleAction('playsoundto')}
                        />
                      ) : null}
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
            </Grid>

            <Grid>
              <Grid.Column>
                <Section title="Movement">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="eye"
                        content="FLW"
                        onClick={() => handleAction('flw')}
                      />
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          icon="download"
                          content="GET"
                          onClick={() => handleAction('get')}
                        />
                      ) : null}
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          icon="paper-plane"
                          content="SEND"
                          onClick={() => handleAction('send')}
                        />
                      ) : null}
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="running"
                        content="JUMPTO"
                        onClick={() => handleAction('jumpto')}
                      />
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          icon="sign-out-alt"
                          content="LOBBY"
                          onClick={() => handleAction('lobby')}
                        />
                      ) : null}
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          icon="columns"
                          content="SEND TO CRYO"
                          onClick={() => handleAction('cryo')}
                        />
                      ) : null}
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>

              <Grid.Column>
                <Section title="Info">
                  <Grid>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="book"
                        content="LOGS"
                        onClick={() => handleAction('logs')}
                      />
                      <Button
                        fluid
                        icon="clipboard"
                        content="NOTES"
                        onClick={() => handleAction('notes')}
                      />
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          icon="eye"
                          content="PLAYTIME"
                          onClick={() => handleAction('playtime')}
                        />
                      ) : null}
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          icon="globe"
                          content="GEOIP"
                          onClick={() => handleAction('geoip')}
                        />
                      ) : null}
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button
                        fluid
                        icon="user-secret"
                        content="TRAITOR PANEL"
                        onClick={() => handleAction('tp')}
                      />
                      <Button
                        fluid
                        icon="code"
                        content="VV"
                        onClick={() => handleAction('vv')}
                      />
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          icon="database"
                          content="CHECK CCDB"
                          onClick={() => handleAction('ccdb')}
                        />
                      ) : null}
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
            </Grid>

            <Grid>
              <Grid.Column>
                {isButtonAllowed('spawn') ? (
                  <Section title="Transformation">
                    <Grid>
                      <Grid.Column size={6}>
                        <Button
                          fluid
                          icon="ghost"
                          content="MAKE GHOST"
                          color={isMobType(data.mobType, 'ghost') ? 'good' : ''}
                          onClick={() => handleAction('makeghost')}
                        />
                        <Button
                          fluid
                          icon="user"
                          content="MAKE HUMAN"
                          color={isMobType(data.mobType, 'human') ? 'good' : ''}
                          onClick={() => handleAction('makehuman')}
                        />
                        <Button
                          fluid
                          icon="paw"
                          content="MAKE MONKEY"
                          color={
                            isMobType(data.mobType, 'monkey') ? 'good' : ''
                          }
                          onClick={() => handleAction('makemonkey')}
                        />
                      </Grid.Column>
                      <Grid.Column size={6}>
                        <Button
                          fluid
                          icon="robot"
                          content="MAKE CYBORG"
                          color={
                            isMobType(data.mobType, 'cyborg') ? 'good' : ''
                          }
                          onClick={() => handleAction('makeborg')}
                        />
                        <Button
                          fluid
                          icon="microchip"
                          content="MAKE AI"
                          color={isMobType(data.mobType, 'ai') ? 'good' : ''}
                          onClick={() => handleAction('makeai')}
                        />
                        <Button
                          fluid
                          icon="microchip"
                          content="ANIMALIZE"
                          color={
                            isMobType(data.mobType, 'animal') ? 'good' : ''
                          }
                          onClick={() => handleAction('makeanimal')}
                        />
                      </Grid.Column>
                    </Grid>
                  </Section>
                ) : null}
                {isMobType(data.mobType, 'ghost') ? (
                  <Section title="Observer">
                    <Grid>
                      <Grid.Column size={2}>
                        <Button
                          fluid
                          content="TOGGLE RESPAWNABILITY"
                          onClick={() => handleAction('respawnability')}
                        />
                      </Grid.Column>
                      <Grid.Column size={2}>
                        <Button
                          fluid
                          icon="staff-snake"
                          content="RE-INCARNATE"
                          disabled={!isButtonAllowed('spawn')}
                          onClick={() => handleAction('reviveghost')}
                        />
                      </Grid.Column>
                    </Grid>
                  </Section>
                ) : (
                  <Section title="Health">
                    <Grid>
                      <Grid.Column size={6}>
                        <Button
                          fluid
                          icon="heart"
                          content="HEALTHSCAN"
                          onClick={() => handleAction('healthscan')}
                        />
                        {isButtonAllowed('admin') ? (
                          <Button
                            fluid
                            content="GIVE DISEASE"
                            onClick={() => handleAction('giveDisease')}
                          />
                        ) : null}

                        {isButtonAllowed('admin') ? (
                          <Button
                            fluid
                            content="CURE DISEASE"
                            onClick={() => handleAction('cureDisease')}
                          />
                        ) : null}
                        {isButtonAllowed('admin') ? (
                          <Button
                            fluid
                            content="CURE ALL BAD DISEASES"
                            onClick={() => handleAction('cureAllDiseases')}
                          />
                        ) : null}
                      </Grid.Column>
                      <Grid.Column size={6}>
                        <Button
                          fluid
                          content="CHEMSCAN"
                          onClick={() => handleAction('chemscan')}
                        />
                        <Button
                          fluid
                          icon="plus"
                          content="REJUVINATE"
                          disabled={!isButtonAllowed('rejuvinate')}
                          onClick={() => handleAction('aheal')}
                        />
                        {isButtonAllowed('admin') ? (
                          <Button
                            fluid
                            icon="dna"
                            content="SHOW DNA"
                            onClick={() => handleAction('mutate')}
                          />
                        ) : null}
                      </Grid.Column>
                    </Grid>
                  </Section>
                )}
              </Grid.Column>
              <Grid.Column>
                {isButtonAllowed('admin') ? (
                  <Section title="Mob Manipulation">
                    <Grid>
                      <Grid.Column size={6}>
                        <Button
                          fluid
                          icon="pencil"
                          content="MOB RANDOMIZE NAME"
                          onClick={() => handleAction('randomizename')}
                        />
                        <Button
                          fluid
                          icon="shirt"
                          content="SELECT EQUIPMENT"
                          onClick={() => handleAction('selectequip')}
                        />
                        <Button
                          fluid
                          icon="microphone"
                          content="CHANGE VOICE"
                          onClick={() => handleAction('changevoice')}
                        />
                        <Button
                          fluid
                          icon="circle-user"
                          content="MIRROR UI TO ADMIN"
                          onClick={() => handleAction('mirroradmin')}
                        />
                      </Grid.Column>
                      <Grid.Column size={6}>
                        <Button
                          fluid
                          icon="pen"
                          content="CHARACTER RANDOMIZE NAME"
                          onClick={() => handleAction('userandomname')}
                        />
                        <Button
                          fluid
                          icon="eraser"
                          content="ERASE FLAVOR"
                          onClick={() => handleAction('eraseflavortext')}
                        />
                        <Button
                          fluid
                          icon="shirt"
                          content="CHECK CONTENTS"
                          onClick={() => handleAction('checkcontents')}
                        />
                        <Button
                          fluid
                          icon="circle-user"
                          content="MIRROR UI TO PLAYER"
                          onClick={() => handleAction('mirrorplayer')}
                        />
                      </Grid.Column>
                    </Grid>
                  </Section>
                ) : null}
                <Section title="Misc">
                  <Grid>
                    <Grid.Column size={6}>
                      {isButtonAllowed('event') ? (
                        <Button
                          fluid
                          icon="gavel"
                          content="THUNDERDOME 1"
                          onClick={() => handleAction('thunderdome1')}
                        />
                      ) : null}
                      {isButtonAllowed('event') ? (
                        <Button
                          fluid
                          icon="gavel"
                          content="THUNDERDOME 2"
                          onClick={() => handleAction('thunderdome2')}
                        />
                      ) : null}
                      <Button
                        fluid
                        icon="comment"
                        content="FORCESAY"
                        onClick={() => handleAction('forcesay')}
                      />
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          icon="handcuffs"
                          content="PRISON"
                          onClick={() => handleAction('prison')}
                        />
                      ) : null}
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          content="SYNDI JAIL RELEASE"
                          onClick={() => handleAction('contractor_release')}
                        />
                      ) : null}
                      {/* <Button
                        fluid
                        icon="language"
                        content="LANGUAGE"
                        onClick={() => handleAction('language')}
                      /> */}
                    </Grid.Column>
                    <Grid.Column size={6}>
                      {isButtonAllowed('event') ? (
                        <Button
                          fluid
                          icon="gavel"
                          content="THUNDERDOME ADMIN"
                          onClick={() => handleAction('thunderdomeadmin')}
                        />
                      ) : null}
                      {isButtonAllowed('event') ? (
                        <Button
                          fluid
                          icon="eye"
                          content="THUNDERDOME OBSERVER"
                          onClick={() => handleAction('thunderdomeobserver')}
                        />
                      ) : null}
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          icon="wheelchair-move"
                          content="AROOM WRAP"
                          onClick={() => handleAction('adminroom')}
                        />
                      ) : null}
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          content="SYNDI JAIL START"
                          onClick={() => handleAction('contractor_start')}
                        />
                      ) : null}
                      {isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          content="SYNDI JAIL STOP"
                          onClick={() => handleAction('contractor_stop')}
                        />
                      ) : null}
                      {isButtonAllowed('event') || isButtonAllowed('admin') ? (
                        <Button
                          fluid
                          icon="cookie"
                          content="SPAWN COOKIE"
                          onClick={() => handleAction('spawncookie')}
                        />
                      ) : null}
                      <Button fluid content="Some Admin Button" />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
            </Grid>

            <Grid>
              <Grid.Column>
                <Section title="Mute Controls">
                  <Grid>
                    <Grid.Column size={7}>
                      <Button.Checkbox
                        fluid
                        checked={data.muteStates.ic}
                        onClick={() => toggleMute('ic')}
                        content="IC"
                        color={!data.muteStates.ic ? 'green' : 'red'}
                      />
                      <Button.Checkbox
                        fluid
                        checked={data.muteStates.ooc}
                        onClick={() => toggleMute('ooc')}
                        content="OOC"
                        color={!data.muteStates.ooc ? 'green' : 'red'}
                      />
                      <Button.Checkbox
                        fluid
                        checked={data.muteStates.pray}
                        onClick={() => toggleMute('pray')}
                        content="PRAY"
                        color={!data.muteStates.pray ? 'green' : 'red'}
                      />
                      <Button.Checkbox
                        fluid
                        checked={data.muteStates.emote}
                        onClick={() => toggleMute('emote')}
                        content="EMOTE"
                        color={!data.muteStates.emote ? 'green' : 'red'}
                      />
                    </Grid.Column>
                    <Grid.Column size={6}>
                      <Button.Checkbox
                        fluid
                        checked={data.muteStates.adminhelp}
                        onClick={() => toggleMute('adminhelp')}
                        content="ADMINHELP"
                        color={!data.muteStates.adminhelp ? 'green' : 'red'}
                      />
                      <Button.Checkbox
                        fluid
                        checked={data.muteStates.deadchat}
                        onClick={() => toggleMute('deadchat')}
                        content="DEADCHAT"
                        color={!data.muteStates.deadchat ? 'green' : 'red'}
                      />
                      <Button.Checkbox
                        fluid
                        checked={data.muteStates.all}
                        onClick={() => toggleMute('all')}
                        content="ALL"
                        color={!data.muteStates.all ? 'green' : 'red'}
                      />
                    </Grid.Column>
                  </Grid>
                </Section>
              </Grid.Column>
            </Grid>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
