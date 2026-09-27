import { useBackend } from '../backend';
import { useState } from 'react';
import { Box, Button, Input, LabeledList, NoticeBox, ProgressBar, Section, Stack } from 'tgui-core/components';
import { Window } from '../layouts';

type ReferralsData = {
  code: string;
  can_enter: boolean;
  discord_linked: boolean;
  referrer: string | null;
  rewarded: boolean;
  revoked: boolean;
  minutes: number;
  days: number;
  invited: number;
  invited_rewarded: number;
  active_until: string | null;
  required_minutes: number;
  required_days: number;
  max_player_age: number;
  reward_days: number;
  referrer_min_hours: number;
  invites_per_tier: number;
  tier: number;
  error: string | null;
};

export const Referrals = (props: unknown) => {
  const { act, data } = useBackend<ReferralsData>();
  const {
    code,
    can_enter,
    discord_linked,
    referrer,
    rewarded,
    revoked,
    minutes,
    days,
    invited,
    invited_rewarded,
    active_until,
    required_minutes,
    required_days,
    max_player_age,
    reward_days,
    referrer_min_hours,
    invites_per_tier,
    tier,
    error,
  } = data;
  const [enteredCode, setEnteredCode] = useState('');

  return (
    <Window width={480} height={560}>
      <Window.Content scrollable>
        <Section
          title="Ваш код"
          buttons={
            <Button icon="rotate" onClick={() => act('refresh')}>
              Обновить
            </Button>
          }
        >
          <Box fontSize="1.5rem" bold color="good" mb="0.5rem">
            {code}
          </Box>
          <LabeledList>
            <LabeledList.Item label="Приглашено">{invited}</LabeledList.Item>
            <LabeledList.Item label="Освоились">
              {invited_rewarded}
            </LabeledList.Item>
            <LabeledList.Item label="Уровень подписки">
              {active_until ? tier : 'не начислен'}
            </LabeledList.Item>
            <LabeledList.Item label="Подписка активна до">
              {active_until || 'не начислена'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!!referrer && (
          <Section title="Вас пригласил">
            <Box mb="0.5rem">
              <Box bold as="span">
                {referrer}
              </Box>
              {revoked
                ? ' — приглашение аннулировано: вы играли с компьютера или адреса пригласившего.'
                : rewarded
                  ? ' — награда уже начислена. Спасибо!'
                  : ' — награда будет начислена, когда вы освоитесь на станции.'}
            </Box>
            {!rewarded && !revoked && (
              <Stack vertical>
                <Stack.Item>
                  <ProgressBar
                    value={minutes}
                    minValue={0}
                    maxValue={required_minutes}
                    ranges={{ good: [required_minutes, Infinity] }}
                  >
                    {`Наиграно: ${Math.floor(minutes / 60)} / ${Math.floor(
                      required_minutes / 60
                    )} ч`}
                  </ProgressBar>
                </Stack.Item>
                <Stack.Item>
                  <ProgressBar
                    value={days}
                    minValue={0}
                    maxValue={required_days}
                    ranges={{ good: [required_days, Infinity] }}
                  >
                    {`Дней с игрой: ${days} / ${required_days}`}
                  </ProgressBar>
                </Stack.Item>
              </Stack>
            )}
          </Section>
        )}
        {!referrer && (
          <Section title="Ввести код">
            {!!error && <NoticeBox danger>{error}</NoticeBox>}
            {!can_enter ? (
              <Box color="label">
                {`Код принимается только в первые ${max_player_age} дней после первого захода на сервер.`}
              </Box>
            ) : !discord_linked ? (
              <Box color="label">
                Сначала привяжите аккаунт Discord — кнопка «Привязка Discord» в
                лобби.
              </Box>
            ) : (
              <Stack>
                <Stack.Item grow>
                  <Input
                    fluid
                    value={enteredCode}
                    placeholder="Код пригласившего"
                    onChange={setEnteredCode}
                    onEnter={(value) => act('apply', { code: value })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="check"
                    disabled={!enteredCode}
                    onClick={() => act('apply', { code: enteredCode })}
                  >
                    Применить
                  </Button>
                </Stack.Item>
              </Stack>
            )}
          </Section>
        )}
        <Section title="Как это работает">
          <Box color="label">
            <Box>
              Ваш код — это ваш ckey. Отдайте его тому, кого зовёте на сервер.
            </Box>
            <Box mt="0.5rem">
              {`Новичок вводит код в первые ${max_player_age} дней после первого захода.`}
            </Box>
            <Box mt="0.5rem">
              {`Как только он наиграет ${Math.floor(
                required_minutes / 60
              )} часов минимум за ${required_days} разных дня, вам начислится первый уровень подписки на ${reward_days} дней. Каждое следующее приглашение продлевает срок ещё на ${reward_days} дней.`}
            </Box>
            <Box mt="0.5rem">
              {`Каждое ${invites_per_tier}-е приглашение поднимает уровень подписки на единицу, а срок отсчитывается заново с ${reward_days} дней.`}
            </Box>
            <Box mt="0.5rem">
              {`Приглашать могут те, кто наиграл больше ${referrer_min_hours} часов. Один аккаунт — один код, навсегда.`}
            </Box>
            <Box mt="0.5rem">
              Мультиаккаунты не проходят: код не примут с компьютера, на котором
              уже играли, и с компьютера или адреса пригласившего.
            </Box>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
