import { Button, LabeledList } from 'tgui-core/components';
import { useBackend } from '../../backend';

export const pai_gps_module = (_props: unknown) => {
  const { act } = useBackend();

  return (
    <LabeledList>
      <LabeledList.Item label="GPS menu">
        <Button onClick={() => act('ui_interact')}>Open GPS</Button>
      </LabeledList.Item>
    </LabeledList>
  );
};
