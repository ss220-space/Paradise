import { sortBy } from 'common/collections';
import {
  Box,
  Button,
  Knob,
  ProgressBar,
  Section,
  Stack,
  Dimmer,
  Icon,
} from '../components';
import type { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Song = {
  name: string;
  length: number;
  beat: number;
};

type Data = {
  active: BooleanLike;
  looping: BooleanLike;
  need_coin: BooleanLike;
  advanced_admin: BooleanLike;
  volume: number;
  max_volume: number;
  start_time: number;
  end_time: number;
  world_time: number;
  track_selected: string | null;
  payment: string | null;
  songs: Song[];
};

export const Jukebox = () => {
  const { act, data } = useBackend<Data>();
  const {
    active,
    looping,
    track_selected,
    volume,
    max_volume,
    songs = [],
    start_time,
    end_time,
    world_time,
    need_coin,
    payment,
    advanced_admin,
  } = data;

  const MAX_NAME_LENGTH = 35;
  const need_payment = !payment && need_coin && !advanced_admin;
  const songs_sorted: Song[] = sortBy(songs, (song: Song) => song.name);
  const song_selected: Song | undefined = songs.find(
    (song) => song.name === track_selected
  );
  const totalTracks = songs_sorted.length;
  const selectedTrackNumber = song_selected
    ? songs_sorted.findIndex((song) => song.name === song_selected.name) + 1
    : 0;

  const formatTime = (seconds: number): string => {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    const formattedTime = `${String(minutes).padStart(2, '0')}:${String(remainingSeconds).padStart(2, '0')}`;
    return formattedTime;
  };

  const trackTimer = (
    <Box textAlign="center">
      {active
        ? looping
          ? '∞'
          : formatTime(Math.round((world_time - start_time) / 10))
        : looping
          ? '∞'
          : formatTime(song_selected?.length ?? 0)}{' '}
      / {looping ? '∞' : formatTime(song_selected?.length ?? 0)}
    </Box>
  );

  return (
    <Window width={350} height={435} title="Музыкальный автомат">
      {need_payment ? <NoCoin /> : null}
      <Window.Content>
        <Stack fill vertical>
          <Stack>
            <Stack.Item grow textAlign="center">
              <Section fill title="Проигрыватель">
                <Stack fill vertical>
                  <Stack.Item bold maxWidth="240px">
                    {song_selected &&
                    song_selected.name.length > MAX_NAME_LENGTH ? (
                      <marquee>{song_selected.name}</marquee>
                    ) : (
                      song_selected?.name
                    )}
                  </Stack.Item>
                  <Stack fill mt={1.5}>
                    <Stack.Item grow basis="0">
                      <Button
                        fluid
                        icon={active ? 'pause' : 'play'}
                        color="transparent"
                        selected={active}
                        onClick={() => act('toggle')}
                      >
                        {active ? 'Стоп' : 'Старт'}
                      </Button>
                    </Stack.Item>
                    <Stack.Item grow basis="0">
                      <Button.Checkbox
                        fluid
                        icon={'undo'}
                        disabled={active || (need_coin && !advanced_admin)}
                        tooltip={
                          need_coin && !advanced_admin
                            ? 'Вы не можете включить повтор за монетку'
                            : null
                        }
                        checked={looping}
                        onClick={() => act('loop', { looping: !looping })}
                      >
                        Повтор
                      </Button.Checkbox>
                    </Stack.Item>
                  </Stack>
                  <Stack.Item>
                    <ProgressBar.Countdown
                      start={start_time}
                      current={!looping ? world_time : end_time}
                      end={end_time}
                    >
                      {trackTimer}
                    </ProgressBar.Countdown>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
            <Stack.Item>
              <Section>
                {active ? <OnMusic /> : null}
                <Stack fill mb={1.5}>
                  <Stack.Item grow m={0}>
                    <Button
                      color="transparent"
                      icon="fast-backward"
                      onClick={() =>
                        act('set_volume', {
                          volume: 'min',
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item m={0}>
                    <Button
                      color="transparent"
                      icon="undo"
                      onClick={() =>
                        act('set_volume', {
                          volume: 'reset',
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item grow m={0} textAlign="right">
                    <Button
                      color="transparent"
                      icon="fast-forward"
                      onClick={() =>
                        act('set_volume', {
                          volume: 'max',
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
                <Stack.Item textAlign="center" textColor="label">
                  <Knob
                    size={2}
                    color={
                      volume <= 25
                        ? 'green'
                        : volume <= 50
                          ? ''
                          : volume <= 75
                            ? 'orange'
                            : 'red'
                    }
                    value={volume}
                    unit="%"
                    minValue={0}
                    maxValue={max_volume}
                    step={1}
                    stepPixelSize={5}
                    onChange={(e, value) =>
                      act('set_volume', {
                        volume: value,
                      })
                    }
                  />
                  Volume
                </Stack.Item>
              </Section>
            </Stack.Item>
          </Stack>
          <Stack.Item grow textAlign="center">
            <Section
              fill
              scrollable
              title="Доступные треки"
              buttons={
                <Button
                  bold
                  icon="random"
                  color="transparent"
                  tooltip="Выбрать случайный трек"
                  tooltipPosition="top-end"
                  onClick={() => {
                    if (totalTracks === 0) return;
                    const randomIndex = Math.floor(Math.random() * totalTracks);
                    const randomTrack = songs_sorted[randomIndex];
                    if (randomTrack) {
                      act('select_track', { track: randomTrack.name });
                    }
                  }}
                >
                  {`${selectedTrackNumber}/${totalTracks}`}
                </Button>
              }
            >
              {songs_sorted.map((song) => (
                <Stack.Item key={song.name} mb={0.5} textAlign="left">
                  <Button
                    fluid
                    selected={song_selected?.name === song.name}
                    color="translucent"
                    onClick={() => {
                      act('select_track', { track: song.name });
                    }}
                  >
                    {
                      <Stack fill>
                        <Stack.Item grow>{song.name}</Stack.Item>
                        <Stack.Item>{formatTime(song.length)}</Stack.Item>
                      </Stack>
                    }
                  </Button>
                </Stack.Item>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const OnMusic = () => {
  return (
    <Dimmer textAlign="center">
      <Icon name="music" size={3} color="gray" mb={1} />
      <Box color="label" bold>
        Играет музыка
      </Box>
    </Dimmer>
  );
};

const NoCoin = () => {
  return (
    <Dimmer textAlign="center">
      <Icon name="coins" size={6} color="gold" mr={1} />
      <Box color="label" bold mt={5} fontSize={2}>
        Вставьте монетку
      </Box>
    </Dimmer>
  );
};
