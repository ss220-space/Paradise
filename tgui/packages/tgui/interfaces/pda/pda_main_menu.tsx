import { useBackend } from '../../backend';
import { Button, Stack, LabeledList, Section } from '../../components';

type MainMenuData = {
  owner: string;
  ownjob: string;
  idInserted: boolean;
  categories: string[];
  pai: boolean;
  notifying: string[];
  apps: App[];
};

type App = {
  name: string;
  uid: string;
  notify_icon: string;
  icon: string;
};

export const pda_main_menu = (props: unknown) => {
  const { act, data } = useBackend<MainMenuData>();

  const { owner, ownjob, idInserted, categories, pai, notifying } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Owner" color="average">
              {owner}, {ownjob}
            </LabeledList.Item>
            <LabeledList.Item label="ID">
              <Button
                icon="sync"
                disabled={!idInserted}
                onClick={() => act('UpdateInfo')}
              >
                Update PDA Info
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Functions">
          <LabeledList>
            {categories.map((name) => {
              let apps: App[] = data.apps[name];

              if (!apps || !apps.length) {
                return null;
              } else {
                return (
                  <LabeledList.Item label={name} key={name}>
                    {apps.map((app) => (
                      <Button
                        key={app.uid}
                        icon={app.uid in notifying ? app.notify_icon : app.icon}
                        iconSpin={app.uid in notifying}
                        color={app.uid in notifying ? 'red' : 'transparent'}
                        onClick={() =>
                          act('StartProgram', { program: app.uid })
                        }
                      >
                        {app.name}
                      </Button>
                    ))}
                  </LabeledList.Item>
                );
              }
            })}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        {!!pai && (
          <Section title="pAI">
            <Button fluid icon="cog" onClick={() => act('pai', { option: 1 })}>
              Configuration
            </Button>
            <Button
              fluid
              icon="eject"
              onClick={() => act('pai', { option: 2 })}
            >
              Eject pAI
            </Button>
          </Section>
        )}
      </Stack.Item>
    </Stack>
  );
};
