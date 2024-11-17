import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section, Box } from '../components';
import { Window } from '../layouts';

export const BotSecurity = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    locked,
    noaccess,
    maintpanel,
    on,
    autopatrol,
    canhack,
    emagged,
    remote_disabled,
    painame,
    check_id,
    check_weapons,
    check_warrant,
    arrest_mode,
    arrest_declare,
  } = data;
  return (
    <Window width={500} height={500}>
      <Window.Content scrollable>
        <NoticeBox>
          Проведите своей ID-картой, чтобы
          {locked ? 'разблокировать' : 'заблокировать'} этот интерфейс.
        </NoticeBox>
        <Section title="Основные настройки">
          <LabeledList>
            <LabeledList.Item label="Состояние">
              <Button
                icon={on ? 'power-off' : 'times'}
                content={on ? 'Включён' : 'Выключен'}
                selected={on}
                disabled={noaccess}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Режим патрулирования">
              <Button.Checkbox
                fluid
                checked={autopatrol}
                content="Автоматическое патрулирование"
                disabled={noaccess}
                onClick={() => act('autopatrol')}
              />
            </LabeledList.Item>
            {!!maintpanel && (
              <LabeledList.Item label="Панель техобслуживания">
                <Box color="bad">Панель открыта</Box>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Протоколы безопасности">
              <Box color={emagged ? 'bad' : 'good'}>
                {emagged ? 'Отключены' : 'Включены'}
              </Box>
            </LabeledList.Item>
            {!!canhack && (
              <LabeledList.Item label="Взлом">
                <Button
                  icon="terminal"
                  content={
                    emagged ? 'Восстановить протоколы безопасности' : 'Взломать'
                  }
                  disabled={noaccess}
                  color="bad"
                  onClick={() => act('hack')}
                />
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Удалённый доступ">
              <Button.Checkbox
                fluid
                checked={!remote_disabled}
                content="Удалённый доступ со стороны ИИ"
                disabled={noaccess}
                onClick={() => act('disableremote')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Задерживаемые цели">
          <Button.Checkbox
            fluid
            checked={check_id}
            content="Неопознанные личности"
            disabled={noaccess}
            onClick={() => act('authid')}
          />
          <Button.Checkbox
            fluid
            checked={check_weapons}
            content="Имеющие неавторизированное оружие"
            disabled={noaccess}
            onClick={() => act('authweapon')}
          />
          <Button.Checkbox
            fluid
            checked={check_warrant}
            content="Разыскиваемые преступники"
            disabled={noaccess}
            onClick={() => act('authwarrant')}
          />
        </Section>
        <Section title="Процедура задержания">
          <Button.Checkbox
            fluid
            checked={arrest_mode}
            content="Бессрочное оглушение целей вместо задержания"
            disabled={noaccess}
            onClick={() => act('arrtype')}
          />
          <Button.Checkbox
            fluid
            checked={arrest_declare}
            content="Сообщать о задержании по радиосвязи"
            disabled={noaccess}
            onClick={() => act('arrdeclare')}
          />
        </Section>
        {painame && (
          <Section title="ПИИ">
            <Button
              fluid
              icon="eject"
              content={painame}
              disabled={noaccess}
              onClick={() => act('ejectpai')}
            />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
