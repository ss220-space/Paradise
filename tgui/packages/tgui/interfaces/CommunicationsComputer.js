import { useBackend, useLocalState } from '../backend';
import {
  Button,
  LabeledList,
  Box,
  Section,
  Collapsible,
  Input,
  Stack,
  Dropdown,
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

const PickWindow = (index) => windows[index];

export const CommunicationsComputer = (props, context) => {
  const { act, data } = useBackend(context);

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

const AuthBlock = (props, context) => {
  const { act, data } = useBackend(context);

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
  let authReadable;
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
                  content={
                    authenticated ? 'Выйти (' + authReadable + ')' : 'Войти'
                  }
                  onClick={() => act('auth')}
                />
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
                    content="Вызвать шаттл"
                    disabled={!authhead}
                    onClick={() => act('callshuttle')}
                  />
                </LabeledList.Item>
              )}
              {!!esc_recallable && (
                <LabeledList.Item label="Опции">
                  <Button
                    icon="times"
                    content="Отозвать шаттл"
                    disabled={!authhead || is_ai}
                    onClick={() => act('cancelshuttle')}
                  />
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

const MainPage = (props, context) => {
  const { act, data } = useBackend(context);

  const { is_admin } = data;

  if (is_admin) {
    return <AdminPage />;
  }
  return <PlayerPage />;
};

const AdminPage = (props, context) => {
  const { act, data } = useBackend(context);
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
              use_confirm={1}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Оповещение">
            <Button
              icon="bullhorn"
              content="Сделать оповещение ЦК"
              disabled={!is_admin}
              onClick={() => act('send_to_cc_announcement_page')}
            />
            {authenticated === 4 && (
              <Button
                icon="plus"
                content="Сделать другое оповещение"
                disabled={!is_admin}
                onClick={() => act('make_other_announcement')}
              />
            )}
          </LabeledList.Item>
          <LabeledList.Item label="ОБР">
            <Button
              icon="ambulance"
              content="Отправить ОБР"
              disabled={!is_admin}
              onClick={() => act('dispatch_ert')}
            />
            <Button.Checkbox
              checked={ert_allowed}
              content={
                ert_allowed ? 'Вызов ОБР разрешён' : 'Вызов ОБР запрещён'
              }
              tooltip={
                ert_allowed
                  ? 'Командование может запросить ОБР'
                  : 'ОБР не может быть запрошен'
              }
              disabled={!is_admin}
              onClick={() => act('toggle_ert_allowed')}
              selected={null}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Ядерная боеголовка">
            <Button.Confirm
              icon="bomb"
              content="Отправить коды аутентификации"
              disabled={!is_admin}
              onClick={() => act('send_nuke_codes')}
            />
          </LabeledList.Item>
          <LabeledList.Item label='Оружейный шаттл "Гамма"'>
            <Button.Confirm
              icon="biohazard"
              content={
                gamma_armory_location
                  ? 'Отправить оружейный шаттл "Гамма"'
                  : 'Отозвать оружейный шаттл "Гамма"'
              }
              disabled={!is_admin}
              onClick={() => act('move_gamma_armory')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Другое">
            <Button
              icon="fax"
              content="Факс-менеджер"
              disabled={!is_admin}
              onClick={() => act('view_fax')}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Collapsible title="Просмотр дейстий, доступных для командования">
        <PlayerPage />
      </Collapsible>
    </Stack.Item>
  );
};

const PlayerPage = (props, context) => {
  const { act, data } = useBackend(context);

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
                content={announceText}
                disabled={!authcapt || msg_cooldown > 0}
                onClick={() => act('announce')}
              />
            </LabeledList.Item>
            {(!!emagged && (
              <LabeledList.Item label="Передача">
                <Button
                  icon="broadcast-tower"
                  color="red"
                  content={ccMessageText}
                  disabled={!authcapt || cc_cooldown > 0}
                  onClick={() => act('MessageSyndicate')}
                />
                <Button
                  icon="sync-alt"
                  content="Сбросить реле"
                  disabled={!authcapt}
                  onClick={() => act('RestoreBackup')}
                />
              </LabeledList.Item>
            )) || (
              <LabeledList.Item label="Передача">
                <Button
                  icon="broadcast-tower"
                  content={ccMessageText}
                  disabled={!authcapt || cc_cooldown > 0}
                  onClick={() => act('MessageCentcomm')}
                />
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Ядерная боеголовка">
              <Button
                icon="bomb"
                content={nukeRequestText}
                disabled={!authcapt || cc_cooldown > 0}
                onClick={() => act('nukerequest')}
              />
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
                content="Изменение Дисплеев статуса"
                disabled={!authhead}
                onClick={() => act('status')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Входящие сообщения">
              <Button
                icon="folder-open"
                content={'Просмотреть (' + messages.length + ')'}
                disabled={!authhead}
                onClick={() => act('messagelist')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </>
  );
};

const StatusScreens = (props, context) => {
  const { act, data } = useBackend(context);

  const { stat_display, authhead, current_message_title } = data;

  let presetButtons = stat_display['presets'].map((pb) => {
    return (
      <Button
        key={pb.name}
        content={pb.label}
        selected={pb.name === stat_display.type}
        disabled={!authhead}
        onClick={() => act('setstat', { statdisp: pb.id })}
      />
    );
  });
  let iconButtons = stat_display['alerts'].map((ib) => {
    return (
      <Button
        key={ib.alert}
        content={ib.label}
        selected={ib.alert === stat_display.icon}
        disabled={!authhead}
        onClick={() => act('setstat', { statdisp: 3, alert: ib.alert })}
      />
    );
  });

  return (
    <Stack.Item grow>
      <Section
        fill
        title="Изменить экраны статуса"
        buttons={
          <Button
            icon="arrow-circle-left"
            content="Вернуться в основное меню"
            onClick={() => act('main')}
          />
        }
      >
        <LabeledList>
          <LabeledList.Item label="Пресеты">{presetButtons}</LabeledList.Item>
          <LabeledList.Item label="Оповещения">{iconButtons}</LabeledList.Item>
          <LabeledList.Item label="Сообщение Строка 1">
            <Button
              icon="pencil-alt"
              content={stat_display.line_1}
              disabled={!authhead}
              onClick={() => act('setmsg1')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Сообщение Строка 2">
            <Button
              icon="pencil-alt"
              content={stat_display.line_2}
              disabled={!authhead}
              onClick={() => act('setmsg2')}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const MessageView = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    authhead,
    current_message_title,
    current_message,
    messages,
    security_level,
  } = data;

  let messageView;
  if (current_message_title) {
    messageView = (
      <Stack.Item>
        <Section
          title={current_message_title}
          buttons={
            <Button
              icon="times"
              content="Вернуться к списку сообщений"
              disabled={!authhead}
              onClick={() => act('messagelist')}
            />
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
            content="Просмотреть"
            disabled={!authhead || current_message_title === m.title}
            onClick={() => act('messagelist', { msgid: m.id })}
          />
          <Button.Confirm
            icon="times"
            content="Удалить"
            disabled={!authhead}
            onClick={() => act('delmessage', { msgid: m.id })}
          />
        </LabeledList.Item>
      );
    });
    messageView = (
      <Section
        title="Сообщение получено"
        buttons={
          <Button
            icon="arrow-circle-left"
            content="Вернуться в Основное меню"
            onClick={() => act('main')}
          />
        }
      >
        <LabeledList>{messageRows}</LabeledList>
      </Section>
    );
  }

  return <Box>{messageView}</Box>;
};

const MappedAlertLevelButtons = (props, context) => {
  const { act, data } = useBackend(context);

  const { levels, required_access, use_confirm } = props;
  const { security_level } = data;

  if (use_confirm) {
    return levels.map((slevel) => {
      return (
        <Button.Confirm
          key={slevel.name}
          icon={slevel.icon}
          content={slevel.name}
          disabled={!required_access || slevel.id === security_level}
          tooltip={slevel.tooltip}
          onClick={() => act('newalertlevel', { level: slevel.id })}
        />
      );
    });
  }

  return levels.map((slevel) => {
    return (
      <Button
        key={slevel.name}
        icon={slevel.icon}
        content={slevel.name}
        disabled={!required_access || slevel.id === security_level}
        tooltip={slevel.tooltip}
        onClick={() => act('newalertlevel', { level: slevel.id })}
      />
    );
  });
};

const AdminAnnouncePage = (props, context) => {
  const { act, data } = useBackend(context);
  const { is_admin } = data;

  if (!is_admin) {
    return act('main');
  }

  const [subtitle, setSubtitle] = useLocalState(context, 'subtitle', '');
  const [text, setText] = useLocalState(context, 'text', '');
  const [classified, setClassified] = useLocalState(context, 'classified', 0);
  const [beepsound, setBeepsound] = useLocalState(context, 'beepsound', 'Beep');

  return (
    <Stack.Item>
      <Section
        title="Оповещение ЦК"
        buttons={
          <Button
            icon="arrow-circle-left"
            content="Вернуться в Основное меню"
            onClick={() => act('main')}
          />
        }
      >
        <Input
          placeholder="Введите заголовок тут."
          fluid
          value={subtitle}
          onChange={(e, value) => setSubtitle(value)}
          mb="5px"
        />
        <Input
          placeholder="Введите текст объявления,\nМногострочный ввод принимается."
          rows={10}
          fluid
          multiline={1}
          value={text}
          onChange={(e, value) => setText(value)}
        />
        <Button.Checkbox
          checked={classified}
          content="Засекречено"
          fluid
          m="5px"
          tooltip={
            classified
              ? 'Отправить на консоли связи станции'
              : 'Публично объявить'
          }
          onClick={() => setClassified(!classified)}
        />
        <Button.Confirm
          content="Сделать объявление"
          fluid
          icon="paper-plane"
          center
          mt="5px"
          textAlign="center"
          onClick={() =>
            act('make_cc_announcement', {
              subtitle: subtitle,
              text: text,
              classified: classified,
              beepsound: beepsound,
            })
          }
        />
      </Section>
    </Stack.Item>
  );
};
