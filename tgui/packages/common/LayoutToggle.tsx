import { useBackend } from '../tgui/backend';
import { Button, Stack } from '../tgui/components';

type Props = {
  /** Current layout state, which will be passed. */
  state: string;
  /** useState function that must be passed in order to make a toggle functional. */
  setState: (newState: string) => void;
};

export enum LAYOUT {
  Grid = 'grid',
  List = 'list',
}

export const getLayoutState = (defaultState?: LAYOUT) => {
  const { config } = useBackend();
  return config.interface.layout;
};

/**
 * Allows the user to toggle between grid and list layouts, if preference on Default value.
 * Otherwise it'll be controlled by preferences.
 */
export const LayoutToggle = (props: Props) => {
  const { setState, state } = props;
  const { act } = useBackend();

  const handleClick = () => {
    const newState = state === LAYOUT.Grid ? LAYOUT.List : LAYOUT.Grid;
    setState(newState);
    act('change_ui_state', {
      new_state: newState,
    });
  };

  return (
    <Stack.Item>
      <Button
        icon={state === LAYOUT.Grid ? 'list' : 'border-all'}
        tooltip={
          state === LAYOUT.Grid
            ? 'Отобразить в виде списка'
            : 'Отобразить в виде сетки'
        }
        tooltipPosition={'bottom-end'}
        onClick={handleClick}
      />
    </Stack.Item>
  );
};
