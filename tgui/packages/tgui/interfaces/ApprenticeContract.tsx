import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, Button, Section, Stack } from '../components';

type School = {
  id: string;
  name: string;
  desc: string;
};

type ApprenticeData = {
  isUsed: boolean;
  isBook: boolean;
  schools: School[];
};

export const ApprenticeContract = (props) => {
  const { act, data } = useBackend<ApprenticeData>();
  const { isUsed, isBook, schools = [] } = data;

  return (
    <Window
      title={isBook ? 'Магический учебник' : 'Contract of Apprenticeship'}
      width={500}
      height={600}
      theme="admin"
    >
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Section>
              {isUsed ? (
                <Box color="bad" bold>
                  {isBook
                    ? 'Письмена стерты, а все страницы пусты. Похоже учебник уже был изучен.'
                    : 'You have already summoned your apprentice.'}
                </Box>
              ) : (
                <Stack vertical>
                  <Stack.Item>
                    <Box bold mb={1} fontSize="1.1em">
                      {isBook
                        ? 'Магический учебник:'
                        : 'Contract of apprenticeship:'}
                    </Box>
                    <Box italic mb={1} color="label">
                      {isBook
                        ? 'Изучив этот учебник, вы определитесь в магии, которую будете практиковать. Перед тем как выбрать один из путей, хорошо подумайте и поговорите со своим учителем для получении рекомендаций.'
                        : 'Using this contract, you may summon an apprentice to aid you on your mission. If you are unable to establish contact with your apprentice, you can feed the contract back to the spellbook to refund your points.'}
                    </Box>
                    <Box bold mt={1}>
                      {isBook
                        ? 'Какую школу магии вы хотели бы изучать?'
                        : 'Which school of magic is your apprentice studying?'}
                    </Box>
                  </Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>

          {!isUsed && (
            <Stack.Item grow>
              <Section fill scrollable>
                <Stack vertical>
                  {schools.map((school) => (
                    <Stack.Item key={school.id}>
                      <Section
                        title={school.name}
                        buttons={
                          <Button
                            icon="magic"
                            onClick={() =>
                              act('choose_school', { school: school.id })
                            }
                          >
                            Выбрать
                          </Button>
                        }
                      >
                        <Box italic>{school.desc}</Box>
                      </Section>
                    </Stack.Item>
                  ))}
                </Stack>
              </Section>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
