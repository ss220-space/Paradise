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
            <Section fill scrollable title="Prisoner Points Manager System">
              <LabeledList>
                <LabeledList.Item label="Prisoner">
                  <Button
                    icon={prisonerInfo.name ? 'eject' : 'id-card'}
                    selected={!!prisonerInfo.name}
                    tooltip={prisonerInfo.name ? 'Eject ID' : 'Insert ID'}
                    onClick={() => act('id_card')}
                  >
                    {prisonerInfo.name ? prisonerInfo.name : '-----'}
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Points">
                  {prisonerInfo.points !== null ? prisonerInfo.points : '-/-'}
                  <Button
                    ml={2}
                    icon="minus-square"
                    disabled={prisonerInfo.points === null}
                    onClick={() => act('reset_points')}
                  >
                    Reset
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item label="Point Goal">
                  {prisonerInfo.goal !== null ? prisonerInfo.goal : '-/-'}
                  <Button
                    ml={2}
                    icon="pen"
                    disabled={prisonerInfo.goal === null}
                    onClick={() => modalOpen('set_points')}
                  >
                    Edit
                  </Button>
                </LabeledList.Item>
                <LabeledList.Item>
                  {!!prisonerInfo.goal && (
                    <Box>
                      1 minute of prison time should roughly equate to 150
                      points.
                      <br />
                      <br />
                      Sentences should not exceed 5000 points.
                      <br />
                      <br />
                      Permanent prisoners should not be given a point goal.
                      <br />
                      <br />
                      Prisoners who meet their point goal will be able to
                      automatically access their locker and return to the
                      station using the shuttle.
                    </Box>
                  )}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable title="Tracking Implants">
              {trackingInfo.map((implant) => (
                <>
                  <Box p={1} backgroundColor={'rgba(255, 255, 255, 0.05)'}>
                    <Box bold>Subject: {implant.subject}</Box>
                    <Box key={implant.subject}>
                      {' '}
                      <br />
                      <LabeledList>
                        <LabeledList.Item label="Location">
                          {implant.location}
                        </LabeledList.Item>
                        <LabeledList.Item label="Health">
                          {implant.health}
                        </LabeledList.Item>
                        <LabeledList.Item label="Prisoner">
                          <Button
                            icon="exclamation-triangle"
                            tooltip="Broadcast a message to this poor sod"
                            onClick={() =>
                              modalOpen('warn', {
                                uid: implant.uid,
                              })
                            }
                          >
                            Warn
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
            <Section fill scrollable title="Chemical Implants">
              {chemicalInfo.map((implant) => (
                <>
                  <Box p={1} backgroundColor={'rgba(255, 255, 255, 0.05)'}>
                    <Box bold>Subject: {implant.name}</Box>
                    <Box key={implant.name}>
                      {' '}
                      <br />
                      <LabeledList>
                        <LabeledList.Item label="Remaining Reagents">
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
                        >{`Inject ${amount}u`}</Button>
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
