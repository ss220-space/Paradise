import { Box, Button, Section, Stack, Table } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

//MARK: Window
type SkillUpgradeWinData = {
  user: UserData;
  categories: SkillCategory[];
};

export const SkillUpgradeWin = (props: unknown) => {
  const { act, data } = useBackend<SkillUpgradeWinData>();

  return (
    <Window width={650} height={900} theme="nologo">
      <Window.Content>
        <Stack fill vertical={true}>
          <Stack.Item height="12%">
            <Section title="Персонаж">{UserView(data.user)}</Section>
          </Stack.Item>
          <Stack.Item height="88%">
            <Section
              title="Навыки"
              minHeight="100%"
              fill
              scrollable
              scrollableHorizontal={true}
            >
              <Stack fill height="100%" vertical={true}>
                {data.categories.map((category: SkillCategory) => (
                  <Stack.Item key={category.id} height="100%">
                    {SkillCategoryView(category)}
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

// MARK: User view
type UserData = {
  username: string;
  job: string;
  admin: boolean;
  points: number;
};

const UserView = (user: UserData) => {
  const { act } = useBackend<UserData>();
  return (
    <Box>
      <Stack width="100%" ml="10px" vertical={true}>
        <Stack.Item>
          <Box>
            <b>Имя:</b> {user.username}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box>
            <b>Должность:</b> {user.job}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box>
            <b>Свободных очков:</b> {user.points}
          </Box>
        </Stack.Item>
      </Stack>
    </Box>
  );
};

// MARK: Category view
type SkillCategory = {
  id: string;
  name: string;
  color: string;
  has_discount: boolean;
  skills: Skill[];
};

const SkillCategoryView = (category: SkillCategory) => {
  const { act } = useBackend<SkillCategory>();
  return (
    <Stack vertical={true} height="100%" fill>
      <Stack.Item>
        <Box
          backgroundColor={category.color}
          style={{
            borderRadius: '10px 10px 0 0',
            padding: '5px',
          }}
        >
          <center>
            <b>{category.name}</b>{' '}
            {category.has_discount ? (
              <i
                style={{
                  color: 'yellow',
                }}
              >
                Скидка!
              </i>
            ) : (
              ''
            )}
          </center>
        </Box>
      </Stack.Item>
      <Stack.Item height="100%">
        <Box
          mt="-3px"
          backgroundColor="#454545"
          style={{
            borderRadius: '0px 0px 10px 10px',
            padding: '5px',
          }}
          height="100%"
        >
          <Stack vertical={true} height="100%">
            {category.skills.map((skill: Skill) => (
              <Stack.Item key={skill.id}>
                {SkillView(category, skill)}
              </Stack.Item>
            ))}
          </Stack>
        </Box>
      </Stack.Item>
    </Stack>
  );
};

// MARK: Skill element
type Skill = {
  id: string;
  name: string;
  desc: string;
  level: number;
  level_name: string;
  level_color: string;
  price: number;
  can_purchase: number;
};

const SkillView = (category: SkillCategory, skill: Skill) => {
  const { act } = useBackend<Skill>();
  return (
    <Table
      width="100%"
      height="75px"
      backgroundColor="#353535"
      style={{
        borderRadius: '5px 5px 5px 5px',
        margin: '2px',
      }}
    >
      <Table.Row height="25px">
        <Table.Cell
          backgroundColor="#252525"
          style={{
            borderRadius: '5px 5px 0px 0px',
          }}
        >
          <Box ml="5px" mt="5px">
            <b>{skill.name}</b>
          </Box>
        </Table.Cell>
      </Table.Row>
      <Table.Row height="25px">
        <Table.Cell>
          <Box ml="5px" mt="-8px" height="100%">
            <p>
              <i>{skill.desc}</i>
            </p>
          </Box>
        </Table.Cell>
      </Table.Row>
      <Table.Row height="8px">
        <Table.Cell color={skill.level_color}>
          <Box ml="5px" mt="-8px" mb="-10px">
            <Stack width="100%">
              <Stack.Item width="79%">
                <b>
                  {skill.level_name} ({skill.level})
                </b>
              </Stack.Item>
              <Stack.Item width="21%">
                <Button
                  pl="5px"
                  pr="5px"
                  pt="2px"
                  pb="2px"
                  mt="-2px"
                  width="115px"
                  textAlign="center"
                  style={{
                    borderRadius: '5px 5px 5px 5px',
                  }}
                  color={skill.can_purchase ? 'green' : 'gray'}
                  disabled={!skill.can_purchase}
                  onClick={() => act('purchase_skill', { skill: skill.id })}
                >
                  Прокачать за {skill.price}
                </Button>
              </Stack.Item>
            </Stack>
          </Box>
        </Table.Cell>
      </Table.Row>
      <Table.Row>
        <Table.Cell>
          <br />
        </Table.Cell>
      </Table.Row>
    </Table>
  );
};
