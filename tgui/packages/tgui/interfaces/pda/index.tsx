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
          <PDAHeader app={AppComponent} />
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

const PDAHeader = ({ app }) => {
  const { act, data } = useBackend<PDAData>();

  const { stationTime, cartridge_name, request_cartridge_name } = data;

  return (
    <Box
      style={{
        background: '#151821',
        borderBottom: '1px solid #222',
      }}
    >
      {/* 🔥 STATUS BAR */}
      <Box
        px={2}
        py={0.5}
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          fontSize: '11px',
          color: '#aaa',
        }}
      >
        <Box>{stationTime}</Box>
        <Box>📡 ███ 🔋</Box>
      </Box>

      {/* 🔥 MAIN HEADER */}
      <Box
        px={2}
        py={1.5}
        style={{
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
        }}
      >
        {app.has_back && (
          <Button
            icon="arrow-left"
            color="transparent"
            onClick={() => act('Back')}
          />
        )}

        <Icon name={app.icon} />

        <Box bold style={{ flexGrow: 1 }}>
          {app.name}
        </Box>

        {/* 🔥 CARTRIDGES */}
        {!!cartridge_name && (
          <Button
            icon="sd-card"
            color="transparent"
            tooltip="Eject cartridge"
            onClick={() => act('Eject')}
          />
        )}

        {!!request_cartridge_name && (
          <Button
            icon="sd-card"
            color="transparent"
            tooltip="Eject request cartridge"
            onClick={() => act('Eject_Request')}
          />
        )}
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
            act('Home'); // 🔥 fallback
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
