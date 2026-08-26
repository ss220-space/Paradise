import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  Box,
  Section,
  Table,
  Tabs,
  Stack,
  Icon,
  Dropdown,
} from '../components';
import { Window } from '../layouts';
import { Access, AccessList } from './common/AccessList';
import { COLORS, JOBS_RU } from '../constants';
import { ReactNode } from 'react';

const deptCols = COLORS.department;

export const CardComputerLoginWarning = () => (
  <Section fill title="Предупреждение">
    <Stack fill>
      <Stack.Item
        bold
        grow
        textAlign="center"
        fontSize={1.75}
        align="center"
        color="label"
      >
        <Icon.Stack style={{ transform: 'translate(-50px, -100px)' }}>
          <Icon name="user" size={5} color="gray" />
          <Icon
            name="slash"
            size={5}
            color="red"
            style={{ transform: 'translate(-15px, 0)' }}
          />
        </Icon.Stack>
        <br />
        Пользователь не авторизован
      </Stack.Item>
    </Stack>
  </Section>
);

export const CardComputerNoCard = () => (
  <Section fill title="Предупреждение">
    <Stack fill>
      <Stack.Item
        bold
        grow
        textAlign="center"
        fontSize={1.75}
        align="center"
        color="label"
      >
        <Icon.Stack style={{ transform: 'translate(-50px, -100px)' }}>
          <Icon name="id-card" size={5} color="gray" />
          <Icon
            name="slash"
            size={5}
            color="red"
            style={{ transform: 'translate(-5px, 0)' }}
          />
        </Icon.Stack>
        <br />
        ID-карта для модификации отсутствует
      </Stack.Item>
    </Stack>
  </Section>
);

export const CardComputerNoRecords = () => (
  <Section fill title="Просмотр записей">
    <Stack fill>
      <Stack.Item
        bold
        grow
        textAlign="center"
        fontSize={1.75}
        align="center"
        color="label"
      >
        <Icon.Stack>
          <Icon name="scroll" size={5} color="gray" />
          <Icon name="slash" size={5} color="red" />
        </Icon.Stack>
        <br />
        Записи отсутствуют
      </Stack.Item>
    </Stack>
  </Section>
);

type CardComputerData = {
  mode: number;
  target_dept: boolean;
  scan_name: string;
  modify_name: string;
  modify_owner: string;
  authenticated: boolean;
  account_number: string;
  modify_lastlog: string;
  modify_rank: string;
  jobs_dept: string[];
  jobFormats: Record<string, string>;
  jobs_top: string[];
  jobs_engineering: string[];
  jobs_medical: string[];
  jobs_science: string[];
  jobs_security: string[];
  jobs_service: string[];
  jobs_karma: string[];
  jobs_supply: string[];
  jobs_civilian: string[];
  iscentcom: boolean;
  jobs_centcom: string[];
  modify_assignment: string;
  canterminate: boolean;
  card_skins: Skin[];
  current_skin: string;
  all_centcom_skins: Skin[];
  auth_or_ghost: boolean;
  cooldown_time: string;
  job_slots: JobSlot[];
  priority_jobs: string[];
  regions: Access[];
  selectedAccess: number[];
  records: JobRecord[];
  people_dept: DepRecord[];
  law_levels: Record<string, number>;
  possible_law_levels: string[];
  law_level: number;
};

type Skin = {
  skin: string;
  display_name: string;
};

type JobSlot = {
  title: string;
  is_priority: boolean;
  current_positions: number;
  total_positions: number;
  can_close: boolean;
  can_open: boolean;
  can_prioritize: boolean;
};

type JobRecord = {
  timestamp: string;
  transferee: string;
  oldvalue: string;
  newvalue: string;
  whodidit: string;
  reason: string;
  deletedby: string;
};

type DepRecord = {
  name: string;
  title: string;
  crimstat: string;
  buttontext: string;
  demotable: boolean;
};

export const CardComputer = (props: unknown) => {
  const { act, data } = useBackend<CardComputerData>();

  let menuBlock = (
    <Tabs>
      <Tabs.Tab
        icon="id-card"
        selected={data.mode === 0}
        onClick={() => act('mode', { mode: 0 })}
      >
        Смена должности
      </Tabs.Tab>
      {!data.target_dept && (
        <Tabs.Tab
          icon="id-card"
          selected={data.mode === 2}
          onClick={() => act('mode', { mode: 2 })}
        >
          Модификация доступа
        </Tabs.Tab>
      )}
      <Tabs.Tab
        icon="folder-open"
        selected={data.mode === 1}
        onClick={() => act('mode', { mode: 1 })}
      >
        Управление вакансиями
      </Tabs.Tab>
      <Tabs.Tab
        icon="scroll"
        selected={data.mode === 3}
        onClick={() => act('mode', { mode: 3 })}
      >
        Логи
      </Tabs.Tab>
      <Tabs.Tab
        icon="users"
        selected={data.mode === 4}
        onClick={() => act('mode', { mode: 4 })}
      >
        Управление отделом
      </Tabs.Tab>
    </Tabs>
  );

  let authBlock = (
    <Section title="Авторизация">
      <LabeledList>
        <LabeledList.Item label="Карта для авторизации">
          <Button
            icon={data.scan_name ? 'sign-out-alt' : 'id-card'}
            selected={!!data.scan_name}
            onClick={() => act('scan')}
          >
            {data.scan_name ? 'Извлечь и выйти: ' + data.scan_name : '-----'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Карта для модификации">
          <Button
            icon={data.modify_name ? 'eject' : 'id-card'}
            selected={!!data.modify_name}
            onClick={() => act('modify')}
          >
            {data.modify_name ? 'Извлечь: ' + data.modify_name : '-----'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );

  let bodyBlock: ReactNode;

  switch (data.mode) {
    case 0: // job transfer
      if (!data.authenticated || !data.scan_name) {
        bodyBlock = <CardComputerLoginWarning />;
      } else if (!data.modify_name) {
        bodyBlock = <CardComputerNoCard />;
      } else {
        bodyBlock = (
          <>
            <Section title="Информация на карте">
              {!data.target_dept && (
                <>
                  <LabeledList.Item label="Имя сотрудника">
                    <Button
                      icon={
                        !data.modify_owner || data.modify_owner === 'НЕ ЗАДАНО'
                          ? 'exclamation-triangle'
                          : 'pencil-alt'
                      }
                      selected={!!data.modify_name}
                      onClick={() => act('reg')}
                    >
                      {data.modify_owner}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Номер счёта">
                    <Button
                      icon={
                        data.account_number
                          ? 'pencil-alt'
                          : 'exclamation-triangle'
                      }
                      selected={!!data.account_number}
                      onClick={() => act('account')}
                    >
                      {data.account_number ? data.account_number : 'НЕ ЗАДАНО'}
                    </Button>
                  </LabeledList.Item>
                </>
              )}
              <LabeledList.Item label="Последняя запись">
                {data.modify_lastlog || '---'}
              </LabeledList.Item>
            </Section>
            <Section
              title={
                data.target_dept
                  ? 'Выбор должности в отделе'
                  : 'Выбор должности'
              }
            >
              <LabeledList>
                {data.target_dept ? (
                  <LabeledList.Item label="Отдел">
                    {data.jobs_dept.map((v) => (
                      <Button
                        selected={data.modify_rank === v}
                        key={v}
                        color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                        onClick={() => act('assign', { assign_target: v })}
                      >
                        {JOBS_RU[v] ? JOBS_RU[v] : v}
                      </Button>
                    ))}
                  </LabeledList.Item>
                ) : (
                  <>
                    <LabeledList.Item label="Особые">
                      {data.jobs_top.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          key={v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {JOBS_RU[v] ? JOBS_RU[v] : v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Инженерия"
                      labelColor={deptCols.engineering}
                    >
                      {data.jobs_engineering.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          key={v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {JOBS_RU[v] ? JOBS_RU[v] : v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Медицина"
                      labelColor={deptCols.medical}
                    >
                      {data.jobs_medical.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          key={v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {JOBS_RU[v] ? JOBS_RU[v] : v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Наука"
                      labelColor={deptCols.science}
                    >
                      {data.jobs_science.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          key={v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {JOBS_RU[v] ? JOBS_RU[v] : v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Безопасность"
                      labelColor={deptCols.security}
                    >
                      {data.jobs_security.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          key={v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {JOBS_RU[v] ? JOBS_RU[v] : v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Обслуживание"
                      labelColor={deptCols.service}
                    >
                      {data.jobs_service.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          key={v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {JOBS_RU[v] ? JOBS_RU[v] : v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Снабжение"
                      labelColor={deptCols.supply}
                    >
                      {data.jobs_supply.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          key={v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {JOBS_RU[v] ? JOBS_RU[v] : v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Ограниченные"
                      labelColor={deptCols.procedure}
                    >
                      {data.jobs_karma.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          key={v}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {JOBS_RU[v] ? JOBS_RU[v] : v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                  </>
                )}
                <LabeledList.Item label="Гражданские">
                  {data.jobs_civilian.map((v) => (
                    <Button
                      selected={data.modify_rank === v}
                      key={v}
                      color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                      onClick={() => act('assign', { assign_target: v })}
                    >
                      {JOBS_RU[v] ? JOBS_RU[v] : v}
                    </Button>
                  ))}
                </LabeledList.Item>
                {!!data.iscentcom && (
                  <LabeledList.Item
                    label="ЦентКом"
                    labelColor={deptCols.centcom}
                  >
                    {data.jobs_centcom.map((v) => (
                      <Button
                        selected={data.modify_rank === v}
                        key={v}
                        color={
                          data.jobFormats[v] ? data.jobFormats[v] : 'purple'
                        }
                        onClick={() => act('assign', { assign_target: v })}
                      >
                        {JOBS_RU[v] ? JOBS_RU[v] : v}
                      </Button>
                    ))}
                  </LabeledList.Item>
                )}
                <LabeledList.Item label="Разжалование">
                  <Button
                    disabled={data.modify_assignment === 'Разжалован'}
                    key="Demoted"
                    tooltip="Минимальный доступ, должность 'Разжалован'."
                    color="red"
                    icon="times"
                    onClick={() => act('demote')}
                  >
                    Понизить
                  </Button>
                </LabeledList.Item>
                {!!data.canterminate && (
                  <LabeledList.Item label="Увольнение">
                    <Button
                      disabled={
                        data.modify_assignment === 'Контракт расторгнут'
                      }
                      key="Terminate"
                      tooltip="Увольнение и расторжения трудового контракта. Сотрудик лишится всех уровней доступа и перестанет быть членом экипажа."
                      color="red"
                      icon="eraser"
                      onClick={() => act('terminate')}
                    >
                      Уволить
                    </Button>
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Section>
            {!data.target_dept && (
              <Section title="Внешний вид карты">
                {data.card_skins.map((v) => (
                  <Button
                    selected={data.current_skin === v.skin}
                    key={v.skin}
                    onClick={() => act('skin', { skin_target: v.skin })}
                  >
                    {v.display_name}
                  </Button>
                ))}
                {!!data.iscentcom && (
                  <Box>
                    {data.all_centcom_skins.map((v) => (
                      <Button
                        selected={data.current_skin === v.skin}
                        key={v.skin}
                        color="purple"
                        onClick={() => act('skin', { skin_target: v.skin })}
                      >
                        {v.display_name}
                      </Button>
                    ))}
                  </Box>
                )}
              </Section>
            )}
          </>
        );
      }
      break;
    case 1: // job slot management
      if (!data.auth_or_ghost) {
        bodyBlock = <CardComputerLoginWarning />;
      } else {
        bodyBlock = (
          <Stack fill vertical>
            <Section color={data.cooldown_time ? 'red' : ''}>
              Следующее изменение доступно:
              {data.cooldown_time ? data.cooldown_time : 'Сейчас'}
            </Section>
            <Section fill scrollable title="Рабочие позиции">
              <Table>
                <Table.Row height={2}>
                  <Table.Cell bold textAlign="center">
                    Название
                  </Table.Cell>
                  <Table.Cell bold textAlign="center">
                    Занято позиций
                  </Table.Cell>
                  <Table.Cell bold textAlign="center">
                    Всего позиций
                  </Table.Cell>
                  <Table.Cell bold textAlign="center">
                    Открытые позиции
                  </Table.Cell>
                  <Table.Cell bold textAlign="center">
                    Закрыть позицию
                  </Table.Cell>
                  <Table.Cell bold textAlign="center">
                    Открыть позицию
                  </Table.Cell>
                  <Table.Cell bold textAlign="center">
                    Приоритет
                  </Table.Cell>
                </Table.Row>
                {data.job_slots.map((slotData) => (
                  <Table.Row
                    key={slotData.title}
                    height={2}
                    className="candystripe"
                  >
                    <Table.Cell textAlign="center">
                      <Box color={slotData.is_priority ? 'green' : ''}>
                        {JOBS_RU[slotData.title]
                          ? JOBS_RU[slotData.title]
                          : slotData.title}
                      </Box>
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      {slotData.current_positions}
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      {slotData.total_positions}
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      {(slotData.total_positions >
                        slotData.current_positions && (
                        <Box color="green">
                          {slotData.total_positions -
                            slotData.current_positions}
                        </Box>
                      )) || <Box color="red">0</Box>}
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      <Button
                        disabled={!!data.cooldown_time || !slotData.can_close}
                        onClick={() =>
                          act('make_job_unavailable', { job: slotData.title })
                        }
                      >
                        -
                      </Button>
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      <Button
                        disabled={!!data.cooldown_time || !slotData.can_open}
                        onClick={() =>
                          act('make_job_available', { job: slotData.title })
                        }
                      >
                        +
                      </Button>
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      {(data.target_dept && (
                        <Box color="green">
                          {data.priority_jobs.indexOf(slotData.title) > -1
                            ? 'Да'
                            : ''}
                        </Box>
                      )) || (
                        <Button
                          selected={slotData.is_priority}
                          disabled={
                            !!data.cooldown_time || !slotData.can_prioritize
                          }
                          onClick={() =>
                            act('prioritize_job', { job: slotData.title })
                          }
                        >
                          {slotData.is_priority ? 'Да' : 'Нет'}
                        </Button>
                      )}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Stack>
        );
      }
      break;
    case 2: // access change
      if (!data.authenticated || !data.scan_name) {
        bodyBlock = <CardComputerLoginWarning />;
      } else if (!data.modify_name) {
        bodyBlock = <CardComputerNoCard />;
      } else {
        bodyBlock = (
          <>
            <Box height={'70%'}>
              <AccessList
                accesses={data.regions}
                selectedList={data.selectedAccess}
                accessMod={(ref) =>
                  act('set', {
                    access: ref,
                  })
                }
                grantAll={() => act('grant_all')}
                denyAll={() => act('clear_all')}
                grantDep={(ref) =>
                  act('grant_region', {
                    region: ref,
                  })
                }
                denyDep={(ref) =>
                  act('deny_region', {
                    region: ref,
                  })
                }
              />
            </Box>
            <Section title="Юридические полномочия" mt={1}>
              <Dropdown
                options={data.possible_law_levels}
                onSelected={(value) =>
                  act('set_law_level', { level: data.law_levels[value] })
                }
                selected={Object.keys(data.law_levels).find(
                  (value, index, obj) =>
                    data.law_levels[value] === data.law_level
                )}
              />
            </Section>
          </>
        );
      }
      break;
    case 3: // records
      if (!data.authenticated) {
        bodyBlock = <CardComputerLoginWarning />;
      } else if (!data.records.length) {
        bodyBlock = <CardComputerNoRecords />;
      } else {
        bodyBlock = (
          <Section
            fill
            scrollable
            title="Логи"
            buttons={
              <Button
                icon="times"
                disabled={
                  !data.authenticated ||
                  data.records.length === 0 ||
                  data.target_dept
                }
                onClick={() => act('wipe_all_logs')}
              >
                Удалить все логи
              </Button>
            }
          >
            <Table>
              <Table.Row height={2}>
                <Table.Cell bold>Сотрудник</Table.Cell>
                <Table.Cell bold>Старая должность</Table.Cell>
                <Table.Cell bold>Новая должность</Table.Cell>
                <Table.Cell bold>Авторизованный аккаунт</Table.Cell>
                <Table.Cell bold>Время</Table.Cell>
                <Table.Cell bold>Причина</Table.Cell>
                {!!data.iscentcom && <Table.Cell bold>Кем удалено</Table.Cell>}
              </Table.Row>
              {data.records.map((record) => (
                <Table.Row key={record.timestamp} height={2}>
                  <Table.Cell>{record.transferee}</Table.Cell>
                  <Table.Cell>
                    {JOBS_RU[record.oldvalue]
                      ? JOBS_RU[record.oldvalue]
                      : record.oldvalue}
                  </Table.Cell>
                  <Table.Cell>
                    {JOBS_RU[record.newvalue]
                      ? JOBS_RU[record.newvalue]
                      : record.newvalue}
                  </Table.Cell>
                  <Table.Cell>{record.whodidit}</Table.Cell>
                  <Table.Cell>{record.timestamp}</Table.Cell>
                  <Table.Cell>{record.reason}</Table.Cell>
                  {!!data.iscentcom && (
                    <Table.Cell>{record.deletedby}</Table.Cell>
                  )}
                </Table.Row>
              ))}
            </Table>
            {!!data.iscentcom && (
              <Box>
                <Button
                  icon="pencil-alt"
                  color="purple"
                  disabled={!data.authenticated || data.records.length === 0}
                  onClick={() => act('wipe_my_logs')}
                >
                  Удалить мои логи
                </Button>
              </Box>
            )}
          </Section>
        );
      }
      break;
    case 4: // department
      if (!data.authenticated || !data.scan_name) {
        bodyBlock = <CardComputerLoginWarning />;
      } else {
        bodyBlock = (
          <Section fill scrollable title="Подотчётный отдел">
            <Table>
              <Table.Row height={2}>
                <Table.Cell bold>Имя</Table.Cell>
                <Table.Cell bold>Должность</Table.Cell>
                <Table.Cell bold>Охранный статус</Table.Cell>
                <Table.Cell bold>Действия</Table.Cell>
              </Table.Row>
              {data.people_dept.map((record) => (
                <Table.Row key={record.title} height={2}>
                  <Table.Cell>{record.name}</Table.Cell>
                  <Table.Cell>
                    {JOBS_RU[record.title]
                      ? JOBS_RU[record.title]
                      : record.title}
                  </Table.Cell>
                  <Table.Cell>{record.crimstat}</Table.Cell>
                  <Table.Cell>
                    <Button
                      disabled={!record.demotable}
                      onClick={() =>
                        act('remote_demote', { remote_demote: record.name })
                      }
                    >
                      {record.buttontext}
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        );
      }
      break;
    default:
      bodyBlock = (
        <Section title="Предупреждение" color="red">
          ОШИБКА: неизвестный режим работы
        </Section>
      );
  }

  return (
    <Window width={850} height={800}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>{authBlock}</Stack.Item>
          <Stack.Item>{menuBlock}</Stack.Item>
          <Stack.Item grow>{bodyBlock}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
