import { Button } from 'tgui-core/components';
import { useBackend } from '../../backend';

export const LogisticsButton = (props: { enabled?: boolean }) => {
  const { act } = useBackend();
  return (
    <Button
      icon="boxes"
      tooltip="Логистика"
      tooltipPosition="bottom"
      disabled={!props.enabled}
      onClick={() => act('open_logistics')}
    />
  );
};
