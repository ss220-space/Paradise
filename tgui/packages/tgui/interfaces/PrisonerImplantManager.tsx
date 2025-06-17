import { useBackend } from '../backend';
import { Button, Section, Box, Stack } from '../components';
import { LabeledList } from '../components/LabeledList';
import { ComplexModal, modalOpen } from './common/ComplexModal';
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';
import { Window } from '../layouts';

type PrisonerImplantManagerData = {
  loginState: LoginState;
  prisonerInfo: PrisonerInfo;
  chemicalInfo: ChemicalInfo[];
  trackingInfo: TrackingInfo[];
};

type PrisonerInfo = {
  name: string;
  points: number;
  goal: number;
};

type Implant = {
  name: string;
  uid: string;
};

type ChemicalInfo = {
  volume: number;
} & Implant;

type TrackingInfo = {
  subject: string;
  location: string;
  health: number;
} & Implant;

export const PrisonerImplantManager = (_props: unknown) => {
  const { act, data } = useBackend<PrisonerImplantManagerData>();
  const { loginState, prisonerInfo, chemicalInfo, trackingInfo } = data;

  if (!loginState.logged_in) {
    return (
      <Window theme="security" width={500} height={850}>
        <Window.Content>
          <LoginScreen />
        </Window.Content>
      </Window>
    );
  }

  let injectionAmount = [1, 5, 10]; // used for auto generating chemical implant inject buttons

  return (
    <Window theme="security" width={500} height={850}>
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <LoginInfo />
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Система управления очками заключённых"
            >
              <LabeledList>
                <LabeledList.Item label="Заключённый">
                  <Button
                    icon={prisonerInfo.name ? 'eject' : 'id-card'}
                    selected={!!prisonerInfo.name}
                    tooltip={
                      prisonerInfo.name
                        ? 'Вытащить ID-карту'
                        : 'Вставить ID-карту'
                    }
                    onClick={() => act('id_card')}
                  >
                    {prisonerInfo.name ? prisonerInfo.name : '-----'}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Очки">
                  {prisonerInfo.points !== null ? prisonerInfo.points : '-/-'}
                  <Button
                    ml={2}
                    icon="minus-square"
                    disabled={prisonerInfo.points === null}
                    onClick={() => act('reset_points')}
                  >
                    Сбросить
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Цель">
                  {prisonerInfo.goal !== null ? prisonerInfo.goal : '-/-'}
                  <Button
                    ml={2}
                    icon="pen"
                    disabled={prisonerInfo.goal === null}
                    onClick={() => modalOpen('set_points')}
                  >
                    Изменить
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item>
                  {!!prisonerInfo.goal && (
                    <Box>
                      1 минута заключения эквивалентна 100 очкам
                      <br />
                      Количество очков не должно привышать 6000
                      <br />
                      Вечным каторожникам не указывается количество очков
                      <br />
                      Заключённые, набравшие необходимое количество очков,
                      смогут самостоятельно вернуться на станцию и получить
                      доступ к своему шкафчику.
                    </Box>
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title="Отслеживающие импланты">
              {trackingInfo.map((implant) => (
                <>
                  <Box p={1} backgroundColor={'rgba(255, 255, 255, 0.05)'}>
                    <Box bold>Субъект: {implant.subject}</Box>
                    <Box key={implant.subject}>
                      {' '}
                      <br />
                      <LabeledList>
                        <LabeledList.Item label="Локация">
                          {implant.location}
                        </LabeledList.Item>
                        <LabeledList.Item label="Состояние здоровья">
                          {implant.health}
                        </LabeledList.Item>
                        <LabeledList.Item label="Заключённый">
                          <Button
                            icon="exclamation-triangle"
                            tooltip="Передать сообщение"
                            onClick={() =>
                              modalOpen('warn', {
                                uid: implant.uid,
                              })
                            }
                          >
                            Предупредить
                          </Button>
                        </LabeledList.Item>
                      </LabeledList>
                    </Box>
                  </Box>
                  <br />
                </>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title="Химические импланты">
              {chemicalInfo.map((implant) => (
                <>
                  <Box p={1} backgroundColor={'rgba(255, 255, 255, 0.05)'}>
                    <Box bold>Субъект: {implant.name}</Box>
                    <Box key={implant.name}>
                      {' '}
                      <br />
                      <LabeledList>
                        <LabeledList.Item label="Оставшиеся реагенты">
                          {implant.volume}
                        </LabeledList.Item>
                      </LabeledList>
                      {injectionAmount.map((amount) => (
                        <Button
                          mt={2}
                          key={amount}
                          disabled={implant.volume < amount}
                          icon="syringe"
                          onClick={() =>
                            act('inject', {
                              uid: implant.uid,
                              amount: amount,
                            })
                          }
                        >{`Ввести ${amount}u`}</Button>
                      ))}
                    </Box>
                  </Box>
                  <br />
                </>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
