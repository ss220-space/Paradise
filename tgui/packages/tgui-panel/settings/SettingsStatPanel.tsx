import {
  Button,
  Collapsible,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import { capitalize } from 'tgui-core/string';
import { FONTS } from './constants';
import { useSettings } from './use-settings';

const tabViews = ['default', 'classic', 'scrollable'];

function LinkedToChat() {
  return <NoticeBox color="red">Отвяжите стат. панель от чата!</NoticeBox>;
}

export function SettingsStatPanel(props) {
  const { settings, updateSettings } = useSettings();
  const { statLinked, statFontSize, statTabsStyle } = settings;

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Стиль" verticalAlign="middle">
              {tabViews.map((view) => (
                <Button
                  key={view}
                  color="transparent"
                  selected={statTabsStyle === view}
                  onClick={() => updateSettings({ statTabsStyle: view })}
                >
                  {capitalize(view)}
                </Button>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Шрифт">
              {statLinked ? (
                <LinkedToChat />
              ) : (
                <Stack.Item>
                  {!settings.freeStatFont ? (
                    <Collapsible
                      title={settings.statFontFamily}
                      width={'100%'}
                      buttons={
                        <Button
                          icon={settings.freeStatFont ? 'lock-open' : 'lock'}
                          color={settings.freeStatFont ? 'good' : 'bad'}
                          onClick={() => {
                            updateSettings({
                              freeStatFont: !settings.statFontFamily,
                            });
                          }}
                        >
                          Пользовательский шрифт
                        </Button>
                      }
                    >
                      {FONTS.map((FONT) => (
                        <Button
                          key={FONT}
                          fontFamily={FONT}
                          selected={settings.statFontFamily === FONT}
                          color="transparent"
                          onClick={() =>
                            updateSettings({
                              statFontFamily: FONT,
                            })
                          }
                        >
                          {FONT}
                        </Button>
                      ))}
                    </Collapsible>
                  ) : (
                    <Stack>
                      <Input
                        width={'100%'}
                        value={settings.statFontFamily}
                        onChange={(value) =>
                          updateSettings({
                            statFontFamily: value,
                          })
                        }
                      />
                      <Button
                        ml={0.5}
                        icon={settings.freeStatFont ? 'lock-open' : 'lock'}
                        color={settings.freeStatFont ? 'good' : 'bad'}
                        onClick={() => {
                          updateSettings({
                            freeStatFont: !settings.freeStatFont,
                          });
                        }}
                      >
                        Пользовательский шрифт
                      </Button>
                    </Stack>
                  )}
                </Stack.Item>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Размер шрифта">
              <Stack.Item grow>
                {statLinked ? (
                  <LinkedToChat />
                ) : (
                  <Slider
                    width="100%"
                    step={1}
                    stepPixelSize={20}
                    minValue={8}
                    maxValue={32}
                    value={statFontSize}
                    unit="px"
                    format={(value) => toFixed(value)}
                    onChange={(e, value) =>
                      updateSettings({ statFontSize: value })
                    }
                  />
                )}
              </Stack.Item>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Divider mt={2.5} />
        <Stack.Item textAlign="center">
          <Button
            fluid
            icon={statLinked ? 'unlink' : 'link'}
            color={statLinked ? 'bad' : 'good'}
            onClick={() => updateSettings({ statLinked: !statLinked })}
          >
            {statLinked ? 'Отвязать от чата' : 'Привязать к чату'}
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
