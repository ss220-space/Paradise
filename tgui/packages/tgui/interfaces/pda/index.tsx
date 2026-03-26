import { useBackend } from '../../backend';
import { Button, Box, Section, Stack, Icon } from '../../components';
import { Window } from '../../layouts';
import { routingError } from '../../routes';

const RequirePDAInterface = require.context('.', false, /\.tsx$/);

const THEME_MAP: Record<string, string> = {
  pda_bank: 'raingor_company',
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
      <Window width={350} height={105}>
        <Window.Content>
          <Section title="Ошибка">
            Не найден пользователь. Пожайлуста обновите данные через ID карту.
          </Section>
        </Window.Content>
      </Window>
    );
  }

  const AppComponent = GetApp(app.template);
  const theme = THEME_MAP[app.template] || 'nanotrasen';

  return (
    <Window width={650} height={850} theme={theme}>
      <Window.Content style={{ padding: 0 }}>
        <Box
          style={{
            display: 'flex',
            flexDirection: 'column',
            height: '100%',
            background: '#0f1115',
          }}
        >
          <PDAHeader />
          <Box
            style={{
              flex: 1,
              overflowY: 'auto',
              padding: '10px',
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

  return (
    <Box style={{ background: '#151821', borderBottom: '1px solid #222' }}>
      <Box
        px={2}
        py={0.5}
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          fontSize: '10px',
          color: '#666',
          borderBottom: '1px solid #1a1f2b',
          background: 'linear-gradient(180deg, #1a1f2b 0%, #151821 100%)',
        }}
      >
        <Box style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Box
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '3px',
              padding: '1px 5px',
              background: 'rgba(74, 158, 255, 0.1)',
              borderRadius: '3px',
              border: '1px solid rgba(74, 158, 255, 0.3)',
            }}
          >
            <Icon name="key" style={{ color: '#4a9eff', fontSize: '10px' }} />
            <Box
              style={{ color: '#4a9eff', fontSize: '8px', fontWeight: 'bold' }}
            >
              VPN
            </Box>
          </Box>

          <Icon name="wifi" style={{ color: '#4a9eff', fontSize: '11px' }} />
        </Box>

        <Box bold style={{ color: '#888', fontSize: '11px' }}>
          {stationTime}
        </Box>

        <Box style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
          <Box bold style={{ color: '#4a9eff', fontSize: '10px' }}>
            87%
          </Box>

          <Box
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '2px',
              padding: '1px 3px',
              background: 'rgba(0,0,0,0.3)',
              borderRadius: '3px',
            }}
          >
            <Box
              style={{
                width: '20px',
                height: '9px',
                border: '1px solid #4a9eff',
                borderRadius: '2px',
                position: 'relative',
                padding: '1px',
              }}
            >
              <Box
                style={{
                  width: '16px',
                  height: '7px',
                  background: 'linear-gradient(90deg, #4a9eff 0%, #5af 100%)',
                  borderRadius: '1px',
                }}
              />
            </Box>
            <Box
              style={{
                width: '2px',
                height: '4px',
                background: '#4a9eff',
                borderRadius: '0 1px 1px 0',
              }}
            />
          </Box>
        </Box>
      </Box>

      <Box
        px={2}
        py={1.5}
        style={{ display: 'flex', alignItems: 'center', gap: '8px' }}
      >
        <Button
          icon={idInserted ? 'id-card' : 'id-card-o'}
          color={idInserted ? 'good' : 'bad'}
          onClick={() => act('Authenticate')}
          style={{ padding: '4px 8px', fontSize: '10px' }}
        >
          {idInserted ? idLink : 'No ID'}
        </Button>

        <Icon name={app?.icon || 'cube'} mr={1} style={{ color: '#6496c8' }} />
        <Box bold style={{ flexGrow: 1, fontSize: '13px', color: '#ddd' }}>
          {app?.name || 'PDA'}
        </Box>

        {cartridge_name ? (
          <Button
            icon="sd-card"
            color="transparent"
            tooltip={`Eject: ${cartridge_name}`}
            onClick={() => act('Eject')}
            style={{ fontSize: '9px', color: '#888' }}
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
            style={{ fontSize: '9px', color: '#888' }}
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
  const { app } = data;

  return (
    <Box
      style={{
        display: 'flex',
        justifyContent: 'space-around',
        padding: '10px 0',
        background: '#151821',
        borderTop: '1px solid #222',
      }}
    >
      {/* BACK */}
      <Button
        color="transparent"
        icon="arrow-left"
        iconColor={app.has_back ? 'white' : '#555'}
        onClick={() => {
          if (app.has_back) {
            act('Back');
          } else {
            act('Home');
          }
        }}
      />

      {/* HOME */}
      <Button
        color="transparent"
        icon="home"
        iconColor={app.is_home ? '#555' : 'white'}
        onClick={() => act('Home')}
      />

      {/* CLOSE */}
      <Button color="transparent" icon="times" onClick={() => act('Close')} />
    </Box>
  );
};
