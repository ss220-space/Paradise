import { useBackend } from '../backend';
import { Box, Button, Section, LabeledList } from '../components';
import { Window } from '../layouts';

type KeycardAuthData = {
  swiping: boolean;
  busy: boolean;
  hasSwiped: boolean;
  redAvailable: boolean;
  ertreason: string;
  event: string;
  hasConfirm: boolean;
  isRemote: boolean;
};
export const KeycardAuth = (props: unknown) => {
  const { act, data } = useBackend<KeycardAuthData>();
  let infoBox = (
    <Section title="Устройство аутентификации">
      <Box>
        Используется для запуска определенных протоколов повышенного уровня
        безопасности. Оно требует одновременного считывания двух ID-карт
        повышенного уровня допуска.
      </Box>
    </Section>
  );
  if (!data.swiping && !data.busy) {
    return (
      <Window width={540} height={280}>
        <Window.Content>
          {infoBox}
          <Section title="Выберите действие">
            <LabeledList>
              <LabeledList.Item label="Красный код">
                <Button
                  icon="exclamation-triangle"
                  disabled={!data.redAvailable}
                  onClick={() =>
                    act('triggerevent', { 'triggerevent': 'Red Alert' })
                  }
                >
                  Красный код
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="ОБР">
                <Button
                  icon="broadcast-tower"
                  onClick={() =>
                    act('triggerevent', {
                      'triggerevent': 'Emergency Response Team',
                    })
                  }
                >
                  Запросить ОБР
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Экстренный доступ в технические тоннели">
                <Button
                  icon="door-open"
                  onClick={() =>
                    act('triggerevent', {
                      'triggerevent': 'Grant Emergency Maintenance Access',
                    })
                  }
                >
                  Разрешить
                </Button>
                <Button
                  icon="door-closed"
                  onClick={() =>
                    act('triggerevent', {
                      'triggerevent': 'Revoke Emergency Maintenance Access',
                    })
                  }
                >
                  Отозвать
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Экстренный доступ во все отсеки станции">
                <Button
                  icon="door-open"
                  onClick={() =>
                    act('triggerevent', {
                      'triggerevent': 'Activate Station-Wide Emergency Access',
                    })
                  }
                >
                  Разрешить
                </Button>
                <Button
                  icon="door-closed"
                  onClick={() =>
                    act('triggerevent', {
                      'triggerevent':
                        'Deactivate Station-Wide Emergency Access',
                    })
                  }
                >
                  Отозвать
                </Button>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Window.Content>
      </Window>
    );
  } else {
    let swipeInfo = <Box color="red">Проведите вашей ID-картой...</Box>;
    if (
      !data.hasSwiped &&
      !data.ertreason &&
      data.event === 'Emergency Response Team'
    ) {
      swipeInfo = (
        <Box color="red">
          Укажите причину запроса отряда быстрого реагирования.
        </Box>
      );
    } else if (data.hasConfirm) {
      swipeInfo = <Box color="green">Запрос подтвержден!</Box>;
    } else if (data.isRemote) {
      swipeInfo = (
        <Box color="orange">Проведите картой, чтобы ПОДТВЕРДИТЬ запрос.</Box>
      );
    } else if (data.hasSwiped) {
      swipeInfo = (
        <Box color="orange">
          Ожидаю подтверждения от другого пользователя...
        </Box>
      );
    }
    return (
      <Window width={540} height={265}>
        <Window.Content>
          {infoBox}
          {data.event === 'Emergency Response Team' && (
            <Section title="Причина вызова ОБР">
              <Box>
                <Button
                  color={data.ertreason ? '' : 'red'}
                  icon={data.ertreason ? 'check' : 'pencil-alt'}
                  disabled={data.busy}
                  onClick={() => act('ert')}
                >
                  {data.ertreason ? data.ertreason : '-----'}
                </Button>
              </Box>
            </Section>
          )}
          <Section
            title={data.event}
            buttons={
              <Button
                icon="arrow-circle-left"
                disabled={data.busy || data.hasConfirm}
                onClick={() => act('reset')}
              >
                Назад
              </Button>
            }
          >
            {swipeInfo}
          </Section>
        </Window.Content>
      </Window>
    );
  }
};
