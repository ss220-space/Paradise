import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

type MiniGamesMenuData = {
  spawners: Spawner[];
  thunderdome_eligible: boolean;
  notifications_enabled: boolean;
};

type Spawner = {
  name: string;
  uids: string;
  desc: string;
  fluff: string;
  important_info: string;
};

export const MiniGamesMenu = (props: unknown) => {
  const { act, data } = useBackend<MiniGamesMenuData>();
  const spawners = data.spawners || [];
  const thunderdome_eligible = data.thunderdome_eligible;
  const notifications_enabled = data.notifications_enabled;
  return (
    <Window width={700} height={600}>
      <Window.Content scrollable>
        <Button
          fluid
          textAlign="center"
          icon="power-off"
          tooltip={
            thunderdome_eligible
              ? 'Выключить участие в боевых мини-играх'
              : 'Включить участие в боевых мини-играх'
          }
          tooltipPosition="bottom"
          color={thunderdome_eligible ? 'good' : 'bad'}
          onClick={() => act('toggle_minigames')}
        >
          {thunderdome_eligible
            ? 'Выключить участие в боевых мини-играх'
            : 'Включить участие в боевых мини-играх'}
        </Button>
        <Button
          fluid
          textAlign="center"
          icon="power-off"
          tooltip={
            notifications_enabled
              ? 'Отключить уведомления о боевых мини-играх'
              : 'Включить уведомления о боевых мини-играх'
          }
          tooltipPosition="bottom"
          color={notifications_enabled ? 'good' : 'bad'}
          onClick={() => act('toggle_notifications')}
        >
          {notifications_enabled
            ? 'Отключить уведомления о боевых мини-играх'
            : 'Включить уведомления о боевых мини-играх'}
        </Button>
        <Section>
          {spawners.map((spawner) => (
            <Section
              mb={0.5}
              key={spawner.name}
              title={spawner.name}
              buttons={
                <>
                  <Button
                    icon="chevron-circle-right"
                    onClick={() =>
                      act('jump', {
                        ID: spawner.uids,
                      })
                    }
                  >
                    Jump
                  </Button>
                  <Button
                    icon="chevron-circle-right"
                    onClick={() =>
                      act('spawn', {
                        ID: spawner.uids,
                      })
                    }
                  >
                    Start
                  </Button>
                </>
              }
            >
              <Box
                style={{ whiteSpace: 'pre-wrap' }} // preserve newline
                mb={1}
                fontSize="16px"
              >
                {spawner.desc}
              </Box>
              {!!spawner.fluff && (
                <Box // lighter grey than default grey for better contrast.
                  style={{ whiteSpace: 'pre-wrap' }}
                  textColor="#878787"
                  fontSize="14px"
                >
                  {spawner.fluff}
                </Box>
              )}
              {!!spawner.important_info && (
                <Box
                  style={{ whiteSpace: 'pre-wrap' }}
                  mt={1}
                  bold
                  color="red"
                  fontSize="18px"
                >
                  {spawner.important_info}
                </Box>
              )}
            </Section>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
