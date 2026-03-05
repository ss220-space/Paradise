import { useState } from 'react';
import { useBackend } from '../backend';
import {
  Button,
  Section,
  Stack,
  Table,
  Tabs,
  LabeledList,
  Box,
} from '../components';
import { Window } from '../layouts';

interface RdData {
  screen: number;
  servers: any[];
  designs: any[];
  technologies: any[];
  consoles: any[];
  usage_logs: any[][];
  clear_logs: any[][];
  temp_server_name: string;
}

export const RdServerControl = (props) => {
  const { act, data } = useBackend<RdData>();
  const {
    screen,
    servers = [],
    designs = [],
    technologies = [],
    consoles = [],
    usage_logs = [],
    clear_logs = [],
    temp_server_name,
  } = data;

  if (screen === 0) {
    return (
      <Window width={500} height={400} title="Управление серверами НИО">
        <Window.Content scrollable>
          <Section title="Подключённые сервера">
            <Stack vertical>
              {servers.map((s) => (
                <Stack.Item key={s.id}>
                  <Button
                    fluid
                    icon="server"
                    content={s.name}
                    onClick={() => act('select_server', { id: s.id })}
                  />
                </Stack.Item>
              ))}
              {servers.length === 0 && 'Сервера не найдены.'}
            </Stack>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window width={700} height={600} title={`Управление: ${temp_server_name}`}>
      <Window.Content scrollable>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={screen === 2}
                onClick={() => act('set_screen', { target: 2 })}
              >
                Данные
              </Tabs.Tab>
              <Tabs.Tab
                selected={screen === 1}
                onClick={() => act('set_screen', { target: 1 })}
              >
                Доступ
              </Tabs.Tab>
              <Tabs.Tab
                selected={screen === 3}
                onClick={() => act('set_screen', { target: 3 })}
              >
                Логи
              </Tabs.Tab>
              <Tabs.Tab onClick={() => act('set_screen', { target: 0 })}>
                Выйти
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {screen === 2 && (
              <Box>
                <Section title="Изученные технологии">
                  <LabeledList>
                    {technologies.map((t) => (
                      <LabeledList.Item key={t.id} label={t.name}>
                        Ур. {t.level}{' '}
                        <Button
                          color="danger"
                          content="Сброс"
                          onClick={() => act('reset_tech', { tech_id: t.id })}
                        />
                      </LabeledList.Item>
                    ))}
                  </LabeledList>
                </Section>
                <Section title="Список дизайнов">
                  <Table>
                    <Table.Row header>
                      <Table.Cell>Название дизайна</Table.Cell>
                      <Table.Cell collapsing>Статус</Table.Cell>
                    </Table.Row>
                    {designs.map((d) => (
                      <Table.Row key={d.id}>
                        <Table.Cell>{d.name}</Table.Cell>
                        <Table.Cell collapsing>
                          <Button
                            icon={d.blacklisted ? 'lock' : 'unlock'}
                            color={d.blacklisted ? 'danger' : 'default'}
                            content={
                              d.blacklisted ? 'Заблокирован' : 'Разрешён'
                            }
                            onClick={() =>
                              act('toggle_blacklist', { design_id: d.id })
                            }
                          />
                        </Table.Cell>
                      </Table.Row>
                    ))}
                  </Table>
                </Section>
              </Box>
            )}
            {screen === 1 && (
              <Section title="Настройка доступа консолей НИО">
                <Table>
                  <Table.Row header>
                    <Table.Cell>Локация</Table.Cell>
                    <Table.Cell collapsing textAlign="center">
                      Разрешения
                    </Table.Cell>
                  </Table.Row>
                  {consoles.map((c) => (
                    <Table.Row key={c.id}>
                      <Table.Cell>
                        {c.loc} (ID: {c.id})
                      </Table.Cell>
                      <Table.Cell collapsing>
                        <Button
                          color={c.upload === 1 ? 'green' : 'danger'}
                          content="Загрузка"
                          onClick={() =>
                            act('toggle_access', {
                              console_id: c.id,
                              type: 'upload',
                            })
                          }
                        />
                        <Button
                          color={c.download === 1 ? 'green' : 'danger'}
                          content="Выгрузка"
                          onClick={() =>
                            act('toggle_access', {
                              console_id: c.id,
                              type: 'download',
                            })
                          }
                        />
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
                {consoles.length === 0 && (
                  <Box mt={1} textAlign="center" color="label">
                    Активные консоли не обнаружены.
                  </Box>
                )}
              </Section>
            )}
            {screen === 3 && (
              <Section
                title="Логи печати"
                buttons={
                  <Button
                    color="danger"
                    icon="trash"
                    content="Удалить все записи"
                    onClick={() => act('clear_logs')}
                  />
                }
              >
                <Table>
                  <Table.Row header>
                    <Table.Cell>Время</Table.Cell>
                    <Table.Cell>Пользователь</Table.Cell>
                    <Table.Cell>Действие</Table.Cell>
                  </Table.Row>
                  {usage_logs &&
                    usage_logs.map((log, i) => (
                      <Table.Row key={i}>
                        <Table.Cell collapsing color="label">
                          {log[0]}
                        </Table.Cell>
                        <Table.Cell collapsing>
                          {log[1]} ({log[2]})
                        </Table.Cell>
                        <Table.Cell>
                          Напечатал {log[3]} через {log[4]}
                        </Table.Cell>
                      </Table.Row>
                    ))}
                  {(!usage_logs || usage_logs.length === 0) && (
                    <Table.Row>
                      <Table.Cell colSpan={3}>Logs are empty.</Table.Cell>
                    </Table.Row>
                  )}
                </Table>
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
