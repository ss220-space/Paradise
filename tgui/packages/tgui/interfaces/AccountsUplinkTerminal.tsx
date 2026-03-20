import { createSearch } from 'common/string';
import { useBackend } from '../backend';
import { Key, ReactNode, useState } from 'react';
import {
  Button,
  Box,
  Dropdown,
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
  salary_modifier?: number;
  salary_modifier_uid?: string;
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
                Account Holder
              </SortButton>
              <SortButton
                sortId={sortId}
                sortOrder={sortOrder}
                setSortId={setSortId}
                setSortOrder={setSortOrder}
                id="account_number"
              >
                Account Number
              </SortButton>
              <SortButton
                sortId={sortId}
                sortOrder={sortOrder}
                setSortId={setSortId}
                setSortOrder={setSortOrder}
                id="suspended"
              >
                Account Status
              </SortButton>
              <SortButton
                sortId={sortId}
                sortOrder={sortOrder}
                setSortId={setSortId}
                setSortOrder={setSortOrder}
                id="money"
              >
                Account Balance
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
          New Account
        </Button>
        <Button
          icon="print"
          disabled={is_printing}
          ml="0.25rem"
          onClick={() => act('print_records')}
        >
          Print Account List
        </Button>
      </Stack.Item>
      <Stack.Item grow>
        <Input
          placeholder="Search by account holder, number, status"
          width="100%"
          expensive
          onChange={setSearchText}
        />
      </Stack.Item>
    </Stack>
  );
};

const DetailedAccountInfo = (_properties) => {
  const { act, data } = useBackend<Account>();
  const {
    account_number,
    owner_name,
    money,
    suspended,
    transactions,
    salary_modifier,
    salary_modifier_uid,
  } = data;

  const isModified = salary_modifier !== undefined && salary_modifier !== 0;
  const [selectedValue, setSelectedValue] = useState<string>(
    String(salary_modifier || 0)
  );
  const color =
    (salary_modifier || 0) > 0
      ? 'good'
      : (salary_modifier || 0) < 0
        ? 'bad'
        : 'transparent';

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section
          title={'#' + account_number + ' / ' + owner_name}
          buttons={
            <Button icon="arrow-left" onClick={() => act('back')}>
              Back
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Account Number">
              #{account_number}
            </LabeledList.Item>
            <LabeledList.Item label="Account Holder">
              {owner_name}
            </LabeledList.Item>
            <LabeledList.Item label="Account Balance">{money}</LabeledList.Item>
            <LabeledList.Item
              label="Account Status"
              color={suspended ? 'red' : 'green'}
            >
              {suspended ? 'Suspended' : 'Active'}
              <Button
                ml={1}
                icon={suspended ? 'unlock' : 'lock'}
                onClick={() => act('toggle_suspension')}
              >
                {suspended ? 'Unsuspend' : 'Suspend'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Корректировка зарплаты">
              <Box>
                Введите значение процента корректировки заработной платы
                (допустимый диапазон: –50% … +50%).
              </Box>
              <Stack>
                <Stack.Item grow>
                  <Input
                    value={selectedValue}
                    onChange={(val) => {
                      const num = parseInt(val, 10);
                      if (!isNaN(num)) {
                        setSelectedValue(
                          String(Math.max(-50, Math.min(50, num)))
                        );
                      } else {
                        setSelectedValue(val);
                      }
                    }}
                    placeholder="Введите процент (-50 до 50)..."
                    width="100%"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="save"
                    color="good"
                    onClick={() =>
                      act('set_salary_modifier', {
                        modifier: selectedValue,
                        owner_name: owner_name,
                        salary_modifier_uid: salary_modifier_uid,
                      })
                    }
                  >
                    Применить
                  </Button>
                </Stack.Item>
              </Stack>

              {isModified && (
                <Box mt={0.5} fontSize="0.9rem">
                  <Icon name="info-circle" color={color} />{' '}
                  <Box color={color} inline>
                    Текущий модификатор: {salary_modifier > 0 ? '+' : ''}
                    {salary_modifier}%
                  </Box>
                  <Button
                    ml={1}
                    icon="undo"
                    color="transparent"
                    fontSize="0.8rem"
                    onClick={() => {
                      setSelectedValue('0');
                      act('set_salary_modifier', {
                        modifier: 0,
                        owner_name: owner_name,
                        salary_modifier_uid: salary_modifier_uid,
                      });
                    }}
                  >
                    Сбросить
                  </Button>
                </Box>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill title="Transactions">
          <Table>
            <Table.Row header>
              <Table.Cell>Timestamp</Table.Cell>
              <Table.Cell>Reason</Table.Cell>
              <Table.Cell>Value</Table.Cell>
              <Table.Cell>Terminal</Table.Cell>
            </Table.Row>
            {transactions.map((t) => (
              <Table.Row key={t}>
                <Table.Cell>{t.time}</Table.Cell>
                <Table.Cell>{t.purpose}</Table.Cell>
                <Table.Cell color={t.amount >= 0 ? 'green' : 'red'}>
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
      title="Create Account"
      buttons={
        <Button icon="arrow-left" onClick={() => act('back')}>
          Back
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Account Holder">
          <Input placeholder="Name Here" onChange={setAccName} />
        </LabeledList.Item>
        <LabeledList.Item label="Initial Deposit">
          <Input placeholder="0" onChange={setAccDeposit} />
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
        Create Account
      </Button>
    </Section>
  );
};
