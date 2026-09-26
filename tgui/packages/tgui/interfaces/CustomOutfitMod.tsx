import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type IconEntry = {
  path: string;
  name?: string;
};

type PathOption = {
  label: string;
  path: string;
};

type PartEntry = {
  name: string;
  path: string;
};

type ModData = {
  active?: BooleanLike;
  module_info?: IconEntry[];
  available_modules?: PathOption[];
  part_info?: PartEntry[];
  deployed_parts?: string[];
};

export const CustomOutfitMod = () => {
  const { act, data } = useBackend<ModData>();
  const [search, setSearch] = useState('');

  const installed = Array.isArray(data.module_info) ? data.module_info : [];
  const partInfo = Array.isArray(data.part_info) ? data.part_info : [];
  const deployedParts = Array.isArray(data.deployed_parts)
    ? data.deployed_parts
    : [];
  const available = (
    Array.isArray(data.available_modules) ? data.available_modules : []
  ).filter((option) =>
    search ? option.label.toLowerCase().includes(search.toLowerCase()) : true,
  );

  return (
    <Window title="MOD" width={900} height={700} theme="admin">
      <Window.Content>
        <Stack fill>
          <Stack.Item grow={1} basis={0}>
            <Stack fill>
              <Stack.Item grow={1} basis={0}>
                <Stack fill vertical>
                  <Stack.Item grow={2} basis={0} style={{ minHeight: 0 }}>
                    <Section fill scrollable title="Установленные модули">
                      {installed.length === 0 ? (
                        <Box color="gray" textAlign="center" p="1em">
                          Модули не установлены
                        </Box>
                      ) : (
                        <Stack vertical>
                          {installed.map((module) => (
                            <Stack.Item key={module.path} mb={0.5}>
                              <Stack align="center">
                                <Stack.Item grow={1}>
                                  <Box fontSize={0.9}>{module.name}</Box>
                                </Stack.Item>
                                <Stack.Item>
                                  <Button
                                    icon="trash"
                                    tooltip="Удалить модуль"
                                    onClick={() =>
                                      act('remove_module', {
                                        path: module.path,
                                      })
                                    }
                                  />
                                </Stack.Item>
                              </Stack>
                            </Stack.Item>
                          ))}
                        </Stack>
                      )}
                    </Section>
                  </Stack.Item>

                    <Stack.Item grow={1} basis={0} style={{ minHeight: 0 }}>
                      <Section
                        fill
                        scrollable
                        title="Элементы костюма"
                        buttons={
                          <Button
                            icon="power-off"
                            content={
                              data.active
                                ? 'Будет включён'
                                : 'Будет выключен'
                            }
                            selected={!!data.active}
                            onClick={() => act('toggle_active')}
                          />
                        }
                      >
                        <Stack>
                          <Stack.Item grow>
                            <Button
                              fluid
                              icon="arrow-up"
                              content="Развернуть все"
                              onClick={() => act('deploy_all_parts')}
                            />
                          </Stack.Item>
                          <Stack.Item grow>
                            <Button
                              fluid
                              icon="arrow-down"
                              content="Свернуть все"
                              onClick={() => act('retract_all_parts')}
                            />
                          </Stack.Item>
                        </Stack>
                        <Stack vertical mt={0.5}>
                          {partInfo.length === 0 ? (
                            <Box color="gray" textAlign="center" p="1em">
                              Нет элементов
                            </Box>
                          ) : (
                            partInfo.map((part) => (
                              <Stack.Item key={part.path}>
                                <Button.Checkbox
                                  fluid
                                  checked={deployedParts.includes(part.path)}
                                  onClick={() =>
                                    act('toggle_part', { path: part.path })
                                  }
                                >
                                  {part.name}
                                </Button.Checkbox>
                              </Stack.Item>
                            ))
                          )}
                        </Stack>
                      </Section>
                    </Stack.Item>
                  </Stack>
              </Stack.Item>

              <Stack.Item grow={1} basis={0}>
                <Section fill scrollable title="Доступные модули">
                  <Stack vertical mb={0.5}>
                    <Stack.Item>
                      <Input
                        fluid
                        value={search}
                        placeholder="Поиск..."
                        onChange={(value) => setSearch(value)}
                      />
                    </Stack.Item>
                  </Stack>
                  <Stack vertical>
                    {available.map((option) => (
                      <Stack.Item key={option.path} mb={0.5}>
                        <Button
                          fluid
                          icon="plus"
                          content={option.label.split(' (')[0]}
                          onClick={() =>
                            act('add_module', { path: option.path })
                          }
                        />
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
