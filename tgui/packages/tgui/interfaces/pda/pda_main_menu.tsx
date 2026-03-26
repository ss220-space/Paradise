import { useBackend } from '../../backend';
import { Box, Button, Icon, Section } from '../../components';

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

const ICON_MAP: Record<string, string> = {
  // 'crew-manifest': 'users',
  // 'crew_manifest': 'users',
  // 'crewmanifest': 'users',
  // 'power-monitor': 'bolt',
  // 'power_monitor': 'bolt',
  // 'medical-records': 'heartbeat',
  // 'medical_records': 'heartbeat',
  // 'security-records': 'shield',
  // 'security_records': 'shield',
  // 'atmospheric-scan': 'cloud',
  // 'atmospheric_scan': 'cloud',
  // 'gas-scanner': 'cloud',
  // 'reagent-scanner': 'flask',
  // 'supply-records': 'cube',
  // 'request-consoles': 'clipboard',
  // 'request_consoles': 'clipboard',
  // 'custodial-locator': 'trash',
  // 'custodial_locator': 'trash',
  // 'status-display': 'info',
  // 'status_display': 'info',
  // 'security-bot-access': 'robot',
  // 'security_bot_access': 'robot',
  // 'enable-flashlight': 'lightbulb',
  // 'enable_gas_scanner': 'cloud',
  // 'enable_med_scanner': 'heartbeat',
  // 'enable_reagent_scanner': 'flask',
};

const AppIcon = ({ app, isNotifying, onClick }) => {
  const rawIconName = isNotifying ? app.notify_icon : app.icon;

  const iconName = ICON_MAP[rawIconName] || rawIconName || 'cube';

  return (
    <Button
      color="transparent"
      onClick={onClick}
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        width: '64px',
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
          background: '#1f2a3a',
          marginBottom: '6px',
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
          fontSize: '10px',
          color: '#ddd',
          textAlign: 'center',
          lineHeight: '1.2',
        }}
      >
        {app.name}
      </Box>
    </Button>
  );
};

export const pda_main_menu = () => {
  const { act, data } = useBackend<MainMenuData>();
  const { owner, ownjob, notifying, apps } = data;

  const allApps: App[] = Object.values(apps || {}).flat();

  return (
    <Box style={{ padding: '10px' }}>
      <Box
        style={{
          marginBottom: '10px',
          padding: '10px',
          background: '#1a1f2b',
          borderRadius: '10px',
        }}
      >
        <Box bold>{owner}</Box>
        <Box style={{ fontSize: '11px', color: '#888' }}>{ownjob}</Box>
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
  );
};
