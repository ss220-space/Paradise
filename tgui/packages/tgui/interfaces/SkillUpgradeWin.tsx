import {
  Box,
  Button,
  Icon,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

// MARK: Window
type SkillUpgradeWinData = {
  user: UserData;
  categories: SkillCategory[];
  max_level: number;
};

export const SkillUpgradeWin = (props: unknown) => {
  const { data } = useBackend<SkillUpgradeWinData>();
  const { user, categories, max_level } = data;

  return (
    <Window width={720} height={860} theme="nologo">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section>
              <Stack align="center" justify="space-between" wrap>
                <Stack.Item>
                  <Stack align="center">
                    <Stack.Item>
                      <Icon name="user" size={2} color="blue" />
                    </Stack.Item>
                    <Stack.Item>
                      <Stack vertical>
                        <Stack.Item>
                          <Box bold fontSize={1.2}>
                            {user.username}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Box opacity={0.7}>{user.job}</Box>
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack align="center">
                    {!!user.admin && (
                      <Stack.Item>
                        <Box color="yellow" italic>
                          Админ-режим
                        </Box>
                      </Stack.Item>
                    )}
                    <Stack.Item>
                      <Box textAlign="right">
                        <Box fontSize={0.85} opacity={0.7}>
                          Свободные очки
                        </Box>
                        <Box
                          bold
                          fontSize={1.5}
                          color={user.points > 0 ? 'good' : 'average'}
                        >
                          <Icon name="star" mr={0.5} />
                          {user.points}
                        </Box>
                      </Box>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Навыки" fill scrollable>
              <Box mb={1} opacity={0.7} fontSize={0.9}>
                Уровень показан без бонусов от руководств. Бонус от мануала
                указан в скобках, например (+1 мануал).
              </Box>
              <Stack vertical>
                {categories.map((category: SkillCategory) => (
                  <SkillCategoryView
                    key={category.id}
                    category={category}
                    maxLevel={max_level}
                  />
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

// MARK: Category view
type SkillCategory = {
  id: string;
  name: string;
  color: string;
  has_discount: boolean;
  skills: Skill[];
};

const CATEGORY_ICONS: Record<string, string> = {
  Общие: 'user',
  Сервис: 'utensils',
  Боевые: 'crosshairs',
  Инженерные: 'wrench',
  Медицинские: 'medkit',
  Научные: 'flask',
};

const SkillCategoryView = ({
  category,
  maxLevel,
}: {
  category: SkillCategory;
  maxLevel: number;
}) => {
  return (
    <Box>
      <Box
        backgroundColor={category.color}
        px={1.5}
        py={0.75}
        style={{
          borderRadius: '6px 6px 0 0',
        }}
      >
        <Stack align="center" justify="space-between">
          <Stack.Item bold fontSize={1.05}>
            <Icon name={CATEGORY_ICONS[category.name] || 'layer-group'} mr={1} />
            {category.name}
          </Stack.Item>
          {!!category.has_discount && (
            <Stack.Item>
              <Box
                backgroundColor="rgba(0, 0, 0, 0.25)"
                px={1}
                py={0.25}
                fontSize={0.85}
                style={{ borderRadius: '3px' }}
              >
                <Icon name="tag" mr={0.5} />
                Скидка
              </Box>
            </Stack.Item>
          )}
        </Stack>
      </Box>
      <Box
        p={1}
        backgroundColor="rgba(0, 0, 0, 0.15)"
        style={{
          borderRadius: '0 0 6px 6px',
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))',
          gap: '0.5rem',
        }}
      >
        {category.skills.map((skill: Skill) => (
          <SkillView key={skill.id} skill={skill} maxLevel={maxLevel} />
        ))}
      </Box>
    </Box>
  );
};

// MARK: Skill element
type Skill = {
  id: string;
  name: string;
  desc: string;
  level: number;
  effective_level: number;
  effective_level_name: string;
  bonus: number;
  level_name: string;
  level_color: string;
  price: number;
  discount: boolean;
  can_purchase: boolean;
};

const SkillView = ({
  skill,
  maxLevel,
}: {
  skill: Skill;
  maxLevel: number;
}) => {
  const { act } = useBackend<SkillUpgradeWinData>();
  const isMaxLevel = skill.level >= maxLevel;

  let buttonTooltip = `Стоимость: ${skill.price}`;
  if (isMaxLevel) {
    buttonTooltip = 'Навык уже максимального уровня';
  } else if (!skill.can_purchase) {
    buttonTooltip = 'Недостаточно свободных очков';
  }

  return (
    <Box
      p={1}
      backgroundColor="rgba(0, 0, 0, 0.2)"
      style={{
        borderRadius: '4px',
        borderLeft: `3px solid ${skill.level_color}`,
      }}
    >
      <Stack vertical>
        <Stack.Item>
          <Stack align="center" justify="space-between">
            <Stack.Item bold>{skill.name}</Stack.Item>
            {!!skill.discount && (
              <Stack.Item>
                <Box color="yellow" italic fontSize={0.85}>
                  <Icon name="tag" mr={0.5} />
                  Скидка
                </Box>
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Box italic opacity={0.7} fontSize={0.9} minHeight="2.4em">
            {skill.desc}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <ProgressBar
            value={skill.level}
            minValue={0}
            maxValue={maxLevel}
            color={skill.level_color}
            height="0.4em"
            empty
          />
        </Stack.Item>
        <Stack.Item>
          <Stack align="center" justify="space-between" wrap>
            <Stack.Item>
              <Box bold textColor={skill.level_color}>
                {skill.level_name} ({skill.level})
              </Box>
              {!!skill.bonus && (
                <Tooltip
                  content={`С бонусом от руководства: ${skill.effective_level_name} (${skill.effective_level})`}
                >
                  <Box inline bold color="good">
                    {' '}
                    (+{skill.bonus} мануал)
                  </Box>
                </Tooltip>
              )}
            </Stack.Item>
            <Stack.Item>
              <Button
                compact
                icon="plus"
                color={skill.can_purchase ? 'green' : undefined}
                disabled={!skill.can_purchase}
                tooltip={buttonTooltip}
                tooltipPosition="top-end"
                onClick={() => act('purchase_skill', { skill: skill.id })}
              >
                {isMaxLevel ? 'Максимум' : `Прокачать за ${skill.price}`}
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Box>
  );
};
