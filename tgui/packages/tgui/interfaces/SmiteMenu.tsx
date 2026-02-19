import { useBackend } from '../backend';
import {
  Button,
  Section,
  Input,
  Box,
  Stack,
  Tabs,
  Icon,
  NoticeBox,
} from '../components';
import { Window } from '../layouts';
import { useState, useMemo } from 'react';

type SmiteMenuData = {
  categorized_smites: Record<string, Record<string, string>>;
  choosen: string;
  reason: string;
};

type Smite = {
  category: string;
  name: string;
  desc: string;
};

const CATEGORY_ICONS: Record<string, string> = {
  'Общие': 'star',
  'Урон': 'skull-crossbones',
  'Смерть': 'skull',
  'Преобразование': 'user-cog',
  'Контроль': 'brain',
};

type SelectedSmiteCardProps = {
  smite?: Smite;
};

const SelectedSmiteCard = (props: SelectedSmiteCardProps) => {
  const { smite } = props;

  return (
    <Section title="Выбранная кара">
      {smite ? (
        <Box
          style={{
            padding: '12px',
            backgroundColor: 'rgba(100, 150, 255, 0.1)',
            borderRadius: '4px',
            border: '1px solid rgba(100, 150, 255, 0.3)',
          }}
        >
          <Box bold mb={1} fontSize={1.2}>
            {smite.name}
          </Box>
          <Box
            color="label"
            style={{
              fontSize: '12px',
              lineHeight: '1.4em',
              wordBreak: 'break-word',
            }}
          >
            {smite.desc}
          </Box>
        </Box>
      ) : (
        <Box
          italic
          color="label"
          textAlign="center"
          style={{
            padding: '20px',
            backgroundColor: 'rgba(0, 0, 0, 0.2)',
            borderRadius: '4px',
            border: '1px dashed rgba(255, 255, 255, 0.1)',
          }}
        >
          Кара не выбрана
        </Box>
      )}
    </Section>
  );
};

type SmiteSettingsProps = {
  reason: string;
  onReasonChange: (value: string) => void;
  hasSelectedSmite: boolean;
  onApplySmite: () => void;
};

const SmiteSettings = (props: SmiteSettingsProps) => {
  const { reason, onReasonChange, hasSelectedSmite, onApplySmite } = props;

  return (
    <Section title="Настройка кары">
      <Stack align="center">
        <Stack.Item grow>
          <Box style={{ flexGrow: 1 }}>
            <Input
              placeholder="Введите причину наказания..."
              onChange={onReasonChange}
              fluid
              style={{
                backgroundColor: 'rgba(255, 255, 255, 0.1)',
                border: '0.1em solid rgba(255, 255, 255, 0.2)',
                color: 'white',
                height: '100%',
                padding: '0.3em',
                width: '100%',
              }}
            />
          </Box>
        </Stack.Item>

        <Stack.Item>
          <Button
            icon="bolt"
            color="bad"
            fontSize="1.2em"
            disabled={!hasSelectedSmite}
            onClick={onApplySmite}
            tooltip={!hasSelectedSmite ? 'Выберите кару сначала' : undefined}
            style={{
              height: '100%',
              width: '100%',
              borderRadius: '4px',
              whiteSpace: 'nowrap',
            }}
          >
            ПРИМЕНИТЬ КАРУ
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type SmiteListProps = {
  smites: Smite[];
  selectedName: string;
  onSelect: (name: string) => void;
  showCategory?: boolean;
};

const SmiteList = (props: SmiteListProps) => {
  const { smites, selectedName, onSelect, showCategory } = props;

  return (
    <Section fill scrollable>
      {smites.length === 0 ? (
        <NoticeBox textAlign="center" color="blue">
          Нет доступных кар
        </NoticeBox>
      ) : (
        smites.map((smite) => (
          <SmiteCard
            key={smite.name}
            smite={smite}
            isSelected={smite.name === selectedName}
            onSelect={() => onSelect(smite.name)}
            showCategory={showCategory}
          />
        ))
      )}
    </Section>
  );
};

type SmiteCardProps = {
  smite: Smite;
  isSelected: boolean;
  onSelect: () => void;
  showCategory?: boolean;
};

const SmiteCard = (props: SmiteCardProps) => {
  const { smite, isSelected, onSelect, showCategory } = props;

  return (
    <Box
      onClick={onSelect}
      style={{
        marginBottom: '6px',
        padding: '8px',
        backgroundColor: isSelected
          ? 'rgba(100, 150, 255, 0.2)'
          : 'rgba(0, 0, 0, 0.1)',
        border: `1px solid ${
          isSelected ? 'rgba(100, 150, 255, 0.4)' : 'rgba(255, 255, 255, 0.05)'
        }`,
        borderRadius: '4px',
        minHeight: '60px',
        position: 'relative',
        cursor: 'pointer',
        flexShrink: 0,
      }}
    >
      <Box
        style={{
          position: 'absolute',
          right: '8px',
          top: '50%',
          transform: 'translateY(-50%)',
        }}
      >
        <Icon
          name={isSelected ? 'check-circle' : 'circle'}
          color={isSelected ? 'good' : 'label'}
          size={1.2}
        />
      </Box>

      <Box style={{ paddingRight: '30px' }}>
        <Box
          bold
          style={{
            whiteSpace: 'nowrap',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
            marginBottom: '2px',
          }}
        >
          {smite.name}
          {showCategory && (
            <Box as="span" color="label" ml={1}>
              [{smite.category}]
            </Box>
          )}
        </Box>
        <Box
          color="label"
          style={{
            fontSize: '11px',
            lineHeight: '1.2em',
            wordBreak: 'break-word',
            whiteSpace: 'pre-wrap',
            overflowWrap: 'break-word',
          }}
        >
          {smite.desc}
        </Box>
      </Box>
    </Box>
  );
};

type CategoryTabsProps = {
  categories: string[];
  activeCategory: string;
  onCategorySelect: (category: string) => void;
};

const CategoryTabs = (props: CategoryTabsProps) => {
  const { categories, activeCategory, onCategorySelect } = props;

  return (
    <Section
      fill
      scrollable
      style={{
        width: '150px',
        minWidth: '160px',
      }}
    >
      <Tabs vertical fluid>
        {categories.map((category) => (
          <Tabs.Tab
            key={category}
            selected={category === activeCategory}
            onClick={() => onCategorySelect(category)}
            icon={CATEGORY_ICONS[category] || 'question'}
          >
            <Box
              style={{
                whiteSpace: 'nowrap',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
                maxWidth: '120px',
              }}
            >
              {category}
            </Box>
          </Tabs.Tab>
        ))}
      </Tabs>
    </Section>
  );
};

export const SmiteMenu = (_props: unknown) => {
  const { act, data } = useBackend<SmiteMenuData>();
  const { categorized_smites, choosen, reason } = data;

  const [activeCategory, setActiveCategory] = useState<string>(
    Object.keys(categorized_smites)[0] || 'Общие'
  );
  const [searchQuery, setSearchQuery] = useState<string>('');

  const allSmites = useMemo(() => {
    const smites: Smite[] = [];
    for (const category in categorized_smites) {
      for (const name in categorized_smites[category]) {
        smites.push({
          category,
          name,
          desc: categorized_smites[category][name],
        });
      }
    }
    return smites;
  }, [categorized_smites]);

  const filteredSmites = useMemo(() => {
    if (!searchQuery) {
      const categorySmites = categorized_smites[activeCategory];
      if (!categorySmites) return [];

      return Object.entries(categorySmites).map(([name, desc]) => ({
        category: activeCategory,
        name,
        desc,
      }));
    }

    const query = searchQuery.toLowerCase();
    return allSmites.filter(
      (smite) =>
        smite.name.toLowerCase().includes(query) ||
        smite.desc.toLowerCase().includes(query) ||
        smite.category.toLowerCase().includes(query)
    );
  }, [searchQuery, activeCategory, categorized_smites, allSmites]);

  const categories = Object.keys(categorized_smites);
  const selectedSmite = allSmites.find((s) => s.name === choosen);

  const handleTabClick = (category: string) => {
    setSearchQuery('');
    setActiveCategory(category);
  };

  const handleReasonChange = (value: string) => {
    act('change_reason', { new_reason: value });
  };

  const handleApplySmite = () => {
    act('activate');
  };

  const handleSelectSmite = (name: string) => {
    act('change_choosen', { new_choosen: name });
  };

  return (
    <Window width={600} height={550} theme="admin">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <SelectedSmiteCard smite={selectedSmite} />
          </Stack.Item>

          <Stack.Item>
            <SmiteSettings
              reason={reason}
              onReasonChange={handleReasonChange}
              hasSelectedSmite={!!choosen}
              onApplySmite={handleApplySmite}
            />
          </Stack.Item>

          <Stack.Item grow>
            <Section
              title="Выбор кары"
              buttons={
                <Input
                  width="250px"
                  placeholder="Поиск по названию или описанию..."
                  value={searchQuery}
                  onChange={(value) => setSearchQuery(value)}
                />
              }
              fill
              style={{
                overflow: 'hidden',
                display: 'flex',
                flexDirection: 'column',
                height: '100%',
              }}
            >
              {!searchQuery ? (
                <Stack fill>
                  <Stack.Item>
                    <CategoryTabs
                      categories={categories}
                      activeCategory={activeCategory}
                      onCategorySelect={handleTabClick}
                    />
                  </Stack.Item>

                  <Stack.Item grow>
                    <Box
                      style={{
                        height: '100%',
                        display: 'flex',
                        flexDirection: 'column',
                        overflow: 'hidden',
                      }}
                    >
                      <SmiteList
                        smites={filteredSmites}
                        selectedName={choosen}
                        onSelect={handleSelectSmite}
                      />
                    </Box>
                  </Stack.Item>
                </Stack>
              ) : (
                <Box
                  style={{
                    height: '100%',
                    display: 'flex',
                    flexDirection: 'column',
                    overflow: 'hidden',
                  }}
                >
                  <Box mb={2} color="label">
                    Найдено {filteredSmites.length} кар
                  </Box>
                  <SmiteList
                    smites={filteredSmites}
                    selectedName={choosen}
                    onSelect={handleSelectSmite}
                    showCategory
                  />
                </Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
