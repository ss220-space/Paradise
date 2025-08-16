import { ReactNode } from 'react';
import { useBackend } from '../backend';
import { Button, LabeledList, Box, Section } from '../components';
import { Window } from '../layouts';

export const pages = {
  0: () => <MainMenu />,
  1: () => <DepartmentList purpose="ASSISTANCE" />,
  2: () => <DepartmentList purpose="SUPPLIES" />,
  3: () => <DepartmentList purpose="INFO" />,
  4: () => <MessageResponse type="SUCCESS" />,
  5: () => <MessageResponse type="FAIL" />,
  6: () => <MessageLog type="MESSAGES" />,
  7: () => <MessageAuth />,
  8: () => <StationAnnouncement />,
  9: () => <PrintShippingLabel />,
  10: () => <MessageLog type="SHIPPING" />,
  default: () => "WE SHOULDN'T BE HERE!",
};

type RequestConsoleData = Partial<{
  screen: number;
  newmessagepriority: number;
  announcementConsole: boolean;
  silent: boolean;
  department: string;
  assist_dept: string[];
  supply_dept: string[];
  info_dept: string[];
  message_log: string[];
  shipping_log: string[];
  recipient: string;
  message: string;
  msgVerified: boolean;
  msgStamped: boolean;
  announceAuth: boolean;
  shipDest: string;
  ship_dept: string[];
}>;

export const RequestConsole = (_props: unknown) => {
  const { data } = useBackend<RequestConsoleData>();
  const { screen } = data;

  const renderPage = pages[screen] || pages.default;

  return (
    <Window width={520} height={410}>
      <Window.Content scrollable>{renderPage()}</Window.Content>
    </Window>
  );
};

const MainMenu = (_props: unknown) => {
  const { act, data } = useBackend<RequestConsoleData>();
  const { newmessagepriority, announcementConsole, silent } = data;
  let messageInfo: ReactNode;
  if (newmessagepriority === 1) {
    messageInfo = <Box color="red">There are new messages</Box>;
  } else if (newmessagepriority === 2) {
    messageInfo = (
      <Box color="red" bold>
        NEW PRIORITY MESSAGES
      </Box>
    );
  }
  return (
    <Section title="Main Menu">
      {messageInfo}
      <Box mt={2}>
        <Button
          icon={newmessagepriority > 0 ? 'envelope-open-text' : 'envelope'}
          onClick={() => act('setScreen', { setScreen: 6 })}
        >
          View Messages
        </Button>
      </Box>
      <Box mt={2} mb={2}>
        <Box mb={0.1}>
          <Button
            icon="hand-paper"
            onClick={() => act('setScreen', { setScreen: 1 })}
          >
            Request Assistance
          </Button>
        </Box>
        <Box mb={0.1}>
          <Button icon="box" onClick={() => act('setScreen', { setScreen: 2 })}>
            Request Supplies
          </Button>
        </Box>
        <Box>
          <Button
            icon="comment"
            onClick={() => act('setScreen', { setScreen: 3 })}
          >
            Relay Anonymous Information
          </Button>
        </Box>
      </Box>
      <Box mt={2}>
        <Box mb={'1px'}>
          <Button icon="tag" onClick={() => act('setScreen', { setScreen: 9 })}>
            Print Shipping Label
          </Button>
        </Box>
        <Box>
          <Button
            icon="clipboard-list"
            onClick={() => act('setScreen', { setScreen: 10 })}
          >
            View Shipping Logs
          </Button>
        </Box>
      </Box>
      {!!announcementConsole && (
        <Box mt={2}>
          <Button
            icon="bullhorn"
            onClick={() => act('setScreen', { setScreen: 8 })}
          >
            Send Station-Wide Announcement
          </Button>
        </Box>
      )}
      <Box mt={2}>
        <Button
          selected={!silent}
          icon={silent ? 'volume-mute' : 'volume-up'}
          onClick={() => act('toggleSilent')}
        >
          {silent ? 'Speaker Off' : 'Speaker On'}
        </Button>
      </Box>
    </Section>
  );
};

type DepartmentListProps = {
  purpose?: string;
};

const DepartmentList = (props: DepartmentListProps) => {
  const { act, data } = useBackend<RequestConsoleData>();
  const { department } = data;

  let list2iterate: string[];
  let sectionTitle: string;
  switch (props.purpose) {
    case 'ASSISTANCE':
      list2iterate = data.assist_dept;
      sectionTitle = 'Request assistance from another department';
      break;
    case 'SUPPLIES':
      list2iterate = data.supply_dept;
      sectionTitle = 'Request supplies from another department';
      break;
    case 'INFO':
      list2iterate = data.info_dept;
      sectionTitle = 'Relay information to another department';
      break;
  }
  return (
    <Section
      title={sectionTitle}
      buttons={
        <Button
          icon="arrow-left"
          onClick={() => act('setScreen', { setScreen: 0 })}
        >
          Back
        </Button>
      }
    >
      <LabeledList>
        {list2iterate
          .filter((d) => d !== department)
          .map((d) => (
            <LabeledList.Item key={d} label={d}>
              <Button
                icon="envelope"
                onClick={() => act('writeInput', { write: d, priority: 1 })}
              >
                Message
              </Button>
              <Button
                icon="exclamation-circle"
                onClick={() => act('writeInput', { write: d, priority: 2 })}
              >
                High Priority
              </Button>
            </LabeledList.Item>
          ))}
      </LabeledList>
    </Section>
  );
};

type MessageResponseProps = {
  type: string;
};

const MessageResponse = (props: MessageResponseProps) => {
  const { act } = useBackend();

  let sectionTitle: string;
  switch (props.type) {
    case 'SUCCESS':
      sectionTitle = 'Message sent successfully';
      break;
    case 'FAIL':
      sectionTitle = 'Request supplies from another department';
      break;
  }

  return (
    <Section
      title={sectionTitle}
      buttons={
        <Button
          icon="arrow-left"
          onClick={() => act('setScreen', { setScreen: 0 })}
        >
          Back
        </Button>
      }
    />
  );
};

type MessageLogProps = {
  type: string;
};

const MessageLog = (props: MessageLogProps) => {
  const { act, data } = useBackend<RequestConsoleData>();

  let list2iterate: string[];
  let sectionTitle: string;
  switch (props.type) {
    case 'MESSAGES':
      list2iterate = data.message_log;
      sectionTitle = 'Message Log';
      break;
    case 'SHIPPING':
      list2iterate = data.shipping_log;
      sectionTitle = 'Shipping label print log';
      break;
  }

  return (
    <Section
      title={sectionTitle}
      buttons={
        <Button
          icon="arrow-left"
          onClick={() => act('setScreen', { setScreen: 0 })}
        >
          Back
        </Button>
      }
    >
      {list2iterate.map((m) => (
        <Box className="RequestConsole__message" key={m}>
          {m}
        </Box>
      ))}
    </Section>
  );
};

const MessageAuth = (_props: unknown) => {
  const { act, data } = useBackend<RequestConsoleData>();
  const { recipient, message, msgVerified, msgStamped } = data;

  return (
    <Section
      title="Message Authentication"
      buttons={
        <Button
          icon="arrow-left"
          onClick={() => act('setScreen', { setScreen: 0 })}
        >
          Back
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Recipient">{recipient}</LabeledList.Item>
        <LabeledList.Item label="Message">{message}</LabeledList.Item>
        <LabeledList.Item label="Validated by" color="green">
          {msgVerified}
        </LabeledList.Item>
        <LabeledList.Item label="Stamped by" color="blue">
          {msgStamped}
        </LabeledList.Item>
      </LabeledList>
      <Button
        fluid
        mt={1}
        textAlign="center"
        icon="envelope"
        onClick={() => act('department', { department: recipient })}
      >
        Send Message
      </Button>
    </Section>
  );
};

const StationAnnouncement = (_props: unknown) => {
  const { act, data } = useBackend<RequestConsoleData>();
  const { message, announceAuth } = data;

  return (
    <Section
      title="Station-Wide Announcement"
      buttons={
        <Button
          icon="arrow-left"
          onClick={() => act('setScreen', { setScreen: 0 })}
        >
          Back
        </Button>
      }
    >
      <Button icon="edit" onClick={() => act('writeAnnouncement')}>
        {message ? message : 'Edit Message'}
      </Button>
      {announceAuth ? (
        <Box mt={1} color="green">
          ID verified. Authentication accepted.
        </Box>
      ) : (
        <Box mt={1}>Swipe your ID card to authenticate yourself.</Box>
      )}
      <Button
        fluid
        mt={1}
        textAlign="center"
        icon="bullhorn"
        disabled={!(announceAuth && message)}
        onClick={() => act('sendAnnouncement')}
      >
        Send Announcement
      </Button>
    </Section>
  );
};

const PrintShippingLabel = (_props: unknown) => {
  const { act, data } = useBackend<RequestConsoleData>();
  const { shipDest, msgVerified, ship_dept } = data;

  return (
    <Section
      title="Print Shipping Label"
      buttons={
        <Button
          icon="arrow-left"
          onClick={() => act('setScreen', { setScreen: 0 })}
        >
          Back
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Destination">{shipDest}</LabeledList.Item>
        <LabeledList.Item label="Validated by">{msgVerified}</LabeledList.Item>
      </LabeledList>
      <Button
        fluid
        mt={1}
        textAlign="center"
        icon="print"
        disabled={!(shipDest && msgVerified)}
        onClick={() => act('printLabel')}
      >
        Print Label
      </Button>
      <Section title="Destinations" mt={1}>
        <LabeledList>
          {ship_dept.map((d) => (
            <LabeledList.Item label={d} key={d}>
              <Button
                selected={shipDest === d}
                onClick={() => act('shipSelect', { shipSelect: d })}
              >
                {shipDest === d ? 'Selected' : 'Select'}
              </Button>
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Section>
    </Section>
  );
};
