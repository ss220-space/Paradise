import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

type UnlockedViewData = {
  transaction_purpose: string;
  transaction_amount: number;
  linked_account: string;
  transaction_paid: boolean;
};

type LockedViewData = {} & UnlockedViewData;

type EFTPOSData = {
  transaction_locked: boolean;
  machine_name: string;
};

export const EFTPOS = (props: unknown) => {
  const { data } = useBackend<EFTPOSData>();
  const { transaction_locked, machine_name } = data;
  return (
    <Window width={800} height={300}>
      <Window.Content>
        <Box italic>
          This terminal is {machine_name}. Report this code when contacting
          Nanotrasen IT Support.
        </Box>
        {transaction_locked ? <LockedView /> : <UnlockedView />}
      </Window.Content>
    </Window>
  );
};

const LockedView = (props: unknown) => {
  const { act, data } = useBackend<LockedViewData>();
  const {
    transaction_purpose,
    transaction_amount,
    linked_account,
    transaction_paid,
  } = data;
  return (
    <Section title="Current Transaction" mt={1}>
      <LabeledList>
        <LabeledList.Item label="Transaction Purpose">
          {transaction_purpose}
        </LabeledList.Item>
        <LabeledList.Item label="Value">
          {/* Ternary required otherwise the 0 is offset weirdly */}
          {transaction_amount ? transaction_amount : '0'}
        </LabeledList.Item>
        <LabeledList.Item label="Linked Account">
          {linked_account ? linked_account : 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="Actions">
          <Button icon="unlock" onClick={() => act('toggle_lock')}>
            {transaction_paid ? 'Reset' : 'Reset (Auth required)'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
      <NoticeBox mt={1}>
        <Button icon="id-card" mr={2} onClick={() => act('scan_card')}>
          ------
        </Button>
        {transaction_paid
          ? 'This transaction has been processed successfully '
          : 'Swipe your card to finish this transaction.'}
      </NoticeBox>
    </Section>
  );
};

const UnlockedView = (props: unknown) => {
  const { act, data } = useBackend<UnlockedViewData>();
  const { transaction_purpose, transaction_amount, linked_account } = data;
  return (
    <Section title="Transation Settings" mt={1}>
      <LabeledList>
        <LabeledList.Item label="Transaction Purpose">
          <Button icon="edit" onClick={() => act('trans_purpose')}>
            {transaction_purpose}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Value">
          <Button
            // Ternary required otherwise the 0 is offset weirdly
            icon="edit"
            onClick={() => act('trans_value')}
          >
            {transaction_amount ? transaction_amount : '0'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Linked Account">
          <Button icon="edit" onClick={() => act('link_account')}>
            {linked_account ? linked_account : 'None'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Actions">
          <Button icon="lock" onClick={() => act('toggle_lock')}>
            Lock in new transaction
          </Button>
          <Button icon="key" onClick={() => act('change_code')}>
            Change access code
          </Button>
          <Button
            tooltip="Requires Captain, HoP or CC access"
            icon="sync-alt"
            onClick={() => act('reset')}
          >
            Reset access code
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
