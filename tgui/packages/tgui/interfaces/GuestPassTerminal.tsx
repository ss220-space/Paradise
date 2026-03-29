import { useState } from 'react';
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
} from '../components';
import { Window } from '../layouts';
import { AccessList } from './common/AccessList';

interface GuestPassData {
  mode: number;
  giver_name: string | null;
  giv_name: string;
  reason: string;
  duration: number;
  logs: string[];
  regions: any[];
  selectedAccess: number[];
  grantableList: number[];
}

export const GuestPassTerminal = (props) => {
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
                  content={giver_name || 'Вставьте ID-карту'}
                />
              </Section>
            </Stack.Item>

            <Stack.Item>
              <Section title="Данные пропуска">
                <Stack mb={1}>
                  <Stack.Item grow>
                    <Input
                      fluid
                      placeholder="Имя Фамилия"
                      value={giv_name}
                      onChange={(v) => act('set_name', { value: v })}
                    />
                  </Stack.Item>
                  <Stack.Item width="85px">
                    <NumberInput
                      fluid
                      unit="м"
                      value={duration}
                      minValue={1}
                      maxValue={30}
                      step={1}
                      onChange={(v) => act('set_duration', { value: v })}
                    />
                  </Stack.Item>
                </Stack>
                <Input
                  fluid
                  placeholder="Причина выдачи"
                  value={reason}
                  onChange={(v) => act('set_reason', { value: v })}
                />
              </Section>
            </Stack.Item>

            <Stack.Item height="410px">
              {' '}
              <AccessList
                accesses={regions}
                selectedList={selectedAccess}
                grantableList={grantableList}
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
                color="success"
                icon="print"
                textAlign="center"
                content="ВЫДАТЬ ПРОПУСК"
                disabled={!giver_name}
                onClick={() => act('issue')}
              />
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
