import { useBackend } from '../../backend';
import { Button, NoticeBox, Stack } from '../../components';

/**
 * Displays a notice box displaying the current login state.
 *
 * Also gives an option to log off (calls `login_logout` TGUI action)
 * @param {object} _properties
 * @param {object} context
 */
export const LoginInfo = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { loginState } = data;
  if (!data) {
    return;
  }
  return (
    <NoticeBox info>
      <Stack>
        <Stack.Item grow mt={0.5}>
          Выполнен вход в систему как: {loginState.name} ({loginState.rank})
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="sign-out-alt"
            content="Выйти из системы"
            color="good"
            onClick={() => act('login_logout')}
          />
          <Button
            icon="eject"
            disabled={!loginState.id}
            content="Извлечь ID"
            color="good"
            onClick={() => act('login_eject')}
          />
        </Stack.Item>
      </Stack>
    </NoticeBox>
  );
};
