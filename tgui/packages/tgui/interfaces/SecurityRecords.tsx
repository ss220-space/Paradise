import { createSearch, decodeHtmlEntities } from 'common/string';
import { useBackend } from '../backend';
import { ReactNode, useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
  Tabs,
  Table,
  Image,
} from '../components';
import { Window } from '../layouts';
import { ComplexModal, modalOpen } from './common/ComplexModal';
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';
import { TemporaryNotice } from './common/TemporaryNotice';
import {
  BaseRecord,
  Comment,
  Field,
  Record,
  SortButton,
} from './MedicalRecords';

const statusStyles = {
  '*Казнь*': 'execute',
  '*Арест*': 'arrest',
  'Заключён': 'incarcerated',
  'Условно-досрочно освобождён': 'parolled',
  'Освобождён': 'released',
  'Понижение': 'demote',
  'Обыск': 'search',
  'Под наблюдением': 'monitor',
};

const doEdit = (field: Field) => {
  modalOpen('edit', {
    field: field.edit,
    value: field.value,
  });
};

type SecurityRecordsData = {
  loginState: LoginState;
  currentPage: number;
  general: SecurityGeneralRecord;
  records: SecRecord[];
  isPrinting: boolean;
  security: SecurityRecord;
};

type SecRecord = {
  status: string;
  uid_gen: string;
  uid_sec: string;
} & Record;

type SecurityRecord = {
  comments: Comment[];
} & BaseRecord;

type SecurityGeneralRecord = {
  has_photos: boolean;
  photos: string[];
} & BaseRecord;

export const SecurityRecords = (_properties) => {
  const { data } = useBackend<SecurityRecordsData>();
  const { loginState, currentPage } = data;

  let body: ReactNode;
  if (!loginState.logged_in) {
    return (
      <Window width={800} height={900} theme="security">
        <Window.Content>
          <LoginScreen />
        </Window.Content>
      </Window>
    );
  } else {
    if (currentPage === 1) {
      body = <SecurityRecordsPageList />;
    } else if (currentPage === 2) {
      body = <SecurityRecordsPageMaintenance />;
    } else if (currentPage === 3) {
      body = <SecurityRecordsPageView />;
    }
  }

  return (
    <Window theme="security" width={800} height={900}>
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <LoginInfo />
          <TemporaryNotice />
          <SecurityRecordsNavigation />
          {body}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const SecurityRecordsNavigation = (_properties) => {
  const { act, data } = useBackend<SecurityRecordsData>();
  const { currentPage, general } = data;
  return (
    <Tabs>
      <Tabs.Tab
        selected={currentPage === 1}
        onClick={() => act('page', { page: 1 })}
      >
        <Icon name="list" />
        Просмотр Записей
      </Tabs.Tab>
      <Tabs.Tab
        selected={currentPage === 2}
        onClick={() => act('page', { page: 2 })}
      >
        <Icon name="wrench" />
        Обслуживание Записей
      </Tabs.Tab>
      {currentPage === 3 && general && !general.empty && (
        <Tabs.Tab selected={currentPage === 3}>
          <Icon name="file" />
          Запись: {general.fields[0].value}
        </Tabs.Tab>
      )}
    </Tabs>
  );
};

const SecurityRecordsPageList = (_properties) => {
  const { act, data } = useBackend<SecurityRecordsData>();
  const { records } = data;
  const [searchText, setSearchText] = useState('');
  const [sortId, setSortId] = useState('name');
  const [sortOrder, setSortOrder] = useState(true);
  return (
    <>
      <Stack.Item>
        <SecurityRecordsActions setSearchText={setSearchText} />
      </Stack.Item>
      <Stack.Item grow mt={0.5}>
        <Section fill scrollable>
          <Table
            className="SecurityRecords__list"
            style={{
              borderCollapse: 'separate',
              borderSpacing: '0 5px',
            }}
          >
            <Table.Row bold mb={1}>
              <SortButton
                id="name"
                sortId={sortId}
                setSortId={setSortId}
                sortOrder={sortOrder}
                setSortOrder={setSortOrder}
              >
                Имя
              </SortButton>
              <SortButton
                id="id"
                sortId={sortId}
                setSortId={setSortId}
                sortOrder={sortOrder}
                setSortOrder={setSortOrder}
              >
                ID
              </SortButton>
              <SortButton
                id="rank"
                sortId={sortId}
                setSortId={setSortId}
                sortOrder={sortOrder}
                setSortOrder={setSortOrder}
              >
                Должность
              </SortButton>
              <SortButton
                id="fingerprint"
                sortId={sortId}
                setSortId={setSortId}
                sortOrder={sortOrder}
                setSortOrder={setSortOrder}
              >
                Отпечатки пальцев
              </SortButton>
              <SortButton
                id="status"
                sortId={sortId}
                setSortId={setSortId}
                sortOrder={sortOrder}
                setSortOrder={setSortOrder}
              >
                Статус
              </SortButton>
            </Table.Row>
            {records
              .filter(
                createSearch(searchText, (record) => {
                  return (
                    record.name +
                    '|' +
                    record.id +
                    '|' +
                    record.rank +
                    '|' +
                    record.fingerprint +
                    '|' +
                    record.status
                  );
                })
              )
              .sort((a, b) => {
                const i = sortOrder ? 1 : -1;
                return a[sortId].localeCompare(b[sortId]) * i;
              })
              .map((record) => (
                <Table.Row
                  key={record.id}
                  mb={1}
                  className={
                    'SecurityRecords__listRow--' + statusStyles[record.status]
                  }
                  onClick={() =>
                    act('view', {
                      uid_gen: record.uid_gen,
                      uid_sec: record.uid_sec,
                    })
                  }
                >
                  <Table.Cell>
                    <Button icon="user">{record.name}</Button>
                  </Table.Cell>
                  <Table.Cell>{record.id}</Table.Cell>
                  <Table.Cell>{record.rank}</Table.Cell>
                  <Table.Cell>{record.fingerprint}</Table.Cell>
                  <Table.Cell>{record.status}</Table.Cell>
                </Table.Row>
              ))}
          </Table>
        </Section>
      </Stack.Item>
    </>
  );
};

const SecurityRecordsActions = (properties: SearchTextProps) => {
  const { act, data } = useBackend<SecurityRecordsData>();
  const { isPrinting } = data;
  const { setSearchText } = properties;
  return (
    <Stack fill>
      <Stack.Item>
        <Button ml="0.25rem" icon="plus" onClick={() => act('new_general')}>
          Новая Запись
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button
          disabled={isPrinting}
          icon={isPrinting ? 'spinner' : 'print'}
          iconSpin={!!isPrinting}
          onClick={() => modalOpen('print_cell_log')}
        >
          Распечатать Запись Камеры Заключения
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        <Input
          placeholder="Поиск по имени, профессии, отпечаткам пальцев, статусу.."
          fluid
          onInput={(e, value) => setSearchText(value)}
        />
      </Stack.Item>
    </Stack>
  );
};

const SecurityRecordsPageMaintenance = (_properties) => {
  return (
    <Box m={1}>
      <Button
        disabled
        icon="download"
        tooltip="Эта функция недоступна."
        tooltipPosition="right"
      >
        Выгрузить На Диск
      </Button>
      <br />
      <Button
        disabled
        icon="upload"
        tooltip="Эта функция недоступна."
        tooltipPosition="right"
        my="0.5rem"
      >
        Загрузить С Диска
      </Button>
      <br />
      <Button.Confirm
        disabled
        icon="trash"
        tooltip="Эта функция недоступна."
        mb="0.5rem"
      >
        Удалить ВСЕ Записи Службы Безопасности
      </Button.Confirm>
      <br />
      <Button.Confirm disabled icon="trash" tooltip="Эта функция недоступна.">
        Удалить ВСЕ Записи Камер Заключения
      </Button.Confirm>
    </Box>
  );
};

const SecurityRecordsPageView = (_properties) => {
  const { act, data } = useBackend<SecurityRecordsData>();
  const { isPrinting, general, security } = data;
  if (!general || !general.fields) {
    return <Box color="bad">Общие записи утеряны!</Box>;
  }
  return (
    <>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          mt="-6px"
          title="Общая Информация"
          buttons={
            <>
              <Button
                disabled={isPrinting}
                icon={isPrinting ? 'spinner' : 'print'}
                iconSpin={!!isPrinting}
                onClick={() => act('print_record')}
              >
                Распечатать Запись
              </Button>
              <Button.Confirm
                icon="trash"
                tooltip={
                  'ВНИМАНИЕ: Это безвозвратно удалит охранные' +
                  'и медицинские записи, связанные с этим членом экипажа!'
                }
                tooltipPosition="bottom-start"
                onClick={() => act('delete_general')}
              >
                Удалить Запись
              </Button.Confirm>
            </>
          }
        >
          <SecurityRecordsViewGeneral />
        </Section>
      </Stack.Item>
      {!security || !security.fields ? (
        <Stack.Item grow color="bad">
          <Section
            fill
            title="Данные Службы Безопасности"
            buttons={
              <Button icon="pen" onClick={() => act('new_security')}>
                Создать Новую Запись
              </Button>
            }
          >
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
                  <Icon name="scroll" size={5} color="gray" />
                  <Icon name="slash" size={5} color="red" />
                </Icon.Stack>
                <br />
                Запись Службы Безопасности отсутствует!
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      ) : (
        <>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Данные Службы Безопасности"
              buttons={
                <Button.Confirm
                  icon="trash"
                  disabled={security.empty}
                  onClick={() => act('delete_security')}
                >
                  Удалить Запись
                </Button.Confirm>
              }
            >
              <Stack.Item>
                <LabeledList>
                  {security.fields.map((field, i) => (
                    <LabeledList.Item key={i} label={field.field}>
                      {decodeHtmlEntities(field.value)}
                      {!!field.edit && (
                        <Button
                          icon="pen"
                          ml="0.5rem"
                          mb={field.line_break ? '1rem' : 'initial'}
                          onClick={() => doEdit(field)}
                        />
                      )}
                    </LabeledList.Item>
                  ))}
                </LabeledList>
              </Stack.Item>
            </Section>
          </Stack.Item>
          <SecurityRecordsViewSecurity />
        </>
      )}
    </>
  );
};

const SecurityRecordsViewGeneral = (_properties) => {
  const { data } = useBackend<SecurityRecordsData>();
  const { general } = data;
  if (!general || !general.fields) {
    return (
      <Stack fill vertical>
        <Stack.Item grow color="bad">
          <Section fill>Записи утеряны!</Section>
        </Stack.Item>
      </Stack>
    );
  }
  return (
    <Stack>
      <Stack.Item grow>
        <LabeledList>
          {general.fields.map((field, i) => (
            <LabeledList.Item key={i} label={field.field}>
              {decodeHtmlEntities('' + field.value)}
              {!!field.edit && (
                <Button
                  icon="pen"
                  ml="0.5rem"
                  mb={field.line_break ? '1rem' : 'initial'}
                  onClick={() => doEdit(field)}
                />
              )}
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Stack.Item>
      {!!general.has_photos &&
        general.photos.map((p, i) => (
          <Stack.Item key={i} inline textAlign="center" color="label" ml={0}>
            <Image
              src={p}
              style={{
                width: '96px',
                marginTop: '5rem',
                marginBottom: '0.5rem',
              }}
            />
            <br />
            Photo #{i + 1}
          </Stack.Item>
        ))}
    </Stack>
  );
};

const SecurityRecordsViewSecurity = (_properties) => {
  const { act, data } = useBackend<SecurityRecordsData>();
  const { security } = data;
  return (
    <Stack.Item height="150px">
      <Section
        fill
        scrollable
        title="Комментарии/Записи"
        buttons={
          <Button icon="comment" onClick={() => modalOpen('comment_add')}>
            Добавить Комментарий
          </Button>
        }
      >
        {security.comments.length === 0 ? (
          <Box color="label">Комментариев не найдено.</Box>
        ) : (
          security.comments.map((comment, i) => (
            <Box key={i} preserveWhitespace>
              <Box color="label" inline>
                {comment.header || 'Auto-generated'}
              </Box>
              <br />
              {comment.text || (comment as any)}
              <Button
                icon="comment-slash"
                color="bad"
                ml="0.5rem"
                onClick={() => act('comment_delete', { id: i + 1 })}
              />
            </Box>
          ))
        )}
      </Section>
    </Stack.Item>
  );
};
