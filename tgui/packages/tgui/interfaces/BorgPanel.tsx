import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

type BorgPanelData = {
  borg: Borg;
  cell: Cell;
  channels: Chanel[];
  modules: Module[];
  upgrades: Upgrade[];
  ais: AI[];
  laws: string[];
};

type Cell = {
  charge: number;
  maxcharge: number;
  missing: boolean;
};

type Borg = {
  name: string;
  emagged: boolean;
  lockdown: boolean;
  scrambledcodes: boolean;
  active_module: string;
  lawmanager: boolean;
  lawupdate: boolean;
};

type Chanel = {
  name: string;
  installed: boolean;
};

type Module = {
  name: string;
  type: string;
};

type Upgrade = {
  name: string;
  type: string;
  installed: boolean;
};

type AI = {
  name: string;
  connected: boolean;
  ref: string;
};

export const BorgPanel = (props: unknown) => {
  const { act, data } = useBackend<BorgPanelData>();
  const { borg, cell, channels, modules, upgrades, ais, laws } = data;
  const cellPercent = cell.charge / cell.maxcharge;
  return (
    <Window title="Borg Panel" width={700} height={700}>
      <Window.Content scrollable>
        <Section
          title={borg.name}
          buttons={
            <Button icon="pencil-alt" onClick={() => act('rename')}>
              Rename
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Status">
              <Button
                icon={borg.emagged ? 'check-square-o' : 'square-o'}
                selected={borg.emagged}
                onClick={() => act('toggle_emagged')}
              >
                Emagged
              </Button>
              <Button
                icon={borg.lockdown ? 'check-square-o' : 'square-o'}
                selected={borg.lockdown}
                onClick={() => act('toggle_lockdown')}
              >
                Locked Down
              </Button>
              <Button
                icon={borg.scrambledcodes ? 'check-square-o' : 'square-o'}
                selected={borg.scrambledcodes}
                onClick={() => act('toggle_scrambledcodes')}
              >
                Scrambled Codes
              </Button>
              <Button onClick={() => act('reset_module')}>Reset Module</Button>
            </LabeledList.Item>
            <LabeledList.Item label="Charge">
              {!cell.missing ? (
                <ProgressBar value={cellPercent}>
                  {cell.charge + ' / ' + cell.maxcharge}
                </ProgressBar>
              ) : (
                <span className="color-bad">No cell installed</span>
              )}
              <br />
              <Button icon="pencil-alt" onClick={() => act('set_charge')}>
                Set
              </Button>
              <Button icon="eject" onClick={() => act('change_cell')}>
                Change
              </Button>
              <Button
                icon="trash"
                color="bad"
                onClick={() => act('remove_cell')}
              >
                Remove
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Radio Channels">
              {channels.map((channel) => (
                <Button
                  key={channel.name}
                  icon={channel.installed ? 'check-square-o' : 'square-o'}
                  selected={channel.installed}
                  onClick={() =>
                    act('toggle_radio', {
                      channel: channel.name,
                    })
                  }
                >
                  {channel.name}
                </Button>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Model">
              {modules.map((module) => (
                <Button
                  key={module.type}
                  icon={
                    borg.active_module === module.name
                      ? 'check-square-o'
                      : 'square-o'
                  }
                  selected={borg.active_module === module.name}
                  onClick={() =>
                    act('setmodule', {
                      module: module.type,
                    })
                  }
                >
                  {module.name + ' module'}
                </Button>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Upgrades">
              {upgrades.map((upgrade) => (
                <Button
                  key={upgrade.type}
                  icon={upgrade.installed ? 'check-square-o' : 'square-o'}
                  selected={upgrade.installed}
                  onClick={() =>
                    act('toggle_upgrade', {
                      upgrade: upgrade.type,
                    })
                  }
                >
                  {upgrade.name}
                </Button>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Master AI">
              {ais.map((ai) => (
                <Button
                  key={ai.ref}
                  icon={ai.connected ? 'check-square-o' : 'square-o'}
                  selected={ai.connected}
                  onClick={() =>
                    act('slavetoai', {
                      slavetoai: ai.ref,
                    })
                  }
                >
                  {ai.name}
                </Button>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Laws"
          buttons={
            <>
              <Button
                selected={borg.lawmanager}
                onClick={() => act('lawmanager')}
              >
                Law Manager
              </Button>
              <Button
                icon={borg.lawupdate ? 'check-square-o' : 'square-o'}
                selected={borg.lawupdate}
                onClick={() => act('toggle_lawupdate')}
              >
                Lawsync
              </Button>
            </>
          }
        >
          {laws.map((law) => (
            <Box key={law}>{law}</Box>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
