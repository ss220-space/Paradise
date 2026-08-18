import { useBackend } from '../../backend';
import { Button, LabeledList } from '../../components';

export const pai_camera_bug = (props: unknown) => {
  const { act } = useBackend();

  return (
    <LabeledList>
      <LabeledList.Item label="Special Syndicate options">
        <Button onClick={() => act('ui_interact')}>Select Monitor</Button>
      </LabeledList.Item>
    </LabeledList>
  );
};
