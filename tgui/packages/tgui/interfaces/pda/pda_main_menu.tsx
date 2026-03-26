import { useBackend } from '../../backend';
import { Button, Box, Section, Stack } from '../../components';

type MainMenuData = {
  owner: string;
  ownjob: string;
  idInserted: boolean;
  categories: string[];
  pai: boolean;
  notifying: string[];
  apps: Record<string, App[]>;
};

type App = {
  name: string;
  uid: string;
  notify_icon: string;
  icon: string;
};

// Компонент одной иконки приложения
const AppIcon = (props: {
  app: App;
  isNotifying: boolean;
  onClick: () => void;
}) => {
  const { app, isNotifying, onClick } = props;

  return (
    <Button
      className="PDA__app-icon"
      color="transparent"
      onClick={onClick}
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '8px 4px',
        gap: '4px',
        aspectRatio: '1/1',
        maxWidth: '100px',
        minWidth: '70px',
        flex: '1 1 80px',
      }}
    >
      <Box
        className="PDA__app-icon__square"
        style={{
          width: '48px',
          height: '48px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: isNotifying
            ? 'rgba(220, 50, 50, 0.15)'
            : 'rgba(255,255,255,0.08)',
          borderRadius: '12px',
          border: isNotifying
            ? '2px solid #dc322f'
            : '1px solid rgba(255,255,255,0.1)',
          transition: 'all 0.15s ease',
        }}
      >
        <Box
          style={{
            fontSize: '24px',
            color: isNotifying ? '#dc322f' : 'white',
            animation: isNotifying ? 'spin 1.5s linear infinite' : 'none',
          }}
        >
          <i className={`fa fa-${isNotifying ? app.notify_icon : app.icon}`} />
        </Box>
      </Box>
      <Box
        style={{
          fontSize: '11px',
          textAlign: 'center',
          color: 'white',
          fontWeight: 500,
          textOverflow: 'ellipsis',
          overflow: 'hidden',
          whiteSpace: 'nowrap',
          width: '100%',
          maxWidth: '90px',
        }}
      >
        {app.name}
      </Box>
    </Button>
  );
};

const CategoryGrid = (props: {
  name: string;
  apps: App[];
  notifying: string[];
  onStart: (uid: string) => void;
}) => {
  const { name, apps, notifying, onStart } = props;

  if (!apps?.length) return null;

  return (
    <Section title={name} mb={2}>
      <Box
        className="PDA__app-grid"
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fill, minmax(80px, 1fr))', // ← Адаптивная сетка
          gap: '12px 8px',
          padding: '8px 4px',
          justifyContent: 'center',
        }}
      >
        {apps.map((app) => (
          <AppIcon
            key={app.uid}
            app={app}
            isNotifying={app.uid in notifying}
            onClick={() => onStart(app.uid)}
          />
        ))}
      </Box>
    </Section>
  );
};

export const pda_main_menu = (_props: unknown) => {
  const { act, data } = useBackend<MainMenuData>();
  const { owner, ownjob, idInserted, categories, pai, notifying, apps } = data;

  return (
    <Stack fill vertical style={{ padding: '4px' }}>
      <Stack.Item>
        <Section
          title="PDA Info"
          style={
            {
              fontSize: '12px',
              '--section-padding': '8px',
            } as any
          }
        >
          <Stack>
            <Stack.Item grow>
              <Box bold>{owner}</Box>
              <Box color="average" style={{ fontSize: '11px' }}>
                {ownjob}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="sync"
                disabled={!idInserted}
                onClick={() => act('UpdateInfo')}
                tooltip="Обновить данные из ID-карты"
              >
                Sync
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item grow>
        {categories.map((catName) => (
          <CategoryGrid
            key={catName}
            name={catName}
            apps={apps?.[catName]}
            notifying={notifying}
            onStart={(uid) => act('StartProgram', { program: uid })}
          />
        ))}
      </Stack.Item>

      {!!pai && (
        <Stack.Item>
          <Section title="pAI Control" style={{ fontSize: '12px' }}>
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="cog"
                  onClick={() => act('pai', { option: 1 })}
                >
                  Configuration
                </Button>
              </Stack.Item>
              <Stack.Item grow>
                <Button
                  fluid
                  icon="eject"
                  onClick={() => act('pai', { option: 2 })}
                  color="bad"
                >
                  Eject
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};
