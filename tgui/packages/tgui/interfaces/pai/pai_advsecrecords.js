import { useBackend } from '../../backend';
import { LabeledList, Button } from '../../components';

export const pai_advsecrecords = (props) => {
  const { act, data } = useBackend();

  return (
    <LabeledList>
      <LabeledList.Item label="Special Syndicate options:">
        <Button content="Select Records" onClick={() => act('ui_interact')} />
      </LabeledList.Item>
    </LabeledList>
  );
};
