import { useBackend } from '../../backend';
import { LabeledList, Button } from '../../components';

export const pai_advsecrecords = (props: unknown) => {
  const { act } = useBackend();

  return (
    <LabeledList>
      <LabeledList.Item label="Special Syndicate options:">
        <Button onClick={() => act('ui_interact')}>Select Records</Button>
      </LabeledList.Item>
    </LabeledList>
  );
};
