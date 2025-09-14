import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type SmiteMenuData = {
  all_smites: string[];
  all_descs: string;
  choosen: string;
  reason: string;
};

export const SmiteMenu = (_props: unknown) => {
  const { act, data } = useBackend<SmiteMenuData>();
  const { all_smites, all_descs, choosen, reason } = data;
  return (
    <Window width={460} height={320}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Valve Status">
              <Button
                disabled={!tank_one || !tank_two}
                onClick={() => act('change_choosen')}
              >
                {valve ? 'Open' : 'Closed'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Assembly"
          buttons={
            <Button
              textAlign="center"
              width="150px"
              icon="cog"
              disabled={!attached_device}
              onClick={() => act('device')}
            >
              Configure Assembly
            </Button>
          }
        >
          <LabeledList>
            {attached_device ? (
              <LabeledList.Item label="Attachment">
                <Button
                  icon="eject"
                  disabled={!attached_device}
                  onClick={() => act('remove_device')}
                >
                  {attached_device}
                </Button>
              </LabeledList.Item>
            ) : (
              <NoticeBox textAlign="center">Attach Assembly</NoticeBox>
            )}
          </LabeledList>
        </Section>
        <Section title="Attachment One">
          <LabeledList>
            {tank_one ? (
              <LabeledList.Item label="Attachment">
                <Button
                  icon="eject"
                  disabled={!tank_one}
                  onClick={() => act('tankone')}
                >
                  {tank_one}
                </Button>
              </LabeledList.Item>
            ) : (
              <NoticeBox textAlign="center">Attach Tank</NoticeBox>
            )}
          </LabeledList>
        </Section>
        <Section title="Attachment Two">
          <LabeledList>
            {tank_two ? (
              <LabeledList.Item label="Attachment">
                <Button
                  icon="eject"
                  disabled={!tank_two}
                  onClick={() => act('tanktwo')}
                >
                  {tank_two}
                </Button>
              </LabeledList.Item>
            ) : (
              <NoticeBox textAlign="center">Attach Tank</NoticeBox>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
