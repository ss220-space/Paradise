import { useBackend } from '../../backend';
import { LabeledList, Button } from '../../components';

export const pai_gps_module = (props: unknown) => {
  const { act } = useBackend();

  return (
    <LabeledList>
      <LabeledList.Item label="GPS menu">
        <Button onClick={() => act('ui_interact')}>Open GPS</Button>
      </LabeledList.Item>
    </LabeledList>
  );
};
