import { Button, LabeledList, Section } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type UploadPanelData = {
  selected_target: string;
  new_law: string;
  id: string;
  transmitting: boolean;
  hacked: boolean;
};

export const UploadPanel = (_props: unknown) => {
  const { act, data } = useBackend<UploadPanelData>();
  const { selected_target, new_law, id, transmitting, hacked } = data;
  return (
    <Window width={900} height={200}>
      <Window.Content>
        <Section title="Silicon Law Upload">
          <LabeledList>
            <LabeledList.Item label="Selected Target">
              <Button
                disabled={transmitting}
                selected={!!selected_target}
                onClick={() => act('choose_silicon')}
              >
                {selected_target ? selected_target : 'No target selected'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Selected Law">
              <Button
                disabled={transmitting}
                selected={!!new_law}
                onClick={() => act('insert_module')}
              >
                {new_law ? new_law : 'No module installed'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Authorization">
              <Button selected={!!id} onClick={() => act('authorization')}>
                {id ? id : hacked ? '$@!ERR0R!@#' : 'No ID card inserted'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Upload Laws">
              <Button
                disabled={
                  !selected_target || !new_law || (hacked ? false : !id)
                }
                selected={!!transmitting}
                onClick={() => act('change_laws')}
              >
                {transmitting ? 'STOP UPLOAD' : 'START UPLOAD'}
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
