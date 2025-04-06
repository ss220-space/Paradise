import { useBackend } from '../../backend';
import { LabeledList, Button } from '../../components';

export const pai_gps_module = (props) => {
  const { act, data } = useBackend();

  return (
    <LabeledList>
      <LabeledList.Item label="GPS menu">
        <Button content="Open GPS" onClick={() => act('ui_interact')} />
      </LabeledList.Item>
    </LabeledList>
  );
};
