import { useBackend } from "../../backend";
import { LabeledList, Button } from "../../components";

export const pai_gps_module = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <LabeledList>
      <LabeledList.Item label="GPS menu">
        <Button
          content="Open GPS"
          onClick={() => act('ui_interact')} />
      </LabeledList.Item>
    </LabeledList>
  );

};
