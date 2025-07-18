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
        <Section title="Авторизация">
          <LabeledList>
            <LabeledList.Item label="ID Карта:">
              <Button
                icon={data.scan_name ? 'eject' : 'id-card'}
                selected={!!data.scan_name}
                tooltip={data.scan_name ? 'Достать карту' : 'Вставить карту'}
                onClick={() => act('scan')}
              >
                {data.scan_name ? data.scan_name : '-----'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Войти:">
              <Button
                icon={data.authenticated ? 'sign-out-alt' : 'id-card'}
                selected={data.authenticated}
                disabled={!data.scan_name && !data.authenticated}
                onClick={() => act('auth')}
              >
                {data.authenticated ? 'Выйти' : 'Войти'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Меню факса">
          <LabeledList>
            <LabeledList.Item label="Сеть">{data.network}</LabeledList.Item>
            <LabeledList.Item label="Документ">
              <Button
                icon={data.paper ? 'eject' : 'paperclip'}
                disabled={!data.authenticated && !data.paper}
                onClick={() => act('paper')}
              >
                {data.paper ? data.paper : '-----'}
              </Button>
              {!!data.paper && (
                <Button icon="pencil-alt" onClick={() => act('rename')}>
                  Переименовать
                </Button>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Отправить в">
              <Button
                icon="print"
                disabled={!data.authenticated}
                onClick={() => act('dept')}
              >
                {data.destination ? data.destination : '-----'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Действие">
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
                {data.sendError ? data.sendError : 'Отправить'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
