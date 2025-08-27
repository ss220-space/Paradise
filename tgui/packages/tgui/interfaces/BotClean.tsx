import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section, Box } from '../components';
import { Window } from '../layouts';

type CleanBotData = {
  cleanblood: boolean;
} & BotControlsData;

export const BotClean = (props: unknown) => {
  const { act, data } = useBackend<CleanBotData>();
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
                selected={on}
                disabled={noaccess}
                onClick={() => act('power')}
              >
                {on ? 'Включён' : 'Выключен'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Режим патрулирования">
              <Button.Checkbox
                fluid
                checked={autopatrol}
                disabled={noaccess}
                onClick={() => act('autopatrol')}
              >
                Автоматическое патрулирование
              </Button.Checkbox>
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
                  disabled={noaccess}
                  color="bad"
                  onClick={() => act('hack')}
                >
                  {emagged ? 'Восстановить протоколы безопасности' : 'Взломать'}
                </Button>
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Удалённый доступ">
              <Button.Checkbox
                fluid
                checked={!remote_disabled}
                disabled={noaccess}
                onClick={() => act('disableremote')}
              >
                Удалённый доступ со стороны ИИ
              </Button.Checkbox>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Настройки процесса уборки">
          <Button.Checkbox
            fluid
            checked={cleanblood}
            disabled={noaccess}
            onClick={() => act('blood')}
          >
            Убирать кровь
          </Button.Checkbox>
        </Section>
        {painame && (
          <Section title="ПИИ">
            <Button
              fluid
              icon="eject"
              disabled={noaccess}
              onClick={() => act('ejectpai')}
            >
              {painame}
            </Button>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
