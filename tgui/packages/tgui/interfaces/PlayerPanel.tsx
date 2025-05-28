import { useBackend } from '../backend';
import { useState } from 'react';
import { Button, Section, Table, Stack, Grid } from '../components';
import { Window } from '../layouts';
import { ButtonProps } from '../components/Button';

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

interface PlayerData {
  characterName: string;
  ckey: string;
  ipAddress: string;
  CID: string;
  discord: string;
  playtime: string;
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
    types[checkType]?.some((type: string) =>
      currentType.toLowerCase().includes(type)
    ) || false
  );
};

export const PlayerPanel = (_props: unknown) => {
  const { act, data } = useBackend<PlayerData>();

  const handleAction = (action: string, params = {}) => {
    act(action, { selectedPlayerCkey: data.ckey, ...params });
  };

  return (
    <Window title={`Options Panel - ${data.ckey}`} width={800} height={950}>
      <Window.Content scrollable>
        <Stack vertical>
          <Stack.Item>
            <Button icon="sync" onClick={() => handleAction('refresh')}>
              Refresh
            </Button>
            <Button icon="sync" onClick={() => handleAction('old_pp')}>
              Old Panel
            </Button>
          </Stack.Item>

          <PlayerInformation />

          <PlayerOptionsMenu />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PlayerInformation = (_props: unknown) => {
  const { act, data } = useBackend<PlayerData>();
  const [hideIP, setIP] = useState(false);
  const [hideCID, setCID] = useState(false);

  const handleAction = (action: string, params = {}) => {
    act(action, { selectedPlayerCkey: data.ckey, ...params });
  };

  return (
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
            <Table.Cell bold>Rank:</Table.Cell>
            <Table.Cell>{data.rank}</Table.Cell>
            <Table.Cell bold>Discord:</Table.Cell>
            <Table.Cell>{data.discord}</Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell bold>Account Registered:</Table.Cell>
            <Table.Cell>{data.accountRegistered}</Table.Cell>
            <Table.Cell bold>Playtime as Crew:</Table.Cell>
            <Table.Cell p="1px">
              <Button onClick={() => handleAction('playtime')}>
                {data.playtime}
              </Button>
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell bold>CID:</Table.Cell>
            <Table.Cell p="1px">
              <Button onClick={() => setCID(!hideCID)}>
                {!hideCID ? 'Hidden' : data.CID}
              </Button>
            </Table.Cell>
            <Table.Cell bold>IP Address:</Table.Cell>
            <Table.Cell p="1px">
              <Button onClick={() => setIP(!hideIP)}>
                {!hideIP ? 'Hidden' : data.ipAddress}
              </Button>
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell bold>Mob Type:</Table.Cell>
            <Table.Cell>{data.mobType}</Table.Cell>
            <Table.Cell bold>Byond Version:</Table.Cell>
            <Table.Cell>{data.byondVersion}</Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell bold>Related By CID:</Table.Cell>
            <Button color="blue" onClick={() => handleAction('relatedbycid')}>
              Related by CID
            </Button>
            <Table.Cell bold>Related By IP:</Table.Cell>
            <Button color="blue" onClick={() => handleAction('relatedbyip')}>
              Related by IP
            </Button>
          </Table.Row>
        </Table>
      </Section>
    </Stack.Item>
  );
};

const PlayerOptionsMenu = (_props: unknown) => {
  return (
    <Stack.Item>
      <Grid>
        <Grid.Column>
          <PunishSection />
        </Grid.Column>
        <Grid.Column>
          <MessageSection />
        </Grid.Column>
      </Grid>

      <Grid>
        <Grid.Column>
          <MovementSection />
        </Grid.Column>
        <Grid.Column>
          <InfoSection />
        </Grid.Column>
      </Grid>

      <Grid>
        <Grid.Column>
          <TransformationSection />
          <HealthObserverSection />
        </Grid.Column>
        <Grid.Column>
          <MobManipulationSection />
          <MiscSection />
        </Grid.Column>
      </Grid>

      <Grid>
        <Grid.Column>
          <MuteSection />
        </Grid.Column>
      </Grid>
    </Stack.Item>
  );
};

const PunishSection = (_props: unknown) => {
  const { act, data } = useBackend<PlayerData>();

  const handleAction = (action: string, params = {}) => {
    act(action, { selectedPlayerCkey: data.ckey, ...params });
  };

  const isButtonAllowed = (checkRight: string): boolean => {
    return data.adminRights.toLowerCase().includes(checkRight) || false;
  };

  const hasCkey = (): boolean => {
    return data.ckey !== 'NO CKEY' ? true : false;
  };

  return (
    <Section title="Punish">
      <Grid>
        <Grid.Column size={6}>
          <Button
            fluid
            icon="times"
            color="red"
            tooltip={hasCkey ? null : 'NO CKEY'}
            disabled={!hasCkey()}
            onClick={() => handleAction('kick')}
          >
            KICK
          </Button>
          <Button
            fluid
            icon="ban"
            color="red"
            tooltip={hasCkey ? null : 'NO CKEY'}
            disabled={!isButtonAllowed('ban') || !hasCkey()}
            onClick={() => handleAction('jobban')}
          >
            JOBBAN
          </Button>
          {isButtonAllowed('admin') ? (
            <Button
              fluid
              icon="bullseye"
              color="red"
              tooltip={hasCkey ? null : 'NO CKEY'}
              disabled={!hasCkey()}
              onClick={() => handleAction('watchlist')}
            >
              ADD TO WATCHLIST
            </Button>
          ) : null}
        </Grid.Column>
        <Grid.Column size={6}>
          <Button
            fluid
            icon="ban"
            color="red"
            tooltip={hasCkey ? null : 'NO CKEY'}
            disabled={!isButtonAllowed('ban') || !hasCkey()}
            onClick={() => handleAction('ban')}
          >
            BAN
          </Button>
          <Button
            fluid
            icon="ban"
            color="red"
            tooltip={hasCkey ? null : 'NO CKEY'}
            disabled={!isButtonAllowed('ban') || !hasCkey()}
            onClick={() => handleAction('appban')}
          >
            APPEARANCE BAN
          </Button>
          {isButtonAllowed('event') ? (
            <Button
              fluid
              icon="bolt"
              color="red"
              onClick={() => handleAction('smite')}
            >
              SMITE
            </Button>
          ) : null}
          {isButtonAllowed('event') ? (
            <Button
              fluid
              icon="hand-holding-heart"
              onClick={() => handleAction('bless')}
            >
              BLESS
            </Button>
          ) : null}
        </Grid.Column>
      </Grid>
    </Section>
  );
};

const MessageSection = (_props: unknown) => {
  const { act, data } = useBackend<PlayerData>();

  const handleAction = (action: string, params = {}) => {
    act(action, { selectedPlayerCkey: data.ckey, ...params });
  };

  const isButtonAllowed = (checkRight: string): boolean => {
    return data.adminRights.toLowerCase().includes(checkRight) || false;
  };

  return (
    <Section title="Message">
      <Grid>
        <Grid.Column size={6}>
          <Button fluid icon="comment" onClick={() => handleAction('pm')}>
            PM
          </Button>
          {isButtonAllowed('admin') ? (
            <Button
              fluid
              icon="comment-alt"
              onClick={() => handleAction('narrate')}
            >
              NARRATE
            </Button>
          ) : null}
          {isButtonAllowed('admin') ? (
            <Button
              fluid
              icon="user-secret"
              onClick={() => handleAction('sendalert')}
            >
              SEND ALERT
            </Button>
          ) : null}
        </Grid.Column>
        <Grid.Column size={6}>
          <Button
            fluid
            icon="user-secret"
            disabled={!isButtonAllowed('event')}
            onClick={() => handleAction('sm')}
          >
            SM
          </Button>
          {isButtonAllowed('admin') ? (
            <Button fluid icon="crown" onClick={() => handleAction('manup')}>
              MAN UP
            </Button>
          ) : null}
          {isButtonAllowed('sound') ? (
            <Button
              fluid
              icon="music"
              onClick={() => handleAction('playsoundto')}
            >
              PLAY SOUND TO
            </Button>
          ) : null}
        </Grid.Column>
      </Grid>
    </Section>
  );
};

const MovementSection = (_props: unknown) => {
  const { act, data } = useBackend<PlayerData>();

  const handleAction = (action: string, params = {}) => {
    act(action, { selectedPlayerCkey: data.ckey, ...params });
  };

  const isButtonAllowed = (checkRight: string): boolean => {
    return data.adminRights.toLowerCase().includes(checkRight) || false;
  };

  return (
    <Section title="Movement">
      <Grid>
        <Grid.Column size={6}>
          <Button fluid icon="eye" onClick={() => handleAction('flw')}>
            FLW
          </Button>
          {isButtonAllowed('admin') ? (
            <Button fluid icon="download" onClick={() => handleAction('get')}>
              GET
            </Button>
          ) : null}
          {isButtonAllowed('admin') ? (
            <Button
              fluid
              icon="paper-plane"
              onClick={() => handleAction('send')}
            >
              SEND
            </Button>
          ) : null}
        </Grid.Column>
        <Grid.Column size={6}>
          <Button fluid icon="running" onClick={() => handleAction('jumpto')}>
            JUMPTO
          </Button>
          {isButtonAllowed('admin') ? (
            <Button
              fluid
              icon="sign-out-alt"
              onClick={() => handleAction('lobby')}
            >
              LOBBY
            </Button>
          ) : null}
          {isButtonAllowed('admin') ? (
            <Button fluid icon="columns" onClick={() => handleAction('cryo')}>
              SEND TO CRYO
            </Button>
          ) : null}
        </Grid.Column>
      </Grid>
    </Section>
  );
};

const InfoSection = (_props: unknown) => {
  const { act, data } = useBackend<PlayerData>();

  const handleAction = (action: string, params = {}) => {
    act(action, { selectedPlayerCkey: data.ckey, ...params });
  };

  const isButtonAllowed = (checkRight: string): boolean => {
    return data.adminRights.toLowerCase().includes(checkRight) || false;
  };

  return (
    <Section title="Info">
      <Grid>
        <Grid.Column size={6}>
          <Button fluid icon="book" onClick={() => handleAction('logs')}>
            LOGS
          </Button>
          <Button fluid icon="clipboard" onClick={() => handleAction('notes')}>
            NOTES
          </Button>
          {isButtonAllowed('admin') ? (
            <Button fluid icon="eye" onClick={() => handleAction('playtime')}>
              PLAYTIME
            </Button>
          ) : null}
          {isButtonAllowed('admin') ? (
            <Button fluid icon="globe" onClick={() => handleAction('geoip')}>
              GEOIP
            </Button>
          ) : null}
        </Grid.Column>
        <Grid.Column size={6}>
          <Button fluid icon="user-secret" onClick={() => handleAction('tp')}>
            TRAITOR PANEL
          </Button>
          <Button fluid icon="code" onClick={() => handleAction('vv')}>
            VV
          </Button>
          {isButtonAllowed('admin') ? (
            <Button fluid icon="database" onClick={() => handleAction('ccdb')}>
              CHECK GLOBAL CCDB
            </Button>
          ) : null}
          <Button fluid icon="eye" onClick={() => handleAction('obs')}>
            OBS
          </Button>
        </Grid.Column>
      </Grid>
    </Section>
  );
};

const TransformationSection = (_props: unknown) => {
  const { act, data } = useBackend<PlayerData>();

  const handleAction = (action: string, params = {}) => {
    act(action, { selectedPlayerCkey: data.ckey, ...params });
  };

  const isButtonAllowed = (checkRight: string): boolean => {
    return data.adminRights.toLowerCase().includes(checkRight) || false;
  };

  if (!isButtonAllowed('spawn')) {
    return null;
  }

  return (
    <Section title="Transformation">
      <Grid>
        <Grid.Column size={6}>
          <Button
            fluid
            icon="ghost"
            color={isMobType(data.mobType, 'ghost') ? 'good' : ''}
            onClick={() => handleAction('makeghost')}
          >
            MAKE GHOST
          </Button>
          <Button
            fluid
            icon="user"
            color={isMobType(data.mobType, 'human') ? 'good' : ''}
            onClick={() => handleAction('makehuman')}
          >
            MAKE HUMAN
          </Button>
          <Button
            fluid
            icon="paw"
            color={isMobType(data.mobType, 'monkey') ? 'good' : ''}
            onClick={() => handleAction('makemonkey')}
          >
            MAKE MONKEY
          </Button>
        </Grid.Column>
        <Grid.Column size={6}>
          <Button
            fluid
            icon="robot"
            color={isMobType(data.mobType, 'cyborg') ? 'good' : ''}
            onClick={() => handleAction('makeborg')}
          >
            MAKE CYBORG
          </Button>
          <Button
            fluid
            icon="microchip"
            color={isMobType(data.mobType, 'ai') ? 'good' : ''}
            onClick={() => handleAction('makeai')}
          >
            MAKE AI
          </Button>
          <Button
            fluid
            icon="microchip"
            color={isMobType(data.mobType, 'animal') ? 'good' : ''}
            onClick={() => handleAction('makeanimal')}
          >
            ANIMALIZE
          </Button>
        </Grid.Column>
      </Grid>
    </Section>
  );
};

const HealthObserverSection = (_props: unknown) => {
  const { act, data } = useBackend<PlayerData>();

  const handleAction = (action: string, params = {}) => {
    act(action, { selectedPlayerCkey: data.ckey, ...params });
  };

  const isButtonAllowed = (checkRight: string): boolean => {
    return data.adminRights.toLowerCase().includes(checkRight) || false;
  };

  return isMobType(data.mobType, 'ghost') ? (
    <Section title="Observer">
      <Grid>
        <Grid.Column size={2}>
          <Button fluid onClick={() => handleAction('respawnability')}>
            TOGGLE RESPAWNABILITY
          </Button>
        </Grid.Column>
        <Grid.Column size={2}>
          <Button
            fluid
            icon="staff-snake"
            disabled={!isButtonAllowed('spawn')}
            onClick={() => handleAction('reviveghost')}
          >
            RE-INCARNATE
          </Button>
        </Grid.Column>
      </Grid>
    </Section>
  ) : (
    <Section title="Health">
      <Grid>
        <Grid.Column size={6}>
          <Button fluid icon="heart" onClick={() => handleAction('healthscan')}>
            HEALTHSCAN
          </Button>
          {isButtonAllowed('admin') ? (
            <Button fluid onClick={() => handleAction('giveDisease')}>
              GIVE DISEASE
            </Button>
          ) : null}

          {isButtonAllowed('admin') ? (
            <Button fluid onClick={() => handleAction('cureDisease')}>
              CURE DISEASE
            </Button>
          ) : null}
          {isButtonAllowed('admin') ? (
            <Button fluid onClick={() => handleAction('cureAllDiseases')}>
              CURE ALL BAD DISEASES
            </Button>
          ) : null}
        </Grid.Column>
        <Grid.Column size={6}>
          <Button fluid onClick={() => handleAction('chemscan')}>
            CHEMSCAN
          </Button>
          <Button
            fluid
            icon="plus"
            disabled={!isButtonAllowed('rejuvinate')}
            onClick={() => handleAction('aheal')}
          >
            REJUVINATE
          </Button>
          {isButtonAllowed('admin') ? (
            <Button fluid icon="dna" onClick={() => handleAction('mutate')}>
              SHOW DNA
            </Button>
          ) : null}
        </Grid.Column>
      </Grid>
    </Section>
  );
};

const MobManipulationSection = (_props: unknown) => {
  const { act, data } = useBackend<PlayerData>();

  const handleAction = (action: string, params = {}) => {
    act(action, { selectedPlayerCkey: data.ckey, ...params });
  };

  const isButtonAllowed = (checkRight: string): boolean => {
    return data.adminRights.toLowerCase().includes(checkRight) || false;
  };

  if (!isButtonAllowed('admin')) {
    return null;
  }

  return (
    <Section title="Mob Manipulation">
      <Grid>
        <Grid.Column size={6}>
          <Button
            fluid
            icon="pencil"
            onClick={() => handleAction('randomizename')}
          >
            MOB RANDOM NAME
          </Button>
          <Button
            fluid
            icon="shirt"
            disabled={!isButtonAllowed('event')}
            onClick={() => handleAction('selectequip')}
          >
            SELECT EQUIPMENT
          </Button>
          <Button
            fluid
            icon="microphone"
            onClick={() => handleAction('changevoice')}
          >
            CHANGE VOICE
          </Button>
          {isButtonAllowed('event') ? (
            <Button
              fluid
              icon="circle-user"
              onClick={() => handleAction('mirroradmin')}
            >
              MIRROR UI TO ADMIN
            </Button>
          ) : null}
        </Grid.Column>
        <Grid.Column size={6}>
          <Button
            fluid
            icon="pen"
            onClick={() => handleAction('userandomname')}
          >
            CHARACTER RANDOM NAME
          </Button>
          <Button
            fluid
            icon="eraser"
            onClick={() => handleAction('eraseflavortext')}
          >
            ERASE FLAVOR
          </Button>
          <Button
            fluid
            icon="shirt"
            onClick={() => handleAction('checkcontents')}
          >
            CHECK CONTENTS
          </Button>
          {isButtonAllowed('event') ? (
            <Button
              fluid
              icon="circle-user"
              onClick={() => handleAction('mirrorplayer')}
            >
              MIRROR UI TO PLAYER
            </Button>
          ) : null}
        </Grid.Column>
      </Grid>
    </Section>
  );
};

const MiscSection = (_props: unknown) => {
  const { act, data } = useBackend<PlayerData>();

  const handleAction = (action: string, params = {}) => {
    act(action, { selectedPlayerCkey: data.ckey, ...params });
  };

  const isButtonAllowed = (checkRight: string): boolean => {
    return data.adminRights.toLowerCase().includes(checkRight) || false;
  };

  return (
    <Section title="Misc">
      <Grid>
        <Grid.Column size={6}>
          {isButtonAllowed('event') ? (
            <Button
              fluid
              icon="gavel"
              onClick={() => handleAction('thunderdome1')}
            >
              THUNDERDOME 1
            </Button>
          ) : null}
          {isButtonAllowed('event') ? (
            <Button
              fluid
              icon="gavel"
              onClick={() => handleAction('thunderdome2')}
            >
              THUNDERDOME 2
            </Button>
          ) : null}
          {isButtonAllowed('event') ? (
            <Button
              fluid
              icon="comment"
              onClick={() => handleAction('forcesay')}
            >
              FORCESAY
            </Button>
          ) : null}
          {isButtonAllowed('admin') ? (
            <Button
              fluid
              icon="handcuffs"
              onClick={() => handleAction('prison')}
            >
              PRISON
            </Button>
          ) : null}
          {isButtonAllowed('admin') ? (
            <Button fluid onClick={() => handleAction('contractor_release')}>
              SYNDI JAIL RELEASE
            </Button>
          ) : null}
          {isButtonAllowed('event') || isButtonAllowed('admin') ? (
            <Button
              fluid
              icon="cookie"
              onClick={() => handleAction('spawncookie')}
            >
              SPAWN COOKIE
            </Button>
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
              onClick={() => handleAction('thunderdomeadmin')}
            >
              THUNDERDOME ADMIN
            </Button>
          ) : null}
          {isButtonAllowed('event') ? (
            <Button
              fluid
              icon="eye"
              onClick={() => handleAction('thunderdomeobserver')}
            >
              THUNDERDOME OBSERVER
            </Button>
          ) : null}
          {isButtonAllowed('admin') ? (
            <Button
              fluid
              icon="wheelchair-move"
              onClick={() => handleAction('adminroom')}
            >
              AROOM WRAP
            </Button>
          ) : null}
          {isButtonAllowed('admin') ? (
            <Button fluid onClick={() => handleAction('contractor_start')}>
              SYNDI JAIL START
            </Button>
          ) : null}
          {isButtonAllowed('admin') ? (
            <Button fluid onClick={() => handleAction('contractor_stop')}>
              SYNDI JAIL STOP
            </Button>
          ) : null}
          <Button fluid onClick={() => handleAction('someadminbutton')}>
            Some Admin Button
          </Button>
        </Grid.Column>
      </Grid>
    </Section>
  );
};

const MuteSection = (_props: unknown) => {
  const { act, data } = useBackend<PlayerData>();

  const handleAction = (action: string, params = {}) => {
    act(action, { selectedPlayerCkey: data.ckey, ...params });
  };

  const toggleMute = (type: string) => {
    if (!data.ckey) {
      return;
    }
    handleAction('toggleMute', { type });
  };

  return (
    <Section title="Mute Controls">
      <Grid>
        <Grid.Column size={7}>
          <ButtonMute
            fluid
            checked={data.muteStates.ic}
            onClick={() => toggleMute('ic')}
          >
            IC
          </ButtonMute>
          <ButtonMute
            fluid
            checked={data.muteStates.ooc}
            onClick={() => toggleMute('ooc')}
          >
            OOC
          </ButtonMute>
          <ButtonMute
            fluid
            checked={data.muteStates.pray}
            onClick={() => toggleMute('pray')}
          >
            PRAY
          </ButtonMute>
          <ButtonMute
            fluid
            checked={data.muteStates.emote}
            onClick={() => toggleMute('emote')}
          >
            EMOTE
          </ButtonMute>
        </Grid.Column>
        <Grid.Column size={6}>
          <ButtonMute
            fluid
            checked={data.muteStates.adminhelp}
            onClick={() => toggleMute('adminhelp')}
          >
            ADMINHELP
          </ButtonMute>
          <ButtonMute
            fluid
            checked={data.muteStates.deadchat}
            onClick={() => toggleMute('deadchat')}
          >
            DEADCHAT
          </ButtonMute>
          <ButtonMute
            fluid
            checked={data.muteStates.all}
            onClick={() => toggleMute('all')}
          >
            ALL
          </ButtonMute>
        </Grid.Column>
      </Grid>
    </Section>
  );
};

// Button.CheckBox doesn't want colors and setting inside, make it "complexed"

type ButtonMuteProps = {
  checked: boolean;
} & ButtonProps;

const ButtonMute = (props: ButtonMuteProps) => {
  const { checked, ...rest } = props;
  return (
    <Button
      color={checked ? 'red' : 'green'}
      icon={checked ? 'check-square-o' : 'square-o'}
      {...rest}
    />
  );
};
