import type { BooleanLike } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';
import { useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Flex, Input, LabeledList, NoticeBox, Section, Stack, Tabs, Tooltip } from 'tgui-core/components';
import { Window } from '../layouts';

type Ruleset = {
  name: string;
  id: string;
  typepath: string;
  weight: string;
  min_pop: string;
  min_round_time: string;
  high_impact: BooleanLike;
};

type ActiveRuleset = {
  name: string;
  id: string;
  players: string[];
};

type QueuedRuleset = {
  name: string;
  id: string;
  index: number;
};

type Data = {
  mode_running: BooleanLike;
  round_started: BooleanLike;
  forced_tier: string | null;
  current_tier?: {
    number: number;
    name: string;
  };
  ruleset_count: Record<string, number>;
  time_until_midround: number;
  time_until_latejoin: number;
  active_rulesets: ActiveRuleset[];
  queued_rulesets: QueuedRuleset[];
  disabled_rulesets: string[];
  all_rulesets: Record<string, Ruleset[]>;
};

const CATEGORY_NAMES = {
  roundstart: 'Раундстарт',
  midround: 'Мидраунд',
  latejoin: 'Латеджойн',
};

const categoryName = (category: string) => CATEGORY_NAMES[category] || category;

const formatTime = (deciseconds: number) => {
  if (deciseconds <= 0) {
    return 'готово';
  }
  const seconds = Math.round(deciseconds / 10);
  const minutes = Math.floor(seconds / 60);
  return `${minutes}м ${seconds % 60}с`;
};

const StatusTab = () => {
  const { act, data } = useBackend<Data>();
  const {
    mode_running,
    round_started,
    forced_tier,
    current_tier,
    ruleset_count,
    time_until_midround,
    time_until_latejoin,
    active_rulesets,
  } = data;

  return (
    <Stack vertical fill>
      {!mode_running && (
        <Stack.Item>
          <NoticeBox>
            {round_started
              ? 'Текущий раунд идёт не в динамическом режиме. Настройки ниже применятся к следующему динамическому раунду.'
              : 'Раунд ещё не начался. Форсированный тир, очередь и выключенные правила применятся, если выпадет динамический режим.'}
          </NoticeBox>
        </Stack.Item>
      )}
      <Stack.Item>
        <Section title="Состояние">
          <LabeledList>
            <LabeledList.Item label="Тир">
              <Flex>
                <Flex.Item>
                  {current_tier
                    ? `${current_tier.number} (${current_tier.name})`
                    : forced_tier
                      ? `форсирован: ${forced_tier}`
                      : 'не выбран'}
                </Flex.Item>
                {!round_started && (
                  <Flex.Item ml={1}>
                    <Button onClick={() => act('set_tier')}>Изменить</Button>
                  </Flex.Item>
                )}
              </Flex>
            </LabeledList.Item>
            {Object.entries(ruleset_count).map(([category, count]) => (
              <LabeledList.Item
                key={category}
                label={`Осталось правил: ${categoryName(category)}`}
              >
                <Flex>
                  <Flex.Item>{count}</Flex.Item>
                  <Flex.Item ml={1}>
                    <Button
                      icon="plus"
                      tooltip="Добавить одно правило"
                      onClick={() => act('add_ruleset_count', { category })}
                    />
                  </Flex.Item>
                  <Flex.Item ml={0.5}>
                    <Button
                      icon="times"
                      disabled={count === 0}
                      tooltip="Обнулить"
                      onClick={() => act('zero_ruleset_count', { category })}
                    />
                  </Flex.Item>
                </Flex>
              </LabeledList.Item>
            ))}
            {!!mode_running && (
              <LabeledList.Item label="Мидраунд">
                <Flex>
                  <Flex.Item>{formatTime(time_until_midround)}</Flex.Item>
                  <Flex.Item ml={1}>
                    <Button
                      disabled={time_until_midround <= 0}
                      onClick={() => act('reset_midround_cooldown')}
                    >
                      Сбросить кулдаун
                    </Button>
                  </Flex.Item>
                  <Flex.Item ml={0.5}>
                    <Button
                      tooltip="Выдать ещё одно случайное мидраунд-правило прямо сейчас"
                      onClick={() => act('roll_midround')}
                    >
                      Прокрутить сейчас
                    </Button>
                  </Flex.Item>
                </Flex>
              </LabeledList.Item>
            )}
            {!!mode_running && (
              <LabeledList.Item label="Латеджойн">
                <Flex>
                  <Flex.Item>{formatTime(time_until_latejoin)}</Flex.Item>
                  <Flex.Item ml={1}>
                    <Button
                      disabled={time_until_latejoin <= 0}
                      onClick={() => act('reset_latejoin_cooldown')}
                    >
                      Сбросить кулдаун
                    </Button>
                  </Flex.Item>
                </Flex>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title="Отработавшие правила">
          {active_rulesets.length === 0 ? (
            <NoticeBox align="center">Пока ничего не отработало.</NoticeBox>
          ) : (
            active_rulesets.map((ruleset) => (
              <Box key={ruleset.id} mb={1}>
                <b>{ruleset.name}</b> ({ruleset.id})
                <Box color="label">
                  {ruleset.players.length
                    ? ruleset.players.join(', ')
                    : 'никто не выбран'}
                </Box>
              </Box>
            ))
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const RulesetsTab = () => {
  const { act, data } = useBackend<Data>();
  const {
    all_rulesets,
    queued_rulesets,
    disabled_rulesets,
    round_started,
    mode_running,
  } = data;

  const [searchText, setSearchText] = useState('');
  const searchFilter = createSearch(
    searchText,
    (ruleset: Ruleset) => `${ruleset.name} ${ruleset.id}`
  );

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title="Очередь">
          {queued_rulesets.length === 0 ? (
            <NoticeBox align="center">Очередь пуста.</NoticeBox>
          ) : (
            queued_rulesets.map((ruleset) => (
              <Box key={ruleset.index}>
                <Button
                  mr={0.5}
                  icon="times"
                  tooltip="Убрать из очереди"
                  onClick={() =>
                    act('unqueue_ruleset', { index: ruleset.index })
                  }
                />
                {ruleset.name} ({ruleset.id})
              </Box>
            ))
          )}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title="Все правила"
          buttons={
            <>
              <Input
                placeholder="Поиск..."
                expensive
                value={searchText}
                onChange={setSearchText}
              />
              <Button ml={0.5} onClick={() => act('disable_all')}>
                Выключить все
              </Button>
              <Button
                disabled={disabled_rulesets.length === 0}
                onClick={() => act('enable_all')}
              >
                Включить все
              </Button>
            </>
          }
        >
          <Stack>
            {Object.entries(all_rulesets).map(([category, rulesets]) => (
              <Stack.Item key={category} grow basis={0}>
                <Box bold mb={1} textAlign="center">
                  {categoryName(category)}
                </Box>
                {rulesets
                  .filter(searchFilter)
                  .sort((a, b) => (a.name > b.name ? 1 : -1))
                  .map((ruleset) => (
                    <Flex key={ruleset.typepath} mb={0.5}>
                      <Flex.Item>
                        {category === 'midround' ? (
                          <Button
                            icon="play"
                            disabled={!mode_running}
                            tooltip="Запустить прямо сейчас"
                            onClick={() =>
                              act('execute_ruleset', {
                                ruleset_type: ruleset.typepath,
                              })
                            }
                          />
                        ) : (
                          <Button
                            icon="plus"
                            disabled={
                              category === 'roundstart' && !!round_started
                            }
                            tooltip="Поставить в очередь"
                            onClick={() =>
                              act('queue_ruleset', {
                                ruleset_type: ruleset.typepath,
                              })
                            }
                          />
                        )}
                      </Flex.Item>
                      <Flex.Item ml={0.5}>
                        <Button.Checkbox
                          checked={disabled_rulesets.includes(ruleset.typepath)}
                          color={
                            disabled_rulesets.includes(ruleset.typepath)
                              ? 'bad'
                              : 'grey'
                          }
                          tooltip="Не выпадать случайно"
                          onClick={() =>
                            act('toggle_ruleset', {
                              ruleset_type: ruleset.typepath,
                            })
                          }
                        />
                      </Flex.Item>
                      <Flex.Item ml={1}>
                        <Tooltip
                          content={`${ruleset.id} — вес ${ruleset.weight}, минимум игроков ${ruleset.min_pop}${
                            ruleset.min_round_time === '0'
                              ? ''
                              : `, не раньше ${ruleset.min_round_time} мин`
                          }`}
                        >
                          <Box
                            color={ruleset.high_impact ? 'orange' : undefined}
                          >
                            {ruleset.name}
                          </Box>
                        </Tooltip>
                      </Flex.Item>
                    </Flex>
                  ))}
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const DynamicPanel = () => {
  const { act, data } = useBackend<Data>();
  const { mode_running } = data;
  const [tab, setTab] = useState('status');

  return (
    <Window title="Dynamic Panel" width={860} height={640}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Flex>
              <Flex.Item grow>
                <Tabs>
                  <Tabs.Tab
                    selected={tab === 'status'}
                    onClick={() => setTab('status')}
                  >
                    Статус
                  </Tabs.Tab>
                  <Tabs.Tab
                    selected={tab === 'rulesets'}
                    onClick={() => setTab('rulesets')}
                  >
                    Правила
                  </Tabs.Tab>
                </Tabs>
              </Flex.Item>
              <Flex.Item>
                <Button
                  disabled={!mode_running}
                  tooltip="Открыть VV режима"
                  onClick={() => act('vv')}
                >
                  VV
                </Button>
              </Flex.Item>
            </Flex>
          </Stack.Item>
          <Stack.Item grow>
            {tab === 'status' ? <StatusTab /> : <RulesetsTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
