import { useBackend } from '../../backend';
import { LabeledList, Box, Button } from '../../components';

type Software = {
  cost: number;
} & Common;

type Toggle = { active: boolean } & Common;

type Emotion = { id: string } & Common;

type Common = {
  icon: string;
  name: string;
  syndi: boolean;
  key: string;
};

type MainMenuData = {
  available_software: Software[];
  installed_software: Software[];
  installed_toggles: Toggle[];
  available_ram: number;
  emotions: Emotion[];
  current_emotion: string;
};

export const pai_main_menu = (props: unknown) => {
  const { act, data } = useBackend<PaiData<MainMenuData>>();
  const {
    available_software,
    installed_software,
    installed_toggles,
    available_ram,
    emotions,
    current_emotion,
  } = data.app_data;

  const installedSoftwareKeys = {};
  installed_software.map((s) => (installedSoftwareKeys[s.key] = s.name));
  installed_toggles.map((s) => (installedSoftwareKeys[s.key] = s.name));

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Available RAM">
          {available_ram}
        </LabeledList.Item>
        <LabeledList.Item label="Available Software">
          {available_software
            .filter((s) => !installedSoftwareKeys[s.key])
            .map((s) => (
              <Button
                key={s.key}
                color={s.syndi ? 'red' : 'default'}
                icon={s.icon}
                disabled={s.cost > available_ram}
                onClick={() => act('purchaseSoftware', { key: s.key })}
              >
                {s.name + ' (' + s.cost + ')'}
              </Button>
            ))}
          {available_software.filter((s) => !installedSoftwareKeys[s.key])
            .length === 0 && 'No software available!'}
        </LabeledList.Item>
        <LabeledList.Item label="Installed Software">
          {installed_software
            .filter((s) => s.key !== 'mainmenu')
            .map((s) => (
              <Button
                key={s.key}
                icon={s.icon}
                onClick={() => act('startSoftware', { software_key: s.key })}
              >
                {s.name}
              </Button>
            ))}
          {installed_software.length === 0 && 'No software installed!'}
        </LabeledList.Item>
        <LabeledList.Item label="Installed Toggles">
          {installed_toggles.map((t) => (
            <Button
              key={t.key}
              icon={t.icon}
              selected={t.active}
              onClick={() => act('setToggle', { toggle_key: t.key })}
            >
              {t.name}
            </Button>
          ))}
          {installed_toggles.length === 0 && 'No toggles installed!'}
        </LabeledList.Item>
        <LabeledList.Item label="Select Emotion">
          {emotions.map((e) => (
            <Button
              key={e.id}
              color={e.syndi ? 'red' : 'default'}
              selected={e.id === current_emotion}
              onClick={() => act('setEmotion', { emotion: e.id })}
            >
              {e.name}
            </Button>
          ))}
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};
