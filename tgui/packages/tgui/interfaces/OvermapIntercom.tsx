import { useEffect, useMemo, useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Input,
  NoticeBox,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';
import { type BooleanLike, classes } from 'tgui-core/react';

import { useBackend, useLocalState } from '../backend';
import { OvermapFrame, OvermapRail } from './overmap/OvermapChrome';

type CommsMessage = {
  id: string;
  sender: string;
  time: string;
  encrypted: BooleanLike;
  unlocked: BooleanLike;
  channel: string;
  text: string;
};

type Cipher = {
  key: string;
  label: string;
  mask: string;
  autodecrypt: BooleanLike;
  announce: BooleanLike;
};

type Data = {
  linked: BooleanLike;
  sector_name?: string;
  vessel_name?: string;
  cooldown: number;
  can_send: BooleanLike;
  jammed: BooleanLike;
  max_body: number;
  key_len: number;
  beep_muted: BooleanLike;
  send_key?: string;
  messages: CommsMessage[];
  ciphers: Cipher[];
};

const randomKey = (len: number) => {
  const chars =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let out = '';
  for (let i = 0; i < len; i++) {
    out += chars[Math.floor(Math.random() * chars.length)];
  }
  return out;
};

const CryptoLamp = (props: { locked: boolean; encrypted: boolean }) => {
  const { locked, encrypted } = props;
  if (!encrypted) {
    return (
      <span className="OvermapCommsLamp OvermapCommsLamp--clear">Открыто</span>
    );
  }
  return (
    <span
      className={classes([
        'OvermapCommsLamp',
        locked ? 'OvermapCommsLamp--locked' : 'OvermapCommsLamp--open',
      ])}
    >
      <span className="OvermapCommsLamp__dot" />
      {locked ? 'ЗАШИФРОВАНО' : 'РАСШИФРОВАНО'}
    </span>
  );
};

export const OvermapIntercom = () => {
  const { act, data } = useBackend<Data>();
  const {
    linked,
    sector_name,
    vessel_name,
    cooldown,
    can_send,
    jammed,
    max_body,
    key_len = 6,
    beep_muted,
    send_key = '',
    messages = [],
    ciphers = [],
  } = data;
  const [draft, setDraft] = useLocalState('commsDraft', '');
  const [listenKey, setListenKey] = useLocalState('commsListenKey', '');
  const [listenLabel, setListenLabel] = useLocalState('commsListenLabel', '');
  const [filter, setFilter] = useLocalState('commsFilter', '');
  const [decryptKeys, setDecryptKeys] = useState<Record<string, string>>({});
  const [cooldownLeft, setCooldownLeft] = useState(cooldown);

  useEffect(() => {
    setCooldownLeft(cooldown);
  }, [cooldown]);

  useEffect(() => {
    if (cooldownLeft <= 0) {
      return;
    }
    const timer = window.setTimeout(() => {
      setCooldownLeft((prev) => Math.max(0, prev - 1));
    }, 1000);
    return () => window.clearTimeout(timer);
  }, [cooldownLeft]);

  const filtered = useMemo(() => {
    const q = filter.trim().toLowerCase();
    if (!q) {
      return messages;
    }
    return messages.filter(
      (message) =>
        message.sender.toLowerCase().includes(q) ||
        message.channel.toLowerCase().includes(q),
    );
  }, [messages, filter]);

  return (
    <OvermapFrame
      title="Sector Comms"
      width={920}
      height={720}
      linked={linked}
      onRelink={() => act('relink')}
      rail={
        <OvermapRail
          name={vessel_name || 'Панель связи'}
          sector={sector_name}
          lamps={[
            { label: 'эфир', on: !!can_send || cooldownLeft > 0 },
            { label: 'кд', warn: cooldownLeft > 0, on: cooldownLeft > 0 },
            { label: 'помехи', bad: !!jammed, on: !!jammed },
            { label: 'beep', on: !beep_muted, warn: !!beep_muted },
          ]}
          extra={
            <Button
              icon={beep_muted ? 'volume-mute' : 'volume-up'}
              tooltip={
                beep_muted
                  ? 'Beep выключен (голосовые оповещения шифра остаются)'
                  : 'Заглушить beep'
              }
              selected={!!beep_muted}
              onClick={() => act('toggle_beep')}
            />
          }
        />
      }
    >
      <Stack fill>
        <Stack.Item width="34%" minWidth={0}>
          <Stack fill vertical>
            <Stack.Item shrink={0}>
              <Section title="Передача">
                {!!jammed && (
                  <NoticeBox danger>
                    Помехи гипертранслятора. Передача недоступна.
                  </NoticeBox>
                )}
                <TextArea
                  fluid
                  height={4}
                  maxLength={max_body}
                  placeholder="Текст сообщения. Enter — новая строка."
                  value={draft}
                  onChange={setDraft}
                />
                <Box mt={0.8} mb={0.3} className="OvermapStat__label">
                  Ключ шифрования
                </Box>
                <Stack>
                  <Stack.Item grow>
                    <Input
                      fluid
                      placeholder="пусто = глобально"
                      value={send_key}
                      maxLength={32}
                      onChange={(value) => act('set_send_key', { key: value })}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="key"
                      tooltip={`Случайный ключ из ${key_len} символов`}
                      onClick={() =>
                        act('set_send_key', { key: randomKey(key_len) })
                      }
                    >
                      Случ.
                    </Button>
                  </Stack.Item>
                </Stack>
                <Button
                  fluid
                  mt={0.8}
                  icon="paper-plane"
                  color="good"
                  disabled={!can_send || cooldownLeft > 0 || !draft.trim()}
                  onClick={() => {
                    act('send', { text: draft, key: send_key });
                    setDraft('');
                  }}
                >
                  {cooldownLeft > 0 ? `КД ${cooldownLeft} с` : 'Отправить'}
                </Button>
              </Section>
            </Stack.Item>
            <Stack.Item grow minHeight={0}>
              <Section fill scrollable title="Прослушивание шифров">
                <Input
                  fluid
                  mb={0.5}
                  placeholder="Название канала…"
                  value={listenLabel}
                  maxLength={32}
                  onChange={setListenLabel}
                />
                <Stack>
                  <Stack.Item grow>
                    <Input
                      fluid
                      placeholder="Ключ…"
                      value={listenKey}
                      maxLength={32}
                      onChange={setListenKey}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="plus"
                      disabled={!listenKey.trim() || !listenLabel.trim()}
                      onClick={() => {
                        act('add_cipher', {
                          key: listenKey,
                          label: listenLabel,
                        });
                        setListenKey('');
                        setListenLabel('');
                      }}
                    >
                      Добавить
                    </Button>
                  </Stack.Item>
                </Stack>
                <Box mt={1}>
                  {!ciphers.length && (
                    <Box className="OvermapRail__meta">Список пуст.</Box>
                  )}
                  {ciphers.map((cipher) => (
                    <Box key={cipher.key} className="OvermapCommsCipher" mb={1}>
                      <Stack align="center">
                        <Stack.Item grow>
                          <Box bold>{cipher.label}</Box>
                          <Box className="OvermapCommsCipher__mask">
                            {cipher.mask}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="pen"
                            compact
                            tooltip="Подставить в ключ передачи"
                            onClick={() =>
                              act('use_cipher', { key: cipher.key })
                            }
                          >
                            Исп.
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="times"
                            compact
                            tooltip="Удалить"
                            onClick={() =>
                              act('remove_cipher', { key: cipher.key })
                            }
                          />
                        </Stack.Item>
                      </Stack>
                      <Stack mt={0.5}>
                        <Stack.Item grow>
                          <Button
                            fluid
                            selected={!!cipher.autodecrypt}
                            onClick={() =>
                              act('toggle_cipher', {
                                key: cipher.key,
                                flag: 'autodecrypt',
                              })
                            }
                          >
                            Авторасшифровка
                          </Button>
                        </Stack.Item>
                        <Stack.Item grow>
                          <Button
                            fluid
                            selected={!!cipher.announce}
                            onClick={() =>
                              act('toggle_cipher', {
                                key: cipher.key,
                                flag: 'announce',
                              })
                            }
                          >
                            Оповещение
                          </Button>
                        </Stack.Item>
                      </Stack>
                    </Box>
                  ))}
                </Box>
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow minWidth={0}>
          <Section
            fill
            scrollable
            title="Журнал сектора"
            buttons={
              <Input
                width={16}
                placeholder="Фильтр…"
                value={filter}
                onChange={setFilter}
              />
            }
          >
            {!filtered.length && (
              <Box className="OvermapRail__meta">Сообщений нет.</Box>
            )}
            {filtered.map((message) => {
              const locked = !!message.encrypted && !message.unlocked;
              return (
                <Box key={message.id} className="OvermapCommsMsg" mb={1}>
                  <Stack align="center">
                    <Stack.Item grow>
                      <Box bold>{message.sender}</Box>
                      <Box className="OvermapRail__meta">
                        {message.channel} · {message.time} назад
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <CryptoLamp
                        encrypted={!!message.encrypted}
                        locked={locked}
                      />
                    </Stack.Item>
                  </Stack>
                  <Collapsible title="Показать сообщение" mt={0.5}>
                    <Box
                      className="OvermapCommsMsg__body"
                      style={{
                        whiteSpace: 'pre-wrap',
                        wordBreak: 'break-word',
                        fontFamily: locked ? 'monospace' : undefined,
                      }}
                    >
                      {message.text}
                    </Box>
                    {locked && (
                      <Stack mt={1}>
                        <Stack.Item grow>
                          <Input
                            fluid
                            placeholder="Ключ для расшифровки"
                            value={decryptKeys[message.id] || ''}
                            maxLength={32}
                            onChange={(value) =>
                              setDecryptKeys((prev) => ({
                                ...prev,
                                [message.id]: value,
                              }))
                            }
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            icon="unlock"
                            onClick={() =>
                              act('decrypt', {
                                id: message.id,
                                key: decryptKeys[message.id] || '',
                              })
                            }
                          >
                            Расшифровать
                          </Button>
                        </Stack.Item>
                      </Stack>
                    )}
                  </Collapsible>
                </Box>
              );
            })}
          </Section>
        </Stack.Item>
      </Stack>
    </OvermapFrame>
  );
};
