import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type FaxMachineData = {
  scan_name: string;
  authenticated: boolean;
  network: string;
  paper: string;
  destination: string;
  sendError: string;
};

export const FaxMachine = (props: unknown) => {
  const { act, data } = useBackend<FaxMachineData>();
  return (
    <Window width={540} height={300}>
      <Window.Content>
        <Section title="Authorization">
          <LabeledList>
            <LabeledList.Item label="ID Card">
              <Button
                icon={data.scan_name ? 'eject' : 'id-card'}
                selected={!!data.scan_name}
                tooltip={data.scan_name ? 'Eject ID' : 'Insert ID'}
                onClick={() => act('scan')}
              >
                {data.scan_name ? data.scan_name : '-----'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Authorize">
              <Button
                icon={data.authenticated ? 'sign-out-alt' : 'id-card'}
                selected={data.authenticated}
                disabled={!data.scan_name && !data.authenticated}
                onClick={() => act('auth')}
              >
                {data.authenticated ? 'Log Out' : 'Log In'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Fax Menu">
          <LabeledList>
            <LabeledList.Item label="Network">{data.network}</LabeledList.Item>
            <LabeledList.Item label="Document">
              <Button
                icon={data.paper ? 'eject' : 'paperclip'}
                disabled={!data.authenticated && !data.paper}
                onClick={() => act('paper')}
              >
                {data.paper ? data.paper : '-----'}
              </Button>
              {!!data.paper && (
                <Button icon="pencil-alt" onClick={() => act('rename')}>
                  Rename
                </Button>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Sending To">
              <Button
                icon="print"
                disabled={!data.authenticated}
                onClick={() => act('dept')}
              >
                {data.destination ? data.destination : '-----'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Action">
              <Button
                icon="envelope"
                disabled={
                  !data.paper ||
                  !data.destination ||
                  !data.authenticated ||
                  !!data.sendError
                }
                onClick={() => act('send')}
              >
                {data.sendError ? data.sendError : 'Send'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
