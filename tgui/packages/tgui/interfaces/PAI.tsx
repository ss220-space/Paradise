import { useBackend } from '../backend';
import { Button, Box, Section, Icon } from '../components';
import { Window } from '../layouts';

/* This is all basically stolen from routes.js. */
import { routingError } from '../routes';

const RequirePAIInterface = require.context('./pai', false, /\.tsx$/);

const GetApp = (name: string) => {
  let appModule;
  try {
    appModule = RequirePAIInterface(`./${name}.tsx`);
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

type PAIData = {
  app_template: string;
  app_icon: string;
  app_title: string;
};

export const PAI = (_props: unknown) => {
  const { act, data } = useBackend<PAIData>();
  const { app_template, app_icon, app_title } = data;

  const App = GetApp(app_template);

  return (
    <Window width={600} height={650}>
      <Window.Content scrollable>
        <Section
          title={
            <Box>
              <Icon name={app_icon} mr={1} />
              {app_title}
              {app_template !== 'pai_main_menu' && (
                <Button
                  ml={2}
                  icon="arrow-up"
                  onClick={() => act('MASTER_back')}
                >
                  Home
                </Button>
              )}
            </Box>
          }
          p={1}
        >
          <App />
        </Section>
      </Window.Content>
    </Window>
  );
};
