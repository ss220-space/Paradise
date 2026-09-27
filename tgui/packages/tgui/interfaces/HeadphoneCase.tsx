import { useState } from 'react';
import { Box, Button, DmIcon, Input, Knob, NoticeBox, ProgressBar, Section, Stack } from 'tgui-core/components';
import { Countdown } from '../components';
import { classes } from 'tgui-core/react';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  icon: string;
  icon_state: string;
  powered: BooleanLike;
  playing: BooleanLike;
  left_inside: BooleanLike;
  right_inside: BooleanLike;
  left_missing: BooleanLike;
  right_missing: BooleanLike;
  left_bud_overlay: string | null;
  right_bud_overlay: string | null;
  track_selected: string | null;
  track_length: number | null;
  volume: number;
  max_volume: number;
  start_time: number;
  end_time: number;
  world_time: number;
  cooldown: number;
  sources: string;
  network_available: BooleanLike;
};

const BAND_COUNT = 7;
const MAX_TITLE_LENGTH = 26;

const formatTime = (deciseconds: number): string => {
  const total = Math.max(0, Math.round(deciseconds / 10));
  const minutes = Math.floor(total / 60);
  const seconds = total % 60;
  return `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
};

const Equalizer = (props: { playing: BooleanLike }) => (
  <Box className="HeadphoneCase__equalizer">
    {Array.from({ length: BAND_COUNT }, (unused, band) => (
      <Box
        key={band}
        className={classes([
          'HeadphoneCase__bandBar',
          props.playing && 'HeadphoneCase__bandBar--playing',
        ])}
        style={{ animationDelay: `${band * 130}ms` }}
      />
    ))}
  </Box>
);

const CaseView = () => {
  const { data } = useBackend<Data>();
  const { icon, icon_state, powered, left_bud_overlay, right_bud_overlay } =
    data;

  return (
    <Box position="relative" width="96px" height="96px">
      {!!powered && <Box className="HeadphoneCase__caseGlow" />}
      {[icon_state, left_bud_overlay, right_bud_overlay].map(
        (state) =>
          state && (
            <DmIcon
              key={state}
              icon={icon}
              icon_state={state}
              width="96px"
              height="96px"
              position="absolute"
              top="0px"
              left="0px"
            />
          )
      )}
    </Box>
  );
};

const BudButton = (props: {
  label: string;
  inside: BooleanLike;
  missing: BooleanLike;
  side: string;
}) => {
  const { act } = useBackend<Data>();
  const { label, inside, missing, side } = props;

  return (
    <Button
      fluid
      icon={missing ? 'triangle-exclamation' : 'headphones'}
      disabled={!inside}
      color={missing ? 'bad' : 'transparent'}
      tooltip={
        missing
          ? 'Наушник потерян'
          : inside
            ? 'Достать наушник из кейса'
            : 'Наушник уже снаружи'
      }
      onClick={() => act('eject', { side })}
    >
      {label}
    </Button>
  );
};

const Display = () => {
  const { data } = useBackend<Data>();
  const {
    playing,
    track_selected,
    track_length,
    start_time,
    end_time,
    world_time,
  } = data;

  const title = track_selected ?? '— нет трека —';

  return (
    <Box
      className={classes([
        'HeadphoneCase__screen',
        !playing && 'HeadphoneCase__screen--idle',
      ])}
    >
      <Stack align="center">
        <Stack.Item grow>
          <Box className="HeadphoneCase__title">
            {playing && title.length > MAX_TITLE_LENGTH ? (
              <marquee>{title}</marquee>
            ) : (
              title
            )}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Equalizer playing={playing} />
        </Stack.Item>
      </Stack>
      <Stack align="center">
        <Stack.Item grow>
          {playing ? (
            <ProgressBar
              className="HeadphoneCase__bar"
              minValue={start_time}
              maxValue={end_time}
              value={world_time}
            />
          ) : (
            <Box className="HeadphoneCase__bar" />
          )}
        </Stack.Item>
        <Stack.Item className="HeadphoneCase__time">
          {playing ? (
            <Countdown
              timeStart={world_time}
              timeEnd={end_time}
              format={(value, formatted) => formatted.substring(3)}
            />
          ) : (
            formatTime(track_length ?? 0)
          )}
        </Stack.Item>
      </Stack>
    </Box>
  );
};

export const HeadphoneCase = () => {
  const { act, data } = useBackend<Data>();
  const {
    powered,
    playing,
    left_inside,
    right_inside,
    left_missing,
    right_missing,
    track_selected,
    volume,
    max_volume,
    cooldown,
    sources,
    network_available,
  } = data;

  const [url, setUrl] = useState('');

  return (
    <Window width={380} height={510} theme="headphones" title="Кейс наушников">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section>
              <Stack align="center">
                <Stack.Item>
                  <CaseView />
                </Stack.Item>
                <Stack.Item grow>
                  <Stack vertical>
                    <Stack.Item>
                      <Button
                        fluid
                        icon="power-off"
                        selected={powered}
                        textAlign="center"
                        onClick={() => act('power')}
                      >
                        {powered ? 'Включен' : 'Выключен'}
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <BudButton
                        label="Левый"
                        side="left"
                        inside={left_inside}
                        missing={left_missing}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <BudButton
                        label="Правый"
                        side="right"
                        inside={right_inside}
                        missing={right_missing}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Section fill title="Проигрыватель">
              {!network_available ? (
                <NoticeBox danger>Медиасеть станции недоступна.</NoticeBox>
              ) : (
                <Stack fill vertical>
                  <Stack.Item>
                    <Display />
                  </Stack.Item>
                  <Stack.Item>
                    <Stack>
                      <Stack.Item grow>
                        <Input
                          fluid
                          value={url}
                          disabled={!powered || cooldown > 0}
                          placeholder={
                            cooldown > 0
                              ? `Приём сигнала... ${cooldown} с`
                              : 'Ссылка на трек'
                          }
                          onChange={setUrl}
                          onEnter={(value) => {
                            act('play', { url: value });
                            setUrl('');
                          }}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="play"
                          disabled={!powered || cooldown > 0 || !url}
                          tooltip="Поставить трек по ссылке"
                          onClick={() => {
                            act('play', { url });
                            setUrl('');
                          }}
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Item>
                    <Stack>
                      <Stack.Item grow>
                        <Button
                          fluid
                          icon="rotate-right"
                          textAlign="center"
                          disabled={!powered || !track_selected || !!playing}
                          tooltip="Включить загруженный трек заново"
                          onClick={() => act('replay')}
                        >
                          Заново
                        </Button>
                      </Stack.Item>
                      <Stack.Item grow>
                        <Button
                          fluid
                          icon="stop"
                          textAlign="center"
                          disabled={!playing}
                          onClick={() => act('stop')}
                        >
                          Стоп
                        </Button>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Item grow textAlign="center" textColor="label">
                    <Knob
                      size={2}
                      value={volume}
                      unit="%"
                      minValue={0}
                      maxValue={max_volume}
                      step={1}
                      stepPixelSize={5}
                      onChange={(event, value) =>
                        act('volume', { volume: value })
                      }
                    />
                    Громкость
                  </Stack.Item>
                </Stack>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <NoticeBox info>Источники: {sources}</NoticeBox>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
