import { useBackend } from '../backend';
import { ReactNode, useState } from 'react';
import {
  Button,
  LabeledList,
  Box,
  Section,
  Collapsible,
  Input,
  Stack,
  TextArea,
} from '../components';
import { Window } from '../layouts';

const windows = {
  1: () => <MainPage />,
  2: () => <StatusScreens />,
  3: () => (
    <Stack.Item grow>
      <Section fill>
        <MessageView />
      </Section>
    </Stack.Item>
  ),
  4: () => <AdminAnnouncePage />,
  default: () =>
    'Ошибка. Неизвестное menu_state. Пожалуйста, свяжитесь с Технической Поддержкой NT.',
};

const PickWindow = (index: number) => windows[index];

type CommunicationsComputerData = {
  menu_state: number;
  authenticated: number;
  noauthbutton: boolean;
  esc_section: number;
  esc_callable: boolean;
  esc_recallable: boolean;
  esc_status: number;
  authhead: boolean;
  is_ai: boolean;
  lastCallLoc: string;
  is_admin: boolean;
  gamma_armory_location: string;
  admin_levels: SecLevel[];
  ert_allowed: boolean;
  msg_cooldown: number;
  emagged: boolean;
  cc_cooldown: number;
  security_level_color: string;
  str_security_level: string;
  levels: SecLevel[];
  authcapt: boolean;
  messages: Message[];
  current_message_title: string;
  current_message: string;
  security_level: string;
  stat_display: StatDisplay;
};

type SecLevel = {
  id: string;
  name: string;
  tooltip: string;
  icon: string;
};

type StatDisplay = {
  alerts: Alert[];
  presets: Preset[];
  type: string;
  icon: string;
  line_1: string;
  line_2: string;
};

type Preset = {
  id: string;
  label: string;
  name: string;
};

type Alert = {
  label: string;
  alert: string;
};

type Message = {
  id: string;
  title: string;
};

export const CommunicationsComputer = (props: unknown) => {
  const { data } = useBackend<CommunicationsComputerData>();

  const { menu_state } = data;

  return (
    <Window width={500} height={600} title="Консоль связи">
      <Window.Content scrollable>
        <Stack fill vertical>
          <AuthBlock />
          {PickWindow(menu_state)()}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const AuthBlock = (props: unknown) => {
  const { act, data } = useBackend<CommunicationsComputerData>();

  const {
    authenticated,
    noauthbutton,
    esc_section,
    esc_callable,
    esc_recallable,
    esc_status,
    authhead,
    is_ai,
    lastCallLoc,
  } = data;

  let hideLogButton = false;
  let authReadable: string;
  if (!authenticated) {
    authReadable = 'Вход не выполнен';
  } else if (authenticated === 1) {
    authReadable = 'Командование';
  } else if (authenticated === 2) {
    authReadable = 'Капитан';
  } else if (authenticated === 3) {
    authReadable = 'Офицер Центрального Командования';
  } else if (authenticated === 4) {
    authReadable = 'Защищённый канал ЦентКома';
    hideLogButton = true;
  } else {
    authReadable = 'ОШИБКА: Сообщите об этом баге!';
  }

  return (
    <>
      <Stack.Item>
        <Section title="Аутентификация">
          <LabeledList>
            {(hideLogButton && (
              <LabeledList.Item label="Доступ">{authReadable}</LabeledList.Item>
            )) || (
              <LabeledList.Item label="Действия">
                <Button
                  icon={authenticated ? 'sign-out-alt' : 'id-card'}
                  selected={authenticated}
                  disabled={noauthbutton}
                  onClick={() => act('auth')}
                >
                  {authenticated ? 'Выйти (' + authReadable + ')' : 'Войти'}
                </Button>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        {!!esc_section && (
          <Section fill title="Эвакуационный шаттл">
            <LabeledList>
              {!!esc_status && (
                <LabeledList.Item label="Статус">{esc_status}</LabeledList.Item>
              )}
              {!!esc_callable && (
                <LabeledList.Item label="Опции">
                  <Button
                    icon="rocket"
                    disabled={!authhead}
                    onClick={() => act('callshuttle')}
                  >
                    Вызвать шаттл
                  </Button>
                </LabeledList.Item>
              )}
              {!!esc_recallable && (
                <LabeledList.Item label="Опции">
                  <Button
                    icon="times"
                    disabled={!authhead || is_ai}
                    onClick={() => act('cancelshuttle')}
                  >
                    Отозвать шаттл
                  </Button>
                </LabeledList.Item>
              )}
              {!!lastCallLoc && (
                <LabeledList.Item label="Последний вызов/отзыв из">
                  {lastCallLoc}
                </LabeledList.Item>
              )}
            </LabeledList>
          </Section>
        )}
      </Stack.Item>
    </>
  );
};

const MainPage = (props: unknown) => {
  const { data } = useBackend<CommunicationsComputerData>();

  const { is_admin } = data;

  if (is_admin) {
    return <AdminPage />;
  }
  return <PlayerPage />;
};

const AdminPage = (props: unknown) => {
  const { act, data } = useBackend<CommunicationsComputerData>();
  const {
    is_admin,
    gamma_armory_location,
    admin_levels,
    authenticated,
    ert_allowed,
  } = data;

  return (
    <Stack.Item>
      <Section title='Действия уровня доступа "Офицер Центрального Командования"'>
        <LabeledList>
          <LabeledList.Item label="Сменить уровень угрозы">
            <MappedAlertLevelButtons
              levels={admin_levels}
              required_access={is_admin}
              use_confirm
            />
          </LabeledList.Item>
          <LabeledList.Item label="Оповещение">
            <Button
              icon="bullhorn"
              disabled={!is_admin}
              onClick={() => act('send_to_cc_announcement_page')}
            >
              Сделать оповещение ЦК
            </Button>
            {authenticated === 4 && (
              <Button
                icon="plus"
                disabled={!is_admin}
                onClick={() => act('make_other_announcement')}
              >
                Сделать другое оповещение
              </Button>
            )}
          </LabeledList.Item>
          <LabeledList.Item label="ОБР">
            <Button
              icon="ambulance"
              disabled={!is_admin}
              onClick={() => act('dispatch_ert')}
            >
              Отправить ОБР
            </Button>
            <Button.Checkbox
              checked={ert_allowed}
              tooltip={
                ert_allowed
                  ? 'Командование может запросить ОБР'
                  : 'ОБР не может быть запрошен'
              }
              disabled={!is_admin}
              onClick={() => act('toggle_ert_allowed')}
              selected={null}
            >
              {ert_allowed ? 'Вызов ОБР разрешён' : 'Вызов ОБР запрещён'}
            </Button.Checkbox>
          </LabeledList.Item>
          <LabeledList.Item label="Ядерная боеголовка">
            <Button.Confirm
              icon="bomb"
              disabled={!is_admin}
              onClick={() => act('send_nuke_codes')}
            >
              Отправить коды аутентификации
            </Button.Confirm>
          </LabeledList.Item>
          <LabeledList.Item label='Оружейный шаттл "Гамма"'>
            <Button.Confirm
              icon="biohazard"
              disabled={!is_admin}
              onClick={() => act('move_gamma_armory')}
            >
              {gamma_armory_location
                ? 'Отправить оружейный шаттл "Гамма"'
                : 'Отозвать оружейный шаттл "Гамма"'}
            </Button.Confirm>
          </LabeledList.Item>
          <LabeledList.Item label="Другое">
            <Button
              icon="fax"
              disabled={!is_admin}
              onClick={() => act('view_fax')}
            >
              Факс-менеджер
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Collapsible title="Просмотр дейстий, доступных для командования">
        <PlayerPage />
      </Collapsible>
    </Stack.Item>
  );
};

const PlayerPage = (props: unknown) => {
  const { act, data } = useBackend<CommunicationsComputerData>();

  const {
    msg_cooldown,
    emagged,
    cc_cooldown,
    security_level_color,
    str_security_level,
    levels,
    authcapt,
    authhead,
    messages,
  } = data;

  let announceText = 'Сделать приоритетное оповещение';
  if (msg_cooldown > 0) {
    announceText += ' (' + msg_cooldown + 's)';
  }

  let ccMessageText = emagged ? 'Сообщение [НЕИЗВЕСТНО]' : 'Сообщение ЦК';
  let nukeRequestText = 'Запросить коды аутентификации';
  if (cc_cooldown > 0) {
    ccMessageText += ' (' + cc_cooldown + 's)';
    nukeRequestText += ' (' + cc_cooldown + 's)';
  }

  return (
    <>
      <Stack.Item grow>
        <Section fill title='Действия уровня доступа "Капитан"'>
          <LabeledList>
            <LabeledList.Item
              label="Текущий уровень угрозы"
              color={security_level_color}
            >
              {str_security_level}
            </LabeledList.Item>
            <LabeledList.Item label="Сменить уровень угрозы">
              <MappedAlertLevelButtons
                levels={levels}
                required_access={authcapt}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Оповещение">
              <Button
                icon="bullhorn"
                disabled={!authcapt || msg_cooldown > 0}
                onClick={() => act('announce')}
              >
                {announceText}
              </Button>
            </LabeledList.Item>
            {(!!emagged && (
              <LabeledList.Item label="Передача">
                <Button
                  icon="broadcast-tower"
                  color="red"
                  disabled={!authcapt || cc_cooldown > 0}
                  onClick={() => act('MessageSyndicate')}
                >
                  {ccMessageText}
                </Button>
                <Button
                  icon="sync-alt"
                  disabled={!authcapt}
                  onClick={() => act('RestoreBackup')}
                >
                  Сбросить реле
                </Button>
              </LabeledList.Item>
            )) || (
              <LabeledList.Item label="Передача">
                <Button
                  icon="broadcast-tower"
                  disabled={!authcapt || cc_cooldown > 0}
                  onClick={() => act('MessageCentcomm')}
                >
                  {ccMessageText}
                </Button>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Ядерная боеголовка">
              <Button
                icon="bomb"
                disabled={!authcapt || cc_cooldown > 0}
                onClick={() => act('nukerequest')}
              >
                {nukeRequestText}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section fill title='Действия уровня доступа "Командование"'>
          <LabeledList>
            <LabeledList.Item label="Дисплеи">
              <Button
                icon="tv"
                disabled={!authhead}
                onClick={() => act('status')}
              >
                Изменение Дисплеев статуса
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Входящие сообщения">
              <Button
                icon="folder-open"
                disabled={!authhead}
                onClick={() => act('messagelist')}
              >
                {'Просмотреть (' + messages.length + ')'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </>
  );
};

const StatusScreens = (props: unknown) => {
  const { act, data } = useBackend<CommunicationsComputerData>();

  const { stat_display, authhead } = data;

  let presetButtons = stat_display.presets.map((pb) => {
    return (
      <Button
        key={pb.name}
        selected={pb.name === stat_display.type}
        disabled={!authhead}
        onClick={() => act('setstat', { statdisp: pb.id })}
      >
        {pb.label}
      </Button>
    );
  });
  let iconButtons = stat_display.alerts.map((ib) => {
    return (
      <Button
        key={ib.alert}
        selected={ib.alert === stat_display.icon}
        disabled={!authhead}
        onClick={() => act('setstat', { statdisp: 3, alert: ib.alert })}
      >
        {ib.label}
      </Button>
    );
  });

  return (
    <Stack.Item grow>
      <Section
        fill
        title="Изменить экраны статуса"
        buttons={
          <Button icon="arrow-circle-left" onClick={() => act('main')}>
            Вернуться в основное меню
          </Button>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Пресеты">{presetButtons}</LabeledList.Item>
          <LabeledList.Item label="Оповещения">{iconButtons}</LabeledList.Item>
          <LabeledList.Item label="Сообщение Строка 1">
            <Button
              icon="pencil-alt"
              disabled={!authhead}
              onClick={() => act('setmsg1')}
            >
              {stat_display.line_1}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Сообщение Строка 2">
            <Button
              icon="pencil-alt"
              disabled={!authhead}
              onClick={() => act('setmsg2')}
            >
              {stat_display.line_2}
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const MessageView = (props: unknown) => {
  const { act, data } = useBackend<CommunicationsComputerData>();

  const { authhead, current_message_title, current_message, messages } = data;

  let messageView: ReactNode;
  if (current_message_title) {
    messageView = (
      <Stack.Item>
        <Section
          title={current_message_title}
          buttons={
            <Button
              icon="times"
              disabled={!authhead}
              onClick={() => act('messagelist')}
            >
              Вернуться к списку сообщений
            </Button>
          }
        >
          <Box>{current_message}</Box>
        </Section>
      </Stack.Item>
    );
  } else {
    let messageRows = messages.map((m) => {
      return (
        <LabeledList.Item key={m.id} label={m.title}>
          <Button
            icon="eye"
            disabled={!authhead || current_message_title === m.title}
            onClick={() => act('messagelist', { msgid: m.id })}
          >
            Просмотреть
          </Button>
          <Button.Confirm
            icon="times"
            disabled={!authhead}
            onClick={() => act('delmessage', { msgid: m.id })}
          >
            Удалить
          </Button.Confirm>
        </LabeledList.Item>
      );
    });
    messageView = (
      <Section
        title="Сообщение получено"
        buttons={
          <Button icon="arrow-circle-left" onClick={() => act('main')}>
            Вернуться в Основное меню
          </Button>
        }
      >
        <LabeledList>{messageRows}</LabeledList>
      </Section>
    );
  }

  return <Box>{messageView}</Box>;
};

type AlertLevelsProps = {
  levels: SecLevel[];
  required_access: boolean;
  use_confirm?: boolean;
};

const MappedAlertLevelButtons = (props: AlertLevelsProps) => {
  const { act, data } = useBackend<CommunicationsComputerData>();

  const { levels, required_access, use_confirm } = props;
  const { security_level } = data;

  if (use_confirm) {
    return levels.map((slevel) => {
      return (
        <Button.Confirm
          key={slevel.name}
          icon={slevel.icon}
          disabled={!required_access || slevel.id === security_level}
          tooltip={slevel.tooltip}
          onClick={() => act('newalertlevel', { level: slevel.id })}
        >
          {slevel.name}
        </Button.Confirm>
      );
    });
  }

  return levels.map((slevel) => {
    return (
      <Button
        key={slevel.name}
        icon={slevel.icon}
        disabled={!required_access || slevel.id === security_level}
        tooltip={slevel.tooltip}
        onClick={() => act('newalertlevel', { level: slevel.id })}
      >
        {slevel.name}
      </Button>
    );
  });
};

const AdminAnnouncePage = (props: unknown) => {
  const { act, data } = useBackend<CommunicationsComputerData>();
  const { is_admin } = data;

  if (!is_admin) {
    act('main');
    return null;
  }

  const [subtitle, setSubtitle] = useState('');
  const [text, setText] = useState('');
  const [classified, setClassified] = useState(false);
  const [beepsound, setBeepsound] = useState('Beep');

  return (
    <Stack.Item>
      <Section
        title="Оповещение ЦК"
        height={30}
        buttons={
          <Button icon="arrow-circle-left" onClick={() => act('main')}>
            Вернуться в Основное меню
          </Button>
        }
      >
        <Stack vertical fill>
          <Stack.Item>
            <Input
              placeholder="Введите заголовок тут."
              fluid
              value={subtitle}
              onChange={setSubtitle}
              mb="5px"
            />
          </Stack.Item>
          <Stack.Item>
            <TextArea
              placeholder="Введите текст объявления. Многострочный ввод принимается."
              fluid
              height={18}
              value={text}
              onChange={setText}
            />
          </Stack.Item>
          <Stack.Item>
            <Button.Checkbox
              checked={classified}
              fluid
              m="5px"
              tooltip={
                classified
                  ? 'Отправить на консоли связи станции'
                  : 'Публично объявить'
              }
              onClick={() => setClassified(!classified)}
            >
              Засекречено
            </Button.Checkbox>
          </Stack.Item>
          <Stack.Item>
            <Button.Confirm
              fluid
              icon="paper-plane"
              mt="5px"
              textAlign="center"
              align="center"
              onClick={() =>
                act('make_cc_announcement', {
                  subtitle: subtitle,
                  text: text,
                  classified: classified,
                  beepsound: beepsound,
                })
              }
            >
              Сделать объявление
            </Button.Confirm>
          </Stack.Item>
        </Stack>
      </Section>
    </Stack.Item>
  );
};
