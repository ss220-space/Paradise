import { Box, Button, Dimmer, Icon, Section, Stack } from '../../components';

import { useBackend } from '../../backend';
import type { MainData } from './data';
import { useHonk } from './honk';

export const InternalDamageToDamagedDesc = {
  MECHA_INT_FIRE: 'Внутренний пожар обнаружен',
  MECHA_INT_TEMP_CONTROL: 'Терморегулятор выключен',
  MECHA_INT_TANK_BREACH: 'Кабина повреждена',
  MECHA_INT_CONTROL_LOST: 'Моторы повреждены',
  MECHA_INT_SHORT_CIRCUIT: 'Короткое замыкание',
};

export const InternalDamageToNormalDesc = {
  MECHA_INT_FIRE: 'Пожаров не обнаружено',
  MECHA_INT_TEMP_CONTROL: 'Терморегулятор активен',
  MECHA_INT_TANK_BREACH: 'Кабина цела',
  MECHA_INT_CONTROL_LOST: 'Моторы активны',
  MECHA_INT_SHORT_CIRCUIT: 'Платы работоспособны',
};

export const AlertPane = (props) => {
  const { act, data } = useBackend<MainData>();
  const { internal_damage, internal_damage_keys, ui_honked } = data;
  const honk = useHonk(ui_honked ? 0.4 : 0);
  return (
    <Section title={honk('Статус')}>
      <Stack vertical>
        {Object.keys(internal_damage_keys).map((t) => (
          <Stack.Item key={t}>
            <Stack justify="space-between">
              <Stack.Item>
                <Box
                  color={
                    internal_damage & internal_damage_keys[t] ? 'bad' : 'good'
                  }
                  style={{ textShadow: '1px 1px 0 black' }}
                >
                  <Icon
                    mr={1}
                    name={
                      internal_damage & internal_damage_keys[t]
                        ? 'warning'
                        : 'check'
                    }
                  />
                  {honk(
                    internal_damage & internal_damage_keys[t]
                      ? InternalDamageToDamagedDesc[t]
                      : InternalDamageToNormalDesc[t]
                  )}
                </Box>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};
