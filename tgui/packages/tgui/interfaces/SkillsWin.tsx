import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';
import { decodeHtmlEntities } from 'common/string';
import { COLORS } from '../constants';

type Skill = {
  name: string;
  value: number;
  level_color: string;
  desc: string;
};

type SkillsCategory = {
  name: string;
  color: string;
  skills: Skill[];
};

export type Skills = {
  username: string;
  job: string;
  categories: SkillsCategory[];
};

const SkillCategoryTable = (category: SkillsCategory) => {
  return (
    category.skills.length > 0 && (
      <Table>
        {category.skills.map((skill: Skill) => (
          <Table.Row key={skill.name}>
            <Table.Cell width="25%">
              <b>{skill.name}</b>
              <br />
              <br />
            </Table.Cell>
            <Table.Cell width="75%" mb={5}>
              <span color='#828163'><i>{skill.desc}</i></span>
              <br />
              <Box inline>
                Уровень: [
                <Box inline bold textColor={skill.level_color}>
                  {skill.value}
                </Box>
                ]
              </Box>
              <br />
              <br />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    )
  );
};

export const SkillsWin = (props: unknown) => {
  const { data } = useBackend<Skills>();
  const { username, job, categories } = data;

  return (
    <Window width={725} height={800} theme="nologo">
      <Window.Content scrollable>
        <Section title={username}>
            {categories.map((category: SkillsCategory) => (
              <Section
                key={category.name}
                title={
                  <Box backgroundColor={category.color} m={-1} pt={1} pb={1}>
                    <Box ml={1} fontSize={1.2}>
                      {category.name}
                    </Box>
                  </Box>
                }
              >
                {SkillCategoryTable(category)}
              </Section>
            ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
