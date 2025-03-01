import { useBackend } from '../backend';
import { Button, ProgressBar, LabeledList, Box, Section } from '../components';
import { Window } from '../layouts';

export const UploadPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { selected_target, new_law, id, transmitting, hacked } = data;
  return (
    <Window width={900} height={200}>
      <Window.Content>
        <Section title="Silicon Law Upload">
          <LabeledList>
            <LabeledList.Item label="Selected Target">
              <Button
                disabled={transmitting}
                selected={selected_target ? true : false}
                content={
                  selected_target ? selected_target : 'No target selected'
                }
                onClick={() => act('choose_silicon')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Selected Law">
              <Button
                disabled={transmitting}
                selected={new_law ? true : false}
                content={new_law ? new_law : 'No module installed'}
                onClick={() => act('insert_module')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Authorization">
              <Button
                selected={id ? true : false}
                content={
                  id ? id : hacked ? '$@!ERR0R!@#' : 'No ID card inserted'
                }
                onClick={() => act('authorization')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Upload Laws">
              <Button
                disabled={
                  !selected_target || !new_law || (hacked ? false : !id)
                }
                selected={transmitting ? true : false}
                content={transmitting ? 'STOP UPLOAD' : 'START UPLOAD'}
                onClick={() => act('change_laws')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
