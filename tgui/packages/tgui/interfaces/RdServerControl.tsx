import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { Window } from '../layouts';

const SCREEN_MAIN = 0;
const SCREEN_ACCESS = 1;
const SCREEN_DATA = 2;
const SCREEN_LOGS = 3;

interface Server {
  id: number | string;
  name: string;
}

interface Design {
  id: string;
  name: string;
  blacklisted: boolean;
}

interface Technology {
  id: string;
  name: string;
  level: number;
}

interface Console {
  id: number;
  loc: string;
  upload: number;
  download: number;
}

interface RdData {
  screen: number;
  servers: Server[];
  designs: Design[];
  technologies: Technology[];
  consoles: Console[];
  usage_logs: [string, string, string, string, string][];
  clear_logs: [string, string, string][];
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
    temp_server_name,
  } = data;

  if (screen === SCREEN_MAIN) {
    return (
      <Window width={500} height={400} title="Управление серверами НИО">
        <Window.Content scrollable>
          <Section title="Подключённые серверы">
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
              {servers.length === 0 && 'Серверы не найдены.'}
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
                selected={screen === SCREEN_DATA}
                onClick={() => act('set_screen', { target: SCREEN_DATA })}
              >
                Данные
              </Tabs.Tab>
              <Tabs.Tab
                selected={screen === SCREEN_ACCESS}
                onClick={() => act('set_screen', { target: SCREEN_ACCESS })}
              >
                Доступ
              </Tabs.Tab>
              <Tabs.Tab
                selected={screen === SCREEN_LOGS}
                onClick={() => act('set_screen', { target: SCREEN_LOGS })}
              >
                Логи
              </Tabs.Tab>
              <Tabs.Tab
                onClick={() => act('set_screen', { target: SCREEN_MAIN })}
              >
                Выйти
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {screen === SCREEN_DATA && (
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
                <Section title="Список шаблонов">
                  <Table>
                    <Table.Row header>
                      <Table.Cell>Название шаблона</Table.Cell>
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
            {screen === SCREEN_ACCESS && (
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
            {screen === SCREEN_LOGS && (
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
                  {usage_logs.map((log, i) => (
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
                  {usage_logs.length === 0 && (
                    <Table.Row>
                      <Table.Cell colSpan={3}>Логи пусты.</Table.Cell>
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
