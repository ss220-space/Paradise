import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';
import { Access, AccessList } from './common/AccessList';

type PortableTurretData = {
  locked: boolean;
  on: boolean;
  lethal: boolean;
  lethal_is_configurable: boolean;
  targetting_is_configurable: boolean;
  check_weapons: boolean;
  neutralize_noaccess: boolean;
  access_is_configurable: boolean;
  regions: Access[];
  selectedAccess: number[];
  one_access: boolean;
  neutralize_norecord: boolean;
  neutralize_criminals: boolean;
  neutralize_all: boolean;
  neutralize_unidentified: boolean;
  neutralize_cyborgs: boolean;
};

export const PortableTurret = (_props: unknown) => {
  const { act, data } = useBackend<PortableTurretData>();
  const {
    locked,
    on,
    lethal,
    lethal_is_configurable,
    targetting_is_configurable,
    check_weapons,
    neutralize_noaccess,
    access_is_configurable,
    regions,
    selectedAccess,
    one_access,
    neutralize_norecord,
    neutralize_criminals,
    neutralize_all,
    neutralize_unidentified,
    neutralize_cyborgs,
  } = data;
  return (
    <Window width={500} height={400}>
      <Window.Content scrollable>
        <NoticeBox>
          Swipe an ID card to {locked ? 'unlock' : 'lock'} this interface.
        </NoticeBox>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Status">
              <Button
                icon={on ? 'power-off' : 'times'}
                selected={on}
                disabled={locked}
                onClick={() => act('power')}
              >
                {on ? 'On' : 'Off'}
              </Button>
            </LabeledList.Item>
            {!!lethal_is_configurable && (
              <LabeledList.Item label="Lethals">
                <Button
                  icon={lethal ? 'exclamation-triangle' : 'times'}
                  color={lethal ? 'bad' : ''}
                  disabled={locked}
                  onClick={() => act('lethal')}
                >
                  {lethal ? 'On' : 'Off'}
                </Button>
              </LabeledList.Item>
            )}
            {!!access_is_configurable && (
              <LabeledList.Item label="One Access Mode">
                <Button
                  icon={one_access ? 'address-card' : 'exclamation-triangle'}
                  selected={one_access}
                  disabled={locked}
                  onClick={() => act('one_access')}
                >
                  {one_access ? 'On' : 'Off'}
                </Button>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
        {!!targetting_is_configurable && (
          <>
            <Section title="Humanoid Targets">
              <Button.Checkbox
                fluid
                checked={neutralize_criminals}
                disabled={locked}
                onClick={() => act('autharrest')}
              >
                Wanted Criminals
              </Button.Checkbox>
              <Button.Checkbox
                fluid
                checked={neutralize_norecord}
                disabled={locked}
                onClick={() => act('authnorecord')}
              >
                No Sec Record
              </Button.Checkbox>
              <Button.Checkbox
                fluid
                checked={check_weapons}
                disabled={locked}
                onClick={() => act('authweapon')}
              >
                Unauthorized Weapons
              </Button.Checkbox>
              <Button.Checkbox
                fluid
                checked={neutralize_noaccess}
                disabled={locked}
                onClick={() => act('authaccess')}
              >
                Unauthorized Access
              </Button.Checkbox>
            </Section>
            <Section title="Other Targets">
              <Button.Checkbox
                fluid
                checked={neutralize_unidentified}
                disabled={locked}
                onClick={() => act('authxeno')}
              >
                Unidentified Lifesigns (Xenos, Animals, Etc)
              </Button.Checkbox>
              <Button.Checkbox
                fluid
                checked={neutralize_cyborgs}
                disabled={locked}
                onClick={() => act('authborgs')}
              >
                Cyborgs
              </Button.Checkbox>
              <Button.Checkbox
                fluid
                checked={neutralize_all}
                disabled={locked}
                onClick={() => act('authsynth')}
              >
                All Non-Synthetics
              </Button.Checkbox>
            </Section>
          </>
        )}
        {!!access_is_configurable && (
          <AccessList
            accesses={regions}
            selectedList={selectedAccess}
            accessMod={(ref) =>
              act('set', {
                access: ref,
              })
            }
            grantAll={() => act('grant_all')}
            denyAll={() => act('clear_all')}
            grantDep={(ref) =>
              act('grant_region', {
                region: ref,
              })
            }
            denyDep={(ref) =>
              act('deny_region', {
                region: ref,
              })
            }
          />
        )}
      </Window.Content>
    </Window>
  );
};
