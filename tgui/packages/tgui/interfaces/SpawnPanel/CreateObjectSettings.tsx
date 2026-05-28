import { storage } from 'common/storage';
import { useEffect, useState } from 'react';
import {
  Button,
  Dropdown,
  Input,
  NumberInput,
  Icon,
  Slider,
  Stack,
  Table,
} from 'tgui/components';

import { useBackend } from '../../backend';
import {
  directionNames,
  directionRotation,
  spawnLocationIcons,
  spawnLocationOptions,
  OffsetType,
  PreciseMode,
} from './constants';
import type { IconSettings } from './index';

export interface SpawnPanelData {
  icon: string;
  iconState: string;
  iconStates: string[];
  selected_object?: string;
  precise_mode: string;
}

interface CreateObjectSettingsProps {
  onCreateObject?: (obj: Record<string, unknown>) => void;
  setAdvancedSettings: (value: boolean) => void;
  iconSettings: IconSettings;
}

export const CreateObjectSettings = (props: CreateObjectSettingsProps) => {
  const { onCreateObject, setAdvancedSettings, iconSettings } = props;
  const { act, data } = useBackend<SpawnPanelData>();

  const [amount, setAmount] = useState(1);
  const [cordsType, setCordsType] = useState(0);
  const [spawnLocation, setSpawnLocation] = useState('Текущая локация');
  const [direction, setDirection] = useState(0);
  const [objectName, setObjectName] = useState('');
  const [offset, setOffset] = useState('');

  const dirValues = [1, 5, 4, 6, 2, 10, 8, 9];

  const updateAmount = (value: number) => {
    setAmount(value);
    sendUpdatedSettings({ atom_amount: value });
  };

  const updateCordsType = (value: number) => {
    setCordsType(value);
    storage.set('spawnpanel-offset_type', value);
    sendUpdatedSettings({
      offset_type: value ? OffsetType.ABSOLUTE : OffsetType.RELATIVE,
    });
  };

  const updateSpawnLocation = (value: string) => {
    setSpawnLocation(value);
    storage.set('spawnpanel-where_target_type', value);
    sendUpdatedSettings({ where_target_type: value });
  };

  const updateDirection = (value: number) => {
    setDirection(value);
    storage.set('spawnpanel-direction', value);
    sendUpdatedSettings({ atom_dir: dirValues[value] });
  };

  const updateObjectName = (value: string) => {
    setObjectName(value);
    storage.set('spawnpanel-atom_name', value);
    sendUpdatedSettings({ atom_name: value });

    if (isPreciseModeActive) {
      sendUpdatedSettings();
    }
  };

  const updateOffset = (value: string) => {
    setOffset(value);
    storage.set('spawnpanel-offset', value);

    const parseOffset = (offsetStr: string): number[] => {
      if (!offsetStr.trim()) return [0, 0, 0];

      const parts = offsetStr.split(',').map((part) => {
        return parseInt(part.trim(), 10);
      });

      while (parts.length < 3) {
        parts.push(0);
      }

      return parts.slice(0, 3);
    };

    sendUpdatedSettings({ offset: parseOffset(value) });
  };

  const sendUpdatedSettings = (
    changedSettings: Partial<Record<string, unknown>> = {}
  ) => {
    const parseOffset = (offsetStr: string): number[] => {
      if (!offsetStr.trim()) return [0, 0, 0];

      const parts = offsetStr.split(',').map((part) => {
        return parseInt(part.trim(), 10);
      });

      while (parts.length < 3) {
        parts.push(0);
      }

      return parts.slice(0, 3);
    };

    const currentSettings = {
      atom_amount: amount,
      offset_type: cordsType ? OffsetType.ABSOLUTE : OffsetType.RELATIVE,
      where_target_type: spawnLocation,
      atom_dir: dirValues[direction],
      offset: parseOffset(offset),
      atom_name: objectName,
      atom_icon_size: iconSettings.iconSize,
      apply_icon_override: iconSettings.applyIcon ?? false,
      ...changedSettings,
    };
    act('update-settings', currentSettings);
  };

  const resetAdvancedSettings = () => {
    const defaultAmount = 1;
    const defaultCordsType = 0;
    const defaultSpawnLocation = 'Текущая локация';
    const defaultDirection = 0;
    const defaultObjectName = '';
    const defaultOffset = '';

    setAmount(defaultAmount);
    setCordsType(defaultCordsType);
    setSpawnLocation(defaultSpawnLocation);
    setDirection(defaultDirection);
    setObjectName(defaultObjectName);
    setOffset(defaultOffset);

    storage.set('spawnpanel-atom_amount', defaultAmount);
    storage.set('spawnpanel-offset_type', defaultCordsType);
    storage.set('spawnpanel-where_target_type', defaultSpawnLocation);
    storage.set('spawnpanel-direction', defaultDirection);
    storage.set('spawnpanel-atom_name', defaultObjectName);
    storage.set('spawnpanel-offset', defaultOffset);

    sendUpdatedSettings({
      atom_amount: defaultAmount,
      offset_type: defaultCordsType ? OffsetType.ABSOLUTE : OffsetType.RELATIVE,
      where_target_type: defaultSpawnLocation,
      atom_dir: dirValues[defaultDirection],
      offset: defaultOffset,
      atom_name: defaultObjectName,
    });
  };

  useEffect(() => {
    const loadStoredValues = async () => {
      const storedCordsType = await storage.get('spawnpanel-offset_type');
      const storedSpawnLocation = await storage.get(
        'spawnpanel-where_target_type'
      );
      const storedDirection = await storage.get('spawnpanel-direction');
      const storedObjectName = await storage.get('spawnpanel-atom_name');
      const storedOffset = await storage.get('spawnpanel-offset');

      if (storedCordsType !== undefined) setCordsType(storedCordsType);
      if (storedSpawnLocation) setSpawnLocation(storedSpawnLocation);
      if (storedDirection !== undefined) setDirection(storedDirection);
      if (storedObjectName !== undefined) setObjectName(storedObjectName);
      if (storedOffset !== undefined) setOffset(storedOffset);
    };

    loadStoredValues();
  }, []);

  const isTargetMode =
    spawnLocation === 'Выбранная локация' ||
    spawnLocation === 'Выбранная локация (десантная капсула)' ||
    spawnLocation === 'В руке выбранного моба';

  const isPreciseModeActive = data?.precise_mode === PreciseMode.TARGET;
  const isMarkModeActive = data?.precise_mode === PreciseMode.MARK;
  const isCopyModeActive = data?.precise_mode === PreciseMode.COPY;

  const isAnyPreciseModeActive = !(data?.precise_mode === PreciseMode.OFF);

  const disablePreciseMode = () => {
    if (isPreciseModeActive) {
      act('toggle-precise-mode', {
        newPreciseType: PreciseMode.OFF,
      });
    }
  };

  const handleSpawn = () => {
    const parseOffset = (offsetStr: string): number[] => {
      if (!offsetStr.trim()) return [0, 0, 0];

      const parts = offsetStr.split(',').map((part) => {
        return parseInt(part.trim(), 10);
      });

      while (parts.length < 3) {
        parts.push(0);
      }

      return parts.slice(0, 3);
    };

    const currentSettings = {
      atom_amount: amount,
      offset_type: cordsType ? OffsetType.ABSOLUTE : OffsetType.RELATIVE,
      where_target_type: spawnLocation,
      atom_dir: dirValues[direction],
      offset: parseOffset(offset),
      atom_name: objectName,
      atom_icon_size: iconSettings.iconSize,
      selected_atom: data.selected_object,
      apply_icon_override: iconSettings.applyIcon ?? false,
    };

    act('update-settings', currentSettings);

    if (!isTargetMode) {
      if (onCreateObject) {
        onCreateObject(currentSettings);
      } else {
        act('create-atom-action', currentSettings);
      }
    } else {
      if (isPreciseModeActive) {
        act('toggle-precise-mode', { newPreciseType: PreciseMode.OFF });
      } else {
        act('toggle-precise-mode', {
          newPreciseType: PreciseMode.TARGET,
          where_target_type: spawnLocation,
        });
      }
    }
  };

  useEffect(() => {
    if (!isTargetMode && isPreciseModeActive) {
      disablePreciseMode();
    }
  }, [spawnLocation]);

  useEffect(() => {
    if (isPreciseModeActive) {
      sendUpdatedSettings();
    }
  }, [iconSettings.icon, iconSettings.iconState, iconSettings.iconSize]);

  return (
    <Stack fill vertical>
      <Stack>
        <Stack.Item grow>
          <Table
            style={{
              paddingLeft: '5px',
            }}
          >
            <Table.Row className="candystripe" lineHeight="16px">
              <Table.Cell pl={1}>Кол-во:</Table.Cell>
              <Table.Cell>
                <Stack>
                  <Stack.Item>
                    <NumberInput
                      width="45px"
                      minValue={1}
                      maxValue={100}
                      step={1}
                      value={amount}
                      onChange={(value) => updateAmount(value)}
                      disabled={isAnyPreciseModeActive}
                    />
                  </Stack.Item>
                  <Stack.Item>Напр-е:</Stack.Item>
                  <Stack.Item>
                    <Button
                      tooltip={directionNames[dirValues[direction]]}
                      tooltipPosition="top"
                      fontSize="14"
                      onClick={() => {
                        updateDirection((direction + 1) % dirValues.length);
                      }}
                      disabled={isAnyPreciseModeActive}
                    >
                      <Icon
                        name="arrow-up"
                        style={{
                          transform: `rotate(${directionRotation[dirValues[direction]]}deg)`,
                        }}
                      />
                    </Button>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Slider
                      tickWhileDragging
                      minValue={0}
                      maxValue={7}
                      step={1}
                      lineHeight={1}
                      stepPixelSize={25}
                      value={direction}
                      format={(value) => dirValues[value].toString()}
                      onChange={(e, value) => updateDirection(value)}
                      disabled={isAnyPreciseModeActive}
                    />
                  </Stack.Item>
                </Stack>
              </Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe" lineHeight="26px">
              <Table.Cell pl={1}>Сдвиг:</Table.Cell>
              <Table.Cell width="1200px">
                <Stack>
                  <Stack.Item>
                    <Button
                      icon={cordsType ? 'a' : 'r'}
                      fontSize="14"
                      onClick={() => {
                        const newCordsType = cordsType ? 0 : 1;
                        updateCordsType(newCordsType);
                        if (isPreciseModeActive) {
                          disablePreciseMode();
                        }
                      }}
                      tooltip={cordsType ? 'Абсолютно' : 'Относительно'}
                      tooltipPosition="top"
                      disabled={
                        isTargetMode ||
                        spawnLocation === 'У отмеченного объекта' ||
                        spawnLocation === 'В отмеченном объекте' ||
                        isAnyPreciseModeActive
                      }
                    />
                  </Stack.Item>
                  <Stack.Item grow>
                    <Input
                      placeholder="x, y, z"
                      value={offset}
                      onChange={(value: string) => updateOffset(value)}
                      width="100%"
                      disabled={
                        isTargetMode ||
                        spawnLocation === 'У отмеченного объекта' ||
                        spawnLocation === 'В отмеченном объекте' ||
                        isAnyPreciseModeActive
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Table.Cell>
            </Table.Row>
            <Table.Row className="candystripe" lineHeight="26px">
              <Table.Cell pl={1} width="80px">
                Название:
              </Table.Cell>
              <Table.Cell>
                <Input
                  onChange={(value: string) => updateObjectName(value)}
                  value={objectName}
                  width="100%"
                  placeholder="название по умолчанию"
                  disabled={isAnyPreciseModeActive}
                />
              </Table.Cell>
            </Table.Row>
          </Table>
        </Stack.Item>
        <Stack.Item grow>
          <Stack fill>
            <Stack.Item>
              <Stack vertical>
                <Stack.Item>
                  <Button
                    icon="gear"
                    onClick={() => setAdvancedSettings(true)}
                    style={{
                      height: '22px',
                      width: '22px',
                      lineHeight: '22px',
                    }}
                    tooltip="Расширенные настройки"
                    tooltipPosition="top"
                    disabled={isAnyPreciseModeActive}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="trash"
                    style={{
                      height: '22px',
                      width: '22px',
                      lineHeight: '22px',
                    }}
                    onClick={() => resetAdvancedSettings()}
                    tooltip="Сбросить расширенные настройки"
                    tooltipPosition="top"
                    disabled={isAnyPreciseModeActive}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    style={{
                      height: '22px',
                      width: '22px',
                      lineHeight: '22px',
                    }}
                    icon={
                      spawnLocation === 'У отмеченного объекта' ||
                      spawnLocation === 'В отмеченном объекте'
                        ? 'thumbtack'
                        : 'eye-dropper'
                    }
                    onClick={() => {
                      act('toggle-precise-mode', {
                        newPreciseType:
                          isMarkModeActive || isCopyModeActive
                            ? PreciseMode.OFF
                            : spawnLocation === 'У отмеченного объекта' ||
                                spawnLocation === 'В отмеченном объекте'
                              ? PreciseMode.MARK
                              : PreciseMode.COPY,
                      });
                    }}
                    selected={isMarkModeActive || isCopyModeActive}
                    tooltip={
                      spawnLocation === 'У отмеченного объекта' ||
                      spawnLocation === 'В отмеченном объекте'
                        ? 'Отметить атом'
                        : 'Копировать путь атома'
                    }
                    tooltipPosition="top"
                    disabled={isAnyPreciseModeActive && !isMarkModeActive}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <Stack vertical fill>
                <Stack.Item grow>
                  <Button
                    onClick={handleSpawn}
                    style={{
                      width: '100%',
                      height: '100%',
                      textAlign: 'center',
                      fontSize: '20px',
                      alignContent: 'center',
                    }}
                    icon={spawnLocationIcons[spawnLocation]}
                    selected={isTargetMode && isPreciseModeActive}
                  >
                    СОЗДАТЬ
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Dropdown
                    options={spawnLocationOptions}
                    onSelected={(value) => {
                      if (
                        data?.precise_mode &&
                        data.precise_mode !== PreciseMode.OFF
                      ) {
                        act('toggle-precise-mode', {
                          newPreciseType: PreciseMode.OFF,
                        });
                      }
                      updateSpawnLocation(value);
                    }}
                    selected={spawnLocation}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Stack>
  );
};
