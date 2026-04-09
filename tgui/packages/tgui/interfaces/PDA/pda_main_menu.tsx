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

const APP_ICON_SIZE = '4.4rem';
const APP_BUTTON_WIDTH = '7.2rem';
const APP_TEXT_SIZE = '1rem';
const APP_ICON_FONT_SIZE = '2rem';

const AppIcon = ({ app, isNotifying, onClick }) => {
  const rawIconName = isNotifying ? app.notify_icon : app.icon;
  const iconName = rawIconName || 'cube';

  return (
    <Button
      color="transparent"
      onClick={onClick}
      width={APP_BUTTON_WIDTH}
      p={0.35}
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
      }}
    >
      <Box
        width={APP_ICON_SIZE}
        height={APP_ICON_SIZE}
        mb={0.4}
        style={{
          borderRadius: '0.9rem',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          margin: '0 auto',
        }}
      >
        <i
          className={`fa fa-${iconName}`}
          style={{
            fontSize: APP_ICON_FONT_SIZE,
            color: '#fff',
          }}
        />
      </Box>

      <Box
        width="100%"
        color="ddd"
        textAlign="center"
        lineHeight={1.2}
        fontSize={APP_TEXT_SIZE}
        overflow="hidden"
        minHeight={2.4}
        maxHeight={3.4}
        style={{
          whiteSpace: 'normal',
          wordBreak: 'break-word',
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

  const notifyList = Array.isArray(notifying)
    ? notifying
    : Object.keys(notifying || {});

  return (
    <Box style={{ padding: '0.75rem' }}>
      <Box
        mb="0.75rem"
        p="0.75rem"
        style={{
          borderRadius: '0.75rem',
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
            padding: '0.5rem 0.75rem',
            fontSize: '1rem',
            borderRadius: '0.5rem',
            overflow: 'hidden',
          }}
        >
          Синхронизировать кпк с ID-картой
        </Button>
      </Box>

      <Box
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(6rem, 1fr))',
          gap: '0.8rem 0.6rem',
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
