import { useBackend } from '../../backend';
import { Button } from '../../components';

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
