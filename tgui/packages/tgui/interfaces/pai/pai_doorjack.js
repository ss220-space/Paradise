import { useBackend } from "../../backend";
import { LabeledList, Button, Box } from "../../components";

export const pai_doorjack = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    cable,
    machine,
    inprogress,
    progress,
    aborted,
  } = data.app_data;

  let cableContent;

  if (machine) {
    cableContent = (
      <Button selected content="Connected" />
    );
  } else {
    cableContent = (
      <Button
        content={cable ? "Extended" : "Retracted"}
        color={cable ? "orange" : null}
        onClick={() => act('cable')}
      />
    );
  }

  let hackContent;
  if (machine) {
    hackContent = (
      <LabeledList.Item label="Hack">
        <Box color={inprogress ? "green" : "red"}> In progress: {inprogress ? "Yes" : "No"} </Box>
        {inprogress ? (
          <Button
            mt={1}
            color="red"
            content="Abort"
            onClick={() => act('cancel')}
          />
        ) : (
          <Button
            mt={1}
            content="Start"
            onClick={() => act('jack')}
          />
        )}
      </LabeledList.Item>
    );
  }

  return (
    <LabeledList>
      <LabeledList.Item label="Cable">
        {cableContent}
      </LabeledList.Item>
      {hackContent}
    </LabeledList>
  );
};
