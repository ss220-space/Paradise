import { useBackend } from "../../backend";
import { LabeledList, Button, ProgressBar, Box } from "../../components";

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
      <Button selected content="Подключён" />
    );
  } else if (cable) {
    cableContent = (
      <Button color={"orange"} content="Извлечён" />
    );
  } else {
    cableContent = (
      <Button
        content="Выдвинуть"
        onClick={() => act('cable')}
      />
    );
  }

  let hackContent;
  if (machine) {
    hackContent = (
      <LabeledList.Item label="Взлом">
        <ProgressBar
          ranges={{
            good: [67, Infinity],
            average: [33, 67],
            bad: [-Infinity, 33],
          }}
          value={progress}
          maxValue={100} />
        {inprogress ? (
          <Button
            mt={1}
            color="red"
            content="Отмена"
            onClick={() => act('cancel')}
          />
        ) : (
          <Button
            mt={1}
            content="Начать"
            onClick={() => act('jack')}
          />
        )}
      </LabeledList.Item>
    );
  }

  return (
    <LabeledList>
      <LabeledList.Item label="Дата-кабель">
        {cableContent}
      </LabeledList.Item>
      {hackContent}
    </LabeledList>
  );
};
