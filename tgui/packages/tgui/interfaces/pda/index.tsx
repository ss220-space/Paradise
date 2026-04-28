import { useState } from 'react';
import { useBackend } from '../../backend';
import { Box, Button, Section, Icon } from '../../components';
import { Window } from '../../layouts';
import { routingError } from '../../routes';

const PDA_UI = {
  window: {
    width: 580,
    height: 850,
  },
};

const RequirePDAInterface = require.context('.', false, /\.tsx$/);

const THEME_MAP: Record<string, string> = {
  pda_bank: 'raingor_company',
};

const THEME_NAMES: Record<string, string> = {
  nanotrasen: 'NT Classic',
  ntos_darkmode: 'Dark Mode',
  ntos_roboblue: 'RoboBlue',
  ntos_cat: 'NT Cat',
  ntos_roboquest: 'RoboQuest',
  ntos_spooky: 'Spooky',
  ntos_synth: 'Synth',
  ntos_terminal: 'Terminal',
  abductor: 'Abductor',
  admin: 'Admin',
  cargo: 'Cargo',
  changeling: 'Changeling',
  clockwork: 'Clockwork',
  hackerman: 'Hacker',
  honker: 'Honker',
  infernal: 'Infernal',
  malfunction: 'Malfunction',
  safe: 'Safe',
  spider_clan: 'Spider Clan',
};

const GetApp = (name) => {
  if (name === 'index') {
    return routingError('notFound', name);
  }

  let appModule;
  try {
    appModule = RequirePDAInterface(`./${name}.tsx`);
  } catch (err) {
    if (err.code === 'MODULE_NOT_FOUND') {
      return routingError('notFound', name);
    }
    throw err;
  }

  const Component = appModule[name];
  if (!Component) {
    return routingError('missingExport', name);
  }

  return Component;
};

type PDAData = {
  app: App;
  owner: boolean;
  idInserted: boolean;
  idLink: string;
  stationTime: string;
  cartridge_name: string;
  request_cartridge_name: string;
  current_theme: string;
};

type App = {
  name: string;
  has_back: boolean;
  is_home: boolean;
  icon: string;
  template: string;
};

export const PDA = () => {
  const { data } = useBackend<PDAData>();
  const { app, owner } = data;

  if (!owner) {
    return (
      <Window width={PDA_UI.window.width} height={PDA_UI.window.height}>
        <Window.Content>
          <Section title="Ошибка">
            Не найден пользователь. Пожалуйста, обновите данные через ID-карту.
          </Section>
        </Window.Content>
      </Window>
    );
  }

  const AppComponent = GetApp(app.template);
  const theme = THEME_MAP[app.template] || data.current_theme || 'nanotrasen';

  return (
    <Window
      width={PDA_UI.window.width}
      height={PDA_UI.window.height}
      theme={theme}
    >
      <Window.Content p={0} height="100%">
        <Box
          height="100%"
          style={{
            display: 'grid',
            gridTemplateRows: 'auto 1fr minmax(4rem, 9%)',
            overflow: 'hidden',
          }}
        >
          <PDAHeader />
          <Box
            p={0.75}
            minHeight={0}
            style={{
              overflowY: 'auto',
            }}
          >
            <AppComponent />
          </Box>

          <PDAFooter />
        </Box>
      </Window.Content>
    </Window>
  );
};

const PDAHeader = () => {
  const { act, data } = useBackend<PDAData>();
  const {
    app,
    idInserted,
    idLink,
    stationTime,
    cartridge_name,
    request_cartridge_name,
  } = data;

  const [pressed, setPressed] = useState(false);

  return (
    <Box>
      <Box
        style={{
          display: 'grid',
          gridTemplateColumns: '1fr auto 1fr',
          alignItems: 'center',
          padding: '0.4rem 0.75rem',
          borderBottom: '1px solid var(--color-border)',
          fontSize: '0.75rem',
          gap: '0.5rem',
        }}
      >
        <Box
          onClick={() => act('VPNConnect')}
          onMouseDown={() => setPressed(true)}
          onMouseUp={() => setPressed(false)}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '0.5rem',
            cursor: 'pointer',
            justifySelf: 'start',
          }}
        >
          <Box
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '0.25rem',
              padding: '0.15rem 0.4rem',
              background: 'rgba(74, 158, 255, 0.1)',
              borderRadius: '0.2rem',
              border: '1px solid rgba(74, 158, 255, 0.3)',
              transform: pressed ? 'scale(0.96)' : 'scale(1)',
              transition: 'transform 0.1s ease',
            }}
          >
            <Icon name="key" style={{ color: '#4a9eff' }} />
            <Box bold style={{ color: '#4a9eff' }}>
              VPN
            </Box>
          </Box>

          <Icon name="wifi" style={{ color: '#4a9eff' }} />
        </Box>

        <Box bold style={{ color: '#888', justifySelf: 'center' }}>
          {stationTime}
        </Box>

        <Box
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '0.35rem',
            justifySelf: 'end',
          }}
        >
          <Box bold style={{ color: '#4a9eff' }}>
            87%
          </Box>

          <Box
            width={1.4}
            height={0.7}
            style={{
              border: '1px solid #4a9eff',
              borderRadius: '0.15rem',
              position: 'relative',
            }}
          >
            <Box
              width="80%"
              height="100%"
              style={{
                background: 'linear-gradient(90deg, #4a9eff 0%, #5af 100%)',
              }}
            />
          </Box>
        </Box>
      </Box>

      {/* MAIN HEADER */}
      <Box
        style={{
          display: 'grid',
          gridTemplateColumns: 'auto auto 1fr auto auto',
          alignItems: 'center',
          gap: '0.5rem',
          padding: '0.6rem 0.75rem',
        }}
      >
        <Button
          icon={idInserted ? 'id-card' : 'id-card-o'}
          color={idInserted ? 'good' : 'bad'}
          onClick={() => act('Authenticate')}
        >
          {idInserted ? idLink : 'No ID'}
        </Button>

        <Icon name={app?.icon || 'cube'} style={{ color: '#6496c8' }} />

        <Box
          bold
          minWidth={0}
          style={{
            overflow: 'hidden',
            textOverflow: 'ellipsis',
            whiteSpace: 'nowrap',
          }}
        >
          {app?.name || 'PDA'}
        </Box>

        {cartridge_name ? (
          <Button
            icon="sd-card"
            color="transparent"
            tooltip={`Eject: ${cartridge_name}`}
            onClick={() => act('Eject')}
          >
            {cartridge_name}
          </Button>
        ) : null}

        {request_cartridge_name ? (
          <Button
            icon="sd-card"
            color="transparent"
            tooltip={`Eject: ${request_cartridge_name}`}
            onClick={() => act('Eject_Request')}
          >
            {request_cartridge_name}
          </Button>
        ) : null}
      </Box>
    </Box>
  );
};

const PDAFooter = () => {
  const { act, data } = useBackend<PDAData>();
  const { app, current_theme } = data;

  return (
    <Box
      p={0.5}
      style={{
        display: 'grid',
        gridTemplateColumns: '1.15fr 1.15fr 1.15fr',
        gap: '0.5rem',
        borderTop: '1px solid #222',
        background: '#151821',
        alignItems: 'stretch',
      }}
    >
      <Button
        fluid
        icon="arrow-left"
        color="transparent"
        textAlign="center"
        style={{
          opacity: app.has_back ? 1 : 0.35,
          pointerEvents: app.has_back ? 'auto' : 'none',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '10% 20%',
        }}
        onClick={() => act('Back')}
      >
        Back
      </Button>

      <Button
        fluid
        icon="home"
        color="transparent"
        textAlign="center"
        style={{
          opacity: app.is_home ? 0.45 : 1,
          pointerEvents: app.is_home ? 'none' : 'auto',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '10% 20%',
        }}
        onClick={() => act('Home')}
      >
        Home
      </Button>

      <Button
        fluid
        icon="palette"
        color="transparent"
        tooltip={`Тема: ${THEME_NAMES[current_theme] || current_theme}`}
        textAlign="center"
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '10% 20%',
        }}
        onClick={() => act('CycleTheme')}
      >
        {THEME_NAMES[current_theme] || current_theme}
      </Button>
    </Box>
  );
};
