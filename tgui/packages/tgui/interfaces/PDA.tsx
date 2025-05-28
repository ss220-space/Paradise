import { useBackend } from '../backend';
import { Button, Box, Section, Stack, Icon } from '../components';
import { Window } from '../layouts';

/* This is all basically stolen from routes.js. */
import { routingError } from '../routes';

const RequirePDAInterface = require.context('./pda', false, /\.tsx$/);

const GetApp = (name) => {
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

export const PDA = (_props: unknown) => {
  const { data } = useBackend<PDAData>();
  const { app, owner } = data;
  if (!owner) {
    return (
      <Window width={350} height={105}>
        <Window.Content scrollable>
          <Section title="Error">
            No user data found. Please swipe an ID card.
          </Section>
        </Window.Content>
      </Window>
    );
  }

  const App = GetApp(app.template);

  return (
    <Window width={600} height={650}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <PDAHeader />
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              p={1}
              pb={0}
              title={
                <Box>
                  <Icon name={app.icon} mr={1} />
                  {app.name}
                </Box>
              }
            >
              <App />
            </Section>
          </Stack.Item>
          <Stack.Item mt={7.5}>
            <PDAFooter />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const PDAHeader = (_props: unknown) => {
  const { act, data } = useBackend<PDAData>();
  const {
    idInserted,
    idLink,
    stationTime,
    cartridge_name,
    request_cartridge_name,
  } = data;

  return (
    <Stack fill>
      <Stack.Item ml={0.5}>
        <Button
          icon="id-card"
          color="transparent"
          onClick={() => act('Authenticate')}
        >
          {idInserted ? idLink : 'No ID Inserted'}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button icon="sd-card" color="transparent" onClick={() => act('Eject')}>
          {cartridge_name
            ? ['Eject ' + cartridge_name]
            : 'No Cartridge Inserted'}
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="sd-card"
          color="transparent"
          onClick={() => act('Eject_Request')}
        >
          {request_cartridge_name
            ? ['Eject ' + request_cartridge_name]
            : 'No Request Cartridge Inserted'}
        </Button>
      </Stack.Item>
      <Stack.Item grow textAlign="right" bold mr={1} mt={0.5}>
        {stationTime}
      </Stack.Item>
    </Stack>
  );
};

const PDAFooter = (_props: unknown) => {
  const { act, data } = useBackend<PDAData>();

  const { app } = data;

  return (
    <Box height="45px" className="PDA__footer" backgroundColor="#1b1b1b">
      <Stack fill>
        {!!app.has_back && (
          <Stack.Item basis="33%" mr={-0.5}>
            <Button
              fluid
              className="PDA__footer__button"
              color="transparent"
              iconColor={app.has_back ? 'white' : 'disabled'}
              icon="arrow-alt-circle-left-o"
              onClick={() => act('Back')}
            />
          </Stack.Item>
        )}
        <Stack.Item basis={app.has_back ? '33%' : '100%'}>
          <Button
            fluid
            className="PDA__footer__button"
            color="transparent"
            iconColor={app.is_home ? 'disabled' : 'white'}
            icon="home"
            onClick={() => {
              act('Home');
            }}
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};
