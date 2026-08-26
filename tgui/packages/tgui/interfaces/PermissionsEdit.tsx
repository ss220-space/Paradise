import React, { useState } from 'react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dropdown,
  Input,
  Section,
  Stack,
  Table,
} from '../components';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';
import { SortButton } from './common/SortButtons';
import { createSearch } from 'common/string';

const noneSelect = '*none*';

const FlagSelector = ({ flags, selectedFlags, onFlagToggle }) => {
  return (
    <Box>
      {Object.keys(flags).map((flag) => (
        <Box key={flag}>
          <label>
            <input
              type="checkbox"
              checked={selectedFlags.includes(flag)}
              onChange={(e) => onFlagToggle(flag, selectedFlags.includes(flag))}
            />
            {flag}
          </label>
        </Box>
      ))}
    </Box>
  );
};

const PresetSelector = ({ ckey, possible_ranks }) => {
  const { act } = useBackend();
  const [preset, setPreset] = useState(noneSelect);
  return (
    <>
      <Dropdown
        options={Object.keys(possible_ranks)}
        selected={preset}
        onSelected={(preset) => {
          setPreset(preset);
        }}
      />
      <Button
        width="100%"
        mt={0.5}
        onClick={() =>
          act('load_preset', { selected_ckey: ckey, selected_preset: preset })
        }
      >
        Загрузить пресет
      </Button>
    </>
  );
};

type PermissionsEditData = {
  possible_permissions: string[];
  possible_ranks: string[];
  possible_presets: string[];
  admins: Admin[];
};

type Admin = {
  ckey: string;
  rank?: string;
  flags?: Record<string, string>[];
  de_admin: BooleanLike;
};

export const PermissionsEdit = (_props: unknown) => {
  const { act, data } = useBackend<PermissionsEditData>();
  const { possible_permissions, possible_ranks, admins } = data;
  const [searchText, setSearchText] = useState('');
  const [sortId, setSortId] = useState('target_name');
  const [sortOrder, setSortOrder] = useState(true);

  const [newAdminCkey, setNewAdminCkey] = useState<string>(null);
  const [newAdminRank, setNewAdminRank] = useState(noneSelect);
  const [newAdminPreset, setNewAdminPreset] = useState(noneSelect);

  return (
    <Window title="Permissions Edit" width={900} height={800} theme="ntos">
      <Window.Content>
        <Section
          title="Редактирование прав"
          fill
          scrollable
          height="85%"
          buttons={
            <Stack fill>
              <Input
                placeholder="Искать..."
                width="300px"
                expensive
                onChange={setSearchText}
              />
            </Stack>
          }
        >
          <Table
            style={{
              borderCollapse: 'separate',
              borderSpacing: '0 5px',
            }}
            className="PermissionsEdit__list"
          >
            <Table.Row bold>
              <SortButton
                id="ckey"
                sortId={sortId}
                setSortId={setSortId}
                sortOrder={sortOrder}
                setSortOrder={setSortOrder}
              >
                Ckey
              </SortButton>
              <SortButton
                id="rank"
                sortId={sortId}
                setSortId={setSortId}
                sortOrder={sortOrder}
                setSortOrder={setSortOrder}
              >
                Ранг
              </SortButton>
              <SortButton
                sortId={'none'}
                setSortId={setSortId}
                sortOrder={sortOrder}
                setSortOrder={setSortOrder}
              >
                Флаги
              </SortButton>
              <SortButton
                sortId={'none'}
                setSortId={setSortId}
                sortOrder={sortOrder}
                setSortOrder={setSortOrder}
              >
                Пресеты
              </SortButton>
              <SortButton
                sortId={'none'}
                setSortId={setSortId}
                sortOrder={sortOrder}
                setSortOrder={setSortOrder}
              >
                Опции
              </SortButton>
            </Table.Row>
            {admins
              .filter(
                createSearch(searchText, ({ ckey, rank }) => {
                  return ckey + '|' + rank;
                })
              )
              .sort((a, b) => {
                const i = sortOrder ? 1 : -1;
                if (a[sortId] === undefined || a[sortId] === null) {
                  return i;
                }
                if (b[sortId] === undefined || b[sortId] === null) {
                  return -1 * i;
                }
                if (typeof a[sortId] === 'number') {
                  return (a[sortId] - b[sortId]) * i;
                }
                let firstValue = a[sortId];
                let secondValue = b[sortId];
                return firstValue.localeCompare(secondValue) * i;
              })
              .map((admin, index) => {
                return (
                  <Table.Row key={index}>
                    <Table.Cell>{admin.ckey}</Table.Cell>
                    <Table.Cell>
                      <Dropdown
                        options={Object.keys(possible_ranks)}
                        selected={admin.rank || noneSelect}
                        onSelected={(rank) => {
                          act('edit_rank', {
                            ckey: admin.ckey,
                            rank: rank,
                          });
                        }}
                      />
                    </Table.Cell>
                    <Table.Cell>
                      {!admin.de_admin && (
                        <FlagSelector
                          flags={possible_permissions}
                          selectedFlags={admin.flags}
                          onFlagToggle={(flag, exist) => {
                            if (!exist) {
                              act('add_flag', {
                                selected_flag: flag,
                                ckey: admin.ckey,
                              });
                              return;
                            }
                            act('remove_flag', {
                              selected_flag: flag,
                              ckey: admin.ckey,
                            });
                          }}
                        />
                      )}
                    </Table.Cell>
                    <Table.Cell>
                      {!admin.de_admin && (
                        <PresetSelector
                          ckey={admin.ckey}
                          possible_ranks={possible_ranks}
                        />
                      )}
                    </Table.Cell>
                    <Table.Cell>
                      {admin.de_admin ? (
                        <Button
                          width="100%"
                          mt={0.5}
                          onClick={() =>
                            act('force_re_admin', { ckey: admin.ckey })
                          }
                        >
                          Принудительный re admin
                        </Button>
                      ) : (
                        <Button
                          width="100%"
                          mt={0.5}
                          onClick={() =>
                            act('force_de_admin', { ckey: admin.ckey })
                          }
                        >
                          Принудительный de admin
                        </Button>
                      )}
                      <Button.Confirm
                        icon="trash"
                        onClick={() => {
                          act('remove_admin', { ckey: admin.ckey });
                        }}
                      />
                    </Table.Cell>
                  </Table.Row>
                );
              })}
          </Table>
        </Section>
        <Section title="Создание нового админа" fill height="10%">
          <Stack>
            <Stack.Item>Сикей: </Stack.Item>
            <Stack.Item>
              <Input
                expensive
                placeholder="Ckey"
                value={newAdminCkey}
                onChange={(value) => setNewAdminCkey(value)}
              />
            </Stack.Item>
            <Stack.Item>Ранг: </Stack.Item>
            <Stack.Item>
              <Dropdown
                options={Object.keys(possible_ranks)}
                selected={newAdminRank}
                onSelected={(selected) => {
                  setNewAdminRank(selected);
                }}
                style={{ display: 'inline' }}
              />
            </Stack.Item>
            <Stack.Item>Прессет: </Stack.Item>
            <Stack.Item>
              <Dropdown
                options={Object.keys(possible_ranks)}
                selected={newAdminPreset}
                onSelected={(selected) => {
                  setNewAdminPreset(selected);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                disabled={
                  !newAdminCkey || !newAdminRank || newAdminRank === noneSelect
                }
                onClick={() =>
                  act('create_new_admin', {
                    ckey: newAdminCkey,
                    rank: newAdminRank,
                    preset: newAdminPreset,
                  })
                }
              >
                Создать
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
