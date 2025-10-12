import { useBackend } from '../backend';
import {
  Button,
  Section,
  NoticeBox,
  LabeledList,
  Collapsible,
  ByondUi,
  Dropdown,
  Stack,
} from '../components';
import { Window } from '../layouts';
import { toTitleCase } from 'common/string';

type CustomAllowData = {
  ckeys: string[];
  choosen_ckey: string;
  custom_view: string;
  sprite_types: string[];
  choosen_icon: string;
  name: string;
  desc: string;
};

export const CustomAllower = (props: unknown) => {
  const { act, data } = useBackend<CustomAllowData>();
  const {
    name,
    desc,
    sprite_types,
    ckeys,
    custom_view,
    choosen_ckey,
    choosen_icon,
  } = data;

  return (
    <Window width={800} height={480}>
      <Window.Content>
        <Section title={name} fill>
          <Stack>
            <Stack.Item>
              <ByondUi
                width="256px"
                height="256px"
                params={{
                  id: custom_view,
                  zoom: 5,
                  type: 'map',
                }}
              />
            </Stack.Item>
            <Stack.Item grow>
              <Dropdown
                selected={choosen_ckey}
                options={Object.keys(ckeys)}
                width="50%"
                onSelected={(v) =>
                  act('select_user', {
                    ckey: v,
                  })
                }
              />
              <Dropdown
                selected={choosen_icon}
                options={Object.keys(sprite_types)}
                width="50%"
                onSelected={(v) =>
                  act('select_icon', {
                    icon_name: v,
                  })
                }
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
