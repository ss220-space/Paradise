import { Fragment } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Icon,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { LogisticsButton } from './common/LogisticsButton';

type SmartfridgeData = {
  secure: boolean; // secure fridge notice
  can_dry: boolean; // dry section
  drying: boolean; // drying rack on/off.
  contents: Item[];
  logistics_enabled: boolean;
};

type Item = {
  display_name: string;
  quantity: number;
  vend: string;
  icon?: string;
  icon_state?: string;
};

export const Smartfridge = (_props: unknown) => {
  const { act, data } = useBackend<SmartfridgeData>();
  const { secure, can_dry, drying, contents, logistics_enabled } = data;
  const items = (contents || [])
    .slice()
    .sort((a, b) => a.display_name.localeCompare(b.display_name));

  return (
    <Window width={520} height={500} theme="ntos">
      <Window.Content>
        <Stack fill vertical>
          {!!secure && (
            <NoticeBox>
              Требуется авторизация. Пожалуйста, предъявите свою ID-карту.
            </NoticeBox>
          )}
          <Section
            fill
            scrollable
            title={
              <Stack align="center" width="100%">
                <Stack.Item>
                  <Icon name="list" />
                </Stack.Item>
                <Stack.Item grow>
                  {can_dry ? 'Сушильная стойка' : 'Содержимое'}
                </Stack.Item>
                <Stack.Item>
                  <LogisticsButton enabled={!!logistics_enabled} />
                </Stack.Item>
                {!!can_dry && (
                  <Stack.Item>
                    <Button
                      width={11}
                      icon={drying ? 'power-off' : 'times'}
                      selected={drying}
                      onClick={() => act('drying')}
                    >
                      {drying ? 'Начать сушку' : 'Закончить сушку'}
                    </Button>
                  </Stack.Item>
                )}
              </Stack>
            }
          >
            {!items.length ? (
              <Box italic>Хранилище пусто.</Box>
            ) : (
              <LabeledList>
                {items.map((item, index) => (
                  <Fragment key={item.vend}>
                    {index > 0 && <LabeledList.Divider />}
                    <LabeledList.Item
                      verticalAlign="middle"
                      label={
                        <Stack align="center">
                          <Stack.Item>
                            {item.icon && item.icon_state ? (
                              <DmIcon
                                icon={item.icon}
                                icon_state={item.icon_state}
                                style={{ width: '32px', height: '32px' }}
                              />
                            ) : (
                              <Icon name="box" />
                            )}
                          </Stack.Item>
                          <Stack.Item>{item.display_name}</Stack.Item>
                        </Stack>
                      }
                      buttons={
                        <>
                          <Button
                            width={3}
                            icon="arrow-down"
                            tooltip="Взять одну штуку."
                            onClick={() =>
                              act('vend', { index: item.vend, amount: 1 })
                            }
                          >
                            1
                          </Button>
                          <NumberInput
                            width="40px"
                            minValue={0}
                            value={0}
                            maxValue={item.quantity}
                            step={1}
                            stepPixelSize={3}
                            onChange={(value) =>
                              act('vend', { index: item.vend, amount: value })
                            }
                          />
                          <Button
                            width={4}
                            icon="arrow-down"
                            tooltip="Взять всё."
                            tooltipPosition="bottom-start"
                            onClick={() =>
                              act('vend', {
                                index: item.vend,
                                amount: item.quantity,
                              })
                            }
                          >
                            Всё
                          </Button>
                        </>
                      }
                    >
                      {item.quantity} шт.
                    </LabeledList.Item>
                  </Fragment>
                ))}
              </LabeledList>
            )}
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
