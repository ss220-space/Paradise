import { useBackend } from '../../backend';
import { Button, Box, Section, Stack } from '../../components';
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
          <Section title="Error">
            No user data found. Please swipe an ID card.
          </Section>
        </Window.Content>
      </Window>
    );
  }

  const AppComponent = GetApp(app.template);
  const theme = THEME_MAP[app.template] || 'nanotrasen';

  return (
    <Window width={580} height={820} theme={theme}>
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
    idInserted,
    idLink,
    stationTime,
    cartridge_name,
    request_cartridge_name,
  } = data;

  return (
    <Box
      style={{
        background: '#12151c',
        borderBottom: '1px solid #222',
      }}
    >
      <Box
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          padding: '4px 8px',
          fontSize: '11px',
          color: '#aaa',
        }}
      >
        <Box>{stationTime}</Box>
        <Box>📡 ███ 🔋</Box>
      </Box>

      <Box style={{ padding: '6px 8px' }}>
        <Stack>
          <Stack.Item grow>
            <Button
              icon="id-card"
              color={idInserted ? 'good' : 'bad'}
              onClick={() => act('Authenticate')}
              style={{ fontSize: '11px' }}
            >
              {idInserted ? idLink : 'No ID'}
            </Button>
          </Stack.Item>

          <Stack.Item>
            <Button
              icon="sd-card"
              onClick={() => act('Eject')}
              tooltip="Eject cartridge"
              style={{ fontSize: '11px' }}
            >
              {cartridge_name || '—'}
            </Button>
          </Stack.Item>

          {!!request_cartridge_name && (
            <Stack.Item>
              <Button
                icon="sd-card"
                onClick={() => act('Eject_Request')}
                style={{ fontSize: '11px' }}
              >
                {request_cartridge_name}
              </Button>
            </Stack.Item>
          )}
        </Stack>
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
        height: '56px',
        display: 'flex',
        justifyContent: 'space-around',
        alignItems: 'center',
        background: '#12151c',
        borderTop: '1px solid #222',
      }}
    >
      <Button
        icon="arrow-left"
        disabled={!app.has_back}
        onClick={() => {
          if (app.has_back) {
            act('Back');
          } else {
            act('Home');
          }
        }}
        style={{ fontSize: '18px' }}
      />

      <Button
        icon="circle"
        onClick={() => act('Home')}
        style={{ fontSize: '18px' }}
      />

      <Button
        icon="times"
        onClick={() => act('Close')}
        style={{ fontSize: '18px' }}
      />
    </Box>
  );
};
