import { useBackend } from '../../backend';
import { Box, Button, Flex, LabeledList, Section } from '../../components';
import { RndRoute, RndNavButton } from './index';
import { MENU, SUBMENU } from '../RndConsole';

type SettingsMenuData = { sync: boolean; admin: boolean } & RndData;

export const SettingsMenu = (properties) => {
  const { data, act } = useBackend<SettingsMenuData>();

  const { sync, admin, linked_destroy, linked_lathe, linked_imprinter } = data;

  return (
    <Box>
      <RndRoute
        submenu={SUBMENU.MAIN}
        render={() => (
          <Section title="Settings">
            <Flex direction="column" align="flex-start">
              <Button
                icon="sync"
                disabled={!sync}
                onClick={() => {
                  act('sync');
                }}
              >
                Sync Database with Network
              </Button>

              <Button
                icon="plug"
                disabled={sync}
                onClick={() => {
                  act('togglesync');
                }}
              >
                Connect to Research Network
              </Button>

              <Button
                disabled={!sync}
                icon="unlink"
                onClick={() => {
                  act('togglesync');
                }}
              >
                Disconnect from Research Network
              </Button>

              <RndNavButton
                disabled={!sync}
                icon="link"
                menu={MENU.SETTINGS}
                submenu={SUBMENU.SETTINGS_DEVICES}
              >
                Device Linkage Menu
              </RndNavButton>

              {admin ? (
                <Button icon="exclamation" onClick={() => act('maxresearch')}>
                  [ADMIN] Maximize Research Levels
                </Button>
              ) : null}
            </Flex>
          </Section>
        )}
      />

      <RndRoute
        submenu={SUBMENU.SETTINGS_DEVICES}
        render={() => (
          <Section title="Device Linkage Menu">
            <Button icon="link" onClick={() => act('find_device')}>
              Re-sync with Nearby Devices
            </Button>

            <Box mt="5px">
              <h3>Linked Devices:</h3>
            </Box>
            <LabeledList>
              {linked_destroy ? (
                <LabeledList.Item label="* Destructive Analyzer">
                  <Button
                    icon="unlink"
                    onClick={() => act('disconnect', { item: 'destroy' })}
                  >
                    Unlink
                  </Button>
                </LabeledList.Item>
              ) : (
                <LabeledList.Item label="* No Destructive Analyzer Linked" />
              )}

              {linked_lathe ? (
                <LabeledList.Item label="* Protolathe">
                  <Button
                    icon="unlink"
                    onClick={() => {
                      act('disconnect', { item: 'lathe' });
                    }}
                  >
                    Unlink
                  </Button>
                </LabeledList.Item>
              ) : (
                <LabeledList.Item label="* No Protolathe Linked" />
              )}

              {linked_imprinter ? (
                <LabeledList.Item label="* Circuit Imprinter">
                  <Button
                    icon="unlink"
                    onClick={() => act('disconnect', { item: 'imprinter' })}
                  >
                    Unlink
                  </Button>
                </LabeledList.Item>
              ) : (
                <LabeledList.Item label="* No Circuit Imprinter Linked" />
              )}
            </LabeledList>
          </Section>
        )}
      />
    </Box>
  );
};
