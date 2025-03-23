import { useBackend } from '../../backend';
import { Box, Button } from '../../components';
import { useCompact } from './hooks';
import { PodLauncherData } from './types';

export const PodLaunch = (props, context) => {
  const { act, data } = useBackend<PodLauncherData>(context);
  const { giveLauncher } = data;

  const [compact] = useCompact(context);

  return (
    <Button
      fluid
      onClick={() => act('giveLauncher')}
      selected={giveLauncher}
      textAlign="center"
      tooltip={`
        Вы должны знать, что
        Об этом говорит Кодекс Астартес`}
      tooltipPosition="top"
    >
      <Box bold fontSize="1.4em" lineHeight={compact ? 1.5 : 3}>
        ЗАПУСК
      </Box>
    </Button>
  );
};
