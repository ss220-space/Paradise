import { useBackend } from '../../backend';
import { Input, LabeledList, Section } from '../../components';

export const pai_encoder = (props, context) => {
  const { act, data } = useBackend(context);
  const { radio_name, radio_rank } = data.app_data;

  return (
    <Section title="Your name and rank in radio channels">
      <LabeledList>
        <LabeledList.Item label="Your current name and rank">
          {radio_name}, {radio_rank}
        </LabeledList.Item>
        <LabeledList.Item label="Set new name">
          <Input
            onInput={(e, value) => act('set_newname', { newname: value })}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Set new rank">
          <Input
            onInput={(e, value) => act('set_newrank', { newrank: value })}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
