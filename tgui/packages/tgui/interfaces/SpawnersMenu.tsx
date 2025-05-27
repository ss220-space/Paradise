import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

type SpawnersMenuData = {
  spawners: Spawner[];
};

type Spawner = {
  name: string;
  uids: string;
  amount_left: number;
  desc: string;
  fluff: string;
  important_info: string;
};

export const SpawnersMenu = (_props: unknown) => {
  const { act, data } = useBackend<SpawnersMenuData>();
  const spawners = data.spawners || [];
  return (
    <Window width={700} height={600}>
      <Window.Content scrollable>
        <Section>
          {spawners.map((spawner) => (
            <Section
              mb={0.5}
              key={spawner.name}
              title={spawner.name + ' (' + spawner.amount_left + ' left)'}
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
                    Spawn
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
