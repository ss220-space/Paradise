import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section, Box } from '../components';
import { Window } from '../layouts';

export const BotClean = (props, context) => {
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
    cleanblood,
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
        <Section title="Настройки процесса уборки">
          <Button.Checkbox
            fluid
            checked={cleanblood}
            content="Убирать кровь"
            disabled={noaccess}
            onClick={() => act('blood')}
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
