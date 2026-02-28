import { useEffect, useState } from 'react';
import { Button, Modal, Section, Stack } from 'tgui/components';
import { fetchRetry } from 'common/https';

import { resolveAsset } from '../../assets';
import { Window } from '../../layouts';
import { logger } from 'common/logging';
import { CreateObject } from './CreateObject';
import { CreateObjectAdvancedSettings } from './CreateObjectAdvancedSettings';
import type { CreateObjectData } from './types';

export interface IconSettings {
  icon: string | null;
  iconState: string | null;
  iconSize: number;
  applyIcon?: boolean;
}

export const SpawnPanel = () => {
  const [data, setData] = useState<CreateObjectData | undefined>();
  const [advancedSettings, setAdvancedSettings] = useState(false);
  const [iconSettings, setIconSettings] = useState<IconSettings>({
    icon: null,
    iconState: null,
    iconSize: 100,
    applyIcon: false,
  });

  useEffect(() => {
    fetchRetry(resolveAsset('spawnpanel_atom_data.json'))
      .then((response) => response.json())
      .then(setData)
      .catch((error) => {
        logger.log(
          'Failed to fetch spawnpanel_atom_data.json',
          JSON.stringify(error)
        );
      });
  }, []);

  const handleIconSettingsChange = (newSettings: Partial<IconSettings>) => {
    setIconSettings((current) => ({
      ...current,
      ...newSettings,
    }));
  };

  return (
    <Window
      height={550}
      title="Панель создания объектов"
      width={575}
      theme="admin"
    >
      <Window.Content>
        {advancedSettings && (
          <Modal
            style={{
              padding: '6px',
              marginTop: '-15em',
            }}
          >
            <Section
              title="Продвинутые настройки"
              buttons={
                <Button
                  color="transparent"
                  icon="close"
                  onClick={() => setAdvancedSettings(false)}
                />
              }
            >
              <CreateObjectAdvancedSettings
                iconSettings={iconSettings}
                onIconSettingsChange={handleIconSettingsChange}
              />
            </Section>
          </Modal>
        )}
        <Stack vertical fill>
          <Stack.Item grow>
            {data && (
              <CreateObject
                objList={data}
                setAdvancedSettings={setAdvancedSettings}
                iconSettings={iconSettings}
                onIconSettingsChange={handleIconSettingsChange}
              />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
