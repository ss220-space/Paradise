import { useBackend } from '../backend';
import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { Window } from '../layouts';
import { AccessList } from './common/AccessList';

const SEX_OPTIONS = ['Мужской', 'Женский'];

export const CustomOutfitID = (props) => {
  const { act, data } = useBackend();
  const [assignmentMode, setAssignmentMode] = useState('dropdown');
  const [customAssignment, setCustomAssignment] = useState('');

  const idCard = data.id_card || {};
  const joblist = Array.isArray(data.joblist) ? data.joblist : [];

  return (
    <Window title="Редактор ID-карты" width={900} height={600} theme="admin">
      <Window.Content>
        <Stack fill>
          <Stack.Item grow={2} basis={0}>
            <Section fill scrollable title="Данные карты">
              <Stack vertical>
                <Stack.Item>
                  <Box color="label" fontSize={0.75} mb={0.5}>
                    Имя на карте
                  </Box>
                  <Input
                    fluid
                    placeholder="Введите имя"
                    value={idCard.name || ''}
                    onChange={(value) => act('set_id_name', { name: value })}
                    onEnter={(value) =>
                      value && act('set_id_name', { name: value })
                    }
                  />
                </Stack.Item>

                <Stack.Item>
                  <Box color="label" fontSize={0.75} mb={0.5}>
                    Должность
                  </Box>
                  <Dropdown
                    fluid
                    options={joblist}
                    selected={
                      assignmentMode === 'custom'
                        ? 'Custom'
                        : idCard.assignment || null
                    }
                    placeholder="Выберите должность или напишите свою"
                    onSelected={(value) => {
                      if (value === 'Custom') {
                        setAssignmentMode('custom');
                        setCustomAssignment(idCard.assignment || '');
                      } else {
                        setAssignmentMode('dropdown');
                        act('set_id_assignment', { assignment: value });
                      }
                    }}
                  />
                  {assignmentMode === 'custom' && (
                    <>
                      <Box color="label" fontSize={0.75} mt={0.5} mb={0.5}>
                        Своя должность
                      </Box>
                      <Input
                        fluid
                        placeholder="Введите должность"
                        value={customAssignment}
                        onChange={setCustomAssignment}
                        onEnter={(value) =>
                          value &&
                          act('set_id_assignment', { assignment: value })
                        }
                        onBlur={(value) =>
                          value &&
                          act('set_id_assignment', { assignment: value })
                        }
                      />
                    </>
                  )}
                </Stack.Item>

                <Stack.Item>
                  <Box color="label" fontSize={0.75} mb={0.5}>
                    Пол
                  </Box>
                  <Dropdown
                    fluid
                    options={SEX_OPTIONS}
                    selected={idCard.sex || null}
                    placeholder="Выберите пол"
                    onSelected={(value) => act('set_id_sex', { sex: value })}
                  />
                </Stack.Item>

                <Stack.Item>
                  <Box color="label" fontSize={0.75} mb={0.5}>
                    Возраст
                  </Box>
                  <NumberInput
                    fluid
                    value={idCard.age ?? 0}
                    minValue={17}
                    maxValue={120}
                    onChange={(value) => act('set_id_age', { age: value })}
                  />
                </Stack.Item>

                <Stack.Item>
                  <Box color="label" fontSize={0.75} mb={0.5}>
                    Группа крови
                  </Box>
                  <Input
                    fluid
                    placeholder="Например: A+"
                    value={idCard.blood_type || ''}
                    onChange={(value) =>
                      act('set_id_blood_type', { blood_type: value })
                    }
                    onEnter={(value) =>
                      value && act('set_id_blood_type', { blood_type: value })
                    }
                  />
                </Stack.Item>

                <Stack.Item>
                  <Box color="label" fontSize={0.75} mb={0.5}>
                    ДНК-хеш
                  </Box>
                  <Input
                    fluid
                    placeholder="ДНК-хеш"
                    value={idCard.dna_hash || ''}
                    onChange={(value) =>
                      act('set_id_dna_hash', { dna_hash: value })
                    }
                    onEnter={(value) =>
                      value && act('set_id_dna_hash', { dna_hash: value })
                    }
                  />
                </Stack.Item>

                <Stack.Item>
                  <Box color="label" fontSize={0.75} mb={0.5}>
                    Отпечатки пальцев
                  </Box>
                  <Input
                    fluid
                    placeholder="Хеш отпечатков"
                    value={idCard.fingerprint_hash || ''}
                    onChange={(value) =>
                      act('set_id_fingerprint_hash', {
                        fingerprint_hash: value,
                      })
                    }
                    onEnter={(value) =>
                      value &&
                      act('set_id_fingerprint_hash', {
                        fingerprint_hash: value,
                      })
                    }
                  />
                </Stack.Item>

                <Stack.Item>
                  <Box color="label" fontSize={0.75} mb={0.5}>
                    Номер счёта
                  </Box>
                  <NumberInput
                    fluid
                    value={idCard.associated_account_number ?? 0}
                    minValue={0}
                    onChange={(value) =>
                      act('set_id_account', { account: value })
                    }
                  />
                </Stack.Item>

                <Stack.Item>
                  <Box color="label" fontSize={0.75} mb={0.5}>
                    Шахтёрские очки
                  </Box>
                  <NumberInput
                    fluid
                    value={idCard.mining_points ?? 0}
                    minValue={0}
                    onChange={(value) =>
                      act('set_id_mining_points', { mining_points: value })
                    }
                  />
                </Stack.Item>

                <Stack.Item>
                  <Button.Checkbox
                    fluid
                    checked={!!idCard.untrackable}
                    onClick={() =>
                      act('set_id_untrackable', {
                        untrackable: !idCard.untrackable ? 1 : 0,
                      })
                    }
                  >
                    Не отслеживается ИИ
                  </Button.Checkbox>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item grow={3} basis={0}>
            <AccessList
              accesses={data.access_regions || []}
              selectedList={idCard.access || []}
              accessMod={(ref) => act('toggle_id_access', { access: ref })}
              grantAll={() => act('grant_id_all_access')}
              denyAll={() => act('clear_id_access')}
              grantDep={(ref) => act('grant_region_access', { region: ref })}
              denyDep={(ref) => act('clear_region_access', { region: ref })}
            />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
