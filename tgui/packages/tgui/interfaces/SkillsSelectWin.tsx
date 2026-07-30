import { useBackend } from '../backend';
import { Box, Button, LabeledList, Section, Table, Stack } from '../components';
import { Layout, Window } from '../layouts';
import { decodeHtmlEntities } from 'common/string';
import { COLORS } from '../constants';

type SkillSelectData = {
  id: string;
  name: string;
  value: number;
  level_color: string;
  desc: string;
  can_increase: boolean;
  can_decrease: boolean;
};

type SkillsSelectCategory = {
  name: string;
  color: string;
  skills: SkillSelectData[];
};

export type SkillsSelectData = {
  username: string;
  job: string;
  admin: boolean;
  can_save: boolean;
  free_points: number;
  total_point: number;
  categories: SkillsSelectCategory[];
};

const SkillCategoryTable = (category: SkillsSelectCategory) => {
  const { act } = useBackend<SkillsSelectData>();
  return (
    category.skills.length > 0 && (
      <Table>
        {category.skills.map((skill: SkillSelectData) => (
          <Table.Row key={skill.name}>
            <Table.Cell width="50%">
              <b>{skill.name}</b>
              <br />
              <br />
            </Table.Cell>
            <Table.Cell width="50%" mb={5}>
              <span color="#828163">
                <i>{skill.desc}</i>
              </span>
              <div />
              <Box inline>
                Уровень:
                <Box inline bold textColor={skill.level_color}>
                  {skill.value + ' '}
                  {skill.can_decrease ? (
                    <Button
                      onClick={() =>
                        act('decrease', {
                          'skill': skill.id,
                        })
                      }
                    >
                      -
                    </Button>
                  ) : (
                    ' '
                  )}
                  {skill.can_increase ? (
                    <Button
                      onClick={() =>
                        act('increase', {
                          'skill': skill.id,
                        })
                      }
                    >
                      +
                    </Button>
                  ) : (
                    ' '
                  )}
                </Box>
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

export const SkillsSelectWin = (props: unknown) => {
  const { act, data } = useBackend<SkillsSelectData>();
  const {
    username,
    job,
    admin,
    can_save,
    categories,
    free_points,
    total_point,
  } = data;

  return (
    <Window width={725} height={820} theme="nologo">
      <Window.Content>
        <Section
          title={
            admin
              ? 'Админ-абуз, очки неограничены'
              : 'Использовано очков навыков: ' +
                (total_point - free_points) +
                '/' +
                total_point
          }
          scrollable
          fill
          buttons={
            <>
              <Button
                ml={0.5}
                tooltip="Схранить"
                tooltipPosition="bottom-end"
                icon="save"
                disabled={!can_save}
                onClick={() => act('save')}
              >
                Сохранить
              </Button>
              <Button
                ml={0.5}
                tooltip="Сбросить распределенные очки"
                icon="refresh"
                onClick={() => act('reset')}
              >
                Сбросить
              </Button>
            </>
          }
        >
          {categories.map((category: SkillsSelectCategory) => (
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
