import { useBackend } from '../backend';
import {
  Button,
  Section,
  Stack,
  Input,
  NumberInput,
  Box,
  Tabs,
  Icon,
  LabeledList,
  TextArea,
} from '../components';
import { Window } from '../layouts';
import { AccessList, Access } from './common/AccessList';

interface GuestPassData {
  mode: number;
  giver_name: string | null;
  giv_name: string;
  reason: string;
  duration: number;
  logs: string[];
  // Используем импортированный тип Access вместо своего AccessRegion
  regions: Access[];
  selectedAccess: number[];
  grantableList: number[];
}
export const GuestPassTerminal = () => {
  const { act, data } = useBackend<GuestPassData>();
  const {
    mode,
    giver_name,
    giv_name,
    reason,
    duration,
    logs = [],
    regions = [],
    selectedAccess = [],
    grantableList = [],
  } = data;

  const effectiveGrantableList: number[] =
    giver_name && grantableList.length === 0 ? [-1] : grantableList;

  return (
    <Window width={600} height={700} title="Терминал временных пропусков">
      <Window.Content scrollable>
        <Tabs>
          <Tabs.Tab
            selected={mode === 0}
            onClick={() => act('set_mode', { mode: 0 })}
          >
            Выдача
          </Tabs.Tab>
          <Tabs.Tab
            selected={mode === 1}
            onClick={() => act('set_mode', { mode: 1 })}
          >
            Логи ({logs.length})
          </Tabs.Tab>
        </Tabs>

        {mode === 0 ? (
          <Stack vertical>
            <Stack.Item>
              <Section title="ID Карта">
                <Button
                  fluid
                  icon="id-card"
                  color={giver_name ? 'green' : 'default'}
                  onClick={() => act('eject_id')}
                >
                  {giver_name || 'Вставьте ID-карту'}
                </Button>
              </Section>
            </Stack.Item>

            <Stack.Item>
              <Section title="Данные пропуска">
                <Stack vertical>
                  <Stack.Item>
                    <Stack align="center">
                      <Stack.Item width="90px" color="label">
                        Кому выдан:
                      </Stack.Item>
                      <Stack.Item width="300px">
                        <TextArea
                          fluid
                          height="22px"
                          placeholder="Имя Фамилия"
                          value={giv_name}
                          onChange={(v) => act('set_name', { value: v })}
                          style={{ resize: 'none' }}
                        />
                      </Stack.Item>
                      <Stack.Item grow textAlign="right">
                        <Stack align="center" justify="flex-end">
                          <Box color="label" mr={1}>
                            Время:
                          </Box>
                          <NumberInput
                            width="70px"
                            unit="м"
                            value={duration}
                            minValue={1}
                            maxValue={30}
                            step={1}
                            onChange={(v) => act('set_duration', { value: v })}
                          />
                        </Stack>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>

                  <Stack.Item mt={1}>
                    <Stack align="center">
                      <Stack.Item width="90px" color="label">
                        Причина:
                      </Stack.Item>
                      <Stack.Item width="300px">
                        <TextArea
                          fluid
                          height="22px"
                          placeholder="Причина выдачи пропуска"
                          value={reason}
                          onChange={(v) => act('set_reason', { value: v })}
                          style={{ resize: 'none' }}
                        />
                      </Stack.Item>
                      <Stack.Item grow />
                    </Stack>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
            <Stack.Item height="410px">
              <AccessList
                accesses={regions}
                selectedList={selectedAccess}
                grantableList={effectiveGrantableList} // ИСПОЛЬЗУЕМ ТУТ
                accessMod={(ref) => act('toggle_access', { id: ref })}
                grantAll={() => act('grant_all')}
                denyAll={() => act('deny_all')}
                grantDep={(regid) => act('grant_region', { region: regid })}
                denyDep={(regid) => act('deny_region', { region: regid })}
              />
            </Stack.Item>
            <Stack.Item mt={1}>
              <Button
                fluid
                bold
                color="green"
                icon="print"
                textAlign="center"
                disabled={!giver_name}
                onClick={() => act('issue')}
              >
                ВЫДАТЬ ПРОПУСК
              </Button>
            </Stack.Item>
          </Stack>
        ) : (
          <Section title="История активности">
            {logs.length === 0 ? (
              <Box color="label">Логи пусты</Box>
            ) : (
              logs.map((log, i) => (
                <Box
                  key={i}
                  py={1}
                  style={{ borderBottom: '1px solid #333', fontSize: '11px' }}
                >
                  {log}
                </Box>
              ))
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
