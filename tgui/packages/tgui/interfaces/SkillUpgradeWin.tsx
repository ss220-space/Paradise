import { Box, Button, Section, Stack, Table } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type SkillUpgradeWinData = {
  user: UserData;
  categories: SkillCategory[];
};

type UserData = {
  username: string;
  job: string;
  admin: boolean;
  points: number;
};

type SkillCategory = {
  id: string;
  name: string;
  color: string;
  skills: Skill[];
};

type Skill = {
  id: string;
  name: string;
  desc: string;
  level: string;
  level_color: string;
  price: number;
};

export const SkillUpgradeWin = (props: unknown) => {
  const { act, data } = useBackend<SkillUpgradeWinData>();

  return (
    <Window width={725} height={820} theme="nologo">
      <Window.Content>
        <Stack>
          {data.categories.map((category: SkillCategory) => (
            <Stack.Item key={category.id}>
              {SkillCategoryView(category)}
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SkillCategoryView = (category: SkillCategory) => {
  const { act } = useBackend<SkillCategory>();
  return (
    <Box backgroundColor={category.color}>
      <h3>{category.name}</h3>
      <Stack>
        {category.skills.map((skill: Skill) => (
          <Stack.Item key={skill.id}>{SkillView(category, skill)}</Stack.Item>
        ))}
      </Stack>
    </Box>
  );
};

const SkillView = (category: SkillCategory, skill: Skill) => {
  const { act } = useBackend<Skill>();
  return (
    <Box backgroundColor={category.color}>
      <b>{skill.name}</b>
      <p>{skill.desc}</p>
      <p color={skill.level_color}>{skill.level}</p>
    </Box>
  );
};
