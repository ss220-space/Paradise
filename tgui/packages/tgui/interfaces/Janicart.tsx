import { useBackend } from '../backend';
import { Button, Stack } from '../components';
import { Window } from '../layouts';

type JanicartData = {
  mybag: string;
  mymop: string;
  myspray: string;
  myreplacer: string;
  signs: string;
};

export const Janicart = (_properties) => {
  const { act, data } = useBackend<JanicartData>();
  const { mybag, mymop, myspray, myreplacer, signs } = data;
  return (
    <Window width={240} height={160}>
      <Window.Content>
        <Stack vertical>
          {!!mybag && (
            <Stack.Item>
              <Button onClick={() => act('garbage')}>{mybag}</Button>
            </Stack.Item>
          )}
          {!!mymop && (
            <Stack.Item>
              <Button onClick={() => act('mop')}>{mymop}</Button>
            </Stack.Item>
          )}
          {!!myspray && (
            <Stack.Item>
              <Button onClick={() => act('spray')}>{myspray}</Button>
            </Stack.Item>
          )}
          {!!myreplacer && (
            <Stack.Item>
              <Button onClick={() => act('replacer')}>{myreplacer}</Button>
            </Stack.Item>
          )}
          {!!signs && (
            <Stack.Item>
              <Button onClick={() => act('sign')}>
                Количество табличек: {signs}
              </Button>
            </Stack.Item>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
};
