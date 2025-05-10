import { useBackend } from '../backend';
import { useState } from 'react';
import {
  Button,
  Table,
  Icon,
  Input,
  Divider,
  Box,
  LabeledList,
  Section,
} from '../components';
import { Window } from '../layouts';
import { Transaction } from './AccountsUplinkTerminal';

/*
#define NO_SCREEN 0
#define CHANGE_SECURITY_LEVEL 1
#define TRANSFER_FUNDS 2
#define VIEW_TRANSACTION_LOGS 3
*/

type ATMData = {
  view_screen: number;
  authenticated_account: boolean;
  ticks_left_locked_down: number;
  linked_db: boolean;
  held_card_name: string;
  security_level: number;
  money: number;
  insurance_type: string;
  owner_name: string;
  insurance: number;
  transaction_log: Transaction[];
};

export const ATM = (props: unknown) => {
  const { data } = useBackend<ATMData>();
  const {
    view_screen,
    authenticated_account,
    ticks_left_locked_down,
    linked_db,
  } = data;
  let body;
  if (ticks_left_locked_down > 0) {
    body = (
      <Box bold color="bad">
        <Icon name="exclamation-triangle" />
        Maximum number of pin attempts exceeded! Access to this ATM has been
        temporarily disabled.
      </Box>
    );
  } else if (!linked_db) {
    body = (
      <Box bold color="bad">
        <Icon name="exclamation-triangle" />
        Unable to connect to accounts database, please retry and if the issue
        persists contact Nanotrasen IT support.
      </Box>
    );
  } else if (authenticated_account) {
    switch (view_screen) {
      case 1: // CHANGE_SECURITY_LEVEL
        body = <ChangeSecurityLevel />;
        break;
      case 2: // TRANSFER_FUNDS
        body = <TransferFunds />;
        break;
      case 3: // VIEW_TRANSACTION_LOGS
        body = <ViewTransactionLogs />;
        break;
      case 4: // CHANGE_INSURANCE_TYPE
        body = <ChangeInsuranceType />;
        break;
      default:
        body = <DefaultScreen />;
    }
  } else {
    body = <LoginScreen />;
  }
  return (
    <Window width={550} height={650}>
      <Window.Content scrollable>
        <IntroductionAndCard />
        <Section>{body}</Section>
      </Window.Content>
    </Window>
  );
};

const IntroductionAndCard = (props: unknown) => {
  const { act, data } = useBackend<ATMData>();
  const { held_card_name } = data;
  return (
    <Section title="Nanotrasen Automatic Teller Machine">
      <Box>For all your monetary needs!</Box>
      <Divider />
      <LabeledList>
        <LabeledList.Item label="Card">
          <Button icon="eject" onClick={() => act('insert_card')}>
            {held_card_name}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ChangeSecurityLevel = (props: unknown) => {
  const { act, data } = useBackend<ATMData>();
  const { security_level } = data;
  return (
    <Section title="Select a new security level for this account">
      <LabeledList>
        <Divider />
        <LabeledList.Item label="Level">
          <Button
            icon="unlock"
            selected={security_level === 0}
            onClick={() =>
              act('change_security_level', { new_security_level: 0 })
            }
          >
            Account Numbe
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Description">
          Either the account number or card is required to access this account.
          EFTPOS transactions will require a card.
        </LabeledList.Item>
        <Divider />
        <LabeledList.Item label="Level">
          <Button
            icon="unlock"
            selected={security_level === 1}
            onClick={() =>
              act('change_security_level', { new_security_level: 1 })
            }
          >
            Account Pin
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Description">
          An account number and pin must be manually entered to access this
          account and process transactions.
        </LabeledList.Item>
        <Divider />
        <LabeledList.Item label="Level">
          <Button
            icon="unlock"
            selected={security_level === 2}
            onClick={() =>
              act('change_security_level', { new_security_level: 2 })
            }
          >
            Card and Account Pin
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Description">
          An account number, pin and card are required to access this account
          and process transactions.
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <BackButton />
    </Section>
  );
};

const TransferFunds = (props: unknown) => {
  const { act, data } = useBackend<ATMData>();
  const [targetAccNumber, setTargetAccNumber] = useState('0');
  const [fundsAmount, setFundsAmount] = useState('0');
  const [purpose, setPurpose] = useState('0');
  const { money } = data;
  return (
    <Section title="Transfer Fund">
      <LabeledList>
        <LabeledList.Item label="Account Balance">${money}</LabeledList.Item>
        <LabeledList.Item label="Target Account Number">
          <Input
            placeholder="7 Digit Number"
            onChange={(e, value) => setTargetAccNumber(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Funds to Transfer">
          <Input onChange={(e, value) => setFundsAmount(value)} />
        </LabeledList.Item>
        <LabeledList.Item label="Transaction Purpose">
          <Input fluid onChange={(e, value) => setPurpose(value)} />
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Button
        icon="sign-out-alt"
        onClick={() =>
          act('transfer', {
            target_acc_number: targetAccNumber,
            funds_amount: fundsAmount,
            purpose: purpose,
          })
        }
      >
        Transfer
      </Button>
      <Divider />
      <BackButton />
    </Section>
  );
};

const ChangeInsuranceType = (props: unknown) => {
  const { act, data } = useBackend<ATMData>();
  const { insurance_type } = data;
  return (
    <Section title="Выберите новый тип страховки">
      <LabeledList>
        <LabeledList.Item label="Тип">
          <Button
            icon="unlock"
            selected={insurance_type === 'None'}
            onClick={() =>
              act('change_insurance_type', { new_insurance_type: 'None' })
            }
          >
            Нет (0)
          </Button>
          <Button
            icon="unlock"
            selected={insurance_type === 'Bugetary'}
            onClick={() =>
              act('change_insurance_type', { new_insurance_type: 'Bugetary' })
            }
          >
            Бюджетная (0)
          </Button>
          <Button
            icon="unlock"
            selected={insurance_type === 'Standart'}
            onClick={() =>
              act('change_insurance_type', { new_insurance_type: 'Standart' })
            }
          >
            Стандартная (500)
          </Button>
          <Button
            icon="unlock"
            selected={insurance_type === 'Deluxe'}
            onClick={() =>
              act('change_insurance_type', { new_insurance_type: 'Deluxe' })
            }
          >
            Делюкс (2000)
          </Button>
        </LabeledList.Item>
      </LabeledList>
      <BackButton />
    </Section>
  );
};

const DefaultScreen = (props: unknown) => {
  const { act, data } = useBackend<ATMData>();
  const [fundsAmount, setFundsAmount] = useState('0');
  const [insuranceAmount, setInsuranceAmount] = useState('0');
  const { owner_name, money, insurance } = data;
  return (
    <>
      <Section
        title={'Welcome, ' + owner_name}
        buttons={
          <Button icon="sign-out-alt" onClick={() => act('logout')}>
            Logout
          </Button>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Account Balance">${money}</LabeledList.Item>
          <LabeledList.Item label="Withdrawal Amount">
            <Input onChange={(e, value) => setFundsAmount(value)} />
          </LabeledList.Item>
          <LabeledList.Item>
            <Button
              icon="sign-out-alt"
              onClick={() => act('withdrawal', { funds_amount: fundsAmount })}
            >
              Withdraw Funds
            </Button>
          </LabeledList.Item>

          <LabeledList.Item label="Insurance Points">
            ${insurance}
          </LabeledList.Item>
          <LabeledList.Item label="Adding Insurance">
            <Input onChange={(e, value) => setInsuranceAmount(value)} />
          </LabeledList.Item>
          <LabeledList.Item>
            <Button
              icon="sign-out-alt"
              onClick={() =>
                act('insurance', { insurance_amount: insuranceAmount })
              }
            >
              Add insurance points
            </Button>
          </LabeledList.Item>

          <LabeledList.Item>
            <Button
              icon="sign-out-alt"
              onClick={() => act('insurance_replenishment', {})}
            >
              Toggle auto-replenishment of insurance
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Menu">
        <Box>
          <Button
            icon="lock"
            onClick={() => act('view_screen', { view_screen: 1 })}
          >
            Change account security level
          </Button>
        </Box>
        <Box>
          <Button
            icon="exchange-alt"
            onClick={() => act('view_screen', { view_screen: 2 })}
          >
            Make transfer
          </Button>
        </Box>
        <Box>
          <Button
            icon="list"
            onClick={() => act('view_screen', { view_screen: 3 })}
          >
            View transaction log
          </Button>
        </Box>
        <Box>
          <Button
            icon="lock"
            onClick={() => act('view_screen', { view_screen: 4 })}
          >
            Change type of insurance
          </Button>
        </Box>
        <Box>
          <Button icon="print" onClick={() => act('balance_statement')}>
            Print balance statement
          </Button>
        </Box>
      </Section>
    </>
  );
};

const LoginScreen = (props: unknown) => {
  const { act } = useBackend();
  const [accountID, setAccountID] = useState('');
  const [accountPin, setAccountPin] = useState('');
  return (
    <Section title="Insert card or enter ID and pin to login">
      <LabeledList>
        <LabeledList.Item label="Account ID">
          <Input
            placeholder="6 Digit Number"
            onChange={(e, value) => setAccountID(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Pin">
          <Input
            placeholder="6 Digit Number"
            onChange={(e, value) => setAccountPin(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item>
          <Button
            icon="sign-in-alt"
            onClick={() =>
              act('attempt_auth', {
                account_num: accountID,
                account_pin: accountPin,
              })
            }
          >
            Login
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ViewTransactionLogs = (props: unknown) => {
  const { data } = useBackend<ATMData>();
  const { transaction_log } = data;
  return (
    <Section title="Transactions">
      <Table>
        <Table.Row header>
          <Table.Cell>Timestamp</Table.Cell>
          <Table.Cell>Reason</Table.Cell>
          <Table.Cell>Value</Table.Cell>
          <Table.Cell>Terminal</Table.Cell>
        </Table.Row>
        {transaction_log.map((t) => (
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
      <Divider />
      <BackButton />
    </Section>
  );
};

const BackButton = (props: unknown) => {
  const { act } = useBackend();
  return (
    <Button
      icon="sign-out-alt"
      onClick={() => act('view_screen', { view_screen: 0 })}
    >
      Back
    </Button>
  );
};
