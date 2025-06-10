import { createSearch } from 'common/string';
import { useBackend } from '../backend';
import { Key, ReactNode, useState } from 'react';
import {
  Button,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
  Table,
} from '../components';
import { Window } from '../layouts';
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';

type Data = {
  loginState: LoginState;
  currentPage: number;
  accounts: Account[];
  is_printing: boolean;
};

type Account = {
  account_index: string;
  owner_name: string;
  account_number: number;
  suspended: boolean;
  money: number;
  transactions: Transaction[];
};

export type Transaction = {
  time: string;
  purpose: string;
  is_deposit: boolean;
  amount: number;
  target_name: string;
} & Key;

export const AccountsUplinkTerminal = (_properties) => {
  const { data } = useBackend<Data>();
  const { loginState, currentPage } = data;

  let body: ReactNode;
  if (!loginState.logged_in) {
    return (
      <Window width={800} height={600}>
        <Window.Content>
          <Stack fill vertical>
            <LoginScreen />
          </Stack>
        </Window.Content>
      </Window>
    );
  } else {
    if (currentPage === 1) {
      body = <AccountsRecordList />;
    } else if (currentPage === 2) {
      body = <DetailedAccountInfo />;
    } else if (currentPage === 3) {
      body = <CreateAccount />;
    }
  }

  return (
    <Window width={800} height={600}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <LoginInfo />
          <Section fill scrollable>
            {body}
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const AccountsRecordList = (_properties) => {
  const { act, data } = useBackend<Data>();
  const { accounts } = data;
  const [searchText, setSearchText] = useState('');
  const [sortId, setSortId] = useState('owner_name');
  const [sortOrder, setSortOrder] = useState(true);
  return (
    <Stack fill vertical>
      <AccountsActions setSearchText={setSearchText} />
      <Stack.Item grow>
        <Section fill scrollable>
          <Table className="AccountsUplinkTerminal__list">
            <Table.Row bold>
              <SortButton
                sortId={sortId}
                sortOrder={sortOrder}
                setSortId={setSortId}
                setSortOrder={setSortOrder}
                id="owner_name"
              >
                Владелец Аккаунта
              </SortButton>
              <SortButton
                sortId={sortId}
                sortOrder={sortOrder}
                setSortId={setSortId}
                setSortOrder={setSortOrder}
                id="account_number"
              >
                Номер Аккаунта
              </SortButton>
              <SortButton
                sortId={sortId}
                sortOrder={sortOrder}
                setSortId={setSortId}
                setSortOrder={setSortOrder}
                id="suspended"
              >
                Статус Аккаунта
              </SortButton>
              <SortButton
                sortId={sortId}
                sortOrder={sortOrder}
                setSortId={setSortId}
                setSortOrder={setSortOrder}
                id="money"
              >
                Баланс Аккаунта
              </SortButton>
            </Table.Row>
            {accounts
              .filter(
                createSearch(searchText, (account) => {
                  return (
                    account.owner_name +
                    '|' +
                    account.account_number +
                    '|' +
                    account.suspended +
                    '|' +
                    account.money
                  );
                })
              )
              .sort((a, b) => {
                const i = sortOrder ? 1 : -1;
                return a[sortId].localeCompare(b[sortId]) * i;
              })
              .map((account) => (
                <Table.Row
                  key={account.account_number}
                  className={
                    'AccountsUplinkTerminal__listRow--' + account.suspended
                  }
                  onClick={() =>
                    act('view_account_detail', {
                      index: account.account_index,
                    })
                  }
                >
                  <Table.Cell>
                    <Icon name="user" /> {account.owner_name}
                  </Table.Cell>
                  <Table.Cell>#{account.account_number}</Table.Cell>
                  <Table.Cell>{account.suspended}</Table.Cell>
                  <Table.Cell>{account.money}</Table.Cell>
                </Table.Row>
              ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

type SortButtonProps = {
  id: string;
  children: ReactNode;
} & SortOrderProps &
  SordIdProps;

const SortButton = (properties: SortButtonProps) => {
  const { sortId, setSortId, sortOrder, setSortOrder } = properties;
  const { id, children } = properties;
  return (
    <Table.Cell>
      <Button
        color={sortId !== id && 'transparent'}
        width="100%"
        onClick={() => {
          if (sortId === id) {
            setSortOrder(!sortOrder);
          } else {
            setSortId(id);
            setSortOrder(true);
          }
        }}
      >
        {children}
        {sortId === id && (
          <Icon name={sortOrder ? 'sort-up' : 'sort-down'} ml="0.25rem;" />
        )}
      </Button>
    </Table.Cell>
  );
};

type AccountsActionsProps = SearchTextProps;

const AccountsActions = (properties: AccountsActionsProps) => {
  const { act, data } = useBackend<Data>();
  const { is_printing } = data;
  const { setSearchText } = properties;
  return (
    <Stack>
      <Stack.Item>
        <Button icon="plus" onClick={() => act('create_new_account')}>
          Новый Аккаунт
        </Button>
        <Button
          icon="print"
          disabled={is_printing}
          ml="0.25rem"
          onClick={() => act('print_records')}
        >
          Распечатать Список Аккаунтов
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        <Input
          placeholder="Поиск по владельцу аккаунта, номеру, статусу.."
          width="100%"
          onInput={(e, value) => setSearchText(value)}
        />
      </Stack.Item>
    </Stack>
  );
};

const DetailedAccountInfo = (_properties) => {
  const { act, data } = useBackend<Account>();
  const { account_number, owner_name, money, suspended, transactions } = data;
  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          title={'#' + account_number + ' / ' + owner_name}
          buttons={
            <Button icon="arrow-left" onClick={() => act('back')}>
              Назад
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Номер аккаунта">
              #{account_number}
            </LabeledList.Item>
            <LabeledList.Item label="Владелец аккаунта">
              {owner_name}
            </LabeledList.Item>
            <LabeledList.Item label="Баланс аккаунта">{money}</LabeledList.Item>
            <LabeledList.Item
              label="Статус аккаунта"
              color={suspended ? 'red' : 'green'}
            >
              {suspended ? 'Неактивен' : 'Активен'}
              <Button
                ml={1}
                icon={suspended ? 'unlock' : 'lock'}
                onClick={() => act('toggle_suspension')}
              >
                {suspended ? 'Возобновить' : 'Приостановить'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill title="Транзакции">
          <Table>
            <Table.Row header>
              <Table.Cell>Время</Table.Cell>
              <Table.Cell>Причина</Table.Cell>
              <Table.Cell>Сумма</Table.Cell>
              <Table.Cell>Терминал</Table.Cell>
            </Table.Row>
            {transactions.map((t) => (
              <Table.Row key={t}>
                <Table.Cell>{t.time}</Table.Cell>
                <Table.Cell>{t.purpose}</Table.Cell>
                <Table.Cell color={t.is_deposit ? 'green' : 'red'}>
                  ${t.amount}
                </Table.Cell>
                <Table.Cell>{t.target_name}</Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const CreateAccount = (properties) => {
  const { act } = useBackend();
  const [accName, setAccName] = useState('');
  const [accDeposit, setAccDeposit] = useState('');
  return (
    <Section
      title="Создать Аккаунт"
      buttons={
        <Button icon="arrow-left" onClick={() => act('back')}>
          Назад
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Владелец Аккаунта">
          <Input
            placeholder="Имя:"
            onChange={(e, value) => setAccName(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Первоначальная Сумма">
          <Input
            placeholder="0"
            onChange={(e, value) => setAccDeposit(value)}
          />
        </LabeledList.Item>
      </LabeledList>
      <Button
        mt={1}
        fluid
        onClick={() =>
          act('finalise_create_account', {
            holder_name: accName,
            starting_funds: accDeposit,
          })
        }
      >
        Создать Аккаунт
      </Button>
    </Section>
  );
};
