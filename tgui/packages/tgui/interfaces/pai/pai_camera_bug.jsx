import { useBackend } from '../../backend';
import { LabeledList, Button } from '../../components';

export const pai_camera_bug = (props) => {
  const { act, data } = useBackend();

  return (
    <LabeledList>
      <LabeledList.Item label="Special Syndicate options">
        <Button content="Select Monitor" onClick={() => act('ui_interact')} />
      </LabeledList.Item>
    </LabeledList>
  );
};
