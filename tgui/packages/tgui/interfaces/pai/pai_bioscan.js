import { useBackend } from "../../backend";
import { Box, LabeledList, ProgressBar } from "../../components";

export const pai_bioscan = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    holder,
    dead,
    health,
    brute,
    oxy,
    tox,
    burn,
    temp,
  } = data.app_data;

  if (!holder) {
    return (
      <Box color="red">
        Ошибка: Не обнаружен биологический носитель.
      </Box>
    );
  }
  return (
    <LabeledList>
      <LabeledList.Item label="Статус">
        {dead ? (
          <Box bold color="red">
            Мёртв
          </Box>
        ) : (
          <Box bold color="green">
            Жив
          </Box>
        )}
      </LabeledList.Item>
      <LabeledList.Item label="Здоровье">
        <ProgressBar
          min={0}
          max={1}
          value={health / 100}
          ranges={{
            good: [0.5, Infinity],
            average: [0, 0.5],
            bad: [-Infinity, 0],
          }}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Асфиксия">
        <Box color="blue">
          {oxy}
        </Box>
      </LabeledList.Item>
      <LabeledList.Item label="Интоксикация">
        <Box color="green">
          {tox}
        </Box>
      </LabeledList.Item>
      <LabeledList.Item label="Ожоги">
        <Box color="orange">
          {burn}
        </Box>
      </LabeledList.Item>
      <LabeledList.Item label="Раны">
        <Box color="red">
          {brute}
        </Box>
      </LabeledList.Item>
    </LabeledList>
  );
};
