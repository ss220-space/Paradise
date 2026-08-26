import { map } from 'common/collections';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, NumberInput, Section } from '../components';
import { Channel, RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';

type RadioData = {
  freqlock: boolean;
  canReset: boolean;
  listening: boolean;
  broadcasting: boolean;
  loudspeaker: boolean;
  has_loudspeaker: boolean;
  schannels: Channel[];
  ichannels: Channel[];
} & Frequency;

export const Radio = (_props: unknown) => {
  const { act, data } = useBackend<RadioData>();
  const {
    freqlock,
    frequency,
    minFrequency,
    maxFrequency,
    canReset,
    listening,
    broadcasting,
    loudspeaker,
    has_loudspeaker,
  } = data;
  const tunedChannel = RADIO_CHANNELS.find(
    (channel) => channel.freq === frequency
  );
  let matchedChannel = tunedChannel && tunedChannel.name ? true : false;
  let colorMap = [];
  let rc: Channel;
  let i = 0;
  for (i = 0; i < RADIO_CHANNELS.length; i++) {
    rc = RADIO_CHANNELS[i];
    colorMap[rc.name] = rc.color;
  }
  const schannels = map(data.schannels, (value, key) => ({
    name: key.toString(),
    status: !!value,
  }));
  const ichannels = map(data.ichannels, (value, key) => ({
    name: key.toString(),
    freq: value,
  }));
  return (
    <Window
      width={400}
      height={150 + schannels.length * 20 + ichannels.length * 10}
    >
      <Window.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Частота">
              {(freqlock && (
                <Box inline color="light-gray">
                  {toFixed(frequency / 10, 1) + ' кГц'}
                </Box>
              )) || (
                <>
                  <NumberInput
                    animated
                    unit="кГц"
                    step={0.2}
                    stepPixelSize={10}
                    minValue={minFrequency / 10}
                    maxValue={maxFrequency / 10}
                    value={frequency / 10}
                    format={(value) => toFixed(value, 1)}
                    onChange={(value) =>
                      act('frequency', {
                        adjust: value - frequency / 10,
                      })
                    }
                  />
                  <Button
                    icon="undo"
                    disabled={!canReset}
                    tooltip="Сброс"
                    onClick={() =>
                      act('frequency', {
                        tune: 'reset',
                      })
                    }
                  />
                </>
              )}
              {matchedChannel && (
                <Box inline color={tunedChannel.color} ml={2}>
                  [{tunedChannel.name}]
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Аудио">
              <Button
                textAlign="center"
                width="37px"
                icon={listening ? 'volume-up' : 'volume-mute'}
                selected={listening}
                color={listening ? '' : 'bad'}
                tooltip={
                  listening
                    ? 'Отключить входящий сигнал'
                    : 'Включить входящий сигнал'
                }
                onClick={() => act('listen')}
              />
              <Button
                textAlign="center"
                width="37px"
                icon={broadcasting ? 'microphone' : 'microphone-slash'}
                selected={broadcasting}
                tooltip={
                  broadcasting
                    ? 'Отключить активный микрофон'
                    : 'Включить активный микрофон'
                }
                onClick={() => act('broadcast')}
              />
              {!!has_loudspeaker && (
                <Button
                  ml={1}
                  icon="bullhorn"
                  selected={loudspeaker}
                  tooltip={
                    loudspeaker
                      ? 'Отключить громкоговоритель'
                      : 'Включить громкоговоритель'
                  }
                  onClick={() => act('loudspeaker')}
                >
                  Громкоговоритель
                </Button>
              )}
            </LabeledList.Item>
            {schannels.length !== 0 && (
              <LabeledList.Item label="Частоты ключей шифрования">
                {schannels.map((channel) => (
                  <Box key={channel.name}>
                    <Button
                      icon={channel.status ? 'check-square-o' : 'square-o'}
                      selected={channel.status}
                      onClick={() =>
                        act('channel', {
                          channel: channel.name,
                        })
                      }
                    />
                    <Box inline color={colorMap[channel.name]}>
                      {channel.name}
                    </Box>
                  </Box>
                ))}
              </LabeledList.Item>
            )}
            {ichannels.length !== 0 && (
              <LabeledList.Item label="Стандартные частоты">
                {ichannels.map((channel) => (
                  <Button
                    key={'i_' + channel.name}
                    icon="arrow-right"
                    selected={
                      matchedChannel && tunedChannel.name === channel.name
                    }
                    onClick={() =>
                      act('ichannel', {
                        ichannel: channel.freq,
                      })
                    }
                  >
                    {channel.name}
                  </Button>
                ))}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
