import { useState } from 'react';
import {
  Box,
  Button,
  Image,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type SpellEntry = {
  name: string;
  path: string;
};

type SpellFlags = {
  wizard_garb: boolean;
  requires_human: boolean;
  castable_as_brain: boolean;
  no_antimagic: boolean;
  no_centcom: boolean;
  requires_mind: boolean;
  mime_vow: boolean;
  castable_without_invocation: boolean;
};

type SpellCreatorData = {
  target_name: string | null;
  base_type: string | null;
  spells: SpellEntry[];
  name?: string;
  desc?: string;
  cooldown?: number;
  invocation?: string;
  has_invocation?: boolean;
  icon_state?: string;
  icon_preview?: string;
  flags?: SpellFlags;
};

const FLAG_LABELS: Record<keyof SpellFlags, string> = {
  wizard_garb: 'Нужна одежда мага',
  requires_human: 'Только для человеческого тела',
  castable_as_brain: 'Можно кастовать в виде мозга',
  no_antimagic: 'Блокируется антимагией',
  no_centcom: 'Нельзя использовать на центкоме',
  requires_mind: 'Нужен разум (mind)',
  mime_vow: 'Нужен обет мима',
  castable_without_invocation: 'Можно кастовать без фразы',
};

export const SpellCreator = (_props: unknown) => {
  const { act, data } = useBackend<SpellCreatorData>();
  const {
    target_name,
    base_type,
    spells = [],
    name = '',
    desc = '',
    cooldown = 0,
    invocation = '',
    has_invocation = false,
    icon_state = '',
    icon_preview,
    flags,
  } = data;

  const [searchText, setSearchText] = useState('');
  const hasBase = !!base_type;

  const filteredSpells = spells.filter(
    createSearch(searchText, (spell: SpellEntry) => spell.name),
  );

  return (
    <Window title="Конструктор спеллов" width={720} height={620}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Цель">
              {target_name ? (
                <Box color="good">{target_name}</Box>
              ) : (
                <Box color="bad">Цель недоступна (мертва/удалена)</Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Stack fill>
              <Stack.Item basis="45%">
                <Stack fill vertical>
                  <Stack.Item grow>
                    <Section
                      title="Базовый спелл"
                      fill
                      scrollable
                      buttons={
                        <Input
                          placeholder="Поиск..."
                          width="150px"
                          expensive
                          onChange={setSearchText}
                        />
                      }
                    >
                      <Stack vertical>
                        {filteredSpells.map((spell) => (
                          <Stack.Item key={spell.path}>
                            <Button
                              fluid
                              selected={spell.path === base_type}
                              onClick={() =>
                                act('select_base', { path: spell.path })
                              }
                            >
                              {spell.name}
                            </Button>
                          </Stack.Item>
                        ))}
                      </Stack>
                    </Section>
                  </Stack.Item>

                  <Stack.Item>
                    <Section
                      title={
                        hasBase
                          ? 'Флаги'
                          : 'Флаги (выберите базовый спелл)'
                      }
                    >
                      <Stack vertical>
                        {flags &&
                          (
                            Object.keys(FLAG_LABELS) as (keyof SpellFlags)[]
                          ).map((flagKey) => (
                            <Stack.Item key={flagKey}>
                              <Button.Checkbox
                                fluid
                                disabled={!hasBase}
                                checked={flags[flagKey]}
                                onClick={() =>
                                  act('toggle_flag', { flag: flagKey })
                                }
                              >
                                {FLAG_LABELS[flagKey]}
                              </Button.Checkbox>
                            </Stack.Item>
                          ))}
                      </Stack>
                    </Section>
                  </Stack.Item>

                  <Stack.Item>
                    <Section
                      title={
                        hasBase ? 'Иконка' : 'Иконка (выберите базовый спелл)'
                      }
                    >
                      <Stack>
                        <Stack.Item>
                          <Box
                            width="64px"
                            height="64px"
                            style={{
                              backgroundColor: 'rgba(0, 0, 0, 0.3)',
                              imageRendering: 'pixelated',
                            }}
                          >
                            {icon_preview && (
                              <Image
                                src={`data:image/jpeg;base64,${icon_preview}`}
                                width="64px"
                                height="64px"
                              />
                            )}
                          </Box>
                        </Stack.Item>
                        <Stack.Item grow>
                          <Stack vertical>
                            <Stack.Item>
                              <Input
                                fluid
                                placeholder="icon_state"
                                disabled={!hasBase}
                                value={icon_state}
                                onBlur={(value) =>
                                  act('set_field', {
                                    field: 'icon_state',
                                    value,
                                  })
                                }
                              />
                            </Stack.Item>
                            <Stack.Item>
                              <Button
                                fluid
                                disabled={!hasBase}
                                icon="folder-open"
                                onClick={() => act('pick_icon_file')}
                              >
                                Выбрать файл иконки...
                              </Button>
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                      </Stack>
                    </Section>
                  </Stack.Item>
                </Stack>
              </Stack.Item>

              <Stack.Item grow>
                <Stack fill vertical>
                  <Stack.Item grow>
                    <Section fill title="Параметры спелла">
                      <LabeledList>
                        <LabeledList.Item label="Имя спелла">
                          <Input
                            fluid
                            disabled={!hasBase}
                            value={name}
                            onBlur={(value) =>
                              act('set_field', { field: 'name', value })
                            }
                          />
                        </LabeledList.Item>
                        <LabeledList.Item label="Описание">
                          <TextArea
                            fluid
                            height="80px"
                            disabled={!hasBase}
                            value={desc}
                            onBlur={(value) =>
                              act('set_field', { field: 'desc', value })
                            }
                          />
                        </LabeledList.Item>
                        <LabeledList.Item label="КД спелла (сек)">
                          <NumberInput
                            width="80px"
                            disabled={!hasBase}
                            value={cooldown}
                            minValue={0}
                            maxValue={3600}
                            step={1}
                            onChange={(value) =>
                              act('set_field', {
                                field: 'cooldown',
                                value: `${value}`,
                              })
                            }
                          />
                        </LabeledList.Item>
                        <LabeledList.Item label="Фраза? (Да/Нет)">
                          <Button.Checkbox
                            disabled={!hasBase}
                            checked={has_invocation}
                            onClick={() => act('toggle_invocation')}
                          >
                            {has_invocation ? 'Да' : 'Нет'}
                          </Button.Checkbox>
                        </LabeledList.Item>
                        <LabeledList.Item label="Фраза при использовании">
                          <Input
                            fluid
                            disabled={!hasBase || !has_invocation}
                            value={invocation}
                            onBlur={(value) =>
                              act('set_field', {
                                field: 'invocation',
                                value,
                              })
                            }
                          />
                        </LabeledList.Item>
                      </LabeledList>
                    </Section>
                  </Stack.Item>

                  <Stack.Item>
                    <Button.Confirm
                      fluid
                      height="2.2em"
                      disabled={!hasBase || !target_name}
                      content="Выдать спелл"
                      confirmContent="Точно выдать?"
                      onClick={() => act('give_spell')}
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
