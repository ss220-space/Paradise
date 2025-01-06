import { storage } from 'common/storage';
import { createUuid } from 'common/uuid';
import { useBackend, useLocalState } from '../../backend';
import {
  Button,
  Divider,
  Input,
  NumberInput,
  Section,
  Stack,
} from '../../components';
import { POD_GREY } from './constants';
import { PodLauncherData } from './types';
type Preset = {
  hue: number;
  id: number;
  title: string;
};
const saveDataToPreset = async (id: string, data: any) => {
  await storage.set('podlauncher_preset_' + id, data);
};

type PresetButtonsProps = {
  deletePreset: (id: number) => void;
  editing: boolean;
  loadPreset: (id: number) => void;
  presetIndex: number;
  setEditing: (status: boolean) => void;
  getPresets: () => void;
};

const PresetButtons = (props: PresetButtonsProps, context) => {
  const { data } = useBackend<PodLauncherData>(context);
  const {
    editing,
    deletePreset,
    loadPreset,
    presetIndex,
    setEditing,
    getPresets,
  } = props;
  return (
    <>
      {!editing && (
        <Button
          color="transparent"
          icon="plus"
          onClick={() => setEditing(!editing)}
          tooltip="Новый пресет"
        />
      )}
      <Button
        color="transparent"
        icon="download"
        inline
        onClick={() => saveDataToPreset(presetIndex.toString(), data)}
        tooltip="Сохранить пресет"
        tooltipPosition="bottom"
      />
      <Button
        color="transparent"
        icon="upload"
        inline
        onClick={() => {
          loadPreset(presetIndex);
        }}
        tooltip="Загрузить пресет"
      />
      <Button
        color="transparent"
        icon="trash"
        inline
        onClick={() => deletePreset(presetIndex)}
        tooltip="Удалить выбраный пресет"
        tooltipPosition="bottom-start"
      />
      <Button
        color="transparent"
        icon="refresh"
        inline
        onClick={() => getPresets()}
        tooltip="Обновить список пресетов"
        tooltipPosition="bottom-start"
      />
    </>
  );
};

export const PresetsPage = (props, context) => {
  const { act, data } = useBackend(context);
  const [editing, setEditing] = useLocalState(context, 'editing', false);
  const [hue, setHue] = useLocalState(context, 'hue', 0);
  const [name, setName] = useLocalState(context, 'name', '');
  const [presetID, setPresetID] = useLocalState(context, 'presetID', 0);
  const [presets, setPresets] = useLocalState<Preset[]>(context, 'presets', []);
  const deletePreset = async (deleteID: number) => {
    const newPresets: any[] = [...presets];
    for (let i = 0; i < presets.length; i++) {
      if (presets[i].id === deleteID) {
        newPresets.splice(i, 1);
        break;
      }
    }
    await storage.set('podlauncher_presetlist', newPresets);
    getPresets();
  };
  const loadPreset = async (id) => {
    act('loadDataFromPreset', {
      payload: await storage.get('podlauncher_preset_' + id),
    });
  };
  const newPreset = async (presetName: string, hue: number, data: any) => {
    const newPresets: any[] = [...presets];
    if (!presets) {
      newPresets.push('hi!');
    }
    const id = createUuid();
    const thing = { id, title: presetName, hue };
    newPresets.push(thing);
    setPresets(newPresets);
    await storage.set('podlauncher_presetlist', newPresets);
    saveDataToPreset(id, data);
    getPresets();
  };

  const getPresets = async () => {
    let thing = await storage.get('podlauncher_presetlist');
    if (thing === undefined) {
      thing = [];
    }
    setPresets(thing);
  };

  return (
    <Section
      buttons={
        <PresetButtons
          deletePreset={deletePreset}
          editing={editing}
          loadPreset={loadPreset}
          presetIndex={presetID}
          setEditing={setEditing}
          getPresets={getPresets}
        />
      }
      fill
      scrollable
      title="Пресеты"
    >
      {editing && (
        <Stack vertical>
          <Stack.Item>
            <Input
              autoFocus
              onChange={(e, value) => setName(value)}
              value={name}
              placeholder="Имя пресета"
            />
            <Button
              icon="check"
              inline
              onClick={() => {
                newPreset(name, hue, data);
                setEditing(false);
              }}
              tooltip="Подтвердить"
              tooltipPosition="right"
            />
            <Button
              icon="window-close"
              inline
              onClick={() => {
                setName('');
                setEditing(false);
              }}
              tooltip="Отменить"
            />
          </Stack.Item>
          <Stack.Item>
            <span color="label"> Hue: </span>
            <NumberInput
              animated
              inline
              maxValue={360}
              minValue={0}
              onChange={(e, value) => setHue(value)}
              step={5}
              stepPixelSize={5}
              value={hue}
              width="40px"
            />
          </Stack.Item>
          <Divider />
        </Stack>
      )}
      {(!presets || presets.length === 0) && (
        <span style={POD_GREY}>
          Нажмите [+], чтобы добавить новый пресет. <br /> Если пресеты должны
          быть, но их нет, то обновите список.
        </span>
      )}
      {presets.map((preset, i) => (
        <Button
          backgroundColor={`hsl(${preset.hue}, 50%, 50%)`}
          key={i}
          onClick={() => setPresetID(preset.id)}
          onDoubleClick={() => loadPreset(preset.id)}
          style={
            presetID === preset.id
              ? {
                  'border-width': '1px',
                  'border-style': 'solid',
                  'border-color': `hsl(${preset.hue}, 80%, 80%)`,
                }
              : ''
          }
          width="100%"
        >
          {preset.title}
        </Button>
      ))}
      <span style={POD_GREY} onload={() => getPresets()}>
        <br />
        <br />
        ПРИМЕЧАНИЕ. Пользовательские звуки, не входящие в файлы базовой игры, не
        сохраняются! :(
      </span>
    </Section>
  );
};
