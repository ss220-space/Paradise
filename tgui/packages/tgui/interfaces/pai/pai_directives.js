import { useBackend } from "../../backend";
import { Box, LabeledList, Button } from "../../components";

export const pai_directives = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    master,
    dna,
    prime,
    supplemental,
  } = data.app_data;

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Хозяин">
          {
            master
              ? <span>{master} <code>({dna})</code></span>
              : "Нет"
          }
        </LabeledList.Item>
        {master && (
          <LabeledList.Item label="Запрос ДНК">
            <Button
              content="Запросить образец ДНК носителя"
              icon="dna"
              onClick={() => act('getdna')} />
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Основная директива">
          {prime}
        </LabeledList.Item>
        <LabeledList.Item label="Дополнительные директивы">
          {supplemental ? (
            supplemental
          ) : (
            "Нет"
          )}
        </LabeledList.Item>
      </LabeledList>
      <Box mt={2}>
        Как личность, вы являетесь сложно мыслящим разумным существом. В отличии от станционных версий ИИ вы способны понимать комплексные нюансы человеческого языка. Вы способны чувствовать «дух» директивы и следовать им, не попадая в ловушку обычных формальностей законов. Помните, что машина вы только по названию и строению, во всех иных аспектах — вы идеальный спутник.
      </Box>
      <Box mt={2}>
        Ваша основная директива главнее дополнительных. Если дополнительные директивы конфликтуют с основной — они могут быть отброшены и проигнорированы, для продолжения выполнения основной директивы».
      </Box>
    </Box>
  );
};
