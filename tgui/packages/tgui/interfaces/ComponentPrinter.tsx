import { useEffect, useState } from 'react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, Button, DmIcon, NoticeBox, Section, Stack } from '../components';
import { toTitleCase } from 'common/string';
import { storage } from 'common/storage';

type Design = {
  name: string;
  desc: string;
  cost: Record<string, number>;
  id: string;
  categories: string[];
  icon: string;
  IconState: string;
};

type Material = {
  name: string;
  ref: string;
  amount: number;
};

type ComponentPrinterData = {
  designs: Record<string, Design>;
  materials: Material[];
  _browser_save?: { key: string; value: string };
};

type LocalSave = {
  key: string;
  name: string;
};

const SAVES_LIST_KEY = 'circuit_saves_list';

export const ComponentPrinter = (props) => {
  const { act, data } = useBackend<ComponentPrinterData>();
  const { designs } = data;

  const [localSaves, setLocalSaves] = useState<LocalSave[]>([]);

  const loadLocalSaves = async () => {
    const saves = await storage.get(SAVES_LIST_KEY);
    setLocalSaves(Array.isArray(saves) ? saves : []);
  };

  useEffect(() => {
    loadLocalSaves();
  }, []);

  useEffect(() => {
    const payload = data._browser_save;
    if (!payload) return;

    (async () => {
      let saves = await storage.get(SAVES_LIST_KEY);
      if (!Array.isArray(saves)) {
        saves = [];
      }
      await storage.set(payload.key, payload.value);

      const exists = saves.some((s: LocalSave) => s.key === payload.key);
      if (!exists) {
        const name = payload.key.replace('circuit_', '');
        saves.push({ key: payload.key, name });
        await storage.set(SAVES_LIST_KEY, saves);
        setLocalSaves(saves);
      }
      act('clear_browser_save');
    })();
  }, [data._browser_save]);

  const handleDeleteLocal = async (key: string) => {
    await storage.remove(key);
    let saves = await storage.get(SAVES_LIST_KEY);
    if (!Array.isArray(saves)) {
      saves = [];
    }
    const newSaves = saves.filter((s: LocalSave) => s.key !== key);
    await storage.set(SAVES_LIST_KEY, newSaves);
    setLocalSaves(newSaves);
  };

  const handleLoadLocal = async (key: string) => {
    const value = await storage.get(key);
    if (value) {
      act('import_local', { payload: value });
    }
  };

  return (
    <Window title="Дубликатор печатных плат" width={670} height={600}>
      <Window.Content scrollable>
        <Section
          title="Локальные схемы"
          buttons={
            <Button icon="refresh" onClick={loadLocalSaves}>
              Обновить
            </Button>
          }
        >
          {localSaves.length === 0 && (
            <NoticeBox info>Нет локально сохранённых схем.</NoticeBox>
          )}
          {localSaves.map((save) => (
            <Stack key={save.key} align="center" mb={1}>
              <Stack.Item grow>{save.name}</Stack.Item>
              <Stack.Item>
                <Button
                  icon="upload"
                  onClick={() => handleLoadLocal(save.key)}
                  tooltip="Загрузить"
                />
                <Button
                  icon="trash"
                  onClick={() => handleDeleteLocal(save.key)}
                  tooltip="Удалить"
                />
              </Stack.Item>
            </Stack>
          ))}
        </Section>

        <Section title="Сохранённые схемы">
          {Object.values(designs).length === 0 && (
            <NoticeBox info mt={1}>
              Сохранённые схемы отсутствуют.
            </NoticeBox>
          )}
          {Object.values(designs).map((design) => (
            <Section key={design.id} style={{ position: 'relative' }}>
              <DmIcon
                icon={design.icon}
                icon_state={design.IconState}
                style={{
                  verticalAlign: 'middle',
                  width: '32px',
                  margin: '0px',
                  marginLeft: '0px',
                }}
              />
              <Button
                mr={1}
                icon="hammer"
                tooltip={design.desc}
                onClick={() => act('print', { designId: design.id })}
              >
                {toTitleCase(design.name)}
              </Button>

              <Box style={{ display: 'inline' }}>
                {(design.cost &&
                  Object.keys(design.cost)
                    .map((mat) => toTitleCase(mat) + ': ' + design.cost[mat])
                    .join(', ')) ||
                  'Ресурсы для печати не требуются.'}
              </Box>

              <Box
                style={{
                  position: 'absolute',
                  right: '8px',
                  top: '8px',
                  display: 'flex',
                  gap: '5px',
                }}
              >
                <Button
                  icon="floppy-disk"
                  tooltip="Сохранить локально"
                  onClick={() => act('save_local', { designId: design.id })}
                />
                <Button
                  icon="trash-can"
                  onClick={() => act('del_design', { designId: design.id })}
                />
              </Box>
            </Section>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
