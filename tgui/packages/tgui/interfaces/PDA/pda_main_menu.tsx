import { useBackend } from '../../backend';
import { Box, Button } from '../../components';

type MainMenuData = {
  owner: string;
  ownjob: string;
  idInserted: boolean;
  categories: string[];
  notifying: string[];
  apps: Record<string, App[]>;
};

type App = {
  name: string;
  uid: string;
  notify_icon: string;
  icon: string;
};

const AppIcon = ({ app, isNotifying, onClick }) => {
  const rawIconName = isNotifying ? app.notify_icon : app.icon;
  const iconName = rawIconName || 'cube';

  return (
    <Button
      color="transparent"
      onClick={onClick}
      width="90px"
      style={{
        padding: '4px',
        display: 'flex',
        justifyContent: 'center',
      }}
    >
      <Box
        width="100%"
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
        }}
      >
        <Box
          position="relative"
          width="58px"
          height="58px"
          mb="6px"
          style={{
            borderRadius: '16px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            background: 'rgba(255,255,255,0.04)',
            border: '1px solid rgba(255,255,255,0.06)',
          }}
        >
          <i
            className={`fa fa-${iconName}`}
            style={{
              fontSize: '20px',
              color: '#fff',
            }}
          />

          {isNotifying && (
            <Box
              position="absolute"
              top="3px"
              right="3px"
              width="10px"
              height="10px"
              style={{
                borderRadius: '50%',
                background: '#ff4d4f',
                boxShadow: '0 0 6px rgba(255,77,79,0.7)',
              }}
            />
          )}
        </Box>

        <Box
          fontSize="9px"
          width="100%"
          color="#ddd"
          textAlign="center"
          minHeight="24px"
          style={{
            lineHeight: '1.2',
            wordBreak: 'break-word',
          }}
        >
          {app.name}
        </Box>
      </Box>
    </Button>
  );
};

export const pda_main_menu = () => {
  const { act, data } = useBackend<MainMenuData>();
  const { idInserted, notifying, apps } = data;

  const allApps: App[] = Object.values(apps || {}).flat();

  const notifyList = Array.isArray(notifying)
    ? notifying
    : Object.keys(notifying || {});

  return (
    <Box style={{ padding: '10px' }}>
      <Box
        mb="10px"
        p="10px"
        style={{
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
          gridTemplateColumns: 'repeat(auto-fit, minmax(90px, 1fr))',
          gap: '12px 8px',
          justifyItems: 'center',
        }}
      >
        {allApps.map((app) => (
          <AppIcon
            key={app.uid}
            app={app}
            isNotifying={notifyList.includes(app.uid)}
            onClick={() => act('StartProgram', { program: app.uid })}
          />
        ))}
      </Box>
    </Box>
  );
};
