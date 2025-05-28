import { useBackend } from '../../backend';
import { Button, NoticeBox, Stack } from '../../components';

export type LoginState = { name: string; rank: string; id: boolean };
type LoginInfoData = {
  loginState: LoginState;
};
/**
 * Displays a notice box displaying the current login state.
 *
 * Also gives an option to log off (calls `login_logout` TGUI action)
 * @param {object} _properties
 */
export const LoginInfo = (_properties) => {
  const { act, data } = useBackend<LoginInfoData>();
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
            color="good"
            onClick={() => act('login_logout')}
          >
            Выйти из системы
          </Button>
          <Button
            icon="eject"
            disabled={!loginState.id}
            color="good"
            onClick={() => act('login_eject')}
          >
            Извлечь ID
          </Button>
        </Stack.Item>
      </Stack>
    </NoticeBox>
  );
};
