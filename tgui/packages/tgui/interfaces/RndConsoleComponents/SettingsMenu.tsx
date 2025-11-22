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
          <Section title="Настройки">
            <Flex direction="column" align="flex-start">
              <Button
                icon="sync"
                disabled={!sync}
                onClick={() => {
                  act('sync');
                }}
              >
                Синхронизировать с сетью НИО
              </Button>

              <Button
                icon="plug"
                disabled={sync}
                onClick={() => {
                  act('togglesync');
                }}
              >
                Подключиться к сети НИО
              </Button>

              <Button
                disabled={!sync}
                icon="unlink"
                onClick={() => {
                  act('togglesync');
                }}
              >
                Отключиться от сети НИО
              </Button>

              <RndNavButton
                disabled={!sync}
                icon="link"
                menu={MENU.SETTINGS}
                submenu={SUBMENU.SETTINGS_DEVICES}
              >
                Меню подключения оборудования
              </RndNavButton>

              {admin ? (
                <Button icon="exclamation" onClick={() => act('maxresearch')}>
                  [АДМИН] Повысить тех. уровни до максимума
                </Button>
              ) : null}
            </Flex>
          </Section>
        )}
      />

      <RndRoute
        submenu={SUBMENU.SETTINGS_DEVICES}
        render={() => (
          <Section title="Меню подключения оборудования">
            <Button icon="link" onClick={() => act('find_device')}>
              Синхронизация ближайшего оборудования
            </Button>

            <Box mt="5px">
              <h3>Подключённое оборудование:</h3>
            </Box>
            <LabeledList>
              {linked_destroy ? (
                <LabeledList.Item label="- Деструктивный анализатор">
                  <Button
                    icon="unlink"
                    onClick={() => act('disconnect', { item: 'destroy' })}
                  >
                    Отключить
                  </Button>
                </LabeledList.Item>
              ) : (
                <LabeledList.Item label="- Деструктивный анализатор (ОТКЛЮЧЕНО)" />
              )}

              {linked_lathe ? (
                <LabeledList.Item label="- Протолат">
                  <Button
                    icon="unlink"
                    onClick={() => {
                      act('disconnect', { item: 'lathe' });
                    }}
                  >
                    Отключить
                  </Button>
                </LabeledList.Item>
              ) : (
                <LabeledList.Item label="- Протолат (ОТКЛЮЧЕНО)" />
              )}

              {linked_imprinter ? (
                <LabeledList.Item label="- Принтер плат">
                  <Button
                    icon="unlink"
                    onClick={() => act('disconnect', { item: 'imprinter' })}
                  >
                    Отключить
                  </Button>
                </LabeledList.Item>
              ) : (
                <LabeledList.Item label="- Принтер плат (ОТКЛЮЧЕНО)" />
              )}
            </LabeledList>
          </Section>
        )}
      />
    </Box>
  );
};
