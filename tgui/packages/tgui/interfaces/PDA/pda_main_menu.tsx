import { useBackend } from '../../backend';
<<<<<<< HEAD
import { Button, Stack, LabeledList, Section } from '../../components';
=======
import { Box, Button } from '../../components';
>>>>>>> upstream/master220

type MainMenuData = {
  owner: string;
  ownjob: string;
  idInserted: boolean;
  categories: string[];
<<<<<<< HEAD
  pai: boolean;
  notifying: string[];
  apps: App[];
=======
  notifying: string[];
  apps: Record<string, App[]>;
>>>>>>> upstream/master220
};

type App = {
  name: string;
  uid: string;
  notify_icon: string;
  icon: string;
};

<<<<<<< HEAD
export const pda_main_menu = (props: unknown) => {
  const { act, data } = useBackend<MainMenuData>();

  const { owner, ownjob, idInserted, categories, pai, notifying } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Owner" color="average">
              {owner}, {ownjob}
            </LabeledList.Item>
            <LabeledList.Item label="ID">
              <Button
                icon="sync"
                disabled={!idInserted}
                onClick={() => act('UpdateInfo')}
              >
                Update PDA Info
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Functions">
          <LabeledList>
            {categories.map((name) => {
              let apps: App[] = data.apps[name];

              if (!apps || !apps.length) {
                return null;
              } else {
                return (
                  <LabeledList.Item label={name} key={name}>
                    {apps.map((app) => (
                      <Button
                        key={app.uid}
                        icon={app.uid in notifying ? app.notify_icon : app.icon}
                        iconSpin={app.uid in notifying}
                        color={app.uid in notifying ? 'red' : 'transparent'}
                        onClick={() =>
                          act('StartProgram', { program: app.uid })
                        }
                      >
                        {app.name}
                      </Button>
                    ))}
                  </LabeledList.Item>
                );
              }
            })}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        {!!pai && (
          <Section title="pAI">
            <Button fluid icon="cog" onClick={() => act('pai', { option: 1 })}>
              Configuration
            </Button>
            <Button
              fluid
              icon="eject"
              onClick={() => act('pai', { option: 2 })}
            >
              Eject pAI
            </Button>
          </Section>
        )}
      </Stack.Item>
    </Stack>
=======
const AppIcon = ({ app, isNotifying, onClick }) => {
  const rawIconName = isNotifying ? app.notify_icon : app.icon;
  const iconName = rawIconName || 'cube';

  return (
    <Button
      color="transparent"
      onClick={onClick}
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        width: '85px',
        padding: '4px',
      }}
    >
      <Box
        style={{
          width: '52px',
          height: '52px',
          borderRadius: '14px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          marginBottom: '6px',
          margin: '0 auto',
        }}
      >
        <i
          className={`fa fa-${iconName}`}
          style={{
            fontSize: '20px',
            color: '#fff',
          }}
        />
      </Box>

      <Box
        style={{
          fontSize: '9px',
          width: '80px',
          color: '#ddd',
          textAlign: 'center',
          lineHeight: '1.1',
          whiteSpace: 'normal',
          wordBreak: 'break-word',
          overflow: 'hidden',
          minHeight: '22px',
          maxHeight: '33px',
          margin: '0 auto',
        }}
      >
        {app.name}
      </Box>
    </Button>
  );
};

export const pda_main_menu = () => {
  const { act, data } = useBackend<MainMenuData>();
  const { idInserted, notifying, apps } = data;

  const allApps: App[] = Object.values(apps || {}).flat();

  return (
    <Box style={{ padding: '10px' }}>
      <Box
        style={{
          marginBottom: '10px',
          padding: '10px',
          borderRadius: '10px',
        }}
      >
        <Button
          fluid
          icon="sync"
          color={idInserted ? 'average' : 'disabled'}
          disabled={!idInserted}
          onClick={() => act('UpdateInfo')}
          tooltip={idInserted ? 'Обновить данные из ID' : 'Вставьте ID карту'}
          style={{
            padding: '6px 10px',
            fontSize: '11px',
          }}
        >
          Sync
        </Button>
      </Box>

      <Box
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(5, 1fr)',
          gap: '12px 8px',
          justifyItems: 'center',
        }}
      >
        {allApps.map((app) => (
          <AppIcon
            key={app.uid}
            app={app}
            isNotifying={notifying.includes(app.uid)}
            onClick={() => act('StartProgram', { program: app.uid })}
          />
        ))}
      </Box>
    </Box>
>>>>>>> upstream/master220
  );
};
