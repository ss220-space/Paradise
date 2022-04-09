import { useBackend } from "../backend";
import { Button, LabeledList, Section, Box, ProgressBar } from "../components";
import { Window } from "../layouts";

export const BlueSpaceArtilleryControl = (props, context) => {
  const { act, data } = useBackend(context);
  let alertStatus;
  if (data.ready) {
    alertStatus = (
      <LabeledList.Item label="Статус" color="green">
        Готово
      </LabeledList.Item>
    );
  } else if (data.reloadtime_text) {
    alertStatus = (
      <LabeledList.Item label="Перезарядится через" color="red">
        {data.reloadtime_text}
      </LabeledList.Item>
    );
  } else {
    alertStatus = (
      <LabeledList.Item label="Статус" color="red">
        Нет подключенных орудий!
      </LabeledList.Item>
    );
  }
  return (
    <Window>
      <Window.Content>
        <Section>
          <LabeledList>
            {data.notice && (
              <LabeledList.Item label="Тревога" color="red">
                {data.notice}
              </LabeledList.Item>
            )}
            {alertStatus}
            <LabeledList.Item label="Цель">
              <Button
                icon="crosshairs"
                content={data.target ? data.target : "Нет"}
                onClick={() => act("recalibrate")} />
            </LabeledList.Item>
            {data.ready === 1 && !!data.target && (
              <LabeledList.Item label="Стрельба">
                <Button
                  icon="skull"
                  content="ЗАЛП!"
                  color="red"
                  onClick={() => act("fire")} />
              </LabeledList.Item>
            )}
            {!data.connected && (
              <LabeledList.Item label="Обслуживание">
                <Button
                  icon="wrench"
                  content="Завершить установку"
                  onClick={() => act("build")} />
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
