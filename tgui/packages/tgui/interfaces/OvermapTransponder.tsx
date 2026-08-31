import { Box, Button, ColorBox, Dropdown, Input, Stack } from 'tgui-core/components';
import { type BooleanLike, classes } from 'tgui-core/react';

import { useBackend, useLocalState } from '../backend';
import {
  OvermapFrame,
  OvermapRail,
  OvermapStat,
  OvermapStats,
} from './overmap/OvermapChrome';

type ColorChoice = {
  name: string;
  color: string;
};

type IffChannel = {
  id: string;
  label: string;
  permanent: BooleanLike;
  receive: BooleanLike;
  transmit: BooleanLike;
  tone?: string;
};

type OvermapTransponderData = {
  linked: BooleanLike;
  broadcast_name: string;
  broadcast_color: string;
  broadcasting: BooleanLike;
  distress: BooleanLike;
  identity_locked: BooleanLike;
  transmitting: BooleanLike;
  colors?: ColorChoice[];
  channels?: IffChannel[];
};

const channelHint = (id: string) => {
  switch (id) {
    case 'global':
      return 'Открытый эфир. Вас видят только суда с включённым приёмом глобала. Приём — вы видите чужой глобальный эфир.';
    case 'centcom':
      return 'Закрытый канал Центкома. Нужен прошитый или введённый ключ.';
    case 'syndicate':
      return 'Закрытый канал Синдиката. Нужен прошитый или введённый ключ.';
    default:
      return 'Закрытый канал шифрования.';
  }
};

const IffSwitch = (props: {
  label: string;
  on: BooleanLike;
  onClick: () => void;
}) => (
  <button
    type="button"
    className={classes([
      'OvermapIffSwitch',
      props.on && 'OvermapIffSwitch--on',
    ])}
    onClick={props.onClick}
  >
    <span className="OvermapIffSwitch__label">{props.label}</span>
    <span className="OvermapIffSwitch__state">{props.on ? 'вкл' : 'выкл'}</span>
  </button>
);

export const OvermapTransponder = () => {
  const { act, data } = useBackend<OvermapTransponderData>();
  const {
    linked,
    broadcast_name,
    broadcast_color,
    broadcasting,
    distress,
    identity_locked,
    transmitting,
    colors = [],
    channels = [],
  } = data;
  const [keyDraft, setKeyDraft] = useLocalState('iffKeyDraft', '');
  const selectedColor =
    colors.find((choice) => choice.color === broadcast_color)?.name ||
    broadcast_color;

  return (
    <OvermapFrame
      title="Transponder"
      width={460}
      height={640}
      linked={linked}
      onRelink={() => act('relink')}
      rail={
        <OvermapRail
          name={broadcast_name || 'Transponder'}
          lamps={[
            { label: 'эфир', on: !!broadcasting },
            { label: 'видно', on: !!transmitting },
            { label: 'авария', bad: !!distress, on: !!distress },
          ]}
        />
      }
      actions={
        <Button
          icon="exclamation-triangle"
          color={distress ? 'bad' : undefined}
          selected={!!distress}
          onClick={() => act('toggle_distress')}
        >
          {distress ? 'Бедствие вкл' : 'Бедствие выкл'}
        </Button>
      }
    >
      <div className="OvermapPanel">
        <OvermapStats>
          <OvermapStat
            hero
            label="статус"
            value={transmitting ? 'в эфире' : 'скрыт'}
            tone={transmitting ? 'good' : 'warn'}
          />
          <OvermapStat
            hero
            label="бедствие"
            value={distress ? 'да' : 'нет'}
            tone={distress ? 'bad' : undefined}
          />
        </OvermapStats>
        <Box mt={1} mb={0.4} className="OvermapStat__label">
          Имя
        </Box>
        {identity_locked ? (
          <Box bold>{broadcast_name}</Box>
        ) : (
          <Input
            fluid
            value={broadcast_name}
            onChange={(value) => act('set_name', { name: value })}
          />
        )}
        <Box mt={1} mb={0.4} className="OvermapStat__label">
          Цвет IFF
        </Box>
        <ColorBox color={broadcast_color} mr={1} />
        <Dropdown
          width="220px"
          selected={selectedColor}
          options={colors.map((choice) => choice.name)}
          onSelected={(value) => act('set_color', { name: value })}
        />
        <Box mt={1.2} mb={0.5} className="OvermapStat__label">
          Ключи шифрования
        </Box>
        <div className="OvermapIffGrid">
          {channels.map((channel) => (
            <div
              key={channel.id}
              className={classes([
                'OvermapIffCard',
                `OvermapIffCard--${channel.tone || channel.id}`,
              ])}
            >
              <div className="OvermapIffCard__head">
                <div>
                  <div className="OvermapIffCard__title">{channel.label}</div>
                  <div className="OvermapIffCard__hint">
                    {channelHint(channel.id)}
                  </div>
                </div>
                <div className="OvermapIffCard__tags">
                  <span className="OvermapIffCard__tag">
                    {channel.permanent ? 'прошит' : 'ключ'}
                  </span>
                  {!channel.permanent && (
                    <Button
                      icon="times"
                      compact
                      tooltip="Удалить ключ"
                      onClick={() =>
                        act('remove_channel', { id: channel.id })
                      }
                    />
                  )}
                </div>
              </div>
              <div className="OvermapIffCard__switches">
                <IffSwitch
                  label="Приём"
                  on={channel.receive}
                  onClick={() =>
                    act('toggle_channel', {
                      id: channel.id,
                      side: 'receive',
                    })
                  }
                />
                <IffSwitch
                  label="Эфир"
                  on={channel.transmit}
                  onClick={() =>
                    act('toggle_channel', {
                      id: channel.id,
                      side: 'transmit',
                    })
                  }
                />
              </div>
            </div>
          ))}
        </div>
        <div className="OvermapIffSlot">
          <div className="OvermapIffSlot__label">Загрузить ключ</div>
          <Stack>
            <Stack.Item grow>
              <Input
                fluid
                className="OvermapIffSlot__input"
                placeholder="XXXXXXXX"
                value={keyDraft}
                onChange={setKeyDraft}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="lock"
                onClick={() => {
                  act('add_key', { key: keyDraft });
                  setKeyDraft('');
                }}
              >
                Принять
              </Button>
            </Stack.Item>
          </Stack>
        </div>
      </div>
    </OvermapFrame>
  );
};
