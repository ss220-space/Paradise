import { Button, LabeledList } from 'tgui-core/components';
import { useBackend } from '../../backend';

export const pai_camera_bug = (_props: unknown) => {
  const { act } = useBackend();

  return (
    <LabeledList>
      <LabeledList.Item label="Special Syndicate options">
        <Button onClick={() => act('ui_interact')}>Select Monitor</Button>
      </LabeledList.Item>
    </LabeledList>
  );
};
