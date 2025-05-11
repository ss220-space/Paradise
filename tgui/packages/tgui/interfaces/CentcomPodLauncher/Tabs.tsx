import { useBackend, useLocalState } from '../../backend';
import { Box, Button } from '../../components';
import { PodLauncherData } from './types';

export const TabPod = (props) => {
  const { act, data } = useBackend<PodLauncherData>();
  const { oldArea } = data;

  return (
    <>
      <Button disabled icon="street-view">
        Телепорт
      </Button>
      <Button disabled icon="undo-alt">
        {oldArea ? oldArea.substring(0, 17) : 'Назад'}
      </Button>
    </>
  );
};

export const TabBay = (props) => {
  const { act, data } = useBackend<PodLauncherData>();
  const [teleported, setTeleported] = useLocalState('teleported', false);
  const { oldArea } = data;

  return (
    <>
      <Button
        icon="street-view"
        onClick={() => {
          act('teleportCentcom');
          setTeleported(true);
        }}
      >
        Телепорт
      </Button>
      <Button
        disabled={!oldArea || !teleported}
        icon="undo-alt"
        onClick={() => {
          act('teleportBack');
          setTeleported(false);
        }}
      >
        {oldArea ? oldArea.substring(0, 17) : 'Назад'}
      </Button>
    </>
  );
};

export const TabDrop = (props) => {
  const { act, data } = useBackend<PodLauncherData>();
  const [teleported, setTeleported] = useLocalState('teleported', false);
  const { oldArea } = data;

  return (
    <>
      <Button
        icon="street-view"
        onClick={() => {
          act('teleportDropoff');
          setTeleported(true);
        }}
      >
        Телепорт
      </Button>
      <Button
        disabled={!oldArea || !teleported}
        icon="undo-alt"
        onClick={() => {
          act('teleportBack');
          setTeleported(false);
        }}
      >
        {oldArea ? oldArea.substring(0, 17) : 'Назад'}
      </Button>
    </>
  );
};
