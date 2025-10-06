import { useBackend } from '../backend';
import {
  Button,
  Section,
  NoticeBox,
  LabeledList,
  Collapsible,
  ByondUi,
  Dropdown,
} from '../components';
import { Window } from '../layouts';
import { toTitleCase } from 'common/string';

type CustomAllowData = {
  ckeys: string[];
  custom_view: string;
  sprite_types: string[];
  name: string;
  desc: string;
};

export const CustomAllower = (props: unknown) => {
  const { act, data } = useBackend<CustomAllowData>();
  const { name, desc, sprite_types, ckeys, custom_view } = data;

  return (
    <Window width={400} height={480}>
      <Window.Content>
        <Section title={name}>
          <Dropdown
            selected={Object.keys(ckeys)[1]}
            options={Object.keys(ckeys)}
            width="50%"
            onSelected={(v) =>
              act('select_user', {
                ckey: v,
              })
            }
          />
          {Object.keys(ckeys)}
          <ByondUi
            width="256px"
            height="256px"
            params={{
              id: custom_view,
              zoom: 5,
              type: 'map',
            }}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
