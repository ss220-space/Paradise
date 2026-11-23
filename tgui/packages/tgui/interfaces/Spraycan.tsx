import { useEffect, useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Slider,
  Stack,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

const PRESET_COLORS = [
  { name: 'Красный', hex: '#da0000' },
  { name: 'Оранжевый', hex: '#ff9300' },
  { name: 'Жёлтый', hex: '#fff200' },
  { name: 'Зелёный', hex: '#00b700' },
  { name: 'Голубой', hex: '#00b7ef' },
  { name: 'Синий', hex: '#0000b7' },
  { name: 'Фиолетовый', hex: '#da00ff' },
  { name: 'Розовый', hex: '#ff70b8' },
  { name: 'Белый', hex: '#ffffff' },
  { name: 'Чёрный', hex: '#282828' },
];

type SprayMode = 'text' | 'letters' | 'graffiti' | 'rune';

type SpraycanData = {
  capped: boolean;
  colour: string;
  uses: number;
  max_uses: number;
  spray_mode: SprayMode;
  spray_text: string;
  spray_font: string;
  text_index: number;
  loop_text: boolean;
  drawtype: string;
  rotation: number;
  scale: number;
  font_list: Record<string, string>;
  graffiti_list: string[];
  rune_list: string[];
  valid_letters: string[];
};

export const Spraycan = () => {
  const { act, data } = useBackend<SpraycanData>();
  const {
    capped,
    colour,
    uses,
    max_uses,
    spray_mode,
    spray_text,
    spray_font,
    text_index,
    loop_text,
    drawtype,
    rotation,
    scale,
    font_list = {},
    graffiti_list = [],
    rune_list = [],
    valid_letters = [],
  } = data;

  const [draftText, setDraftText] = useState(spray_text);

  useEffect(() => {
    setDraftText(spray_text);
  }, [spray_text]);

  const textChars = Array.from(spray_text);
  const currentChar =
    textChars.length > 0 && text_index >= 1 && text_index <= textChars.length
      ? textChars[text_index - 1]
      : '';

  return (
    <Window width={520} height={580}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section
              title="Управление баллончиком"
              buttons={
                <Stack>
                  <Stack.Item>
                    <Box color="label" px={1} py={0.3}>
                      Краска: {uses} / {max_uses}
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon={capped ? 'lock' : 'lock-open'}
                      color={capped ? 'bad' : 'good'}
                      onClick={() => act('toggle_cap')}
                    >
                      {capped ? 'Колпачок надет' : 'Колпачок снят'}
                    </Button>
                  </Stack.Item>
                </Stack>
              }
            >
              <LabeledList>
                <LabeledList.Item label="Цвет краски">
                  <Stack align="center" wrap>
                    {PRESET_COLORS.map((preset) => (
                      <Stack.Item key={preset.hex}>
                        <Button
                          tooltip={preset.name}
                          selected={
                            colour.toLowerCase() === preset.hex.toLowerCase()
                          }
                          p={0.3}
                          onClick={() =>
                            act('set_color', { color: preset.hex })
                          }
                        >
                          <Box
                            width="16px"
                            height="16px"
                            backgroundColor={preset.hex}
                          />
                        </Button>
                      </Stack.Item>
                    ))}
                    <Stack.Item>
                      <Button
                        icon="palette"
                        onClick={() => act('custom_color')}
                      >
                        Свой...
                      </Button>
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Трансформация и предпросмотр">
              <Stack align="center">
                <Stack.Item grow>
                  <LabeledList>
                    <LabeledList.Item label="Поворот">
                      <Stack align="center">
                        <Stack.Item grow>
                          <Slider
                            minValue={-180}
                            maxValue={180}
                            step={5}
                            stepPixelSize={2}
                            value={rotation}
                            unit="°"
                            onChange={(_, value) =>
                              act('set_rotation', { rotation: value })
                            }
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            onClick={() => act('set_rotation', { rotation: 0 })}
                          >
                            0°
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            onClick={() =>
                              act('set_rotation', {
                                rotation: ((rotation + 45 + 180) % 360) - 180,
                              })
                            }
                          >
                            +45°
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </LabeledList.Item>
                    <LabeledList.Item label="Масштаб">
                      <Stack align="center">
                        <Stack.Item grow>
                          <Slider
                            minValue={0.5}
                            maxValue={2}
                            step={0.25}
                            stepPixelSize={18}
                            value={scale}
                            unit="x"
                            onChange={(_, value) =>
                              act('set_scale', {
                                scale: Math.round(value * 4) / 4,
                              })
                            }
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            selected={scale === 0.5}
                            onClick={() => act('set_scale', { scale: 0.5 })}
                          >
                            0.5x
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            selected={scale === 0.75}
                            onClick={() => act('set_scale', { scale: 0.75 })}
                          >
                            0.75x
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            selected={scale === 1}
                            onClick={() => act('set_scale', { scale: 1 })}
                          >
                            1x
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            selected={scale === 1.5}
                            onClick={() => act('set_scale', { scale: 1.5 })}
                          >
                            1.5x
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            selected={scale === 2}
                            onClick={() => act('set_scale', { scale: 2 })}
                          >
                            2x
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item>
                  <Box
                    width="96px"
                    height="96px"
                    backgroundColor="#1b1b1b"
                    position="relative"
                    style={{
                      border: '1px solid #444',
                      overflow: 'hidden',
                    }}
                  >
                    {spray_mode === 'text' ? (
                      currentChar && currentChar !== ' ' ? (
                        <Box
                          position="absolute"
                          top="50%"
                          left="50%"
                          width="44px"
                          height="44px"
                          style={{
                            marginLeft: '-22px',
                            marginTop: '-22px',
                            lineHeight: '44px',
                            textAlign: 'center',
                            fontFamily:
                              spray_font || '"Courier New", monospace',
                            fontSize: '14px',
                            fontWeight: 'bold',
                            color: colour,
                            textShadow: '1px 1px 0 #111, -1px -1px 0 #111',
                            transformOrigin: 'center center',
                            transform: `rotate(${rotation}deg) scale(${scale})`,
                          }}
                        >
                          {currentChar}
                        </Box>
                      ) : (
                        <Box
                          color="label"
                          fontSize="10px"
                          textAlign="center"
                          mt="40px"
                        >
                          Пусто
                        </Box>
                      )
                    ) : (
                      <Box
                        position="absolute"
                        top="50%"
                        left="50%"
                        width="44px"
                        height="44px"
                        style={{
                          marginLeft: '-22px',
                          marginTop: '-22px',
                          lineHeight: 0,
                          imageRendering: 'pixelated',
                          transformOrigin: 'center center',
                          transform: `rotate(${rotation}deg) scale(${scale})`,
                        }}
                      >
                        <DmIcon
                          icon="icons/effects/crayondecal.dmi"
                          icon_state={drawtype || 'amyjon'}
                          color={colour}
                          width="44px"
                          height="44px"
                        />
                      </Box>
                    )}
                  </Box>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Режим"
              buttons={
                <Stack>
                  <Stack.Item>
                    <Button
                      icon="font"
                      selected={spray_mode === 'text'}
                      onClick={() => act('set_mode', { mode: 'text' })}
                    >
                      Текст (UTF-8)
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="th"
                      selected={spray_mode === 'letters'}
                      onClick={() => act('set_mode', { mode: 'letters' })}
                    >
                      Символы
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="spray-can"
                      selected={spray_mode === 'graffiti'}
                      onClick={() => act('set_mode', { mode: 'graffiti' })}
                    >
                      Граффити
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="star"
                      selected={spray_mode === 'rune'}
                      onClick={() => act('set_mode', { mode: 'rune' })}
                    >
                      Руны
                    </Button>
                  </Stack.Item>
                </Stack>
              }
            >
              {spray_mode === 'text' && (
                <Stack vertical>
                  <Stack.Item>
                    <Box color="label" mb={0.5}>
                      Кириллица, латиница, цифры и знаки. Каждый клик ставит
                      выделенный символ и сдвигает указатель:
                    </Box>
                    <Stack>
                      <Stack.Item grow>
                        <Input
                          fluid
                          value={draftText}
                          maxLength={64}
                          placeholder="Например: ПРИВЕТ СБ!"
                          onChange={(value) => setDraftText(value)}
                          onEnter={() => act('set_text', { text: draftText })}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="check"
                          color="good"
                          onClick={() => act('set_text', { text: draftText })}
                        >
                          Применить
                        </Button>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Item>
                    <Stack align="center" wrap>
                      <Stack.Item>
                        <Box color="label">Шрифт:</Box>
                      </Stack.Item>
                      {Object.entries(font_list).map(([label, family]) => (
                        <Stack.Item key={family}>
                          <Button
                            selected={spray_font === family}
                            onClick={() => act('set_font', { font: family })}
                          >
                            <span style={{ fontFamily: family }}>{label}</span>
                          </Button>
                        </Stack.Item>
                      ))}
                    </Stack>
                  </Stack.Item>
                  <Stack.Item>
                    <Stack align="center" wrap>
                      <Stack.Item>
                        <Button
                          icon="step-backward"
                          tooltip="В начало"
                          onClick={() => act('set_index', { index: 1 })}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="arrow-left"
                          tooltip="Предыдущий символ"
                          disabled={text_index <= 1}
                          onClick={() =>
                            act('set_index', { index: text_index - 1 })
                          }
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <NumberInput
                          minValue={1}
                          maxValue={Math.max(1, textChars.length)}
                          value={text_index}
                          step={1}
                          width="42px"
                          onChange={(value) =>
                            act('set_index', { index: value })
                          }
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="arrow-right"
                          tooltip="Следующий символ"
                          disabled={text_index >= textChars.length}
                          onClick={() =>
                            act('set_index', { index: text_index + 1 })
                          }
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button.Checkbox
                          checked={loop_text}
                          onClick={() => act('toggle_loop')}
                        >
                          По кругу
                        </Button.Checkbox>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Item>
                    <Stack wrap>
                      {textChars.map((ch, idx) => {
                        const pos = idx + 1;
                        const isCurrent = pos === text_index;
                        return (
                          <Stack.Item key={pos}>
                            <Button
                              selected={isCurrent}
                              color={isCurrent ? 'good' : undefined}
                              onClick={() => act('set_index', { index: pos })}
                            >
                              {ch === ' ' ? '␣' : ch}
                            </Button>
                          </Stack.Item>
                        );
                      })}
                    </Stack>
                  </Stack.Item>
                </Stack>
              )}
              {spray_mode === 'letters' && (
                <Stack vertical>
                  <Stack.Item>
                    <Button
                      fluid
                      icon="random"
                      onClick={() => act('random_letter')}
                    >
                      Случайный символ
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Stack wrap justify="center">
                      {valid_letters.map((lState) => (
                        <Stack.Item key={lState}>
                          <Button
                            tooltip={lState.toUpperCase()}
                            selected={drawtype === lState}
                            p={0.5}
                            onClick={() =>
                              act('select_drawtype', { drawtype: lState })
                            }
                          >
                            <DmIcon
                              icon="icons/effects/crayondecal.dmi"
                              icon_state={lState}
                              color={colour}
                              width="32px"
                              height="32px"
                            />
                          </Button>
                        </Stack.Item>
                      ))}
                    </Stack>
                  </Stack.Item>
                </Stack>
              )}

              {spray_mode === 'graffiti' && (
                <Stack vertical>
                  <Stack.Item>
                    <Button
                      fluid
                      icon="random"
                      onClick={() => act('random_graffiti')}
                    >
                      Случайное граффити
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Stack wrap justify="center">
                      {graffiti_list.map((gState) => (
                        <Stack.Item key={gState}>
                          <Button
                            tooltip={gState}
                            selected={drawtype === gState}
                            p={0.5}
                            onClick={() =>
                              act('select_drawtype', { drawtype: gState })
                            }
                          >
                            <DmIcon
                              icon="icons/effects/crayondecal.dmi"
                              icon_state={gState}
                              color={colour}
                              width="32px"
                              height="32px"
                            />
                          </Button>
                        </Stack.Item>
                      ))}
                    </Stack>
                  </Stack.Item>
                </Stack>
              )}

              {spray_mode === 'rune' && (
                <Stack vertical>
                  <Stack.Item>
                    <Button
                      fluid
                      icon="random"
                      onClick={() => act('random_rune')}
                    >
                      Случайная руна
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Stack wrap justify="center">
                      {rune_list.map((rState) => (
                        <Stack.Item key={rState}>
                          <Button
                            tooltip={rState}
                            selected={drawtype === rState}
                            p={0.5}
                            onClick={() =>
                              act('select_drawtype', { drawtype: rState })
                            }
                          >
                            <DmIcon
                              icon="icons/effects/crayondecal.dmi"
                              icon_state={rState}
                              color={colour}
                              width="32px"
                              height="32px"
                            />
                          </Button>
                        </Stack.Item>
                      ))}
                    </Stack>
                  </Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
